//
//  CoinsListElement.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 13.08.2025.
//

import Foundation

public struct PlatformInfo: CodableModel {
    public let platformId: String
    public let address: String
}

// MARK: - CoinInfo
public struct CoinInfo: CodableModel {
    public let id, symbol, name: String?
    public let platforms: [String: String]?
    
    var platformInfos: [PlatformInfo] {
        platforms?
            .map{
                PlatformInfo(platformId: $0.key,
                             address: $0.value)
            } ?? []
    }
}

public typealias CoinsList = [CoinInfo]
