//
//  HLExtension-UITableView.swift
//  CloudStore
//
//  Created by Liang on 2021/4/28.
//  Copyright © 2021 HangZhouMYQ. All rights reserved.
//

import UIKit

fileprivate let cs_base_tableviewheaderfooterView_identifier = "UITableViewHeaderFooterView_Base"

extension UITableView {
    
    final func customRegisterCell(with classes:[UITableViewCell.Type]) {
        classes.forEach {
            register($0.self, forCellReuseIdentifier: NSStringFromClass($0))
        }
        register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
    }
    
    final func customDequeueCell<T>(for indexPath:IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: NSStringFromClass(T.self as! AnyClass)) as? T
        if cell != nil {
            return cell!
        }
        return dequeueReusableCell(withIdentifier: NSStringFromClass(T.self as! AnyClass), for: indexPath) as! T
    }
    
    final func customDequeueBaseCell(for indexPath:IndexPath) -> UITableViewCell {
        dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath) as UITableViewCell
    }

    
    final func register(_ headerFooterClasses:[UITableViewHeaderFooterView.Type],containBase:Bool = false) {
        headerFooterClasses.forEach{
            register($0.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass($0))
        }
        if containBase {
            register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: cs_base_tableviewheaderfooterView_identifier)
        }
    }
    
    final func customRegisterHeaderFooterView(with classes:[UITableViewHeaderFooterView.Type]) {
        classes.forEach {
            register($0.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass($0))
        }
        register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(UITableViewHeaderFooterView.self))
    }
    
    final func customDequeueHeaderFooterView<T>() -> T? {
        dequeueReusableHeaderFooterView(withIdentifier: NSStringFromClass(T.self as! AnyClass)) as? T
    }

    final func customCellforRow<T>(at indexPath:IndexPath) -> T? {
        return cellForRow(at: indexPath) as? T
    }
    

}
