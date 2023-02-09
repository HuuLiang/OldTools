//
//  HLExtension-UIImageView.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/12.
//  Copyright © 2019 Liang. All rights reserved.
//

enum ImageType:String {
    case png = "png"
    case jpg = "jpg"
}

extension UIImageView {
    
    final func loadImage(url:String?,placeholdImage:UIImage? = nil,size:CGSize = .zero,cornerRadius:CGFloat = 0) {
        guard url?.hasPrefix("http") == true else {
            image = placeholdImage
            return
        }
        var options:[KingfisherOptionsInfoItem] = [.cacheOriginalImage]
        if size != .zero {
            options.append(.processor(DownsamplingImageProcessor.init(size: size)))
            if cornerRadius > 0 {
                options.append(.processor(DownsamplingImageProcessor.init(size: size) |> RoundCornerImageProcessor.init(cornerRadius: cornerRadius,targetSize: size,backgroundColor: backgroundColor)))
            }
        }
        self.kf.setImage(with: URL(string: url!),
                         placeholder: placeholdImage,
                         options: options)
    }
}
