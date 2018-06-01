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
    @IBOutlet weak var rightActionLabel: UILabel!

    @IBOutlet weak var leftActionLabel: UILabel!

    override var overlayState: SwipeResultDirection? {
        didSet {
            switch overlayState {
            case .left? :
                let leftColor = UIColor.warning()
                leftColor!.withAlphaComponent(0.3)
                EffectlayerImageView.backgroundColor = leftColor


                leftActionLabel.isHidden = false
                rightActionLabel.isHidden = true

//                overlayImageView.image = UIImage(named: overlayLeftImageName)
            case .right? :
                let rightColor = UIColor.success()
                EffectlayerImageView.backgroundColor = rightColor
                rightColor?.withAlphaComponent(0.3)

                rightActionLabel.isHidden = false
                leftActionLabel.isHidden = true

//                overlayImageView.image = UIImage(named: overlayRightImageName)
            default:
                EffectlayerImageView.image = nil
            }
        }
    }

}
