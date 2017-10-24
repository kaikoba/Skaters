//
//  LoginViewController.swift
//  Skaters
//
//  Created by cls on 2017/07/19.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit
import NCMB

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet var imageView: UIView!
    @IBOutlet weak var logo: DesignableButton!
    var userProfile : NSDictionary!
    var targetDisplayImage: UIImage? = nil
    var targetUser: String = ""
    var targetEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //グラデーションの開始色(白）
        let topColor = UIColor(red:0.45, green:0.82, blue:0.99, alpha:1.0)
        //グラデーションの終了色（スカイブルー）
        let bottomColor = UIColor(red:0.11, green:0.72, blue:1.00, alpha:1.0)
        
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame = self.view.bounds
        
        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)

        loginButton.cornerRadius = 5.0
        loginButton.borderWidth = 2.0
        loginButton.backgroundColor = UIColor.init(hex: "4267b2")
        loginButton.borderColor = UIColor.init(hex: "4267b2")
        loginButton.tintColor = UIColor.white
        
        if (FBSDKAccessToken.current() != nil) {
            print("User Already Logged In")
            self.performSegue(withIdentifier: "login", sender: self)
        } else {
            print("User not Logged In")
            
        }
    }
    
    @IBAction func logo_Clicked(_ sender: DesignableButton) {
        
        //animation
        sender.animation = "squeeze"
        sender.curve = "spring"
        sender.duration = 1.5
        sender.damping = 0.1
        sender.velocity = 0.2
        sender.animate()
    }
    
    
    // Loginボタン押下時の処理
    @IBAction func FacebookLoginBtn(_ sender: AnyObject) {
         NCMBFacebookUtils.logIn(withReadPermission: ["email"]) {(user, error) -> Void in
            if (error != nil){
                //遷移しない
                print("Error: \(error)")
            }else{
                print("Facebookの会員登録とログインに成功しました：\(String(describing: user?.objectId))")
                self.returnUserData()
            }
            
        }
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
                
                //メールアドレスを取得
                self.targetEmail = (self.userProfile.object(forKey: "email") as? String)!

                let query: NCMBQuery = NCMBQuery(className: "User")
                query.whereKey("Email", equalTo: self.targetEmail)
                
                // ユーザー登録済みか検索
                query.findObjectsInBackground({ (objects, error) in
                    if error == nil {
                        if (objects?.count)! > 0 {
                            //登録済みの場合はそのままログイン
                            self.performSegue(withIdentifier: "login", sender: self)
                        }else {
                            //未登録の場合は新規登録
                            do {
                                let imgData: NSData

                                imgData = try NSData(contentsOf:encURL! as URL,options: NSData.ReadingOptions.mappedIfSafe)
                                let img = UIImage(data:imgData as Data);
                                
                                //プロフィール画像にセット
                                self.targetDisplayImage = img
                                
                                //名前を取得
                                self.targetUser = (self.userProfile.object(forKey: "name") as? String)!
                                
                                //保存対象の画像ファイルを作成する
                                let imageData: NSData = UIImagePNGRepresentation(self.targetDisplayImage!)! as NSData
                                let targetFile = NCMBFile.file(with: imageData as Data!) as! NCMBFile
                                
                                //新規データを1件登録する
                                var saveError: NSError? = nil
                                let obj: NCMBObject = NCMBObject(className: "User")
                                obj.setObject(targetFile.name, forKey: "userPic")
                                obj.setObject(self.targetUser, forKey: "userName")
                                obj.setObject(self.targetEmail, forKey: "Email")
                                obj.save(&saveError)
                                
                                //ファイルはバックグラウンド実行をする
                                targetFile.saveInBackground({ (error) in
                                    if error != nil {
                                        // 保存に失敗した場合の処理
                                        print("アップロード中にエラーが発生しました: \(error)")
                                    }else{
                                        // 保存に成功した場合の処理
                                        print("画像データ保存完了: \(targetFile.name)")
                                    }
                                })
                                
                                if saveError == nil {
                                    print("success save data.")
                                    //データ登録後ログイン
                                    self.performSegue(withIdentifier: "login", sender: self)
                                } else {
                                    print("failure save data. \(saveError)")
                                }
                            } catch {
                                print("Error: can't create image.")
                            }
                        }
                    } else {
                      //エラーあり
                        print(error?.localizedDescription)
                    }
                })
                
            }
        })
        
    }
}
