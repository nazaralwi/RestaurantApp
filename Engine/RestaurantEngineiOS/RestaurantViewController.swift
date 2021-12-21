//
//  RestaurantViewController.swift
//  RestaurantEngineiOS
//
//  Created by Nazar Alwi on 14/12/21.
//

import UIKit
import RestaurantEngine

public final class RestaurantViewController: UITableViewController {
    private var loader: RestaurantLoader?
    private var tableModel = [RestaurantItem]()
    
    public convenience init(loader: RestaurantLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            switch result {
            case let .success(restaurant):
                self?.tableModel = restaurant
                self?.tableView.reloadData()
            case .failure:
                break
            }
            
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = RestaurantCell()
        cell.nameLabel.text = cellModel.name
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        cell.ratingLabel.text = "\(cellModel.rating)"
        return cell
    }
}
