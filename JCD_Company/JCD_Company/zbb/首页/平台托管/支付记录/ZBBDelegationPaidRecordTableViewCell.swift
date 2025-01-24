//
//  ZBBDelegationPaidRecordTableViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit

class ZBBDelegationPaidRecordTableViewCell: UITableViewCell {

    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var timeLabel: UILabel!
    private var priceLabel: UILabel!
    private var statusLabel: UILabel!
    
    var model: ZBBOrderPayRecordModel? {
        didSet {
            titleLabel.text = model?.nodeName
            timeLabel.text = model?.transactionTime
            priceLabel.text = String(format: "-¥%.2f", CGFloat(model?.transactionAmount ?? 0)/100.0)
            
            let status = model?.settlementStatus ?? "0"
            if status == "1" {
                statusLabel.text = "已结算"
                statusLabel.textColor = .hexColor("#131313")
            } else if status == "2" {
                statusLabel.text = "已退款"
                statusLabel.textColor = .hexColor("#131313")
            } else {
                statusLabel.text = "待结算"
                statusLabel.textColor = .hexColor("#F1670B")
            }
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }
    
    private func createViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(0)
        }

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.equalTo(24)
        }

        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .hexColor("#999999")
        containerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalTo(titleLabel)
            make.height.equalTo(18)
            make.bottom.equalTo(-15)
        }

        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 17, weight: .medium)
        priceLabel.textColor = .hexColor("#131313")
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(24)
        }

        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 13)
        statusLabel.textColor = .hexColor("#F1670B")
        containerView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.right.equalTo(-15)
            make.height.equalTo(18)
        }
    }

}
