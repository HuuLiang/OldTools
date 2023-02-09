//
//  HLExtension-Double.swift
//  CloudStore
//
//  Created by 胡亮亮 on 2022/4/20.
//  Copyright © 2022 HangZhouMYQ. All rights reserved.
//

extension Double {
    
    var intValue:Int {
        return Int(self)
    }
    
    var decimalValue:Decimal {
        return stringValue.decimalValue
    }
    
    var stringValue:String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .none
        formatter.decimalSeparator = "."
        return formatter.string(from: self as NSNumber) ?? ""
    }
    
    var longStringValue:String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        formatter.numberStyle = .none
        formatter.decimalSeparator = "."
        return formatter.string(from: self as NSNumber) ?? ""
    }

}
