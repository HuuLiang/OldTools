//
//  HLExtension-Dictionary.swift
//  CloudStore
//
//  Created by Liang on 2021/7/7.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//


extension Dictionary {
    
//    func filterSingle(_ isIncluded:(Element) -> Bool) -> Element? {
//        for x in self {
//            if isIncluded(x) {
//                return x
//            }
//        }
//        return nil
//    }
    func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else {
            return nil
        }
        guard let str = String.init(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }

}
