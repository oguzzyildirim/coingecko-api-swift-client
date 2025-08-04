//
//  APIProvider.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation
import CoinGeckoCore

public protocol GenericAPIProviderProtocol: Sendable {
    var bodyEncoding: BodyEncoding { get }
}

public enum BodyEncoding: Sendable {
    case json
    case urlEncoded
    
    var contentTypeHeader: String {
        switch self {
        case .json:
            return "application/json"
        case .urlEncoded:
            return "application/x-www-form-urlencoded"
        }
    }
}

public struct APIProvider<ResponseType: CodableModel>: APIEndpoint, GenericAPIProviderProtocol {
    public let baseURLString: String?
    public let apiVersion: String?
    public let separatorPath: String?
    public let path: String
    public let queryItems: [URLQueryItem]?
    public let params: [String: SendableValue]?
    public let method: APIHTTPMethod
    public let customDataBody: Data?
    public let bodyEncoding: BodyEncoding
    public let headers: [String: String]?
    
    public init(
            baseURLString: String? = APIConfiguration.shared.currentBaseURL,
            apiVersion: String? = nil,
            separatorPath: String? = nil,
            path: String,
            headers: [String: String]? = nil,
            queryItems: [URLQueryItem]? = nil,
            params: [String: Any]? = nil,
            method: APIHTTPMethod = .get,
            customDataBody: Data? = nil,
            bodyEncoding: BodyEncoding = .json
        ) {
            self.baseURLString = baseURLString
            self.apiVersion = apiVersion
            self.separatorPath = separatorPath
            self.path = path
            self.queryItems = queryItems
            self.method = method
            self.customDataBody = customDataBody
            self.bodyEncoding = bodyEncoding
            
            // Convert params to SendableValue
            self.params = params?.mapValues { SendableValue.from($0) }
            
            // Setup headers with content type
            var defaultHeaders = ["Content-Type": bodyEncoding.contentTypeHeader]
            if let apiKey = APIConfiguration.shared.apiKey {
                defaultHeaders["x-cg-demo-api-key"] = apiKey
            }
//            if let customHeaders = headers {
//                for (key, value) in customHeaders {
//                    defaultHeaders[key] = value
//                }
//            }
            self.headers = defaultHeaders
        }
        
        // Sendable params ile init
        public init(
            baseURLString: String? = APIConfiguration.shared.currentBaseURL,
            apiVersion: String? = nil,
            separatorPath: String? = nil,
            path: String,
            headers: [String: String]? = nil,
            queryItems: [URLQueryItem]? = nil,
            sendableParams: [String: SendableValue]? = nil,
            method: APIHTTPMethod = .get,
            customDataBody: Data? = nil,
            bodyEncoding: BodyEncoding = .json
        ) {
            self.baseURLString = baseURLString
            self.apiVersion = apiVersion
            self.separatorPath = separatorPath
            self.path = path
            self.queryItems = queryItems
            self.params = sendableParams
            self.method = method
            self.customDataBody = customDataBody
            self.bodyEncoding = bodyEncoding
            
            var defaultHeaders = ["Content-Type": bodyEncoding.contentTypeHeader]
            if let customHeaders = headers {
                for (key, value) in customHeaders {
                    defaultHeaders[key] = value
                }
            }
            self.headers = defaultHeaders
        }
}

public extension APIProvider {
    private func perform(service: APIServiceProtocol) async throws -> ResponseType {
        try await service.fetch(endpoint: self)
    }
    
//    func perform(
//        completion: @MainActor @escaping @Sendable (Result<ResponseType, Error>) -> Void
//    ) {
//        Task { @MainActor in
//            do {
//                let result = try await self.perform(service: APIService(httpClient: URLSession.shared))
//                completion(.success(result))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//    }
    
    func perform(
        completion: @MainActor @escaping @Sendable (Result<ResponseType, Error>) -> Void
    ) {
        Task {
            do {
                let response = try await self.execute()
                await MainActor.run {
                    completion(.success(response))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func execute() async throws -> ResponseType {
        let service = APIService(httpClient: URLSession.shared)
        return try await service.fetch(endpoint: self)
    }
}
