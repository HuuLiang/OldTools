//
//  HLExtension-UIButton.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/10.
//  Copyright © 2019 Liang. All rights reserved.
//

import UIKit

public extension UIButton {
    @objc enum HLButtonEdgeInsetsStyle:Int {
        case Top
        case Left
        case Bottom
        case Right
    }
    
    
    @objc final func layoutButton(_ insetsStyle:HLButtonEdgeInsetsStyle,_ imageTitleSpace:CGFloat) -> Void {
        let imageWidth:CGFloat = (self.imageView?.frame.size.width)!
        let imageHeigth:CGFloat = (self.imageView?.frame.size.height)!
        
        var labelWidth:CGFloat!
        var labelHeight:CGFloat!
        labelWidth = 0.0
        labelHeight = 0.0
        
        if UIDevice.current.systemVersion.floatValue >= 8.0 {
            labelWidth = self.titleLabel?.intrinsicContentSize.width
            labelHeight = self.titleLabel?.intrinsicContentSize.height
        } else {
            labelWidth = self.titleLabel?.frame.size.width
            labelHeight = self.titleLabel?.frame.size.height
        }
        
        var imageEdgeInsets:UIEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets:UIEdgeInsets = UIEdgeInsets.zero
        
        switch insetsStyle {
        case .Top:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight - imageTitleSpace/2.0, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: -imageWidth - imageTitleSpace/2.0, right: 0)
        case .Left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTitleSpace/2.0, bottom: 0, right: imageTitleSpace/2.0);
            labelEdgeInsets = UIEdgeInsets(top: 0, left: imageTitleSpace/2.0, bottom: 0, right: -imageTitleSpace/2.0);
        case .Bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight-imageTitleSpace/2.0, right: -labelWidth);
            labelEdgeInsets = UIEdgeInsets(top: -imageHeigth-imageTitleSpace/2.0, left: -imageWidth, bottom: 0, right: 0);
        case .Right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+imageTitleSpace/2.0, bottom: 0, right: -labelWidth-imageTitleSpace/2.0);
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth-imageTitleSpace/2.0, bottom: 0, right: imageWidth+imageTitleSpace/2.0);
        }
        
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
}
