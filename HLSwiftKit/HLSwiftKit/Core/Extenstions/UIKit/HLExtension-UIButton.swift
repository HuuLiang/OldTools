//
//  HLExtension-UIButton.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//



//MARK: 图片文字位置
public extension UIButton {
    ///图片位置
    @objc enum HLButtonEdgeInsetsStyle:Int {
        ///图片 上
        case top
        ///图片 左
        case left
        ///图片 下
        case bottom
        ///图片 右
        case right
    }
    
    @objc final func layoutButton(_ insetsStyle:HLButtonEdgeInsetsStyle,_ imageTitleSpace:CGFloat) -> Void {
        let imageRect: CGRect = self.imageView?.frame ?? CGRect.init()
        let titleRect: CGRect = self.titleLabel?.frame ?? CGRect.init()
        let selfWidth: CGFloat = self.frame.size.width
        let selfHeight: CGFloat = self.frame.size.height
        let totalHeight = titleRect.size.height + imageTitleSpace + imageRect.size.height
        switch insetsStyle {
        case .left:
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTitleSpace / 2, bottom: 0, right: -imageTitleSpace / 2)
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTitleSpace / 2, bottom: 0, right: imageTitleSpace / 2)
        case .right:
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageRect.size.width + imageTitleSpace/2), bottom: 0, right: (imageRect.size.width + imageTitleSpace/2))
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: (titleRect.size.width + imageTitleSpace / 2), bottom: 0, right: -(titleRect.size.width +  imageTitleSpace/2))
        case .top :
            self.titleEdgeInsets = UIEdgeInsets(top: ((selfHeight - totalHeight) / 2 + imageRect.size.height + imageTitleSpace - titleRect.origin.y), left: (selfWidth / 2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2, bottom: -((selfHeight - totalHeight) / 2 + imageRect.size.height + imageTitleSpace - titleRect.origin.y), right: -(selfWidth / 2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2)
            self.imageEdgeInsets = UIEdgeInsets(top: ((selfHeight - totalHeight) / 2 - imageRect.origin.y), left: (selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2), bottom: -((selfHeight - totalHeight) / 2 - imageRect.origin.y), right: -(selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2))
        case .bottom:
            self.titleEdgeInsets = UIEdgeInsets(top: ((selfHeight - totalHeight) / 2 - titleRect.origin.y), left: (selfWidth / 2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2, bottom: -((selfHeight - totalHeight) / 2 - titleRect.origin.y), right: -(selfWidth/2 - titleRect.origin.x - titleRect.size.width / 2) - (selfWidth - titleRect.size.width) / 2)
            self.imageEdgeInsets = UIEdgeInsets(top: ((selfHeight - totalHeight) / 2 + titleRect.size.height + imageTitleSpace - imageRect.origin.y), left: (selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2), bottom: -((selfHeight - totalHeight) / 2 + titleRect.size.height + imageTitleSpace - imageRect.origin.y), right: -(selfWidth / 2 - imageRect.origin.x - imageRect.size.width / 2))
        default:
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    
}

///防止多次点击
import Aspects
extension UIButton {
    
    private struct CSButtonKeys {
        static var clickTimeIntervalKey = "button_clickTimeInterval"
        
        static var sendActionKey        = "button_sendAction"
    }
    
    var clickTimeInterval:Double {
        set {
            objc_setAssociatedObject(self, &CSButtonKeys.clickTimeIntervalKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            let block:@convention(block) (AnyObject?) -> Void = { info in
                self.clickIntervalAction()
            }
            let wrappedObject: AnyObject = unsafeBitCast(block, to: AnyObject.self)
            var aspectToken:AspectToken? = objc_getAssociatedObject(self, &CSButtonKeys.sendActionKey) as? AspectToken
            if aspectToken == nil {
                do {
                    try aspectToken = self.aspect_hook(#selector(sendAction(_:to:for:)), with: [.positionBefore], usingBlock: wrappedObject)
                } catch {
                    HLog("Error = \(error)")
                }
                objc_setAssociatedObject(self, &CSButtonKeys.sendActionKey, aspectToken, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        get {
            objc_getAssociatedObject(self, &CSButtonKeys.clickTimeIntervalKey) as? Double ?? 0
        }
    }
    
    @objc private final func clickIntervalAction() {
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + clickTimeInterval,
                                      qos: .userInteractive) {  [weak self] in
            guard self != nil else {return}
            self!.isUserInteractionEnabled = true
        }
    }
}
