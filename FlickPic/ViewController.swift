//
//  ViewController.swift
//  FlickPic
//
//  Created by Eisuke Sato on 2016/06/18.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import Colours
import TwitterKit
import SVProgressHUD
import FontAwesome_swift
import SafariServices
import SwiftyUserDefaults
import UserNotifications
import Firebase
import SwiftDate
import Ballcap

import SVProgressHUD

public extension SVProgressHUD {
    
    struct qp {
        public static func show(maskType: SVProgressHUDMaskType = .clear) {
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setFont(UIFont.boldSystemFont(ofSize: 14.0))
            SVProgressHUD.setRingThickness(6.0)
            SVProgressHUD.setForegroundColor(ColorManager.sharedSingleton.accsentColor())
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            SVProgressHUD.setMinimumDismissTimeInterval(2.0)
            SVProgressHUD.setDefaultMaskType(maskType)
            SVProgressHUD.show()
        }
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFiled: UITextField!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var rirekiButton: UIButton!
    @IBOutlet weak var rirekiRightButton: UIButton!
    @IBOutlet weak var rirekiLeftButton: UIButton!
    
    @IBOutlet weak var hotButton: UIButton!
    @IBOutlet weak var rerekiButton: UIButton!
    @IBOutlet weak var selectStateLabel: UILabel!

    var currentRerekiNum = 0
    var maxRerekiNum = 0
    var currentHotNum = 0
    var maxHotNum = 0
    
    var rerekiFlag = true
    var sortedHotArray: [HotWord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFiled.delegate = self
        textFiled.layer.borderColor = UIColor.clear.cgColor
        textFiled.addBorderBottom(height: 1.0, color: ColorManager.sharedSingleton.accsentColor())
        textFiled.fitTextToBounds()
        
        let attributes = [
//            NSAttributedStringKey.foregroundColor: ColorManager.sharedSingleton.accsentColor(),
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)
        ]
        
