//
//  FilterCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/17.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    var titleLable: UILabel!
    
    var isSelect : Bool = false {
        didSet {
            if isSelect {
                titleLable.textColor = PublicColor.emphasizeTextColor
                titleLable.layer.borderColor = PublicColor.emphasizeTextColor.cgColor
            }else {
                titleLable.textColor = PublicColor.commonTextColor
                titleLable.layer.borderColor = PublicColor.partingLineColor.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        titleLable = UILabel()
        titleLable.font = UIFont.systemFont(ofSize: 13)
        titleLable.textAlignment = .center
        titleLable.backgroundColor = UIColor.white
        titleLable.textColor = PublicColor.commonTextColor
        contentView.addSubview(titleLable)
        
        titleLable.layer.borderWidth = 0.5
        titleLable.layer.borderColor = PublicColor.partingLineColor.cgColor
        titleLable.layer.cornerRadius = 4
        
        titleLable.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
