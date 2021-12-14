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
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
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
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeRestaurantLoading()
        
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_userInitiatedRestaurantReloadTwice_loadsRestaurantTwice() {
        let (sut, loader) = makeSUT()
            
        sut.simulateUserInitiatedRestaurantReload()
        
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedRestaurantReload()
        
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_userInitiatedRestaurantReload_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
                
        sut.simulateUserInitiatedRestaurantReload()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator)
    }
    
    func test_userInitiatedRestaurantReload_hidesLoadingIndicator() {
        let (sut, loader) = makeSUT()
                
        sut.simulateUserInitiatedRestaurantReload()
        loader.completeRestaurantLoading()
        
        XCTAssertFalse(sut.isShowingLoadingIndicator)
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
        private var completions = [(RemoteRestaurantsLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (RemoteRestaurantsLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeRestaurantLoading() {
            completions[0](.success([]))
        }
    }
}

private extension RestaurantViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func simulateUserInitiatedRestaurantReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}
