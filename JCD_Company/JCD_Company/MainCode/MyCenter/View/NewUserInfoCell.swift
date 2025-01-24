//
//  NewUserInfoCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/9.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class NewUserInfoCell: UITableViewCell {

    var leftLabel : UILabel!
    var rightLabel : UILabel!
    var arrowImgView : UIImageView!
    var line:UIView!
    
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
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func createSubView() {
        
        //左边label
        leftLabel = UILabel()
        leftLabel.text = "头像"
        leftLabel.textColor = PublicColor.commonTextColor
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(leftLabel)
        
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        //箭头
        arrowImgView = UIImageView()
        arrowImgView.image = UIImage(named: "arrow_right")
        arrowImgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(arrowImgView)
        
        arrowImgView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(14)
            make.width.equalTo(7)
            make.top.equalToSuperview().offset(17)
            make.bottom.equalToSuperview().offset(-17)
        }
        
        //右边label
        rightLabel = UILabel()
        rightLabel.text = ""
        rightLabel.textAlignment = .right
        rightLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xB3B3B3)
        rightLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(rightLabel)
        
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(arrowImgView.snp.left).offset(-8)
            make.width.equalTo(200)
            make.height.greaterThanOrEqualTo(11)
        }
        
        line = UIView()
        line.backgroundColor = PublicColor.partingLineColor
        self.contentView.addSubview(line)
        
        line.snp.makeConstraints { (make) in
            make.right.equalTo(arrowImgView.snp.right)
            make.height.equalTo(0.5)
            make.left.equalTo(leftLabel.snp.left)
            make.bottom.equalToSuperview()
        }
        
    }
}
