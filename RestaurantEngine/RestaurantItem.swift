//
//  RestaurantItem.swift
//  RestaurantEngine
//
//  Created by Nazar Alwi on 18/11/21.
//

import Foundation

public struct RestaurantItem: Equatable {
    let id: String
    let name: String
    let description: String
    let pictureId: Int
    let city: String
    let rating: Double
}
