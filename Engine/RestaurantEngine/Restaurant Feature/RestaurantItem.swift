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
    public let location: String
    public let rating: Double
    public let imageURL: URL
    
    public init(id: String, name: String, description: String, location: String, rating: Double, imageURL: URL) {
        self.id = id
        self.name = name
        self.description = description
        self.location = location
        self.rating = rating
        self.imageURL = imageURL
    }
}
