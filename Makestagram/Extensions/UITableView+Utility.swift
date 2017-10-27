//
//  UITableView+Utility.swift
//  Makestagram
//
//  Created by STH on 2017/7/1.
//  Copyright © 2017年 STH. All rights reserved.
//

import UIKit

protocol CellIdentifiable {
    static var cellIdentifier: String { get }
}

// can define default values for our protocol properties and functions
extension CellIdentifiable where Self: UITableViewCell {
    // define a default value for cellIdentifier
    static var cellIdentifier: String {
        // return the name of the custom UITableViewCell class as a string using String(describing:)
        return String(describing: self)
    }
}

// make sure that UITableViewCell implements the CellIdentifiable protocol
extension UITableViewCell: CellIdentifiable { }

extension UITableView {
    // define a generic function that extensions UITableView
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: CellIdentifiable {
        // unwrap the custom UITableViewCell based on it's cellIdentifier and make sure the type conforms to T
        guard let cell = dequeueReusableCell(withIdentifier: T.cellIdentifier) as? T else {
            // If the identifier or casting fails, we crash the app but print a nice error message so we'll know which cell caused the issue
            fatalError("Error dequeuing cell for identifier \(T.cellIdentifier)")
        }
        
        return cell
    }
}
