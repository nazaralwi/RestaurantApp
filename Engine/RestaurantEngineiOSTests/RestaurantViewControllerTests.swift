//
//  RestaurantViewControllerTests.swift
//  RestaurantEngineiOSTests
//
//  Created by Nazar Alwi on 08/12/21.
//

import XCTest
import UIKit
import RestaurantEngine

final class RestaurantViewController: UITableViewController {
    private var loader: RestaurantLoader?
    
    convenience init(loader: RestaurantLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        loader?.load { _ in }
    }
}

class RestaurantViewControllerTests: XCTestCase {
    func test_init_doesNotLoadRestaurant() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsRestaurant() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsRestaurant() {
        let (sut, loader) = makeSUT()
        
        sut.refreshControl?.allTargets.forEach({ target in
            sut.refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
        
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RestaurantViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = RestaurantViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    class LoaderSpy: RestaurantLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (RemoteRestaurantsLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
