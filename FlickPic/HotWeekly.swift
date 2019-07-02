//
//  HotWeekly.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2018/09/13.
//  Copyright © 2018年 Eisuke Sato. All rights reserved.
//

import Foundation
import Firebase
import Ballcap

//@objcMembers
//class HotWeekly : Object{
//    dynamic var dataTitle: String = ""
//    dynamic var hotWords: ReferenceCollection<HotWord>?
//}
//

struct HotWeekly: Codable, Equatable, Modelable {
    var dataTitle: String = ""
    var hotWords: [HotWord] = []
}

//
//class HotWeekly: Object, DataRepresentable & HierarchicalStructurable {
//
//    var data: Model?
//
//    var hotWords: [Hotword] = []
////    var transcripts: [Transcript] = []
//
//    struct Model: Modelable & Codable {
//        var dataTitle: String = ""
//    }
//
//    enum CollectionKeys: String {
//        case hotWords
//    }
//}
