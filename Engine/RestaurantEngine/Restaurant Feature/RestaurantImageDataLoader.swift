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
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> RestaurantImageDataLoaderTask
}
