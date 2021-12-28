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
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.dev/images/medium/")!
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.dev/images/medium/")!
        
        sut.loadImageData(from: url)
        sut.loadImageData(from: url)
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteRestaurantImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRestaurantImageDataLoader(client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append(url)
        }
    }
}
