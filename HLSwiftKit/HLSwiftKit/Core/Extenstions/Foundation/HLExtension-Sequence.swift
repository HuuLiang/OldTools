//
//  HLExtension-Sequence.swift
//  CloudStore
//
//  Created by Liang on 2021/7/2.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//


extension Sequence {
    
    func customMap(_ each:(inout Element) -> Void) -> [Element] {
        var result:[Element] = []
        for var item in self {
            each(&item)
            result.append(item)
        }
        return result
    }

    mutating func mutatingMap(_ each:(inout Element) -> Void) {
        var result:[Element] = []
        for var item in self {
            each(&item)
            result.append(item)
        }
        self = result as! Self
    }

}


extension Sequence {
    
//    func toString() -> String {
//        let encoder = JSONEncoder()
//        let x = try! encoder.encode(self)
//        
//    }
    
}
