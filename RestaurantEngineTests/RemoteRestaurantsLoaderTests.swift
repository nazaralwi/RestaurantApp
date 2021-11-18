//
//  RemoteRestaurantsLoaderTests.swift
//  RestaurantEngineTests
//
//  Created by Nazar Alwi on 16/11/21.
//

import XCTest
import RestaurantEngine

class RemoteRestaurantsLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataUponCreation() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://any-url.com")!
        let (sut, cliet) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(cliet.requestedURLs, [url, url])
    }
    
    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteRestaurantsLoader.Error]()
        sut.load { error in capturedError.append(error) }
        
        let clientError = NSError(domain: "error", code: 0)
        client.completion(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteRestaurantsLoader.Error]()
        sut.load { error in capturedError.append(error) }
        
        client.completion(withStatusCode: 400)
        
        XCTAssertEqual(capturedError, [.invalidData])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteRestaurantsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRestaurantsLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func completion(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func completion(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )
            
            messages[index].completion(nil, response)
        }
    }
}
