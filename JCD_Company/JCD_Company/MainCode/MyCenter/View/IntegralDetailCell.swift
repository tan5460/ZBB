//
//  IntegralDetailCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/20.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

class IntegralDetailCell: UITableViewCell {

    var topLineVie: UIView!
    var timeLabel: UILabel!
    var detailLabel: UILabel!
    var changeLabel: UILabel!
    
    var detailModel: IntegralDetailModel? {
        didSet {
            
            timeLabel.text = "2000-01-01 00:00:00"
            detailLabel.text = "明细"
            changeLabel.text = "+0"
            
            if let valueStr = detailModel?.changeTime {
                timeLabel.text = valueStr
            }
            if let valueStr = detailModel?.changeDetail {
                detailLabel.text = valueStr
            }
            if let valueStr = detailModel?.changeValue {
                changeLabel.text = valueStr
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
        
        self.backgroundColor = .white
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //上分割线
        topLineVie = UIView()
        topLineVie.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(topLineVie)
        
        topLineVie.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //时间
        timeLabel = UILabel()
        timeLabel.numberOfLines = 2
        timeLabel.textAlignment = .center
        timeLabel.text = "2000-01-01 00:00:00"
        timeLabel.textColor = PublicColor.placeholderTextColor
        timeLabel.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.0/3)
            make.width.equalTo(70)
        }
        
        //明细
        detailLabel = UILabel()
        detailLabel.text = "明细"
        detailLabel.textColor = PublicColor.placeholderTextColor
        detailLabel.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        //积分变化
        changeLabel = UILabel()
        changeLabel.text = "+0"
        changeLabel.textColor = PublicColor.placeholderTextColor
        changeLabel.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(changeLabel)
        
        changeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(5.0/3)
        }
        
        //下分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

}
