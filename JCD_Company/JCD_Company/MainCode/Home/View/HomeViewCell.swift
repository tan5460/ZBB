//
//  HomeViewCell.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/27.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit

class HomeViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var imageTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        let offset = IS_iPad ? 15.0 : 10.0
        
        //图片
        let imageWidth = IS_iPad ? 70.0 : 50.0
        imageView = UIImageView()
        imageView.contentMode = .center
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-offset)
            make.size.equalTo(CGSize.init(width: imageWidth, height: imageWidth))
        }
        
        //名字
        imageTitle = UILabel()
        imageTitle.textColor = PublicColor.commonTextColor
        imageTitle.textAlignment = NSTextAlignment.center
        imageTitle.font = UIFont.systemFont(ofSize: IS_iPad ? 15 : 13)
        contentView.addSubview(imageTitle)
        
        imageTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(offset)
        }
        
    }
    
}
