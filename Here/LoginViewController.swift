//
//  LoginViewController.swift
//  Here
//
//  Created by cristina todoran on 08/01/17.
//  Copyright © 2017 cristina todoran. All rights reserved.
//

import Foundation

import Firebase


class LoginViewController : UIViewController {
    
    // MARK: Constants
    let loginToList = "LoginToList"
    
    @IBOutlet weak var textFieldLoginEmail: UITextField!
 
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    var loginSuccess = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
     
 
    }
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(false)
        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
            if (self.loginSuccess == true){
                self.performSegue(withIdentifier: self.loginToList, sender: nil)
            }
        }    }
    
    @IBAction func loginTouchUpInside(_ sender: AnyObject) {
        
      
        FIRAuth.auth()!.signIn(withEmail:  textFieldLoginEmail.text!,
                               password:textFieldLoginPassword.text!)
        
        self.loginSuccess = true
        if(self.loginSuccess == true)
        {
            self.performSegue(withIdentifier: self.loginToList, sender: nil)        }
        
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        
                                        FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                                                   password: passwordField.text!) { user, error in
                                                                    if error == nil {
                                                                        FIRAuth.auth()!.signIn(withEmail: self.textFieldLoginEmail.text!,
                                                                                               password: self.textFieldLoginPassword.text!)
                                                                    }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
    
}
