//
//  OnlineUsersTableViewController.swift
//  Here
//
//  Created by cristina todoran on 15/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import Foundation
import Firebase


class OnlineUsersTableViewController: UITableViewController{
    
    // MARK: Constants
    let userCell = "UserCell"
    let usersRef = FIRDatabase.database().reference(withPath: "online")
    
  
    // MARK: Properties
    var currentUsers: [String] = []
    
   
    @IBAction func signOutButton(_ sender: Any) {
        do {
            try FIRAuth.auth()!.signOut()
            dismiss(animated: true, completion: nil)
        }
        catch {
            
        }
        
    }
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usersRef.observe(.childAdded, with: { snap in
            guard let email = snap.value as? String else { return }
            self.currentUsers.append(email)
            let row = self.currentUsers.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .top)
        })
        
        usersRef.observe(.childRemoved, with: { snap in
            guard let emailToFind = snap.value as? String else { return }
            for (index, email) in self.currentUsers.enumerated() {
                if email == emailToFind {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.currentUsers.remove(at: index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        })
        
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsers.count
    }
    
    @IBAction func signoutButtonPressed(_ sender: AnyObject) {
        
        do {
            try FIRAuth.auth()!.signOut()
            dismiss(animated: true, completion: nil)
        } catch {
            
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        return cell
    }
}
