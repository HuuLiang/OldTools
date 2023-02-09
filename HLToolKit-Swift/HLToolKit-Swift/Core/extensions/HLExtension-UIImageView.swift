//
//  HLExtension-UIImageView.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/12.
//  Copyright © 2019 Liang. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    convenience init(_ fileName:String, _ fileType:String) {
        let img = UIImage.init(fileName, fileType)
        self.init(image:img)
    }
    
    convenience init(_ fileName:String) {
        let img = UIImage.init(fileName)
        self.init(image:img)
    }
    
    final func loadImage(with urlStr:String) {
        self.kf.setImage(with: URL.init(string: urlStr))
    }
    
    final func loadImage(with urlStr:String,_ placeholdImageName:String) {
        self.kf.setImage(with: URL.init(string: urlStr), placeholder: UIImage.init(placeholdImageName), options: nil, progressBlock: nil, completionHandler: nil)
    }
}
