//
//  HLExtension-UIViewController.swift
//  CloudStore
//
//  Created by Liang on 2020/9/11.
//  Copyright © 2020 HangZhouMYQ. All rights reserved.
//

// MARK:EmptyDataSet
extension UIViewController : EmptyDataSetDelegate,EmptyDataSetSource {
    
    
    public typealias EmptyAction = () -> Void
    
    private struct EmptySceneInfo {
        var imageName:String
        var text:String
    }

    private struct EmptyDataSetKeys {
        static var touchActionKey:String = "emptyDataSet_touchAction"
        static var SceneKey:String = "emptyDataSet_scene"
    }

    enum EmptyScene {
        ///通用
        case common
        ///地址
        case address
        ///购物车
        case cart
        ///消息
        case msg
        ///问题反馈
        case feedback
        ///礼包券列表
        case ticketList
        ///自定义
        case custom(imgName:String = "empty_common",
                    text:String = "暂无数据",
                    buttonText:String? = nil,
                    customView:UIView? = nil,
                    verticalOffset:CGFloat = -100)
        
        var imageName:String {
            switch self {
            case .common:           return "empty_common"
            case .address:          return "empty_address"
            case .cart:             return "empty_cart"
            case .msg:              return "empty_msg"
            case .feedback:         return "empty_feedback"
            case .ticketList:       return "empty_ticketList"
            case .custom(let imageName, _, _, _, _):
                return imageName
            }
        }
        
        var text:String {
            switch self {
            case .common:           return "暂无数据"
            case .address:          return "暂无地址，去添加新地址吧"
            case .cart:             return "购物车太空了，快去挑选吧"
            case .msg:              return "暂无消息"
            case .feedback:         return "暂无记录"
            case .ticketList:       return "没有可用礼包券呢"
            case .custom(_, let text, _, _, _):
                return text
            }
        }
        
        var customView:UIView? {
            switch self {
            case .custom(_, _, _,let view, _):
                return view
            default: return nil
            }
        }
        
        var buttonText:String? {
            switch self {
            case .cart: return "去逛逛"
            case .custom(_, _, let btnText,_, _):
                return btnText
            default: return nil
            }
        }
        
        var verticalOffset:CGFloat {
            switch self {
            case .custom(_, _, _, _, let offset):
                return offset
            default:
                return -100
            }
        }
        
    }
    
    private var emptyScene:EmptyScene {
        get {
            return objc_getAssociatedObject(self, &EmptyDataSetKeys.SceneKey) as? EmptyScene ?? .common
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataSetKeys.SceneKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    private var emptyAction:EmptyAction? {
        get {
            return objc_getAssociatedObject(self, &EmptyDataSetKeys.touchActionKey) as? EmptyAction
        }
        set {
            objc_setAssociatedObject(self, &EmptyDataSetKeys.touchActionKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    final func registerEmptyScene(with scrollView:UIScrollView,
                                  emptyScene:EmptyScene = .common,
                                  action: EmptyAction? = nil) {
        scrollView.emptyDataSetDelegate = self
        scrollView.emptyDataSetSource = self
        self.emptyScene = emptyScene
        self.emptyAction = action
    }
    
    
    //MARK: - DZNEmptyDataSetSource
//    public func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
//        return true
//    }
    
    public func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage.init(named: emptyScene.imageName)
    }
    
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSAttributedString.init(string: emptyScene.text,
                                       attributes: [NSAttributedString.Key.font:kFont(15),
                                                    NSAttributedString.Key.foregroundColor:kColor("999999")])
    }
    
    public func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        if emptyScene.buttonText != nil {
            return NSAttributedString.init(string: emptyScene.buttonText!,
                                           attributes: [NSAttributedString.Key.font:kFont(14),
                                                        NSAttributedString.Key.foregroundColor:kColor("222222")])
        }
        return nil
    }
    
    public func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return emptyScene.customView
    }
    
    public func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return emptyScene.verticalOffset
    }
    
    //MARK: - DZNEmptyDataSetDelegate Methods
    public func emptyDataSet(_ scrollView: UIScrollView, didTapView view: UIView) {
        self.emptyAction?()
    }
    
    public func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        self.emptyAction?()
    }

}
