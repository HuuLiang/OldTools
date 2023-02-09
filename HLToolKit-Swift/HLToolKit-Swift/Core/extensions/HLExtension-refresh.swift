//
//  HLExtension-refresh.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/17.
//  Copyright © 2019 Liang. All rights reserved.
//

import MJRefresh

extension UIScrollView {
    
    fileprivate var hl_refreshTextColor:UIColor {
        get {
            return UIColor.init(white: 0.5, alpha: 1)
        }
    }
    
    @objc final func hl_isRefresh() -> Bool {
        if (self.mj_header != nil) || (self.mj_footer != nil) {
            return self.mj_header.isRefreshing || self.mj_footer.isRefreshing
        }
        return false
    }
    
    @objc final func hl_hideRefreshView() {
        if self.mj_header != nil {
            self.mj_header.isHidden = true
        }
        if self.mj_footer != nil {
            self.mj_footer.isHidden = true
        }
    }
    
    @objc final func hl_addPullToRefresh(_ handler:@escaping () -> Void ) {
        if self.mj_header == nil {
            let refreshHeader = MJRefreshNormalHeader.init(refreshingBlock: handler)
            refreshHeader?.stateLabel.textColor = self.hl_refreshTextColor
            self.mj_header = refreshHeader
        }
    }
    
    @objc final func hl_triggerPullToRefresh() {
        if self.mj_header != nil {
            self.mj_header.beginRefreshing()
        }
    }
    
    @objc final func hl_endPullToRefresh() {
        if self.mj_header != nil && self.mj_header.isRefreshing {
            self.mj_header.endRefreshing()
        }
        if self.mj_footer != nil && self.mj_footer.isRefreshing {
            self.mj_footer.endRefreshing()
        }
    }
    
    @objc final func hl_addPagingRefresh(_ handler:@escaping () -> Void ) {
        if self.mj_footer == nil {
            let refreshFooter = MJRefreshAutoNormalFooter.init(refreshingBlock: handler)
            refreshFooter?.stateLabel.textColor = self.hl_refreshTextColor
            self.mj_footer = refreshFooter
        }
    }
    
    @objc final func hl_pagingRefreshNoMoreData() {
        if self.mj_footer != nil {
            self.mj_footer.endRefreshingWithNoMoreData()
        }
    }
    
    @objc final func hl_setHeaderState(_ state:MJRefreshState) {
        if self.mj_header != nil {
            self.mj_header.state = state;
        }
    }
    
    @objc final func hl_setFooterState(_ state:MJRefreshState) {
        if self.mj_footer != nil {
            self.mj_footer.state = state;
        }
    }
    
    
}
