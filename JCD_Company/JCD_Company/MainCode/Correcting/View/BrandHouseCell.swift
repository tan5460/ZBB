//
//  CollectionViewCell.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class BrandHouseCell: UICollectionViewCell {
    
    var showImageView: UIImageView!         //缩略图
   
    var titleLabel: UILabel!            //标题
   
    var merchantModel: BrandListItem? {
        didSet {
            if let brandName = merchantModel?.brandName {
                titleLabel.text = brandName
            }
            
            if var brandImg = merchantModel?.transformImageURL {
                if !brandImg.hasPrefix("/") {
                    brandImg = "/" + brandImg
                }
                
                showImageView.backgroundColor = .clear
                if let imageUrl = URL(string: APIURL.ossPicUrl + brandImg) {
                   showImageView.kf.setImage(with: imageUrl, placeholder: UIImage())
                }
                
            }else {
                showImageView.image = UIImage()
                showImageView.backgroundColor = .white
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //品牌图
        showImageView = UIImageView()
        showImageView.contentMode = .scaleAspectFit
        showImageView.image = UIImage.init(named: "loading")
        contentView.addSubview(showImageView)
        
        showImageView.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            
        }
        
        //品牌名
        titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.textAlignment = .center
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.bottom.right.equalTo(-8)
            make.top.equalTo(showImageView.snp.bottom).offset(8)

        }
        
      
    }
    
    
}
