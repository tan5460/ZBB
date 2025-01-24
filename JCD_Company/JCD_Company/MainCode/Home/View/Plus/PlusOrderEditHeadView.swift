//
//  PlusOrderEditHeadView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/27.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class PlusOrderEditHeadView: UITableViewHeaderFooterView {

    var titleLabel: UILabel!                        //组标题
    var upOrDownBtn: UIButton!
    var upOrDownBlock: (()->())?
    
    var selectedBtn: UIButton!
    
    var selectedBlock: ((_ isCheck: Bool)->())?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {

        //选中按钮
        selectedBtn = UIButton.init(type: .custom)
        selectedBtn.setImage(UIImage.init(named: "car_unchecked"), for: .normal)
        selectedBtn.setImage(UIImage.init(named: "car_checked"), for: .selected)
        selectedBtn.addTarget(self, action: #selector(selectedAction(_:)), for: .touchUpInside)
        contentView.addSubview(selectedBtn)
        
        selectedBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(35)
        }
        
        //展开
        upOrDownBtn = UIButton(type: .custom)
        upOrDownBtn.setImage(UIImage.init(named: "order_icon_down"), for: .normal)
        upOrDownBtn.setImage(UIImage.init(named: "order_icon_up"), for: .selected)
        upOrDownBtn.addTarget(self, action: #selector(tapClickAction), for: .touchUpInside)
        contentView.addSubview(upOrDownBtn)
        
        upOrDownBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-18)
            make.width.height.equalTo(20)
        }
        
        //组名
        titleLabel = UILabel()
        titleLabel.text = "产品"
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(selectedBtn)
            make.left.equalTo(selectedBtn.snp.right)
            make.right.equalTo(upOrDownBtn.snp.left)
            make.height.equalTo(30)
        }
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapClickAction)))
        
        
    }
    @objc func tapClickAction() {
        if let block = upOrDownBlock {
            self.upOrDownBtn.isSelected = !self.upOrDownBtn.isSelected
            block()
        }
    }
    @objc func selectedAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if selectedBlock != nil {
            
            selectedBlock!(sender.isSelected)
        }
    }
}
