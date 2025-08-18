//
//  LiveAPITests.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import XCTest
@testable import CoinGeckoSwiftSDK

@MainActor
final class LiveAPITests: XCTestCase {
    let ids = ["bitcoin"]
    let platformId = "base"
    let contractAddress = "0x06abb84958029468574b28b6e7792a770ccaa2f6"
    let currencies = ["usd"]
    
    override func setUp() {
        super.setUp()
        guard let apiKey = ProcessInfo.processInfo.environment["COINGECKO_API_KEY"], !apiKey.isEmpty else {
            XCTFail("API key not found in environment")
            return
        }
        API.configure(apiKey: apiKey)
    }
    
    override func tearDown() {
        API.resetConfiguration()
        Thread.sleep(forTimeInterval: 1.5)
        super.tearDown()
    }
    
    func test_SupportedCurrencies_WithExecuteMethod_ReturnsValidCurrencies() async {
        // When
        do {
            let response = try await API.supportedCurrencies().execute()
            // Then
            XCTAssertNotNil(response, "Response should not be nil")
            
            XCTAssertGreaterThan(response.count, 0, "Currencies array should not be empty")
        } catch {
            XCTFail("API call failed with error: \(error)")
        }
    }
    
    // MARK: - Coin(to Bitcoin for now) Price Tests
    
    func test_CoinPrice_WithExecuteMethod_ReturnsValidUSDPrice() async {
        // When
        do {
            let response = try await API.coinPrice(ids: ids, vsCurrencies: currencies).execute()
            
            // Then
            XCTAssertNotNil(response, "Response should not be nil")
            
            let usdPrice = response.price(of: "bitcoin", in: "usd")
            XCTAssertNotNil(usdPrice, "USD price should not be nil")
            XCTAssertGreaterThan(usdPrice ?? 0, 0, "USD price should be greater than 0")
        } catch {
            XCTFail("API call failed with error: \(error)")
        }
    }
    
    func test_CoinPrice_WithPerformMethod_ReturnsValidUSDPrice() {
        // Given
        let expectation = expectation(description: "API call completes")
        
        // When
        API.coinPrice(ids: ids, vsCurrencies: currencies).perform { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertNotNil(response, "Response should not be nil")
                let usdPrice = response.price(of: "bitcoin", in: "usd")
                XCTAssertNotNil(usdPrice, "USD price should not be nil")
                XCTAssertGreaterThan(usdPrice ?? 0, 0, "USD price should be greater than 0")
            case .failure(let error):
                XCTFail("API call failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15)
    }
    
    func test_CoinPriceByTokenAdress_WithPerformMethod_ReturnsValidUSDPrice() {
        // Given
        let expectation = expectation(description: "API call completes")
        
        // When
        API.coinPriceByTokenAddress(platformId: platformId,
                                    contractAddresses: contractAddress,
                                    vsCurrencies: currencies).perform { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertNotNil(response, "Response should not be nil")
                
                let usdPrice = response.price(of: self.contractAddress, in: "usd")
                
                XCTAssertNotNil(usdPrice, "USD price should not be nil")
                XCTAssertGreaterThan(usdPrice ?? 0, 0, "USD price should be greater than 0")
            case .failure(let error):
                XCTFail("API call failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15)
    }
    
    func test_CoinPriceByTokenAdress_WithExecuteMethod_ReturnsValidUSDPrice() async {
        // When
        do {
            // Then
            let response = try await API.coinPriceByTokenAddress(platformId: platformId,
                                                                 contractAddresses: contractAddress,
                                                                 vsCurrencies: currencies).execute()
            
            XCTAssertNotNil(response, "Response should not be nil")
        } catch {
            XCTFail("API call failed with error: \(error)")
        }
    }
    
    // MARK: - Coins List Test
    
    func test_coinsList_WithExecuteMethod_ReturnsValidCoins() async {
        // When
        do {
            // Then
            let response = try await API.coinsList(includePlatform: true).execute()
            
            XCTAssertNotNil(response, "Response should not be nil")
        } catch {
            XCTFail("API call failed with error: \(error)")
        }
    }
    
    func test_coinsList_WithPerformMethod_ReturnsValidCoins() {
        // Given
        let expectation = expectation(description: "API call completes")
        
        // When
        API.coinsList(includePlatform: true).perform { result in
            // Then
            switch result {
            case .success(let response):
                XCTAssertNotNil(response, "Response should not be nil")
            case .failure(let error):
                XCTFail("API call failed with error: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15)
    }
}
