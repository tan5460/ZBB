//
//  IMMoreCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/8.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class IMMoreCell: UICollectionViewCell {
    lazy var itemButton: UIButton = {
        let itemBtn = UIButton()
        itemBtn.backgroundColor = UIColor.white
        itemBtn.isUserInteractionEnabled = false
        return itemBtn
    }()
    
    lazy var itemLabel: UILabel = {
        let itemL = UILabel()
        itemL.textColor = PublicColor.commonTextColor
        itemL.font = UIFont.systemFont(ofSize: 12.0)
        itemL.textAlignment = .center
        return itemL
    }()
    
    var type: IMMoreType?
    
    // MARK:- 记录属性
    var model: (name: String, icon: UIImage, type: IMMoreType)? {
        didSet {
            self.itemButton.setImage(model?.icon, for: .normal)
            self.itemLabel.text = model?.name
            self.type = model?.type
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(itemButton)
        self.addSubview(itemLabel)
        
        itemLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
            make.height.equalTo(21)
        }
        itemButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.top).offset(6)
            make.bottom.equalTo(itemLabel.snp.top).offset(-5)
            make.width.equalTo(itemButton.snp.height)
            make.centerX.equalTo(self.snp.centerX)
        }
        
    }
}
