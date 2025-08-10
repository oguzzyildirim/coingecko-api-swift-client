//
//  APIProvider.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation
import CoinGeckoCore

/// A protocol that defines the required properties for a generic API provider.
/// Conforms to `Sendable` for thread-safe usage in concurrent contexts.
public protocol GenericAPIProviderProtocol: Sendable {
    /// The body encoding type used for the API request.
    var bodyEncoding: BodyEncoding { get }
}

/// Represents the encoding types for request bodies.
public enum BodyEncoding: Sendable {
    /// JSON encoding.
    case json
    /// URL-encoded form data.
    case urlEncoded
    
    /// The `Content-Type` header value associated with the encoding type.
    var contentTypeHeader: String {
        switch self {
        case .json:
            return "application/json"
        case .urlEncoded:
            return "application/x-www-form-urlencoded"
        }
    }
}

/// A generic API provider that conforms to `APIEndpoint` and `GenericAPIProviderProtocol`,
/// allowing configuration and execution of HTTP requests for a specific `ResponseType`.
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
    
    /// Initializes the API provider with non-sendable parameters.
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
        
        self.params = params?.mapValues { SendableValue.from($0) }
        
        var defaultHeaders = ["Content-Type": bodyEncoding.contentTypeHeader]
        if let apiKey = APIConfiguration.shared.apiKey {
            defaultHeaders["x-cg-demo-api-key"] = apiKey
        }
        self.headers = defaultHeaders
    }
    
    /// Initializes the API provider with sendable parameters.
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
    /// Executes the API request using the given service instance.
    private func perform(service: APIServiceProtocol) async throws -> ResponseType {
        try await service.fetch(endpoint: self)
    }
    
    /// Executes the API request asynchronously and returns the response via completion handler.
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
    
    /// Executes the API request asynchronously and returns the decoded `ResponseType`.
    func execute() async throws -> ResponseType {
        let service = APIService(httpClient: URLSession.shared)
        return try await service.fetch(endpoint: self)
    }
}
