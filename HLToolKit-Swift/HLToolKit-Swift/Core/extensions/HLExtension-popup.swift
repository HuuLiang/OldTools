//
//  HLExtension-popup.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/14.
//  Copyright © 2019 Liang. All rights reserved.
//

import UIKit
import SnapKit

private var shadowViewKey: Void?
//private var shadowActionKey: Void?
//private var handlerActionKey: Void?
private var hideActionKey: Void?

private var heightKey: Void?
private var paramKey: Void?

extension UIViewController {
    
//    typealias ShadowAction = () -> Void
//    typealias HandlerAction = () -> Void
    typealias HideAction = (AnyObject?) -> Void
    
    var shadowView:UIView? {
        get {
            var view = objc_getAssociatedObject(self, &shadowViewKey) as? UIView
            if view == nil {
                view = UIView()
                view?.backgroundColor = kColor("000000", 0.45)
                view?.isHidden = true
                view?.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
                objc_setAssociatedObject(self, &shadowViewKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return view
        }
        set {
            objc_setAssociatedObject(self, &shadowViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
//    var shadowAction:ShadowAction? {
//        get {
//            return objc_getAssociatedObject(self, &shadowActionKey) as? ShadowAction
//        }
//        set {
//            objc_setAssociatedObject(self, &shadowActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//        }
//    }
    
//    var handler:HandlerAction? {
//        get {
//            return objc_getAssociatedObject(self, &handlerActionKey) as? HandlerAction
//        }
//        set {
//            objc_setAssociatedObject(self, &handlerActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
//            weak var weakSelf = self
//            self.shadowView?.addEvent({
//                weakSelf?.shadowAction!()
//            })
//        }
//    }
    
    var height:CGFloat? {
        get {
            return objc_getAssociatedObject(self, &heightKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &heightKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var hideAction:HideAction? {
        get {
            return objc_getAssociatedObject(self, &hideActionKey) as? HideAction
        }
        set {
            objc_setAssociatedObject(self, &hideActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            weak var weakSelf = self
            self.shadowView?.addEvent({
                weakSelf?.hideAction!(nil)
            })
        }
    }
    
    @objc static func showIn(_ viewController:UIViewController, _ height:CGFloat, _ handler:@escaping HideAction) -> Void {
        self.init().showin(viewController, height, handler)
    }
    
    @objc final func showin(_ viewController:UIViewController, _ height:CGFloat, _ handler:@escaping HideAction) -> Void {
        self.hideAction = handler
        self.height = height
        
        var anyView = false
        for obj in viewController.children {
            if obj.isEqual(self) {
                anyView = true
                break
            }
        }
        
        if anyView { return }
        
        if viewController.view.subviews.contains(self.view) { return }
        
        viewController.addChild(self)
        self.view.frame = CGRect.init(x: 0, y: kScreenHeight, width: kScreenWidth, height: self.height!)
        self.shadowView?.alpha = 0
        
        viewController.view.addSubview(self.shadowView!)
        viewController.view.addSubview(self.view)
        self.didMove(toParent: viewController)
        
        viewController.view.layoutIfNeeded()
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.shadowView?.alpha = 1.0
            self.view.snp.remakeConstraints({ (make) in
                make.left.firstBaseline.equalToSuperview()
                make.height.equalTo(self.height!)
                make.bottom.equalTo(viewController.view.snp_bottom).offset(0)
            })
        }, completion: nil)
    }
    
    
    @objc final func hide(_ param:AnyObject?) {
        if self.view.superview == nil {
            return
        }
        self.view.setNeedsUpdateConstraints()
        let superView = self.view.superview
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.shadowView?.alpha = 0.0
            self.view.snp.remakeConstraints({ (make) in
                make.left.right.equalTo(superView!)
                make.height.equalTo(self.height!)
                make.top.equalTo(superView!.snp_bottom).offset(50)
            })
            superView!.layoutIfNeeded()
        }) { (finished) in
            self.shadowView?.removeFromSuperview()
            self.shadowView = nil
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if self.hideAction != nil {
                self.hideAction!(param)
            }
        }
    }
    
    @objc final func hide() {
        self.hide(nil)
    }
    
    @objc final func updatePosition(withPoint:CGPoint) {
        let superView:UIView! = self.view.superview
        superView.layoutIfNeeded()
        self.view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.snp.remakeConstraints({ (make) in
                make.left.right.equalTo(superView)
                make.height.equalTo(self.height!)
                make.bottom.equalToSuperview()
            })
            superView.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    
}
