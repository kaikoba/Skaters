//
//  ConfigViewController.swift
//  Skaters
//
//  Created by cls on 2017/07/21.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit
import NCMB

class ConfigViewController: UIViewController {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var spotKanri: UIButton!
    @IBOutlet weak var hyojiSettei: UIButton!
    @IBOutlet weak var otoiawase: UIButton!
    
    private var myWindow: UIWindow!
    private var myWindowButton: UIButton!
    private var myButton: UIButton!
    
    
    var userProfile : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userProfileImage.layer.cornerRadius = userProfileImage.layer.bounds.width/2
        userProfileImage.clipsToBounds = true
        
        myWindow = UIWindow()
        myWindowButton = UIButton()
        myButton = UIButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        returnUserData()
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me",
                                                                 parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // エラー処理
                print("Error: \(error)")
            }
            else
            {
                // プロフィール情報をディクショナリに入れる
                self.userProfile = result as! NSDictionary
                print(self.userProfile)
                
                // Facebookのプロフィール画像の取得
                let profileImageURL : String = ((self.userProfile.object(forKey: "picture") as AnyObject).object(forKey: "data") as AnyObject).object(forKey: "url") as! String
                let encURL = NSURL(string:profileImageURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
                
                let imgData: NSData
                
                do {
                    imgData = try NSData(contentsOf:encURL! as URL,options: NSData.ReadingOptions.mappedIfSafe)
                    let img = UIImage(data:imgData as Data);
                    
                    //プロフィール画像にセット
                    self.userProfileImage.image = img
                } catch {
                    print("Error: can't create image.")
                }

                //名前を取得
                self.userName.text = self.userProfile.object(forKey: "name") as? String
                
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton_Clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func logoutButton(_ sender: Any) {
       
        let alertController = UIAlertController(title: "ログアウト",message: "ログアウトしますか？", preferredStyle: UIAlertControllerStyle.alert)
        
        //        ②-1 OKボタンの実装
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            //    ②-2 OKがクリックされた時の処理
            // 　　ログアウト
            NCMBUser.logOut()
            self.performSegue(withIdentifier: "Back Login", sender: self)
        }
        //        CANCELボタンの実装
        let cancelButton = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: nil)
        //        ③-1 ボタンに追加
        alertController.addAction(okAction)
        //        ③-2 CANCELボタンの追加
        alertController.addAction(cancelButton)
        //        ④ アラートの表示
        present(alertController,animated: true,completion: nil)
        }
    
    /*
     自作Windowを生成する
     */
    internal func makeMyWindow(){
        
        // 背景を白に設定する.
        myWindow.backgroundColor = UIColor.white
        myWindow.frame = CGRect(x:0, y:0, width:200, height:250)
        myWindow.layer.position = CGPoint(x:self.view.frame.width/2, y:self.view.frame.height/2)
        myWindow.alpha = 0.8
        myWindow.layer.cornerRadius = 20
        
        // myWindowをkeyWindowにする.
        myWindow.makeKey()
        
        // windowを表示する.
        self.myWindow.makeKeyAndVisible()
        
        // ボタンを作成する.
        myWindowButton.frame = CGRect(x:0, y:0, width:100, height:60)
        myWindowButton.backgroundColor = UIColor.orange
        myWindowButton.setTitle("Close", for: .normal)
        myWindowButton.setTitleColor(UIColor.white, for: .normal)
        myWindowButton.layer.masksToBounds = true
        myWindowButton.layer.cornerRadius = 20.0
        myWindowButton.layer.position = CGPoint(x:self.myWindow.frame.width/2, y:self.myWindow.frame.height-50)
        myWindowButton.addTarget(self, action: #selector(ConfigViewController.onClickMyButton(sender:)), for: .touchUpInside)
        self.myWindow.addSubview(myWindowButton)
        
        // TextViewを作成する.
        let myTextView: UITextView = UITextView(frame: CGRect(x:10, y:10, width:self.myWindow.frame.width - 20, height:150))
        myTextView.backgroundColor = UIColor.clear
        myTextView.text = ""
        myTextView.font = UIFont.systemFont(ofSize: 15.0)
        myTextView.textColor = UIColor.black
        myTextView.textAlignment = NSTextAlignment.left
        myTextView.isEditable = true
        
        self.myWindow.addSubview(myTextView)
    }
    
    @IBAction func otoawase_Clicked(_ sender: UIButton) {
        if sender == myWindowButton {
            myWindow.isHidden = true
        }
        else  {
            makeMyWindow()
        }
        
    }
    
    
    /*
     ボタンイベント
     */
    internal func onClickMyButton(sender: UIButton) {
        
        if sender == myWindowButton {
            myWindow.isHidden = true
        }
        else if sender == myButton {
            makeMyWindow()
        }
    }

}
