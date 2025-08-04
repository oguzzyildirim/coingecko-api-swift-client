//
//  SupportedCurrencies.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 4.08.2025.
//

import Foundation

// MARK: - SupportedCurrencies Model
public struct SupportedCurrencies: CodableModel {
    public let currencies: [String]
    
    public init(currencies: [String]) {
        self.currencies = currencies
    }
}

// MARK: - Codable Implementation
extension SupportedCurrencies: Codable {
    public init(from decoder: Decoder) throws {
        // API direkt string array döndüğü için
        let container = try decoder.singleValueContainer()
        self.currencies = try container.decode([String].self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(currencies)
    }
}

// MARK: - Convenience Methods
extension SupportedCurrencies {
    /// Belirli bir currency'nin desteklenip desteklenmediğini kontrol eder
    public func contains(_ currency: String) -> Bool {
        return currencies.contains(currency.lowercased())
    }
    
    /// Crypto ve fiat currency'leri ayırır (basit heuristic)
    public var cryptoCurrencies: [String] {
        return currencies.filter { currency in
            // Genellikle crypto'lar 3-4 karakter ve küçük harf
            currency.count <= 4 && currency.allSatisfy { $0.isLowercase || $0.isNumber }
        }
    }
    
    public var fiatCurrencies: [String] {
        return currencies.filter { currency in
            // Fiat'lar genellikle 3 karakter ve büyük harf ISO kodu
            currency.count == 3 && currency.allSatisfy { $0.isUppercase }
        }
    }
}

// MARK: - Collection Conformance (Optional - Kullanım kolaylığı için)
extension SupportedCurrencies: Collection {
    public typealias Element = String
    public typealias Index = Array<String>.Index
    
    public var startIndex: Index {
        return currencies.startIndex
    }
    
    public var endIndex: Index {
        return currencies.endIndex
    }
    
    public subscript(index: Index) -> Element {
        return currencies[index]
    }
    
    public func index(after i: Index) -> Index {
        return currencies.index(after: i)
    }
}
