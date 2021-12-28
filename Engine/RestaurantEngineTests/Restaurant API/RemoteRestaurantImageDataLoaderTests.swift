//
//  RemoteRestaurantImageDataLoader.swift
//  RestaurantEngineTests
//
//  Created by Nazar Alwi on 28/12/21.
//

import XCTest
import RestaurantEngine

class RemoteRestaurantImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL) {
        client.get(from: url) { _ in }
    }
}

class RemoteRestaurantImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let client = HTTPClientSpy()
        _ = RemoteRestaurantImageDataLoader(client: client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteRestaurantImageDataLoader(client: client)
        let url = URL(string: "https://a-url.dev/images/medium/")!
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // - MARK: Helpers
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append(url)
        }
    }
}
