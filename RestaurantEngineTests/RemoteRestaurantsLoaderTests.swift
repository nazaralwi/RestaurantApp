//
//  RemoteRestaurantsLoaderTests.swift
//  RestaurantEngineTests
//
//  Created by Nazar Alwi on 16/11/21.
//

import XCTest

class RemoteRestaurantsLoader { }

class HTTPClient {
    var requestedURL: URL?
}

class RemoteRestaurantsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataUponCreation() {
        let client = HTTPClient()
        _ = RemoteRestaurantsLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
