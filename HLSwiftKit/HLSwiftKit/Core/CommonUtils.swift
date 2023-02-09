//
//  CommonUtils.swift
//  CloudStore
//
//  Created by Liang on 2020/10/24.
//  Copyright © 2020 HangZhouMYQ. All rights reserved.
//


/// 通用工具模块
final class CommonUtils {}

//MARK: Common
extension CommonUtils {
    ///加载基础配置信息
    static func loadBaseConfig() {
        if #available(iOS 11.0, *) {
            kSafeInsets = rootViewController?.view.safeAreaInsets ?? .init(top: 20, left: 0, bottom: 0, right: 0)
        } else {
            // Fallback on earlier versions
            kSafeInsets = .init(top: 20, left: 0, bottom: 0, right: 0)
        }
        isNotchScreen = kSafeInsets.top != 20.0
    }
    
    /// 打开设置界面
    static func openSetting() {
        if let settingUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingUrl, options: [:]) { (_) in
                
            }
        }
    }
    
    /// 获取根视图控制器
    static var rootViewController:UIViewController? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    ///用户登录密码
    static var userEncrypt:String = ""
}

//MARK: Alert
extension CommonUtils {
    
    /// 系统弹窗
    /// - Parameters:
    ///   - viewController: 视图控制器
    ///   - title: 主标题
    ///   - subTitle: 副标题
    ///   - leftDesc: 左按钮
    ///   - leftHandle: 左事件
    ///   - rightDesc: 右按钮
    ///   - rightHandle: 右事件
    static func showSystemAlert(from viewController:UIViewController? = nil,
                                title:String? = nil,
                                subTitle:String? = nil,
                                leftDesc:String? = nil,
                                leftHandle:(()->Void)? = nil,
                                rightDesc:String? = nil,
                                rightHandle:(()->Void)? = nil) {
        
        let block = {
            let rootVC:UIViewController? = viewController ?? rootViewController
            if rootVC == nil {
                return
            }
            
            let alertView = UIAlertController.init(title: title, message: subTitle, preferredStyle: .alert)
            if leftDesc != nil {
                if leftHandle == nil {
                    alertView.addAction(UIAlertAction.init(title: leftDesc, style: .cancel, handler:nil))
                } else {
                    alertView.addAction(UIAlertAction.init(title: leftDesc, style: .default, handler: { _ in
                        leftHandle?()
                    }))
                }
            }
            alertView.addAction(UIAlertAction.init(title: rightDesc, style: .default, handler: { _ in
                rightHandle?()
            }))
            if UIDevice.current.userInterfaceIdiom == .pad {
                alertView.popoverPresentationController?.sourceView = rootVC!.view
                alertView.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 0.1, height: 0.1)
            }
            
            rootVC!.present(alertView, animated: true, completion: nil)
        }
        
        executeInMainQueue {
            block()
        }
    }
    

    /// 弹出带有文本输入框的系统弹窗
    /// - Parameters:
    ///   - viewController: 视图控制器
    ///   - title: 标题
    ///   - leftDesc: 文本输入框
    ///   - rightDesc: 按钮文本
    ///   - completion: 输入框文本回传
    static func showSystemTextFieldAlertView(in viewController:UIViewController,
                                             _ title:String?,
                                             _ leftDesc:String?,
                                             _ rightDesc:String?,
                                             _ completion:((String?)->Void)?) {
        let alertView = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
        
        alertView.addTextField { (textfield) in
            textfield.textColor = kColor("333333")
            textfield.font = kFont(14)
            textfield.returnKeyType = .done
            textfield.delegate = viewController as? UITextFieldDelegate
        }
        alertView.addAction(UIAlertAction.init(title: leftDesc, style: .cancel, handler:nil))
        
        alertView.addAction(UIAlertAction.init(title: rightDesc, style: .default, handler: {action in
            let textfield = alertView.textFields![0]
            completion?(textfield.text)
        }))
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertView.popoverPresentationController?.sourceView = viewController.view
            alertView.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 0.1, height: 0.1)
        }
        DispatchQueue.main.async {
            viewController.present(alertView, animated: true, completion: nil)
        }
    }
}

//MARK: GCD
extension CommonUtils {
    /// 主线程执行
    /// - Parameter block: 执行block
    static func executeInMainQueue(block:@escaping ()->Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
        
    static func excuteAsync(in queue:DispatchQueue,with group:DispatchGroup,block:@escaping( @escaping ()->Void )->Void) {
        group.enter()
        queue.async {
            block() {
                group.leave()
            }
        }
    }
    
    static func excuteAsyncDownloadImage(with url:String?,
                                        queue:DispatchQueue,
                                        group:DispatchGroup,
                                         completion:@escaping (UIImage?)->Void) {
        guard url?.urlLegal == true else {return}
        excuteAsync(in: queue, with: group) { action in
            KingfisherManager.shared.retrieveImage(with: URL.init(stringLiteral: url!),options: [.processingQueue(.untouch)]) { (result) in
                switch result {
                case .success(let resp):
                    completion(resp.image)
                case .failure(let error):
                    HUDManager.default().showHint(error.localizedDescription)
                    completion(nil)
                }
                action()
            }
        }
    }
    
    static func asyncAfter(timeInterval:Double,handler:@escaping ()->Void) {
        let workItem = DispatchWorkItem.init {
            handler()
        }
        asyncAfter(timeInterval: timeInterval, workItem: workItem)
    }
    
    static func asyncAfter(timeInterval:Double,workItem:DispatchWorkItem) {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + timeInterval, execute: workItem)
    }
}

//MARK: 系统版本及设备
extension CommonUtils {
    
