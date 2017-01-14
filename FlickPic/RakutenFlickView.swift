//
//  RakutenFlickView.swift
//  FlickPic
//
//  Created by HIroki Taniguti on 2017/01/11.
//  Copyright © 2017年 Eisuke Sato. All rights reserved.
//

import UIKit

class RakutenFlickView: UIView {

    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var captionTextView: UITextView!


    var originalImage: UIImage?

    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }

    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("RakutenFlickView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
    
}

