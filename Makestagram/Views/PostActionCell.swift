    //
//  PostActionCell.swift
//  Makestagram
//
//  Created by STH on 2017/6/28.
//  Copyright © 2017年 STH. All rights reserved.
//

import UIKit
    
// delegate for PostActionCell to communicate with HomeViewController
protocol PostActionCellDelegate: class {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell)
}
    
class PostActionCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: PostActionCellDelegate? // wil release memory
    
    static let height: CGFloat = 46
    
    // MARK: - Subviews
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    // MARK: - Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - IBActions
    @IBAction func likeButtonTapped(_ sender: Any) {
        delegate?.didTapLikeButton(sender as! UIButton, on: self)
        
        print("like button tapped")
    }
    
}
