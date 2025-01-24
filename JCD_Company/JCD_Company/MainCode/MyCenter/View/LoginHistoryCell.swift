//
//  LoginHistoryCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/29.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class LoginHistoryCell: UITableViewCell {

    var titleLabel : UILabel!
    var deleteBtn : UIButton!
    
    var deleteBlock : ((_ rowText:String)->())?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func createSubView() {
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        
        //左边label
        titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(-80)
            make.centerY.equalToSuperview()
        }
        
        //箭头
        deleteBtn = UIButton()
        deleteBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        self.contentView.addSubview(deleteBtn)
        
        deleteBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-23)
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xFFC8B0)
        self.contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(28)
            make.right.equalTo(-18)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
    }
    
    @objc func deleteAction() {
        if (self.deleteBlock != nil) {
            self.deleteBlock!(titleLabel.text!)
        }
    }
}
