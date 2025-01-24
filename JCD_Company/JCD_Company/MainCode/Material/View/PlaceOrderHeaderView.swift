//
//  PlaceOrderHeaderView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/22.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class PlaceOrderHeaderView: UITableViewHeaderFooterView {

    var titleLabel: UILabel!
    var selectedBtn: UIButton!
    var addBtn: UIButton!
    
    var selectedBlock: ((_ isCheck: Bool)->())?
    var addBlock: (()->())?
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //自定义分割线
        let separatorView = UIView()
        separatorView.backgroundColor = PublicColor.backgroundViewColor
        contentView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //选中按钮
        selectedBtn = UIButton.init(type: .custom)
        selectedBtn.setImage(UIImage.init(named: "car_unchecked"), for: .normal)
        selectedBtn.setImage(UIImage.init(named: "car_checked"), for: .selected)
        selectedBtn.addTarget(self, action: #selector(selectedAction(_:)), for: .touchUpInside)
        contentView.addSubview(selectedBtn)
        
        selectedBtn.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        //组名
        titleLabel = UILabel()
        titleLabel.text = "全选"
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(selectedBtn)
            make.left.equalTo(selectedBtn.snp.right)
        }
        
        //添加按钮
        addBtn = UIButton.init(type: .custom)
        addBtn.setImage(UIImage.init(named: "sureOrder_add"), for: .normal)
        addBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        contentView.addSubview(addBtn)
        
        addBtn.snp.makeConstraints { (make) in
            make.right.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    
    @objc func selectedAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if selectedBlock != nil {
            
            selectedBlock!(sender.isSelected)
        }
    }
    
    @objc func addAction() {
   
        if addBlock != nil {
            
            addBlock!()
        }
    }
}
