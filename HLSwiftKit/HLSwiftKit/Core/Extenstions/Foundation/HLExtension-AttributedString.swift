//
//  HLExtension-AttributedString.swift
//  CloudStore
//
//  Created by 胡亮亮 on 2022/5/13.
//  Copyright © 2022 HangZhouMYQ. All rights reserved.
//

extension NSAttributedString {
    
    ///整型转化为金额attribute的风格
    enum CustomPriceAttributeStyle:Equatable {
        ///主要价格
        case main(font:UIFont,color:UIColor,autoIgnoreDecimal:Bool = false,decimalFont:UIFont? = nil)
        ///正负符号
        case sign(value:String? = nil, font:UIFont? = nil,color:UIColor? = nil)
        ///金额符号
        case symbol(value:String = "¥", font:UIFont? = nil, color:UIColor? = nil,kern:CGFloat = 0,baselineOffset:CGFloat = 0)
        ///链接符号
        case link(value:String = "-",font:UIFont? = nil, color:UIColor? = nil,kern:CGFloat = 0)
        ///自定义部分
        case custom(attributes:[NSAttributedString.Key : Any] = [:])
        
        static func == (lhs: CustomPriceAttributeStyle, rhs: CustomPriceAttributeStyle) -> Bool {
            switch (lhs,rhs) {
            case (.main(_, _, _, _),.main(_, _, _, _)):
                return true
            case (.sign(_, _, _),.sign(_, _, _)):
                return true
            case (.symbol(_, _, _, _, _),.symbol(_, _, _, _, _)):
                return true
            case (.link(_,_,_,_),.link(_,_,_,_)):
                return true
            case (.custom(_),.custom(_)):
                return true
            default:return false
            }
        }
    }
    
    convenience init(value:Int,styles:[CustomPriceAttributeStyle]) {
        self.init(values: [value], styles: styles)
    }
    
    convenience init(values:[Int],styles:[CustomPriceAttributeStyle]) {
        let mutableAttri = NSMutableAttributedString()
        
        if case .main(let mainFont,let mainColor,let autoIgnoreDecimal,let decimalFont) = styles.first {
            //符号
            if case .symbol(let symbol,let font,let color,let kern,let baselineOffset) = styles.first(where: {$0 == .symbol()}) {
                mutableAttri.append(.init(string: symbol,
                                          attributes: [.font:font ?? mainFont,
                                                       .foregroundColor:color ?? mainColor,
                                                       .kern:kern,
                                                       .baselineOffset:baselineOffset]))
            }
            for idx in 0..<values.count {
                //链接符
                if idx != 0,case .link(let link,let font,let color,let kern) = styles.first(where: {$0 == .link()}) {
                    mutableAttri.addAttributes([.kern:kern], range: NSRange.init(location: mutableAttri.length - 1, length: 1))
                    mutableAttri.append(.init(string: link,
                                              attributes: [.font:font ?? mainFont,
                                                           .foregroundColor:color ?? mainColor,
                                                           .kern:kern]))
                }
                
                let doubleValue = Double(values[idx])/100.0
                let doubleValueStr = autoIgnoreDecimal ? doubleValue.stringValue : doubleValue.longStringValue
                let subMutableAttri = NSMutableAttributedString.init(string: doubleValueStr,
                                                                     attributes: [.font:mainFont,
                                                                                  .foregroundColor:mainColor])
                
                let pointRange:NSRange = (subMutableAttri.string as NSString).range(of: ".")
                if pointRange != NSRange.init(location: NSNotFound, length: 0) {
                    subMutableAttri.addAttributes([.font:decimalFont ?? mainFont],
                                                  range: NSRange.init(location: pointRange.location,
                                                                      length: subMutableAttri.string.count - pointRange.location))
                }
                mutableAttri.append(subMutableAttri)
            }
            if case .custom(let attributes) = styles.first(where: {$0 == .custom()}) {
                mutableAttri.addAttributes(attributes,
                                           range: .init(location: 0,
                                                        length: mutableAttri.string.count))
            }
        }
        
        self.init(attributedString: mutableAttri)
    }
}


extension NSTextAttachment {
    
    static func create(with font:UIFont,image:UIImage) -> NSTextAttachment {
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        let mid = font.descender + font.capHeight
        textAttachment.bounds = CGRect(x: 0, y: font.descender - image.size.height / 2 + mid + 2, width: image.size.width, height: image.size.height).integral
        return textAttachment
    }
}
