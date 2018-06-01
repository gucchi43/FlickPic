//
//  EmptyFlickView.swift
//  FlickPic
//
//  Created by HIroki Taniguti on 2017/01/11.
//  Copyright © 2017年 Eisuke Sato. All rights reserved.
//

import UIKit

class EmptyFlickView: UIView {


    

    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }

    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("FlickView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
}
