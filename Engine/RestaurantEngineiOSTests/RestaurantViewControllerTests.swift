//
//  RestaurantViewControllerTests.swift
//  RestaurantEngineiOSTests
//
//  Created by Nazar Alwi on 08/12/21.
//

import XCTest
import RestaurantEngine

final class RestaurantViewController {
    init(loader: RestaurantLoader) {
        
    }
}

class RestaurantViewControllerTests: XCTestCase {
    func test_init_doesNotLoadRestaurant() {
        let loader = LoaderSpy()
        _ = RestaurantViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy: RestaurantLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (RemoteRestaurantsLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
