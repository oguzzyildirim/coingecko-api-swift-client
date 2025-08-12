//
//  APIMapper.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

/// Handles mapping API responses to either successful models or error states
///
/// - Transforms successful responses (status 200) into decoded models
/// - Converts error responses (status 4xx/5xx) into appropriate `APIError` cases
/// - Automatically handles API error DTO parsing when available
public enum APIMapper {
    /// Maps raw API response data to either a decoded model or throws an error
    /// - Parameters:
    ///   - data: The raw response data from the API
    ///   - response: The HTTPURLResponse containing status code
    /// - Returns: The successfully decoded model of type T
    /// - Throws: `APIError` with specific case depending on failure scenario
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
