//
//  RestaurantEngineAPIEndToEndTests.swift
//  RestaurantEngineAPIEndToEndTests
//
//  Created by Nazar Alwi on 30/11/21.
//

import XCTest
import RestaurantEngine

class RestaurantEngineAPIEndToEndTests: XCTestCase {
    func test_endToEndTestServerGETRestaurantResult_matchesFixedTestAccountData() {
        switch getRestaurantResult() {
        case let .success(items):
            XCTAssertEqual(items.count, 20, "Expected 20 items in the test account restaurant")
            
        case let .failure(error):
            XCTFail("Expected successful restaurant result, got \(error) instead")
            
        default:
            XCTFail("Expected successful restaurant result, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private func getRestaurantResult(file: StaticString = #filePath, line: UInt = #line) -> RemoteRestaurantsLoader.Result? {
        let testServerURL = URL(string: "https://restaurant-api.dicoding.dev/list")!
        let client = URLSessionHTTPClient()
        let loader = RemoteRestaurantsLoader(url: testServerURL, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: RemoteRestaurantsLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return receivedResult
    }
}
