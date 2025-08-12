//
//  CoinPrice.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

/// Represents coin price data for multiple coins and currencies
public struct CoinPriceResponse: CodableModel {
    /// Dictionary mapping coin IDs to their price data
    public let coins: [String: CoinPrice]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var result: [String: CoinPrice] = [:]
        
        for key in container.allKeys {
            let value = try container.decode(CoinPrice.self, forKey: key)
            result[key.stringValue] = value
        }
        
        self.coins = result
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (key, value) in coins {
            guard let codingKey = DynamicCodingKeys(stringValue: key) else {
                throw EncodingError.invalidValue(key, EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Invalid key: \(key)"
                ))
            }
            try container.encode(value, forKey: codingKey)
        }
    }
    
    /// Gets the price for a specific coin and currency
    public func price(of coinId: String, in currency: String) -> Decimal? {
        return coins[coinId]?.currencies[currency]?.price
    }
    
    /// Gets the market cap for a specific coin and currency
    public func marketCap(of coinId: String, in currency: String) -> Decimal? {
        return coins[coinId]?.currencies[currency]?.marketCap
    }
    
    public subscript(coinId: String, currency: String) -> CurrencyDetail? {
        return coins[coinId]?.currencies[currency]
    }
    
    public var allCoins: [String] {
        return Array(coins.keys)
    }
}

/// Price data for a single coin across multiple currencies
public struct CoinPrice: CodableModel {
    /// Dictionary mapping currency codes to detailed price information
    public let currencies: [String: CurrencyDetail]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var temp: [String: CurrencyDetail] = [:]
        
        for key in container.allKeys {
            let keyStr = key.stringValue
            let components = keyStr.split(separator: "_")
            let currency = String(components.first ?? "")
            let field = components.dropFirst().joined(separator: "_") // e.g., market_cap, 24h_vol
            
            var detail = temp[currency] ?? CurrencyDetail()
            
            if field == "market_cap" {
                detail.marketCap = try container.decode(Decimal.self, forKey: key)
            } else if field == "24h_vol" {
                detail.volume24h = try container.decode(Decimal.self, forKey: key)
            } else if field == "24h_change" {
                detail.change24h = try container.decode(Decimal.self, forKey: key)
            } else {
                // basic price (e.g., "usd": 123.45)
                detail.price = try container.decode(Decimal.self, forKey: key)
            }
            
            temp[currency] = detail
        }
        
        self.currencies = temp
    }
}

/// Detailed price information for a single currency
public struct CurrencyDetail: CodableModel {
    /// Current price value
    public var price: Decimal?
    /// Market capitalization
    public var marketCap: Decimal?
    /// 24-hour trading volume
    public var volume24h: Decimal?
    /// 24-hour price change percentage
    public var change24h: Decimal?
    
    public init(
        price: Decimal? = nil,
        marketCap: Decimal? = nil,
        volume24h: Decimal? = nil,
        change24h: Decimal? = nil
    ) {
        self.price = price
        self.marketCap = marketCap
        self.volume24h = volume24h
        self.change24h = change24h
    }
}

/// Helper for decoding dynamic JSON keys
public struct DynamicCodingKeys: CodingKey {
    /// The string value of the coding key
    /// - Note: This matches the JSON key name exactly
    public var stringValue: String
    
    /// Creates a coding key from a string value
    /// - Parameter stringValue: The JSON key name to use for decoding
    public init?(stringValue: String) { self.stringValue = stringValue }
    
    /// Integer representation of the coding key (unused)
    /// - Returns: Always returns nil since we only work with string keys
    public var intValue: Int? { return nil }
    
    /// Creates a coding key from an integer value (unused)
    /// - Returns: Always returns nil since we only work with string keys
    public init?(intValue: Int) { return nil }
}
