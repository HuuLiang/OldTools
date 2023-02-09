//
//  HLExtension-QuartzCore.swift
//  CloudStore
//
//  Created by Liang on 2021/4/21.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//

extension CAGradientLayer {
        
    static func create(size:CGSize,
                       colors:[UIColor],
                       locations:[CGFloat] = [0,1],
                       direct:CSGradientDirection) -> CAGradientLayer {
        if colors.count != locations.count {
            fatalError("colors count must equal locations count")
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map({$0.cgColor})
        gradientLayer.locations = locations.map({NSNumber(value: Float($0))})
        gradientLayer.frame = .init(x: 0, y: 0, width: size.width, height: size.height)
        let directPoint = direct.directPoint(rect: .init(x: 0, y: 0, width: size.width, height: size.height))
        gradientLayer.startPoint = .init(x: directPoint.startPoint.x / size.width, y: directPoint.startPoint.y / size.height)
        gradientLayer.endPoint = .init(x: directPoint.endPoint.x / size.width, y: directPoint.endPoint.y / size.height)
        return gradientLayer
    }

}
