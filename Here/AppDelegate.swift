//
//  AppDelegate.swift
//  Here
//
//  Created by cristina todoran on 07/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
    // 1
    let googleMapsApiKey = "AIzaSyB75W7onE8KAMPXtHkFGHmggJx4hL7bTtY"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]? = [:]) -> Bool {
        UIApplication.shared.statusBarStyle = .lightContent
        // 2 googleapi places
        GMSServices.provideAPIKey(googleMapsApiKey)
        
        //3 firebase
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        return true
       
    }
 
}
