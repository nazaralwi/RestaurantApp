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
        client.get(from: url)
    }
}

class HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteRestaurantsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataUponCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://any-url.com")!
        
        sut.load(url: url)
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: RemoteRestaurantsLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteRestaurantsLoader(client: client)
        return (sut, client)
    }
}
