//
//  APIHTTPMethod.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

/// Represents the standard HTTP methods used for API requests.
/// Conforms to `Sendable` to allow safe usage across concurrent contexts.
public enum APIHTTPMethod: String, Sendable {
    /// GET request method (retrieve data)
    case get
    
    /// POST request method (create new resource)
    case post
    
    /// PUT request method (update entire resource)
    case put
    
    /// DELETE request method (remove resource)
    case delete
    
    /// PATCH request method (partial resource update)
    case patch
}
