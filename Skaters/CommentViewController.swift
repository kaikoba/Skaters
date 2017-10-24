//
//  CommentViewController.swift
//  Skaters
//
//  Created by cls on 2017/07/15.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var newButton: ActionButton!
    var comment = Comment.allComments()
    var post: Post!
    
    
    var actionButton: ActionButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //セルを選択できないようにする
        tableView.allowsSelection = false

        navigationController?.navigationBar.tintColor = UIColor.init(hex: "1cb8ff")
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        //トップに戻るボタンを作成
        let backButton = UIBarButtonItem(title: "トップに戻る", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CommentViewController.clickBackButton))
        
        self.navigationItem.leftBarButtonItem = backButton
        
        
        let nib = UINib(nibName: "PostInCommentTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "postInCommentCell")

        let nib2 = UINib(nibName: "CommentTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "commentCell")
        
        createNewButton()

    }

    func clickBackButton(){
        self.navigationController?.popViewController(animated: true)
        print("go to top")
    }
    
    private func createNewButton() {
       
        newButton = ActionButton(attachedToView: self.view, items: [])
        newButton.action = {button in
            print("Post Button Pressed")
            self.performSegue(withIdentifier: "New Comment Composer", sender: self)
        }
        
        let newPostImage = UIImage(named: "pencil.png")!
        newButton.setImage(newPostImage, forState: UIControlState())
        newButton.backgroundColor = UIColor.init(hex: "1cb8ff")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "New Comment Composer"{
            let newCommentViewController = segue.destination as! NewCommentViewController
            newCommentViewController.post = post
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CommentViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (comment.count+1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row  == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postInCommentCell", for: indexPath) as! PostInCommentTableViewCell
            cell.post = post
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as!
            CommentTableViewCell
            cell.comment = comment[indexPath.row-1]
            return cell
        }
    }
}
