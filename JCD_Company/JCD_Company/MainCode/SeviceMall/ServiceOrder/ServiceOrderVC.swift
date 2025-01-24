//
//  ServiceOrderVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/9.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia

class ServiceOrderVC: BaseViewController {
    
    private let titleScrollView =  UIScrollView().backgroundColor(.white)
    private let pageScrollView = UIScrollView().backgroundColor(.white)
    private let titles = ["全部", "待确认", "已确认", "待商家服务", "待验收", "质保中"]
    private var titleBtns = [UIButton]()
    private var vcs = [ServiceOrderListVC]()
    public var currentIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的订单"
        
        view.sv(titleScrollView, pageScrollView)
        view.layout(
            0,
            |titleScrollView.height(37)|,
            0,
            |pageScrollView|,
            0
        )
        pageScrollView.layoutIfNeeded()
        pageScrollView.isPagingEnabled = true
        pageScrollView.bounces = true
        pageScrollView.delegate = self
        pageScrollView.contentSize = CGSize(width: view.width*CGFloat(titles.count), height: 0)
        pageScrollView.showsHorizontalScrollIndicator = false
        titleScrollView.showsHorizontalScrollIndicator = false
        var offsetX: CGFloat = 14
        let btnSpace: CGFloat = 24
        titles.enumerated().forEach { (item) in
            // 标题栏
            let index = item.offset
            let title = item.element
            let currentSize = title.getSizeWithHeight(font: UIFont.systemFont(ofSize: 12))
            
            let btnW: CGFloat = currentSize.width
            let titleBtn = UIButton().text(title).textColor(.k2FD4A7).font(12)
            titleScrollView.sv(titleBtn)
            titleScrollView.layout(
                0,
                |-offsetX-titleBtn.width(btnW+1).height(37)-(>=14)-|,
                0
            )
            
            titleBtn.layoutIfNeeded()
            titleBtn.tag = index
            titleBtn.addTarget(self, action: #selector(titleBtnClick(btn:)))
            titleBtns.append(titleBtn)
            
            
            let line = UIView().backgroundColor(.k2FD4A7).cornerRadius(0.5)
            line.tag = 10001
            titleBtn.sv(line)
            titleBtn.layout(
                >=0,
                line.width(btnW).height(1).centerHorizontally(),
                5
            )
            offsetX += (btnW + btnSpace)
            
            // 页面栏
            let pageOffsetX: CGFloat = view.width*CGFloat(index)
            let ordersVC = ServiceOrderListVC()
            ordersVC.index = index
            addChild(ordersVC)
            pageScrollView.sv(ordersVC.view)
            pageScrollView.layout(
                0,
                |-pageOffsetX-ordersVC.view-(>=0)-|,
                0
            )
            ordersVC.view.Width == pageScrollView.Width
            ordersVC.view.Height == pageScrollView.Height
            
            vcs.append(ordersVC)
            
            if index == (currentIndex ?? -1)+1 {
                titleBtn.textColor(.k2FD4A7)
                line.isHidden = false
            } else {
                titleBtn.textColor(.kColor33)
                line.isHidden = true
            }
        }
        let offsetX1: CGFloat = CGFloat((currentIndex ?? -1)+1)*view.width
        pageScrollView.contentOffset = CGPoint(x: offsetX1, y: 0)
    }
    
    
    @objc func titleBtnClick(btn: UIButton) {
        switchBtn(index: btn.tag)
        let offsetX: CGFloat = CGFloat(btn.tag)*view.width
        pageScrollView.contentOffset = CGPoint(x: offsetX, y: 0)
    }
    
    private func switchBtn(index: Int) {
        titleBtns.forEach { (titleBtn) in
            let line = titleBtn.viewWithTag(10001)
            if titleBtn.tag == index {
                titleBtn.textColor(.k2FD4A7)
                line?.isHidden = false
            } else {
                titleBtn.textColor(.kColor33)
                line?.isHidden = true
            }
        }
        vcs.forEach { (vc) in
            if vc.index == index {
//                if vc.dataSource == nil || vc.dataSource?.count == 0 {
//                    vc.loadData(false)
//                }
            }
        }
    }
}

extension ServiceOrderVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / view.width)
        switchBtn(index: index)
    }
}
