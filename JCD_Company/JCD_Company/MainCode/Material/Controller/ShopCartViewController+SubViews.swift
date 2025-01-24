//
//  ShopCartViewController+SubViews.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/11/2.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh

extension ShopCartViewController {
    
    func prepareBottomView() {
        
        //底部结算栏
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-54)
            } else {
                make.height.equalTo(54)
            }
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = .kColor230
        bottomView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        
        let allCheckBtn = UIButton().text("  全选").textColor(.kColor66).font(12)
        allCheckBtn.setImage(#imageLiteral(resourceName: "login_uncheck"), for: .normal)
        allCheckBtn.setImage(#imageLiteral(resourceName: "login_check"), for: .selected)
        bottomView.addSubview(allCheckBtn)
        allCheckBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(14)
            make.height.equalTo(40)
        }
        self.allSelectBtn = allCheckBtn
        self.allSelectBtn.addTarget(self, action: #selector(allCheckBtnClick(btn:)))
        
        //去结算
        placeOrderBtn = UIButton.init(type: .custom)
        placeOrderBtn.setTitle("下一步", for: .normal)
        placeOrderBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        placeOrderBtn.setTitleColor(UIColor.white, for: .normal)
        placeOrderBtn.addTarget(self, action: #selector(placeOrderAction), for: .touchUpInside)
        
        bottomView.addSubview(placeOrderBtn)
        
        if IS_iPad {
            placeOrderBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            placeOrderBtn.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-14)
                make.width.equalTo(200)
                make.height.equalTo(38)
            }
        }else {
            placeOrderBtn.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-14)
                make.width.equalTo(100)
                make.height.equalTo(38)
            }
        }
        placeOrderBtn.fillGreenColor()
        placeOrderBtn.cornerRadius(19).masksToBounds()
        
        let desLabel = UILabel().text("产品项数: ").textColor(.kColor33).font(12)
        bottomView.addSubview(desLabel)
        desLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-150)
        }
        //主材项数
        materialCountLabel = UILabel()
        materialCountLabel.text = "0"
        materialCountLabel.textColor = .kFFAB3D
        materialCountLabel.font = UIFont.systemFont(ofSize: 12)
        bottomView.addSubview(materialCountLabel)
        
        if IS_iPad {
            materialCountLabel.font = UIFont.systemFont(ofSize: 15)
            materialCountLabel.snp.makeConstraints { (make) in
                make.left.equalTo(desLabel.snp.right)
                make.centerY.equalTo(placeOrderBtn)
            }
        }else {
            materialCountLabel.snp.makeConstraints { (make) in
                make.left.equalTo(desLabel.snp.right)
                make.centerY.equalTo(placeOrderBtn)
            }
        }
    }
    
    func prepareTableView() {
        
        //创建分类滑动视图
        classView = ClassificationSlidingView.init(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: PublicSize.screenHeight), titles: ["产品"])
        view.addSubview(classView)
        classView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        materialTableView = UITableView()
        materialTableView.backgroundColor = UIColor.clear
        materialTableView.rowHeight = 140.5
        materialTableView.separatorStyle = .none
        materialTableView.delegate = self
        materialTableView.dataSource = self
        materialTableView.register(ShopCartCell.self, forCellReuseIdentifier: identifier)
        
        let sview = classView.scollBgViews.first
        sview?.addSubview(materialTableView)
        materialTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if #available(iOS 11.0, *) {
            materialTableView.estimatedRowHeight = 0
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(loadData))
        materialTableView.mj_header = header
        
        //购物车空提示
        cartNullView = UIImageView()
        cartNullView.isHidden = true
        cartNullView.image = UIImage.init(named: "cartNull")
        cartNullView.contentMode = .scaleAspectFit
        view.addSubview(cartNullView)
        
        cartNullView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
            make.width.height.equalTo(150)
        }
    }
    
}
