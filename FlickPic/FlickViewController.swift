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

private let frameAnimationSpringBounciness: CGFloat = 9
private let frameAnimationSpringSpeed: CGFloat = 16
private let kolodaCountOfVisibleCards = 5
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class FlickViewController: UIViewController {

    var searchText = ""

    var images = [String]()
    var imagesArray = [Int: UIImage]()
    var ItemsArray = [[String: String?]]()
    var currentRakutenItem = [String: String?]()
    var numberOfCards: Int = 100

    var nextQuery = ""
    var rakutenNextPage = 1
    
    @IBOutlet weak var targetTextLabel: UILabel!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.delegate = self
        kolodaView.dataSource = self
        kolodaView.animator = FlickViewAnimator(koloda: kolodaView)
        leftButton.tintColor = UIColor.warning()
        rightButton.tintColor = UIColor.success()
        targetTextLabel.text = searchText

        getTwitterMedia()
        callRakutenAPI()

    }

    @IBAction func tappedLeftButton(_ sender: AnyObject) {
        kolodaView.swipe(SwipeResultDirection.left)
    }
    
    @IBAction func tappedRightButton(_ sender: AnyObject) {
        kolodaView.swipe(SwipeResultDirection.right)
    }

    @IBAction func tapReloadData(_ sender: Any) {
        getTwitterMedia()
        callRakutenAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getTwitterMedia() {
        let url = "https://api.twitter.com/1.1/search/tweets.json"
        var params = [
            "q": searchText + " filter:images -filter:retweets -filter:faves",
            "lang": "ja",
            "count": "100",
            ]
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            print(userID)
            let client = TWTRAPIClient(userID: userID)
            var request = client.urlRequest(withMethod: "GET", url: url, parameters: params, error: nil)
            if nextQuery != "" {
                if nextQuery == "nothing" {
                    print("もう画像は見つからない")
                }else {
                    request = client.urlRequest(withMethod: "GET", url: url + nextQuery, parameters: nil, error: nil)
                }
            }
            client.sendTwitterRequest(request, completion: {
                response, data, error in
                if let error = error {
                    print(error)
                } else {
                    let json = JSON(data: data!)
                    print("json", json)
                    if let nextResults = json["search_metadata"]["next_results"].string {
                        print("nextResults", nextResults)
                        self.nextQuery = nextResults
                    }else {
                        self.nextQuery = "nothing"
                    }
                    print("nextQuery", self.nextQuery)
                    for tweet in json["statuses"].array! {
                        print("取ってきたツイートのカウント", json["statuses"].array!.count)
                        if let extendedEntities = tweet["extended_entities"]["media"].array {
                            for mediaInfo in extendedEntities {
                                if let imageUrl = mediaInfo["media_url"].string {
                                    self.images.append(imageUrl)
                                }
                            }
                        }else {
                            if let imageURL = tweet["entities"]["media"][0]["media_url"].string {
                                print("imageURL", imageURL)
                                print("images追加前", self.images)
                                self.images.append(imageURL)
                                print("images追加後", self.images)
                            }
                        }
                    }
                    print("imagesデータロードデビュー", self.images)
//                    self.kolodaView.reloadData()
                    self.kolodaView.resetCurrentCardIndex()
                }
            })
        }
    }
    
    func cropThumbnailImage(_ image :UIImage, w:Int, h:Int) ->UIImage {
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
    public func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        print("imagesArraey", imagesArray)
        switch (index + 1) % 8 {
        case 0 :
            print("商品表示")
            let num = (index + 1) / 8 - 1
            if ItemsArray[num].isEmpty == false{
                let image = imagesArray[index]
                let photo = IDMPhoto(image: image)
                let browser = IDMPhotoBrowser(photos: [photo as Any!], animatedFrom: koloda)
                self.present(browser!, animated: true, completion: nil)
            }else {
                print("ショップURLがない")
            }
        default :            
            print("画像")
            let image = imagesArray[index]
            let photo = IDMPhoto(image: image)
            let browser = IDMPhotoBrowser(photos: [photo as Any!], animatedFrom: koloda)
            self.present(browser!, animated: true, completion: nil)
        }
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
            switch (index + 1) % 8 {
            case 0 :
                print("go to Rauten")
                if let rakutenUrl = currentRakutenItem["itemUrl"]{
                    UIApplication.shared.openURL(URL(string: rakutenUrl!)!)
                }else {
                    print("URLがない(ありえない)")
                }
            default :
                print("save Image")
                savedImage(index: Int(index))
            }
        }
        print("imagesArray消去前", imagesArray)
        removeGarbageImageArray(index: index)
        print("imagesArray消去後", imagesArray)

        //次のカードがなくなったので次のデータをロード
        if index == numberOfCards - 1 {
            print("カードがない時多分")
            print("imagesのカウント", images.count)
            getTwitterMedia()
        }
    }

    public func savedImage(index: Int) {
        print("saved image.")
        UIImageWriteToSavedPhotosAlbum(imagesArray[index]!, self, nil, nil)
    }

    func removeGarbageImageArray(index : Int) {
        print("imagesArrayのいらないとこ消す")
        imagesArray.removeValue(forKey: index)
    }

    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation?.springBounciness = frameAnimationSpringBounciness
        animation?.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}

extension FlickViewController: KolodaViewDataSource {

    public func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        numberOfCards = images.count
        print("カードのカウント", numberOfCards)
        return numberOfCards
    }

    //カードが現れた時
    //（あとカード３枚になったら裏側でリロード開始）
    public func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
