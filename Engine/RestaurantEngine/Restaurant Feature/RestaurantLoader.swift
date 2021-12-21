//
//  RestaurantLoader.swift
//  RestaurantEngine
//
//  Created by Nazar Alwi on 08/12/21.
//

import Foundation

public protocol RestaurantLoader {
    func load(completion: @escaping (RemoteRestaurantsLoader.Result) -> Void)
}
