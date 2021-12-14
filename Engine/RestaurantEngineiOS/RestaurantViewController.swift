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
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
