//
//  HLExtension-UIView.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

//import Aspects

public extension UIView {
    
    private struct AssociatedKeys {
        static var enlargeHitAreaKey: Void?
        static var tapHandlerKey: Void?
    }
    
    //    MARK: PointArea
    var enlargeHitArea:UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.enlargeHitAreaKey) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.enlargeHitAreaKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    
    private final func _point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let relativeFrame = self.bounds
        let hitFrame = relativeFrame.inset(by: enlargeHitArea)
        return hitFrame.contains(point)
    }
    
    final func custom(hitTest point: CGPoint, with event: UIEvent?) -> Bool {
        guard superview != nil else {
            return false
        }
        let p:CGPoint = convert(point, from: superview!)
        return _point(inside: p, with: event)
    }
        
    //    MARK: UITapGestureRecognizer
    ///    add tap UIGestureRecognizer
    @objc func addEvent(_ handler:(() -> Void)? ) {
        if self.isUserInteractionEnabled == false {
            return
        }
        if self.gestureRecognizers != nil && self.gestureRecognizers!.count > 0 {
            for ges in self.gestureRecognizers! {
                self.removeGestureRecognizer(ges)
            }
        }
        
        let tapG = UITapGestureRecognizer()
        self.addGestureRecognizer(tapG)

        tapG.rx.event.take(until: self.rx.deallocated).subscribe(onNext:{ _ in
            handler?()
        }).disposed(by: disposeBag)
    }
    
}

//MARK: Animation
extension UIView {

    /// SwifterSwift: 摇动视图的方向
    ///
    /// - horizontal: 水平
    /// - vertical: 垂直
    /// - rotation:旋转
    public enum ShakeDirection {
        case horizontal
        case vertical
        case rotation
    }
    /// SwifterSwift: 摇动动画类型
    ///
    /// - linear: 线性动画
    /// - easeIn: 缓入动画
    /// - easeOut: 缓出动画
    /// - easeInOut: 缓入缓出动画
    public enum ShakeAnimationType {
        case linear
        case easeIn
        case easeOut
        case easeInOut
    }
    /// SwifterSwift: 摇动视图.
    ///
    /// - Parameters:
    ///   - direction: 摇动方向（水平或垂直），（默认为 .horizontal）
    ///   - duration: 以秒为单位的动画持续时间（默认为 1 秒）。
    ///   - animationType: 摇动动画类型（默认为 .easeOut）。
    ///   - completion: 在动画完成时运行的可选完成处理程序（默认值为 nil）。
    public func shake(direction: ShakeDirection = .horizontal,
                      duration: TimeInterval = 1,
                      animationType: ShakeAnimationType = .easeOut,
                      values:[Any] = [],
                      completion:(() -> Void)? = nil) {
        CATransaction.begin()
        let animation: CAKeyframeAnimation
        switch direction {
        case .horizontal:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        case .vertical:
            animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        case .rotation:
            animation = CAKeyframeAnimation(keyPath: "transform.rotation")
        }
        switch animationType {
        case .linear:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        case .easeIn:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        case .easeOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        case .easeInOut:
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        }
        CATransaction.setCompletionBlock(completion)
        animation.duration = duration
        if values.isEmpty {
            switch direction {
            case .horizontal:
                animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
            case .vertical:
                animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
            case .rotation:
                animation.values = [-Double.pi/12, Double.pi/12,-Double.pi/12,0]
            }
        } else {
            animation.values = values
        }
        layer.add(animation, forKey: "shake")
        CATransaction.commit()
    }
}
//MARK: TableviewSectionHeader
extension UIView {
        
    static func tableSectionView() -> UIView {
        let view = UIView()
        view.backgroundColor = kColor("#f5f5f5")
        return view
    }
    
}
