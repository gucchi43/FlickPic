//
//  effectlayerView.swift
//  FlickPic
//
//  Created by HIroki Taniguti on 2016/12/30.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit
import Koloda
import Colours

class EffectlayerView: OverlayView {

    @IBOutlet weak var EffectlayerImageView: UIImageView!


    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                let leftColor = UIColor.warning()
                leftColor!.withAlphaComponent(0.5)
                EffectlayerImageView.backgroundColor = leftColor
                
//                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                let rightColor = UIColor.success()
                EffectlayerImageView.backgroundColor = rightColor
                rightColor?.withAlphaComponent(0.5)
//                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                EffectlayerImageView.image = nil
            }
        }
    }

}
