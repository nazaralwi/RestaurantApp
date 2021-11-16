//
//  RemoteRestaurantsLoaderTests.swift
//  RestaurantEngineTests
//
//  Created by Nazar Alwi on 16/11/21.
//

import XCTest

class RemoteRestaurantsLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(url: URL) {
        client.requestedURL = url
    }
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteRestaurantsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataUponCreation() {
        let client = HTTPClient()
        _ = RemoteRestaurantsLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteRestaurantsLoader(client: client)
        let url = URL(string: "https://any-url.com")!
        
        sut.load(url: url)
        
        XCTAssertEqual(client.requestedURL, url)
    }
}
