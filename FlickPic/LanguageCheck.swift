//
//  LanguageCheck.swift
//  FlickPic
//
//  Created by Hiroki Taniguchi on 2019/07/10.
//  Copyright © 2019 Eisuke Sato. All rights reserved.
//

import UIKit

class LanguageCheck {

    fileprivate func get() -> String {
        let type = Bundle.main.preferredLocalizations.first!
        return type
    }
    
    func checkLanguage() -> String {
        let type = get()
        if type.contains("ja") {
            return "ja"
        }
        if type.contains("ko") {
            return "ko"
        }
        if type.contains("ru") {
            return "ru"
        }
        if type.contains("pt") {
            return "pt"
        }
        if type.contains("ar") {
            return "ar"
        }
        if type.contains("es") {
            return "es"
        }
        if type.contains("fr") {
            return "fr"
        }
        if type.contains("zh") {
            return "zh"
        }
        if type.contains("en") {
            return "en"
        }
        return "en"
    }
}
