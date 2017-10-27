//
//  CreateUsernameViewController.swift
//  Makestagram
//
//  Created by STH on 2017/6/26.
//  Copyright © 2017年 STH. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController
{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.layer.cornerRadius = 6
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        // guard to check that a FIRUser is logged in and that the user has provided a username in the text field
        guard let firUser = Auth.auth().currentUser,
            let username = usernameTextField.text,
            !username.isEmpty else { return }
        
        UserService.create(firUser, username: username) { (user) in
            guard let user = user else { return }
            // Create a custom setter method to set the current user
            User.setCurrent(user, writeToUserDefaults: true)
            
            print("Created new user: \(user.username)")
        }
        
        let initialViewController = UIStoryboard.initialViewController(for: .main)
        self.view.window?.rootViewController = initialViewController
        self.view.window?.makeKeyAndVisible()
    }
}
