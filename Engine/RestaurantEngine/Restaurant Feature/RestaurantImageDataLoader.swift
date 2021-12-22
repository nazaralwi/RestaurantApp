//
//  RestaurantImageDataLoader.swift
//  RestaurantEngine
//
//  Created by Nazar Alwi on 21/12/21.
//

import Foundation

public protocol RestaurantImageDataLoaderTask {
    func cancel()
}

public protocol RestaurantImageDataLoader {
    func loadImageData(from url: URL) -> RestaurantImageDataLoaderTask
}
