//
//  GXNewVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/10/23.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper

class GXNewVC: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    private let backBtn = UIButton().image(#imageLiteral(resourceName: "back_white"))
    private let titleLabel = UILabel().text("新品上市").textColor(.white).fontBold(18)
    private let bannerIV = UIImageView().image(#imageLiteral(resourceName: "gx_new_banner"))
    private let titleScrollView =  UIScrollView().backgroundColor(.clear)
    private let pageScrollView = UIScrollView().backgroundColor(.clear)
    private var titles = ["新品现货", "新品预购"]
    private var titleBtns = [UIButton]()
    private var vcs = [GXNewListVC]()
    private var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        statusStyle = .lightContent
        setupTopBgView()
        bannerIV.contentMode = .scaleAspectFill
        view.sv(backBtn, titleLabel, bannerIV, titleScrollView ,pageScrollView)
        view.layout(
            PublicSize.kStatusBarHeight,
            |-5-backBtn.size(44)-(>=0)-titleLabel.centerHorizontally(),
            15,
            |-14-bannerIV.height(110)-14-|,
            25,
            |titleScrollView.height(30)|,
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
        refresh()
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
    
    func setupTopBgView() {
        let topBgView = UIView()
        topBgView.frame = CGRect(x: 0, y: 0, width: view.width, height: 156.5)
        // fill
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.87, green: 0.98, blue: 0.94, alpha: 1).cgColor, UIColor(red: 0, green: 0.53, blue: 0.3, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = topBgView.bounds
        bgGradient.startPoint = CGPoint(x: 0.5, y: 1)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 0)
        topBgView.layer.addSublayer(bgGradient)
        topBgView.alpha = 1
        topBgView.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 20)
        view.addSubview(topBgView)
    }
    
    
    func refresh() {
        var offsetX: CGFloat = 14
        let btnW: CGFloat = 80
        let btnH: CGFloat = 30
        titles.enumerated().forEach { (item) in
            // 标题栏
            let index = item.offset
            let title = item.element
            let titleBtn = UIButton().text(title).textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "gx_new_switch_btn"))
            titleScrollView.sv(titleBtn)
            titleScrollView.layout(
                0,
                |-offsetX-titleBtn.width(btnW).height(btnH),
                0
            )
            titleBtn.titleEdgeInsets = UIEdgeInsets(top: -4, left: 0, bottom: 0, right: 0)
            titleBtn.layoutIfNeeded()
            offsetX += btnW + 15
            titleBtn.tag = index
            titleBtn.addTarget(self, action: #selector(titleBtnClick(btn:)))
            titleBtns.append(titleBtn)
            
            if index == 0 {
                titleBtn.textColor(.white).backgroundImage(#imageLiteral(resourceName: "gx_new_switch_btn"))
            } else {
                titleBtn.textColor(.kColor66).backgroundImage(UIImage())
            }
            
            // 页面栏
            let pageOffsetX: CGFloat = view.width*CGFloat(index)
            let ordersVC = GXNewListVC()
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
        currentIndex = index
        titleBtns.forEach { (titleBtn) in
            if titleBtn.tag == index {
                titleBtn.textColor(.white).backgroundImage(#imageLiteral(resourceName: "gx_new_switch_btn"))
            } else {
                titleBtn.textColor(.kColor66).backgroundImage(UIImage())
            }
        }
        let vc = vcs[index]
        vc.current = 1
        vc.index = currentIndex
        vc.loadData()
    }
}

extension GXNewVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / PublicSize.kScreenWidth)
        switchBtn(index: index)
    }
}
