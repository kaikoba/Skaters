//
//  ViewController.swift
//  Skaters
//
//  Created by cls on 2017/07/10.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit
import NCMB
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let post = Post()
    var hidingNavBarManager: HidingNavigationBarManager?
    var searchBar: UISearchBar!
    private var newButton: ActionButton!
    //Memoデータを格納する場所
    var memoArray: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //スクロール時にナビゲーションバーを隠す
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: tableView)
    
        //セルを選択できないようにする
        tableView.allowsSelection = false
        
        //バックボタン非表示
        self.navigationItem.hidesBackButton = true
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "postCell")
        
        navigationController?.navigationBar.tintColor = UIColor.init(hex: "1cb8ff")
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        
        //self.navigationItem.titleView = UIImageView(image:UIImage(named:""))
        createNewButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //データのリロード
    func loadMemoData() {
        
        let query: NCMBQuery = NCMBQuery(className: "SharePost")
        query.order(byDescending: "createDate")
        query.findObjectsInBackground({(objects, error) in
        
            if error == nil {
                
                if (objects?.count)! > 0 {
                    
                    self.memoArray = objects as! NSArray
                    
                    //テーブルビューをリロードする
                    self.tableView.reloadData()
                }
                
            } else {
                print(error?.localizedDescription)
            }
        })
        
    }

    
    private func createNewButton() {
        //新規投稿
        let newPostImage = UIImage(named: "pencil.jpg")!
        let newPost = ActionButtonItem(title: "新規投稿", image: newPostImage)
        newPost.action = {button in
            print("Post Button Pressed")
            self.performSegue(withIdentifier: "New Post Composer", sender: self)
            self.newButton.toggleMenu()
        }
        
        //スポット
        let spotImage = UIImage(named: "spot.png")!
        let spot = ActionButtonItem(title: "スポット", image: spotImage)
        spot.action = {button in
            print("Spot Button Pressed")
            self.performSegue(withIdentifier: "Show Spot Page", sender: self)
            self.newButton.toggleMenu()
        }

        //設定
        let configImage = UIImage(named: "config.png")!
        let config = ActionButtonItem(title: "設定", image: configImage)
        config.action = {button in
            print("Config Button Pressed")
            self.performSegue(withIdentifier: "Show Config Page", sender: self)
            self.newButton.toggleMenu()
        }
        
        newButton = ActionButton(attachedToView: self.view, items: [config, spot, newPost])
        newButton.action = { button in button.toggleMenu() }

        
        newButton.backgroundColor = UIColor.init(hex: "1cb8ff")
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadMemoData()
        navigationController?.setNavigationBarHidden(false, animated: true)
        setupSearchBar()
        hidingNavBarManager?.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hidingNavBarManager?.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    
    //// TableView datasoure and delegate
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        
        return true
    }
    
    private func setupSearchBar() {
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            
            searchBar.placeholder = "Search"
            //searchBar.showsCancelButton = true
            searchBar.delegate = self
            searchBar.tintColor = UIColor.init(hex: "1cb8ff")
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            searchBar.keyboardType = UIKeyboardType.default
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
            //searchBar.becomeFirstResponder()
            
        }
    }
    
    //キーボード表示でキャンセルボタンを表示
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        DispatchQueue.main.async
            {
                self.searchBar.setShowsCancelButton(true, animated: true)
        }
        
        tableView.reloadData()
    }
    
    // キャンセルボタンが押されたらキャンセルボタンを無効にしてフォーカスをはずす
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
       
    }
    
    
    //データをページ移動の際に一緒に移動させる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Comment Page" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.post = sender as! Post
            
        }
    }
}


extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //取得データの総数
        if self.memoArray.count > 0 {
            return self.memoArray.count
        } else {
            return 0
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        cell.delegate = self
        
        //各値をセルに入れる
        let targetMemoData = self.memoArray[indexPath.row]
        print(targetMemoData)
        
        var userPicName: String
        var postImageName: String
        
        post.usernameLabel =  ((targetMemoData as AnyObject).object(forKey: "user") as? String)!
        post.postText =  ((targetMemoData as AnyObject).object(forKey: "postText") as? String)!
        post.createdAt =  ((targetMemoData as AnyObject).object(forKey: "createDate") as? String)!
        
        cell.usernameLabel.text = (targetMemoData as AnyObject).object(forKey: "user") as? String
        cell.postText.text = (targetMemoData as AnyObject).object(forKey: "postText") as? String
        cell.createdAt.text = (targetMemoData as AnyObject).object(forKey: "createDate") as? String

        userPicName = ((targetMemoData as AnyObject).object(forKey: "userPic") as? String)!
        postImageName = ((targetMemoData as AnyObject).object(forKey: "postImageFile") as? String)!
        
        //画像データの取得
        let postImageFile = NCMBFile.file(withName: postImageName, data: nil) as! NCMBFile
        let userImageFile = NCMBFile.file(withName: userPicName, data: nil) as! NCMBFile
        // ファイルを検索
        postImageFile.getDataInBackground{(data, error) in

            if error != nil {
                print("写真の取得失敗: \(error)")
            } else {
                cell.postImage.image = UIImage.init(data: data!)
                
            }
        }
        
        userImageFile.getDataInBackground{(data, error) in
        
            if error != nil {
                print("写真の取得失敗: \(error)")
            } else {
                cell.userProfilePic.image = UIImage.init(data: data!)
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.updateUI()
        return cell
    }
    
}

extension ViewController: PostTableViewCellDelegate {
    func commentButton_Clicked(post: Post) {
        self.performSegue(withIdentifier: "Show Comment Page", sender: post)
    }
    
    
}
