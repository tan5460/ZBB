//
//  MoreCell.swift
//  YZB_Company
//
//  Created by 周化波 on 2017/12/28.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit

class MoreCell: UITableViewCell {
    
    var titleLabel: UILabel!                    //左边标题
    var contentLabel: UILabel!                  //右边内容
    var exitLabel: UILabel!                     //退出登录
    var arrowView: UIImageView!                 //右边箭头
    var iconView: UIImageView!                  //图标
    var topLineView: UIView!                    //cell头部分割线
    var downLineView: UIView!                   //cell尾部分割线
    var activityView: UIActivityIndicatorView!  //清除缓存时显示的菊花
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubView() {
        
        //图标
        iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        contentView.addSubview(iconView)
        
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(18)
            make.centerY.equalToSuperview()
            make.left.equalTo(20)
        }
        
        //左边标题
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x1E1E1E)
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = "我是标题"
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(9)
            make.centerY.equalToSuperview()
            make.height.equalTo(19)
        }
        
        //箭头
        arrowView = UIImageView()
        arrowView.image = UIImage.init(named: "arrow_right")
        arrowView.contentMode = .scaleAspectFit
        contentView.addSubview(arrowView)
        
        arrowView.snp.makeConstraints { (make) in
            make.width.equalTo(7)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        
        //菊花
        activityView = UIActivityIndicatorView.init(style:.gray)
        activityView.backgroundColor = UIColor.white
        contentView.addSubview(activityView)
        
        activityView.snp.makeConstraints { (make) in
            make.width.height.equalTo(36)
            make.centerY.equalToSuperview()
            make.right.equalTo(arrowView.snp.left).offset(-8)
        }
        
        //右边文本
        contentLabel = UILabel()
        contentLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xB3B3B3)
        contentLabel.text = "我是内容"
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(contentLabel)
        
        contentLabel.snp.makeConstraints { (make) in
            make.right.equalTo(arrowView.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(17)
        }
        
        //上分割线
        topLineView = UIView()
        topLineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(topLineView)
        
        topLineView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        //下分割线
        downLineView = UIView()
        downLineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(downLineView)
        
        downLineView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        //退出
        exitLabel = UILabel()
        exitLabel.text = "退出登录"
        exitLabel.font = UIFont.systemFont(ofSize: 15)
        exitLabel.textColor = PublicColor.emphasizeTextColor
        contentView.addSubview(exitLabel)
        
        exitLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }

    }

}
