//
//  Extension.swift
//  FlickPic
//
//  Created by HIroki Taniguti on 2017/01/09.
//  Copyright © 2017年 Eisuke Sato. All rights reserved.
//

import UIKit

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

