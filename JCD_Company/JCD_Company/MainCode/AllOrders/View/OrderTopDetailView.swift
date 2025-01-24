//
//  OrderTopDetailView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/15.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class OrderTopDetailView: UIView {
    var plusNameLabel: UILabel!                 //套餐名
    var houseView: UIView!                      //工地背景
    var nameLabel: UILabel!                     //名字
    var sexLabel: UILabel!                      //性别
    var phoneLabel: UILabel!                    //电话
    var plotLabel: UILabel!                     //小区
    var roomNoLabel: UILabel!                   //房间号
    var acreageLabel: UILabel!                  //面积
    var addressLabel: UILabel!                  //地址
    
    var materialPriceLabel: UILabel!            //主材总价
    var materialCountLabel: UILabel!            //主材项数
    var servicePriceLabel: UILabel!             //施工总价
    var serviceCountLabel: UILabel!             //施工项数
    var priceLabel: UILabel!                    //订单总价
    var orderNoLabel: UILabel!                  //订单编号
    var createTimeLabel: UILabel!               //下单时间
    
    var telBtn: UIButton!
    var copyBtn: UIButton!
    
    var orderModel: OrderModel? {
        
        didSet {
            
            plusNameLabel.text = "套餐名"
            nameLabel.text = "姓名:"
            phoneLabel.text = "电话:"
            sexLabel.text = "性别:"
            roomNoLabel.text = "房间号:"
            acreageLabel.text = "面积:"
            plotLabel.text = "小区:"
            addressLabel.text = "地址:"
            
            priceLabel.text = "订单总价: ￥0.00"
            orderNoLabel.text = "订单编号:"
            createTimeLabel.text = "下单时间:"
            plusNameLabel.text = "自由组合"
            
            if let valueStr = orderModel?.customName {
                nameLabel.text = "姓名: \(valueStr)"
            }
            
            if let valueStr = orderModel?.customeMobile {
                phoneLabel.text = "电话: \(valueStr)"
            }
            
            if let valueType = orderModel?.sex?.intValue {
                
                if valueType > 0 && valueType <= AppData.sexList.count {
                    let array = Utils.getFieldArrInDirArr(arr: AppData.sexList, field: "label")
                    sexLabel.text = "性别: \(array[valueType-1])"
                }
            }
            
            if let valueStr = orderModel?.roomNo {
                roomNoLabel.text = "房间号: \(valueStr)"
            }
            
            if let valueStr = orderModel?.houseSpace?.doubleValue {
                let value = valueStr.notRoundingString(afterPoint: 2)
                acreageLabel.text = String.init(format: "面积: %@㎡", value)
            }
            
            if let valueStr = orderModel?.plotName {
                plotLabel.text = "小区: \(valueStr)"
            }
            
            if let valueStr = orderModel?.address {
                addressLabel.text = "地址: \(valueStr)"
            }
            
            if let valueStr = orderModel?.payMoney?.doubleValue {
                let value = valueStr.notRoundingString(afterPoint: 2)
                priceLabel.text = String(format: "订单总价: ¥%@", value)
            }
            
            if let valueStr = orderModel?.orderNo {
                orderNoLabel.text = "订单编号: \(valueStr)"
            }
            
            if let valueStr = orderModel?.createDate {
                createTimeLabel.text = "下单时间: \(valueStr)"
            }
   
        }
    }
    
    deinit {
        AppLog(">>>>>>>>>>>> 导出弹窗释放 <<<<<<<<<<<<")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubView() {
        //顶部图片
        let topImageView = UIImageView()
        topImageView.image = UIImage.init(named: "orderDetail_header")
        self.addSubview(topImageView)
        
        topImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(123)
        }
        
        //套餐名
        plusNameLabel = UILabel()
        plusNameLabel.text = "套餐名"
        plusNameLabel.textColor = .white
        plusNameLabel.font = UIFont.systemFont(ofSize: 17)
        self.addSubview(plusNameLabel)
        
        plusNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalToSuperview().offset(23)
        }
        
        //打电话
        telBtn = UIButton(type: .custom)
