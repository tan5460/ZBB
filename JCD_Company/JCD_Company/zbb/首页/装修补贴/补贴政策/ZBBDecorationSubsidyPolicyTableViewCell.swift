//
//  ZBBDecorationSubsidyPolicyTableViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/7.
//

import UIKit

class ZBBDecorationSubsidyPolicyTableViewCell: UITableViewCell {

    var policyTitle: String? {
        didSet {
            nameLabel.text = policyTitle
        }
    }
    
    private var containerView: UIView!
    private var leftIcon: UIImageView!
    private var nameLabel: UILabel!
    private var rightIcon: UIImageView!
    
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
        
        
        leftIcon = UIImageView(image: UIImage(named: "zbbt_subsidy_left"))
        containerView.addSubview(leftIcon)
        leftIcon.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 13, weight: .medium)
        nameLabel.textColor = .hexColor("#131313")
        nameLabel.numberOfLines = 0
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(45)
            make.right.equalTo(-37)
            make.height.greaterThanOrEqualTo(36)
            make.bottom.equalTo(-15)
        }
        
        rightIcon = UIImageView(image: UIImage(named: "zbbt_subsidy_right"))
        containerView.addSubview(rightIcon)
        rightIcon.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(12)
            make.height.equalTo(15)
        }
    }

}
