//
//  ZBBPlatformDelegationCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/27.
//

import UIKit

class ZBBPlatformDelegationCell: UITableViewCell {

    var model: ZBBPlatformDelegationOrderModel? {
        didSet {
            nameLabel.text = model?.serviceMerchantName
            userLabel.text = "客户：" + (model?.customerName ?? "")
            priceLabel.text = String(format: "总费用：¥%.2f", CGFloat(model?.totalAmount ?? 0)/100.0)
            areaLabel.text = "小区：" + (model?.communityName ?? "")
            houseLabel.text = "房号：" + (model?.buildNo ?? "")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }
    
    
    
    private var containerView: UIView!
    
    private var icon: UIImageView!
    private var nameLabel: UILabel!
    
    private var userLabel: UILabel!
    private var priceLabel: UILabel!
    private var areaLabel: UILabel!
    private var houseLabel: UILabel!
    
    
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
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(0)
        }
        
        icon = UIImageView(image: UIImage(named: "zbb_bt_record_icon"))
        containerView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.left.equalTo(10)
            make.width.height.equalTo(18)
        }
        
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        nameLabel.textColor = .hexColor("#131313")
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(icon.snp.right).offset(2)
            make.centerY.equalTo(icon)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(12)
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
            make.bottom.equalTo(-10)
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
    }

}
