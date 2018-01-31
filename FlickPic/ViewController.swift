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

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFiled: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textFiled.delegate = self
        textFiled.layer.borderColor = UIColor.clear.cgColor
        textFiled.addBorderBottom(height: 1.0, color: ColorManager.sharedSingleton.accsentColor())
    }

    override func viewDidAppear(_ animated: Bool) {
        firstAlert()
    }

    @objc func alertExplain() {
        let alert = UIAlertController(
            title: "👼探してる画像をケンサク👼",
            message: "キーワードを入れて、ムシメガネボタンをタップしてね🔍今はTwitterの中からだけ検索できるよ🐣これからもっと増える予定だから待っててね😌",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "それで", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertSecondExplain()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertSecondExplain() {
        let alert = UIAlertController(
            title: "👼出てきた画像をホゾン👼",
            message: "出てきた画像をいらなかったら👈にスワイプ！保存したかったら👉にスワイプ！とっても簡単だね✌️",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "りょ", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertCarefull()
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
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @objc func firstAlert() {
        //初回起動判定
        let ud = UserDefaults.standard
        if ud.bool(forKey: "firstLaunch") {
            // 初回起動時の処理
            print("初回起動")
            self.alertExplain()
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            ud.set(false, forKey: "firstLaunch")
        }else {
            print("初回起動じゃない")
        }
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
        SVProgressHUD.show()
        Twitter.sharedInstance().logIn { (session, error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                print(error.localizedDescription)
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
}
