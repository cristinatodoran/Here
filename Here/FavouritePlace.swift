//
//  FavouritePlace.swift
//  Here
//
//  Created by cristina todoran on 15/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import Foundation
import Firebase

class FavouritePlace{
    
    //for storing in database as favourite place
    var name: String
    var key: String?
    var ref: FIRDatabaseReference?
    var completed: Bool?
    var addedByUser: String?
    
    init(name: String,addedByUser: String,completed: Bool,key: String = "")
    {
        self.key = key
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
        self.ref = nil
    }
    init(snapshot: FIRDataSnapshot)
    {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        addedByUser = snapshotValue["addedByUser"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
        
    }
    
    func toAnyObject() -> Any{
        return [
             "name":name,
             "addedByUser":addedByUser,
             "completed":completed]
    }
}
