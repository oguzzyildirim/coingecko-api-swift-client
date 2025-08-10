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

// MARK: - Collection Conformance (Optional - For ease of use)
public extension SupportedCurrencies: Collection {
    /// The type of elements stored in the collection.
    public typealias Element = String
    
    /// The type used for indexing into the collection.
    public typealias Index = Array<String>.Index
    
    /// The position of the first element in a nonempty collection.
    public var startIndex: Index {
        return currencies.startIndex
    }
    
    /// The collection’s “past the end” position—that is, the position one greater than the last valid subscript argument.
    public var endIndex: Index {
        return currencies.endIndex
    }
    
    /// Accesses the element at the specified position.
    /// - Parameter index: The position of the element to access.
    public subscript(index: Index) -> Element {
        return currencies[index]
    }
    
    /// Returns the position immediately after the given index.
    /// - Parameter index: A valid index of the collection.
    /// - Returns: The index value immediately after `index`.
    public func index(after index: Index) -> Index {
        return currencies.index(after: index)
    }
}
