//
//  HLExtension-pop.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import pop

public extension NSObject {
    
    private struct AnimationKeys {
        static var kHLBasicAnimationKey:String? = "kHLBasicAnimationKey"
        static var kHLBasicBlockAnimationKey:String? = "kHLBasicBlockAnimationKey"
        static var kHLSpringAnimationKey:String? = "kHLSpringAnimationKey"
    }

    @objc func hl_basicAnimation(_ fromValue:Any, _ toValue:Any, _ duration:Double, _ key:String) {
        self.hl_basicAnimation(fromValue, toValue, 0, duration, key)
    }
    
    @objc func hl_basicAnimation(_ fromValue:Any, _ toValue:Any, _ beginTime:Double, _ duration:Double, _ key:String) -> Void {
        let basicAnimation = POPBasicAnimation.init(propertyNamed: key)
        basicAnimation?.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
        basicAnimation?.beginTime = beginTime
        basicAnimation?.duration = duration
        basicAnimation?.fromValue = fromValue
        basicAnimation?.toValue = toValue
        self.pop_add(basicAnimation, forKey: AnimationKeys.kHLBasicAnimationKey)
    }

    func hl_basicAnimation(_ fromValue:Any, _ toValue:Any, _ duration:Double, _ animationBlock:@escaping (_ prop:POPMutableAnimatableProperty?) -> Void ) {
        let basicAnimation = POPBasicAnimation.linear()
        basicAnimation?.property = POPAnimatableProperty.property(withName: AnimationKeys.kHLBasicBlockAnimationKey, initializer: animationBlock ) as? POPAnimatableProperty
        basicAnimation?.beginTime = 0
        basicAnimation?.duration = duration
        basicAnimation?.fromValue = fromValue
        basicAnimation?.toValue = toValue
        self.pop_add(basicAnimation, forKey: AnimationKeys.kHLBasicBlockAnimationKey)
    }
    
    @objc func hl_springAnimation(_ fromValue:Any, _ toValue:Any, _ key:String) {
        self.hl_springAnimation(fromValue, toValue, 0, key)
    }
    
    @objc func hl_springAnimation(_ fromValue:Any, _ toValue:Any, _ beginTime:Double, _ key:String) {
        let springAnimation = POPSpringAnimation.init(propertyNamed: key)
        springAnimation?.beginTime = beginTime
        springAnimation?.springBounciness = 16
        springAnimation?.springSpeed = 6
        springAnimation?.fromValue = fromValue
        springAnimation?.toValue = toValue
        self.pop_add(springAnimation, forKey: AnimationKeys.kHLSpringAnimationKey)
    }
    
    @objc func hl_springAnimationWithNoFriction(_ fromValue:Any, _ toValue:Any, _ key:String) {
        let springAnimation = POPSpringAnimation.init(propertyNamed: key)
        springAnimation?.beginTime = 0.3
        springAnimation?.fromValue = fromValue
        springAnimation?.toValue = toValue
        springAnimation?.springSpeed = 12.0
        springAnimation?.springBounciness = 4.0
        springAnimation?.dynamicsMass = 1.0
        springAnimation?.dynamicsFriction = 0.0
        springAnimation?.dynamicsTension = 15.0
        self.pop_add(springAnimation, forKey: AnimationKeys.kHLSpringAnimationKey)
    }

}
