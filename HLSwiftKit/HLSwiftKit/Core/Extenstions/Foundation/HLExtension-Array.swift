//
//  HLExtension-Array.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/7/31.
//  Copyright © 2019 Liang. All rights reserved.
//

extension Array {
    //过滤组内重复元素 保留唯一
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    
    
    //比较2组元素 返回相同元素
    
    //比较2组元素 返回不同元素

//    func filterSingle(_ isIncluded:(Element) -> Bool) -> Element? {
//        for x in self {
//            if isIncluded(x) {
//                return x
//            }
//        }
//        return nil
//    }
    
}

