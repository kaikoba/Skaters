//
//  NewCommentViewController.swift
//  Skaters
//
//  Created by cls on 2017/07/16.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit

class NewCommentViewController: UIViewController {

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var user = User.allUsers()[0]
    var post: Post!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentText.text = ""
        commentText.becomeFirstResponder()
        
        profileImage.image! = user.profileImage
        usernameLabel.text! = user.fullName
        
        navigationBar.tintColor = UIColor.init(hex: "1cb8ff")
        profileImage.layer.cornerRadius = profileImage.layer.bounds.width/2
        profileImage.clipsToBounds = true
        
        //Notification center
        NotificationCenter.default.addObserver(self, selector: #selector(NewCommentViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewCommentViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        self.commentText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardSize?.height)!+10, right: 0)
        self.commentText.scrollIndicatorInsets = self.commentText.contentInset
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.commentText.contentInset = UIEdgeInsets.zero
        self.commentText.scrollIndicatorInsets = UIEdgeInsets.zero
        
    }
    
    @IBAction func backButton_Clicked(_ sender: Any) {
        commentText.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func commentButton_Clicked(_ sender: Any) {
         commentText.resignFirstResponder()
         dismiss(animated: true, completion: nil)
    }
    
}
