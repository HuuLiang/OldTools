//
//  HLExtension-UIColor.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import UIKit

public extension UIColor {
    
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
    
    convenience init(_ hex:String) {
        self.init(hex, 1.0)
    }
    
    convenience init(_ hex:String,_ alpha:CGFloat) {
        
        var hexStr = hex
        if hexStr.hasPrefix("#") {
            hexStr = hexStr[1..<7]
        }
        assert(hexStr.count == 6, "hex has 6 chars ,e.g. efefef ")
        
        var red_:UInt32 = 0
        var green_:UInt32 = 0
        var blue_:UInt32 = 0
        
        
        let redStr = hex[0..<2]
        let greenStr = hex[2..<4]
        let blueStr = hex[4..<6]
        
        Scanner.init(string: redStr).scanHexInt32(&red_)
        Scanner.init(string: greenStr).scanHexInt32(&green_)
        Scanner.init(string: blueStr).scanHexInt32(&blue_)
        
        self.init(red: CGFloat(red_)/255.0, green: CGFloat(green_)/255.0, blue: CGFloat(blue_)/255.0, alpha: alpha)
    }
//
//    @objc static func hex(_ hex:String) -> UIColor? {
//        return UIColor(hex)
//    }
//
//    @objc static func hex(_ hex:String,_ alpha:CGFloat) -> UIColor? {
//        return UIColor(hex,alpha)
//    }
    
}
