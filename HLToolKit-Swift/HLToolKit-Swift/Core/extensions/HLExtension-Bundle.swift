//
//  HLExtension-Bundle.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import Foundation

extension Bundle {
    @objc func bundleVersion() -> String {
        return self.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    @objc func bundleName() -> String {
        return self.infoDictionary!["CFBundleDisplayName"] as! String
    }
}
