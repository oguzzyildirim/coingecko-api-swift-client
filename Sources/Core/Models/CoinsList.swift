//
//  CoinsListElement.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 13.08.2025.
//

import Foundation

// Represents platform-specific information for a cryptocurrency
///
/// This structure contains the platform identifier and the associated contract address
/// for a cryptocurrency on a specific blockchain platform.
public struct PlatformInfo: CodableModel {
    /// The unique identifier for the blockchain platform (e.g., "ethereum", "binance-smart-chain")
    public let platformId: String
    
    /// The contract address of the cryptocurrency on the specified platform
    public let address: String
}

// MARK: - CoinInfo

/// Represents comprehensive information about a cryptocurrency
///
/// This structure contains basic cryptocurrency metadata including identification,
/// symbol, name, and platform-specific contract addresses across different blockchains.
public struct CoinInfo: CodableModel {
    /// The unique identifier for the cryptocurrency
    public let id: String?
    
    /// The trading symbol/ticker for the cryptocurrency (e.g., "BTC", "ETH")
    public let symbol: String?
    
    /// The full name of the cryptocurrency (e.g., "Bitcoin", "Ethereum")
    public let name: String?
    
    /// A dictionary mapping platform identifiers to their corresponding contract addresses
    ///
    /// The key represents the platform ID (e.g., "ethereum", "polygon-pos")
    /// and the value represents the contract address on that platform.
    public let platforms: [String: String]?
    
    /// Computed property that converts the platforms dictionary into an array of PlatformInfo objects
    ///
    /// This property provides a more structured way to access platform information
    /// by transforming the key-value pairs into dedicated PlatformInfo instances.
    ///
    /// - Returns: An array of PlatformInfo objects, or an empty array if platforms is nil
    var platformInfos: [PlatformInfo] {
        platforms?
            .map {
                PlatformInfo(platformId: $0.key,
                             address: $0.value)
            } ?? []
    }
}

/// Type alias representing a collection of cryptocurrency information
///
/// This typealias provides a convenient way to refer to an array of CoinInfo objects,
/// typically used when handling multiple cryptocurrencies from API responses or data collections.
public typealias CoinsList = [CoinInfo]
