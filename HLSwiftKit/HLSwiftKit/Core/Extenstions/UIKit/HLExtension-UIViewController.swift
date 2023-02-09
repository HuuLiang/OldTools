//
//  HLExtension-UIViewController.swift
//  CloudStore
//
//  Created by Liang on 2020/9/11.
//  Copyright © 2020 HangZhouMYQ. All rights reserved.
//

// MARK:Common
extension UIViewController {
    
    /// 导航进入指定页面
    /// - Parameters:
    ///   - targetViewController: 指定控制器
    ///   - animated: 是否动画效果
    ///   - ignoreSelf: 是否在栈中隐藏自己
    final func pushInto(_ targetViewController:UIViewController, animated:Bool = true, ignoreSelf:Bool = false) {
        pushInto(targetViewControllers: [targetViewController], animated: animated, ignoreSelf: ignoreSelf)
    }
    
    /// 导航进入指定页面
    /// - Parameters:
    ///   - targetViewControllers: 指定控制器组
    ///   - animated: 是否动画效果
    ///   - ignoreSelf: 是否在栈中隐藏自己
    final func pushInto(targetViewControllers:[UIViewController], animated:Bool = true, ignoreSelf:Bool = false) {
        guard let navigationController = self.navigationController else {
            return
        }
        if (navigationController.viewControllers.count == 1 && targetViewControllers.count == 1)
            || (targetViewControllers.count == 1 && !ignoreSelf) {
            navigationController.pushViewController(targetViewControllers.first!, animated: animated)
            return
        }
        var newVCs:[UIViewController] = []
        if navigationController.viewControllers.count == 1 || !ignoreSelf {
            newVCs.append(contentsOf: navigationController.viewControllers)
        } else {
            newVCs.append(contentsOf: navigationController.viewControllers.filter({!$0.isEqual(self)}))
        }
        newVCs.append(contentsOf: targetViewControllers)
        navigationController.setViewControllers(newVCs, animated: animated)
    }

    
    /// 跳转到指定视图控制器
    /// - Parameters:
    ///   - targetController: 目前控制器
    ///   - ignoreList: 隐藏的栈控制器列表
    ///   - animated: 动画
    final func skipTo(targetController:UIViewController,ignoreList:[UIViewController.Type],animated:Bool = true) {
        guard let viewControllers = navigationController?.viewControllers,
                !viewControllers.isEmpty else {
            return
        }
        
        if viewControllers.count == 1 {
            navigationController?.pushViewController(targetController, animated: animated)
            return
        }
        
        var newVCs:[UIViewController] = []
        for idx in 0..<viewControllers.count {
            if ignoreList.contains(where: {viewControllers[idx].isKind(of: $0.self)}) && idx != 0 {
                continue
            }
            newVCs.append(viewControllers[idx])
        }
        newVCs.append(targetController)
        navigationController?.setViewControllers(newVCs, animated: animated)
    }
    
    
    /// 返回前一个页面
    /// - Parameter animated: 是否动画效果
    final func popToForward(animated:Bool = true) {
        var findTargetViewController:UIViewController? = nil
        if let viewControllers = self.navigationController?.viewControllers {
            var readyToFind = false
            for tempVC in viewControllers.reversed() {
                if readyToFind {
                    findTargetViewController = tempVC
                    break
                }
                if tempVC == self {
                    readyToFind = true
                }
            }
        }
        if findTargetViewController != nil {
            self.navigationController?.popToViewController(findTargetViewController!, animated: animated)
        }
    }
    
    
    /// 设置返回按钮
//    final func setBackButtonItem() {
//        let backItem = UIBarButtonItem.init(image: kImage("back_navi"), style: .plain, target: nil, action: nil)
//        navigationItem.backBarButtonItem = backItem
//    }
}


//MARK: Popup
extension UIViewController {
    
    ///视图弹出流程场景
    enum PopupActionType:Equatable {
        ///即将显示
        case willShow
        ///已经显示
        case endShow
        
        ///显示背景阴影
        case showShadow
        ///阴影点击事件
        case shadowEvent
        
        ///即将消失
        case willHide
        ///已经消失
        case endHide
    }
    
    struct PopupControllerKeys {
        static var shadowViewKey:String             = "popupController_shadowView"
        static var heightKey:String                 = "popupController_height"
        static var superViewControllerKey:String    = "popupController_superViewController"
        static var superViewKey:String              = "popupController_superView"
        static var actionTypeKey:String             = "popupController_actionType"
        static var actionHandlerKey:String          = "popupController_actionHandler"
        static var isPopingKey:String               = "popupController_isPoping"
    }

    typealias PopupActionHandler = (PopupActionType) -> Bool
    
    static let DefaultActionHandler:PopupActionHandler = { popupAction -> Bool in
        return true
    }
    
    final func showIn(viewController:UIViewController? = nil,
                      height:CGFloat,
                      popupActions:[PopupActionType] = [],
                      completion:@escaping PopupActionHandler = DefaultActionHandler) {
        if viewController != nil {
            superVC = viewController
            superView = viewController!.view
        } else {
            superVC = UIApplication.shared.delegate?.window??.rootViewController
            superView = superVC?.view
        }
        
        if superVC?.isPoping == true {
            return
        }
        superVC?.isPoping = true
        
        if popupActions.isEmpty {
            self.popupActions.append(contentsOf: [.willShow,.endShow,.showShadow,.shadowEvent,.willHide,.endHide])
        } else {
            self.popupActions.append(contentsOf: popupActions)
        }
        
        self.popupActionHandler = completion
        
        self.height = height
        
        if self.popupActions.contains(.willShow) {
            if self.popupActionHandler(.willShow) == false {
                return
            }
        }
        
        showAnimation { [weak self] in
            if self?.popupActions.contains(.endShow) == true {
                _ = self?.popupActionHandler(.endShow)
            }
        }
    }
    
