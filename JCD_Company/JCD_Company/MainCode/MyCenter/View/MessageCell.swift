//
//  MessageCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/13.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class MessageCell: UITableViewCell {

    var timeLabel: UILabel!
    var backView: UIView!
    var msgTitleLabel: UILabel!
    var msgImageView: UIImageView!
    var msgDetailLabel: UILabel!
    
    var detailBlock: (()->())?
    
    var messageModel: SystemMsgModel? {
        
        didSet {
            
            timeLabel.text = "2000年01月01日 00:00"
            msgTitleLabel.text = "消息标题"
            msgImageView.isHidden = true
            msgDetailLabel.text = "(消息描述)"
            
            msgDetailLabel.snp.remakeConstraints { (make) in
                make.left.right.equalTo(msgTitleLabel)
                make.top.equalTo(msgTitleLabel.snp.bottom).offset(10)
                make.height.lessThanOrEqualTo(48)
            }
            
            timeLabel.text = messageModel?.createTime ?? ""
            if let valueStr = messageModel?.message {
                msgTitleLabel.text = valueStr
            }
            if let valueStr = messageModel?.message {
                msgDetailLabel.text = valueStr
            }
            if let valueStr = messageModel?.pushImg {
                
                if valueStr != "" {
                    msgImageView.isHidden = false
                    msgDetailLabel.snp.remakeConstraints { (make) in
                        make.left.right.equalTo(msgTitleLabel)
                        make.top.equalTo(msgImageView.snp.bottom).offset(10)
                        make.height.lessThanOrEqualTo(48)
                    }
                    
                    let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                    msgImageView.kf.setImage(with: imageUrl, placeholder: nil)
                }
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
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //时间
        timeLabel = UILabel()
        timeLabel.text = "2018年06月13日 11:00"
        timeLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xBFBFBF)
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(18)
            make.centerX.equalToSuperview()
        }
        
        //内容背景
        backView = UIView()
        backView.isUserInteractionEnabled = true
        backView.backgroundColor = .white
        contentView.addSubview(backView)
        
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(12)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalToSuperview()
        }
        
        //手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(detailAction))
        tapOne.numberOfTapsRequired = 1
        backView.addGestureRecognizer(tapOne)
        
        //标题
        msgTitleLabel = UILabel()
        msgTitleLabel.text = "梦想家具展厅成为现实，跟未来见个面吧！我们不会忽悠你的，真的！"
        msgTitleLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x333333)
        msgTitleLabel.font = UIFont.systemFont(ofSize: 16)
        backView.addSubview(msgTitleLabel)
        
        msgTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(18)
        }
        
        //图片
        msgImageView = UIImageView()
        msgImageView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF2F2F2)
        msgImageView.contentMode = .scaleAspectFit
        msgImageView.layer.cornerRadius = 3
        msgImageView.layer.masksToBounds = true
        backView.addSubview(msgImageView)
        
        msgImageView.snp.makeConstraints { (make) in
            make.top.equalTo(msgTitleLabel.snp.bottom).offset(12)
            make.left.right.equalTo(msgTitleLabel)
            make.height.equalTo(160)
        }
        
        //内容文本
        msgDetailLabel = UILabel()
        msgDetailLabel.text = "2018年5月，经过几个月的筹备，本着精益求精的精神，经过了5版的设计和讨论，最终定稿，完成设计。"
        msgDetailLabel.textColor = PublicColor.placeholderTextColor
        msgDetailLabel.font = UIFont.systemFont(ofSize: 13)
        msgDetailLabel.numberOfLines = 0
        backView.addSubview(msgDetailLabel)
        
        msgDetailLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(msgTitleLabel)
            make.top.equalTo(msgImageView.snp.bottom).offset(10)
            make.height.lessThanOrEqualTo(48)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        backView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(-35)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        //查看详情
        let lookLabel = UILabel()
        lookLabel.text = "查看详情"
        lookLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x4D4D4D)
        lookLabel.font = UIFont.systemFont(ofSize: 13)
        backView.addSubview(lookLabel)
        
        lookLabel.snp.makeConstraints { (make) in
            make.top.equalTo(msgDetailLabel.snp.bottom).offset(22)
            make.left.equalTo(msgTitleLabel)
            make.height.equalTo(15)
            make.bottom.equalTo(-11)
        }
        
        //箭头
        let arrowView = UIImageView()
        arrowView.image = UIImage.init(named: "arrow_message")
        arrowView.contentMode = .scaleAspectFit
        backView.addSubview(arrowView)
        
        arrowView.snp.makeConstraints { (make) in
            make.width.equalTo(6)
            make.height.equalTo(12)
            make.centerY.equalTo(lookLabel)
            make.right.equalTo(msgTitleLabel)
        }
    }
    
    @objc func detailAction() {
        
        if let block = detailBlock {
            block()
        }
    }
}
