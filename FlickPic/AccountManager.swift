
//
//  AccountManager.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2018/07/13.
//  Copyright © 2018年 Eisuke Sato. All rights reserved.
//

import UIKit
import Ballcap

class AccountManager: NSObject {
    static let shared = AccountManager()
    var currentUser: Document<User>?
}

//class TestManager: NSObject {
//    static let shared = TestManager()
//    var currentUser: Document<TestUser>?
//}
