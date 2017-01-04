//
//  OverlayView.swift
//  FlickPic
//
//  Created by HIroki Taniguti on 2016/12/30.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import Koloda

private let overlayRightImageName = "yesOverlayImage"
private let overlayLeftImageName = "noOverlayImage"

class FlickOverlayView: OverlayView {

//    @IBOutlet lazy var overlayImageView: UIImageView! = {
//        [unowned self] in
//
//        var imageView = UIImageView(frame: self.bounds)
//        self.addSubview(imageView)
//
//        return imageView
//        }()

    



    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                overlayImageView.image = nil
            }
        }
    }
    
}

