//
//  OrderDetailController+SubView.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/2/7.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import MJRefresh

extension OrderDetailController {

    
    func prepareBottomView() {
        
        //底部栏
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
            } else {
                make.height.equalTo(44)
            }
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        bottomView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //状态
        iconImage = UIImageView()
        iconImage.image = UIImage.init(named: "orderState_wait")
        bottomView.addSubview(iconImage)
        
        iconImage.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.width.height.equalTo(15)
            make.top.equalTo(15)
        }
        
        orderStateLabel = UILabel()
        orderStateLabel.text = "待确认"
        orderStateLabel.textAlignment = .center
        orderStateLabel.textColor = PublicColor.minorTextColor
        orderStateLabel.font = UIFont.systemFont(ofSize: 14)
        bottomView.addSubview(orderStateLabel)
        
        orderStateLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconImage)
            make.left.equalTo(iconImage.snp.right).offset(5)
        }
        
        let whiteImage = PublicColor.buttonColorImage
        let lightGrayImage = PublicColor.buttonHightColorImage
        
        //导出订单
        exportBtn = UIButton(type: .custom)
        exportBtn.layer.masksToBounds = true
        exportBtn.layer.borderWidth = 1
        exportBtn.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xEEEDED).cgColor
        exportBtn.layer.cornerRadius = 2
        exportBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        exportBtn.setTitle("导出", for: .normal)
        exportBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        exportBtn.setBackgroundImage(whiteImage, for: .normal)
        exportBtn.setBackgroundImage(lightGrayImage, for: .highlighted)
        exportBtn.addTarget(self, action: #selector(exportAction), for: .touchUpInside)
        bottomView.addSubview(exportBtn)
        
        exportBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconImage)
            make.width.equalTo(54)
            make.height.equalTo(28)
            make.right.equalTo(-15)
        }
        
        //修改状态
        modifyBtn = UIButton(type: .custom)
        modifyBtn.layer.masksToBounds = true
        modifyBtn.layer.borderWidth = 1
        modifyBtn.layer.borderColor = exportBtn.layer.borderColor
        modifyBtn.layer.cornerRadius = exportBtn.layer.cornerRadius
        modifyBtn.titleLabel?.font = exportBtn.titleLabel?.font
        modifyBtn.setTitle("修改", for: .normal)
        modifyBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        modifyBtn.setBackgroundImage(whiteImage, for: .normal)
        modifyBtn.setBackgroundImage(lightGrayImage, for: .highlighted)
       // modifyBtn.addTarget(self, action: #selector(modifyOrderAction), for: .touchUpInside)
        bottomView.addSubview(modifyBtn)
        
        modifyBtn.snp.makeConstraints { (make) in
            make.centerY.width.height.equalTo(exportBtn)
            make.right.equalTo(exportBtn.snp.left).offset(-8)
        }
        
        //取消订单
        deleteBtn = UIButton(type: .custom)
        deleteBtn.layer.masksToBounds = true
        deleteBtn.layer.borderWidth = 1
        deleteBtn.layer.borderColor = exportBtn.layer.borderColor
        deleteBtn.layer.cornerRadius = exportBtn.layer.cornerRadius
        deleteBtn.titleLabel?.font = exportBtn.titleLabel?.font
        deleteBtn.setTitle("删除", for: .normal)
        deleteBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        deleteBtn.setBackgroundImage(whiteImage, for: .normal)
        deleteBtn.setBackgroundImage(lightGrayImage, for: .highlighted)
        deleteBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        bottomView.addSubview(deleteBtn)
        
        deleteBtn.snp.makeConstraints { (make) in
            make.centerY.width.height.equalTo(exportBtn)
            make.right.equalTo(modifyBtn.snp.left).offset(-8)
        }
        
        //修改状态
        changeStateBtn = UIButton(type: .custom)
        changeStateBtn.layer.masksToBounds = true
        changeStateBtn.layer.borderWidth = 1
        changeStateBtn.layer.borderColor = exportBtn.layer.borderColor
        changeStateBtn.layer.cornerRadius = exportBtn.layer.cornerRadius
        changeStateBtn.titleLabel?.font = exportBtn.titleLabel?.font
        changeStateBtn.setTitle("更改状态", for: .normal)
        changeStateBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        changeStateBtn.setBackgroundImage(whiteImage, for: .normal)
        changeStateBtn.setBackgroundImage(lightGrayImage, for: .highlighted)
        changeStateBtn.addTarget(self, action: #selector(changeStateAction), for: .touchUpInside)
        bottomView.addSubview(changeStateBtn)
        
        changeStateBtn.snp.makeConstraints { (make) in
            make.width.equalTo(76)
            make.centerY.height.equalTo(exportBtn)
            make.right.equalTo(deleteBtn.snp.left).offset(-8)
        }
        
        //一键采购
        oneKeyBtn = UIButton(type: .custom)
        oneKeyBtn.layer.masksToBounds = true
        oneKeyBtn.isHidden = true
        oneKeyBtn.layer.borderWidth = 1
        oneKeyBtn.layer.borderColor = exportBtn.layer.borderColor
        oneKeyBtn.layer.cornerRadius = exportBtn.layer.cornerRadius
        oneKeyBtn.titleLabel?.font = exportBtn.titleLabel?.font
        oneKeyBtn.setTitle("一键采购", for: .normal)
        oneKeyBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        oneKeyBtn.setBackgroundImage(whiteImage, for: .normal)
        oneKeyBtn.setBackgroundImage(lightGrayImage, for: .highlighted)
        oneKeyBtn.addTarget(self, action: #selector(oneKeyAction), for: .touchUpInside)
        bottomView.addSubview(oneKeyBtn)
        
        oneKeyBtn.snp.makeConstraints { (make) in
            make.width.equalTo(76)
            make.centerY.height.equalTo(exportBtn)
            make.right.equalTo(deleteBtn.snp.left).offset(-8)
        }
    }
    
    func prepareHeaderView() {
        
        //顶部视图
        topView = OrderTopDetailView.init(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 351))
        topView.telBtn.addTarget(self,  action: #selector(telAction), for: .touchUpInside)
        topView.copyBtn.addTarget(self,  action: #selector(copyAction), for: .touchUpInside)

    }

    func prepareTableView() {

        tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 143
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(OrderDetailCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        tableView.tableHeaderView = topView
        
        //--注册组头
        tableView.register(OrderDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(loadData))
        tableView.mj_header = header
    }
}
