//
//  HotWeekly.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2018/09/13.
//  Copyright © 2018年 Eisuke Sato. All rights reserved.
//

import Foundation
import Firebase
import Pring

@objcMembers
class HotWeekly : Object{
    dynamic var dataTitle: String = ""
    dynamic var hotWords: ReferenceCollection<HotWord> = []
}
