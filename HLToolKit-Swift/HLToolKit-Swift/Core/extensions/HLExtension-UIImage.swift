//
//  HLExtension-UIImage.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import UIKit

public extension UIImage {
    @objc static func color(_ colorHex:String) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(kColor(colorHex).cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    convenience init(_ fileName:String, _ fileType:String) {
        let filePath = Bundle.main.path(forResource: fileName, ofType: fileType)
        self.init(contentsOfFile:filePath!)!
    }
    
    convenience init(_ fileName:String) {
        self.init(fileName,"png")
    }
//
//    @objc static func fileName(_ fileName:String,_ fileType:String) -> UIImage? {
//        let filePath = Bundle.main.path(forResource: fileName, ofType: fileType)
//        return UIImage.init(contentsOfFile: filePath!)
//    }
//
//    @objc static func fileName(_ name:String) -> UIImage? {
//        return UIImage.fileName(name, "png")
//    }
    
}
