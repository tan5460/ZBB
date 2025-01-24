//
//  MyCenterController+SubViews.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/21.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation

extension MyCenterController {
    
    func createSubView() {
        
        //MARK:滚动视图
        scrollerView = UIScrollView()
        scrollerView.delegate = self
        scrollerView.showsVerticalScrollIndicator = false
        scrollerView.bounces = true
        scrollerView.alwaysBounceVertical = true
        view.addSubview(scrollerView)
        
        scrollerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if #available(iOS 11.0, *) {
            scrollerView.contentInsetAdjustmentBehavior = .never
        }
        
        
        //MARK:上背景
        headImageView = UIImageView.init(image: UIImage.init(named: "me_bg_img"))
        headImageView.frame = CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: headerHeight)
        headImageView.contentMode = .scaleAspectFit
        headImageView.layer.masksToBounds = true
        scrollerView.addSubview(headImageView)
        
        //头像
        headerImageBtn = UIButton(type: .custom)
        headerImageBtn.backgroundColor = .clear
        headerImageBtn.imageView?.contentMode = .scaleAspectFit
        headerImageBtn.layer.cornerRadius = 57/2
        headerImageBtn.layer.masksToBounds = true
        headerImageBtn.setImage(UIImage.init(named: "headerImage_man"), for: .normal)
        headerImageBtn.addTarget(self, action: #selector(headerImageAction), for: .touchUpInside)
        scrollerView.addSubview(headerImageBtn)
        
        headerImageBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(headImageView.snp.bottom).offset(-28)
            make.left.equalTo(22)
            make.width.height.equalTo(57)
        }
        
        //用户名
        nameLabel = UILabel()
        nameLabel.text = "周大大"
        nameLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xFEFEFE)
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        scrollerView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerImageBtn).offset(7)
            make.left.equalTo(headerImageBtn.snp.right).offset(22)
        }
        
        //职位
        displayJob = UILabel()
        displayJob.textAlignment = .center
        displayJob.layer.cornerRadius = 8
        displayJob.layer.masksToBounds = true
        displayJob.backgroundColor = UIColor.init(netHex: 0xE9FB55)
        displayJob.textColor = UIColor.init(netHex: 0x02B653)
        displayJob.font = UIFont.systemFont(ofSize: 10)
        scrollerView.addSubview(displayJob)
        
        displayJob.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.bottom.equalTo(nameLabel)
            make.height.equalTo(17)
            make.width.equalTo(33)
        }
        
        //店铺
        storeLabel = UILabel()
        storeLabel.text = "湖南优装宝装修公司"
        storeLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xFEFEFE)
        storeLabel.font = UIFont.systemFont(ofSize: 15)
        scrollerView.addSubview(storeLabel)
        
        storeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(9)
        }
        
        //设置
        let settingBtn = UIButton(type: .custom)
        settingBtn.setImage(UIImage.init(named: "settings_icon"), for: .normal)
        settingBtn.addTarget(self, action: #selector(settingAction), for: .touchUpInside)
        scrollerView.addSubview(settingBtn)
        
        settingBtn.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(20)
            }
            make.right.equalTo(-5)
            make.width.height.equalTo(40)
        }
        
        //消息
        chatBtn = UIButton(type: .custom)
        chatBtn.setImage(UIImage.init(named: "msg_chat"), for: .normal)
        chatBtn.addTarget(self, action: #selector(chatBtnClickAction), for: .touchUpInside)
        /// TODO:  - 
        scrollerView.addSubview(chatBtn)
        
        chatBtn.snp.makeConstraints { (make) in
            make.right.equalTo(settingBtn.snp.left)
            make.top.width.height.equalTo(settingBtn)
        }
        
        if UserData.shared.userType == .cgy {
            chatBtn.isHidden = true
        }
        
        //未读标记
        unreadMsgView = UIView()
        unreadMsgView.isHidden = true
        unreadMsgView.layer.cornerRadius = 4
        unreadMsgView.clipsToBounds = true
        unreadMsgView.backgroundColor = UIColor.red
        chatBtn.addSubview(unreadMsgView)
        
        unreadMsgView.snp.makeConstraints { (make) in
            make.width.height.equalTo(8)
            make.centerX.equalToSuperview().offset(10)
            make.centerY.equalToSuperview().offset(-10)
        }
        
        
        //MARK:我的客户工地背景
        let mineView = UIView()
        mineView.backgroundColor = .white
        scrollerView.addSubview(mineView)

        mineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(headerHeight)
            make.height.equalTo(80)
        }

        //我的客户
        customerBtn = UIButton(type: .custom)
        customerBtn.tag = 1000
        customerBtn.frame = CGRect(x:0, y: 0, width: PublicSize.screenWidth/3, height: 80)
        customerBtn.addTarget(self, action: #selector(customerAction), for: .touchUpInside)
        customerBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        customerBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        customerBtn.titleLabel?.lineBreakMode = .byTruncatingTail
        mineView.addSubview(customerBtn)
        
        customerBtn.set(image: UIImage.init(named: "mine_customer"), title: "我的客户", imagePosition: .top, additionalSpacing: 10, state: .normal)

        customerBtn.snp.makeConstraints { (make) in
            make.bottom.top.equalToSuperview()
            make.left.equalToSuperview()
        }

        //我的积分
        workBtn = UIButton(type: .custom)
        workBtn.tag = 1001
        workBtn.frame = CGRect(x:0, y: 0, width: PublicSize.screenWidth/3, height: 80)
        workBtn.addTarget(self, action: #selector(workSiteAction), for: .touchUpInside)
        workBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        workBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        workBtn.titleLabel?.lineBreakMode = .byTruncatingTail
        mineView.addSubview(workBtn)
        
        workBtn.set(image: UIImage.init(named: "mine_workSite"), title: "我的工地", imagePosition: .top, additionalSpacing: 10, state: .normal)

        workBtn.snp.makeConstraints { (make) in
            make.left.equalTo(customerBtn.snp.right)
            make.bottom.top.width.equalTo(customerBtn)
        }

        //自建品牌
        selfBuildBtn = UIButton(type: .custom)
        selfBuildBtn.isHidden = true
        selfBuildBtn.frame = CGRect(x:0, y: 0, width: PublicSize.screenWidth/3, height: 80)
        selfBuildBtn.addTarget(self, action: #selector(selfBuildAction), for: .touchUpInside)
        selfBuildBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        selfBuildBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        selfBuildBtn.titleLabel?.lineBreakMode = .byTruncatingTail
        mineView.addSubview(selfBuildBtn)
        
        selfBuildBtn.set(image: UIImage.init(named: "mine_selfBuild"), title: "自建产品", imagePosition: .top, additionalSpacing: 10, state: .normal)

        selfBuildBtn.snp.makeConstraints { (make) in
            make.left.equalTo(workBtn.snp.right)
            make.top.bottom.equalTo(customerBtn)
            make.width.equalTo(0)
            make.right.equalToSuperview()
        }
        
        
        //MARK:采购订单背景
        cgOrderView = UIView()
        cgOrderView.backgroundColor = .white
        scrollerView.addSubview(cgOrderView)
        
        cgOrderView.snp.makeConstraints { (make) in
            make.top.equalTo(mineView.snp.bottom).offset(10)
            make.left.right.equalTo(mineView)
            make.height.equalTo(114)
        }

        //采购订单
        let cgOrderLabel = UILabel()
        cgOrderLabel.text = "采购订单"
        cgOrderLabel.textColor = PublicColor.commonTextColor
        cgOrderLabel.font = UIFont.systemFont(ofSize: 15)
        cgOrderView.addSubview(cgOrderLabel)
        
        cgOrderLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(14)
        }
        
        //更多订单箭头
        let cgOrderArrowView = UIImageView()
        cgOrderArrowView.image = UIImage.init(named: "arrow_right")
        cgOrderArrowView.contentMode = .center
        cgOrderView.addSubview(cgOrderArrowView)
        
        cgOrderArrowView.snp.makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalTo(cgOrderLabel)
            make.right.equalTo(-15)
        }

        //分割线
        let cgOrderLineView = UIView()
        cgOrderLineView.backgroundColor = PublicColor.partingLineColor
        cgOrderView.addSubview(cgOrderLineView)
        
        cgOrderLineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(cgOrderLabel.snp.bottom).offset(14)
        }
        
        //MARK:我的订单背景
        orderView = UIView()
        orderView.backgroundColor = .white
        scrollerView.addSubview(orderView)
        
        orderView.snp.makeConstraints { (make) in
            make.top.equalTo(cgOrderLineView.snp.bottom)
            make.left.right.equalTo(cgOrderLineView)
            make.height.equalTo(114)
        }

        //我的订单
        let orderLabel = UILabel()
        orderLabel.text = "客户订单"
        orderLabel.textColor = PublicColor.commonTextColor
        orderLabel.font = UIFont.systemFont(ofSize: 15)
        orderView.addSubview(orderLabel)
        
        orderLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(14)
        }
        
        //更多订单箭头
        let orderArrowView = UIImageView()
        orderArrowView.image = UIImage.init(named: "arrow_right")
        orderArrowView.contentMode = .center
        orderView.addSubview(orderArrowView)
        
        orderArrowView.snp.makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalTo(orderLabel)
            make.right.equalTo(-15)
        }

        //分割线
        let orderLineView = UIView()
        orderLineView.backgroundColor = PublicColor.partingLineColor
        orderView.addSubview(orderLineView)
        
        orderLineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(orderLabel.snp.bottom).offset(14)
        }
        
        //采购订单按钮
        let cgOrderBtn = UIButton(type: .custom)
        cgOrderBtn.addTarget(self, action: #selector(cgOrderAction), for: .touchUpInside)
        cgOrderView.addSubview(cgOrderBtn)
        cgOrderBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //交易明细按钮
        let moreOrderBtn = UIButton(type: .custom)
        moreOrderBtn.addTarget(self, action: #selector(moreOrderAction), for: .touchUpInside)
        orderView.addSubview(moreOrderBtn)
        
        moreOrderBtn.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(orderLineView)
        }
        
        //订单按钮
        let titles = ["待确认","已确认","已完成"]
        let imgs = ["icon_unconfirmed","icon_confirmed","icon_completed"]
        let w = (PublicSize.screenWidth-40)/CGFloat(titles.count)
        for (i,title) in titles.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = 1000 + i
            btn.frame = CGRect(x:20 + w * CGFloat(i), y: 50, width: w, height: 60)
            btn.addTarget(self, action: #selector(orderClickAction(_:)), for: .touchUpInside)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            btn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            orderView.addSubview(btn)
            
            btn.set(image: UIImage.init(named: imgs[i]), title: title, imagePosition: .top, additionalSpacing: 7, state: .normal)
            
            if i == 0 {
                unconfirmedCount = UILabel()
                unconfirmedCount.isHidden = true
                unconfirmedCount.text = "0"
                unconfirmedCount.textColor = .white
                unconfirmedCount.textAlignment = .center
                unconfirmedCount.font = UIFont.systemFont(ofSize: 9)
                unconfirmedCount.backgroundColor = PublicColor.unreadMsgColor
                unconfirmedCount.layer.cornerRadius = 7
                unconfirmedCount.layer.masksToBounds = true
                orderView.addSubview(unconfirmedCount)
                
                unconfirmedCount.snp.makeConstraints { (make) in
                    make.height.width.equalTo(14)
                    make.top.equalTo(btn.snp.top).offset(2)
                    make.centerX.equalTo(btn).offset(9)
                }
            }
        }
 
        //MARK:交易记录背景
        recordView = UIView()
        recordView.backgroundColor = .white
        scrollerView.addSubview(recordView)
        
        recordView.snp.makeConstraints { (make) in
            make.top.equalTo(orderView.snp.bottom).offset(10)
            make.left.right.height.equalTo(orderView)
        }
        
        //交易记录
        let recordLabel = UILabel()
        recordLabel.text = "交易记录"
        recordLabel.textColor = PublicColor.commonTextColor
        recordLabel.font = UIFont.systemFont(ofSize: 15)
        recordView.addSubview(recordLabel)
        
        recordLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(14)
        }
        
        //更多交易箭头
        let recordArrowView = UIImageView()
        recordArrowView.image = UIImage.init(named: "arrow_right")
        recordArrowView.contentMode = .center
        recordView.addSubview(recordArrowView)
        
        recordArrowView.snp.makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalTo(recordLabel)
            make.right.equalTo(-15)
        }
        
        //分割线
        let recordLineView = UIView()
        recordLineView.backgroundColor = PublicColor.partingLineColor
        recordView.addSubview(recordLineView)
        
        recordLineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(recordLabel.snp.bottom).offset(14)
        }
        
        //交易明细按钮
        let moreRecordBtn = UIButton(type: .custom)
        moreRecordBtn.addTarget(self, action: #selector(moreRecordAction), for: .touchUpInside)
        recordView.addSubview(moreRecordBtn)
        
        moreRecordBtn.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        //交易量
        recordCountLabel = UILabel()
        recordCountLabel.text = "0"
        recordCountLabel.textColor = PublicColor.emphasizeTextColor
        recordCountLabel.font = UIFont.systemFont(ofSize: 15)
        recordView.addSubview(recordCountLabel)
        
        recordCountLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().multipliedBy(1.0/2)
            make.top.equalTo(recordLineView.snp.bottom).offset(12)
        }
        
        //单位
        let recordUnitLabel = UILabel()
        recordUnitLabel.text = "单"
        recordUnitLabel.textColor = PublicColor.emphasizeTextColor
        recordUnitLabel.font = UIFont.systemFont(ofSize: 10)
        recordView.addSubview(recordUnitLabel)
        
        recordUnitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(recordCountLabel.snp.right).offset(1)
            make.bottom.equalTo(recordCountLabel).offset(-1)
        }
        
        //本月成交量
        let recordDetailLabel = UILabel()
        recordDetailLabel.text = "本月成交量"
        recordDetailLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x4D4D4D)
        recordDetailLabel.font = UIFont.systemFont(ofSize: 12)
        recordView.addSubview(recordDetailLabel)
        
        recordDetailLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(recordCountLabel).offset(5)
            make.top.equalTo(recordCountLabel.snp.bottom).offset(5)
        }
        
        //分割线
        let recordLineView2 = UIView()
        recordLineView2.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6)
        recordView.addSubview(recordLineView2)
        
        recordLineView2.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordLineView.snp.bottom).offset(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(1)
        }
        
        //交易金额
        recordMoneyLabel = UILabel()
        recordMoneyLabel.text = "0.00"
        recordMoneyLabel.textColor = PublicColor.emphasizeTextColor
        recordMoneyLabel.font = UIFont.systemFont(ofSize: 15)
        recordView.addSubview(recordMoneyLabel)
        
        recordMoneyLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().multipliedBy(3.0/2)
            make.centerY.equalTo(recordCountLabel)
        }
        
        //单位
        let moneyUnitLabel = UILabel()
        moneyUnitLabel.text = "元"
        moneyUnitLabel.textColor = PublicColor.emphasizeTextColor
        moneyUnitLabel.font = UIFont.systemFont(ofSize: 10)
        recordView.addSubview(moneyUnitLabel)
        
        moneyUnitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(recordMoneyLabel.snp.right).offset(1)
            make.bottom.equalTo(recordMoneyLabel).offset(-1)
        }
        
        //本月成交量
        let moneyDetailLabel = UILabel()
        moneyDetailLabel.text = "本月成交额"
        moneyDetailLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x4D4D4D)
        moneyDetailLabel.font = UIFont.systemFont(ofSize: 12)
        recordView.addSubview(moneyDetailLabel)
        
        moneyDetailLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(recordMoneyLabel).offset(5)
            make.centerY.equalTo(recordDetailLabel)
        }
        
        changeViewBg = recordView
        var topOffset = 10
        if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
            
            /// 显示切换
            if UserData.shared.workerModel?.jobType == 999 || UserData.shared.workerModel?.jobType == 4  {
                
                topOffset = 0
                
                //MARK:切换changeViewBg背景
                changeViewBg = UIView()
                changeViewBg.backgroundColor = .white
                scrollerView.addSubview(changeViewBg)
                
                changeViewBg.snp.makeConstraints { (make) in
                    make.top.equalTo(recordView.snp.bottom).offset(10)
                    make.left.right.equalTo(mineView)
                    make.height.equalTo(44)
                }
                
                //切换模式
                let inviteTapOne = UITapGestureRecognizer(target: self, action: #selector(changeMode))
                inviteTapOne.numberOfTapsRequired = 1
                changeViewBg.addGestureRecognizer(inviteTapOne)
                
                //切换
                let inviteLabel = UILabel()
                inviteLabel.text = "切换模式"
                inviteLabel.textColor = PublicColor.commonTextColor
                inviteLabel.font = UIFont.systemFont(ofSize: 15)
                changeViewBg.addSubview(inviteLabel)
                
                inviteLabel.snp.makeConstraints { (make) in
                    make.top.left.equalTo(14)
                }
                
                //箭头
                let inviteArrowView = UIImageView()
                inviteArrowView.image = UIImage.init(named: "arrow_right")
                inviteArrowView.contentMode = .center
                changeViewBg.addSubview(inviteArrowView)
                
                inviteArrowView.snp.makeConstraints { (make) in
                    make.width.equalTo(8)
                    make.height.equalTo(15)
                    make.centerY.equalTo(inviteLabel)
                    make.right.equalTo(-15)
                }
                
                
                let modeTitle = UserData.shared.userType == .jzgs ? "客户下单" : "采购下单"
                let displayCurrentModel = UILabel()
                displayCurrentModel.text = "\"\(modeTitle)\"模式"
                displayCurrentModel.textColor = PublicColor.minorTextColor
                displayCurrentModel.font = UIFont.systemFont(ofSize: 15)
                changeViewBg.addSubview(displayCurrentModel)
                
                displayCurrentModel.snp.makeConstraints { (make) in
                    make.right.equalTo(inviteArrowView.snp.left).offset(-8)
                    make.centerY.equalTo(inviteLabel)
                }
                
                redView = UIView()
                redView.isHidden = true
                redView.layer.cornerRadius = 4
                redView.clipsToBounds = true
                redView.backgroundColor = UIColor.red
                changeViewBg.addSubview(redView)
                
                redView.snp.makeConstraints { (make) in
                    make.width.height.equalTo(8)
                    make.bottom.equalTo(inviteLabel.snp.top)
                    make.left.equalTo(inviteLabel.snp.right)
                }
            }
            else if  UserData.shared.workerModel?.jobType != 999 && UserData.shared.workerModel?.jobType != 4 {
                
                topOffset = 0

                //MARK:切换changeViewBg背景
                changeViewBg = UIView()
                changeViewBg.backgroundColor = .white
                scrollerView.addSubview(changeViewBg)

                changeViewBg.snp.makeConstraints { (make) in
                    make.top.equalTo(recordView.snp.bottom).offset(10)
                    make.left.right.equalTo(mineView)
                    make.height.equalTo(0)
                }

                let inviteTapOne = UITapGestureRecognizer(target: self, action: #selector(toShop))
                inviteTapOne.numberOfTapsRequired = 1
                changeViewBg.addGestureRecognizer(inviteTapOne)

                let inviteLabel = UILabel()
                inviteLabel.text = "产品商城"
                inviteLabel.textColor = PublicColor.commonTextColor
                inviteLabel.font = UIFont.systemFont(ofSize: 15)
                changeViewBg.addSubview(inviteLabel)

                inviteLabel.snp.makeConstraints { (make) in
                    make.top.left.equalTo(14)
                }

                //箭头
                let inviteArrowView = UIImageView()
                inviteArrowView.image = UIImage.init(named: "arrow_right")
                inviteArrowView.contentMode = .center
                changeViewBg.addSubview(inviteArrowView)

                inviteArrowView.snp.makeConstraints { (make) in
                    make.width.equalTo(8)
                    make.height.equalTo(15)
                    make.centerY.equalTo(inviteLabel)
                    make.right.equalTo(-15)
                }
            }
            
        }
       
        //MARK:我的邀请背景
//        let inviteView = UIView()
//        inviteView.backgroundColor = .white
//        scrollerView.addSubview(inviteView)
//
//        inviteView.snp.makeConstraints { (make) in
//            make.top.equalTo(changeViewBg.snp.bottom).offset(topOffset)
//            make.left.right.equalTo(mineView)
//            make.height.equalTo(44)
//        }
//
//
//        //我的邀请手势
//        let inviteTapOne = UITapGestureRecognizer(target: self, action: #selector(inviteAction))
//        inviteTapOne.numberOfTapsRequired = 1
//        inviteView.addGestureRecognizer(inviteTapOne)
//
//        //我的邀请
//        let inviteLabel = UILabel()
//        inviteLabel.text = "我的邀请"
//        inviteLabel.textColor = PublicColor.commonTextColor
//        inviteLabel.font = UIFont.systemFont(ofSize: 15)
//        inviteView.addSubview(inviteLabel)
//
//        inviteLabel.snp.makeConstraints { (make) in
//            make.top.left.equalTo(14)
//        }
//
//        //我的邀请箭头
//        let inviteArrowView = UIImageView()
//        inviteArrowView.image = UIImage.init(named: "arrow_right")
//        inviteArrowView.contentMode = .center
//        inviteView.addSubview(inviteArrowView)
//
//        inviteArrowView.snp.makeConstraints { (make) in
//            make.width.equalTo(8)
//            make.height.equalTo(15)
//            make.centerY.equalTo(inviteLabel)
//            make.right.equalTo(-15)
//        }
//
        //MARK:会员背景
        let memberView = UIView()
        memberView.backgroundColor = .white
        scrollerView.addSubview(memberView)
        
        memberView.snp.makeConstraints { (make) in
            make.top.equalTo(changeViewBg.snp.bottom).offset(topOffset)
            make.left.right.equalTo(mineView)
            make.height.equalTo(44)
        }
        
        //会员手势
        let memberTapOne = UITapGestureRecognizer(target: self, action: #selector(memberAction))
        memberTapOne.numberOfTapsRequired = 1
        memberView.addGestureRecognizer(memberTapOne)
        
        //会员中心
        let memberLabel = UILabel()
//        memberLabel.text = "会员中心"
        memberLabel.text = "邀请码"
        memberLabel.textColor = PublicColor.commonTextColor
        memberLabel.font = UIFont.systemFont(ofSize: 15)
        memberView.addSubview(memberLabel)
        
        memberLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(14)
        }
        
        //更多箭头
        let memberArrowView = UIImageView()
        memberArrowView.image = UIImage.init(named: "arrow_right")
        memberArrowView.contentMode = .center
        memberView.addSubview(memberArrowView)
        
        memberArrowView.snp.makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalTo(memberLabel)
            make.right.equalTo(-15)
        }
        
        if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {

            //MARK:会员中心
            let substationView = UIView()
            substationView.backgroundColor = .white
            scrollerView.addSubview(substationView)
            substationView.isHidden = true 
            substationView.snp.makeConstraints { (make) in
                make.top.equalTo(memberView.snp.bottom)
                make.left.right.equalTo(mineView)
                make.height.equalTo(44)
            }

            //会员手势
            let substationTapOne = UITapGestureRecognizer(target: self, action: #selector(memberCenter))
            substationTapOne.numberOfTapsRequired = 1
            substationView.addGestureRecognizer(substationTapOne)

            //会员中心
            let substationLabel = UILabel()
            substationLabel.text = "会员中心"
            substationLabel.textColor = PublicColor.commonTextColor
            substationLabel.font = UIFont.systemFont(ofSize: 15)
            substationView.addSubview(substationLabel)

            substationLabel.snp.makeConstraints { (make) in
                make.left.top.equalTo(14)
            }

            //更多箭头
            let substationArrowView = UIImageView()
            substationArrowView.image = UIImage.init(named: "arrow_right")
            substationArrowView.contentMode = .center
            substationView.addSubview(substationArrowView)

            substationArrowView.snp.makeConstraints { (make) in
                make.width.equalTo(8)
                make.height.equalTo(15)
                make.centerY.equalTo(substationLabel)
                make.right.equalTo(-15)
            }

        }
        //else {
//
//            //MARK: 系统通知背景
//            let msgView = UIView()
//            msgView.backgroundColor = .white
//            scrollerView.addSubview(msgView)
//
//            msgView.snp.makeConstraints { (make) in
//                make.top.equalTo(memberView.snp.bottom)
//                make.left.right.equalTo(mineView)
//                make.height.equalTo(inviteView)
//            }
//
//            //会员手势
//            let msgTapOne = UITapGestureRecognizer(target: self, action: #selector(msgAction))
//            msgTapOne.numberOfTapsRequired = 1
//            msgView.addGestureRecognizer(msgTapOne)
//
//            //会员中心
//            let msgLabel = UILabel()
//            msgLabel.text = "系统通知"
//            msgLabel.textColor = PublicColor.commonTextColor
//            msgLabel.font = UIFont.systemFont(ofSize: 15)
//            msgView.addSubview(msgLabel)
//
//            msgLabel.snp.makeConstraints { (make) in
//                make.left.top.equalTo(14)
//            }
//
//            //更多箭头
//            let msgArrowView = UIImageView()
//            msgArrowView.image = UIImage.init(named: "arrow_right")
//            msgArrowView.contentMode = .center
//            msgView.addSubview(msgArrowView)
//
//            msgArrowView.snp.makeConstraints { (make) in
//                make.width.equalTo(8)
//                make.height.equalTo(15)
//                make.centerY.equalTo(msgLabel)
//                make.right.equalTo(-15)
//            }
//
//            //未读标记
//            unreadView = UIView()
//            unreadView.isHidden = true
//            unreadView.layer.cornerRadius = 4
//            unreadView.clipsToBounds = true
//            unreadView.backgroundColor = UIColor.red
//            msgView.addSubview(unreadView)
//
//            unreadView.snp.makeConstraints { (make) in
//                make.width.height.equalTo(8)
//                make.top.equalTo(msgLabel)
//                make.left.equalTo(msgLabel.snp.right).offset(2)
//            }
//        }
    }
    
    func createRefreshView() {
        
        //刷新控件背景图
        refreshView = UIView()
        refreshView.backgroundColor = UIColor.clear
        refreshView.isHidden = true
        view.addSubview(refreshView)
        
        refreshView.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.width.equalTo(110)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(24)
            }
            make.centerX.equalToSuperview()
        }
        
        //加载时的菊花
        activityView = UIActivityIndicatorView(style: .white)
        activityView.isHidden = true
        activityView.backgroundColor = UIColor.clear
        refreshView.addSubview(activityView)
        
        activityView.snp.makeConstraints { (make) in
            make.centerY.left.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        //下拉时的箭头
        refreshImage = UIImageView()
        refreshImage.contentMode = .scaleAspectFit
        refreshImage.image = UIImage.init(named: "center_arrow_up")
        refreshView.addSubview(refreshImage)
        
        refreshImage.snp.makeConstraints { (make) in
            make.center.equalTo(activityView)
            make.width.height.equalTo(16)
        }
        
        //下拉加载的提示语
        refreshLabel = UILabel()
        refreshLabel.textColor = .white
        refreshLabel.text = "松手即可刷新"
        refreshLabel.font = UIFont.systemFont(ofSize: 13)
        refreshView.addSubview(refreshLabel)
        
        refreshLabel.snp.makeConstraints { (make) in
            make.centerY.right.equalToSuperview()
            make.left.equalTo(activityView.snp.right).offset(5)
        }
    }
    
}
