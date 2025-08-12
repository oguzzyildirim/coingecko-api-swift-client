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
    var baseURLString: String? { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var params: [String: SendableValue]? { get }
    var method: APIHTTPMethod { get }
    var customDataBody: Data? { get }
}

public extension APIEndpoint {
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
        guard let baseURLString = baseURLString,
              var components = URLComponents(string: baseURLString) else {
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
                    let paramString = params
                        .map { key, value in
                            let encodedValue = "\(value)"
                                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            return "\(key)=\(encodedValue)"
                        }
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

/// A type-safe wrapper for values that can be safely sent across concurrency domains.
///
/// `SendableValue` is an enum representing primitive and composite types that conform to `Sendable`,
/// making it safe for use in concurrent contexts. It supports basic types like `String`, `Int`, `Double`, and `Bool`,
/// as well as arrays and dictionaries of other `SendableValue` instances. A `null` case is also provided to represent
/// an absence of value, mapping to `NSNull` when serialized.
///
/// This type is useful for building APIs that need to store or transmit heterogeneous and type-erased values
/// while maintaining thread safety.
///
/// - Note: Use the `rawValue` property to retrieve the underlying value as `Any`.
@frozen
public enum SendableValue: Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([SendableValue])
    case dictionary([String: SendableValue])
    case null
    
    /// Returns the underlying raw value for the case, type-erased to `Any`.
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

/// Convenience initializers and factory methods for creating `SendableValue` instances.
public extension SendableValue {
    /// Creates a `SendableValue` instance from a given `Any` value.
    ///
    /// This method inspects the runtime type of the provided value and returns
    /// the corresponding `SendableValue` case. Supported types include:
    /// - `String` → `.string`
    /// - `Int` → `.int`
    /// - `Double` → `.double`
    /// - `Bool` → `.bool`
    /// - `[Any]` → `.array`, recursively mapping each element to a `SendableValue`
    /// - `[String: Any]` → `.dictionary`, recursively mapping each value to a `SendableValue`
    ///
    /// Any unsupported type will result in `.null`.
    ///
    /// - Parameter value: The value to convert into a `SendableValue`.
    /// - Returns: A corresponding `SendableValue` instance.
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
