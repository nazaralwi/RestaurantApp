//
//  ViewController.swift
//  Prototype
//
//  Created by Nazar Alwi on 01/12/21.
//

import UIKit

class RestaurantViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 10 }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "RestaurantItemCell")!
    }
}
