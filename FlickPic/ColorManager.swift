//
//  ColorManager.swift
//  FlickPic
//
//  Created by HIroki Taniguti on 2017/01/06.
//  Copyright © 2017年 Eisuke Sato. All rights reserved.
//

import UIKit

final class ColorManager {
    fileprivate init() {
    }
    static let sharedSingleton = ColorManager()
    //キイロ系の色
    func mainColor() -> UIColor {
        return UIColor.init(fromHexString: "F8E71C")
        //            return UIColor.init(hexString: "37CD5F", withAlpha: 1.0)
    }
    //ピンク系の色（mainColorの補色）
    func accsentColor() -> UIColor {
        return UIColor.init(fromHexString: "F31FB4")
        //        return UIColor.init(hexString: "cd37a5", withAlpha: 1.0)
    }
    //楽天の色（濁った赤）
    func rakutenColor() -> UIColor {
        return UIColor.init(fromHexString: "BE0000")
        //        return UIColor.init(hexString: "cd37a5", withAlpha: 1.0)
    }
    //既存のよくあるボタンの水色のやつ
    func defaultButtonColor() -> UIColor { //skyBuleColor
        return UIColor(red: 19/255.0, green:144/255.0, blue:255/255.0, alpha:1.0)

    }

    //緑系のクリーム色（未読のNotificationの色）
    func noReadColor() -> UIColor {
        return UIColor.init(fromHexString: "CFFFDB")
    }
    
}
