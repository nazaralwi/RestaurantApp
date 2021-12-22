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
        
        XCTAssertEqual(loader.loadRestaurantCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadRestaurantCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedRestaurantReload()
        
        XCTAssertEqual(loader.loadRestaurantCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedRestaurantReload()
        
        XCTAssertEqual(loader.loadRestaurantCallCount, 3, "Expected yet another loading request once user initiates another reload")
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
    
    func test_restaurantImageView_loadsImageURLWhenVisible() {
        let restaurant0 = makeRestaurant(imageURL: URL(string: "https://a-url/images/0")!)
        let restaurant1 = makeRestaurant(imageURL: URL(string: "https://a-url/images/1")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeRestaurantLoading(with: [restaurant0, restaurant1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL request until views become visible")
        
        sut.simulateRestaurantImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [restaurant0.imageURL], "Expected first image URL request once first view becomes visible")
        
        sut.simulateRestaurantImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [restaurant0.imageURL, restaurant1.imageURL], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_restaurantImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let restaurant0 = makeRestaurant(imageURL: URL(string: "https://a-url/images/0")!)
        let restaurant1 = makeRestaurant(imageURL: URL(string: "https://a-url/images/1")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeRestaurantLoading(with: [restaurant0, restaurant1])
        
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled URL request until image is not visible")
        
        sut.simulateRestaurantImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [restaurant0.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateRestaurantImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [restaurant0.imageURL, restaurant1.imageURL], "Expected two cancelled image URL request once second image is not visible anymore")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RestaurantViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = RestaurantViewController(restaurantLoader: loader, restaurantImageLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
    
    private func assertThat(_ sut: RestaurantViewController, isRendering restaurants: [RestaurantItem], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedRestaurantViews == restaurants.count else {
            return XCTFail("Expected \(restaurants.count) restaurants, got \(sut.numberOfRenderedRestaurantViews) instead", file: file, line: line)
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
        
        XCTAssertEqual(cell.nameText, restaurant.name, "Expected name text to be \(String(describing: restaurant.name)) for restaurant cell at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, restaurant.description, "Expected description text to be \(String(describing: restaurant.description)) for restaurant cell at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.locationText, restaurant.location, "Expected location text to be \(String(describing: restaurant.location)) for restaurant cell at index \(index)", file: file, line: line)
        XCTAssertEqual(cell.ratingText, "\(restaurant.rating)", "Expected rating text to be \(String(describing: restaurant.rating)) for restaurant cell at index \(index)", file: file, line: line)
    }
    
    private func makeRestaurant(imageURL: URL = URL(string: "https://a-url/images/0")!) -> RestaurantItem {
        RestaurantItem(id: "12345", name: "a restaurant", description: "a description", location: "a location", rating: 0.0, imageURL: imageURL)
    }
    
    class LoaderSpy: RestaurantLoader, RestaurantImageDataLoader {
        // MARK: - RestaurantLoader
        private var restaurantRequests = [(RemoteRestaurantsLoader.Result) -> Void]()
        
        var loadRestaurantCallCount: Int {
            restaurantRequests.count
        }
        
        func load(completion: @escaping (RemoteRestaurantsLoader.Result) -> Void) {
            restaurantRequests.append(completion)
        }
        
        func completeRestaurantLoading(with restaurant: [RestaurantItem] = [], at index: Int = 0) {
            restaurantRequests[index](.success(restaurant))
        }
        
        func completeRestaurantLoadingWithError(at index: Int = 0) {
            restaurantRequests[index](.failure(.connectivity))
        }
        
        // MARK: - RestaurantImageDataLoader
        
        private struct TaskSpy: RestaurantImageDataLoaderTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL) -> RestaurantImageDataLoaderTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
    }
}

private extension RestaurantViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    var numberOfRenderedRestaurantViews: Int {
        tableView.numberOfRows(inSection: restaurantSection)
    }

    var restaurantSection: Int {
        0
    }
    
    func simulateUserInitiatedRestaurantReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateRestaurantImageViewVisible(at index: Int = 0) -> RestaurantCell? {
        return restaurantView(at: index) as? RestaurantCell
    }
    
    func simulateRestaurantImageViewNotVisible(at row: Int = 0) {
        let view = simulateRestaurantImageViewVisible(at: row)
        
        let dl = tableView.delegate
        let index = IndexPath(row: row, section: restaurantSection)
        dl?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func restaurantView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: restaurantSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

private extension RestaurantCell {
    var nameText: String? {
        nameLabel.text
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var ratingText: String? {
        ratingLabel.text
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
