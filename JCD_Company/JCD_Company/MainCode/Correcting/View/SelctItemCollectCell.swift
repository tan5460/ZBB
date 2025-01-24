//
//  SelctItemCollectCell.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class SelctItemCollectCell: UICollectionViewCell {

    var titleLabel: UILabel!            //标题
    var leftLine: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
     
        titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.textAlignment = .center
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        leftLine = UIView()
        leftLine.backgroundColor = #colorLiteral(red: 0.9629756808, green: 0.3033517301, blue: 0.2902962863, alpha: 1)
        contentView.addSubview(leftLine)
        
        leftLine.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.width.equalTo(2)
            make.height.equalTo(30)
        }
    }

}
