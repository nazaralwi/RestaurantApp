//
//  RestaurantViewControllerTests.swift
//  RestaurantEngineiOSTests
//
//  Created by Nazar Alwi on 08/12/21.
//

import XCTest
import UIKit
import RestaurantEngine
import RestaurantEngineiOS

class RestaurantViewControllerTests: XCTestCase {
    func test_loadRestaurantActions_requestRestaurantFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedRestaurantReload()
        
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedRestaurantReload()
        
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingRestaurantIndicator_isVisibleWhileLoadingRestaurant() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeRestaurantLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedRestaurantReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indiactor once user initiates a reload")
        
        sut.simulateUserInitiatedRestaurantReload()
        loader.completeRestaurantLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes successfully")
        
        sut.simulateUserInitiatedRestaurantReload()
        loader.completeRestaurantLoadingWithError(at: 2)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
        
    func test_loadRestaurantCompletion_rendersSuccessfullyLoadedRestaurant() {
        let restaurant0 = makeRestaurant()
        let restaurant1 = makeRestaurant()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeRestaurantLoading(with: [restaurant0], at: 0)
        assertThat(sut, isRendering: [restaurant0])
        
        sut.simulateUserInitiatedRestaurantReload()
        loader.completeRestaurantLoading(with: [restaurant0, restaurant1], at: 1)
        assertThat(sut, isRendering: [restaurant0, restaurant1])
    }

    func test_loadRestaurantCompletionWithError_doesNotAlterCurrentRenderedRestaurant() {
        let restaurant0 = makeRestaurant()
        let restaurant1 = makeRestaurant()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeRestaurantLoading(with: [restaurant0, restaurant1], at: 0)
        assertThat(sut, isRendering: [restaurant0, restaurant1])
        
        sut.simulateUserInitiatedRestaurantReload()
        loader.completeRestaurantLoadingWithError(at: 1)
        assertThat(sut, isRendering: [restaurant0, restaurant1])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RestaurantViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = RestaurantViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assertThat(_ sut: RestaurantViewController, isRendering restaurants: [RestaurantItem], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.tableView.numberOfRows(inSection: 0) == restaurants.count else {
            return XCTFail("Expected \(restaurants.count) restaurants, got \(sut.tableView.numberOfRows(inSection: 0)) instead", file: file, line: line)
        }
        
        restaurants.enumerated().forEach { index, restaurant in
            assertThat(sut, hasViewConfiguredFor: restaurant, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: RestaurantViewController, hasViewConfiguredFor restaurant: RestaurantItem, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.restaurantView(at: 0)
        
        guard let cell = view as? RestaurantCell else {
            return XCTFail("Expected \(RestaurantCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.nameLabel.text, restaurant.name, "Expected name text to be \(String(describing: restaurant.name)) for restaurant cell at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionLabel.text, restaurant.description, "Expected description text to be \(String(describing: restaurant.description)) for restaurant cell at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.locationLabel.text, restaurant.city, "Expected location text to be \(String(describing: restaurant.city)) for restaurant cell at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.ratingLabel.text, "\(restaurant.rating)", "Expected rating text to be \(String(describing: restaurant.rating)) for restaurant cell at index \(index)", file: file, line: line)
    }
    
    private func makeRestaurant() -> RestaurantItem {
        RestaurantItem(id: "12345", name: "a restaurant", description: "a description", pictureId: 0, city: "a city", rating: 0.0)
    }
    
    class LoaderSpy: RestaurantLoader {
        private var completions = [(RemoteRestaurantsLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (RemoteRestaurantsLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeRestaurantLoading(with restaurant: [RestaurantItem] = [], at index: Int = 0) {
            completions[index](.success(restaurant))
        }
        
        func completeRestaurantLoadingWithError(at index: Int = 0) {
            completions[index](.failure(.connectivity))
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
    
    func restaurantView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: restaurantSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    var restaurantSection: Int {
        0
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
