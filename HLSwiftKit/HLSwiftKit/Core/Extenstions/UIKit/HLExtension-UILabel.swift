//
//  HLExtension-UILabel.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/17.
//  Copyright © 2019 Liang. All rights reserved.
//

//MARK: DynamicPriceLabel
extension UILabel {
    private struct DynamicPriceLabelKeys {
        static var originalFontKey:String? = "originalFontKey"
        static var labelPriceKey:String? = "labelPriceKey"
        static var ignoreDecimalKey:String? = "ignoreDecimalKey"
        static var showSmallDecimalKey:String? = "showSmallDecimalKey"
        static var showSmallSymbolKey:String? = "showSmallSymbolKey"
    }

    final func analysisPriceText(_ price:Int) -> NSMutableAttributedString? {
        objc_setAssociatedObject(self, &DynamicPriceLabelKeys.labelPriceKey, price, .OBJC_ASSOCIATION_ASSIGN)

        let symbolFont = showSmallSymbol ? kFont(self.originalFont.fontName, self.originalFont.pointSize * 0.7) : self.originalFont
        let newFont = kFont(self.originalFont.fontName, self.originalFont.pointSize * 0.6)

        let attriStr = NSMutableAttributedString.init(string: price >= 0 ? "¥" : "-¥", attributes: [NSAttributedString.Key.font:symbolFont,NSAttributedString.Key.foregroundColor:self.textColor!])

        let newPrice = price >= 0 ? price : -price

        if newPrice % 100 == 0 && ignoreDecimal == true {
            attriStr.append(NSAttributedString.init(string: "\(newPrice/100)", attributes: [NSAttributedString.Key.font:self.originalFont,NSAttributedString.Key.foregroundColor:self.textColor!]))
        } else {
            let originalText = String(format: "%.2f", CGFloat(newPrice)/100)
            attriStr.append(NSAttributedString.init(string: originalText, attributes: [NSAttributedString.Key.font:self.originalFont,NSAttributedString.Key.foregroundColor:self.textColor!]))
            if showSmallDecimal {
                let pointRange:NSRange = (attriStr.string as NSString).range(of: ".")
                attriStr.addAttributes([NSAttributedString.Key.font:newFont], range: NSRange.init(location: pointRange.location, length: attriStr.string.count - pointRange.location))
            }
        }
        return attriStr
    }