    static var systemVersion:String = {
        return UIDevice.current.systemVersion
    }()
    
    static var iPhoneType:String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let platform = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        
        if platform == "iPhone1,1" { return "iPhone 2G" }
        if platform == "iPhone1,2" { return "iPhone 3G" }
        if platform == "iPhone2,1" { return "iPhone 3GS"}
        if platform == "iPhone3,1" { return "iPhone 4" }
        if platform == "iPhone3,2" { return "iPhone 4" }
        if platform == "iPhone3,3" { return "iPhone 4" }
        if platform == "iPhone4,1" { return "iPhone 4S" }
        if platform == "iPhone5,1" { return "iPhone 5" }
        if platform == "iPhone5,2" { return "iPhone 5" }
        if platform == "iPhone5,3" { return "iPhone 5C" }
        if platform == "iPhone5,4" { return "iPhone 5C" }
        if platform == "iPhone6,1" { return "iPhone 5S" }
        if platform == "iPhone6,2" { return "iPhone 5S" }
        if platform == "iPhone7,1" { return "iPhone 6 Plus"}
        if platform == "iPhone7,2" { return "iPhone 6" }
        if platform == "iPhone8,1" { return "iPhone 6S" }
        if platform == "iPhone8,2" { return "iPhone 6S Plus" }
        if platform == "iPhone8,4" { return "iPhone SE" }
        if platform == "iPhone9,1" { return "iPhone 7" }
        if platform == "iPhone9,2" { return "iPhone 7 Plus" }
        if platform == "iPhone10,1" { return "iPhone 8" }
        if platform == "iPhone10,2" { return "iPhone 8 Plus" }
        if platform == "iPhone10,3" { return "iPhone X" }
        if platform == "iPhone10,4" { return "iPhone 8" }
        if platform == "iPhone10,5" { return "iPhone 8 Plus" }
        if platform == "iPhone10,6" { return "iPhone X" }
        if platform == "iPhone11,2" { return "iPhone XS" }
        if platform == "iPhone11,4" { return "iPhone XS Max" }
        if platform == "iPhone11,6" { return "iPhone XS" }
        if platform == "iPhone11,8" { return "iPhone XR" }
        if platform == "iPhone12,1" { return "iPhone 11" }
        if platform == "iPhone12,3" { return "iPhone 11 Pro" }
        if platform == "iPhone12,5" { return "iPhone 11 Pro Max" }
        if platform == "iPhone12,8" { return "iPhone SE 2nd Gen" }
        if platform == "iPhone13,1" { return "iPhone 12 Mini" }
        if platform == "iPhone13,2" { return "iPhone 12" }
        if platform == "iPhone13,3" { return "iPhone 12 Pro" }
        if platform == "iPhone13,4" { return "iPhone 12 Pro Max" }
        if platform == "iPhone14,2" { return "iPhone 13 Pro" }
        if platform == "iPhone14,3" { return "iPhone 13 Pro Max" }
        if platform == "iPhone14,4" { return "iPhone 13 Mini" }
        if platform == "iPhone14,5" { return "iPhone 13" }

        if platform == "iPod1,1" { return "iPod Touch 1G"}
        if platform == "iPod2,1" { return "iPod Touch 2G"}
        if platform == "iPod3,1" { return "iPod Touch 3G"}
        if platform == "iPod4,1" { return "iPod Touch 4G"}
        if platform == "iPod5,1" { return "iPod Touch 5G"}
        
        if platform == "iPad1,1" { return "iPad 1"}
        if platform == "iPad2,1" { return "iPad 2"}
        if platform == "iPad2,2" { return "iPad 2"}
        if platform == "iPad2,3" { return "iPad 2"}
        if platform == "iPad2,4" { return "iPad 2"}
        if platform == "iPad2,5" { return "iPad Mini 1"}
        if platform == "iPad2,6" { return "iPad Mini 1"}
        if platform == "iPad2,7" { return "iPad Mini 1"}
        if platform == "iPad3,1" { return "iPad 3"}
        if platform == "iPad3,2" { return "iPad 3"}
        if platform == "iPad3,3" { return "iPad 3"}
        if platform == "iPad3,4" { return "iPad 4"}
        if platform == "iPad3,5" { return "iPad 4"}
        if platform == "iPad3,6" { return "iPad 4"}
        if platform == "iPad4,1" { return "iPad Air"}
        if platform == "iPad4,2" { return "iPad Air"}
        if platform == "iPad4,3" { return "iPad Air"}
        if platform == "iPad4,4" { return "iPad Mini 2"}
        if platform == "iPad4,5" { return "iPad Mini 2"}
        if platform == "iPad4,6" { return "iPad Mini 2"}
        if platform == "iPad4,7" { return "iPad Mini 3"}
        if platform == "iPad4,8" { return "iPad Mini 3"}
        if platform == "iPad4,9" { return "iPad Mini 3"}
        if platform == "iPad5,1" { return "iPad Mini 4"}
        if platform == "iPad5,2" { return "iPad Mini 4"}
        if platform == "iPad5,3" { return "iPad Air 2"}
        if platform == "iPad5,4" { return "iPad Air 2"}
        if platform == "iPad6,3" { return "iPad Pro 9.7"}
        if platform == "iPad6,4" { return "iPad Pro 9.7"}
        if platform == "iPad6,7" { return "iPad Pro 12.9"}
        if platform == "iPad6,8" { return "iPad Pro 12.9"}
        
        if platform == "i386"   { return "iPhone Simulator"}
        if platform == "x86_64" { return "iPhone Simulator"}
        
        return platform
        
    }()

}
