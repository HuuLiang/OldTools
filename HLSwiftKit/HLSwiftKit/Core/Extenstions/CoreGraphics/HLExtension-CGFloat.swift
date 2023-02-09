//
//  HLExtension-CGFloat.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/7/23.
//  Copyright © 2019 Liang. All rights reserved.
//

import Foundation

extension CGFloat {
    
    func ceilfloatValue() -> CGFloat {
        return CGFloat(ceilf(Float(self)))
    }
    
    func floorfloatValue() -> CGFloat {
        return CGFloat(floorf(Float(self)))
    }

//    ///custom 合适的高度
//    var suitHeight:CGFloat {
//        if kSafeInsets.bottom == 0 {
//            return self
//        } else {
//            return self + kSafeInsets.bottom - kWidth(8)
//        }
//    }
//    
}
