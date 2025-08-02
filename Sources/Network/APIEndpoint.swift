//
//  APIEndpoint.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

/// Protocol that defines the requirements for API endpoints in the application
///
/// This protocol provides a standardized way to configure and create network requests
/// for different API endpoints by specifying URL components, HTTP method, headers, and body parameters.
public protocol APIEndpoint {
    var baseURLString: String { get }
    //var apiVersion: String? { get }
    //var separatorPath: String? { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var params: [String: SendableValue]? { get }
    var method: APIHTTPMethod { get }
    var customDataBody: Data? { get }
}

extension APIEndpoint {
    /// Creates and returns a fully configured URLRequest based on the endpoint properties
    public func makeRequest() throws -> URLRequest {
        guard let urlComponents = createURLComponents() else {
            throw APIError.requestFailed
        }
        guard let url = urlComponents.url else {
            throw APIError.requestFailed
        }
        var request = URLRequest(url: url)
        try configureRequest(&request)
        return request
    }
    
    // MARK: - Private helpers
    
    /// Creates URLComponents from the endpoint configuration
    /// - Returns: Configured URLComponents or nil if creation fails
    private func createURLComponents() -> URLComponents? {
        guard var components = URLComponents(string: baseURLString) else {
            return nil
        }
        
        components.path += getFullPath()
        components.queryItems = queryItems
        
        return components
    }
    
    /// Configures the HTTP method, headers and body of the request
    /// - Parameter request: The URLRequest to configure
    private func configureRequest(_ request: inout URLRequest) throws {
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        try setRequestBody(for: &request)
    }
    
    /// Sets the HTTP body for the request based on the available parameters
    /// - Parameter request: The URLRequest to configure with a body
    private func setRequestBody(for request: inout URLRequest) throws {
        if let customDataBody = customDataBody {
            request.httpBody = customDataBody
        } else if let params = params {
            if let self = self as? GenericAPIProviderProtocol {
                switch self.bodyEncoding {
                case .json:
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: params)
                        request.httpBody = jsonData
                    } catch {
                        throw APIError.encoding(error)
                    }
                case .urlEncoded:
                    let paramString = params.map { "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                        .joined(separator: "&")
                    request.httpBody = paramString.data(using: .utf8)
                }
            } else {
                // Default: JSON
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: params)
                    request.httpBody = jsonData
                } catch {
                    throw APIError.encoding(error)
                }
            }
        }
    }
    
    /// Constructs the full URL path by combining API version, separator path, and endpoint path
    /// - Returns: The complete path string starting with "/"
    private func getFullPath() -> String {
        var components: [String] = []
        components.append(path)
        return "/" + components.joined(separator: "/")
    }
}

@frozen
public enum SendableValue: Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([SendableValue])
    case dictionary([String: SendableValue])
    case null
    
    public var rawValue: Any {
        switch self {
        case .string(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .bool(let value): return value
        case .array(let values): return values.map { $0.rawValue }
        case .dictionary(let dict): return dict.mapValues { $0.rawValue }
        case .null: return NSNull()
        }
    }
}

// Convenience initializers
public extension SendableValue {
    static func from(_ value: Any) -> SendableValue {
        switch value {
        case let string as String: return .string(string)
        case let int as Int: return .int(int)
        case let double as Double: return .double(double)
        case let bool as Bool: return .bool(bool)
        case let array as [Any]: return .array(array.map { SendableValue.from($0) })
        case let dict as [String: Any]: return .dictionary(dict.mapValues { SendableValue.from($0) })
        default: return .null
        }
    }
}
