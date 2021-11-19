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
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://any-url.com")!
        let (sut, cliet) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(cliet.requestedURLs, [url, url])
    }
    
    func test_load_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleWithError: .connectivity, when: {
            let clientError = NSError(domain: "error", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleWithError: .invalidData, when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleWithError: .invalidData, when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversEmptyDataOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        var capturedResults = [RemoteRestaurantsLoader.Result]()
        sut.load { result in capturedResults.append(result) }
        
        let emptyJSON = Data("{\"restaurants\": []}".utf8)
        client.complete(withStatusCode: 200, data: emptyJSON)
                
        XCTAssertEqual(capturedResults, [.success([])])
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        var capturedResults = [RemoteRestaurantsLoader.Result]()
        sut.load { result in capturedResults.append(result) }
        
        let json = """
            {
                "restaurants": [
                        {
                            "id": "rqdv5juczeskfw1e867",
                            "name": "Melting Pot",
                            "description": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. ...",
                            "pictureId": "14",
                            "city": "Medan",
                            "rating": 4.2
                        },
                        {
                            "id": "s1knt6za9kkfw1e867",
                            "name": "Kafe Kita",
                            "description": "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. ...",
                            "pictureId": "25",
                            "city": "Gorontalo",
                            "rating": 4
                        }
                ]
            }
        """
        
        let jsonItems = Data(json.utf8)
        
        client.complete(withStatusCode: 200, data: jsonItems)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteRestaurantsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRestaurantsLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteRestaurantsLoader, toCompleWithError expectedError: RemoteRestaurantsLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResult = [RemoteRestaurantsLoader.Result]()
        sut.load { result in capturedResult.append(result) }

        action()
        
        XCTAssertEqual(capturedResult, [.failure(expectedError)], file: file, line: line)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success(data, response))
        }
    }
}
