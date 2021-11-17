//
//  HTTPClient.swift
//  RestaurantEngine
//
//  Created by Nazar Alwi on 17/11/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}
