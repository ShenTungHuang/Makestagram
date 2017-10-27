//
//  MGPhotoHelper.swift
//  Makestagram
//
//  Created by STH on 2017/6/27.
//  Copyright © 2017年 STH. All rights reserved.
//

//1. Presenting the popover to allow the user to choose between taking a new photo or selecting one from the photo library
//2. Depending on the user's selection, presenting the camera or photo library
//3. Returning the image that the user has taken or selected

import UIKit

class MGPhotoHelper: NSObject {

    // MARK: - Properties
    var completionHandler: ((UIImage) -> Void)?
    
    // MARK: - Helper Methods
    func presentActionSheet(from viewController: UIViewController) {
        // Initialize a new UIAlertController of type actionSheet
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
        
        // Check if the current device has a camera available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Create a new UIAlertAction
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { [unowned self] action in
                // do nothing yet...
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            
            // Add the action to the alertController instance we created
            alertController.addAction(capturePhotoAction)
        }
        
        // Check if the current device has a photo library available
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // Create a new UIAlertAction
            let uploadAction = UIAlertAction(title: "Upload from Library", style: .default, handler: { [unowned self] action in
                // do nothing yet...
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            
            // Add the action to the alertController instance we created
            alertController.addAction(uploadAction)
        }
        
        // Add a cancel action to allow an user to close the UIAlertController action sheet
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // Add the action to the alertController instance we created
        alertController.addAction(cancelAction)
        
        // Present the UIAlertController from our UIViewController
        viewController.present(alertController, animated: true)
    }
    
    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        // create a new instance of UIImagePickerController
        let imagePickerController = UIImagePickerController()
        // set the sourceType to determine whether the UIImagePickerController will activate the camera and display a photo taking overlay or show the user's photo library
        imagePickerController.sourceType = sourceType
        // sets up the delegate property of imagePickerController
        imagePickerController.delegate = self
        // after imagePickerController is initialized and configured, present the view controller
        viewController.present(imagePickerController, animated: true)
    }
    
}

extension MGPhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // called when an image is selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // check if we were passed back an image in the info dictionary
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // pass it to our completionHandler property
            completionHandler?(selectedImage)
        }
        // hide the image picker controller
        picker.dismiss(animated: true)
    }
    
    // called when the cancel button is tapped
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // hide the image picker controller
        picker.dismiss(animated: true)
    }
    
}
