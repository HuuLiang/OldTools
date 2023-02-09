//
//  HLDefines.swift
//  HLToolKit-Swift
//
//  Created by Liang on 2019/6/28.
//

import UIKit

public let kScreenHeight = UIScreen.main.bounds.size.height
public let kScreenWidth  = UIScreen.main.bounds.size.width

public func kWidth(_ width:CGFloat) ->CGFloat {
    return CGFloat(floorf(Float(kScreenWidth*width/375.0)))
}

public func kColor(_ hexColor:String) -> UIColor {
    return UIColor(hexColor)
}

public func kColor(_ hexColor:String, _ alpha:CGFloat) -> UIColor {
    return UIColor(hexColor, alpha)
}

public func kFont(_ font:CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: font)
}

public func kFont(_ fontName:String,_ font:CGFloat) ->UIFont! {
    return UIFont.init(name: fontName, size: font)
}

public typealias HLAction = () -> Void
public typealias HLCompletionHandler = (_ obj:AnyObject?,_ error:Error?) -> Void

public func kTimeTest(_ action:@escaping () -> Void) -> Double {
    let start:CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    action()
    let end: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    return end - start
}
