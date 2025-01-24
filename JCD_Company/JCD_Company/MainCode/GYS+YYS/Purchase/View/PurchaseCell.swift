//
//  PurchaseCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 10.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class PurchaseCell: UITableViewCell {

    @IBOutlet weak var orderNoLabel: UILabel!           //订单号
    @IBOutlet weak var orderStateLabel: UILabel!        //订单状态
    @IBOutlet weak var timeLabel: UILabel!              //时间
    @IBOutlet weak var storeTitleLabel: UILabel!        //采购公司标题
    @IBOutlet weak var storeNameLabel: UILabel!         //采购公司
    @IBOutlet weak var merchantTitleLabel: UILabel!     //供应商标题
    @IBOutlet weak var merchantLabel: UILabel!          //供应商
    @IBOutlet weak var addressLabel: UILabel!           //地址
    @IBOutlet weak var moneyTitleLabel: UILabel!        //订单金额标题
    @IBOutlet weak var payMoneyLabel: UILabel!          //支付金额
    @IBOutlet weak var referTitleLabel: UILabel!        //平台金额标题
    @IBOutlet weak var referMoneyLabel: UILabel!        //平台金额
    
    var puechaseOrderModel: PurchaseOrderModel? {
        
        didSet {
            orderNoLabel.text = "订单号: 未知"
            orderStateLabel.text = "未知"
            timeLabel.text = "未知"
            storeNameLabel.text = "未知"
            merchantLabel.text = "未知"
            addressLabel.text = "未知"
            payMoneyLabel.text = "未知"
            referMoneyLabel.text = "未知"
            
            if let valueStr = puechaseOrderModel?.orderNo {
                orderNoLabel.text = "订单号: \(valueStr)"
            }
            if let valueStr = puechaseOrderModel?.orderStatus {
                
                let statusStr = Utils.getFieldValInDirArr(arr: AppData.purchaseOrderStatusTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
                if statusStr.count > 0 {
                    orderStateLabel.text = " \(statusStr)  "
                }
                
                if valueStr == 8 {
                    orderStateLabel.backgroundColor = PublicColor.redLabelColor
                }else if valueStr == 6 || valueStr == 7 {
                    orderStateLabel.backgroundColor = PublicColor.greenLabelColor
                }else {
                    orderStateLabel.backgroundColor = PublicColor.orangeLabelColor
                }
            }
            timeLabel.text = puechaseOrderModel?.orderTime?.replacingOccurrences(of: "T", with: " ")

            if let valueStr = puechaseOrderModel?.address {
                addressLabel.text = valueStr
            }
            if let valueStr = puechaseOrderModel?.storeName {
                storeNameLabel.text = valueStr
            }
            if let costValue = puechaseOrderModel?.payMoney?.doubleValue {
                payMoneyLabel.text = costValue.notRoundingString(afterPoint: 2) + "元"
            }
            if let valueStr = puechaseOrderModel?.payMoney?.doubleValue {
                referMoneyLabel.text = valueStr.notRoundingString(afterPoint: 2) + "元"
            }
            
            switch UserData.shared.userType {
            case .jzgs, .cgy:
                if puechaseOrderModel?.orderStatus?.intValue ?? 0 > 3 && puechaseOrderModel?.orderStatus?.intValue ?? 0 < 7 {
                    if let valueStr = puechaseOrderModel?.payMoney?.doubleValue {
                        payMoneyLabel.text = valueStr.notRoundingString(afterPoint: 2) + "元"
                    }
                } else {
                    if let supplyValue = puechaseOrderModel?.payMoney?.doubleValue {
                        payMoneyLabel.text = (supplyValue).notRoundingString(afterPoint: 2) + "元"
                    }
                }
                
                referMoneyLabel.text = puechaseOrderModel?.contact ?? "未知"
                merchantLabel.text = puechaseOrderModel?.tel ?? "未知"
                storeNameLabel.text = puechaseOrderModel?.merchantName ?? "未知"

            case .gys:
                merchantLabel.text = puechaseOrderModel?.contact ?? "未知"
                if referMoneyLabel.text!.contains("元") == false {
                    referMoneyLabel.text = referMoneyLabel.text! + "元"
                }
            case .yys:
                merchantLabel.text = puechaseOrderModel?.merchant?.name ?? "未知"
                merchantLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(merchantTitleLabel.snp.right).offset(5)
                    make.centerY.equalTo(merchantTitleLabel)
                }
            case .fws:
                merchantLabel.text = puechaseOrderModel?.contact ?? "未知"
                if referMoneyLabel.text!.contains("元") == false {
                    referMoneyLabel.text = referMoneyLabel.text! + "元"
                }
            }
        }
    }
    
    
    @IBOutlet weak var referConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        orderStateLabel.layer.cornerRadius = 4
        orderStateLabel.layer.masksToBounds = true
        
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            referConstraint.constant = 50
            storeTitleLabel.text = "品牌商:"
            if UserData.shared.userType == .cgy {
                storeTitleLabel.text = "供应商:"
            }
            moneyTitleLabel.text = "订单金额: "
            referTitleLabel.text = "客户名: "
            merchantTitleLabel.text = "电话: "
        case .gys:
            storeTitleLabel.text = "采购公司:"
            moneyTitleLabel.text = "订单金额: "
            referTitleLabel.text = "销售订单金额: "
            referTitleLabel.isHidden = true
            referMoneyLabel.isHidden = true
            merchantTitleLabel.text = "收货人: "
            referConstraint.constant = 90
        case .yys:
            storeTitleLabel.text = "采购公司:"
            moneyTitleLabel.text = "订单金额: "
            referTitleLabel.text = "销售订单金额: "
            referTitleLabel.isHidden = true
            referMoneyLabel.isHidden = true
            merchantTitleLabel.text = "供应商: "
           // referConstraint.constant = 5
        case .fws:
            storeTitleLabel.text = "采购公司:"
            moneyTitleLabel.text = "订单金额: "
            referTitleLabel.text = "销售订单金额: "
            referTitleLabel.isHidden = true
            referMoneyLabel.isHidden = true
            merchantTitleLabel.text = "收货人: "
            referConstraint.constant = 90
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