        textFiled.attributedPlaceholder = NSAttributedString(string: LocalizeKey.searchPlaceholder.localizedString(), attributes:attributes)
        infoButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 32, style: .regular)
        infoButton.setTitle(String.fontAwesomeIcon(name: .questionCircle), for: .normal)
        subConfigure()
        addObserver()
    }
    
    func subConfigure() {
        rirekiButton.titleLabel?.adjustsFontSizeToFitWidth = true
        rirekiButton.layer.borderColor = UIColor.clear.cgColor
        rirekiButton.addBorderBottom(height: 1.0, color: ColorManager.sharedSingleton.accsentColor())
        
        selectStateLabel.text = "🌛"
        rerekiButton.setTitle("📓", for: .normal)
        hotButton.setTitle("🔥", for: .normal)
        hotButton.alpha = 0.5
        rerekiButton.alpha = 1.0
        rerekiButton.titleLabel?.font = UIFont.systemFont(ofSize: 44)
        hotButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRereki()
        getHotArray()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstAlert()
    }
    
    func loadRereki() {
        maxRerekiNum = Defaults[.searchedWords].count
        if maxRerekiNum > 0 {
            setRirekiButtonTitle(with: Defaults[.searchedWords][currentRerekiNum])
        } else {
            setRerekiEmptyButton()
        }
    }
    
    func setRerekiEmptyButton() {
        rirekiButton.isEnabled = false
        rirekiButton.setTitle(NSLocalizedString(LocalizeKey.emptyHistory.localizedString(), comment: ""), for: UIControlState.normal)
    }
    
    func setRirekiButtonTitle(with title: String) {
        rirekiButton.isEnabled = true
        if rerekiFlag {
            rirekiButton.setTitle(title, for: UIControlState.normal)
        } else {
            var numEmoji = ""
            switch currentHotNum{
            case 0:
                numEmoji = "🥇 "
            case 1:
                numEmoji = "🥈 "
            case 2:
                numEmoji = "🥉 "
            case 3:
                numEmoji = "4️⃣ "
            case 4:
                numEmoji = "5️⃣ "
            default:
                numEmoji = ""
            }
            rirekiButton.setTitle(numEmoji + title, for: UIControlState.normal)
        }
    }
    
    func changeRerekiButton(next: Bool) {
        guard maxRerekiNum > 0 else { return }
        if next {
            if currentRerekiNum == maxRerekiNum - 1 {
                currentRerekiNum = 0
            } else {
                currentRerekiNum += 1
            }
        } else {
            if currentRerekiNum == 0 {
                currentRerekiNum = maxRerekiNum - 1
            } else {
                currentRerekiNum -= 1
            }
        }
        setRirekiButtonTitle(with: Defaults[.searchedWords][currentRerekiNum])
    }
    
    func getHotArray() {
        let firstWeekDay = Date().dateAt(.startOfWeek)
        print("firstWeekDay : ", firstWeekDay)
        Document<HotWeekly>.get(id: firstWeekDay.toString()) { (doc, error) in
            if let error = error {
                print(error)
            } else {
                guard let doc = doc else { return }
                let hotWordsData = doc.data!.hotWords
                print("hotWordsData : ", hotWordsData)
                let result = hotWordsData.sorted(by: { $0.num > $1.num })
                self.sortedHotArray = Array(result.prefix(5))
                print("sortedHotArray : ", self.sortedHotArray)
                self.loadHotArray()
            }
        }
    }
    
    func loadHotArray() {
        maxHotNum = sortedHotArray.count
        if maxHotNum > 0 {
            let hot: HotWord = sortedHotArray[currentHotNum]
            setRirekiButtonTitle(with: hot.word)
        } else {
            setHotEmptyButton()
        }
    }
    
    func changeHotButton(next: Bool) {
        guard maxHotNum > 0 else { return }
        if next {
            if currentHotNum == maxHotNum - 1 {
                currentHotNum = 0
            } else {
                currentHotNum += 1
            }
        } else {
            if currentHotNum == 0 {
                currentHotNum = maxHotNum - 1
            } else {
                currentHotNum -= 1
            }
        }
        let currentHot:HotWord = sortedHotArray[currentHotNum]
        setRirekiButtonTitle(with: currentHot.word)
    }
    
    func setHotEmptyButton() {
        rirekiButton.isEnabled = false
        rirekiButton.setTitle(LocalizeKey.emptyHotWord.localizedString(), for: UIControlState.normal)
    }
    
    func setHotButtonTitle(with title: String) {
        hotButton.isEnabled = true
        hotButton.setTitle(title, for: UIControlState.normal)
    }
 
    @IBAction func tapHotButton(_ sender: Any) {
        selectStateLabel.text = "🌜"
        hotButton.alpha = 1.0
        rerekiButton.alpha = 0.5
        rerekiButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        hotButton.titleLabel?.font = UIFont.systemFont(ofSize: 44)
        rerekiFlag = false
        loadHotArray()
    }
    
    @IBAction func tapRerekiButton(_ sender: Any) {
        selectStateLabel.text = "🌛"
        hotButton.alpha = 0.5
        rerekiButton.alpha = 1.0
        rerekiButton.titleLabel?.font = UIFont.systemFont(ofSize: 44)
        hotButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        rerekiFlag = true
        loadRereki()
    }
    
    func pleasePushDialog() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            if granted {
                print("プッシュ通知ダイアログ 許可")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("プッシュ通知ダイアログ 拒否")
            }
        })
    }

    //MARK: キーボードが出ている状態で、キーボード以外をタップしたらキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //非表示にする。
        if(textFiled.isFirstResponder){
            textFiled.resignFirstResponder()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()

        return true
    }

    @objc func twitterLink() {
        let store = TWTRTwitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            self.performSegue(withIdentifier: "showFlickViewController", sender: self)
        } else {
            self.logInAndSearch()
        }
        if let text = self.textFiled.text {
            // DEBUG
            self.updateUserRirekiData(with: text)
            self.checkHotWeekly(with: text)
        }
    }
    
    func logInAndSearch() {
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            SVProgressHUD.qp.show()
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                print("error : ", error.localizedDescription)
            }else {
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "showFlickViewController", sender: self)
            }
        }
    }

    @IBAction func tapSearchButton(_ sender: Any) {
        if textFiled.text?.isEmpty == true {
            let alert = UIAlertController(
                title: LocalizeKey.keyWordEmptyAleartTitle.localizedString(),
                message: LocalizeKey.keyWordEmptyAleartMessage.localizedString(),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: LocalizeKey.ok.localizedString(), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            }))
            self.present(alert, animated: true, completion: nil)
        }else {
            self.twitterLink()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFlickViewController" {
            let flickViewController = segue.destination as! FlickViewController
            if let searchText = textFiled.text {
                flickViewController.searchText = searchText
            }
        }
    }

    func addObserver() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(autoSearchWord(notification:)), name: .receiveHotwordNotification, object: nil)
    }
    
    @objc func autoSearchWord(notification: Notification) {
        guard let word = notification.userInfo?["word"] as? String else { return }
            if let status = notification.userInfo!["status"] as? String {
                if status == "FG" {
                    if (UIApplication.topViewController() as? ViewController) != nil {
                        showHotWordAlert(word: word)
                    }
                } else {
                    self.textFiled.text = word as! String
                    self.twitterLink()
                }
            }
    }
    
    @IBAction func tapRirekiButton(_ sender: Any) {
        let searchText = rirekiButton.titleLabel?.text
        if rerekiFlag {
            textFiled.text = searchText!
        } else {
            textFiled.text = sortedHotArray[currentHotNum].word
        }
        self.twitterLink()
    }
    
    @IBAction func tapRirekiRightButton(_ sender: Any) {
        if rerekiFlag {
            changeRerekiButton(next: true)
        } else {
            changeHotButton(next: true)
        }
    }
    
    @IBAction func tapRirekiLeftButton(_ sender: Any) {
        if rerekiFlag {
            changeRerekiButton(next: false)
        } else {
            changeHotButton(next: false)
        }
    }

    @IBAction func tapInfoButton(_ sender: Any) {
        showInfoActionSheet()
    }
}

