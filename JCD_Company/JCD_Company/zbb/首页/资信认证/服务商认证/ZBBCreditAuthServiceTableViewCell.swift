//
//  ZBBCreditAuthServiceTableViewCell.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit

class ZBBCreditAuthServiceTableViewCell: UITableViewCell {

    var nameText: String? {
        didSet {
            nameLabel.text = nameText
        }
    }
    
    private var nameLabel: UILabel!
    
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
        
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = .hexColor("#131313")
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.height.equalTo(20)
            make.bottom.equalTo(-15)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        contentView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
}
