//
//  User.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2018/07/13.
//  Copyright © 2018年 Eisuke Sato. All rights reserved.
//

import Foundation
import Firebase
import Ballcap

struct User: Codable, Equatable, Modelable {
    var originId: String = ""
    var kaisu: Int = 0
    var wordArray: [String]?
    var fcmToken: String = ""
    var badgeNum: Int = 0
}


//class User: Object, DataRepresentable {
//    
//    var data: Model?
//
//    struct Model: Modelable & Codable {
//        var originId: String = ""
//        var kaisu: Int = 0
//        var wordArray: [String]?
//        var fcmToken: String = ""
//        var badgeNum: Int = 0
//    }
//}