    final func hide() {
        if self.view.superview == nil {
            return
        }
        
        if self.popupActions.contains(.willHide) {
            if self.popupActionHandler(.willHide) == false {
                return
            }
        }
        
        hideAnimation { [weak self] in
            if self?.popupActions.contains(.endHide) == true {
                _ = self?.popupActionHandler(.endHide)
            }
        }
    }
    
    final func updatePosition(_ point:CGPoint) {
        self.view.setNeedsUpdateConstraints()
        if self.superView != nil {
            self.view.snp.remakeConstraints({ (make) in
                make.left.right.equalTo(superView!)
                make.height.equalTo(self.height!)
                make.bottom.equalToSuperview().offset(point.y)
            })
            
            UIView.animate(withDuration: 0.5, animations: {
                self.superView!.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    private final func showAnimation(_ completion:@escaping ()->Void) {
        var anyView = false
        for obj in superVC?.children ?? [] {
            if obj.isEqual(self) {
                anyView = true
                break
            }
        }
        
        if anyView { return }
        
        if superView!.subviews.contains(self.view) { return }
        
        superVC!.addChild(self)
        self.view.frame = CGRect.init(x: 0, y: kScreenHeight, width: kScreenWidth, height: self.height!)
        
        if self.shadowView != nil {
            superView!.addSubview(self.shadowView!)
            superView?.bringSubviewToFront(self.shadowView!)
            superView?.insertSubview(self.view, aboveSubview: self.shadowView!)
        } else {
            superView!.addSubview(self.view)
            superView?.bringSubviewToFront(self.view!)
        }
        self.didMove(toParent: superVC!)
        
        self.view.setNeedsUpdateConstraints()
        superView!.layoutIfNeeded()
        self.view.snp.remakeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(self.height!)
            make.bottom.equalTo(superView!.snp.bottom).offset(0)
        })
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.shadowView?.isHidden = false
            self.shadowView?.alpha = 1.0
            self.superView!.layoutIfNeeded()
        }) { (success) in
            completion()
        }
    }
    
    private final func hideAnimation(_ completion:@escaping ()->Void) {
        
        self.view.setNeedsUpdateConstraints()
        superView?.layoutIfNeeded()
        self.view.snp.remakeConstraints({ (make) in
            make.left.right.equalTo(superView!)
            make.height.equalTo(self.height!)
            make.top.equalTo(superView!.snp.bottom).offset(50)
        })
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.shadowView?.alpha = 0.0
            self.superView!.layoutIfNeeded()
        }) { (finished) in
            self.superVC?.isPoping = false
            self.shadowView?.removeFromSuperview()
            self.shadowView = nil
            
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            self.superVC = nil
            self.superView = nil
            completion()
        }
    }
    
    private(set) var shadowView:UIView? {
        get {
            if self.popupActions.contains(.showShadow) && self.popupActionHandler(.showShadow) == true {
                var view = objc_getAssociatedObject(self, &PopupControllerKeys.shadowViewKey) as? UIView
                if view == nil {
                    view = UIView()
                    view!.backgroundColor = kColor("000000",0.45)
                    view!.backgroundColor = kColor("000000", 0.45)
                    view!.alpha = 0
                    view!.isHidden = true
                    view!.frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
                    if self.popupActions.contains(.shadowEvent) {
                        if self.popupActionHandler(.shadowEvent) == true {
                            view?.addEvent({ [weak self] in
                                self?.hide()
                            })
                        }
                    }
                    objc_setAssociatedObject(self, &PopupControllerKeys.shadowViewKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                }
                return view
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &PopupControllerKeys.shadowViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var superVC:UIViewController? {
        get {
            return objc_getAssociatedObject(self, &PopupControllerKeys.superViewControllerKey) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &PopupControllerKeys.superViewControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var superView:UIView? {
        get {
            return objc_getAssociatedObject(self, &PopupControllerKeys.superViewKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &PopupControllerKeys.superViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var height:CGFloat? {
        get {
            return objc_getAssociatedObject(self, &PopupControllerKeys.heightKey) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &PopupControllerKeys.heightKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var popupActions:[PopupActionType] {
        get {
            return objc_getAssociatedObject(self, &PopupControllerKeys.actionTypeKey) as? [PopupActionType] ?? []
        }
        set {
            objc_setAssociatedObject(self, &PopupControllerKeys.actionTypeKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var popupActionHandler:PopupActionHandler {
        get {
            return objc_getAssociatedObject(self, &PopupControllerKeys.actionHandlerKey) as? PopupActionHandler ?? UIViewController.DefaultActionHandler
        }
        set {
            objc_setAssociatedObject(self, &PopupControllerKeys.actionHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private(set) var isPoping:Bool! {
        get {
            return objc_getAssociatedObject(self, &PopupControllerKeys.isPopingKey) as? Bool ?? false
        }
        set {
//            if newValue {
//                (self as? CSBaseController)?.allowGestureRecognizer = false
//            } else {
//                (self as? CSBaseController)?.allowGestureRecognizer = true
//            }
            objc_setAssociatedObject(self, &PopupControllerKeys.isPopingKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }

}
