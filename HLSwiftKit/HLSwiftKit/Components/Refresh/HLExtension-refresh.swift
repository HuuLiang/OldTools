//
//  HLExtension-refresh.swift
//  MSShop-Swift
//
//  Created by Liang on 2019/6/17.
//  Copyright © 2019 Liang. All rights reserved.
//

import MJRefresh

fileprivate let gif:CSGIFImage = {
    guard let gif = CSGIFImage.init(from: "pay_wait", options: .init(scale: 5.0)) else {
        fatalError()
    }
    return gif
}()

extension UIScrollView {
    
    @objc final func hl_headerView(hidden:Bool) {
        self.mj_header?.isHidden = hidden
    }
    
    @objc final func hl_footerView(hidden:Bool) {
        self.mj_footer?.isHidden = hidden
    }
    
    @objc final func hl_addPullToRefresh(_ top:CGFloat = 0, _ handler:@escaping () -> Void ) {
        if self.mj_header == nil {
            let refreshHeader = MJRefreshGifHeader.init(refreshingBlock: handler)
            refreshHeader.setImages(gif.images, duration: gif.duration, for: .idle)
            refreshHeader.setImages(gif.images, duration: gif.duration, for: .willRefresh)
            refreshHeader.setImages(gif.images, duration: gif.duration, for: .refreshing)
            refreshHeader.lastUpdatedTimeLabel?.isHidden = true
            refreshHeader.stateLabel?.isHidden = true
            refreshHeader.ignoredScrollViewContentInsetTop = top
            self.mj_header = refreshHeader
        }
    }
    
    @objc final func hl_addPagingRefresh(_ handler:@escaping () -> Void ) {
        if self.mj_footer == nil {
            let refreshFooter = MJRefreshAutoStateFooter.init(refreshingBlock: handler)
            refreshFooter.triggerAutomaticallyRefreshPercent = 0.1
            self.mj_footer = refreshFooter
        }
    }

    @objc final func hl_endPullToRefresh() {
        self.mj_header?.endRefreshing()
        self.mj_footer?.endRefreshing()
    }
    
    @objc final func hl_pagingRefreshNoMoreData() {
        self.mj_footer?.endRefreshingWithNoMoreData()
    }
}
