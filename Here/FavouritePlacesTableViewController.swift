//
//  FavouritePlacesViewController.swift
//  Here
//
//  Created by cristina todoran on 15/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import Foundation
import  FirebaseDatabase
import Firebase
import UIKit

class FavouritePlacesTableViewController : UITableViewController{
    
    //establish a connection to your Firebase database using the provided path
    //Firebase properties are referred to as references because they refer to a location in your Firebase database
    
    
    let ref = FIRDatabase.database().reference(withPath: "favourite-places")
    
    
    // MARK: Constants
    let listToUsers = "ListToUsers"
    
    // MARK: Properties
    var items: [FavouritePlace] = []
    
    let usersRef = FIRDatabase.database().reference(withPath: "online")
    var user: User!
    
    var userCountBarButtonItem: UIBarButtonItem!
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        
        userCountBarButtonItem = UIBarButtonItem(title: "1",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        usersRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
            } else {
                self.userCountBarButtonItem?.title = "0"
            }
        })
        
        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            var newItems: [FavouritePlace] = []
            
            for item in snapshot.children {
                let placeItem = FavouritePlace(snapshot: item as! FIRDataSnapshot)
                newItems.append(placeItem)
            }
            
            self.items = newItems
            self.tableView.reloadData()
        })
        
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let placeItem = items[indexPath.row]
        
        cell.textLabel?.text = placeItem.name
        cell.detailTextLabel?.text = placeItem.addedByUser
        
        toggleCellCheckbox(cell, isCompleted: placeItem.completed!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let placeItem = items[indexPath.row]
            placeItem.ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let placeItem = items[indexPath.row]
        let toggledCompletion = !placeItem.completed!
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        placeItem.ref?.updateChildValues([
            "completed": toggledCompletion
            ])
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    
    @IBAction func addButtonDidTouch(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Favourite Place",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { _ in
                                        // 1
                                        guard let textField = alert.textFields?.first,
                                            let text = textField.text else { return }
                                        
                                        // 2
                                        let placeItem = FavouritePlace(name: text,
                                                                      addedByUser: self.user.email,
                                                                      completed: false)
                                        // 3
                                        let placeItemRef = self.ref.child(text.lowercased())
                                        
                                        // 4
                                        placeItemRef.setValue(placeItem.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)    }
    func userCountButtonDidTouch() {
        performSegue(withIdentifier: listToUsers, sender: nil)
    }}
