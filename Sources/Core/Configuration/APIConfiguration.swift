//
//  APIConfiguration.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

public typealias CoinGeckoConfiguration = APIConfiguration

// MARK: - API Configuration
public final class APIConfiguration: @unchecked Sendable {
    public static let shared = APIConfiguration()
    
    private var _apiKey: String?
    private let queue = DispatchQueue(label: "api.configuration", attributes: .concurrent)
    
    private var _environment: Environment = .free

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
    
    public var baseURL: String {
        return "https://api.coingecko.com/api/v3"
    }
    
    public var proBaseURL: String {
        return "https://pro-api.coingecko.com/api/v3"
    }
    
    public var currentBaseURL: String {
        switch environment {
        case .free:
            return baseURL
        case .pro:
            return proBaseURL
        }
    }
    
    public func configure(apiKey: String, environment: Environment = .free) {
        self.apiKey = apiKey
        self.environment = environment
    }
    
    public func reset() {
        self.apiKey = nil
        self.environment = .free
    }
}
