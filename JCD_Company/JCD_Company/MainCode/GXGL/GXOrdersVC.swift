//
//  GXOrdersVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia

class GXOrdersVC: BaseViewController {
    private let backBtn = UIButton().image(#imageLiteral(resourceName: "detail_back"))
    private let titleLabel = UILabel().text("我的订单").textColor(.kColor33).fontBold(18)
    private let titleScrollView =  UIScrollView().backgroundColor(.clear)
    private let pageScrollView = UIScrollView().backgroundColor(.clear)
    private var titles = ["全部", "待确认", "待付款", "待发货", "待收货"]
    private var titleBtns = [UIButton]()
    private var vcs = [GXOrdersListVC]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        statusStyle = .default
        let line = UIView().backgroundColor(.kColorEE)
        view.sv(backBtn, titleLabel, line, titleScrollView ,pageScrollView)
        view.layout(
            PublicSize.kStatusBarHeight,
            |-5-backBtn.size(44)-(>=0)-titleLabel.centerHorizontally(),
            0,
            |line.height(0.5)|,
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
        titleScrollView.showsHorizontalScrollIndicator = false
        backBtn.addTarget(self, action: #selector(backBtnClick(btn:)))
        loadData()
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
    
    func loadData() {
        // pleaseWait()
        refresh()
    }
    
    func refresh() {
        let btnW = view.width/5
        titles.enumerated().forEach { (item) in
            // 标题栏
            let index = item.offset
            let title = item.element
            let offsetX: CGFloat = btnW * CGFloat(index)
            let titleBtn = UIButton().text(title).textColor(.k2FD4A7).font(12)
            titleScrollView.sv(titleBtn)
            titleScrollView.layout(
                0,
                |-offsetX-titleBtn.width(btnW).height(37),
                0
            )
            titleBtn.tag = index
            titleBtn.addTarget(self, action: #selector(titleBtnClick(btn:)))
            titleBtns.append(titleBtn)
            
            let line = UIView().backgroundColor(.k2FD4A7).cornerRadius(1)
            line.tag = 10001
            titleBtn.sv(line)
            titleBtn.layout(
                >=0,
                line.width(24).height(2).centerHorizontally(),
                2
            )
            if index > 0 {
                line.isHidden = true
                titleBtn.textColor(.kColor33)
            }
            
            // 页面栏
            let pageOffsetX: CGFloat = view.width*CGFloat(index)
            let ordersVC = GXOrdersListVC()
            ordersVC.index = index
            addChild(ordersVC)
            pageScrollView.sv(ordersVC.view)
            pageScrollView.layout(
                0,
                |-pageOffsetX-ordersVC.view-(>=0)-|,
                0
            )
            ordersVC.view.width(pageScrollView.width).height(pageScrollView.height)
            vcs.append(ordersVC)
        }
    }
    
    @objc func titleBtnClick(btn: UIButton) {
        switchBtn(index: btn.tag)
        let offsetX: CGFloat = CGFloat(btn.tag)*PublicSize.kScreenWidth
        pageScrollView.contentOffset = CGPoint(x: offsetX, y: 0)
    }
    
    private func switchBtn(index: Int) {
        titleBtns.forEach { (titleBtn) in
            let line = titleBtn.viewWithTag(10001)
            if titleBtn.tag == index {
                line?.isHidden = false
                titleBtn.textColor(.k2FD4A7)
            } else {
                line?.isHidden = true
                titleBtn.textColor(.kColor33)
            }
        }
        let vc = vcs[index]
        if vc.rowsData.count == 0 {
            vc.current = 1
            vc.loadData()
        }
    }
}

extension GXOrdersVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / PublicSize.kScreenWidth)
        switchBtn(index: index)
    }
}
