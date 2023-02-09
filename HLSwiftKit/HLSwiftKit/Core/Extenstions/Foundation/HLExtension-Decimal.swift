//
//  HLExtension-Decimal.swift
//  CloudStore
//
//  Created by Liang on 2021/7/26.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//


extension Decimal {
    ///重要 小数不能强转 精度会丢失 只限于乘以商品价格之后 后两位为0的场景适用
    var intValue:Int {
        return NSNumber(value: doubleValue).intValue
    }
    
    var doubleValue:Double {
//        return NSDecimalNumber(decimal: self).doubleValue
        return stringValue.doubleValue
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
