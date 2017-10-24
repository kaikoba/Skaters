//
//  SpotViewController.swift
//  Skaters
//
//  Created by cls on 2017/07/16.
//  Copyright © 2017年 cls. All rights reserved.
//

import UIKit
import NCMB
import GoogleMaps
import GooglePlaces

class SpotViewController: UIViewController, CLLocationManagerDelegate , GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    // OUTLETS
    @IBOutlet weak var googleMapsView: GMSMapView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    // VARIABLES
    var locationManager = CLLocationManager()
    
    //Memoデータを格納する場所
    var memoArray: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = UIColor.init(hex: "1cb8ff")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initGoogleMaps()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadMemoData()
    }
    
    //データのリロード
    func loadMemoData() {
        
        /**
         * Just FYI
         *
         * Example: 文字列と一致する場合
         * query.whereKey("title", equalTo: "xxx")
         *
         * メソッドのインターフェイスについて:
         * NCMBQuery.hを参照するとNCMBQueryのインスタンスメソッドの引数にとるべき値等が見れます。
         *
         */
        //let marker = GMSMarker()
        let query: NCMBQuery = NCMBQuery(className: "SharePost")
        query.order(byDescending: "createDate")
        query.findObjectsInBackground({(objects, error) in
            
            if error == nil {
                
                if (objects?.count)! > 0 {
                    
                    self.memoArray = objects as! NSArray
                    
                    //テーブルビューをリロードする
                    //self.memoTableView.reloadData()
                    for share in objects! {
                        self.addImageMarker(location: (share as AnyObject).object(forKey: "geoLocation") as! NCMBGeoPoint, title: (share as AnyObject).object(forKey: "postText") as! String, snippet: (share as AnyObject).object(forKey: "user") as! String, imageName: (share as AnyObject).object(forKey: "postImageFile") as! String)
                    }

                }
                
            } else {
                print(error?.localizedDescription)
            }
        })
        
    }

    // マーカー作成（画像アイコン）
    func addImageMarker(location: NCMBGeoPoint, title: String, snippet: String, imageName: String) {
        addMarker(location: location, title: title, snippet: snippet, color: nil, imageName: imageName)
    }
    
    // マーカー作成
    func addMarker(location: NCMBGeoPoint, title: String, snippet: String, color: UIColor?, imageName: String?) {
        let marker = GMSMarker()
       
        // 画像アイコン
        if imageName != nil {
            /** 【mBaaS：ファイルストア】アイコン画像データを取得 **/
            // ファイル名を設定
            let imageFile = NCMBFile.file(withName: imageName, data: nil) as! NCMBFile            // ファイルを検索
            imageFile.getDataInBackground{(data, error) in
                if error != nil {
                    // ファイル取得失敗時の処理
                    print("\(snippet)icon画像の取得に失敗しました:\(String(describing: error))")
                } else {
                    // ファイル取得成功時の処理
                    print("\(snippet)icon画像の取得に成功しました")
                    
                    let spotImage: UIImage = UIImage.init(data: data!)!
                    let respotImage = spotImage.ResizeUIImage(width: 60, height: 60)

                    
                    // 画像アイコン
                    marker.icon = respotImage
                }
                
                // 位置情報
                marker.position = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                // タイトル
                marker.title = title
                // コメント
                marker.snippet = snippet
                // マーカー表示時のアニメーションを設定
                marker.appearAnimation = GMSMarkerAnimation.pop
                // マーカーを表示するマップの設定
                marker.map = self.googleMapsView
                
                self.googleMapsView.selectedMarker =  marker
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
                print("Tapp detected")
    }
    
    func initGoogleMaps() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.googleMapsView.camera = camera
        
        self.googleMapsView.delegate = self
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true

    }
    
    @IBAction func backButton_Clicked(_ sender: Any) {
        //postText.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.googleMapsView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.googleMapsView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.googleMapsView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
        
    }
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.googleMapsView.camera = camera
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    
    
    @IBAction func openSearchAddress(_ sender: UIBarButtonItem) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    
}

