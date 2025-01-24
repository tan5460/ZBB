//
//  PlaceOrderController2+SubViews.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/1.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

extension PlaceOrderController {
    func prepareTopView() {
        
        //顶部工地栏
        topView = UIView()
        topView.backgroundColor = .white
        topView.isUserInteractionEnabled = true
        view.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(64)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
     
        
        //手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(editHouseAction))
        tapOne.numberOfTapsRequired = 1
        topView.addGestureRecognizer(tapOne)
        
        //请选择客户工地
        houseHintLabel = UILabel()
        houseHintLabel.text = "请选择客户工地"
        houseHintLabel.font = UIFont.systemFont(ofSize: 15)
        topView.addSubview(houseHintLabel)
        
        houseHintLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        //工地详情内容
        houseDetailView = UIView()
        houseDetailView.isHidden = true
        houseDetailView.backgroundColor = .white
        topView.addSubview(houseDetailView)
        
        houseDetailView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //彩色条纹
        let colourView = UIImageView()
        colourView.image = UIImage.init(named: "order_colour")
        view.addSubview(colourView)
        
        colourView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalTo(topView)
            make.height.equalTo(3)
        }
        
        //箭头
        let arrowImageView = UIImageView()
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.image = UIImage.init(named: "order_arrow")
        topView.addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(18)
        }
        
        //姓名
        nameLabel = UILabel()
        nameLabel.text = "姓名"
        nameLabel.textColor = PublicColor.commonTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        houseDetailView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(28)
            make.top.equalTo(10)
            make.width.equalTo(95)
        }
        
        //电话
        phoneLabel = UILabel()
        phoneLabel.text = "电话"
        phoneLabel.textColor = nameLabel.textColor
        phoneLabel.font = nameLabel.font
        houseDetailView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(120)
        }
        
        //面积
        acreageLabel = UILabel()
        acreageLabel.text = "面积"
        acreageLabel.textColor = nameLabel.textColor
        acreageLabel.font = nameLabel.font
        houseDetailView.addSubview(acreageLabel)
        
        acreageLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-45)
            make.centerY.equalTo(nameLabel)
        }
        
        //地址图标
        let plotIcoView = UIImageView()
        plotIcoView.contentMode = .scaleAspectFit
        plotIcoView.image = UIImage.init(named: "order_plotIco")
        houseDetailView.addSubview(plotIcoView)
        
        plotIcoView.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(11)
            make.width.height.equalTo(15)
        }
        
        //小区
        plotLabel = UILabel()
        plotLabel.text = "小区"
        plotLabel.textColor = PublicColor.minorTextColor
        plotLabel.font = UIFont.systemFont(ofSize: 12)
        houseDetailView.addSubview(plotLabel)
        
        plotLabel.snp.makeConstraints { (make) in
            make.left.equalTo(plotIcoView.snp.right).offset(2)
            make.centerY.equalTo(plotIcoView)
            make.right.equalTo(-80)
        }
        
        if enterType == .fromDetail {
            if let valueStr = houseModel?.customName {
                 nameLabel.text = valueStr
             }
             
             if let valueStr = houseModel?.customMobile {
                 phoneLabel.text = valueStr
             }
             
             if let acreageStr = houseModel?.space?.doubleValue {
                 let acreage = acreageStr.notRoundingString(afterPoint: 2, qian: false)
                 acreageLabel.text = String.init(format: "%@㎡", acreage)
             }
             
             var plotName = ""
             if let valueStr = houseModel?.plotName {
                 plotName = valueStr
                 
                 if let roomNoStr = houseModel?.roomNo {
                     plotName += roomNoStr
                     plotLabel.text = plotName
                 }
             }
             
             if houseModel == nil {
                 
                 houseDetailView.isHidden = true
                 
                 topView.snp.remakeConstraints { (make) in
                     if #available(iOS 11.0, *) {
                         make.top.equalTo(view.safeAreaLayoutGuide)
                     } else {
                         make.top.equalTo(64)
                     }
                     make.left.right.equalToSuperview()
                     make.height.equalTo(40)
                 }
                 
             }else {
                 houseDetailView.isHidden = false
            
                 topView.snp.remakeConstraints { (make) in
                     if #available(iOS 11.0, *) {
                         make.top.equalTo(view.safeAreaLayoutGuide)
                     } else {
                         make.top.equalTo(64)
                     }
                     make.left.right.equalToSuperview()
                     make.height.equalTo(56)
                 }
                 
             }
        }
        
        if enterType == .fromOrderDetail {
            if let valueStr = orderModel?.customName {
                nameLabel.text = valueStr
            }
            
            if let valueStr = orderModel?.customeMobile {
                phoneLabel.text = valueStr
            }
            
            if let acreageStr = orderModel?.houseSpace?.doubleValue {
                let acreage = acreageStr.notRoundingString(afterPoint: 2, qian: false)
                acreageLabel.text = String.init(format: "%@㎡", acreage)
            }
            
            var plotName = ""
            if let valueStr = orderModel?.plotName {
                plotName = valueStr
                
                if let roomNoStr = orderModel?.roomNo {
                    plotName += roomNoStr
                    plotLabel.text = plotName
                }
            }
            
            if orderModel == nil {
                houseDetailView.isHidden = true
                
                topView.snp.remakeConstraints { (make) in
                    if #available(iOS 11.0, *) {
                        make.top.equalTo(view.safeAreaLayoutGuide)
                    } else {
                        make.top.equalTo(64)
                    }
                    make.left.right.equalToSuperview()
                    make.height.equalTo(40)
                }
                
            }else {
                houseDetailView.isHidden = false
                topView.snp.remakeConstraints { (make) in
                    if #available(iOS 11.0, *) {
                        make.top.equalTo(view.safeAreaLayoutGuide)
                    } else {
                        make.top.equalTo(64)
                    }
                    make.left.right.equalToSuperview()
                    make.height.equalTo(56)
                }
            }
        }
        
    }
    
    func prepareBottomView() {
        
        //底部结算栏
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
        
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        bottomView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
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
        
        selectNumLabel = UILabel()
        selectNumLabel.text = "已选: \(rowsData.count)"
        selectNumLabel.textColor = PublicColor.minorTextColor
        selectNumLabel.font = UIFont.systemFont(ofSize: 13)
        bottomView.addSubview(selectNumLabel)
        selectNumLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(15)
        }
        
        var allPrice: Decimal = 0
        if activityType == 2 {
            allPrice = Decimal.init(currentSKUModel?.price?.doubleValue ?? 0)
        } else {
            rowsData.forEach { (item) in
                if materials1.count > 0 {
                    let count = Decimal.init(item.buyCount.doubleValue)
                    let price = Decimal.init(item.priceSell?.doubleValue ?? 0)
                    allPrice += count * price
                } else {
                    if enterType == .fromCart {
                        let count = Decimal.init(item.count?.doubleValue ?? 0)
                        let price = Decimal.init(item.priceSell?.doubleValue ?? 0)
                        allPrice += count * price
                    } else if enterType == .fromOrderDetail {
                        let count = Decimal.init(item.materialsCount?.doubleValue ?? 0)
                        let price = Decimal.init(string: item.materialsPriceCustom ?? "0") ?? 0
                        allPrice += count * price
                    }
                    else {
                        let count = Decimal.init(item.buyCount.doubleValue)
                        
                        var price = Decimal.init(currentSKUModel?.priceSell?.doubleValue ?? 0)
                        
                        if activityType == 3  || activityType == 4 {
                            price = Decimal.init(currentSKUModel?.price?.doubleValue ?? 0)
                        }
                        if detailType == .hyzx {
                            price = Decimal.init(currentSKUModel?.activityPrice?.doubleValue ?? 0)
                        }
                        allPrice += count * price
                    }
                }
            }
        }
        
        allPriceLabel = UILabel()
        allPriceLabel.text = "合计: \(allPrice)"
        allPriceLabel.textColor = PublicColor.minorTextColor
        allPriceLabel.font = UIFont.systemFont(ofSize: 13)
        
        bottomView.addSubview(allPriceLabel)
        allPriceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(selectNumLabel.snp.right).offset(10)
            make.top.equalTo(15)
        }
        totalValue = allPrice
    }
    
    func prepareTableView() {
        classView = ClassificationSlidingView.init(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: PublicSize.screenHeight), titles: ["产品"])
        view.addSubview(classView)
        classView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(13)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        //左边列表
        leftTableView = UITableView()
        leftTableView.tag = 1001
        leftTableView.backgroundColor = .clear
        leftTableView.rowHeight = 152
        leftTableView.separatorStyle = .none
        leftTableView.delegate = self
        leftTableView.dataSource = self
        leftTableView.showsVerticalScrollIndicator = false
        let sview = classView.scollBgViews.first
        sview?.backgroundColor = UIColor.init(red: 242.0/255, green: 243.0/255, blue: 246.0/255, alpha: 1)
        sview?.addSubview(leftTableView)
        leftTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        if #available(iOS 11.0, *) {
            leftTableView.estimatedRowHeight = 0
        }
 
        //无数据提示
        leftEmptyLabel = UILabel()
        leftEmptyLabel.isHidden = true
        leftEmptyLabel.text = "没有可下单的主材包哦，赶紧去添加吧~"
        leftEmptyLabel.font = UIFont.systemFont(ofSize: 11)
        leftEmptyLabel.textColor = PublicColor.placeholderTextColor
        leftTableView.addSubview(leftEmptyLabel)
        
        leftEmptyLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(49)
        }
    }
}
