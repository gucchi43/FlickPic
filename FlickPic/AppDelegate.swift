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
import FirebaseAuth
import FirebaseMessaging
import SwiftyJSON
import Alamofire
import SwiftyUserDefaults
import UserNotifications
import Pring

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var remoteConfig: RemoteConfig!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        TWTRTwitter.sharedInstance().start(withConsumerKey:"r8ELYQHWuQRJl42Is8NmJGbG0", consumerSecret:"N5i9un4GBvjiZbowRZKs0q0oauT5EKQ7Hi2kitYADj4LVMaknx")
        GADMobileAds.configure(withApplicationID: "ca-app-pub-2311091333372031~3773509156")
        Defaults[.launchCount] += 1
        UNUserNotificationCenter.current().delegate = self
        
        // RemoteConfigの設定
        self.remoteConfig = RemoteConfig.remoteConfig()
        // デバッグモードの有効化
//        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
//        remoteConfig.configSettings = remoteConfigSettings
        
        // デフォルト値のセット
        remoteConfig.setDefaults(["must_update_ver": "1.0.0" as NSObject])
        remoteConfig.setDefaults(["must_update_message": "おねがーい" as NSObject])
        checkAppVersion()
        if let user = AccountManager.shared.currentUser {
            print("ログイン済み: ", user)
        } else {
            self.setUpUser()
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if TWTRTwitter.sharedInstance().application(app, open: url, options: options) {
            return true
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("userInfo : ", userInfo)
        // アプリが起動している間に通知を受け取った場合の処理を行う。
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // アプリがバックグラウンド状態の時に通知を受け取った場合の処理を行う。
        print("userInfo : ", userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("プッシュ通知登録失敗 : ", error)
        // システムへのプッシュ通知の登録が失敗した時の処理を行う。
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Device Token を取得した時の処理を行う。
        print("APNs token retrieved: \(deviceToken)")
    }
    
    func setUpUser() {
        Auth.auth().signInAnonymously() { (authUser, error) in
            if let error = error {
                print("atuth error: ", error)
            } else {
                print("auth user: ", authUser)
                User.get((authUser!.user.uid), block: { (user, error) in
                    if let error = error {
                        print("atuth error: ", error)
                    } else {
                        if let user = user {
                            AccountManager.shared.currentUser = user
                        } else {
                            let newUser = User(id: authUser!.user.uid)
                            newUser.fcmToken = Messaging.messaging().fcmToken!
                            newUser.save({ (ref, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else if let ref = ref {
                                    print(ref)
                                    AccountManager.shared.currentUser = newUser
                                }
                            })
                        }
                    }
                })
            }
        }
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

extension AppDelegate : UNUserNotificationCenterDelegate {
    // iOS 10 以降では通知を受け取るとこちらのデリゲートメソッドが呼ばれる。
    // foreground で受信
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let content = notification.request.content
        // Push Notifications のmessageを取得
        let badge = content.badge
        let body = notification.request.content.body
        print("userNotificationCenterのwillPresentから: \(body), \(badge)")
        print("content : ", content)
        //　iphone7 haptic feedback
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
        // audio & vibrater
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate), nil)
        
        let userInfo = ["word": body, "status": "FG"]
        let center = NotificationCenter.default
        center.post(name: .receiveHotwordNotification, object: nil, userInfo: userInfo)
        completionHandler([])
    
    }
    
    // background で受信してアプリを起動
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Push Notifications のmessageを取得
        let content = response.notification.request.content
        let badge = content.badge
        let body = response.notification.request.content.body
        print("userNotificationCenterのdidReceiveから: \(body), \(badge)")
        print("content : ", content)
        let userInfo = ["word": body, "status": "BG"]
        let center = NotificationCenter.default
        center.post(name: .receiveHotwordNotification, object: nil, userInfo: userInfo)
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
}
