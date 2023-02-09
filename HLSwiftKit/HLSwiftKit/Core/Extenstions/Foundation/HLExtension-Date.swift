//
//  HLExtension-Date.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/8/6.
//  Copyright © 2019 Liang. All rights reserved.
//


import SwiftDate

extension Date {
    
    static func transform(_ time:String, format:String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale.init(identifier: "ZH")
        dateFormat.dateFormat = format
        return dateFormat.date(from: time)!
    }
    
    static func transform(_ date:Date,format:String = "yyyy-MM-dd HH:mm:ss") -> String {
        return date.transform(with: format)
    }
    
    func transform(with format:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale.init(identifier: "ZH")
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
    
    func calculateNewDate(_ component: Calendar.Component, _ value:Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: value, to: self)!
    }
    
    func timeCompare(form newDate:Date,with seconds:Double) -> Bool {
        let region = DateInRegion.init(self, region: .local)
        let newRegion = DateInRegion.init(newDate, region: .local)
        return (newRegion.date - region.date).timeInterval < seconds
    }
    
}
