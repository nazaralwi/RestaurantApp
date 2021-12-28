//
//  RemoteRestaurantImageDataLoader.swift
//  RestaurantEngineTests
//
//  Created by Nazar Alwi on 28/12/21.
//

import XCTest

class RemoteRestaurantImageDataLoader {
    init(client: Any) {
        
    }
}

class RemoteRestaurantImageDataLoaderTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let client = ClientSpy()
        _ = RemoteRestaurantImageDataLoader(client: client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    // - MARK: Helpers
    
    private class ClientSpy {
        var requestedURLs = [URL]()
    }
}
