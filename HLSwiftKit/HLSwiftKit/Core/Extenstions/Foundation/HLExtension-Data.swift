//
//  HLExtension-Data.swift
//  CloudStore
//
//  Created by 胡亮亮 on 2022/3/11.
//  Copyright © 2022 HangZhouMYQ. All rights reserved.
//

extension Data {
    
    func toString() -> String {
        return String.init(data: self, encoding: .utf8) ?? ""
    }
    
}
