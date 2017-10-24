//
//  PostInCommentTableViewCell.swift
//  Skaters
//
//  Created by cls on 2017/07/15.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit
import NCMB

class PostInCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var likeButton: DesignableButton!
    
    
    private var currentUserDidLike: Bool = false
    
    var post: Post! {
        didSet{
            updateUI()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI() {
        
        //profileImage.image! = post.user.profileImage
        usernameLabel.text! = post.usernameLabel
        createdAt.text! = post.createdAt
        //postImage.image! = post.postImage
        postText.text! = post.postText
        
        //likeButton.setTitle("👍　\(post.numberOfLikes) Likes", for: .normal)
        
        changeLikeButtonColor()
        configureButtonApperence()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileImage.layer.cornerRadius = profileImage.layer.bounds.width/2
        profileImage.clipsToBounds = true
    }
    
    private func configureButtonApperence() {
        likeButton.cornerRadius = 3.0
        likeButton.borderWidth = 2.0
        likeButton.borderColor = UIColor.lightGray
        likeButton.tintColor = UIColor.lightGray
    }
    
    private func changeLikeButtonColor() {
        if currentUserDidLike {
            likeButton.borderColor = UIColor.init(hex: "b94047")
            likeButton.tintColor = UIColor.init(hex: "b94047")
        } else {
            likeButton.borderColor = UIColor.lightGray
            likeButton.tintColor = UIColor.lightGray
        }
    }

    
    @IBAction func likeButton_Clicked(_ sender: DesignableButton) {
//        post.userDidLike = !post.userDidLike
//        if post.userDidLike {
//            post.numberOfLikes += 1
//        } else {
//            post.numberOfLikes -= 1
//        }
        
        //likeButton.setTitle("👍　\(post.numberOfLikes) Likes", for: .normal)
        //currentUserDidLike = post.userDidLike
        changeLikeButtonColor()
        
        //animation
        sender.animation = "pop"
        sender.curve = "spring"
        sender.duration = 1.5
        sender.damping = 0.1
        sender.velocity = 0.2
        sender.animate()
    }
    
    
    
    
    
    
}
