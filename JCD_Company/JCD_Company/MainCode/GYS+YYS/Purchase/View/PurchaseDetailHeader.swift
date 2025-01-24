//
//  PurchaseDetailHeader.swift
//  YZB_Company
//
//  Created by yzb_ios on 15.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class PurchaseDetailHeader: UITableViewHeaderFooterView {

    var headerTitleLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        let backView = UIView()
        backView.backgroundColor = .white
        contentView.addSubview(backView)
        
        backView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        headerTitleLabel = UILabel()
        headerTitleLabel.text = "订单信息"
        headerTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerTitleLabel.textColor = PublicColor.commonTextColor
        backView.addSubview(headerTitleLabel)
        
        headerTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(15)
            make.height.equalTo(20)
        }
        
    }
}