// HotWordのsave,update関連
extension ViewController {

    // HotWeeklyがすでにあるかチェック
    // ある -> checkHotWordData へ
    // ない -> HotWeekly を新規作成 -> checkHotWordData へ
    func checkHotWeekly(with searchText: String) {
        Document<HotWeekly>.get(id: Date().dateAt(.startOfWeek).toString()) { (doc, error) in
            if let error = error {
                print(error)
            } else {
                if let doc = doc {
                    self.checkHotWordData(with: searchText, hotWeekly: doc)
                } else {
                    let newHotWeekly = Document<HotWeekly>.init(id: Date().dateAt(.startOfWeek).toString())
                    newHotWeekly.data?.dataTitle = Date().dateAt(.startOfWeek).toString()
                    newHotWeekly.save(completion: { (error) in
                        if let error = error {
                            print(error)
                        } else {
                            print("checkHotWeekly save 成功")
                            self.checkHotWordData(with: searchText, hotWeekly: newHotWeekly)
                        }
                    })
                }

            }
        }
    }

    // HotWordのDataを更新する(set役)
    // HotWordがある -> setして、updateHotWordData へ
    // HotWordがない -> setして、createHotWordData へ
    func checkHotWordData(with searchText: String, hotWeekly: Document< HotWeekly>) {
        Document<HotWord>.where("word", isEqualTo: searchText).get { (snapshot, error) in
            snapshot?.documents.first?.data()
            if let doc = snapshot?.documents.first {
                let hotWordData = doc.data()
                let updateDate = (hotWordData["updatedAt"] as! Timestamp).dateValue()
                print(updateDate)
                var resetFlag = true
                if updateDate.compare(.isThisWeek) {
                    //前回のデータは今週中にupdateされたもの→numを+1で更新する
                    resetFlag = false
                } else {
                    //前回のデータは今週より前にupdateされたもの→numを=1で更新する
                    resetFlag = true
                }
                self.updateHotWordData(with: doc.documentID, data: hotWordData, resetFlag: resetFlag, hotWeekly: hotWeekly)
            } else {
                self.createHotWordData(with: searchText, hotWeekly: hotWeekly)
            }
        }
    }

    // HotWordのDataを更新する
    // -> 既存のHotWordのnumを更新する
    // -> HotWeeklyのデータを更新する(save役)
    // -> Done!
    func updateHotWordData(with id: String, data: [String: Any], resetFlag: Bool, hotWeekly: Document<HotWeekly>){
        
        let hotWord: Document<HotWord> = Document(id: id)
        hotWord.data!.word = data["word"] as! String
        if resetFlag {
            hotWord.data!.num = 1
        } else {
            hotWord.data!.num = (data["num"] as! Int) + 1
        }
        hotWord.update { (error) in
            if let error = error {
                print(error)
            } else {
                print("hotword update まで成功 : ", data["word"] as! String)
                let targetArray = hotWeekly.data?.hotWords.filter{$0.word == hotWord.data!.word}
                if let target = targetArray?.first {
                    if let index = hotWeekly.data?.hotWords.index(of: target) {
                        hotWeekly.data?.hotWords.remove(at: index)
                        hotWeekly.data?.hotWords.append(hotWord.data!)
                    }
                } else {
                    hotWeekly.data?.hotWords.append(hotWord.data!)
                }
                print("test 後: ", hotWeekly.data?.hotWords)
                hotWeekly.update(completion: { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("horWord cycle done!! current ver")
                    }
                })
            }
        }
    }

    // HotWord新規作成 & HotWeeklyに追加
    func createHotWordData(with searchText: String, hotWeekly: Document<HotWeekly>) {

        //documentIdをUUID生成して独自で作る場合
        // 一応残しとく
        // let hotWord: Document<HotWord> = Document()
        // let uuid = NSUUID().uuidString
        // print("uuid: \(uuid)")
        // let hotWord: Document<HotWord> = Document<HotWord>.init(id: uuid)
        
        let hotWord: Document<HotWord> = Document()
        hotWord.data?.word = searchText
        hotWord.data?.num = 1
        hotWord.save { (error) in
            if let error = error {
                print(error)
            } else {
                print("hotword update まで成功 : ", searchText)
                hotWeekly.data?.hotWords.append(hotWord.data!)
                hotWeekly.update(completion: { (error) in
                    if let error = error {
                        print(error)
                    } else {
                        print("horWord cycle done!! new ver")
                    }
                })
            }
        }
    }

    func updateUserRirekiData(with searchText: String) {
        if Defaults[.searchedWords].index(of: searchText) == nil {
            if Defaults[.searchedWords].count <= 5{
                Defaults[.searchedWords].insert(searchText, at: 0)
            } else {
                Defaults[.searchedWords].removeLast()
                Defaults[.searchedWords].insert(searchText, at: 0)
            }
        } else {
            print("searchedWordsの中に" + searchText + "はすでにあった")
            Defaults[.searchedWords].remove(at: Defaults[.searchedWords].index(of: searchText)!)
            Defaults[.searchedWords].insert(searchText, at: 0)
        }
        guard let user = AccountManager.shared.currentUser else { return }
        user.data?.wordArray = Defaults[.searchedWords]
        user.update()
    }
}

