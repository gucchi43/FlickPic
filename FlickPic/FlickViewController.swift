//
//  FlickViewController.swift
//  FlickPic
//
//  Created by Eisuke Sato on 2016/06/18.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON
import Alamofire
import Koloda
import pop
import Colours
import IDMPhotoBrowser
import SVProgressHUD
import GoogleMobileAds
import SwiftyUserDefaults
import StoreKit

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 5
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class FlickViewController: UIViewController {
    
    @objc var searchText = ""
    
    @objc var images = [String]()
    @objc var imagesArray = [Int: UIImage]()
    var ItemsArray = [[String: String?]]()
    var maxId = ""
    @objc var numberOfCards: Int = 100
    
    @objc var nextQuery = ""
    @objc var imageExistFlag = true
    
    @IBOutlet weak var targetTextLabel: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    enum queryPattern {
        case first
        case other
        case empty
    }
    
    var nowQuery: queryPattern = queryPattern.first
    
    var adoCount = 0
    
    // PROD
    let interstitialADTestUnitID = "ca-app-pub-2311091333372031/6603686625"
    // TEST
//    let interstitialADTestUnitID = "ca-app-pub-3940256099942544/4411468910"
    
    fileprivate var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = createAndLoadInterstitial()
        self.nowQuery = queryPattern.first
        
        kolodaView.delegate = self
        kolodaView.dataSource = self
        
        kolodaView.animator = FlickViewAnimator(koloda: kolodaView)
        leftButton.tintColor = UIColor.warning()
        rightButton.tintColor = UIColor.success()
        targetTextLabel.adjustsFontSizeToFitWidth = true
        targetTextLabel.text = searchText
        
        getTwitterMedia()
        imageExistFlag = true
    }
    
    @IBAction func tappedLeftButton(_ sender: AnyObject) {
        kolodaView.swipe(SwipeResultDirection.left)
    }
    
    @IBAction func tappedRightButton(_ sender: AnyObject) {
        kolodaView.swipe(SwipeResultDirection.right)
    }
    
    @IBAction func tapReloadData(_ sender: Any) {
        getTwitterMedia()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func getTwitterMedia(){
        switch nowQuery {
        case .first:
            print("first")
            self.loadingQuery()
        case .other:
            print("other")
            self.loadingQuery()
        case .empty:
            print("empty")
            sorryAlert()
        }
    }
    
    @objc func loadingQuery() {
        let url = "https://api.twitter.com/1.1/search/tweets.json"
        var params = [
            "q": searchText + " filter:images -filter:retweets -filter:faves",
//            "q": searchText + " filter:images",
            "lang": "ja",
            "count": "50"
//            "result_type" : "recent"
            ]
        if maxId != "" {
            print("検索maxId", maxId)
            params["max_id"] = maxId
        }
        print("検索params", params)
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            print(userID)
            let client = TWTRAPIClient(userID: userID)
            var request = client.urlRequest(withMethod: "GET", urlString: url + self.nextQuery, parameters: params, error: nil)
            SVProgressHUD.qp.show()
            client.sendTwitterRequest(request, completion: {
                response, data, error in
                if let error = error {
                    print("検索エラー", error)
                    SVProgressHUD.dismiss()
                    self.searchErrorAlert()
                } else {
                    let json = try! JSON(data: data!)
                    print("検索json", json)
                    SVProgressHUD.dismiss()
                    if json["statuses"].array?.count == 0 {
                        print("jsonの中身がもうないよ")
                        self.nowQuery = queryPattern.empty
                        self.sorryAlert()
                    } else {
                        self.setImages(json: json)
                        print("imagesデータロードデビュー", self.images)
                        self.kolodaView.resetCurrentCardIndex()
                    }
                    
//                    if let currentMaxId = json["search_metadata"]["max_id_str"].string {
//                        if self.maxId != currentMaxId {
//                            self.maxId = currentMaxId
//                            //                        self.maxId = String(Int(currentMaxId)! - 1)
//                        } else {
//                            print("maxId == currentMaxIdやんけ",self.maxId,currentMaxId)
//                        }
//                        self.nowQuery = queryPattern.other
//                    } else {
//                        self.nowQuery = queryPattern.empty
//                    }
                //Twitterの次回の検索があるか
//                    if let nextResults = json["search_metadata"]["next_results"].string {
//                        print("nextResults", nextResults)
//                        self.nextQuery = nextResults
//                        self.nowQuery = queryPattern.other
//                    }else {
//                        self.nextQuery = ""
//                        self.nowQuery = queryPattern.empty
//                    }
//                    print("nextQuery", self.nextQuery)
                }
            })
        }
    }
    
    func setImages(json: JSON) {
        for tweet in json["statuses"].array! {
            if let id = tweet["id"].int {
                self.maxId = String(id - 1)
                self.nowQuery = queryPattern.other
            } else {
                self.nowQuery = queryPattern.empty
            }
            print("取ってきたツイートのカウント", json["statuses"].array!.count)
            if let extendedEntities = tweet["extended_entities"]["media"].array {
                for mediaInfo in extendedEntities {
                    if let imageUrl = mediaInfo["media_url_https"].string {
                        self.images.append(imageUrl)
                    }
                }
            }else {
                if let imageURL = tweet["entities"]["media"][0]["media_url_https"].string {
                    self.images.append(imageURL)
                }
            }
        }
    }
    
    @objc func sorryAlert() {
        let alert = UIAlertController(
            title: LocalizeKey.notFouondAleartTitle.localizedString(),
            message: LocalizeKey.notFouondAleartMessage.localizedString(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchErrorAlert() {
        let alert = UIAlertController(
            title: LocalizeKey.errorAleartTitle.localizedString(),
            message: LocalizeKey.errorAleartMessage.localizedString(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizeKey.ok.localizedString(), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func firstSaveAlert() {
        let alert = UIAlertController(
            title: "🎉" + LocalizeKey.firstSaveAleartTitle.localizedString() + "🎉",
            message: LocalizeKey.firstSaveAleartMessage.localizedString(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizeKey.ok.localizedString(), style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    func snsShareAlert() {
        let alert = UIAlertController(
            title: LocalizeKey.snsShareAleartButton.localizedString() + "🐤",
            message:LocalizeKey.snsShareAleartMessage.localizedString() + "❤️",
            preferredStyle: .alert)
        let goToTwitter = UIAlertAction(title: LocalizeKey.snsShareAleartButton.localizedString() + "📢", style: .default) { (action) in
            let text = "@Qupick_46 https://itunes.apple.com/jp/app/id1281328373?mt=8".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            var url = URL(string: "twitter://post?message=\(text)")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                url = URL(string: "https://twitter.com/intent/tweet?text=\(text)")!
                UIApplication.shared.open(url)
            }
        }
        let cancel = UIAlertAction(title: LocalizeKey.cancel.localizedString(), style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(goToTwitter)
        self.present(alert, animated: true, completion: nil)
    }

    @objc func cropThumbnailImage(_ image :UIImage, w:Int, h:Int) ->UIImage {
        // リサイズ処理
        let origRef    = image.cgImage;
        let origWidth  = Int((origRef?.width)!)
        let origHeight = Int((origRef?.height)!)
        var resizeWidth:Int = 0, resizeHeight:Int = 0
        
        if (origWidth < origHeight) {
            resizeWidth = w
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = h
            resizeWidth = origWidth * resizeHeight / origHeight
        }
        
        let resizeSize = CGSize(width: CGFloat(resizeWidth), height: CGFloat(resizeHeight))
        UIGraphicsBeginImageContext(resizeSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: CGFloat(resizeWidth), height: CGFloat(resizeHeight)))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 切り抜き処理
        let cropRect  = CGRect(
            x: CGFloat((resizeWidth - w) / 2),
            y: CGFloat((resizeHeight - h) / 2),
            width: CGFloat(w), height: CGFloat(h))
        let cropRef   = resizeImage?.cgImage?.cropping(to: cropRect)
        let cropImage = UIImage(cgImage: cropRef!)
        
        return cropImage
    }
    
    @IBAction func closeModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension FlickViewController: KolodaViewDelegate {
    //カードをタップした時
    @objc public func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        print("imagesArraey", imagesArray)
        let image = imagesArray[index]
        let photo = IDMPhoto(image: image)
        let browser = IDMPhotoBrowser(photos: [photo as Any!], animatedFrom: koloda)
        self.present(browser!, animated: true, completion: nil)
    }
    
    //カードをスワイプしてると必ず通る(スワイプを途中で辞めても)
    public func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        if direction == SwipeResultDirection.left {
            print("shouldSwipeCardAt : left", Int(index))
        } else if direction == SwipeResultDirection.right {
            print("shouldSwipeCardAt : right ", Int(index))
        }
        return true
    }
    
    //カードをスワイプし終わった時
    public func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == SwipeResultDirection.left {
            print("didSwipeCardAtIndex : left")
        }else if direction == SwipeResultDirection.right {
            print("didSwipeCardAtIndex : right")
            print("save Image")
            savedImage(index: Int(index))
        }
        removeGarbageImageArray(index: index)
        presentAdo()
    }
    
    @objc public func savedImage(index: Int) {
        print("saved image.")
        UIImageWriteToSavedPhotosAlbum(imagesArray[index]!, self, nil, nil)

        Defaults[.saveCount] += 1
        if Defaults[.saveCount] == 1 {
            // 初めて画像保存できたことを伝える
            self.firstSaveAlert()
        } else if Defaults[.saveCount] == 5 {
            if Defaults[.presentReaview] {
                // レビュー依頼
                Defaults[.presentReaview] = true
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    // Fallback on earlier versions
                }
            }
        } else if Defaults[.saveCount] == 10 {
            //SNSシェア依頼(Twitter)
            self.snsShareAlert()
        }
    }
    
    @objc func removeGarbageImageArray(index : Int) {
        print("imagesArrayのいらないとこ消す")
        imagesArray.removeValue(forKey: index)
    }
    
    @objc func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: interstitialADTestUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    func presentAdo() {
        adoCount += 1
        print("adoCount : ", adoCount)
        if adoCount >= 7 {
            //7回以上フリックした後は5分の１で広告表示
            if arc4random_uniform(5) == 1 {
                if Defaults[.presentReaview] {
                    if interstitial.isReady {
                        interstitial.present(fromRootViewController: self)
                    } else {
                        print("Ad wasn't ready")
                    }
                }
                adoCount = 0
            }
        }
    }
}

extension FlickViewController: KolodaViewDataSource {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .moderate
    }
    
    @objc func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        print("kolodaDidRunOutOfCards")
        getTwitterMedia()
    }
    
    @objc public func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        numberOfCards = images.count
        print("カードのカウント", numberOfCards)
        return numberOfCards
    }
    
    //新しいカードが現れた時
    //（あとカード３枚になったら裏側でリロード開始）
    @objc public func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        //        if index == numberOfCards - 1 {
        //            print("カードがない時多分")
        //            print("imagesのカウント", images.count)
        //            getTwitterMedia()
        //
        //        }
    }
    
    //カードのデータの読み込み
    @objc public func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        print("index", index)
        var callString = ""
        if let imageString = images.first {
            print("imagesから1つ消去前 : ", images)
            callString = imageString
            images.removeFirst()
            print("imagesから1つ消去後 : ", images)
        }else {
            print("imagesがない、次の画像データゲット")
        }
        let view = FlickView.init(frame: CGRect.zero)
        view.layer.cornerRadius =  10.0
        view.layer.masksToBounds = true
        //非同期で変換
        let req = request(callString)
        req.responseData { (response) in
            if response.result.isSuccess == true {
                if let data = response.result.value {
                    DispatchQueue.main.async {
                        
                        view.configure(image: UIImage(data: data)!)
//                        view.originalImage = UIImage(data: data)
                        
//                        view.imageView.contentMode = .scaleAspectFit
//                        view.imageView.image = view.originalImage
                        
//                        view.imageView.contentMode = .scaleAspectFill
//                        view.imageView.clipsToBounds = true
//                        view.imageView.image = view.originalImage
                        
//                        view.bgImageView.contentMode = .scaleAspectFill
//                        view.bgImageView.clipsToBounds = true
//                        view.bgImageView.image = view.originalImage
//                        view.imageView.image = self.cropThumbnailImage(view.originalImage!, w: Int(view.imageView.frame.width), h: Int(view.imageView.frame.height))
                        
//                        view.bgImageView.image = self.cropThumbnailImage(view.originalImage!, w: Int(view.imageView.frame.width), h: Int(view.imageView.frame.height))
//                        view.loadingLabel.isHidden = true
                        self.imagesArray[index] = view.originalImage!
                        print("imagesArray", self.imagesArray)
                        print("imagesArray count", self.imagesArray.count)
                    }
                }
            } else {
                print("error")
                self.searchErrorAlert()
            }
        }
        return view
    }
    
    @objc func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("EffectlayerView", owner: self, options: nil)?[0] as? OverlayView
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.35
    }
}

extension FlickViewController: GADInterstitialDelegate {
    /// Tells the delegate an ad request succeeded.
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
}
