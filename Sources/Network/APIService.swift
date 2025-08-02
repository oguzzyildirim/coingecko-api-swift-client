//
//  APIService.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol APIServiceProtocol {
    func fetch<T: CodableModel>(endpoint: APIEndpoint) async throws -> T
}

public final class APIService: APIServiceProtocol {
    private let httpClient: HTTPClient

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func fetch<T: Decodable>(endpoint: APIEndpoint) async throws -> T {
        let request = try endpoint.makeRequest()
        let (data, response) = try await httpClient.perform(request)
        return try APIMapper.map(data: data, response: response)
    }
}
