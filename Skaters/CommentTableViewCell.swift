//
//  CommentTableViewCell.swift
//  Skaters
//
//  Created by cls on 2017/07/15.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var comment: Comment! {
        didSet {
            let extractedExpr: () = updateUI()
            extractedExpr
        }
    }
    
    private func updateUI() {
        userProfileImage.image! = comment.user.profileImage
        usernameLabel.text! = comment.user.fullName
        createdAt.text! = comment.createdAt
        commentLabel.text! = comment.commentText
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userProfileImage.layer.cornerRadius = userProfileImage.layer.bounds.width/2
        userProfileImage.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
