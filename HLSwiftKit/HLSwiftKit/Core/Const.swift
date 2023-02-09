//
//  Const.swift


@_exported import SnapKit
@_exported import Kingfisher

// MARK:Base Info
///屏幕高度
public let kScreenHeight = UIScreen.main.bounds.size.height

///屏幕宽度
public let kScreenWidth  = UIScreen.main.bounds.size.width


///是否是iPhone
public func isiPhone() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .phone
}

///是否是iPad
public func isiPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

///是否是刘海屏
public var isNotchScreen:Bool = false
///安全边距
public var kSafeInsets:UIEdgeInsets = .zero


// MARK:Layout Info
/// iphone width is 375 ,ipad width is 667
public func kWidth(_ width:CGFloat) -> CGFloat {
    return (kScreenWidth * width / 375).rounded(.toNearestOrAwayFromZero)
}

public func kFloat(_ float:CGFloat) -> CGFloat {
    return (kScreenWidth * float / 375).rounded(.toNearestOrAwayFromZero)
}


public func kEdgeInsets(top:CGFloat = 0,
                        left:CGFloat = 0,
                        bottom:CGFloat = 0,
                        right:CGFloat = 0,
                        convert:Bool = true) -> UIEdgeInsets {
    convert ? .init(top: kWidth(top),left: kWidth(left),bottom: kWidth(bottom),right: kWidth(right))
            : .init(top: top, left: left, bottom: bottom, right: right)
}

public func kRect(x:CGFloat = 0,
                  y:CGFloat = 0,
                  w:CGFloat = 0,
                  h:CGFloat = 0,
                  convert:Bool = true) -> CGRect {
    convert ? .init(x: kWidth(x), y: kWidth(y), width: kWidth(w), height: kWidth(h))
            : .init(x: x, y: y, width: w, height: h)
}

public func kSize(w:CGFloat = 0,
                  h:CGFloat = 0,
                  convert:Bool = true) -> CGSize {
    convert ? .init(width: kWidth(w), height: kWidth(h))
            : .init(width: w, height: h)
}

public func kColor(_ hex:String) -> UIColor {
    return UIColor.`init`(hex:hex)
}

public func kColor(_ hex:String, _ alpha:CGFloat) -> UIColor {
    return UIColor.`init`(hex:hex, alpha:alpha)
}

public func kColor(_ lightColor:String,_ darkColor:String,_ alpha:CGFloat = 1) -> UIColor {
    if #available(iOS 13.0, *) {
        let dymicColor =  UIColor.init { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return kColor(darkColor, alpha)
            }
            return kColor(lightColor,alpha)
        }
        return dymicColor
    } else {
        return kColor(lightColor, alpha)
    }
}

// MARK:Font

public func kFont(_ fontSize:CGFloat,_ trans:Bool = true) -> UIFont {
    return kFont("PingFangSC-Regular", fontSize, trans)
}

public func kLFont(_ fontSize:CGFloat,_ trans:Bool = true) -> UIFont {
    return kFont("PingFangSC-Light", fontSize, trans)
}

public func kMFont(_ fontSize:CGFloat,_ trans:Bool = true) -> UIFont {
    return kFont("PingFangSC-Medium", fontSize, trans)
}

public func kDFont(_ fontSize:CGFloat,_ trans:Bool = true) -> UIFont {
    return kFont("DINAlternate-Bold", fontSize, trans)
}

public func kFont(_ fontName:String,_ fontSize:CGFloat,_ trans:Bool = true) -> UIFont {
    return UIFont(name: fontName, size: trans ? kWidth(fontSize) : fontSize) ?? UIFont.systemFont(ofSize: trans ? kWidth(fontSize) : fontSize)
}

// MARK:Image
public func kImage(_ imageNamed:String) -> UIImage? {
    return UIImage.init(named: imageNamed)
}

// MARK:Action
typealias ConfirmAction = () -> Void

typealias ValidateAction = (Bool) -> Void
