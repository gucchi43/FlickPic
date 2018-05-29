//
//  AppDelegate.swift
//  FlickPic
//
//  Created by Eisuke Sato on 2016/06/18.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import TwitterKit
import Firebase
import SwiftyJSON
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var remoteConfig: RemoteConfig!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        TWTRTwitter.sharedInstance().start(withConsumerKey:"r8ELYQHWuQRJl42Is8NmJGbG0", consumerSecret:"N5i9un4GBvjiZbowRZKs0q0oauT5EKQ7Hi2kitYADj4LVMaknx")

        // NSUserDefaults のインスタンス取得
        let ud = UserDefaults.standard
        // デフォルト値の設定
        let dic = ["firstLaunch": true]
        ud.register(defaults: dic)
        
        // RemoteConfigの設定
        self.remoteConfig = RemoteConfig.remoteConfig()
        // デバッグモードの有効化
//        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
//        remoteConfig.configSettings = remoteConfigSettings
        // デフォルト値のセット
        
        remoteConfig.setDefaults(["must_update_ver": "1.0.0" as NSObject])
        remoteConfig.setDefaults(["must_update_message": "おねがーい" as NSObject])
        
        checkAppVersion()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if TWTRTwitter.sharedInstance().application(app, open: url, options: options) {
            return true
        }
        return true
    }
    
    func checkAppVersion() {
        Alamofire.request("http://itunes.apple.com/lookup?id=1281328373").responseJSON { (response) in
            guard let object = response.value else{
                return
            }
            //現アプリのバージョン(currentversion)とApp Storeの最新のバージョン(latestVersion)を取得する
            let json = JSON(object)
            guard let storeVersion = json["results"][0]["version"].string else { return }
            let currentversion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            //バージョンのフォーマットをIntの配列に変更する ex) 1.2.3 → [1, 2, 3]
            let currentArray = currentversion.characters.split {$0 == "."}.map { String($0) }.map {Int($0) ?? 0}
            let storeArray = storeVersion.characters.split {$0 == "."}.map { String($0) }.map {Int($0) ?? 0}
            print("currentArray", currentArray)
            print("storeVersion", storeVersion)
            //App Storeの最新のバージョンが、現アプリよりもバージョンが上のときのみアラートを出すためのチェック
            guard let storeArrayFirst = storeArray.first, let currentArrayFirst = currentArray.first else {
                print("特定のバージョンがない")
                return
            }
            if storeArrayFirst > currentArrayFirst { // A.b.c
                print("AppStoreのMajorVersionが大きい A.b.c")
                self.mustUpdateCheck(currentVersion: currentversion)
            } else if storeArray.count > 1 && (currentArray.count <= 1 || storeArray[1] > currentArray[1]) { // a.B.c
                print("AppStoreのMinorVersionが大きい a.B.c")
                self.mustUpdateCheck(currentVersion: currentversion)
            } else if storeArray.count > 2 && (currentArray.count <= 2 || storeArray[1] == currentArray[1] && storeArray[2] > currentArray[2]) { // a.b.C
                print("AppStoreのRevisionが大きい a.b.C")
                self.mustUpdateCheck(currentVersion: currentversion)
            }  else {
                print("This versiosn is latest")
            }
        }
    }
    
    func mustUpdateCheck(currentVersion: String) {
        
        let expirationDuration = remoteConfig.configSettings.isDeveloperModeEnabled ? 0 : 3600
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if (status == RemoteConfigFetchStatus.success) {
                // フェッチ成功
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            } else {
                // フェッチ失敗
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
            }
            let mustUpdateVersion = self.remoteConfig["must_update_ver"].stringValue!
            let mustUpdateMessage = self.remoteConfig["must_update_message"].stringValue!
            print("mustUpdateVersion : ", mustUpdateVersion)
            //バージョンのフォーマットをIntの配列に変更する ex) 1.2.3 → [1, 2, 3]
            let currentArray = currentVersion.characters.split {$0 == "."}.map { String($0) }.map {Int($0) ?? 0}
            let mustUpdateArray = mustUpdateVersion.characters.split {$0 == "."}.map { String($0) }.map {Int($0) ?? 0}
            guard let mustUpdateArrayFirst = mustUpdateArray.first, let currentArrayFirst = currentArray.first else {
                print("特定のバージョンがない")
                return
            }
            if mustUpdateArrayFirst > currentArrayFirst { // A.b.c
                self.showMustUpdateAlert(message: mustUpdateMessage)
            } else if mustUpdateArray.count > 1 && (currentArray.count <= 1 || mustUpdateArray[1] > currentArray[1]) { //a.B.c
                self.showMustUpdateAlert(message: mustUpdateMessage)
            } else if mustUpdateArray.count > 2 && (currentArray.count <= 2 || mustUpdateArray[1] == currentArray[1] && mustUpdateArray[2] > currentArray[2]) { // a.b.C
                self.showMustUpdateAlert(message: mustUpdateMessage)
            }  else {
                self.showUpdateAlert()
            }
            
        }
    }
    
    func showUpdateAlert() {
        let alert = UIAlertController(
            title: "アップデートしちゃってよ💝",
            message: "ほらほらあ",
            preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "アプデする", style: .default) {
            action in
            UIApplication.shared.open(URL(string: "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=1281328373")!)
        }
        alert.addAction(updateAction)
        alert.addAction(UIAlertAction(title: "絶対しない", style: .destructive))
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func showMustUpdateAlert(message: String) {
        let alert = UIAlertController(
            title: "アップデートしてね💝",
            message: message,
            preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "アプデする", style: .default) {
            action in
            UIApplication.shared.open(URL(string: "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=1281328373")!)
        }
        alert.addAction(updateAction)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

