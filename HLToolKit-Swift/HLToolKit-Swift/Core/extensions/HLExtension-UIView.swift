//
//  HLExtension-UIView.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import UIKit
import CoreGraphics
import Aspects

private var TapHandlerKey: Void?


public extension UIView {
    
    var CG_width:CGFloat {
        get {
            return self.bounds.size.width
        }
    }
    
    var CG_height:CGFloat {
        get {
            return self.bounds.size.height
        }
    }
    
    var CG_size:CGSize {
        get {
            return self.bounds.size
        }
    }
    
    var CG_left:CGFloat {
        get {
            return self.frame.origin.x;
        }
    }
    
    var CG_right:CGFloat {
        get {
            return self.frame.maxX
        }
    }
    
    var CG_top:CGFloat {
        get {
            return self.frame.origin.y;
        }
    }
    
    var CG_bottom:CGFloat {
        get {
            return self.frame.maxY
        }
    }
    
    var CG_centerX:CGFloat {
        get {
            return self.CG_left + self.CG_width/2;
        }
    }
    
    var CG_centerY:CGFloat {
        get {
            return self.CG_top + self.CG_height/2;
        }
    }
    
    var CG_boundsCenter:CGPoint {
        get {
            return CGPoint(x: self.bounds.origin.x + self.CG_width/2, y: self.bounds.origin.y + self.CG_height/2)
        }
    }
    
    
    private struct AssociatedKeys {
        static var forceRoundCornerKey: Void?
        static var rectCornerKey: Void?
        static var rectCornerRadiusKey: Void?
        static var hitAreaKey: Void?
        static var layoutSubviewsKey: Void?
        static var enlargeHitAreaKey: Void?
    }
    
    var forceRoundCorner:Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.forceRoundCornerKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.forceRoundCornerKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            let block: @convention(block) (AnyObject?) -> Void = {
                info in
                let aspectInfo = info as! AspectInfo
                let thisView:UIView = aspectInfo.instance() as! UIView
                thisView.layer.cornerRadius = CGFloat(ceilf(Float(thisView.bounds.height/2.0)))
                thisView.layer.masksToBounds = true
            }
            let wrappedObject: AnyObject = unsafeBitCast(block, to: AnyObject.self)
            var aspectToken:AspectToken? = objc_getAssociatedObject(self, &AssociatedKeys.layoutSubviewsKey) as? AspectToken
            if newValue && aspectToken == nil {
                do {
                    try aspectToken = self.aspect_hook(#selector(layoutSubviews), with: .positionInstead, usingBlock: wrappedObject)
                } catch {
                    print("Error = \(error)")
                }
                objc_setAssociatedObject(self, &AssociatedKeys.layoutSubviewsKey, aspectToken, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else if !newValue {
                aspectToken!.remove()
                objc_setAssociatedObject(self, &AssociatedKeys.layoutSubviewsKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            self.setNeedsLayout()
        }
    }
    
    var rectCornerRadius:CGFloat {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rectCornerRadiusKey) as! CGFloat
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.rectCornerRadiusKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var rectCorner:UIRectCorner {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rectCornerKey) as? UIRectCorner ?? UIRectCorner.topLeft
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.rectCornerKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            let block: @convention(block) (AnyObject?) -> Void = { info in
                let aspectInfo = info as! AspectInfo
                let thisView:UIView = aspectInfo.instance() as! UIView
                let maskPath:UIBezierPath = UIBezierPath.init(roundedRect: thisView.bounds, byRoundingCorners: newValue, cornerRadii: CGSize.init(width: thisView.rectCornerRadius, height: thisView.rectCornerRadius))
                let layer:CAShapeLayer = CAShapeLayer()
                layer.frame = maskPath.bounds
                layer.path = maskPath.cgPath
                thisView.layer.mask = layer
            }
            let warppedObject:AnyObject = unsafeBitCast(block, to: AnyObject.self)
            var aspectToken:AspectToken? = objc_getAssociatedObject(self, &AssociatedKeys.layoutSubviewsKey) as? AspectToken
            
            if aspectToken == nil {
                do {
                    try aspectToken = self.aspect_hook(#selector(layoutSubviews), with:AspectOptions(rawValue: 0     << 0), usingBlock: warppedObject)
                } catch {
                    print("Error = \(error)")
                }
                objc_setAssociatedObject(self, &AssociatedKeys.layoutSubviewsKey, aspectToken, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                aspectToken!.remove()
                objc_setAssociatedObject(self, &AssociatedKeys.layoutSubviewsKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            self.setNeedsLayout()
        }
    }
    //    MARK: PointArea
    var enlargeHitArea:UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.hitAreaKey) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.hitAreaKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitFrame = relativeFrame.inset(by: self.enlargeHitArea)
        return hitFrame.contains(point)
    }
    
    typealias TapHandler = () ->Void
    
    var handler:TapHandler? {
        get {
            return objc_getAssociatedObject(self, &TapHandlerKey) as? TapHandler
        }
        set {
            objc_setAssociatedObject(self, &TapHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    //    MARK: UITapGestureRecognizer
    /// add tap UIGestureRecognizer
    @objc func addEvent(_ handler:@escaping TapHandler) {
        assert(self.isUserInteractionEnabled, "This view:\(self) isUserInteractionEnabled = false")
        
        self.handler = handler
        
        if self.gestureRecognizers != nil && self.gestureRecognizers!.count > 0 {
            for ges in self.gestureRecognizers! {
                self.removeGestureRecognizer(ges)
            }
        }
        
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(viewTapAction))
        self.addGestureRecognizer(tapGes)
    }
    
    @objc func viewTapAction() {
        if self.handler != nil {
            self.handler!()
        }
    }
}
