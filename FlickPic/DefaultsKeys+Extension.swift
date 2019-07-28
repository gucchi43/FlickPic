//
//  DefaultsKeys+Extension.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2018/07/09.
//  Copyright © 2018年 Eisuke Sato. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
    static let launchCount = DefaultsKey<Int>("launchCount")
    static let presentExplainView = DefaultsKey<Bool>("presentExplainView")
    static let presentReaview = DefaultsKey<Bool>("presentReaview")
    static let saveCount = DefaultsKey<Int>("saveCount")
    static let searchedWords = DefaultsKey<[String]>("searchedWords")
    static let snsShare = DefaultsKey<Bool>("snsShare")
}
