//
//  asd.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import PopupDialog

class NewMaterialCell: UICollectionViewCell {
    
    var showImageView: UIImageView!         //缩略图
    var singleImgView: UIImageView!         //单品标签
    var showTitleLabel: UILabel!            //标题
    var priceLabel: UILabel!                //市场价
    var priceLabel2: UILabel!                //销售价
    var originalLabel: UILabel!             //原价
    var brandLabel: UILabel!                //品牌
    
    var model: MaterialsModel? {
        didSet {
            
            showImageView.image = UIImage.init(named: "loading")
            showTitleLabel.text = ""
            brandLabel.text = "品牌: 无"
            priceLabel.text = "￥未定价"
            
            if let valueStr = model?.name {
                showTitleLabel.text = valueStr
            }
            
            if model?.type == 1 {
                //                singleImgView.image = UIImage.init(named: "single_icon")
            }else {
                singleImgView.image = UIImage.init(named: "built_mark")
            }
            
            //            if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
            //
            //                originalLabel.text = "会员价"
            //                singleImgView.isHidden = true
            //
            //                var priceValue: Double = 0
            //
            //                if let valueStr = model?.beforePriceCost?.doubleValue {
            //                    priceValue = valueStr
            //                }
            //                else if let valueStr = model?.priceCost?.doubleValue {
            //                    priceValue = valueStr
            //                }
            //
            //                let value = ToolsFunc.notRounding(priceValue, afterPoint: 2)
            //                priceLabel.text = String.init(format: "￥%@", value)
            //                priceLabel.textColor = PublicColor.emphasizeTextColor
            //
            //            }else if UserData.shared.userType == .cgy {
            //
            //                originalLabel.text = "进货价"
            //                singleImgView.isHidden = true
            //
            //                //进货价
            //                var priceSupply: Double = 0
            //
            //                if let valueStr = model?.beforePriceSupply?.doubleValue {
            //                    priceSupply = valueStr
            //                }else if let valueStr = model?.priceSupply?.doubleValue {
            //                    priceSupply = valueStr
            //                }
            //
            //                let value = ToolsFunc.notRounding(priceSupply, afterPoint: 2)
            //                priceLabel.text = String.init(format: "￥%@", value)
            //                priceLabel.textColor = PublicColor.emphasizeTextColor
            //
            //            }else {
            //                //单品判断
            //                if model?.isOneSell == 1 {
            //                    singleImgView.isHidden = false
            //                    originalLabel.text = "销售价"
            //
            //                    if let customValueStr = model?.priceCustom?.doubleValue {
            //                        let customValue = ToolsFunc.notRounding(customValueStr, afterPoint: 2)
            //                        priceLabel.text = String.init(format: "￥%@", customValue)
            //                        priceLabel.textColor = PublicColor.emphasizeTextColor
            //                    }
            //                }else {
            //                    originalLabel.text = "市场价"
            originalLabel.text = "销售价"
            singleImgView.isHidden = true
            if let valueStr = model?.priceShow?.doubleValue {
                let value = valueStr.notRoundingString(afterPoint: 2)
                priceLabel.text = String.init(format: "￥%@", value)
                priceLabel.attributedText = priceLabel.text!.addUnderline()
                priceLabel.textColor = PublicColor.emphasizeColor
            }
            
            if let customValueStr = model?.priceCustom?.doubleValue {
                let customValue = customValueStr.notRoundingString(afterPoint: 2)
                priceLabel2.text = String.init(format: "￥%@", customValue)
                
            }
            
            if let valueStr = model?.brandName {
                brandLabel.text = "品牌: \(valueStr)"
            }
            
            if let imageStr = model?.transformImageURL, let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
                showImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
            } else {
                showImageView.image = UIImage.init(named: "loading")
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
        
        //商品图
        showImageView = UIImageView()
        showImageView.contentMode = .scaleAspectFit
        showImageView.image = UIImage.init(named: "loading")
        contentView.addSubview(showImageView)
        
        showImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(8)
            make.right.equalTo(-8)
        }
        
        //单品标签
        singleImgView = UIImageView()
        singleImgView.isHidden = true
        singleImgView.contentMode = .scaleAspectFit
        //        singleImgView.image = UIImage.init(named: "single_icon")
        contentView.addSubview(singleImgView)
        
        singleImgView.snp.makeConstraints { (make) in
            make.left.top.equalTo(showImageView)
            make.width.height.equalTo(34)
        }
        
        //商品名
        showTitleLabel = UILabel()
        showTitleLabel.text = ""
        showTitleLabel.textColor = PublicColor.commonTextColor
        showTitleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        contentView.addSubview(showTitleLabel)
        
        showTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(showImageView.snp.bottom).offset(8)
            make.height.equalTo(13)
        }
        
        //品牌
        brandLabel = UILabel()
        brandLabel.text = "品牌:"
        brandLabel.textColor = PublicColor.minorTextColor
        brandLabel.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(brandLabel)
        
        brandLabel.snp.makeConstraints { (make) in
            make.top.equalTo(showTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(showTitleLabel)
            make.height.equalTo(12)
        }
        
        //售价
        priceLabel = UILabel()
        priceLabel.textColor = PublicColor.emphasizeColor
        priceLabel.font = UIFont.systemFont(ofSize: 9)
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(brandLabel.snp.bottom).offset(7)
            make.left.equalTo(showTitleLabel)
            make.height.equalTo(13)
            make.bottom.equalTo(-8)
        }
        
        //售价
        priceLabel2 = UILabel()
        priceLabel2.textColor = PublicColor.priceTextColor
        priceLabel2.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(priceLabel2)
        
        priceLabel2.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(2)
            make.centerY.equalTo(priceLabel)
        }
        
        //市场价
        originalLabel = UILabel()
        originalLabel.text = "市场价"
        originalLabel.numberOfLines = 2
        originalLabel.textColor = PublicColor.minorTextColor
        originalLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(originalLabel)
        
        originalLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel2.snp.right).offset(5)
            make.centerY.equalTo(priceLabel)
            make.right.equalTo(-2)
        }
        
    }
    
}
