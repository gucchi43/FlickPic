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
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent: CGFloat = 0.1

class FlickViewController: UIViewController {

    var searchText = ""

    var images = [String]()
    var imagesArray = [Int: UIImage]()
    var ItemsArray = [[String: String?]]()
    
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
        let params = [
            "q": searchText + " filter:images -filter:retweets -filter:faves",
            "lang": "ja",
            "count": "100",
            ]
        
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            print(userID)
            let client = TWTRAPIClient(userID: userID)
            let request = client.urlRequest(withMethod: "GET", url: url, parameters: params, error: nil)
            client.sendTwitterRequest(request, completion: {
                response, data, error in
                if let error = error {
                    print(error)
                } else {
                    print("response", response)
                    print("data", data)
                    let json = JSON(data: data!)
                    let metadata = json["search_metadata"]["next_results"].string
                    print("metadata", metadata)
                    for tweet in json["statuses"].array! {
                        if let imageURL = tweet["entities"]["media"][0]["media_url"].string {
                            self.images.append(imageURL)
                        }
                    }
                    self.kolodaView.reloadData()
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
//                let shopURL = ItemsArray[num]["itemUrl"]!!
//                UIApplication.shared.openURL(URL(string: shopURL)!)
                let image = imagesArray[index]
                let photo = IDMPhoto(image: image)
                let browser = IDMPhotoBrowser(photos: [photo as Any!], animatedFrom: koloda)
                self.present(browser!, animated: true, completion: nil)
            }else {
                print("ショップURLがない")
            }
        default :            
            print("画像")
//            let image = imagesArray.first
            let image = imagesArray[index]
            let photo = IDMPhoto(image: image)
            let browser = IDMPhotoBrowser(photos: [photo as Any!], animatedFrom: koloda)
            self.present(browser!, animated: true, completion: nil)
//            let photo = IDMPhoto(url: NSURL(fileURLWithPath: images[index]) as URL!)
//            UIApplication.shared.openURL(URL(string: images[Int(index)])!)
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
                let num = (index + 1) / 8 - 1
                if ItemsArray[num].isEmpty == false{
                    let shopURL = ItemsArray[num]["itemUrl"]!!
                    UIApplication.shared.openURL(URL(string: shopURL)!)
                }else {
                    print("ショップURLがない")
                }
            default :
                print("save Image")
                savedImage(index: Int(index))
            }
        }
        print("imagesArray消去前", imagesArray)
        removeGarbageImageArray(index: index)
        print("imagesArray消去後", imagesArray)
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

    public func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {
        
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
            if ItemsArray[num].isEmpty == false{
                callString = ItemsArray[num]["mediumImageUrls"]!!
            }else {
                print("楽天から取ってきたデータがもうない")
                //とりあえずの手段
                if let imageString = images.first {
                    callString = imageString
                    images.removeFirst()
                }else {
                    print("imagesがない、次の画像データゲット")
                }
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
                        if let itemName = self.ItemsArray[num]["itemName"]{
                            view.titleLabel.text = itemName
                        }
                        if let price = self.ItemsArray[num]["itemPrice"]{
                            view.priceLabel.text = price
                        }
                        view.imageView.image = view.originalImage!
//                        view.imageView.image = self.cropThumbnailImage(view.originalImage!, w: Int(view.originalImage!.size.width), h: Int(view.originalImage!.size.height))
                        self.imagesArray[index] = view.originalImage!
                    }
                }
            }
            return view
        default:
            if let imageString = images.first {
                callString = imageString
                images.removeFirst()
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
//                        self.imagesArray.append(view.originalImage!)
                        print("imagesArray", self.imagesArray)
                    }
                }
            }
            return view
        }
    }

    public func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return Int(images.count)
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("EffectlayerView", owner: self, options: nil)?[0] as? OverlayView
    }
}

extension FlickViewController {

    func setRakutenData(itemsJson : JSON) {
        itemsJson.forEach({ (_ , itemJson) in
            let article: [String: String?] = [
                "item" : itemJson["Item"]["itemName"].string,
                "itemName": itemJson["Item"]["itemName"].string,
                "itemPrice": itemJson["Item"]["itemPrice"].string,
                "itemUrl": itemJson["Item"]["itemUrl"].string,
                "mediumImageUrls": itemJson["Item"]["mediumImageUrls"][0]["imageUrl"].string
            ]
            self.ItemsArray.append(article)
            print("ItemsArray : ", self.ItemsArray)
        })
    }

    func callRakutenAPI() {

        let parms1 = ["keyword" : searchText, "minAffiliateRate" : 5.0] as [String : Any]
        let parms2 = ["keyword" : searchText] as [String : Any]


        //アフィリ５%以上の商品
        let req1 = request("https://app.rakuten.co.jp/services/api/IchibaItem/Search/20140222?format=json&field=0&sort=standard&hits=30&applicationId=1098197859526591121", method: HTTPMethod.get, parameters: parms1, encoding: URLEncoding(destination: .methodDependent), headers: nil)
        //アフィリエイト制限無し
        let req2 = request("https://app.rakuten.co.jp/services/api/IchibaItem/Search/20140222?format=json&field=0&sort=standard&hits=30&applicationId=1098197859526591121", method: HTTPMethod.get, parameters: parms2, encoding: URLEncoding(destination: .methodDependent), headers: nil)

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
            }
        }
    }
}
