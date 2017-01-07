//
//  PlacesTableView.swift
//  Here
//
//  Created by cristina todoran on 07/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import UIKit
protocol PlacesTableViewControllerDelegate: class {
    
    func typesController(_ controller: PlacesTableViewController, didSelectTypes types: [String])
}


class PlacesTableViewController : {
    
  
    let possibleTypesDictionary = ["bakery":"Bakery", "bar":"Bar", "cafe":"Cafe", "grocery_or_supermarket":"Supermarket", "restaurant":"Restaurant"]
    var selectedTypes: [String]!
    weak var delegate: PlacesTableViewControllerDelegate!
    var sortedKeys: [String] {
        return possibleTypesDictionary.keys.sorted()
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return possibleTypesDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        let key = sortedKeys[indexPath.row]
        let type = possibleTypesDictionary[key]!
        cell.textLabel?.text = type
        cell.imageView?.image = UIImage(named: key)
        cell.accessoryType = (selectedTypes!).contains(key) ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = sortedKeys[indexPath.row]
        if (selectedTypes!).contains(key) {
            selectedTypes = selectedTypes.filter({$0 != key})
        } else {
            selectedTypes.append(key)
        }
        
        tableView.reloadData()
    }
}
