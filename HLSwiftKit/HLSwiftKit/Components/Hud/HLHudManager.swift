//
//  HLHudManager.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/20.
//  Copyright © 2019 Liang. All rights reserved.
//

public class HUDManager {
    
    private static var manager:HUDManager = {
        let mana = HUDManager.init()
        
        PKHUD.sharedHUD.dimsBackground = true
        PKHUD.sharedHUD.userInteractionOnUnderlyingViewsEnabled = false
        PKHUD.sharedHUD.registerForKeyboardNotifications()
        
        return mana
    }()
    
    private init() {}
    
    static func `default`() -> HUDManager {
        return manager
    }
}

//MARK: SDK-HUD
extension HUDManager {
    public final func showMsg(_ message:String) {
        HUD.flash(.label(message), delay: 1)
    }
    
    public final func showErr(_ title:String?, _ message:String?) {
        HUD.flash(.labeledError(title: title, subtitle: message), delay: 1)
    }
    
    public final func showSuc(_ title:String?, _ message:String?) {
        HUD.flash(.labeledSuccess(title: title, subtitle: message), delay: 1)
    }
    
    public final func showSuc(_ title:String?, _ message:String?, _ completion:( () -> Void )? ) {
        HUD.flash(.labeledSuccess(title: title, subtitle: message), onView: nil, delay: 1) { (_) in
            completion?()
        }
    }
    
    public final func showProgress(_ title:String?, _ message:String?) {
        HUD.flash(.labeledProgress(title: title, subtitle: message), delay: 1)
    }
    
    public final func showProgress(_ gracePeriod:Double,_ title:String?, _ message:String?) {
        PKHUD.sharedHUD.gracePeriod = gracePeriod
        HUD.flash(.labeledProgress(title: title, subtitle: message))
    }
    
    public final func beginLoading(delay:Double = 0,message:String = "") {
        beginLoading(delay: delay, message: message, hide: 0, completion: nil)
    }
    
    public final func beginLoading(delay:Double = 0.5,message:String = "",hide:Double = 0,completion:((Bool)->Void)?) {
        PKHUD.sharedHUD.gracePeriod = delay
        HUD.show(.labeledProgress(title: nil, subtitle: message))
        if hide > 0 {
            HUD.hide(afterDelay: hide, completion: completion)
        }
    }

    
    
    public final func endLoading() {
        PKHUD.sharedHUD.gracePeriod = 0
        HUD.hide()
    }
    
    public final func hide() {
        HUD.hide()
    }
}

//MARK: CustomView
extension HUDManager {
    
    public final func showErr(_ message:String?) {
        HUD.flash(.customView(view: HUDCustomView.error(message)), delay:1)
    }
    
    public final func showWarning(_ message:String?) {
        HUD.flash(.customView(view: HUDCustomView.notice(message)), delay: 1)
    }
    
    public final func showSuccess(_ message:String?) {
        showSuccess(message, nil)
    }
    
    public final func showSuccess(_ message:String?, _ completion:(() -> Void)? ) {
        HUD.flash(.customView(view: HUDCustomView.success(message)), onView: nil, delay: 1) { (_) in
            completion?()
        }
    }
    
    public final func showHint(_ message:String?) {
        showHint(message, 1.5, nil)
    }
    
    public final func showHint(_ message:String?, _ completion:(()->Void)? = nil) {
        showHint(message, 1.5, completion)
    }
    
    public final func showHint(_ message:String?,_ delay:CGFloat, _ completion:(()->Void)? = nil) {
        guard Thread.isMainThread,
              message?.isEmpty == false else {
            return
        }
        endLoading()
        HUD.flash(.customView(view: HUDCustomView.hint(message)), onView: nil, delay: TimeInterval(delay)) { (_) in
            completion?()
        }
    }
    
    public final func showCustomView(_ customView:UIView) {
        endLoading()
        HUD.show(.customView(view: customView))
    }

    public final func showCustomView(_ customView:UIView, on view:UIView) {
        endLoading()
        HUD.show(.customView(view: customView), onView: view)
    }

    public final func showCustomView(_ customView:UIView,delay:CGFloat) {
        endLoading()
        HUD.flash(.customView(view: customView), delay: TimeInterval(delay))
    }

}

