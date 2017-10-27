//
//  LikeService.swift
//  Makestagram
//
//  Created by STH on 2017/6/28.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation
import FirebaseDatabase

class LikeService {
    
    static func create(for post: Post, success: @escaping (Bool) -> Void) {
        // check the post has a key and return false if there is not (each post that we like must have a key)
        guard let key = post.key else {
            return success(false)
        }
        
        // create a reference to the current user's UID
        let currentUID = User.current.uid
        
        // code to like a post
        // Define a location for where we're planning to write data
        let likesRef = DatabaseReference.toLocation(.likes(postKey: key, currentUID: currentUID))
        // Write the data by setting the value for the location specified
        likesRef.setValue(true) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            let likeCountRef = DatabaseReference.toLocation(.likesCount(posterUID: post.poster.uid, postKey: key))
            // Call the transaction API on the DatabaseReference location we want to update
            likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                // Check that the value exists and increment it if it does
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount + 1
                // Return the updated value
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                // Handle the completion block if there's an error
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else { // Handle the completion block if the transaction was successful
                    success(true)
                }
            })
        }
    }
    
    static func delete(for post: Post, success: @escaping (Bool) -> Void) {
        // check the post has a key and return false if there is not (each post that we like must have a key)
        guard let key = post.key else {
            return success(false)
        }
        
        // create a reference to the current user's UID
        let currentUID = User.current.uid
        
        // code to like a post
        // Define a location for where we're planning to write data
        let likesRef = DatabaseReference.toLocation(.likes(postKey: key, currentUID: currentUID))
        // Write the data by setting the value for the location specified
        likesRef.setValue(nil) { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            
            let likeCountRef = DatabaseReference.toLocation(.likesCount(posterUID: post.poster.uid, postKey: key))
            // Call the transaction API on the DatabaseReference location we want to update
            likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                // Check that the value exists and decrement it if it does
                let currentCount = mutableData.value as? Int ?? 0
                mutableData.value = currentCount - 1
                // Return the updated value
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                // Handle the completion block if there's an error
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else { // Handle the completion block if the transaction was successful
                    success(true)
                }
            })
        }
    }
    
    static func isPostLiked(_ post: Post, byCurrentUserWithCompletion completion: @escaping (Bool) -> Void) {
        // make sure that the post has a key.
        guard let postKey = post.key else {
            assertionFailure("Error: post must have key.")
            return completion(false)
        }
        
        // build a relative path to the location of where we store the current user's like data for a specific post, if a like were to exist
        let likesRef = DatabaseReference.toLocation(.isLiked(postKey: postKey))
        // use a special query that checks whether a value exists at the location that we're reading from
        likesRef.queryEqual(toValue: nil, childKey: User.current.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? [String : Bool] {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    static func setIsLiked(_ isLiked: Bool, for post: Post, success: @escaping (Bool) -> Void) {
        if isLiked {
            create(for: post, success: success)
        } else {
            delete(for: post, success: success)
        }
    }
    
}
