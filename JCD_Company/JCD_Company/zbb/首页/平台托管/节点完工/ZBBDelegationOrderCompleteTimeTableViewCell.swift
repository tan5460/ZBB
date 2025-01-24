//
//  ZBBDelegationOrderCompleteTimeTableViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit

class ZBBDelegationOrderCompleteTimeTableViewCell: UITableViewCell {

    var leftLabel: UILabel!
    var rightLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }
    
    private func createViews() {
        selectionStyle = .none
        backgroundColor = .white
        
        let topLine = UIView()
        topLine.backgroundColor = .hexColor("#F0F0F0")
        contentView.addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }
        
        leftLabel = UILabel()
        leftLabel.font = .systemFont(ofSize: 14)
        leftLabel.textColor = .hexColor("#131313")
        contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.height.equalTo(20)
            make.bottom.equalTo(-15)
        }
        
        rightLabel = UILabel()
        rightLabel.font = .systemFont(ofSize: 14, weight: .medium)
        rightLabel.textColor = .hexColor("#131313")
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.right.equalTo(-15)
            make.centerY.equalTo(contentView)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = .hexColor("#F0F0F0")
        contentView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
            make.bottom.equalTo(0)
        }
    }

}
