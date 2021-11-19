//
//  RestaurantItem.swift
//  RestaurantEngine
//
//  Created by Nazar Alwi on 18/11/21.
//

import Foundation

public struct RestaurantItem: Equatable {
    public let id: String
    public let name: String
    public let description: String
    public let pictureId: Int
    public let city: String
    public let rating: Double
    
    public init(id: String, name: String, description: String, pictureId: Int, city: String, rating: Double) {
        self.id = id
        self.name = name
        self.description = description
        self.pictureId = pictureId
        self.city = city
        self.rating = rating
    }
}
