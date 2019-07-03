//
//  FlickView.swift
//  FlickPic
//
//  Created by Eisuke Sato on 2016/06/18.
//  Copyright © 2016年 Eisuke Sato. All rights reserved.
//

import UIKit

class FlickView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    @objc var originalImage: UIImage?
    
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
        loadingLabel.textColor = ColorManager.sharedSingleton.accsentColor()
        self.addSubview(content)
    }
    
    func configure(image: UIImage) {
        originalImage = image
        
        let w = image.size.width
        let h = image.size.height
        
        // タテヨコ比が4:5よりも縦の方が長い時
        if w * 1.25 < h {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        } else {
            imageView.contentMode = .scaleAspectFit
        }
        imageView.image = image
        
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.clipsToBounds = true
        bgImageView.image = blurEffect(originImage: image)
        
        loadingLabel.isHidden = true
    }
    
    func blurEffect(originImage: UIImage) -> UIImage {
        var context = CIContext(options: nil)
        
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: originImage)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        return processedImage
    }
}
