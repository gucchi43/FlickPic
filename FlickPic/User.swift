//
//  User.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2018/07/13.
//  Copyright © 2018年 Eisuke Sato. All rights reserved.
//

import Foundation
import Firebase
import Pring

@objcMembers
class User : Object{
    dynamic var originId: String = ""
    dynamic var kaisu: Int = 0
    dynamic var wordArray: [String]?
    dynamic var fcmToken: String = ""
    dynamic var badgeNum: Int = 0
}
