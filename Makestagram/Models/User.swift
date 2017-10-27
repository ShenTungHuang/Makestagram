//
//  User.swift
//  Makestagram
//
//  Created by STH on 2017/6/26.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject
{
    
    // MARK: - Properties
    let uid: String
    let username: String
    var isFollowed = false
    
    // MARK: - Init
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
        // to be explicit about calling init from NSObject
        super.init()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let username = dict["username"] as? String
            else { return nil }
        
        self.uid = snapshot.key
        self.username = username
        // to be explicit about calling init from NSObject
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
            let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
            else { return nil }
        
        self.uid = uid
        self.username = username
        
        super.init()
    }
    
    // MARK: - Singleton
    // a private static variable to hold our current user
    private static var _current: User?
    
    // a computed variable that only has a getter that can access the private _current variable
    static var current: User {
        // Check that _current that is of type User
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        
        // If _current isn't nil, it will be returned to the user
        return currentUser
    }
    
    // MARK: - Class Methods
    // Create a custom setter method to set the current user, a Bool on whether the user should be written to UserDefaults
    class func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        // check if the boolean value for writeToUserDefaults is true. If so, we write the user object to UserDefaults
        if writeToUserDefaults {
            // use NSKeyedArchiver to turn our user object into Data, needed to implement the NSCoding protocol and inherit from NSObject to use NSKeyedArchiver
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            
            // store the data for our current user with the correct key in UserDefaults
            UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
        }
        
        _current = user
    }
    
}

extension User: NSCoding {

    // Implement the user object can properly be encoded as Data
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
        aCoder.encode(username, forKey: Constants.UserDefaults.username)
    }
    
}
