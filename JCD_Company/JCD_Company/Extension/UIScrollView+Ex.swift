//
//  UIScrollView+Ex.swift
//  ChalkTalks
//
//  Created by Cloud on 2019/10/15.
//  Copyright © 2019 巢云. All rights reserved.
//

import UIKit
import MJRefresh

extension UIScrollView {
    /// 下拉刷新
    /// - Parameter completion: 刷新回调，用来进行接口请求
    func refreshHeader(completion: (() -> Void)?) {
        mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
            if let block = completion {
                block()
            }
            self?.resumeRefresh()
        })
    }
    /// 上拉刷新
    /// - Parameter completion: 刷新回调，用来进行接口请求
    func refreshFooter(completion: (() -> Void)?) {
        mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {
            if let block = completion {
                block()
            }
        })
    }
    
    func refreshBackFooter(completion: (() -> Void)?) {
        mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
            if let block = completion {
                block()
            }
        })
    }
    
    /// 开始下拉刷新
    func beginHeaderRefresh() {
        guard mj_header != nil else { return }
        mj_header?.beginRefreshing()
    }
    
    /// 开始下拉刷新
    func beginHeaderRefresh(completionBlock: (() -> Void)?) {
        guard mj_header != nil else { return }
        if let block = completionBlock {
            mj_header?.beginRefreshing(completionBlock: block)
        }
    }
    
    /// 结束无法上拉刷新
    func resumeRefresh() {
        guard mj_footer != nil else { return }
        mj_footer?.resetNoMoreData()
    }
    /// 结束下拉刷新
    /// - Parameter completion: 结束刷新回调
    func endHeaderRefresh(completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now()+35/60) { [weak self] in
            guard self?.mj_header != nil else { return }
            self?.mj_header?.endRefreshing {
                if let block = completion {
                    block()
                }
            }
        }
    }
    
    /// 结束上拉刷新
    /// - Parameter text: 刷新完后提醒文字
    /// - Parameter completion: 结束刷新回调
    func endFooterRefresh(completion: (() -> Void)? = nil) {
        guard mj_footer != nil else { return }
        mj_footer?.endRefreshing {
            if let block = completion {
                block()
            }
        }
    }
    /// 结束上拉刷新并提醒没有更多数据
    func endFooterRefreshNoMoreData() {
        guard mj_footer != nil else { return }
        mj_footer?.endRefreshingWithNoMoreData()
    }
}
