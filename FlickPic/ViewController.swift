//
//  ViewController.swift
//  FlickPic
//
//  Created by Eisuke Sato on 2016/06/18.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFiled: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        textFiled.delegate = self
        textFiled.borderStyle = UITextBorderStyle.init(rawValue: 2)!
        // Do any additional setup after loading the view, typically from a nib
    }

    func loadSearchText() {
        let text = textFiled.text
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

//        if Twitter.sharedInstance().sessionStore.session() != nil {
//            self.performSegue(withIdentifier: "showFlickViewController", sender: self)
//        }else {
//            Twitter.sharedInstance().logIn {
//                (session, error) -> Void in
//                if (session != nil) {
//                    print("signed in user name \(session?.userName)");
//                    self.performSegue(withIdentifier: "showFlickViewController", sender: self)
//                } else {
//                    print("Error：\(error?.localizedDescription)");
//                }
//            }
//
//        }
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
