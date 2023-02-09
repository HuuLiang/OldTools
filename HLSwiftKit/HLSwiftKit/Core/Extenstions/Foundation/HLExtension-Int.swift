//
//  HLExtension-Int.swift
//  CloudStore
//
//  Created by 胡亮亮 on 2022/2/18.
//  Copyright © 2022 HangZhouMYQ. All rights reserved.
//

extension Array where Element == UInt32 {
    
    func toString() -> String {
        var result:String = ""
        forEach {
            result.append(Character.init(Unicode.Scalar.init($0)!))
        }
        return result
    }
    
    func encrypt() -> [UInt32] {
        var new:[UInt32] = []
        for idx in 0..<count {
            if idx % 2 == 0 {
                new.append(self[idx] + 1)
            } else {
                new.append(self[idx] - 1)
            }
        }
        return new
    }
    
    func decrypt() -> [UInt32] {
        var new:[UInt32] = []
        for idx in 0..<count {
            if idx % 2 == 0 {
                new.append(self[idx] - 1)
            } else {
                new.append(self[idx] + 1)
            }
        }
        return new
    }
    
}
