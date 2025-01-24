//
//  BacklogCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class BacklogCell: UITableViewCell {
    
    lazy var orderNoLabel: UILabel = {
        let orderL = UILabel()
        orderL.textColor = PublicColor.commonTextColor
        orderL.font = UIFont.systemFont(ofSize: 14.0)
        return orderL
    }()
    
    lazy var procurementLabel: UILabel = {
        let pL = UILabel()
        pL.textColor = PublicColor.commonTextColor
        pL.font = UIFont.systemFont(ofSize: 15.0)
        return pL
    }()
    
    lazy var supplierLabel: UILabel = {
        let supplier = UILabel()
        supplier.textColor = PublicColor.commonTextColor
        supplier.font = UIFont.systemFont(ofSize: 15.0)
        return supplier
    }()
    
    lazy var alertLabel: UILabel = {
        let alertL = UILabel()
        alertL.font = UIFont.systemFont(ofSize: 13.0)
        alertL.textColor = PublicColor.minorTextColor
        return alertL
    }()
    
    lazy var timeLabel: UILabel = {
        let timeL = UILabel()
        timeL.font = UIFont.systemFont(ofSize: 13.0)
        timeL.textColor = PublicColor.minorTextColor
        return timeL
    }()
    
    lazy var badgeLabel: UILabel = {
        let badgeL = UILabel()
        badgeL.isHidden = true
        badgeL.backgroundColor = PublicColor.unreadMsgColor
        badgeL.layer.cornerRadius = 3
        badgeL.layer.masksToBounds = true
        return badgeL
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = PublicColor.partingLineColor
        return line
    }()
    
    var model: BacklogModel? {
        didSet {
            orderNoLabel.text = "订单号："
            procurementLabel.text = "采购单位："
            supplierLabel.text = ""
            alertLabel.text = ""
            timeLabel.text = ""
            
            if UserData.shared.userType == .cgy {
                procurementLabel.text = "供应商："
            }
            
            if let orderNo = model?.orderNo {
                orderNoLabel.text = "订单号：" + orderNo
            }
            
            if let isRead = model?.isRead?.boolValue {
                badgeLabel.isHidden = !isRead
            }
            
            
            if UserData.shared.userType == .cgy {
                procurementLabel.snp.updateConstraints { (make) in
                    make.top.equalTo(lineView.snp.bottom).offset(14)
                }
                if let comName = model?.merchantName {
                    procurementLabel.text = "供应商：" + comName
                }
                if model?.orderType == 1 { // 客户订单存在多个供应商的商品下单，这里无法确定，隐藏掉供应商
                    procurementLabel.isHidden = true
                } else {
                    procurementLabel.isHidden = false
                }
            }else {
                if let comName = model?.storeName {
                    procurementLabel.text = "采购单位：" + comName
                } else if let comName = model?.storeContacts {
                    procurementLabel.text = "采购单位：" + comName
                }
            }
            
            if UserData.shared.userType == .yys {
                if let mName = model?.storeName {
                    supplierLabel.text = "供应商：" + mName
                }
            }
            
            if let message = model?.message {
                alertLabel.text = message
            }
            
            timeLabel.text = model?.createTime ?? ""
        }
    }
    
    // MARK:- init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- 初始化
    func createSubView() {
        
        let line = UIView()
        line.backgroundColor = PublicColor.backgroundViewColor
        self.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(10)
        }
        
        self.addSubview(orderNoLabel)
        orderNoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(14)
            make.top.equalTo(line.snp.bottom).offset(13)
            make.height.greaterThanOrEqualTo(13)
            make.right.equalTo(-20)
        }
        
        self.addSubview(badgeLabel)
        badgeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-14)
            make.centerY.equalTo(orderNoLabel)
            make.width.height.equalTo(6)
        }
        
        self.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(orderNoLabel.snp.bottom).offset(13)
            make.height.equalTo(0.5)
        }
        
        self.addSubview(procurementLabel)
        procurementLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(orderNoLabel)
            make.top.equalTo(lineView.snp.bottom).offset(14)
        }
        
        self.addSubview(supplierLabel)
        supplierLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(orderNoLabel)
            make.top.equalTo(procurementLabel.snp.bottom).offset(5)
        }
        
        self.addSubview(alertLabel)
        alertLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(orderNoLabel)
            make.top.equalTo(supplierLabel.snp.bottom).offset(14)
            make.height.greaterThanOrEqualTo(15)
        }
        
        self.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(orderNoLabel)
            make.top.equalTo(alertLabel.snp.bottom).offset(14)
            make.height.greaterThanOrEqualTo(13)
            make.bottom.equalTo(-18)
        }
     
    }
}
