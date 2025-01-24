//
//  ZBBDelegationOrderPaidChangedTableViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit

class ZBBDelegationOrderPaidChangedTableViewCell: UITableViewCell {

    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var statusLabel: UILabel!
    
    private var rateLabel: UILabel!
    private var paidLabel: UILabel!
    private var addFeeLabel: UILabel!
    private var waitPayLabel: UILabel!
    private var addFeeDescLabel: UILabel!

    private var payBtn: UIButton!
    
    
    var model: ZBBOrderWaitPayNodeModel? {
        didSet {
            titleLabel.text = model?.nodeName
            
            rateLabel.text = "付款比例：" + "\(model?.nodeRatio ?? 0)%"
            paidLabel.text = String(format: "付款金额：%.2f", CGFloat(model?.paidAmount ?? 0)/100.0)
            addFeeLabel.text = String(format: "增项费用：%.2f", CGFloat(model?.additionalAmount ?? 0)/100.0)
            waitPayLabel.text = String(format: "待付金额：%.2f", CGFloat(model?.waitPayAmount ?? 0)/100.0)
            addFeeDescLabel.text = model?.additionalRemarks
        }
    }
    
    var payBtnActionClosure: (() -> Void)?
    
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
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.lessThanOrEqualTo(-10)
            make.height.equalTo(22)
        }
        
        statusLabel = UILabel()
        statusLabel.text = "待支付"
        statusLabel.font = .systemFont(ofSize: 15, weight: .medium)
        statusLabel.textColor = .hexColor("")
        containerView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-10)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(0.5)
        }
        
        rateLabel = UILabel()
        rateLabel.font = .systemFont(ofSize: 13)
        rateLabel.textColor = .hexColor("#131313")
        containerView.addSubview(rateLabel)
        rateLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
            make.height.equalTo(18)
        }

        paidLabel = UILabel()
        paidLabel.font = .systemFont(ofSize: 13)
        paidLabel.textColor = .hexColor("#131313")
        containerView.addSubview(paidLabel)
        paidLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.left.equalTo(containerView.snp.centerX).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(18)
        }

        addFeeLabel = UILabel()
        addFeeLabel.font = .systemFont(ofSize: 13)
        addFeeLabel.textColor = .hexColor("#131313")
        containerView.addSubview(addFeeLabel)
        addFeeLabel.snp.makeConstraints { make in
            make.top.equalTo(rateLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
            make.height.equalTo(18)
        }

        waitPayLabel = UILabel()
        waitPayLabel.font = .systemFont(ofSize: 13)
        waitPayLabel.textColor = .hexColor("#131313")
        containerView.addSubview(waitPayLabel)
        waitPayLabel.snp.makeConstraints { make in
            make.top.equalTo(paidLabel.snp.bottom).offset(10)
            make.left.equalTo(containerView.snp.centerX).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(18)
        }

        addFeeDescLabel = UILabel()
        addFeeDescLabel.font = .systemFont(ofSize: 13)
        addFeeDescLabel.textColor = .hexColor("#131313")
        containerView.addSubview(addFeeDescLabel)
        addFeeDescLabel.snp.makeConstraints { make in
            make.top.equalTo(addFeeLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(18)
        }
        
       

        let btnTopLine = UIView()
        btnTopLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(btnTopLine)
        btnTopLine.snp.makeConstraints { make in
            make.top.equalTo(addFeeDescLabel.snp.bottom).offset(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(0.5)
        }

        payBtn = UIButton(type: .custom)
        payBtn.backgroundColor = .white
        payBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        payBtn.setTitle("立即支付", for: .normal)
        payBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        payBtn.addTarget(self, action: #selector(payBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(payBtn)
        payBtn.snp.makeConstraints { make in
            make.top.equalTo(btnTopLine.snp.bottom)
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50)
        }
    }
    
    @objc private func payBtnAction(_ sender: UIButton) {
        payBtnActionClosure?()
    }
}
