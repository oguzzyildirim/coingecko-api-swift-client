//
//  URLSession.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import Foundation
import Combine

public protocol HTTPClient {
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

extension URLSession: HTTPClient {
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        return dataTaskPublisher(for: request)
            .tryMap ({ result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw APIError.invalidResponseType
                }
                return (result.data, httpResponse)
            })
            .eraseToAnyPublisher()
    }
    
    public func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            
            cancellable = publisher(request)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}