extension ViewController {
    func showHotWordAlert(word: String) {
        let alert = UIAlertController(title: "🔥" + word + "🔥", message: LocalizeKey.pushAleartTitle.localizedString(), preferredStyle: .alert)
        let serch = UIAlertAction(title: LocalizeKey.pushAleartSearchButton.localizedString(), style: .default) { (action) in
            self.textFiled.text = word
            self.twitterLink()
        }
        let cancel = UIAlertAction(title: LocalizeKey.pushAleartCancelButton.localizedString(), style: .cancel, handler: nil)
        alert.addAction(serch)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showInfoActionSheet() {
        let alert = UIAlertController(title: "👩‍🏫 " + NSLocalizedString(LocalizeKey.helpAleartTitle.localizedString(), comment: "") + " 👨‍🏫", message: nil, preferredStyle: .actionSheet)
        let help = UIAlertAction(title: LocalizeKey.helpAleartHowTo.localizedString(), style: .default) { (action) in
            self.alertExplain(firstFlag: false)
        }
        let goToLine = UIAlertAction(title: LocalizeKey.helpAleartContact.localizedString(), style: .default) { (action) in
            UIApplication.shared.open(URL(string: "http://line.me/ti/p/%40ozx5488u")!)
        }
        let cancel = UIAlertAction(title: LocalizeKey.cancel.localizedString(), style: .cancel, handler: nil)
        alert.addAction(help)
        alert.addAction(goToLine)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func firstAlert() {
        //初回起動判定
        if Defaults[.presentExplainView] {
            print("もう説明してる")
        } else {
            print("初めてなので説明")
            self.alertExplain(firstFlag: true)
        }
    }
    
    @objc func alertExplain(firstFlag: Bool) {
        let alert = UIAlertController(
            title: "👼" + LocalizeKey.searchAleartTitle.localizedString() + "👼",
            message: LocalizeKey.searchAleartMessage.localizedString(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizeKey.next.localizedString(), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertSecondExplain(firstFlag: firstFlag)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertSecondExplain(firstFlag: Bool) {
        let alert = UIAlertController(
            title: "👼" + LocalizeKey.saveAleartTitle.localizedString() + "👼",
            message: LocalizeKey.saveAleartMessage.localizedString(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizeKey.next.localizedString(), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertThirdExplain(firstFlag: firstFlag)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertThirdExplain(firstFlag: Bool) {
        let alert = UIAlertController(
            title: "👼" + LocalizeKey.recommendAleartTitle.localizedString() + "👼",
            message: LocalizeKey.recommendAleartMessage.localizedString(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizeKey.ok.localizedString(), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            if firstFlag == true {
                self.alertCarefull()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertCarefull() {
        let alert = UIAlertController(
            title: "👽" + LocalizeKey.occasionAleartTitle.localizedString() + "👽",
            message: LocalizeKey.occasionAleartMessage.localizedString(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizeKey.ok.localizedString(), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertTerms()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertTerms() {
        let alert = UIAlertController(
            title: "🕴" + LocalizeKey.termsAleartTitle.localizedString() + "🕴",
            message: LocalizeKey.termsAleartMessage.localizedString(),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizeKey.ok.localizedString(), style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            Defaults[.presentExplainView] = true
            self.pleasePushDialog()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
