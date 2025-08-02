//
//  APIMapper.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

public enum APIMapper {
    public static func map<T: Decodable>(data: Data, response: HTTPURLResponse) throws -> T {
        if response.statusCode == 200 {
            return try JSONDecoder().decode(T.self, from: data)
        }
        if response.statusCode >= 400 && response.statusCode < 600 {
            if let apiErrorDTO = try? JSONDecoder().decode(ApiErrorDTO.self, from: data) {
                throw APIError.customApiError(apiErrorDTO)
            } else {
                throw APIError.emptyErrorWithStatusCode("\(response.statusCode)")
            }
        }
        throw APIError.requestFailed
    }
}
