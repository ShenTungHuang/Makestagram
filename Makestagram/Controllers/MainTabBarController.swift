//
//  MainTabBarController.swift
//  Makestagram
//
//  Created by STH on 2017/6/27.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    let photoHelper = MGPhotoHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoHelper.completionHandler = { image in
            print("handle image")
            PostService.create(for: image)
        }
        
        // set the MainTabBarController as the delegate of it's tab bar
        delegate = self
        // set the tab bar's unselectedItemTintColor from the default of gray to black
        tabBar.unselectedItemTintColor = .black
    }
    
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == 1 {
            photoHelper.presentActionSheet(from: self)
            // present photo taking action sheet
            print("take photo")
            // view controller will not be displayed
            return false
        } else {
            // the tab bar will behave as usual
            return true
        }
    }
    
}
