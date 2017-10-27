//
//  FollowService.swift
//  Makestagram
//
//  Created by STH on 2017/6/28.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct FollowService {
    
    private static func followUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        // create a dictionary to update multiple locations at the same time
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : true,
                          "following/\(currentUID)/\(user.uid)" : true]
        
        // write our new relationship to Firebase
        let ref = DatabaseReference.toLocation(.root)
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
            }
            
            // get all posts for the user
            UserService.posts(for: user) { (posts) in
                // get all of the post keys for that user's posts
                let postKeys = posts.flatMap { $0.key }
                
                // build a multiple location update using a dictionary that adds each of the followee's post to our timeline
                var followData = [String : Any]()
                let timelinePostDict = ["poster_uid" : user.uid]
                postKeys.forEach { followData["timeline/\(currentUID)/\($0)"] = timelinePostDict }
                
                // write the dictionary to our database
                ref.updateChildValues(followData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    // return success based on whether we received an error
                    success(error == nil)
                })
            }
        }
    }
    
    private static func unfollowUser(_ user: User, forCurrentUserWithSuccess success: @escaping (Bool) -> Void) {
        // Must use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any] or it'll get error
        // http://stackoverflow.com/questions/38462074/using-updatechildvalues-to-delete-from-firebase
        let currentUID = User.current.uid
        let followData = ["followers/\(user.uid)/\(currentUID)" : NSNull(),
                          "following/\(currentUID)/\(user.uid)" : NSNull()]
        
        // write our new relationship to Firebase
        let ref = DatabaseReference.toLocation(.root)
        ref.updateChildValues(followData) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            // get all posts for the user
            UserService.posts(for: user, completion: { (posts) in
                // build a multiple location update using a dictionary that adds each of the followee's post to our timeline
                var unfollowData = [String : Any]()
                let postsKeys = posts.flatMap { $0.key }
                postsKeys.forEach {
                    // Use NSNull() object instead of nil because updateChildValues expects type [Hashable : Any]
                    unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
                }
                
                // write the dictionary to our database
                ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    // return success based on whether we received an error
                    success(error == nil)
                })
            })
        }
    }
    
    static func isUserFollowed(_ user: User, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        let currentUID = User.current.uid
        // build a relative path to the location of where we store the followers
        let ref = DatabaseReference.toLocation(.followers(uid: user.uid))
        // use a special query that checks whether a value exists at the location that we're reading from
        ref.queryEqual(toValue: nil, childKey: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func setIsFollowing(_ isFollowing: Bool, fromCurrentUserTo followee: User, success: @escaping (Bool) -> Void) {
        if isFollowing {
            followUser(followee, forCurrentUserWithSuccess: success)
        } else {
            unfollowUser(followee, forCurrentUserWithSuccess: success)
        }
    }
    
}
