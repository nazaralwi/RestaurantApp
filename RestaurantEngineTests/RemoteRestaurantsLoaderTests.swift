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
        
        expect(sut, toCompleWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "error", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversEmptyDataOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleWith: .success([]), when: {
            let emptyJSON = Data("{\"restaurants\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        var capturedResults = [RemoteRestaurantsLoader.Result]()
        sut.load { result in capturedResults.append(result) }
        
        let item1 = RestaurantItem(
            id: "any id",
            name: "any name",
            description: "any description",
            pictureId: 1,
            city: "any city",
            rating: 0.0)
        
        let item1JSON = [
            "id": item1.id,
            "name": item1.name,
            "description": item1.description,
            "pictureId": item1.pictureId,
            "city": item1.city,
            "rating": item1.rating
        ] as [String : Any]
        
        let itemsJSON = ["restaurants": [item1JSON]]
        
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        client.complete(withStatusCode: 200, data: json)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteRestaurantsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteRestaurantsLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteRestaurantsLoader, toCompleWith result: RemoteRestaurantsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResult = [RemoteRestaurantsLoader.Result]()
        sut.load { result in capturedResult.append(result) }

        action()

        XCTAssertEqual(capturedResult, [result], file: file, line: line)
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
