//
//  HLNetworkMonitor.swift
//  HLSwiftKit
//
//  Created by 胡亮亮 on 2022/5/25.
//

import CoreTelephony
import Alamofire
import AlamofireNetworkActivityIndicator

/// 网络监听模块
final class HLNetworkMonitor: NSObject {
    
    private var reachable:Bool = false
    private var cellularState:CTCellularDataRestrictedState = .restrictedStateUnknown
    private var completionAction:ConfirmAction? = nil
    
    static let `default`:HLNetworkMonitor = {
        let mana = HLNetworkMonitor()
        return mana
    }()
    
    private override init() {
        NetworkActivityIndicatorManager.shared.startDelay = 0
        NetworkActivityIndicatorManager.shared.isEnabled = true
    }
    
    private lazy var networkErrorView:CSNetworkErrorView = { [unowned self] in
        let view = CSNetworkErrorView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        view.touchAction = { [weak self] in
            self?.showAlertWithcellularState()
        }
        return view
    }()
    
    private lazy var cellularData:CTCellularData = { [unowned self] in
        let cellData = CTCellularData()
        return cellData
    }()
    
    /// 监听网络连接状态
    /// Tips 蜂窝网络在关闭情况下 设备仍然可以通过wifi连接网络 优化判断是否连接入网络 如果有网直接返回true。如果没有网再判断是否是权限问题
    final func startMonitor(completion:(()-> Void)? = nil) {
        completionAction = completion
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { [weak self] (listener) in
            switch listener {
            case .unknown:
                HLog("listener-unknow")
            case .notReachable:
                self?.reachable = false
                HUDManager.default().showCustomView(self!.networkErrorView)
            case .reachable(_):
                self?.reachable = true
                HUDManager.default().hide()
                self?.completionAction?()
                self?.completionAction = nil
            }
            
            self?.cellularData.cellularDataRestrictionDidUpdateNotifier = { [weak self] state in
                self?.cellularState = state
                CommonUtils.asyncAfter(timeInterval: 0.5) {
                    self?.showAlertWithcellularState()
                }
            }
        })
    }
    
    /// 根据蜂窝网络权限提示用户
    /// - Parameter cellularState: 当前蜂窝网络状态
    private final func showAlertWithcellularState() {
        //如果当前有网络链接 返回
        if reachable { return}
        
        //无网络链接
        switch cellularState {
        case .restricted:
            //无权限
            CommonUtils.showSystemAlert(from: nil,
                                        title: "已为“\(Bundle.main.displayName())”关闭蜂窝网络",
                                        subTitle: "您可以在“设置”中为此App打开蜂窝数据",
                                        leftDesc: "设置",
                                        leftHandle: {
                                            CommonUtils.openSetting()
                                        }, rightDesc: "好")
        case .notRestricted:
            //有权限
            CommonUtils.showSystemAlert(from: nil,
                                        title: "网络异常，",
                                        subTitle: "请检查网络链接状态后重试",
                                        rightDesc: "好")
        default:
            break
        }
    }
    
    
}
