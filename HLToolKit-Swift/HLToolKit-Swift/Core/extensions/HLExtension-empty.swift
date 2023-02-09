//
//  HLExtension-empty.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/14.
//  Copyright © 2019 Liang. All rights reserved.
//

import EmptyDataSet_Swift

private var EmptyViewActionKey: Void?
private var EmptyButtonActionKey: Void?

private var EmptyTypeKey: Void?

extension UIViewController : EmptyDataSetDelegate,EmptyDataSetSource {
    
    public typealias ViewAction = () -> Void
    public typealias ButtonAction = () -> Void
    
    
    enum EmptyType:Int {
        case none
        case error
        case cate
        case cart
        case orderList
        case stock
    }
    
    var emptyType:EmptyType {
        get {
            return objc_getAssociatedObject(self, &EmptyTypeKey) as! EmptyType
        }
        set {
            objc_setAssociatedObject(self, &EmptyTypeKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var viewAction:ViewAction? {
        get {
            return objc_getAssociatedObject(self, &EmptyViewActionKey) as? ViewAction
        }
        set {
            objc_setAssociatedObject(self, &EmptyViewActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var buttonAction:ButtonAction? {
        get {
            return objc_getAssociatedObject(self, &EmptyButtonActionKey) as? ButtonAction
        }
        set {
            objc_setAssociatedObject(self, &EmptyButtonActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    final public func registerProtocol() {
        for subView in self.view.subviews {
            if subView.isKind(of: UIScrollView.self) {
                (subView as! UIScrollView).emptyDataSetDelegate = self
                (subView as! UIScrollView).emptyDataSetSource = self
                break
            }
        }
    }
    
    //MARK: - DZNEmptyDataSetSource
    public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    public func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        var imgName:String = ""
        switch self.emptyType {
        case .error:
            imgName = ""
        case .cate:
            imgName = ""
        case .cart:
            imgName = ""
        case .orderList:
            imgName = ""
        case .stock:
            imgName = ""
        default:
            return nil
        }
        return UIImage.init(imgName)
    }
    
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var title = ""
        switch self.emptyType {
        case .error:
            title = "您的购物车为空，快去选购呦"
        case .cate:
            title = "暂无订单信息"
        case .cart:
            title = "商品为您准备中"
        case .orderList:
            title = "暂无订单信息"
        case .stock:
            title = "暂无商品"
        default:
            return nil
        }
        let attributes:[NSAttributedString.Key : Any]! = [NSAttributedString.Key.font:kFont(17) as Any,NSAttributedString.Key.foregroundColor:kColor("#999999") as Any]
        return NSAttributedString.init(string: title, attributes: attributes)
    }
    
    //MARK: - DZNEmptyDataSetDelegate Methods
    public func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView) {
        if self.viewAction != nil {
            self.viewAction!()
        }
    }
    
    
    public func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        if self.buttonAction != nil {
            self.buttonAction!()
        }
    }

}
