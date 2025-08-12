//
//  CodableModel.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

public typealias CodableModel = DecodableModel & EncodableModel & Sendable

/// A protocol for types that can be decoded from JSON.
/// Used across all models in the SDK.
/// Use the `decoder` property when decoding manually.
public protocol DecodableModel: Decodable, Sendable {
    /// Preconfigured JSONDecoder instance.
    static var decoder: JSONDecoder { get }

    /// Optional strategy for decoding date values.
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? { get }
}

/// A protocol for types that can be encoded into JSON.
/// Used across all models in the SDK.
/// Use the `encoder` property when encoding manually.
public protocol EncodableModel: Encodable, Sendable {
    /// Preconfigured JSONEncoder instance.
    static var encoder: JSONEncoder { get }

    /// Optional strategy for encoding date values.
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? { get }
}

public extension DecodableModel {
    static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? {
        return .iso8601
    }

    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()

        if let dateDecodingStrategy = dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        }

        return decoder
    }
}

public extension EncodableModel {
    static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? {
        return .iso8601
    }

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()

        if let dateEncodingStrategy = dateEncodingStrategy {
            encoder.dateEncodingStrategy = dateEncodingStrategy
        }

        return encoder
    }
}

// Extensions for array types to automatically inherit decoding/encoding configuration
extension Array: DecodableModel where Element: DecodableModel {
    public static var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? {
        return Element.dateDecodingStrategy
    }

    public static var decoder: JSONDecoder {
        return Element.decoder
    }
}

extension Array: EncodableModel where Element: EncodableModel {
    public static var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy? {
        return Element.dateEncodingStrategy
    }

    public static var encoder: JSONEncoder {
        return Element.encoder
    }
}
