//
//  LiveAPITests.swift
//  CoinGeckoSwiftSDK
//
//  Created by Oguz Yildirim on 1.08.2025.
//

import XCTest
@testable import CoinGeckoSwiftSDK

final class LiveAPITests: XCTestCase {
    let ids = ["bitcoin"]
    let currencies = ["usd"]
    
    override func setUp() {
        super.setUp()
        API.configure(apiKey: "YOUR_API_KEY")
    }
    
    override func tearDown() {
        API.resetConfiguration()
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
    
    // MARK: - Bitcoin Price Tests
    
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
    
    @MainActor
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
        
        waitForExpectations(timeout: 5)
    }
}
