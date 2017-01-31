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

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFiled: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textFiled.delegate = self
        textFiled.layer.borderColor = UIColor.clear.cgColor

        textFiled.addBorderBottom(height: 1.0, color: ColorManager.sharedSingleton.accsentColor())
    }

    override func viewDidAppear(_ animated: Bool) {
        print("call : viewDidAppear")
        firstAlert()
    }

    func alertExplain() {
        let alert = UIAlertController(
            title: "👼はじめにちょっと使い方👼",
            message: "探してる画像のキーワードを入れて、ムシメガネボタンをタップしてね🔍画像が出てくるから、いらなかったら👈にスワイプ！欲しかったら👉にスワイプ！👉にスワイプした画像は保存できてるよ✌️",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "りょ", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.alertTerms()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func alertTerms() {
        let alert = UIAlertController(
            title: "👽ついでにすこし注意書き👽",
            message: "検索ワードによっては、ちょっとエッチ💋だったり、少し怖い画像💀がでてくるかもしれないよ。もしそんなことがあってもびっくりしないで、冷静に👈にスワイプしてね。あ、もしほしかったら👉にスワイプしていいんだからねっ❤️",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "りょ", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func firstAlert() {
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

    func twitterLink() {
        Twitter.sharedInstance().logIn {
            (session, error) -> Void in
            if (session != nil) {
                print("signed in user name \(session?.userName)");
                self.performSegue(withIdentifier: "showFlickViewController", sender: self)
            } else {
                print("Error：\(error?.localizedDescription)");
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
