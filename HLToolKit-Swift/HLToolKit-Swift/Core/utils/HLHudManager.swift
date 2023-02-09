//
//  HLHudManager.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/20.
//  Copyright © 2019 Liang. All rights reserved.
//


import SCLAlertView
import PKHUD

public class HLHudManager {
    public static func showMsg(_ message:String) {
        HUD.flash(.label(message))
    }
}
