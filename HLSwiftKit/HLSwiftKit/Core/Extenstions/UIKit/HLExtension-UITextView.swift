//
//  HLExtension-UITextView.swift
//  CloudStore
//
//  Created by Liang on 2021/10/9.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//

extension UITextView {
    
    private struct UITextFieldAssociated {
        static var inputAccessoryKey = "inputAccessoryKey"
    }
    
    var inputAccessoryViewEnable:Bool {
        get {
            return objc_getAssociatedObject(self, &UITextFieldAssociated.inputAccessoryKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UITextFieldAssociated.inputAccessoryKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if newValue {
                let backView = UIView(frame: kRect(x: 0, y: 0, w: kScreenWidth, h: 45 , convert: false))
                backView.backgroundColor = kColor("#D1D5DB")
                
                let button = UIButton(type: .custom)
                button.setTitle("完成", for: .normal)
                button.frame = kRect(x: kScreenWidth - 52, y: 0, w: 52, h: 45, convert: false)
                button.backgroundColor = kColor("#D1D5DB")
                button.setTitleColor(kColor("000000") , for: .normal)
                button.titleLabel?.font = kMFont(15)
                button.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
                backView.addSubview(button)
                self.inputAccessoryView = backView
            }
        }
    }
    
    @objc private final func hideKeyboard() {
        if canResignFirstResponder {
            resignFirstResponder()
        }
    }
}
