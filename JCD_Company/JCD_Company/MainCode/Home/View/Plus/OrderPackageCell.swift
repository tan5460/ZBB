//
//  OrderPackageCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 16.11.2018.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class OrderPackageCell: UITableViewCell {

    var roomTitleLabel: UILabel!                //房间名
    var signView: UIView!                       //选中标记
    var selIcon: UIImageView!                   //已选标记
    
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
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //房间标题
        roomTitleLabel = UILabel()
        roomTitleLabel.text = "房间名"
        roomTitleLabel.numberOfLines = 2
        roomTitleLabel.textColor = PublicColor.commonTextColor
        roomTitleLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(roomTitleLabel)
        
        roomTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            make.right.lessThanOrEqualTo(-12)
        }
        
        //选中标记
        signView = UIView()
        signView.backgroundColor = PublicColor.emphasizeTextColor
        contentView.addSubview(signView)
        
        signView.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.width.equalTo(2)
            make.height.equalTo(40)
        }
        
        //已选标记
        selIcon = UIImageView()
        selIcon.image = UIImage.init(named: "order_room_sel")
        contentView.addSubview(selIcon)
        
        selIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(roomTitleLabel)
            make.width.height.equalTo(8)
            make.left.equalTo(roomTitleLabel.snp.right).offset(2)
        }
    }
}
