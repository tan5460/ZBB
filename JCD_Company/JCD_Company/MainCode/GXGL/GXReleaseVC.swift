//
//  GXReleaseVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia

class GXReleaseVC: BaseViewController {
    private let backBtn = UIButton().image(#imageLiteral(resourceName: "detail_back"))
    private let titleLabel = UILabel().text("我的发布").textColor(.kColor33).fontBold(18)
    private let titleScrollView =  UIScrollView().backgroundColor(.clear)
    private let pageScrollView = UIScrollView().backgroundColor(.clear)
    private var titles = ["清仓处理", "每周特惠", "拼购活动", "新品现货", "新品预购", "定制预购"]
    private var titleBtns = [UIButton]()
    private var vcs = [GXReleaseListVC]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        statusStyle = .default
        let line = UIView().backgroundColor(.kColorEE)
        if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
//            view.sv(backBtn, titleLabel, line, titleScrollView ,pageScrollView)
//            view.layout(
//                PublicSize.kStatusBarHeight,
//                |-5-backBtn.size(44)-(>=0)-titleLabel.centerHorizontally(),
//                0,
//                |line.height(0.5)|,
//                >=0
//            )
//            prepareNoDateView("暂无数据")
//            noDataView.isHidden = false
            titles = ["团购邀请"]
        } else {
            
        }
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
        loadData()
        backBtn.addTarget(self , action: #selector(backBtnClick(btn:)))
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
    
    func loadData() {
        // pleaseWait()
        refresh()
    }
    
    func refresh() {
        var offsetX: CGFloat = 14
        titles.enumerated().forEach { (item) in
            // 标题栏
            let index = item.offset
            let title = item.element
            let titleBtn = UIButton().text(title).textColor(.k2FD4A7).font(12)
            titleScrollView.sv(titleBtn)
            titleScrollView.layout(
                0,
                |-offsetX-titleBtn.height(37)-(>=14)-|,
                0
            )
            titleBtn.layoutIfNeeded()
            offsetX += titleBtn.width + 25
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
            let ordersVC = GXReleaseListVC()
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
        vc.index = index
        
        if vc.rowsData.count == 0 {
            vc.current = 1
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                vc.loadTGData()
            } else {
                if index == 3 {
                    vc.loaXPXHData()
                } else {
                    vc.loadData()
                }
            }
        }
    }
}

extension GXReleaseVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / PublicSize.kScreenWidth)
        switchBtn(index: index)
    }
}
