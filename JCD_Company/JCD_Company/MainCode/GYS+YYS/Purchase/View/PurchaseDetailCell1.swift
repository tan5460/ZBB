//
//  PuechaseDetailCell1.swift
//  YZB_Company
//
//  Created by yzb_ios on 15.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

enum PurchaseCellType {
    ///订单信息
    case orderInfo
    ///收货信息
    case contactInfo
    ///支付信息
    case payInfo
}

class PurchaseDetailCell1: UITableViewCell {
    
    //1~5行label
    var titleLabel1: UILabel!
    var titleLabel2: UILabel!
    var titleLabel3: UILabel!
    var titleLabel4: UILabel!
    var titleLabel5: UILabel!
    var titleLabel6: UILabel!
    var titleLabel7: UILabel!
    var label1: UILabel!
    var label2: UILabel!
    var label3: UILabel!
    var label4: UILabel!
    var label5: UILabel!
    var label6: UILabel!
    var label7: UILabel!

    let textFont = UIFont.systemFont(ofSize: 13)
    
    //聊天按钮
    var contactBtn1: UIButton!
    var contactBtn2: UIButton!
    
    var purchaseCellType: PurchaseCellType?
    
    var purchaseModel: PurchaseOrderModel? {
        
        didSet {
            
            guard let cellType = purchaseCellType else {
                return
            }
            titleLabel1.isHidden = false
            label1.isHidden = false
            titleLabel4.isHidden = false
            label4.isHidden = false
            titleLabel5.isHidden = true
            label5.isHidden = true
            contactBtn1.isHidden = true
            contactBtn2.isHidden = true
            
            titleLabel2.snp.remakeConstraints { (make) in
                make.width.equalTo(60)
                make.left.height.equalTo(titleLabel1)
                make.top.equalTo(label1.snp.bottom).offset(12)
            }
            
            label3.snp.remakeConstraints { (make) in
                make.left.equalTo(titleLabel3.snp.right)
                make.right.equalTo(label1)
                make.top.equalTo(titleLabel3)
                make.height.greaterThanOrEqualTo(15)
            }
            
            label4.snp.remakeConstraints { (make) in
                make.left.equalTo(titleLabel4.snp.right)
                make.right.equalTo(label1)
                make.top.equalTo(titleLabel4)
                make.height.greaterThanOrEqualTo(15)
                make.bottom.equalTo(-15)
            }
            
            contactBtn1.snp.remakeConstraints { (make) in
                make.left.equalTo(titleLabel1)
                make.height.equalTo(30)
                make.width.equalTo(105)
                make.top.equalTo(label5.snp.bottom).offset(12)
            }
            
            switch cellType {
            case .orderInfo:
                
                titleLabel1.snp.remakeConstraints { (make) in
                    make.left.equalTo(15)
                    make.top.equalTo(10)
                    make.height.equalTo(15)
                }
                
                label1.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel1.snp.right)
                    make.right.equalTo(-15)
                    make.top.equalTo(titleLabel1)
                    make.height.greaterThanOrEqualTo(15)
                }
                titleLabel2.snp.remakeConstraints { (make) in
                    make.width.equalTo(60)
                    make.left.height.equalTo(titleLabel1)
                    make.top.equalTo(label1.snp.bottom).offset(12)
                }
                label2.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel2.snp.right)
                    make.right.equalTo(label1)
                    make.top.equalTo(titleLabel2)
                    make.height.greaterThanOrEqualTo(15)
                }
                titleLabel3.snp.remakeConstraints { (make) in
                    make.left.height.equalTo(titleLabel1)
                    make.top.equalTo(label2.snp.bottom).offset(12)
                }
                label3.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel3.snp.right)
                    make.right.equalTo(label1)
                    make.top.equalTo(titleLabel3)
                    make.height.greaterThanOrEqualTo(15)
                }
                
                [titleLabel6, label6].forEach { $0?.removeFromSuperview() }
                
                titleLabel1.text = "订单号: "
                titleLabel2.text = "订单状态: "
                titleLabel3.text = "下单时间: "
                titleLabel4.text = "备注: "
                
                label1.text = "未知"
                label2.text = "未知"
                label3.text = "未知"
                label4.text = "未知"
                label5.text = "未知"
                
                label2.textColor = PublicColor.commonTextColor
                
                if let valueStr = purchaseModel?.orderNo {
                    label1.text = valueStr
                }
                if let valueStr = purchaseModel?.orderStatus?.intValue {
                    
                    let statusStr = Utils.getFieldValInDirArr(arr: AppData.purchaseOrderStatusTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
                    if statusStr.count > 0 {
                        label2.text = statusStr
                    }
                    
                    if valueStr >= 3 {
                        titleLabel5.isHidden = false
                        label5.isHidden = false
                        titleLabel4.text = "发货期限: "
                        titleLabel5.text = "备注: "
                        
                        label4.snp.remakeConstraints { (make) in
                            make.left.equalTo(titleLabel4.snp.right)
                            make.right.equalTo(label1)
                            make.top.equalTo(titleLabel4)
                            make.height.greaterThanOrEqualTo(15)
                        }
                        
                        titleLabel5.snp.remakeConstraints { (make) in
                            make.left.height.equalTo(titleLabel1)
                            make.top.equalTo(label4.snp.bottom).offset(12)
                        }
                        
                        label5.snp.remakeConstraints { (make) in
                            make.left.equalTo(titleLabel5.snp.right)
                            make.right.equalTo(label1)
                            make.top.equalTo(titleLabel5)
                            make.height.greaterThanOrEqualTo(15)
                            make.bottom.equalTo(-15)
                        }
                        
                        if let sendTerm = purchaseModel?.sendTerm {
                            label4.text = "\(sendTerm)"
                        }
                        
                        if let valueStr = purchaseModel?.remarks {
                            if valueStr != "" {
                                label5.text = valueStr
                            }else {
                                label5.text = "无"
                            }
                        }
                    }else {
                        [titleLabel5, label5].forEach {
                            $0?.isHidden = true
                        }
                        titleLabel4.snp.remakeConstraints { (make) in
                            make.left.height.equalTo(titleLabel1)
                            make.top.equalTo(label3.snp.bottom).offset(12)
                        }
                        label4.snp.remakeConstraints { (make) in
                            make.left.equalTo(titleLabel4.snp.right)
                            make.right.equalTo(label1)
                            make.top.equalTo(titleLabel4)
                            make.height.greaterThanOrEqualTo(15)
                            make.bottom.equalTo(-15)
                        }
                        
                        if let valueStr = purchaseModel?.remarks {
                            if valueStr != "" {
                                label4.text = valueStr
                            }else {
                                label4.text = "无"
                            }
                        }
                    }
                }
                label3.text = purchaseModel?.orderTime ?? ""

                
                break
                
            case .contactInfo:
                
                [contactBtn1, contactBtn2, titleLabel5, titleLabel6, titleLabel7, label5, label6, label7].forEach { $0?.isHidden = false }
                
                titleLabel1.text = "采购人: "
                titleLabel2.text = "采购单位: "
                titleLabel3.text = "供应商: "
                titleLabel4.text = "收货人: "
                titleLabel5.text = "手机号: "
                titleLabel6.text = "座机: "
                titleLabel7.text = "地址: "

                label1.text = "未知"
                label2.text = "未知"
                label3.text = "未知"
                label4.text = "未知"
                label5.text = "未知"
                label6.text = "未知"
                label7.text = "未知"
                
                titleLabel1.snp.remakeConstraints { (make) in
                    make.left.equalTo(15)
                    make.top.equalTo(10)
                    make.height.equalTo(15)
                }
                
                label1.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel1.snp.right)
                    make.right.equalTo(-15)
                    make.top.equalTo(titleLabel1)
                    make.height.greaterThanOrEqualTo(15)
                }
                titleLabel2.snp.remakeConstraints { (make) in
                    make.width.equalTo(60)
                    make.left.height.equalTo(titleLabel1)
                    make.top.equalTo(label1.snp.bottom).offset(12)
                }
                label2.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel2.snp.right)
                    make.right.equalTo(label1)
                    make.top.equalTo(titleLabel2)
                    make.height.greaterThanOrEqualTo(15)
                }
                titleLabel3.snp.remakeConstraints { (make) in
                    make.left.height.equalTo(titleLabel1)
                    make.top.equalTo(label2.snp.bottom).offset(12)
                }
                label3.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel3.snp.right)
                    make.right.equalTo(label1)
                    make.top.equalTo(titleLabel3)
                    make.height.greaterThanOrEqualTo(15)
                }
                titleLabel4.snp.remakeConstraints { (make) in
                    make.left.height.equalTo(titleLabel1)
                    make.top.equalTo(label3.snp.bottom).offset(12)
                }
                label4.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel4.snp.right)
                    make.right.equalTo(label1)
                    make.top.equalTo(titleLabel4)
                    make.height.greaterThanOrEqualTo(15)
                }
                titleLabel5.snp.remakeConstraints { (make) in
                    make.left.height.equalTo(titleLabel1)
                    make.top.equalTo(label4.snp.bottom).offset(12)
                }
                label5.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel5.snp.right)
                    make.right.equalTo(label1)
                    make.top.equalTo(titleLabel5)
                    make.height.greaterThanOrEqualTo(15)
                }
                titleLabel6.snp.remakeConstraints { (make) in
                    make.left.height.equalTo(titleLabel1)
                    make.top.equalTo(label5.snp.bottom).offset(12)
                }
                label6.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel6.snp.right)
                    make.right.equalTo(label1)
                    make.top.equalTo(titleLabel6)
                    make.height.greaterThanOrEqualTo(15)
                }
                titleLabel7.snp.remakeConstraints { (make) in
                    make.width.equalTo(35)
                    make.left.height.equalTo(titleLabel1)
                    make.top.equalTo(label6.snp.bottom).offset(12)
                }
                label7.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel7.snp.right)
                    make.right.equalTo(label1)
                    make.top.equalTo(titleLabel7)
                    make.height.greaterThanOrEqualTo(15)
                }
                contactBtn1.snp.remakeConstraints { (make) in
                    make.left.equalTo(titleLabel1)
                    make.height.equalTo(30)
                    make.width.equalTo(105)
                    make.top.equalTo(label7.snp.bottom).offset(12)
                    make.bottom.equalTo(-15)
                }
                
                label3.textColor = PublicColor.commonTextColor
                
                if let valueStr = purchaseModel?.workerName {
                    label1.text = valueStr
                }
                if let valueStr = purchaseModel?.storeName {
                    label2.text = valueStr
                }
                if let valueStr = purchaseModel?.merchantName {
                    label3.text = valueStr
                }
                if let valueStr = purchaseModel?.contact {
                    label4.text = valueStr
                }
                if let valueStr = purchaseModel?.tel {
                    label5.text = valueStr
                }
                if let valueStr = purchaseModel?.expressPhone {
                    label6.text = valueStr
                }
                if let valueStr = purchaseModel?.address {
                    label7.text = valueStr
                }
                break
                
            case .payInfo:
                if UserData.shared.userType == .cgy {
                    titleLabel1.text = "订单金额: "
                    titleLabel2.text = "商品总价: "
                    titleLabel3.text = "服务费: "
                    titleLabel4.text = "服务费备注: "
                    titleLabel5.text = "支付状态: "
                    
                    label1.text = "未知"
                    label2.text = "未知"
                    label3.text = "未知"
                    label4.text = "未知"
                    label5.text = "未知"
                    
                    
                    
                    [titleLabel5, label5].forEach { $0?.isHidden = false }
                    [titleLabel6, label6].forEach { $0?.isHidden = true }
                    
                    if let supplyValue = purchaseModel?.payMoney?.doubleValue {
                        label1.textColor(.red)
                        label1.text = "\((supplyValue).notRoundingString(afterPoint: 2)) 元"
                    }
                    if let supplyValue = purchaseModel?.supplyMoney?.doubleValue {
                        label2.text = "\(supplyValue.notRoundingString(afterPoint: 2)) 元"
                    }
                    
                    label3.text = purchaseModel?.serviceMoney?.doubleValue.notRoundingString(afterPoint: 2)
                    label4.text = purchaseModel?.serviceRemarks ?? "无"
                
                    if let valueStr = purchaseModel?.payStatus {
                        let statusStr = Utils.getFieldValInDirArr(arr: AppData.purchaseOrderPayStatusList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
                        if statusStr.count > 0 {
                            label5.text = statusStr
                        }
                    }
                    
                    label4.snp.remakeConstraints { (make) in
                        make.left.equalTo(titleLabel4.snp.right)
                        make.right.equalTo(label1)
                        make.top.equalTo(titleLabel4)
                        make.height.greaterThanOrEqualTo(15)
                    }
                    
                    titleLabel5.snp.remakeConstraints { (make) in
                        make.top.equalTo(titleLabel4.snp.bottom).offset(12)
                        make.height.equalTo(titleLabel1.snp.height)
                        make.left.equalTo(titleLabel1.snp.left)
                        make.bottom.equalTo(-15)
                    }
                } else {
                    titleLabel1.text = "订单金额: "
                    titleLabel2.text = "商品总价: "
                    titleLabel3.text = "服务费: "
                    titleLabel4.text = "平台服务佣金: "
                    titleLabel4.isHidden = true
                    titleLabel5.text = "支付状态: "
                    titleLabel6.text = "支付时间: "
                    
                    label1.text = "未知"
                    label2.text = "未知"
                    label3.text = "未知"
                    label4.text = "未知"
                    label4.isHidden = true
                    label5.text = "未知"
                    label6.text = "未知"
        
                    if let supplyValue = purchaseModel?.payMoney?.doubleValue {
                        label1.attributedText = ToolsFunc.getMixtureAttributString([MixtureAttr(string: (supplyValue).notRoundingString(afterPoint: 2), color: PublicColor.emphasizeTextColor, font: textFont), MixtureAttr(string: " 元", color: PublicColor.commonTextColor, font: textFont)])
                        label3.text = purchaseModel?.serviceMoney?.doubleValue.notRoundingString(afterPoint: 2)
                        label4.text = "付款时计算"
                    }
                    if let supplyValue = purchaseModel?.supplyMoney?.doubleValue {
                        label2.text = supplyValue.notRoundingString(afterPoint: 2)
                    }
                    
                    
                    
                    if let valueStr = purchaseModel?.payStatus {
                        let statusStr = Utils.getFieldValInDirArr(arr: AppData.purchaseOrderPayStatusList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
                        if statusStr.count > 0 {
                            label5.text = statusStr
                        }
                    }
//                    if let valueStr = purchaseModel?.orderPayTime?.doubleValue {
//                        
//                        let date = Date(timeIntervalSince1970: valueStr/1000)
//                        let dfmatter = DateFormatter()
//                        dfmatter.dateFormat="yyyy/MM/dd HH:mm:ss"
//                        let timeStr = dfmatter.string(from: date)
//                        label6.text = timeStr
//                    }
                    label4.snp.remakeConstraints { (make) in
                        make.left.equalTo(titleLabel4.snp.right)
                        make.right.equalTo(label1)
                        make.top.equalTo(titleLabel4)
                        make.height.greaterThanOrEqualTo(15)
                    }
                    
                    titleLabel5.snp.remakeConstraints { (make) in
                        make.top.equalTo(titleLabel3.snp.bottom).offset(12)
                        make.height.equalTo(titleLabel1.snp.height)
                        make.left.equalTo(titleLabel1.snp.left)
                    }
                    
                    titleLabel6.snp.remakeConstraints { (make) in
                        make.left.equalTo(titleLabel5)
                        make.top.equalTo(titleLabel5.snp.bottom).offset(12)
                        make.height.greaterThanOrEqualTo(15)
                        make.bottom.equalTo(-15)
                    }
                    
                    [titleLabel5, label5].forEach { $0?.isHidden = false }
                    [titleLabel6, label6].forEach { $0?.isHidden = false }
                }
                
                
                break
            }
            
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        createSubView()
    }
    
    func createSubView() {
        titleLabel1 = UILabel()
        titleLabel1.text = "采购人: "
        titleLabel1.textColor = PublicColor.minorTextColor
        titleLabel1.font = textFont
        contentView.addSubview(titleLabel1)
        
        titleLabel1.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.height.equalTo(15)
        }
        
        label1 = UILabel()
        label1.numberOfLines = 0
        label1.text = "未知"
        label1.textColor = PublicColor.commonTextColor
        label1.font = textFont
        contentView.addSubview(label1)
        
        label1.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel1.snp.right)
            make.right.equalTo(-15)
            make.top.equalTo(titleLabel1)
            make.height.greaterThanOrEqualTo(15)
        }
        
        titleLabel2 = UILabel()
        titleLabel2.text = "采购单位: "
        titleLabel2.textColor = PublicColor.minorTextColor
        titleLabel2.font = textFont
        contentView.addSubview(titleLabel2)
        
        titleLabel2.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.left.height.equalTo(titleLabel1)
            make.top.equalTo(label1.snp.bottom).offset(12)
        }
        
        label2 = UILabel()
        label2.numberOfLines = 0
        label2.text = "未知"
        label2.textColor = PublicColor.commonTextColor
        label2.font = textFont
        contentView.addSubview(label2)
        
        label2.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel2.snp.right)
            make.right.equalTo(label1)
            make.top.equalTo(titleLabel2)
            make.height.greaterThanOrEqualTo(15)
        }
        
        titleLabel3 = UILabel()
        titleLabel3.text = "供应商: "
        titleLabel3.textColor = PublicColor.minorTextColor
        titleLabel3.font = textFont
        contentView.addSubview(titleLabel3)
        
        titleLabel3.snp.makeConstraints { (make) in
            make.left.height.equalTo(titleLabel1)
            make.top.equalTo(label2.snp.bottom).offset(12)
        }
        
        label3 = UILabel()
        label3.numberOfLines = 0
        label3.text = "未知"
        label3.textColor = PublicColor.commonTextColor
        label3.font = textFont
        contentView.addSubview(label3)
        
        label3.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel3.snp.right)
            make.right.equalTo(label1)
            make.top.equalTo(titleLabel3)
            make.height.greaterThanOrEqualTo(15)
        }
        
        titleLabel4 = UILabel()
        titleLabel4.text = "收货人: "
        titleLabel4.textColor = PublicColor.minorTextColor
        titleLabel4.font = textFont
        contentView.addSubview(titleLabel4)
        
        titleLabel4.snp.makeConstraints { (make) in
            make.left.height.equalTo(titleLabel1)
            make.top.equalTo(label3.snp.bottom).offset(12)
        }
        
        label4 = UILabel()
        label4.numberOfLines = 0
        label4.text = "未知"
        label4.textColor = PublicColor.commonTextColor
        label4.font = textFont
        contentView.addSubview(label4)
        
        label4.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel4.snp.right)
            make.right.equalTo(label1)
            make.top.equalTo(titleLabel4)
            make.height.greaterThanOrEqualTo(15)
        }
        
        titleLabel5 = UILabel()
        titleLabel5.text = "电话: "
        titleLabel5.textColor = PublicColor.minorTextColor
        titleLabel5.font = textFont
        contentView.addSubview(titleLabel5)
        
        titleLabel5.snp.makeConstraints { (make) in
            make.left.height.equalTo(titleLabel1)
            make.top.equalTo(label4.snp.bottom).offset(12)
        }
        
        label5 = UILabel()
        label5.numberOfLines = 0
        label5.text = "未知"
        label5.textColor = PublicColor.commonTextColor
        label5.font = textFont
        contentView.addSubview(label5)
        
        label5.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel5.snp.right)
            make.right.equalTo(label1)
            make.top.equalTo(titleLabel5)
            make.height.greaterThanOrEqualTo(15)
        }
        
        titleLabel6 = UILabel()
        titleLabel6.text = "地址: "
        titleLabel6.textColor = PublicColor.minorTextColor
        titleLabel6.font = textFont
        contentView.addSubview(titleLabel6)
        
        titleLabel6.snp.makeConstraints { (make) in
            make.left.height.equalTo(titleLabel1)
            make.top.equalTo(label5.snp.bottom).offset(12)
        }
      
        label6 = UILabel()
        label6.numberOfLines = 0
        label6.text = "未知"
        label6.textColor = PublicColor.commonTextColor
        label6.font = textFont
        contentView.addSubview(label6)
        
        label6.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel6.snp.right)
            make.right.equalTo(label1)
            make.top.equalTo(titleLabel6)
            make.height.greaterThanOrEqualTo(15)
        }
        
        
        titleLabel7 = UILabel()
        titleLabel7.isHidden = true
        titleLabel7.text = "地址: "
        titleLabel7.textColor = PublicColor.minorTextColor
        titleLabel7.font = textFont
        contentView.addSubview(titleLabel7)
        
        titleLabel7.snp.makeConstraints { (make) in
            make.left.height.equalTo(titleLabel1)
            make.top.equalTo(label6.snp.bottom).offset(12)
        }
        
        label7 = UILabel()
        label7.isHidden = true
        label7.numberOfLines = 0
        label7.text = "未知"
        label7.textColor = PublicColor.commonTextColor
        label7.font = textFont
        contentView.addSubview(label7)
        
        label7.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel7.snp.right)
            make.right.equalTo(label1)
            make.top.equalTo(titleLabel7)
            make.height.greaterThanOrEqualTo(15)
        }
        
        contactBtn1 = UIButton()
        contactBtn1.layer.borderWidth = 0.5
        contactBtn1.layer.borderColor = PublicColor.orangeLabelColor.cgColor
        contactBtn1.layer.cornerRadius = 4
        contactBtn1.setTitle("联系买家", for: .normal)
        contactBtn1.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        contactBtn1.titleLabel?.sizeToFit()
        contactBtn1.setTitleColor(PublicColor.orangeLabelColor, for: .normal)
        contactBtn1.setTitleColor(PublicColor.minorTextColor, for: .highlighted)
        contentView.addSubview(contactBtn1)
        
        contactBtn1.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel1)
            make.height.equalTo(30)
            make.width.equalTo(105)
            make.top.equalTo(label7.snp.bottom).offset(12)
            make.bottom.equalTo(-15)
        }
        
        contactBtn2 = UIButton()
        contactBtn2.layer.borderWidth = contactBtn1.layer.borderWidth
        contactBtn2.layer.cornerRadius = contactBtn1.layer.cornerRadius
        contactBtn2.setTitle("联系卖家", for: .normal)
        contactBtn2.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        contactBtn2.titleLabel?.sizeToFit()
        contactBtn2.setTitleColor(PublicColor.minorTextColor, for: .highlighted)
        contentView.addSubview(contactBtn2)
        
        if UserData.shared.userType == .yys {
            contactBtn1.set(image: UIImage.init(named: "beginChat_icon"), title: "联系买家", imagePosition: .left, additionalSpacing: 5, state: .normal)
            
            contactBtn2.layer.borderColor = PublicColor.orangeLabelColor.cgColor
            contactBtn2.setTitleColor(PublicColor.orangeLabelColor, for: .normal)
            contactBtn2.set(image: UIImage.init(named: "beginChat_icon"), title: "联系卖家", imagePosition: .left, additionalSpacing: 5, state: .normal)
            
            contactBtn2.snp.makeConstraints { (make) in
                make.left.equalTo(contactBtn1.snp.right).offset(10)
                make.width.height.centerY.equalTo(contactBtn1)
            }
        }else if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            contactBtn1.set(image: UIImage.init(named: "beginChat_icon"), title: "联系买家", imagePosition: .left, additionalSpacing: 5, state: .normal)
            
            contactBtn2.layer.borderColor = PublicColor.greenLabelColor.cgColor
            contactBtn2.setTitleColor(PublicColor.greenLabelColor, for: .normal)
            contactBtn2.set(image: UIImage.init(named: "phone_icon"), title: "拨打买家电话", imagePosition: .left, additionalSpacing: 5, state: .normal)
            
            contactBtn2.snp.makeConstraints { (make) in
                make.left.equalTo(contactBtn1.snp.right).offset(10)
                make.height.centerY.equalTo(contactBtn1)
                make.width.equalTo(135)
            }
        }else if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
            contactBtn1.set(image: UIImage.init(named: "beginChat_icon"), title: "联系卖家", imagePosition: .left, additionalSpacing: 5, state: .normal)
            
            contactBtn2.layer.borderColor = PublicColor.greenLabelColor.cgColor
            contactBtn2.setTitleColor(PublicColor.greenLabelColor, for: .normal)
            contactBtn2.set(image: UIImage.init(named: "phone_icon"), title: "拨打卖家电话", imagePosition: .left, additionalSpacing: 5, state: .normal)
            
            contactBtn2.snp.makeConstraints { (make) in
                make.left.equalTo(contactBtn1.snp.right).offset(10)
                make.height.centerY.equalTo(contactBtn1)
                make.width.equalTo(135)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
