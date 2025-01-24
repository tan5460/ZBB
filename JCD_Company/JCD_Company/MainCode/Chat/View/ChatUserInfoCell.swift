//
//  ChatUserInfoCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/22.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class ChatUserInfoCell: UITableViewCell {

    var nameLabel: UILabel!             //客户名字
    var phoneLabel: UILabel!            //客户电话
    var headerBtn: UIButton!            //头像
    var telBtn: UIButton!               //打电话
    var lineView: UIView!               //底部视图
    
    var callPhoneBlock: (()->())?       //打电话
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func createSubView() {
        
        //头像
        let headerHeight: CGFloat = 45
        headerBtn = UIButton()
        headerBtn.backgroundColor = .clear
        headerBtn.imageView?.contentMode = .scaleAspectFit
        headerBtn.layer.cornerRadius = headerHeight/2
        headerBtn.layer.masksToBounds = true
        headerBtn.setImage(UIImage.init(named: "headerImage_man"), for: .normal)
        contentView.addSubview(headerBtn)
        
        headerBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
            make.width.height.equalTo(headerHeight)
        }
        
        //名字
        nameLabel = UILabel()
        nameLabel.text = "王健林"
        nameLabel.textColor = PublicColor.commonTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerBtn.snp.top).offset(4)
            make.left.equalTo(headerBtn.snp.right).offset(13)
        }
 
        phoneLabel = UILabel()
        phoneLabel.text = "18800560021"
        phoneLabel.textColor = PublicColor.minorTextColor
        phoneLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        ///打电话
        telBtn = UIButton(type: .custom)
        telBtn.setImage(UIImage.init(named: "order_tel"), for: .normal)
        telBtn.addTarget(self, action: #selector(telAction), for: .touchUpInside)
        contentView.addSubview(telBtn)
        
        telBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerY.equalTo(headerBtn.snp.centerY)
            make.right.equalTo(-12)
        }
        
        lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func hiddenHeaderBtn(_ hidden:Bool) {
        headerBtn.isHidden = hidden
        
        if hidden {
            headerBtn.snp.remakeConstraints { (make) in
                make.left.equalTo(2)
                make.top.equalTo(10)
                make.bottom.equalTo(-10)
                make.width.equalTo(0)
                make.height.equalTo(45)
            }
        }else {
            headerBtn.snp.remakeConstraints { (make) in
                make.left.equalTo(15)
                make.top.equalTo(15)
                make.bottom.equalTo(-15)
                make.width.height.equalTo(45)
            }
        }
    }
    
    ///拨打电话
    @objc func telAction(){
        
        if let block = callPhoneBlock {
            block()
        }
    }

}
