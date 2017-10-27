//
//  UserService.swift
//  Makestagram
//
//  Created by STH on 2017/6/26.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct UserService {
    
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        // create a dictionary to store the username the user has provided inside our database
        let userAttrs = ["username": username]
        // specify a relative path for the location of where we want to store our data
        let ref = DatabaseReference.toLocation(.showUser(uid: firUser.uid))
        // write the data we want to store at the location we provided previous line
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            // read the user we just wrote to the database and create a user from the snapshot
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
                
                // handle newly created user here
            })
        }
    }

    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        //
        let ref = DatabaseReference.toLocation(.showUser(uid: uid))
        // read from the path we created and pass an event closure to handle the data (snapshot) is passed back from the database
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        let ref = DatabaseReference.toLocation(.posts(uid: user.uid))
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            // use dispatch groups to wait for all of the asynchronous code to complete before calling our completion handler on the main thread
            let dispatchGroup = DispatchGroup()
            
            let posts: [Post] =
                snapshot
                    .reversed()
                    .flatMap {
                        guard let post = Post(snapshot: $0)
                            else { return nil }
                        // Can begin and complete a new item by calling enter() and leave() on the dispatch group instance respectively     
                        // When the number of tasks that have been started equal the number completed, the dispatch group can notify you that all tasks have been executed
                        dispatchGroup.enter()
                        
                        LikeService.isPostLiked(post) { (isLiked) in
                            post.isLiked = isLiked
                            
                            dispatchGroup.leave()
                        }
                        
                        return post
            }
            
            // use the notify(queue:) method on DispatchGroup as a completion handler for when all follow data has been read
            // Run the completion block after all posts data has returned
            dispatchGroup.notify(queue: .main, execute: { completion(posts) })
        })
    }
    
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        // Create a DatabaseReference to read all users from the database
        let ref = DatabaseReference.toLocation(.users)
        
        // Read the users node from the database
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            // 1. convert all of the child DataSnapshot into User using our failable initializer
            // 2. filter out the current user object from the User array
            let users =
                snapshot
                    .flatMap(User.init)
                    .filter { $0.uid != currentUser.uid }
            
            // Create a new DispatchGroup so that we can be notified when all asynchronous tasks are finished executing
            let dispatchGroup = DispatchGroup()
            users.forEach { (user) in
                dispatchGroup.enter()
                
                // Make a request for each individual user to determine if the user is being followed by the current user
                FollowService.isUserFollowed(user) { (isFollowed) in
                    user.isFollowed = isFollowed
                    dispatchGroup.leave()
                }
            }
            
            // use the notify(queue:) method on DispatchGroup as a completion handler for when all follow data has been read
            // Run the completion block after all follow relationship data has returned
            dispatchGroup.notify(queue: .main, execute: { completion(users) })
        })
    }
    
    static func followers(for user: User, completion: @escaping ([String]) -> Void) {
        // Create a DatabaseReference to read all of a given user's followers
        let followersRef = DatabaseReference.toLocation(.followers(uid: user.uid))
        // fetch the UIDs of all of a given user's followers
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            // return them as an String array
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
        })
    }
    
//    static func timeline(completion: @escaping ([Post]) -> Void) {
//        let currentUser = User.current
//        // Create a DatabaseReference to read data from timeline/currentuser_uid
//        let timelineRef = DatabaseReference.toLocation(.timeline(uid: currentUser.uid))
//        // Read the timeline/currentuser_uid node from the database
//        timelineRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            // get and downcast datebase into [DataSnapshot] type
//            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
//                else { return completion([]) }
//            // use dispatch groups to wait for all of the asynchronous code to complete before calling our completion handler on the main thread
//            let dispatchGroup = DispatchGroup()
//            
//            var posts = [Post]()
//            
//            for postSnap in snapshot {
//                guard let postDict = postSnap.value as? [String : Any],
//                    let posterUID = postDict["poster_uid"] as? String
//                    else { continue }
//                // Can begin and complete a new item by calling enter() and leave() on the dispatch group instance respectively
//                dispatchGroup.enter()
//                
//                PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
//                    if let post = post {
//                        posts.append(post)
//                    }
//                    // Can begin and complete a new item by calling enter() and leave() on the dispatch group instance respectively
//                    dispatchGroup.leave()
//                }
//            }
//            // use the notify(queue:) method on DispatchGroup as a completion handler for when all follow data has been read
//            // Run the completion block after all posts data has returned
//            dispatchGroup.notify(queue: .main, execute: { completion(posts.reversed()) })
//        })
//    }
    
    static func timeline(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([Post]) -> Void) {
        let currentUser = User.current
        
        let ref = DatabaseReference.toLocation(.timeline(uid: currentUser.uid))
        var query = ref.queryOrderedByKey().queryLimited(toLast: pageSize)
        if let lastPostKey = lastPostKey {
            query = query.queryEnding(atValue: lastPostKey)
        }
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            // get and downcast datebase into [DataSnapshot] type
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            // use dispatch groups to wait for all of the asynchronous code to complete before calling our completion handler on the main thread
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                // Can begin and complete a new item by calling enter() and leave() on the dispatch group instance respectively
                dispatchGroup.enter()
                
                PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                    // Can begin and complete a new item by calling enter() and leave() on the dispatch group instance respectively
                    dispatchGroup.leave()
                }
            }
            // use the notify(queue:) method on DispatchGroup as a completion handler for when all follow data has been read
            // Run the completion block after all posts data has returned
            dispatchGroup.notify(queue: .main, execute: { completion(posts.reversed()) })
        })
    }
    
}

