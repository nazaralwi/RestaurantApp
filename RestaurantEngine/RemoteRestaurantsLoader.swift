//
//  RemoteRestaurantsLoader.swift
//  RestaurantEngine
//
//  Created by Nazar Alwi on 17/11/21.
//

import Foundation

public class RemoteRestaurantsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Result: Equatable {
        case success([RestaurantItem])
        case failure(Error)
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, _):
                guard let jsonResult = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {
                    return completion(.failure(.invalidData))
                }

                let restaurants = [Root]()
                let jsonResataurants = jsonResult["restaurants"] as! [AnyObject]
                
                for jsonResataurant in jsonResataurants {
                    let _ = Root(
                        id: jsonResataurant["id"] as! String,
                        name: jsonResataurant["name"] as! String,
                        description: jsonResataurant["description"] as! String,
                        pictureId: jsonResataurant["pictureId"] as? String ?? "0",
                        city: jsonResataurant["city"] as! String,
                        rating: jsonResataurant["rating"] as! Double)
                }
                
                completion(.success(restaurants.map { restaurant in
                    let pictureId: Int? = Int(restaurant.pictureId)
                    
                    return RestaurantItem(id: restaurant.id, name: restaurant.name, description: restaurant.description, pictureId: pictureId ?? 0, city: restaurant.city, rating: restaurant.rating)
                }))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

struct Root {
    let id: String
    let name: String
    let description: String
    let pictureId: String
    let city: String
    let rating: Double
}