//        if index == numberOfCards - 1 {
//            print("カードがない時多分")
//            print("imagesのカウント", images.count)
//            getTwitterMedia()
//
//        }
    }

    //カードのデータの読み込み
    public func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {

        print("index", index)
        var i = arc4random_uniform(4)
        //７回に一回楽天商品
        var callString = ""
        switch (index + 1) % 8 {
        case 0:
            let num = (index + 1) / 8 - 1
            print("ItemsArray.count", ItemsArray.count)
            if ItemsArray.count != 0 {
                currentRakutenItem = ItemsArray[num]
                callString = currentRakutenItem["mediumImageUrls"]!!
                ItemsArray.remove(at: num)
            }else {
                print("楽天データがなくなった")
                callString = images.first!
                images.removeFirst()
            }
            let view = FlickView.init(frame: CGRect.zero)
            view.layer.cornerRadius = 5.0
            view.layer.masksToBounds = true
            //非同期で変換
            let req = request(callString)
            req.responseData { (response) in
                if let data = response.result.value {
                    DispatchQueue.main.async {
                        if let itemName = self.currentRakutenItem["itemName"]{
                            view.titleLabel.text = itemName!
                        }
                        if let price = self.currentRakutenItem["itemPrice"]{
                            if let price = price {
                                view.priceLabel.text = "¥" + price
                            }
                        }
                        view.originalImage = UIImage(data: data)
                        view.imageView.image = view.originalImage!
                        self.imagesArray[index] = UIImage(data: data)
//                        view.imageView.image = self.cropThumbnailImage(view.originalImage!, w: Int(view.originalImage!.size.width), h: Int(view.originalImage!.size.height))

//                        //UIImageViewの生成
//                        let imageView = UIImageView(image: UIImage(data: data))
//                        //UIImageViewのサイズを自動的にimageのサイズに合わせる
//                        imageView.contentMode = UIViewContentMode.center
//                        view.addSubview(imageView)
//                        self.imagesArray[index] = imageView.image
                    }
                }
            }
            return view
        default:
            if let imageString = images.first {
                print("imagesから1つ消去前 : ", images)
                callString = imageString
                images.removeFirst()
                print("imagesから1つ消去後 : ", images)
            }else {
                print("imagesがない、次の画像データゲット")
            }
            let view = FlickView.init(frame: CGRect.zero)
            view.layer.cornerRadius = 5.0
            view.layer.masksToBounds = true
            //非同期で変換
            let req = request(callString)
            req.responseData { (response) in
                if let data = response.result.value {
                    DispatchQueue.main.async {
                        view.originalImage = UIImage(data: data)
                        view.titleLabel.text = ""
                        view.priceLabel.text = ""
                        view.imageView.image = self.cropThumbnailImage(view.originalImage!, w: Int(view.imageView.frame.width), h: Int(view.imageView.frame.height))
                        self.imagesArray[index] = view.originalImage!
                        print("imagesArray", self.imagesArray)
                    }
                }
            }
            return view
        }
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("EffectlayerView", owner: self, options: nil)?[0] as? OverlayView
    }
}


//楽天API関連
extension FlickViewController {

    func setRakutenData(itemsJson : JSON) {
        itemsJson.forEach({ (_ , itemJson) in
            let article: [String: String?] = [
                "itemName": itemJson["Item"]["itemName"].string,
                "itemPrice": String(describing: itemJson["Item"]["itemPrice"].int!),
                "itemUrl": itemJson["Item"]["itemUrl"].string,
                "mediumImageUrls": itemJson["Item"]["mediumImageUrls"][0]["imageUrl"].string
            ]
            self.ItemsArray.append(article)
            print("ItemsArray : ", self.ItemsArray)
        })
    }

    func callRakutenAPI() {

        let rakutenUrl = "https://app.rakuten.co.jp/services/api/IchibaItem/Search/20140222?format=json&field=0&sort=standard&hits=30&applicationId=1098197859526591121"
        let parms1 = ["keyword" : searchText, "affiliateId" : "156ea7d0.ed98f7f9.156ea7d1.cd28bb8c", "imageFlag" : 1, "minAffiliateRate" : 5.0, "page" : rakutenNextPage] as [String : Any]
        let parms2 = ["keyword" : searchText, "affiliateId" : "156ea7d0.ed98f7f9.156ea7d1.cd28bb8c", "imageFlag" : 1, "page" : rakutenNextPage] as [String : Any]
        //アフィリ５%以上の商品
        let req1 = request(rakutenUrl, method: HTTPMethod.get, parameters: parms1, encoding: URLEncoding(destination: .methodDependent), headers: nil)
        //アフィリエイト制限無し
        let req2 = request(rakutenUrl, method: HTTPMethod.get, parameters: parms2, encoding: URLEncoding(destination: .methodDependent), headers: nil)

        req1.responseJSON { (response) in
            if let object = response.result.value {
                let json = JSON(object)
                let itemsJson = json["Items"]
                if itemsJson.count == 0 {
                    req2.responseJSON { (response) in
                        if response.result.isSuccess == true {
                            if let object = response.result.value {
                                let json = JSON(object)
                                let itemsJson = json["Items"]
                                print("itemsJson : ", itemsJson)
                                self.setRakutenData(itemsJson: itemsJson)
                            }
                        }else if response.result.isSuccess == false {
                            print("商品が見つからない")
                        }
                    }
                }
                print("itemsJson : ", itemsJson)
                self.setRakutenData(itemsJson: itemsJson)
                self.rakutenNextPage += 1
            }
        }
    }
}
