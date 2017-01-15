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

        // Do any additional setup after loading the view, typically from a nib
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
        twitterLink()
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
