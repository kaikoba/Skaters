//
//  PostTableViewCell.swift
//  Skaters
//
//  Created by cls on 2017/07/10.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit
protocol PostTableViewCellDelegate {
    func commentButton_Clicked(post: Post)
}

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfilePic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var likeButton: DesignableButton!
    @IBOutlet weak var commentButton: DesignableButton!
    
    private var currentUserDidLike: Bool = false
    var delegate: PostTableViewCellDelegate!
    
    var post: Post! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        
        //画像を丸める
        userProfilePic.layer.cornerRadius = userProfilePic.layer.bounds.width/2
        postImage.layer.cornerRadius = 5.0
        
        userProfilePic.clipsToBounds = true
        postImage.clipsToBounds = true
        
        //userProfilePic.image! = post.user.profileImage
        //usernameLabel.text! = post.usernameLabel
        //createdAt.text! = post.createdAt
        //postImage.image! = post.postImage
        //postText.text! = post.postText
        
        //commentButton.setTitle("\(post.numberOfLikes) コメント", for: .normal)
        
        configureButtonApperence()
    }
    
    func configureButtonApperence() {
        likeButton.cornerRadius = 3.0
        likeButton.borderWidth = 2.0
        likeButton.borderColor = UIColor.lightGray
        likeButton.tintColor = UIColor.lightGray
        
        commentButton.cornerRadius = 3.0
        commentButton.borderWidth = 2.0
        commentButton.borderColor = UIColor.lightGray
        commentButton.tintColor = UIColor.lightGray
        
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func likeButton_Clicked(_ sender: DesignableButton) {
        /*
        post.userDidLike = !post.userDidLike
        if post.userDidLike {
            post.numberOfLikes += 1
        } else {
            post.numberOfLikes -= 1
        }
        
        currentUserDidLike = post.userDidLike
         */
        changeLikeButtonColor()
        
        //animation
        sender.animation = "pop"
        sender.curve = "spring"
        sender.duration = 1.5
        sender.damping = 0.1
        sender.velocity = 0.2
        sender.animate()
    }
    
    @IBAction func commentButton_Clicked(_ sender: DesignableButton) {
        
        //commentButton.setTitle("\(post.numberOfLikes) コメント", for: .normal)
        
        //animation
        sender.animation = "pop"
        sender.curve = "spring"
        sender.duration = 1.5
        sender.damping = 0.1
        sender.velocity = 0.2
        sender.animate()
        
        delegate?.commentButton_Clicked(post: post)
    }
}
