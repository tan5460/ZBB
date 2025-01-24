//
//  PlusOrderController+SubViews.swift
//  YZB_Company
//
//  Created by yzb_ios on 14.11.2018.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import Foundation

extension PlusOrderController {

    func prepareNavItem() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        
        //编辑
        let editBtn = UIButton(type: .custom)
        editBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        editBtn.setTitle("编辑", for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        editBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        editBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0xB3B3B3), for: .highlighted)
        editBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        let editItem = UIBarButtonItem.init(customView: editBtn)
        navigationItem.rightBarButtonItem = editItem
        
        //标题
        let titleView = UIView.init(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth*2/3, height: 44))
        navigationItem.titleView = titleView
        
        let plusNameLabel = UILabel()
        plusNameLabel.text = "套餐开单"
        plusNameLabel.textColor = PublicColor.commonTextColor
        plusNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        plusNameLabel.textAlignment = .center
        titleView.addSubview(plusNameLabel)
        
        plusNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(16)
        }
        
        let customNameLabel = UILabel()
        customNameLabel.text = "客户名"
        customNameLabel.textColor = PublicColor.minorTextColor
        customNameLabel.font = UIFont.systemFont(ofSize: 12)
        customNameLabel.textAlignment = .center
        titleView.addSubview(customNameLabel)
        
        customNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(plusNameLabel.snp.bottom).offset(5)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(13)
        }
        
        if let valueStr = plusModel?.name {
            plusNameLabel.text = valueStr
        }
        
        if let valueStr = houseModel?.custom?.realName {
            customNameLabel.text = valueStr
            
            if let spaceValue = houseModel?.space?.doubleValue {
                let spaceStr = spaceValue.notRoundingString(afterPoint: 2)
                customNameLabel.text = String.init(format: "%@ %@㎡", valueStr, spaceStr)
            }
        }
    }
    
    func prepareBottomView() {
        
        //底部结算栏
        bottomView = UIView()
        bottomView.backgroundColor = .white
        bottomView.layerShadow(color: .black, offsetSize: CGSize(width: 0, height: -1), opacity: 0.1, radius: 2)
        view.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
            } else {
                make.height.equalTo(44)
            }
        }
        
        //保存订单
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        surePayBtn = UIButton.init(type: .custom)
        surePayBtn.setTitle("保存订单", for: .normal)
        surePayBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        surePayBtn.setTitleColor(UIColor.white, for: .normal)
        surePayBtn.setBackgroundImage(backgroundImg, for: .normal)
        surePayBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        surePayBtn.addTarget(self, action: #selector(sureOrderAction), for: .touchUpInside)
        bottomView.addSubview(surePayBtn)
        
        if IS_iPad {
            
            surePayBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            surePayBtn.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(44)
            }
        }else {
            surePayBtn.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.width.equalTo(110)
                make.height.equalTo(44)
            }
        }
        
        //订单总价
        orderPriceLabel = UILabel()
        orderPriceLabel.text = "订单总价:￥0.00"
        orderPriceLabel.textColor = PublicColor.commonTextColor
        orderPriceLabel.font = UIFont.systemFont(ofSize: 13)
        bottomView.addSubview(orderPriceLabel)
        
        if IS_iPad {
            
            orderPriceLabel.font = UIFont.systemFont(ofSize: 14)
            orderPriceLabel.snp.makeConstraints { (make) in
                make.left.equalTo(15)
                make.centerY.equalTo(surePayBtn)
            }
        }else {
            orderPriceLabel.snp.makeConstraints { (make) in
                make.left.equalTo(10)
                make.top.equalTo(8)
            }
        }
        
        //主材价格
        materialPriceLabel = UILabel()
        materialPriceLabel.text = "产品:￥0.00"
        materialPriceLabel.textColor = PublicColor.minorTextColor
        materialPriceLabel.font = UIFont.systemFont(ofSize: 10)
        bottomView.addSubview(materialPriceLabel)
        
        if IS_iPad {
            
            materialPriceLabel.font = UIFont.systemFont(ofSize: 13)
            materialPriceLabel.snp.makeConstraints { (make) in
                make.left.equalTo(orderPriceLabel.snp.right).offset(50)
                make.centerY.equalTo(orderPriceLabel)
            }
        }else {
            materialPriceLabel.snp.makeConstraints { (make) in
                make.left.equalTo(orderPriceLabel)
                make.top.equalTo(orderPriceLabel.snp.bottom).offset(3)
            }
        }
        
        //施工价格
        servicePriceLabel = UILabel()
        servicePriceLabel.text = "施工:￥0.00"
        servicePriceLabel.textColor = materialPriceLabel.textColor
        servicePriceLabel.font = materialPriceLabel.font
        bottomView.addSubview(servicePriceLabel)
        
        servicePriceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(materialPriceLabel.snp.right).offset(20)
            make.centerY.equalTo(materialPriceLabel)
        }
    }
    
    func prepareScrollerView() {
        
        //顶部条
        topBarView = UIView()
        topBarView.backgroundColor = .white
        topBarView.layer.shadowColor = UIColor.colorFromRGB(rgbValue: 0x000000,alpha:0.12).cgColor
        topBarView.layer.shadowOffset = CGSize(width: 0, height: 1)
        topBarView.layer.shadowOpacity = 0.8
        topBarView.layer.shadowRadius = 2
        view.addSubview(topBarView)
        
        topBarView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        //加号
        let addIconBtn = UIButton()
        addIconBtn.setImage(UIImage.init(named: "menu_add"), for: .normal)
        addIconBtn.addTarget(self, action: #selector(addRoomAction), for: .touchUpInside)
        topBarView.addSubview(addIconBtn)
        
        addIconBtn.snp.makeConstraints { (make) in
            make.centerY.right.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        //滚动视图
        roomScrollerView = UIScrollView()
        roomScrollerView.delegate = self
        roomScrollerView.showsVerticalScrollIndicator = false
        roomScrollerView.showsHorizontalScrollIndicator = false
        roomScrollerView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        topBarView.addSubview(roomScrollerView)
        
        roomScrollerView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(addIconBtn.snp.left).offset(-5)
        }
        
        //跟随条
        followView = UIView()
        followView.backgroundColor = PublicColor.emphasizeTextColor
        
        //列表滚动视图
        contentScrollerView = UIScrollView()
        contentScrollerView.delegate = self
        contentScrollerView.showsVerticalScrollIndicator = false
        contentScrollerView.showsHorizontalScrollIndicator = false
        contentScrollerView.isPagingEnabled = true
        view.insertSubview(contentScrollerView, at: 0)
        
        contentScrollerView.snp.makeConstraints { (make) in
            make.top.equalTo(topBarView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
            make.left.right.equalToSuperview()
        }
    }
    
}
