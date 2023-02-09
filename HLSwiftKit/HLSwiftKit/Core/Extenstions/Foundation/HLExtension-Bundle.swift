//
//  HLExtension-Bundle.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

extension Bundle {
    
    ///应用名称
    func displayName() -> String {
        return self.infoDictionary!["CFBundleDisplayName"] as! String
    }
    
    ///应用版本号
    func appVersion() -> String {
        return self.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    ///构建版本号
    func buildVersion() -> String {
        return self.infoDictionary!["CFBundleVersion"] as! String
    }
    
}
