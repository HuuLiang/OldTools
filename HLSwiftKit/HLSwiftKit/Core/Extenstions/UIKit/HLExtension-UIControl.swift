//
//  HLExtension-UIControl.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/11.
//  Copyright © 2019 Liang. All rights reserved.
//

//import UIKit
//
//private var controlHandlersKey: Void?
//
//open class ControlWrapper: NSObject,NSCopying {
//    
//    typealias Handler = () -> Void
//    
//    var controlEvent: UIControl.Event
//    var handler:Handler
//    
//    
//    init(handler:@escaping() -> Void ,for controlEvent:UIControl.Event) {
//        self.handler = handler
//        self.controlEvent = controlEvent
//    }
//
//    public func copy(with zone: NSZone? = nil) -> Any {
//        return ControlWrapper.init(handler: self.handler, for: self.controlEvent)
//    }
//    
//    @objc public final func invoke() {
//        self.handler()
//    }
//}
//
//extension UIControl {
//    @objc final func addEvent(_ handler:@escaping () -> Void, for controlEvent:UIControl.Event) {
//        var events = objc_getAssociatedObject(self, &controlHandlersKey) as? NSMutableDictionary
//        
//        if events == nil {
//            events = NSMutableDictionary()
//        }
//        
//        if events!.count == 0 {
//            objc_setAssociatedObject(self, &controlHandlersKey, events, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        
//        let key = NSNumber.init(value: controlEvent.rawValue)
//        var handlers = events![key] as? NSMutableSet
//        if handlers == nil {
//            handlers = NSMutableSet.init()
//        }
//        if handlers!.count == 0 {
//            events![key] = handlers
//        }
//        let target:ControlWrapper = ControlWrapper.init(handler: handler, for: controlEvent)
//        handlers!.add(target)
//        self.addTarget(target, action: #selector(ControlWrapper.invoke), for: controlEvent)
//    }
//    
//    @objc final func removeEvent(for controlEvent:UIControl.Event) {
//        var events = objc_getAssociatedObject(self, &controlHandlersKey) as! NSMutableDictionary
//        if events.count == 0 {
//            events = NSMutableDictionary()
//            objc_setAssociatedObject(self, &controlHandlersKey, events, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        let key = NSNumber.init(value: controlEvent.rawValue)
//        let handlers = events[key] as! NSMutableSet
//        if handlers.count == 0 {
//            return
//        }
//        
//        for (obj) in handlers.enumerated() {
//            self.removeTarget(obj, action: nil, for: controlEvent)
//        }
//        events.removeObject(forKey: key)
//    }
//    
//    @objc final func hasEvent(for controlEvent:UIControl.Event) -> Bool {
//        var events = objc_getAssociatedObject(self, &controlHandlersKey) as! NSMutableDictionary
//        if events.count == 0 {
//            events = NSMutableDictionary()
//            objc_setAssociatedObject(self, &controlHandlersKey, events, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        let key = NSNumber.init(value: controlEvent.rawValue)
//        let handlers = events[key] as! NSMutableSet
//        return handlers.count > 0
//    }
//    
//}
