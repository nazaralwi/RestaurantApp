//
//  ViewController.swift
//  Prototype
//
//  Created by Nazar Alwi on 01/12/21.
//

import UIKit

class RestaurantViewController: UITableViewController {
    private let restaurant = RestaurantItemViewModel.prototypeRestaurant
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { restaurant.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantItemCell", for: indexPath) as! RestaurantItemViewCell
        let model = restaurant[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
}

extension RestaurantItemViewCell {
    func configure(with model: RestaurantItemViewModel){
        nameLabel.text = model.name
        descriptionLabel.text = model.description
        locationLabel.text = model.location
        ratingLabel.text = model.rating
        fadeIn(UIImage(named: model.imageName))
    }
}
