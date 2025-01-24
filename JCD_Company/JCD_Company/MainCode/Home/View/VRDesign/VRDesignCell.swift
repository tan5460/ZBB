//
//  VRDesignCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/30.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class VRDesignCell: UICollectionViewCell {
    
    var showImageView: UIImageView!         //缩略图
    var titleLabel: UILabel!            //标题
    var placeLabel: UILabel!                //小区
    
    func setModelWithCollectionView(_ model:VRdesignModel,_ collectionView:UICollectionView) {
        self.titleLabel.text = model.name
        
        var detailStr = ""
        
        if let commName = model.commName {
            detailStr = commName
        }
        if let area = model.area?.doubleValue {
            let areaStr = area.notRoundingString(afterPoint: 2)
            detailStr += String.init(format: "  %@㎡", areaStr)
        }
        self.placeLabel.text = detailStr
        if let mainImgUrl = model.transformCoverPic {
            if let imageUrl = URL(string: mainImgUrl) {
                self.showImageView.kf.setImage(with: imageUrl)
//                self.showImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading_vr"), options: nil, progressBlock: nil) { (image, error, casheType, url) in
//                    if image != nil {
//                        
//                        XHWebImageAutoSize.storeImageSize(image!, for: url!) { (result) in
//                            if result {
//                                
//                                collectionView.xh_reloadData(for: url)
//                            }
//                        }
//                    }
//                }
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        //商品图
        showImageView = UIImageView()
        
        showImageView.image = UIImage.init(named: "loading")
        contentView.addSubview(showImageView)
        

        //商品名
        titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.numberOfLines = 2
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        contentView.addSubview(titleLabel)
        
        //售价
        placeLabel = UILabel()
        placeLabel.textColor = PublicColor.minorTextColor
        placeLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(placeLabel)
        
        placeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.greaterThanOrEqualTo(12)
            make.bottom.equalTo(-12)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(placeLabel)
            make.height.greaterThanOrEqualTo(15)
            make.bottom.equalTo(placeLabel.snp.top).offset(-8)
        }
      
        showImageView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-10)
        }
        
        let playBtn = UIButton(frame: CGRect.init(x: 0, y: 0, width: 88, height: 30))
        playBtn.setTitle("3D", for: .normal)
        playBtn.setImage(UIImage.init(named: "play3d"), for: .normal)
        playBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        playBtn.layer.cornerRadius = 15
        playBtn.layer.masksToBounds = true
        playBtn.setBackgroundImage(UIColor.black.withAlphaComponent(0.2).image(), for: .normal)
        playBtn.isUserInteractionEnabled = false
        contentView.addSubview(playBtn)
        playBtn.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.center.equalTo(showImageView.snp.center)
        }
    }
}
