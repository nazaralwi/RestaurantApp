//
//  ViewController.swift
//  Prototype
//
//  Created by Nazar Alwi on 01/12/21.
//

import UIKit

class RestaurantViewController: UITableViewController {
    private var restaurant = [RestaurantItemViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if self.restaurant.isEmpty {
                self.restaurant = RestaurantItemViewModel.prototypeRestaurant
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { restaurant.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantItemCell", for: indexPath) as! RestaurantItemCell
        let model = restaurant[indexPath.row]
        cell.configure(with: model)
        
        return cell
    }
}

extension RestaurantItemCell {
    func configure(with model: RestaurantItemViewModel){
        nameLabel.text = model.name
        descriptionLabel.text = model.description
        locationLabel.text = model.location
        ratingLabel.text = model.rating
        fadeIn(UIImage(named: model.imageName))
    }
}