//        telBtn.addTarget(self, action: #selector(telAction), for: .touchUpInside)
        telBtn.setTitleColor(.white, for: .normal)
        telBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.addSubview(telBtn)
        
        telBtn.set(image: UIImage.init(named: "order_phone"), title: "联系客户", imagePosition: .right, additionalSpacing: 4, state: .normal)
        
        telBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(plusNameLabel)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        
        //工地栏
        houseView = UIView()
        houseView.backgroundColor = .white
        houseView.layer.cornerRadius = 4
        self.addSubview(houseView)
        
        houseView.layerShadow()
        
        houseView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.width.equalTo(PublicSize.screenWidth-20)
            make.top.equalTo(plusNameLabel.snp.bottom).offset(25)
            make.height.equalTo(112)
        }
        
        //名字
        nameLabel = UILabel()
        nameLabel.text = "姓名:"
        nameLabel.textColor = PublicColor.minorTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        houseView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(23)
            make.top.equalTo(15)
            make.width.equalTo((PublicSize.screenWidth-20)/2-33)
        }
        
        //性别
        sexLabel = UILabel()
        sexLabel.text = "性别:"
        sexLabel.textColor = nameLabel.textColor
        sexLabel.font = nameLabel.font
        houseView.addSubview(sexLabel)
        
        sexLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        //电话
        phoneLabel = UILabel()
        phoneLabel.text = "电话:"
        phoneLabel.textColor = nameLabel.textColor
        phoneLabel.font = nameLabel.font
        houseView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(nameLabel)
            make.top.equalTo(sexLabel.snp.bottom).offset(5)
        }
        
        //小区
        plotLabel = UILabel()
        plotLabel.text = "小区:"
        plotLabel.textColor = nameLabel.textColor
        plotLabel.font = nameLabel.font
        houseView.addSubview(plotLabel)
        
        plotLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.right.equalTo(-10)
            make.centerY.equalTo(nameLabel)
        }
        
        //房间号
        roomNoLabel = UILabel()
        roomNoLabel.text = "房间号:"
        roomNoLabel.textColor = nameLabel.textColor
        roomNoLabel.font = nameLabel.font
        houseView.addSubview(roomNoLabel)
        
        roomNoLabel.snp.makeConstraints { (make) in
            make.left.width.equalTo(plotLabel)
            make.top.equalTo(plotLabel.snp.bottom).offset(5)
        }
        
        //面积
        acreageLabel = UILabel()
        acreageLabel.text = "面积:"
        acreageLabel.textColor = nameLabel.textColor
        acreageLabel.font = nameLabel.font
        houseView.addSubview(acreageLabel)
        
        acreageLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(plotLabel)
            make.top.equalTo(roomNoLabel.snp.bottom).offset(5)
        }
        
        //地址
        addressLabel = UILabel()
        addressLabel.text = "地址:"
        addressLabel.textColor = nameLabel.textColor
        addressLabel.font = nameLabel.font
        addressLabel.numberOfLines = 2
        houseView.addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(phoneLabel.snp.bottom).offset(5)
            make.right.equalTo(plotLabel)
        }
        
        //上内容视图
        let upContentView = UIView()
        upContentView.backgroundColor = .white
        self.addSubview(upContentView)
        
        upContentView.snp.makeConstraints { (make) in
            make.top.equalTo(houseView.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.width.equalTo(PublicSize.screenWidth)
            make.height.equalTo(152)
        }
        
        //主材总价
        materialPriceLabel = UILabel()
        materialPriceLabel.text = "产品总价: ￥0.00"
        materialPriceLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x747474)
        materialPriceLabel.font = UIFont.systemFont(ofSize: 12)
        upContentView.addSubview(materialPriceLabel)
        
        materialPriceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(15)
            make.width.equalTo(PublicSize.screenWidth/2)
        }
        
        //主材项数
        materialCountLabel = UILabel()
        materialCountLabel.text = "产品项数: 0"
        materialCountLabel.textColor = materialPriceLabel.textColor
        materialCountLabel.font = materialPriceLabel.font
        upContentView.addSubview(materialCountLabel)
        
        materialCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-11)
            make.centerY.equalTo(materialPriceLabel)
        }
        
        //施工总价
        servicePriceLabel = UILabel()
        servicePriceLabel.isHidden = true
        servicePriceLabel.text = "施工总价: ￥0.00"
        servicePriceLabel.textColor = materialPriceLabel.textColor
        servicePriceLabel.font = materialPriceLabel.font
        upContentView.addSubview(servicePriceLabel)
        
        servicePriceLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(materialPriceLabel)
            make.top.equalTo(materialPriceLabel.snp.bottom).offset(5)
        }
        
        //施工项数
        serviceCountLabel = UILabel()
        serviceCountLabel.text = "施工项数: 0"
        serviceCountLabel.isHidden = true
        serviceCountLabel.textColor = materialPriceLabel.textColor
        serviceCountLabel.font = materialPriceLabel.font
        upContentView.addSubview(serviceCountLabel)
        
        serviceCountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(materialCountLabel)
            make.centerY.equalTo(servicePriceLabel)
        }
        
        //订单总价
        priceLabel = UILabel()
        priceLabel.text = "订单总价: ￥0.00"
        priceLabel.textColor = materialPriceLabel.textColor
        priceLabel.font = materialPriceLabel.font
        upContentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(materialPriceLabel)
            make.top.equalTo(servicePriceLabel.snp.bottom).offset(5)
        }
        
        let lineV = UIView()
        lineV.backgroundColor = PublicColor.partingLineColor
        upContentView.addSubview(lineV)
        
        lineV.snp.makeConstraints { (make) in
            make.left.equalTo(materialPriceLabel)
            make.right.equalTo(materialCountLabel)
            make.height.equalTo(1)
            make.top.equalTo(priceLabel.snp.bottom).offset(16)
        }
        
        //订单编号
        orderNoLabel = UILabel()
        orderNoLabel.text = "订单编号:"
        orderNoLabel.textColor = materialPriceLabel.textColor
        orderNoLabel.font = materialPriceLabel.font
        upContentView.addSubview(orderNoLabel)
        
        orderNoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(materialPriceLabel)
            make.top.equalTo(lineV.snp.bottom).offset(15)
        }
        
        //创建时间
        createTimeLabel = UILabel()
        createTimeLabel.text = "下单时间:"
        createTimeLabel.textColor = materialPriceLabel.textColor
        createTimeLabel.font = materialPriceLabel.font
        upContentView.addSubview(createTimeLabel)
        
        createTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(orderNoLabel)
            make.top.equalTo(orderNoLabel.snp.bottom).offset(5)
        }
        
        //复制
        let whiteImage = PublicColor.buttonColorImage
        let lightGrayImage = PublicColor.buttonHightColorImage
        
        copyBtn = UIButton(type: .custom)
        copyBtn.layer.masksToBounds = true
        copyBtn.layer.borderWidth = 1
        copyBtn.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xEEEDED).cgColor
        copyBtn.layer.cornerRadius = 2
        copyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        copyBtn.setTitle("复制", for: .normal)
        copyBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        copyBtn.setBackgroundImage(whiteImage, for: .normal)
        copyBtn.setBackgroundImage(lightGrayImage, for: .highlighted)
//        copyBtn.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        upContentView.addSubview(copyBtn)
        
        copyBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(orderNoLabel)
            make.right.equalTo(-15)
            make.height.equalTo(20)
            make.width.equalTo(60)
        }
        
    }
}
