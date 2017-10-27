//
//  FindFriendsCell.swift
//  Makestagram
//
//  Created by STH on 2017/6/29.
//  Copyright © 2017年 STH. All rights reserved.
//

import Foundation
import UIKit

protocol FindFriendsCellDelegate: class {
    func didTapFollowButton(_ followButton: UIButton, on cell: FindFriendsCell)
}

class FindFriendsCell: UITableViewCell {
    
    weak var delegate: FindFriendsCellDelegate?
    
    // MARK: - Properties
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        followButton.layer.borderWidth = 1
        followButton.layer.cornerRadius = 6
        followButton.clipsToBounds = true
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
    }
    
    // MARK: - IBActions
    @IBAction func followButtonTapped(_ sender: Any) {
        delegate?.didTapFollowButton(sender as! UIButton, on: self)
        
        print("follow button tapped")
    }
    
}
