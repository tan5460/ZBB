//
//  OrderRecordCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/12.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

class OrderRecordCell: UITableViewCell {

    var nameLabel: UILabel!
    var timeLabel: UILabel!
    var moneyLabel: UILabel!
    var lineView: UIView!
    
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
        
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //图标
        let iconView = UIImageView()
        iconView.image = UIImage.init(named: "order_money")
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)
        
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        }
        
        //订单名
        nameLabel = UILabel()
        nameLabel.text = "订单名"
        nameLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x4D4D4D)
        nameLabel.font = UIFont .systemFont(ofSize: 14)
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.top)
            make.left.equalTo(iconView.snp.right).offset(13)
        }
        
        //时间
        timeLabel = UILabel()
        timeLabel.text = "2018-00-00 00:00"
        timeLabel.textColor = PublicColor.placeholderTextColor
        timeLabel.font = UIFont .systemFont(ofSize: 12)
        contentView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconView.snp.bottom)
            make.left.equalTo(nameLabel)
        }
        
        //金额
        moneyLabel = UILabel()
        moneyLabel.text = "+0"
        moneyLabel.textColor = PublicColor.emphasizeTextColor
        moneyLabel.font = UIFont .systemFont(ofSize: 15)
        contentView.addSubview(moneyLabel)
        
        moneyLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-17)
        }
        
        //分割线
        lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(nameLabel)
        }
    }

}