    ///原始字体
    private var originalFont:UIFont {
        get {
            if let font = objc_getAssociatedObject(self, &DynamicPriceLabelKeys.originalFontKey) as? UIFont {
                return font
            }
            let currentFont = self.font
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.originalFontKey, currentFont!, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return font!
        }
        set {
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.originalFontKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    ///隐藏小数点 在.00状态下 default false
    var ignoreDecimal:Bool {
        get {
            if let ignore = objc_getAssociatedObject(self, &DynamicPriceLabelKeys.ignoreDecimalKey) as? Bool {
                return ignore
            }
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.ignoreDecimalKey, false, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return false
        }
        set {
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.ignoreDecimalKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    ///显示缩略小数点 在.00状态下 default false
    var showSmallDecimal:Bool {
        get {
            if let ignore = objc_getAssociatedObject(self, &DynamicPriceLabelKeys.showSmallDecimalKey) as? Bool {
                return ignore
            }
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.showSmallDecimalKey, false, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return false
        }
        set {
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.showSmallDecimalKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

    ///显示缩略符号 ¥ default false
    var showSmallSymbol:Bool {
        get {
            if let ignore = objc_getAssociatedObject(self, &DynamicPriceLabelKeys.showSmallSymbolKey) as? Bool {
                return ignore
            }
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.showSmallSymbolKey, false, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            return false
        }
        set {
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.showSmallSymbolKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }


    ///价格
    var price:Int? {
        get {
            return objc_getAssociatedObject(self, &DynamicPriceLabelKeys.labelPriceKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &DynamicPriceLabelKeys.labelPriceKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            self.attributedText = self.analysisPriceText(newValue ?? 0)
        }
    }

}

//MARK: MenuItemLabel
extension UILabel {
    
    private struct MenuItemLabelKeys {
        static var menuCopyItemLabelKey:String? = "menuCopyItemLabelKey"
        static var copyDirectLabelKey:String? = "copyDirectLabelKey"
        
        static var touchActionLabelKey:String? = "touchActionLabelKey"
        static var touchActionEnableKey:String? = "touchActionEnableKey"
    }

    var menuCopyEnable:Bool {
        get {
            return objc_getAssociatedObject(self, &MenuItemLabelKeys.menuCopyItemLabelKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &MenuItemLabelKeys.menuCopyItemLabelKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if newValue {
                
                self.isUserInteractionEnabled = true
                
                var canAddRecognizer = true
                if self.gestureRecognizers != nil && self.gestureRecognizers!.count > 0 {
                    for ges in self.gestureRecognizers! {
                        if ges.isKind(of: UILongPressGestureRecognizer.self) {
                            canAddRecognizer = false
                            break
                        }
                    }
                }
                
                if canAddRecognizer {
                    let longPresG = UILongPressGestureRecognizer()
                    longPresG.rx.event.take(until: self.rx.deallocated).subscribe(onNext:{[weak self]  _ in
                        self?.addMenuItemCopyEvent()
                    }).disposed(by: disposeBag)
                    addGestureRecognizer(longPresG)
                }
            }
        }
    }
    
    private final func addMenuItemCopyEvent() {
        self.becomeFirstResponder()
        let menuController = UIMenuController.shared
        if menuController.isMenuVisible {
            return
        }
        if #available(iOS 13.0, *) {
            menuController.showMenu(from: self, rect: self.bounds)
        } else {
            menuController.setTargetRect(self.bounds, in: self)
            menuController.setMenuVisible(true, animated: true)
        }
    }
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        }
        return false
    }
    
    open override func copy(_ sender: Any?) {
        UIPasteboard.general.string = self.text
        HUDManager.default().showHint("复制成功", 1, nil)
    }
    
    var attachmentText:String? {
        get {
            return text
        }
        set {
            touchCopyEnable = true
            let str = newValue ?? ""
            let attri = NSMutableAttributedString.init(string: str, attributes: [NSAttributedString.Key.font:font!,NSAttributedString.Key.foregroundColor:textColor!])
            let attach = NSTextAttachment()
            let img = kImage("order_copy")
            attach.image = img
            attach.bounds = kRect(x: 0, y: -(font.lineHeight - font.pointSize)/2 - 1, w: img!.size.width - 1, h: img!.size.height - 1 , convert: false)
            attri.insert(NSAttributedString.init(attachment: attach), at: str.count)
            attributedText = attri
        }
    }
    
    var touchCopyEnable:Bool {
        get {
            return objc_getAssociatedObject(self, &MenuItemLabelKeys.copyDirectLabelKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &MenuItemLabelKeys.copyDirectLabelKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if newValue {
                
                self.isUserInteractionEnabled = true
                
                var canAddRecognizer = true
                if self.gestureRecognizers != nil && self.gestureRecognizers!.count > 0 {
                    for ges in self.gestureRecognizers! {
                        if ges.isKind(of: UITapGestureRecognizer.self) {
                            canAddRecognizer = false
                            break
                        }
                    }
                }
                
                if canAddRecognizer {
                    let tapG = UITapGestureRecognizer()
                    tapG.rx.event.take(until: self.rx.deallocated).subscribe(onNext:{[weak self]  _ in
                        self?.copy(nil)
                    }).disposed(by: disposeBag)
                    addGestureRecognizer(tapG)
                }
            }
        }
    }
    
    final func addAttachment(text:String?, image:UIImage?,action: (()->Void)? = nil) {
        let str = text ?? ""
        let attri = NSMutableAttributedString.init(string: str, attributes: [NSAttributedString.Key.font:font!,NSAttributedString.Key.foregroundColor:textColor!])
        let attach = NSTextAttachment()
        if let img = image {
            attach.image = img
            //计算图片大小，与文字同高，按比例设置宽度
            let imgH:CGFloat = font.pointSize;
            let imgW:CGFloat = (img.size.width / img.size.height) * imgH;
            //计算文字padding-top ，使图片垂直居中
            let textPaddingTop:CGFloat = (font.lineHeight - font.pointSize) / 2;
            attach.bounds = CGRect(x: 0, y: -textPaddingTop , width: imgW, height: imgH);
            attri.insert(NSAttributedString.init(attachment: attach), at: str.count)
        }
        attributedText = attri
  
        addEvent {
            action?()
        }
    }
    
    
}

//MARK: Custom Download Font
extension UILabel {
    
    func custom(fontName:String,size:CGFloat) {
        if UIFont.fontExists(name: fontName,size: size) {
            isHidden = false
            self.font = kFont(fontName, size, false)
        } else {
            if UIFont.downloadableFontNames().contains(fontName) {
                UIFont.downloadFontWithName(name: fontName, size: size, progress: { downloadedSize, totalSize, percentage in
                    HLog("downloadedSize:\(downloadedSize)\ntotalSize:\(totalSize)\npercentage:\(percentage)")
                }) { [weak self] targetFont in
                    self?.isHidden = false
                    self?.font = targetFont
                }
            } else {
                isHidden = false
                self.font = UIFont.systemFont(ofSize: size)
            }
        }

    }
}
