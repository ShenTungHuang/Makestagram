//
//  StorageService.swift
//  Makestagram
//
//  Created by STH on 2017/6/27.
//  Copyright © 2017年 STH. All rights reserved.
//

import UIKit
import FirebaseStorage

struct StorageService {
    
    // provide method for uploading images
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void) {
        // change the image from an UIImage to Data and reduce the quality of the image
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // upload media data to the path provided as a parameter to the method
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // After the upload completes, check if there was an error
            if let error = error {
                // assertFailure will crash the app and print the error when we're running in debug mode
                assertionFailure(error.localizedDescription)
                // return nil to completion closure
                return completion(nil)
            }
            
            // return the download URL for the image
            completion(metadata?.downloadURL())
        })
    }
    
}
