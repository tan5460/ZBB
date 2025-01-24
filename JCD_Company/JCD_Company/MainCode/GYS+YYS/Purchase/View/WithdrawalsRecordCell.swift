//
//  WithdrawalsRecordCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 25.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class WithdrawalsRecordCell: UITableViewCell {

    var topLineVie: UIView!
    var timeLabel: UILabel!
    var bankNameLabel: UILabel!
    var bankNoLabel: UILabel!
    var moneyLabel: UILabel!
    var statusLabel: UILabel!
    
    var recordModel: WithdrawalsRecordModel? {
        didSet {
            
            timeLabel.text = "2000/01/01 00:00:00"
            bankNameLabel.text = "交易号: "
            bankNoLabel.text = "****  ****  ****  ****"
            moneyLabel.text = "0.00"
            statusLabel.text = ""
            statusLabel.textColor = PublicColor.placeholderTextColor
            
            if let valueStr = recordModel?.createTime {
                timeLabel.text = valueStr
            }
          
            if let valueStr = recordModel?.orderNo {
                bankNoLabel.text = "\(valueStr)"
            }
            if let valueStr = recordModel?.operAmount?.doubleValue {
                moneyLabel.text = "\(valueStr.notRoundingString(afterPoint: 2))"
            }
            if let valueStr = recordModel?.status {
                
                if valueStr == "succeeded" || valueStr == "paid" {
                    statusLabel.text = "成功"
                    statusLabel.textColor = PublicColor.placeholderTextColor
                } else if valueStr == "pending" || valueStr == "created" {
                    statusLabel.text = "已受理"
                    statusLabel.textColor = PublicColor.greenLabelColor
                } else {
                    statusLabel.text = "失败"
                    statusLabel.textColor = PublicColor.redLabelColor
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //上分割线
        topLineVie = UIView()
        topLineVie.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(topLineVie)
        
        topLineVie.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //时间
        timeLabel = UILabel()
        timeLabel.text = "2000/01/01 00:00:00"
        timeLabel.textColor = PublicColor.minorTextColor
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(12)
            make.left.equalTo(15)
        }
        
        //金额
        moneyLabel = UILabel()
        moneyLabel.text = "0.00"
        moneyLabel.textColor = PublicColor.emphasizeColor
        moneyLabel.font = timeLabel.font
        contentView.addSubview(moneyLabel)
        
        moneyLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeLabel)
            make.right.equalTo(-15)
        }
        
        //银行名
        bankNameLabel = UILabel()
        bankNameLabel.text = "银行名称"
        bankNameLabel.textColor = PublicColor.placeholderTextColor
        bankNameLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(bankNameLabel)
        
        bankNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel)
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
        }
        
        //银行卡号
        bankNoLabel = UILabel()
        bankNoLabel.text = " (****  ****  ****  ****)"
        bankNoLabel.textColor = bankNameLabel.textColor
        bankNoLabel.font = bankNameLabel.font
        contentView.addSubview(bankNoLabel)
        
        bankNoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bankNameLabel.snp.right)
            make.centerY.equalTo(bankNameLabel)
        }
        
        //状态
        statusLabel = UILabel()
        statusLabel.text = ""
        statusLabel.textColor = bankNameLabel.textColor
        statusLabel.font = bankNameLabel.font
        contentView.addSubview(statusLabel)
        
        statusLabel.snp.makeConstraints { (make) in
            make.right.equalTo(moneyLabel)
            make.centerY.equalTo(bankNameLabel)
        }
        
        //下分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}
