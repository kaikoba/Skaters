//
//  PostViewController.swift
//  Skaters
//
//  Created by cls on 2017/07/11.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit
import ImageIO
import AssetsLibrary
import Photos
import NCMB

class PostViewController: UIViewController {
    
    //編集フラグ
    var editFlag: Bool = false
    
    //編集対象メモのobjectId
    var targetMemoObjectId: String = ""
    
    //編集対象メモのfilename
    var targetFileName: String = ""
    
    //ViewController.swiftから渡されたデータ
    var targetData: AnyObject!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImage: DesignableImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var PostImagePic: UIImage!
    var userProfile : NSDictionary!
    var targetUser: String = ""
    var targetCommnet: String = ""
    var targetDisplayImage: UIImage? = nil
    var targetUserImage: UIImage? = nil
    var targetGPS: NSObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImage.isUserInteractionEnabled = true
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(displayCameraAction(_:)))
        singleTap.numberOfTapsRequired = 1;
        postImage.addGestureRecognizer(singleTap)
        
        self.view.addSubview(postImage)
        
        navigationBar.tintColor = UIColor.init(hex: "1cb8ff")
        userProfileImage.layer.cornerRadius = userProfileImage.layer.bounds.width/2
        userProfileImage.clipsToBounds = true
        
        postText.text = ""
        postText.becomeFirstResponder()
        
        //Notification center
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
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
                self.usernameLabel.text = self.userProfile.object(forKey: "name") as? String
                
            }
        })
        
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
        self.postText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardSize?.height)!+10, right: 0)
        self.postText.scrollIndicatorInsets = self.postText.contentInset
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.postText.contentInset = UIEdgeInsets.zero
        self.postText.scrollIndicatorInsets = UIEdgeInsets.zero
        
    }
    
    //キャンセル
    @IBAction func backButton_Clicked(_ sender: Any) {
        postText.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    //シェアする
    @IBAction func postButton_Clicked(_ sender: Any) {
        
        //バリデーションを通す前の準備
        //self.targetTitle = self.titleField.text!
        self.targetUser = self.usernameLabel.text!
        self.targetCommnet = self.postText.text!
        self.targetDisplayImage = self.postImage.image
        self.targetUserImage = self.userProfileImage.image
        
        if (self.targetCommnet.isEmpty) {
            
            //エラーのアラートを表示してOKを押すと戻る
            let errorAlert = UIAlertController(
                title: "エラー",
                message: "投稿が入力がされていません",
                preferredStyle: UIAlertControllerStyle.alert
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: nil
                )
            )
            present(errorAlert, animated: true, completion: nil)
            
            
        } else if (PostImagePic == nil) {
            //カメラ画像を揺らす
            shakeImageView()
            
            //OK:データを1件NCMBにセーブする
        } else {
            
            //保存対象の画像ファイルを作成する
            let imageData: NSData = UIImagePNGRepresentation(self.targetDisplayImage!)! as NSData
            let imageUserData: NSData = UIImagePNGRepresentation(self.targetUserImage!)! as NSData
            let targetFile = NCMBFile.file(with: imageData as Data!) as! NCMBFile
            let targetUserFile = NCMBFile.file(with: imageUserData as Data!) as! NCMBFile
            
            //NCMBへデータを登録・編集をする
            if self.editFlag == true {
                
                //既存データを1件更新する
                var saveError: NSError? = nil
                let obj: NCMBObject = NCMBObject(className: "SharePost")
                obj.objectId = self.targetMemoObjectId
                obj.fetchInBackground({(error) in
                    
                    if (error == nil) {
                        
                        //obj.setObject(self.targetTitle, forKey: "title")
                        obj.setObject(targetFile.name, forKey: "postImageFile")
                        obj.setObject(self.targetUser, forKey: "user")
                        obj.setObject(self.targetCommnet, forKey: "postText")
                        obj.setObject(targetUserFile.name, forKey: "userPic")
                        obj.setObject(self.targetGPS, forKey: "geoLocation")
                        obj.save(&saveError)
                        
                    } else {
                        print("データ取得処理時にエラーが発生しました: \(error)")
                    }
                })
                
                //ファイルは更新があった際のみバックグラウンドで保存する
                if targetFile.name != self.targetFileName {
                    
                    targetUserFile.saveInBackground({ (error) in
                        if error != nil {
                            // 保存に失敗した場合の処理
                            print("アップロード中にエラーが発生しました: \(error)")
                        }else{
                            // 保存に成功した場合の処理
                            print("画像データ保存完了: \(targetUserFile.name)")
                        }
                    })
                    
                    targetFile.saveInBackground({ (error) in
                        if error != nil {
                            // 保存に失敗した場合の処理
                            print("アップロード中にエラーが発生しました: \(error)")
                        }else{
                            // 保存に成功した場合の処理
                            print("画像データ保存完了: \(targetFile.name)")
                        }
                    })
                }
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
                
                //ファイルは更新があった際のみバックグラウンドで保存する
                if targetUserFile.name != self.targetFileName {
                    
                    targetUserFile.saveInBackground({ (error) in
                        if error != nil {
                            // 保存に失敗した場合の処理
                            print("アップロード中にエラーが発生しました: \(error)")
                        }else{
                            // 保存に成功した場合の処理
                            print("画像データ保存完了: \(targetUserFile.name)")
                        }
                    })
                }
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
            } else {
                
                //新規データを1件登録する
                var saveError: NSError? = nil
                let obj: NCMBObject = NCMBObject(className: "SharePost")
                obj.setObject(targetFile.name, forKey: "postImageFile")
                obj.setObject(self.targetUser, forKey: "user")
                obj.setObject(self.targetCommnet, forKey: "postText")
                obj.setObject(targetUserFile.name, forKey: "userPic")
                obj.setObject(self.targetGPS, forKey: "geoLocation")
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
                } else {
                    print("failure save data. \(saveError)")
                }
                
                //ファイルはバックグラウンド実行をする
                targetUserFile.saveInBackground({ (error) in
                    if error != nil {
                        // 保存に失敗した場合の処理
                        print("アップロード中にエラーが発生しました: \(error)")
                    }else{
                        // 保存に成功した場合の処理
                        print("画像データ保存完了: \(targetUserFile.name)")
                    }
                })
                
                if saveError == nil {
                    print("success save data.")
                } else {
                    print("failure save data. \(saveError)")
                }
            }
            
            //UITextFieldを空にする
            self.postText.text = ""
            
            //登録されたアラートを表示してOKを押すと戻る
            let errorAlert = UIAlertController(
                title: "完了",
                message: "入力データがシェアされました",
                preferredStyle: UIAlertControllerStyle.alert
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.default,
                    handler: saveComplete
                )
            )
            present(errorAlert, animated: true, completion: nil)
        }
        
    }
    
    func shakeImageView() {
        postImage.animation = "shake"
        postImage.curve = "spring"
        postImage.duration = 1.0
        postImage.animate()
    }
    
    //登録が完了した際のアクション
    func saveComplete(ac: UIAlertAction) -> Void {
        postText.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    
    //カメラで画像を追加するアクション
    func displayCameraAction(_ gestureRecognizer: UITapGestureRecognizer) {
        
        //UIActionSheetを起動して選択させて、カメラ・フォトライブラリを起動
        let alertActionSheet = UIAlertController(
            title: "スポット写真",
            message: "新規投稿の画像を選択してください",
            preferredStyle: UIAlertControllerStyle.actionSheet
        )
        
        //UIActionSheetの戻り値をチェック
        alertActionSheet.addAction(
            UIAlertAction(
                title: "ライブラリから選択",
                style: UIAlertActionStyle.default,
                handler: handlerActionSheet
            )
        )
       
        
        alertActionSheet.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: UIAlertActionStyle.cancel,
                handler: handlerActionSheet
            )
        )
        present(alertActionSheet, animated: true, completion: nil)
    }
    
    //アクションシートの結果に応じて処理を変更
    func handlerActionSheet(ac: UIAlertAction) -> Void {
        
        switch ac.title! {
            
        case "ライブラリから選択":
            self.selectAndDisplayFromPhotoLibrary()
            break
        case "キャンセル":
            break
        default:
            break
        }
    }
    
    //ライブラリから写真を選択してimageに書き出す
    func selectAndDisplayFromPhotoLibrary() {
        
        //フォトアルバムを表示
        let ipc = UIImagePickerController()
        ipc.allowsEditing = true
        ipc.delegate = self
        ipc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(ipc, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let resizeSelectedImage = image.ResizeUIImage(width: 200, height: 200)
            
            
            let assetURL:AnyObject = info[UIImagePickerControllerReferenceURL]! as AnyObject // get asset url
            let url = NSURL(string: assetURL.description)                       // convert phrase to NSURL
            
            let assetLib = ALAssetsLibrary()
            assetLib.asset(for: url as! URL, resultBlock: { (asset:ALAsset!) -> Void in
                
                let metadata = asset.defaultRepresentation().metadata()
                
                print(metadata)
                
                if metadata?[kCGImagePropertyGPSDictionary as AnyHashable] == nil {
                    print("Location data nothing")
                    
                    //エラーのアラートを表示してOKを押すと戻る
                    let errorAlert = UIAlertController(
                        title: "エラー",
                        message: "画像に位置情報がありません",
                        preferredStyle: UIAlertControllerStyle.alert
                    )
                    errorAlert.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: UIAlertActionStyle.default,
                            handler: nil
                        )
                    )
                    self.present(errorAlert, animated: true, completion: nil)
                    
                    
                    
                }else{
                    let gps = metadata?[kCGImagePropertyGPSDictionary as AnyHashable] as! [NSObject: AnyObject]
                    let lat = gps[kCGImagePropertyGPSLatitude] as! Double
                    let lng = gps[kCGImagePropertyGPSLongitude] as! Double
                    let latGeo = String(format:"%.6f", lat)
                    let lonGeo = String(format:"%.6f", lng)
                    NSLog("GPS Info Lat:%f Lng:%f", lat,lng)
                   
                    let geoPoint = NCMBGeoPoint(latitude: atof(latGeo), longitude: atof(lonGeo))
                    
                    self.postImage.contentMode = .scaleToFill
                    self.postImage.image = resizeSelectedImage
                    self.PostImagePic = self.postImage.image
                    self.targetGPS = geoPoint
                }
                
                if metadata == nil {
                    print("メタデータ取得処理に失敗しました")
                    
                }
                
                
            }) { (error) -> Void in
                print("メタデータ取得処理に失敗しました: \(error)")
                picker.dismiss(animated: true, completion: nil)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        //picker.dismiss(animated: true, completion: nil);
    }
}

extension UIImage{
    
    // 画質を担保したままResizeするクラスメソッド.
    func ResizeUIImage(width : CGFloat, height : CGFloat)-> UIImage!{
        
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        var context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(x:0,  y:0,  width:size.width, height:size.height))
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension PostViewController: ImagePickerSheetControllerDelegate {
    
    func controllerWillEnlargePreview(_ controller: ImagePickerSheetController) {
        print("Will enlarge the preview")
    }
    
    func controllerDidEnlargePreview(_ controller: ImagePickerSheetController) {
        print("Did enlarge the preview")
    }
    
    func controller(_ controller: ImagePickerSheetController, willSelectAsset asset: PHAsset) {
        print("Will select an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, didSelectAsset asset: PHAsset) {
        print("Did select an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, willDeselectAsset asset: PHAsset) {
        print("Will deselect an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, didDeselectAsset asset: PHAsset) {
        print("Did deselect an asset")
    }
    
}
