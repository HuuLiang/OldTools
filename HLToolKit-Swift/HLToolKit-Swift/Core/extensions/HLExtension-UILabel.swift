//
//  HLExtension-UILabel.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/17.
//  Copyright © 2019 Liang. All rights reserved.
//

import UIKit

private var labelPriceKey: Void?

extension UILabel {
    
    var price:uint? {
        get {
            return objc_getAssociatedObject(self, &labelPriceKey) as? uint
        }
        set {
            objc_setAssociatedObject(self, &labelPriceKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.attributedText = self.analysisPriceText(newValue!)
        }
    }
    
    @objc final func analysisPriceText(_ price:uint) -> NSMutableAttributedString? {
        self.price = price
        
        let attriStr = NSMutableAttributedString.init(string: "", attributes: [NSAttributedString.Key.font:self.font!,NSAttributedString.Key.foregroundColor:self.textColor!])
        if price % 100 == 0 {
            attriStr.append(NSAttributedString.init(string: "¥\(price/100)"))
        } else {
            let originalText = "¥\(CGFloat(price)/100.0)"
            attriStr.append(NSAttributedString.init(string: originalText))
            if CGFloat(price)/100.0 > 10.0 {
                let newFontSize = self.font.pointSize - 3
                let newFont = kFont(self.font.fontName, newFontSize)
                let pointRange:NSRange = (originalText as NSString).range(of: ".")
                attriStr.addAttributes([NSAttributedString.Key.font:newFont!], range: NSRange.init(location: pointRange.location, length: 2))
            }
        }
        attriStr.addAttributes([NSAttributedString.Key.kern:1], range: NSRange.init(location: 0, length: 1))
        return attriStr
    }
}
