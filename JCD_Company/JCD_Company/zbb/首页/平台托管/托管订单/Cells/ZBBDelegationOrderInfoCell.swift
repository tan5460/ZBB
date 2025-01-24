//
//  ZBBDelegationOrderInfoCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/28.
//

import UIKit

class ZBBDelegationOrderInfoCell: UITableViewCell {

    private var statusIcon: UIImageView!
    private var statusLabel: UILabel!
    private var timeLabel: UILabel!
    private var detailBtn: UIButton!
    
    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var userLabel: UILabel!
    private var priceLabel: UILabel!
    private var areaLabel: UILabel!
    private var houseLabel: UILabel!
    private var protocolBtn: UIButton!
    
    
    var model: ZBBPlatformDelegationOrderModel? {
        didSet {
            //
            let status = model?.orderStatus ?? "1"
            switch status {
            case "1":
                statusIcon.image = UIImage(named: "zbbt_dqy")
                statusLabel.text = "待签约"
            case "2":
                statusIcon.image = UIImage(named: "zbbt_tgz")
                statusLabel.text = "托管中"
            case "3":
                statusIcon.image = UIImage(named: "zbbt_ywc")
                statusLabel.text = "已完成"
            case "4":
                statusIcon.image = UIImage(named: "zbbt_yzz")
                statusLabel.text = "已终止"
            case "5":
                statusIcon.image = UIImage(named: "zbbt_ssz")
                statusLabel.text = "申诉中"
            default:
                break
            }
            
            //
            timeLabel.text = "创建时间：" + (model?.createDate ?? "")
            
            
            titleLabel.text = "服务商：" + (model?.serviceMerchantName ?? "")
            userLabel.text = "客户：" + (model?.customerName ?? "")
            priceLabel.text = String(format: "总费用：¥%.2f", CGFloat(model?.totalAmount ?? 0)/100.0)
            areaLabel.text = "小区：" + (model?.communityName ?? "")
            houseLabel.text = "房号：" + (model?.buildNo ?? "")
        }
    }
    
    var detailBtnActionClosure: (() -> Void)?
    var protocolBtnActionClosure: (() -> Void)?
    
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
        
        statusIcon = UIImageView()
        contentView.addSubview(statusIcon)
        statusIcon.snp.makeConstraints { make in
            make.top.equalTo(18)
            make.left.equalTo(20)
            make.width.height.equalTo(30)
        }

        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 20, weight: .medium)
        statusLabel.textColor = .hexColor("#131313")
        contentView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(statusIcon.snp.right).offset(10)
            make.height.equalTo(28)
        }

        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .hexColor("#666666")
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(2)
            make.left.equalTo(statusLabel)
            make.height.equalTo(16)
        }

        detailBtn = UIButton(type: .custom)
        detailBtn.layer.cornerRadius = 7
        detailBtn.layer.masksToBounds = true
        detailBtn.backgroundColor = .white
        detailBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        detailBtn.setTitle("详细信息", for: .normal)
        detailBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        detailBtn.addTarget(self, action: #selector(detailBtnAction(_:)), for: .touchUpInside)
        contentView.addSubview(detailBtn)
        detailBtn.snp.makeConstraints { make in
            make.centerY.equalTo(statusIcon)
            make.width.equalTo(75)
            make.height.equalTo(34)
            make.right.equalTo(-20)
        }
        
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(15)
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
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(0.5)
        }

        userLabel = UILabel()
        userLabel.font = .systemFont(ofSize: 13)
        userLabel.textColor = .hexColor("#131313")
        containerView.addSubview(userLabel)
        userLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
            make.height.equalTo(18)
        }

        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 13)
        priceLabel.textColor = .hexColor("#131313")
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.left.equalTo(containerView.snp.centerX).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(18)
        }

        areaLabel = UILabel()
        areaLabel.font = .systemFont(ofSize: 13)
        areaLabel.textColor = .hexColor("#131313")
        containerView.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { make in
            make.top.equalTo(userLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
            make.height.equalTo(18)
        }

        houseLabel = UILabel()
        houseLabel.font = .systemFont(ofSize: 13)
        houseLabel.textColor = .hexColor("#131313")
        containerView.addSubview(houseLabel)
        houseLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.left.equalTo(containerView.snp.centerX).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(18)
        }

        protocolBtn = UIButton(type: .custom)
        protocolBtn.layer.cornerRadius = 20
        protocolBtn.layer.masksToBounds = true
        protocolBtn.backgroundColor = .hexColor("#007E41")
        protocolBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        protocolBtn.setTitle("查看协议/签约", for: .normal)
        protocolBtn.setTitleColor(.white, for: .normal)
        protocolBtn.addTarget(self, action: #selector(protocolBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(protocolBtn)
        protocolBtn.snp.makeConstraints { make in
            make.top.equalTo(areaLabel.snp.bottom).offset(20)
            make.centerX.equalTo(containerView)
            make.height.equalTo(40)
            make.width.equalTo(240)
            make.bottom.equalTo(-10)
        }
    }
    
    @objc private func detailBtnAction(_ sender: UIButton) {
        self.detailBtnActionClosure?()
    }
    
    @objc private func protocolBtnAction(_ sender: UIButton) {
        self.protocolBtnActionClosure?()
    }
}
