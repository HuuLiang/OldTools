//
//  HLExtension-String.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import Foundation
import CoreGraphics

extension String {
    /// 使用下标截取字符串 例: "示例字符串"[0..<2] 结果是 "示例"
    subscript (r: Swift.Range<Int>) -> String {
        get {
            if (r.lowerBound > count) || (r.upperBound > count) { return "截取超出范围" }
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    
    var floatValue:CGFloat {
        get {
            let strDouble = Double(self)
            let strFloat = CGFloat(strDouble ?? 0.0)
            return strFloat
        }
    }
}
