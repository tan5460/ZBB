//
//  MyInviteCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/29.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

class MyInviteCell: UITableViewCell {

    var timeLabel: UILabel!                 //时间
    var nameLabel: UILabel!                 //姓名
    var integralLabel: UILabel!             //奖励积分
    
    var workerModel: WorkerModel? {
        
        didSet {
            
            timeLabel.text = "2000-01-01"
            nameLabel.text = "辅导xxx的奖励积分"
            integralLabel.text = "0"
            
            if let valueStr = workerModel?.createDate {
                let detaStr = valueStr.stringToDateStr()
                timeLabel.text = detaStr
            }
            
            if let valueStr = workerModel?.realName {
                nameLabel.text = "辅导\(valueStr)的奖励积分"
            }
            
            if let valueStr = workerModel?.bonusPoint {
                
                //初始化NumberFormatter
                let format = NumberFormatter()
                //设置numberStyle(有多种格式)
                format.numberStyle = .decimal
                //转换后的string
                let newValue = format.string(from: valueStr)
                integralLabel.text = newValue
            }
        }
    }
    
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
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //白色背景
        let backView = UIView()
        backView.backgroundColor = .white
        contentView.addSubview(backView)
        
        backView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-5)
        }
        
        //时间
        timeLabel = UILabel()
        timeLabel.text = "2000-01-01"
        timeLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xBFBFBF)
        timeLabel.font = UIFont.systemFont(ofSize: 10)
        backView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
        }
        
        //姓名
        nameLabel = UILabel()
        nameLabel.text = "辅导xxx的奖励积分"
        nameLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x4D4D4D)
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        backView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(timeLabel)
            make.top.equalTo(timeLabel.snp.bottom).offset(8)
        }
        
        //积分
        integralLabel = UILabel()
        integralLabel.text = "0"
        integralLabel.textColor = PublicColor.minorTextColor
        integralLabel.font = UIFont.systemFont(ofSize: 14)
        backView.addSubview(integralLabel)
        
        integralLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.centerY.equalTo(nameLabel)
        }
        
        //积分单位
        let integralIcon = UIImageView()
        integralIcon.image = UIImage.init(named: "invite_icon")
        backView.addSubview(integralIcon)
        
        integralIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(integralLabel)
            make.right.equalTo(integralLabel.snp.left).offset(-5)
            make.width.height.equalTo(16)
        }
    }

}
