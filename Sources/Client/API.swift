//
//  API.swift.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation
import CoinGeckoNetwork

/// CoinGecko API endpoints
public struct API {
    private let service: APIService
    
    public init(service: APIService = APIService(httpClient: URLSession.shared)) {
        self.service = service
    }
    
    // Configure the SDK with your API key
    /// - Parameter apiKey: Your CoinGecko API key
    public static func configure(apiKey: String, environment: Environment = .free) {
        APIConfiguration.shared.configure(apiKey: apiKey, environment: environment)
    }

    /// Reset API configuration (use free tier)
    public static func resetConfiguration() {
        APIConfiguration.shared.reset()
    }
    
    public static func coinPrice(
        ids: [String],
        vsCurrencies: [String],
        includeMarketCap: Bool = false,
        include24hVol: Bool = false,
        include24hChange: Bool = false,
        includeLastUpdatedAt: Bool = false,
        precision: String = "1"
    ) -> APIProvider<CoinPriceResponse> {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "ids", value: ids.joined(separator: ",")),
            URLQueryItem(name: "vs_currencies", value: vsCurrencies.joined(separator: ",")),
            URLQueryItem(name: "include_market_cap", value: includeMarketCap.description),
            URLQueryItem(name: "include_24hr_vol", value: include24hVol.description),
            URLQueryItem(name: "include_24hr_change", value: include24hChange.description),
            URLQueryItem(name: "include_last_updated_at", value: includeLastUpdatedAt.description),
            URLQueryItem(name: "precision", value: "\(precision)")
        ]
        
        var headers: [String: String] = [
            "accept": "application/json"
        ]
        
        if let apiKey = APIConfiguration.shared.apiKey {
            headers["x-cg-demo-api-key"] = apiKey
        }
        
        return APIProvider<CoinPriceResponse>(
            baseURLString: APIConfiguration.shared.currentBaseURL,
            path: "simple/price",
            headers: headers,
            queryItems: queryItems,
            method: .get
        )
    }
}
