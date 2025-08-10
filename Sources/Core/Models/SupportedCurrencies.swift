//
//  SupportedCurrencies.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 4.08.2025.
//

import Foundation

// MARK: - SupportedCurrencies Model
public struct SupportedCurrencies: CodableModel {
    /// List of currency codes.
    public let currencies: [String]
    
    /// Initialize with a list of currencies.
    public init(currencies: [String]) {
        self.currencies = currencies
    }
}

// MARK: - Codable Implementation
public extension SupportedCurrencies: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.currencies = try container.decode([String].self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(currencies)
    }
}

// MARK: - Convenience Methods
public extension SupportedCurrencies {
    /// Checks if currency exists (case-insensitive).
    func contains(_ currency: String) -> Bool {
        return currencies.contains(currency.lowercased())
    }
    
    /// Returns crypto currencies (length ≤ 4, lowercase or digit).
    var cryptoCurrencies: [String] {
        return currencies.filter { currency in
            currency.count <= 4 && currency.allSatisfy { $0.isLowercase || $0.isNumber }
        }
    }
    
    /// Returns fiat currencies (length = 3, uppercase).
    var fiatCurrencies: [String] {
        return currencies.filter { currency in
            currency.count == 3 && currency.allSatisfy { $0.isUppercase }
        }
    }
}

// MARK: - Collection Conformance (Optional - Kullanım kolaylığı için)
public extension SupportedCurrencies: Collection {
    public typealias Element = String
    public typealias Index = Array<String>.Index
    
    var startIndex: Index {
        return currencies.startIndex
    }
    
    var endIndex: Index {
        return currencies.endIndex
    }
    
    subscript(index: Index) -> Element {
        return currencies[index]
    }
    
    func index(after index: Index) -> Index {
        return currencies.index(after: index)
    }
}
