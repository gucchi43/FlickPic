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
            
        }
    }
    
    func setRerekiEmptyButton() {
        rirekiButton.isEnabled = false
        rirekiButton.setTitle("まだ履歴がないよ", for: UIControlState.normal)
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
        rirekiButton.setTitle("ホットワードが無いよ", for: UIControlState.normal)
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
                UIApplication.shared.registerForRemoteNotifications()
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
                title: "🕴キーワードがからっぽだよ🕴",
                message: "探してる画像のキーワードを入力してね🖍",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "りょ", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
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
    func checkHotWordData(with searchText: String, hotWeekly: Document<HotWeekly>) {
        Document<HotWord>.where("word", isEqualTo: searchText).get { (snapshot, errpr) in
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

    // HotWordのでDataを更新する
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
        let alert = UIAlertController(title: "🔥" + word + "🔥", message: "今日の激アツホットワードが届いたよ", preferredStyle: .alert)
        let serch = UIAlertAction(title: "検索する", style: .default) { (action) in
            self.textFiled.text = word
            self.twitterLink()
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(serch)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showInfoActionSheet() {
        let alert = UIAlertController(title: "👩‍🏫困りごとかい？👨‍🏫", message: nil, preferredStyle: .actionSheet)
        let help = UIAlertAction(title: "使い方を見る", style: .default) { (action) in
            self.alertExplain(firstFlag: false)
        }
        let goToLine = UIAlertAction(title: "LINEで問い合わせ", style: .default) { (action) in
            UIApplication.shared.open(URL(string: "http://line.me/ti/p/%40ozx5488u")!)
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
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
            title: "👼探してる画像をケンサク👼",
            message: "キーワードを入れて、🔍ボタンをタップしてね！今はTwitterの中からだけ検索できるよ🐣これからもっと増える予定だから待っててね😌",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "それで", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertSecondExplain(firstFlag: firstFlag)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertSecondExplain(firstFlag: Bool) {
        let alert = UIAlertController(
            title: "👼出てきた画像をホゾン👼",
            message: "出てきた画像をいらなかったら👈にスワイプ！保存したかったら👉にスワイプ！とっても簡単だね✌️",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "それでそれで", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertThirdExplain(firstFlag: firstFlag)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertThirdExplain(firstFlag: Bool) {
        let alert = UIAlertController(
            title: "👼おすすめからケンサク👼",
            message: "今までの検索履歴 → 📓！　最近のホットワード → 🔥",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "おけまる", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            if firstFlag == true {
                self.alertCarefull()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertCarefull() {
        let alert = UIAlertController(
            title: "👽ついでにすこし注意書き👽",
            message: "検索ワードによっては、ちょっとエッチ💋だったり、少し怖い画像💀がでてくるかもしれないよ。もしそんなことがあってもびっくりしないで、冷静に👈にスワイプしてね。あ、もしほしかったら👉にスワイプしていいんだからねっ❤️",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "りょ", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertTerms()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertTerms() {
        let alert = UIAlertController(
            title: "🕴最後に利用規約🕴",
            message: "この利用規約（以下，「本規約」といいます。）は，株式会社Bocchi（以下，「当社」といいます。）が提供する、Qupickのサービス（以下，「本サービス」といいます。）の利用条件を定めるものです。登録ユーザーの皆さま（以下，「ユーザー」といいます。）には，本規約に従って，本サービスをご利用いただきます。第1条（適用）本規約は，ユーザーと当社との間の本サービスの利用に関わる一切の関係に適用されるものとします。第4条（禁止事項）ユーザーは，本サービスの利用にあたり，以下の行為をしてはなりません。（1）法令または公序良俗に違反する行為（2）犯罪行為に関連する行為（3）当社のサーバーまたはネットワークの機能を破壊したり，妨害したりする行為（4）当社のサービスの運営を妨害するおそれのある行為（5）他のユーザーに関する個人情報等を収集または蓄積する行為（6）当社のサービスに関連して，反社会的勢力に対して直接または間接に利益を供与する行為（7）当社，本サービスの他の利用者または第三者の知的財産権，肖像権，プライバシー，名誉その他の権利または利益を侵害する行為（8）その他，当社が不適切と判断する行為第5条（本サービスの提供の停止等）当社は，理由の如何を問わず，ユーザーに事前に通知することなく本サービスの全部または一部の提供を停止または中断することができる権利を留保します。当社は，本サービスの提供の停止または中断により，ユーザーまたは第三者が被ったいかなる不利益または損害について，理由を問わず一切の責任を負わないものとします。第7条（利用制限および登録抹消）当社は，以下の場合には，事前の通知なく，データを削除し，ユーザーに対して本サービスの全部もしくは一部の利用を制限しまたはユーザーとしての登録を抹消することができるものとします。（1）本規約のいずれかの条項に違反した場合（2）登録事項に虚偽の事実があることが判明した場合（3）破産，民事再生，会社更生または特別清算の手続開始決定等の申立がなされたとき（4）当社からの問い合わせその他の回答を求める連絡に対して30日間以上応答がない場合（5）第2条第2項各号に該当する場合（6）その他，当社が本サービスの利用を適当でないと判断した場合前項各号のいずれかに該当した場合，ユーザーは，当然に当社に対する一切の債務について期限の利益を失い，その時点において負担する一切の債務を直ちに一括して弁済しなければなりません。当社は，本条に基づき当社が行った行為によりユーザーに生じた損害について，一切の責任を負いません。第8条（保証の否認および免責事項）当社は，本サービスに事実上または法律上の瑕疵（安全性，信頼性，正確性，完全性，有効性，特定の目的への適合性，セキュリティなどに関する欠陥，エラーやバグ，権利侵害などを含みます。）がないことを明示的にも黙示的にも保証しておりません。当社は，本サービスに起因してユーザーに生じたあらゆる損害について一切の責任を負いません。ただし，本サービスに関する当社とユーザーとの間の契約（本規約を含みます。）が消費者契約法に定める消費者契約となる場合，この免責規定は適用されません。前項ただし書に定める場合であっても，当社は，当社の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害のうち特別な事情から生じた損害（当社またはユーザーが損害発生につき予見し，または予見し得た場合を含みます。）について一切の責任を負いません。また，当社の過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害の賠償は，ユーザーから当該損害が発生した月に受領した利用料の額を上限とします。当社は，本サービスに関して，ユーザーと他のユーザーまたは第三者との間において生じた取引，連絡または紛争等について一切責任を負いません。第9条（サービス内容の変更等）当社は，ユーザーに通知することなく，本サービスの内容を変更しまたは本サービスの提供を中止することができるものとし，これによってユーザーに生じた損害について一切の責任を負いません。第10条（利用規約の変更）当社は，必要と判断した場合には，ユーザーに通知することなくいつでも本規約を変更することができるものとします。第11条（通知または連絡）ユーザーと当社との間の通知または連絡は，当社の定める方法によって行うものとします。第12条（権利義務の譲渡の禁止）ユーザーは，当社の書面による事前の承諾なく，利用契約上の地位または本規約に基づく権利もしくは義務を第三者に譲渡し，または担保に供することはできません。第13条（準拠法・裁判管轄）本規約の解釈にあたっては，日本法を準拠法とします。本サービスに関して紛争が生じた場合には，当社の本店所在地を管轄する裁判所を専属的合意管轄とします。以上",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "わかった", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            Defaults[.presentExplainView] = true
            self.pleasePushDialog()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}



