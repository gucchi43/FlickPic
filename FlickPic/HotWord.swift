//
//  HotWord.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2018/07/13.
//  Copyright © 2018年 Eisuke Sato. All rights reserved.
//

import Foundation
import Firebase
import Ballcap

//@objcMembers
//class HotWord : Object{
//    dynamic var word: String = ""
//    dynamic var num: Int = 0
//}

struct HotWord: Codable, Equatable, Modelable {
    var word: String = ""
    var num: Int = 0
}
//
//class HotWord: Object, DataRepresentable {
//    
//    var data: Model?
//    
//    struct Model: Modelable & Codable {
//        var word: String = ""
//        var num: Int = 0
//    }
//}
