//
//  PostService.swift
//  Makestagram
//
//  Created by STH on 2017/6/27.
//  Copyright © 2017年 STH. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

struct PostService {
    
    static func create(for image: UIImage) {
        let imageRef = StorageReference.newPostImageReference()
        StorageService.uploadImage(image, at: imageRef) { (downloadURL) in
            guard let downloadURL = downloadURL else {
                return
            }
            
            let urlString = downloadURL.absoluteString
            let aspectHeight = image.aspectHeight
            create(forURLString: urlString, aspectHeight: aspectHeight)
            print("image url: \(urlString)")
        }
    }
    
    // write a new Post object to database
    private static func create(forURLString urlString: String, aspectHeight: CGFloat) {
        // Create a reference to the current user
        let currentUser = User.current
        // Initialize a new Post using the data passed in by the parameters
        let post = Post(imageURL: urlString, imageHeight: aspectHeight)
        
        // create references to the important locations that we're planning to write data
        let rootRef = DatabaseReference.toLocation(.root)
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
        
        // Use our class method to get an array of all of our follower UIDs
        UserService.followers(for: currentUser) { (followerUIDs) in
            // construct a timeline JSON object where we store our current user's uid
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            // create a mutable dictionary that will store all of the data we want to write to our database
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            // add our post to each of our follower's timelines
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            // make sure to write the post we are trying to create
            let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            // write our multi-location update to our database
            rootRef.updateChildValues(updatedData)
        }
    }
    
    static func show(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        // Define a location for where we're planning to write data
        let ref = DatabaseReference.toLocation(.showPost(uid: posterUID, postKey: postKey))
        // Read the posts/user-uid/postkey node from the database
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil) // call back function
            }
            
            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
    
}
