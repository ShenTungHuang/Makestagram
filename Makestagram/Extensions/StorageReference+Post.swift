//
//  StorageReference+Post.swift
//  Makestagram
//
//  Created by STH on 2017/6/27.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation
import FirebaseStorage

extension StorageReference {
    
    static let dateFormatter = ISO8601DateFormatter()
    
    static func newPostImageReference() -> StorageReference {
        let uid = User.current.uid
        let timestamp = dateFormatter.string(from: Date())
        
        return Storage.storage().reference().child("images/posts/\(uid)/\(timestamp).jpg")
    }
}
