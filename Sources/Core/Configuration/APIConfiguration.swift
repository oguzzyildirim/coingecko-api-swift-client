//
//  APIConfiguration.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

public typealias CoinGeckoConfiguration = APIConfiguration

// MARK: - API Configuration
/// A shared configuration class to manage API settings for CoinGecko.
/// It supports different environments and handles the API key safely using a concurrent queue.
public final class APIConfiguration: @unchecked Sendable {
    /// Shared singleton instance to use throughout the app
    public static let shared = APIConfiguration()
    
    private var _apiKey: String?
    private let queue = DispatchQueue(label: "api.configuration", attributes: .concurrent)
    
    private var _environment: Environment = .free

    /// Current environment used for API requests (.free or .pro)
    public var environment: Environment {
        get {
            queue.sync { _environment }
        }
        set {
            queue.async(flags: .barrier) {
                self._environment = newValue
            }
        }
    }
    
    private init() {}
    
    /// API key used in requests. It is thread-safe.
    public var apiKey: String? {
        get {
            queue.sync { _apiKey }
        }
        set {
            queue.async(flags: .barrier) {
                self._apiKey = newValue
            }
        }
    }
    
    /// Base URL for free CoinGecko API
    public var baseURL: String {
        return "https://api.coingecko.com/api/v3"
    }
    
    /// Base URL for pro CoinGecko API
    public var proBaseURL: String {
        return "https://pro-api.coingecko.com/api/v3"
    }
    
    /// Returns the current base URL depending on the environment
    public var currentBaseURL: String {
        switch environment {
        case .free:
            return baseURL
        case .pro:
            return proBaseURL
        }
    }
    
    /// Set apiKey and environment at once
        /// - Parameters:
        ///   - apiKey: The API key string
        ///   - environment: The API environment, default is .free
    public func configure(
        apiKey: String,
        environment: Environment = .free
    ) {
        self.apiKey = apiKey
        self.environment = environment
    }
    
    public func reset() {
        self.apiKey = nil
        self.environment = .free
    }
}
