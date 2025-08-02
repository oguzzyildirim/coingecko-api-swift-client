//
//  APIErrors.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

/// Data transfer object that represents API error responses
///
/// This public struct maps the common error structure returned by the API,
/// containing an error code, message, and optional detailed error items.
public struct ApiErrorDTO: Codable, Sendable {
    public let status: Status?
    
    public struct Status: Codable, Sendable {
        public let timestamp: String?
        public let errorCode: Int?
        public let errorMessage: String?
        
        enum CodingKeys: String, CodingKey {
            case timestamp
            case errorCode = "error_code"
            case errorMessage = "error_message"
        }
    }
}

enum APIError: Error {
    case customApiError(ApiErrorDTO)
    case requestFailed
    case normalError(Error)
    case decodingError(Error)
    case emptyErrorWithStatusCode(String)
    case encoding(Error)
    case invalidResponseType

    /// A human-readable description of the error
    ///
    /// This computed property formats the error information in a consistent way
    /// that can be presented to users or logged for debugging purposes.
    /// - Returns: String description of the error
    var errorDescription: String? {
        switch self {
        case .customApiError(let apiErrorDTO):
            if let status = apiErrorDTO.status {
                let codeString = status.errorCode.map { String($0) } ?? ""
                let message = status.errorMessage ?? ""
                return "\(codeString) \(message)"
            } else {
                return "Internal error!"
            }
        case .requestFailed:
            return "Request failed"
        case .normalError(let error):
            return error.localizedDescription
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .emptyErrorWithStatusCode(let status):
            return status
        case .encoding(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .invalidResponseType:
                    return "Invalid response type. Expected HTTPURLResponse."
        }
    }
}
