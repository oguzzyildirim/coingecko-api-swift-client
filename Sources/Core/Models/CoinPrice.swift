//
//  CoinPrice.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

public struct CoinPriceResponse: CodableModel {
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
            try container.encode(value, forKey: DynamicCodingKeys(stringValue: key)!)
        }
    }

    // Convenience accessors
    public func price(of coinId: String, in currency: String) -> Decimal? {
        return coins[coinId]?.currencies[currency]?.price
    }

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

public struct CoinPrice: CodableModel {
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

public struct CurrencyDetail: CodableModel {
    public var price: Decimal?
    public var marketCap: Decimal?
    public var volume24h: Decimal?
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

// To parse dynamic keys like "usd", "eur_market_cap", etc.
public struct DynamicCodingKeys: CodingKey {
    public var stringValue: String
    public init?(stringValue: String) { self.stringValue = stringValue }
    public var intValue: Int? { return nil }
    public init?(intValue: Int) { return nil }
}
