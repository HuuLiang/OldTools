//
//  HLExtension-Notification.swift
//  CloudStore
//
//  Created by Liang on 2020/3/12.
//  Copyright © 2020 HangZhouMYQ. All rights reserved.
//

//e.g
//
// NotificationCenter.post(customeNotification: .userLogin)

public enum CSNotification: String {
    ///登录
    case userLogin
    ///登出
    case userLogout
    
    ///购物车商品数量修改
    case cartChanged
    ///刷新购物车界面
    case cartReload
    ///购物车重新选择sku
    case cartReselect
    
    ///升级成功刷新首页数据
    case upgrade
    
//    ///友盟数据统计注册
//    case registerUM
//    ///友盟推送注册
//    case registerPush
    
    var stringValue: String {
        return "CS" + rawValue
    }
    
    var notificationName: NSNotification.Name {
        return NSNotification.Name(stringValue)
    }
}

extension NotificationCenter {
    static func post(customeNotification name: CSNotification, object: Any? = nil){
        NotificationCenter.default.post(name: name.notificationName, object: object)
    }
}
