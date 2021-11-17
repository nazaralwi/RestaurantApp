//
//  RemoteRestaurantsLoaderTests.swift
//  RestaurantEngineTests
//
//  Created by Nazar Alwi on 16/11/21.
//

import XCTest

class RemoteRestaurantsLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteRestaurantsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataUponCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://any-url.com")!
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteRestaurantsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRestaurantsLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?

        func get(from url: URL) {
            requestedURL = url
        }
    }
}
