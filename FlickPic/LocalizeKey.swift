//
//  LocalizeKey.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2019/07/06.
//  Copyright © 2019 Eisuke Sato. All rights reserved.
//

import UIKit

enum LocalizeKey: String {

    case test
    case searchPlaceholder
    case emptyHotWord
    case emptyHistory
    case helpAleartTitle
    case helpAleartHowTo
    case helpAleartContact
    case searchAleartTitle
    case searchAleartMessage
    case saveAleartTitle
    case saveAleartMessage
    case recommendAleartTitle
    case recommendAleartMessage
    case next
    case ok
    case keyWordEmptyAleartTitle
    case keyWordEmptyAleartMessage
    case notFouondAleartTitle
    case notFouondAleartMessage
    case errorAleartTitle
    case errorAleartMessage
    case firstSaveAleartTitle
    case firstSaveAleartMessage
    case reviewAleartTitle
    case reviewAleartMessage
    case pushAleartTitle
    case pushAleartSearchButton
    case pushAleartCancelButton
    case occasionAleartTitle
    case occasionAleartMessage
    case termsAleartTitle
    case termsAleartMessage
    case cancel
    
    // selfの値をローカライズして返す
    func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
