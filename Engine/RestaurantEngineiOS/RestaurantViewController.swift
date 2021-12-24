//
//  RestaurantViewController.swift
//  RestaurantEngineiOS
//
//  Created by Nazar Alwi on 14/12/21.
//

import UIKit
import RestaurantEngine

public final class RestaurantViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var restaurantLoader: RestaurantLoader?
    private var restaurantImageLoader: RestaurantImageDataLoader?
    private var tableModel = [RestaurantItem]()
    private var tasks = [IndexPath: RestaurantImageDataLoaderTask]()
    
    public convenience init(restaurantLoader: RestaurantLoader, restaurantImageLoader: RestaurantImageDataLoader) {
        self.init()
        self.restaurantLoader = restaurantLoader
        self.restaurantImageLoader = restaurantImageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        restaurantLoader?.load { [weak self] result in
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
        cell.imageView?.image = nil
        cell.imageRetryButton.isHidden = true
        cell.imageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }
            
            self.tasks[indexPath] = self.restaurantImageLoader?.loadImageData(from: cellModel.imageURL) { [weak cell] result in
                switch result {
                case let .success(data):
                    let image = UIImage(data: data) ?? nil
                    cell?.imageView?.image = image
                    cell?.imageRetryButton.isHidden = image != nil
                case .failure:
                    cell?.imageRetryButton.isHidden = false
                }
                
                cell?.imageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            _ = restaurantImageLoader?.loadImageData(from: cellModel.imageURL) { _ in }
        }
    }
}
