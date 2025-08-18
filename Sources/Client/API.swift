//
//  API.swift.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation
import CoinGeckoNetwork
import CoinGeckoCore

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
    
    public static func supportedCurrencies() -> APIProvider<SupportedCurrencies> {
        return APIProvider<SupportedCurrencies>(
            path: "simple/supported_vs_currencies",
            method: .get
        )
    }
    
    public static func coinPrice(
        ids: [String],
        vsCurrencies: [String],
        includeMarketCap: Bool = false,
        include24hVol: Bool = false,
        include24hChange: Bool = false,
        includeLastUpdatedAt: Bool = false,
        precision: String = "full"
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
        
        return APIProvider<CoinPriceResponse>(
            path: "simple/price",
            queryItems: queryItems,
            method: .get
        )
    }
    
    public static func coinPriceByTokenAddress(
        platformId: String,
        contractAddresses: String,
        vsCurrencies: [String],
        includeMarketCap: Bool = false,
        include24hVol: Bool = false,
        include24hChange: Bool = false,
        includeLastUpdatedAt: Bool = false,
        precision: String = "full"
    ) -> APIProvider<CoinPriceResponse> {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "contract_addresses", value: contractAddresses),
            URLQueryItem(name: "vs_currencies", value: vsCurrencies.joined(separator: ",")),
            URLQueryItem(name: "include_market_cap", value: includeMarketCap.description),
            URLQueryItem(name: "include_24hr_vol", value: include24hVol.description),
            URLQueryItem(name: "include_24hr_change", value: include24hChange.description),
            URLQueryItem(name: "include_last_updated_at", value: includeLastUpdatedAt.description),
            URLQueryItem(name: "precision", value: "\(precision)")
        ]
        
        return APIProvider<CoinPriceResponse>(
            path: "simple/token_price/" + platformId,
            queryItems: queryItems,
            method: .get
        )
    }
    
    public static func coinsList(
        includePlatform: Bool = false
    ) -> APIProvider<CoinsList> {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "include_platform",
                         value: includePlatform.description)
        ]
        
        return APIProvider<CoinsList>(
            path: "coins/list",
            queryItems: queryItems,
            method: .get
        )
    }
}
