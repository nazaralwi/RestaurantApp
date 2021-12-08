//
//  RestaurantViewControllerTests.swift
//  RestaurantEngineiOSTests
//
//  Created by Nazar Alwi on 08/12/21.
//

import XCTest

final class RestaurantViewController {
    init(loader: RestaurantViewControllerTests.LoaderSpy) {
        
    }
}

class RestaurantViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = RestaurantViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
