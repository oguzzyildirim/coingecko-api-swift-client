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
    case get
    case post
    case put
    case delete
    case patch
}
