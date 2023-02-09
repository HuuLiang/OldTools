//
//  HLExtension-UIColor.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import UIKit

public extension UIColor {
    
//    static func hex(_ value: UInt32) -> UIColor {
//
//        let r = (value & 0xFF000000) >> 24
//        let g = (value & 0x00FF0000) >> 16
//        let b = (value & 0x0000FF00) >> 8
//        let a = (value & 0x000000FF)
//
//        return rgba(r: Int(r), g: Int(g), b: Int(b), a: Int(a))
//    }
//
//    static func rgba(r: Int, g: Int, b: Int, a: Int) -> UIColor {
//        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
//    }
    
    var toHexString:String {
        
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
                
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format:"%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
    static func `init`(hex:String) -> UIColor {
        return `init`(hex:hex, alpha:1.0)
    }
    
    static func `init`(hex:String,alpha:CGFloat) -> UIColor {
        let hexStr = hex.trimmingCharacters(in: .punctuationCharacters).lowercased()
        
        assert(hexStr.count == 6, "hex has 6 chars ,e.g. efefef ")
        
        if hexStr == "ffffff" {
            return .init(white: 1, alpha: alpha)
        } else if hexStr == "000000" {
            return .init(white: 0, alpha: alpha)
        }
        var red_:UInt32 = 0
        var green_:UInt32 = 0
        var blue_:UInt32 = 0
        
        let redStr = hexStr[0..<2]
        let greenStr = hexStr[2..<4]
        let blueStr = hexStr[4..<6]
        
        Scanner.init(string: redStr).scanHexInt32(&red_)
        Scanner.init(string: greenStr).scanHexInt32(&green_)
        Scanner.init(string: blueStr).scanHexInt32(&blue_)
        
        return UIColor.init(red: CGFloat(red_)/255.0, green: CGFloat(green_)/255.0, blue: CGFloat(blue_)/255.0, alpha: alpha)
    }
    
    var components:[CGFloat] {
        get {
            guard let c = cgColor.components else {
                return [0, 0, 0, 1]
            }
            if (cgColor.numberOfComponents == 2) {
                return [c[0], c[0], c[0], c[1]]
            } else {
                return [c[0], c[1], c[2], c[3]]
            }
        }
    }
    
    static func interpolate(from: UIColor, to: UIColor, with fraction: CGFloat) -> UIColor {
      let f = min(1, max(0, fraction))
      let c1 = from.components
      let c2 = to.components
      let r = c1[0] + (c2[0] - c1[0]) * f
      let g = c1[1] + (c2[1] - c1[1]) * f
      let b = c1[2] + (c2[2] - c1[2]) * f
      let a = c1[3] + (c2[3] - c1[3]) * f
      return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}


extension UIColor {
    
    var image:UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(self.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
}
