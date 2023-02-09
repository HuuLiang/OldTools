//
//  HLExtension-CoreGraphics.swift
//  CloudStore
//
//  Created by Liang on 2021/4/21.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//


struct CSGradientDirectPoint {
    let startPoint:CGPoint
    let endPoint:CGPoint
}

/// 渐变方向
enum CSGradientDirection {
    ///从上到下 ,
    case topToBottom
    ///从左到右
    case leftToRight
    ///从左上到右下
    case topLToBottomR
    
    ///custom
    case customDirection(startPoint:CGPoint,endPoint:CGPoint)
    
    func directPoint(rect:CGRect) -> CSGradientDirectPoint {
        switch self {
        case .topToBottom:
            return .init(startPoint: .init(x: rect.origin.x + rect.width / 2.0, y: rect.origin.y),
                         endPoint: .init(x: (rect.origin.x + rect.width) / 2.0, y: rect.origin.y + rect.height))
        case .leftToRight:
            return .init(startPoint: .init(x: rect.origin.x, y: rect.origin.y + rect.height / 2.0),
                         endPoint: .init(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height / 2.0))
        case .topLToBottomR:
            return .init(startPoint: rect.origin,
                         endPoint: .init(x: rect.origin.x + rect.width, y: rect.origin.y + rect.height))
        case let .customDirection(startPoint: startPoint, endPoint: endPoint):
            return .init(startPoint: startPoint,
                         endPoint: endPoint)
        }
    }
    
    var percentPoint:CSGradientDirectPoint {
        switch self {
        case .topToBottom:
            return .init(startPoint: .init(x: 0.5, y: 0),
                         endPoint: .init(x: 0.5, y: 1))
        case .leftToRight:
            return .init(startPoint: .init(x: 0, y: 0.5),
                         endPoint: .init(x: 1, y: 0.5))
        case .topLToBottomR:
            return .init(startPoint: .zero,
                         endPoint: .init(x: 1, y: 1))
        case let .customDirection(startPoint: startPoint, endPoint: endPoint):
            return .init(startPoint: startPoint,
                         endPoint: endPoint)
        }
    }
}

extension CGGradient {
    
    static func `init`(colors:[UIColor],locations:[CGFloat] = [0,1]) -> CGGradient? {
        if colors.count != locations.count {
            //            fatalError("colors count must equal locations count")
            return nil
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components:[CGFloat] = colors.flatMap { (color) -> [CGFloat] in
            return color.components
        }
        return CGGradient.init(colorSpace: colorSpace, colorComponents: components, locations: locations, count: locations.count)
    }
    
}
