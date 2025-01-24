//
//  RetailCollectionViewCell.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/24.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import PopupDialog

class MaterialCell: UICollectionViewCell {
    
    var showImageView: UIImageView!         //缩略图
    var singleImgView: UIImageView!         //单品标签
    var comBuy: UIButton!                   //组合购标
    var showTitleLabel: UILabel!            //标题
    var priceLabel: UILabel!                //市场价
    var priceLabel2: UILabel!                //销售价
    var originalLabel: UILabel!             //原价
    var addShopBtn: UIButton!               //加入购物车
    var brandLabel: UILabel!                //品牌
    var addMaterial: UIButton!              //添加此主材
    
    var addMaterialBlock: (()->())?         //添加此主材block
    var displayResultTitle: UILabel!            //结算标题
    var displayResultPrice: UILabel!            //结算s价
    var sjsFlag = false
    
    var isAddMaterial: Bool = false {
        didSet {
            if isAddMaterial {
                addShopBtn.isHidden = true
                addMaterial.isHidden = false
            }
            else {
                addShopBtn.isHidden = true
                if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
                    addShopBtn.isHidden = true
                }
                addMaterial.isHidden = true
                addShopBtn.isHidden = true
            }
        }
    }
    
    var model: MaterialsModel? {
        didSet {
            
            showImageView.image = UIImage.init(named: "loading")
            showTitleLabel.text = ""
            brandLabel.text = "品牌: 无"
            priceLabel.text = "￥0"
            priceLabel.isHidden = true
            
            if let valueStr = model?.name {
                showTitleLabel.text = valueStr
            }
            
            if model?.type == 1 {
                singleImgView.image = UIImage.init(named: "single_icon")
            }else {
                singleImgView.image = UIImage.init(named: "built_mark")
            }
            
            singleImgView.isHidden = true
            
            if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
                comBuy.isHidden = true
                originalLabel.text = "会员价"
                singleImgView.isHidden = true
                comBuy.isHidden = true
                var priceValue: Double = 0
                
                if let valueStr = model?.priceSupplyMin1?.doubleValue {
                    priceValue = valueStr
                }
                
                let value = priceValue.notRoundingString(afterPoint: 2)
                priceLabel2.text = String.init(format: "￥%@", value)
                priceLabel2.textColor = PublicColor.orangeLabelColor
                priceLabel2.isHidden = false
                
            }else if UserData.shared.userType == .cgy {
                if model?.isOneSell == 2 {
                    comBuy.isHidden = false
                } else {
                    comBuy.isHidden = true
                }
                originalLabel.text = "会员价"
                singleImgView.isHidden = true
                if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                    originalLabel.text = "销售价"
                }
                //进货价
                var priceSupply: Double = 0
                
                if let valueStr = model?.priceSupplyMin1?.doubleValue {
                    priceSupply = valueStr
                }
                
                let value = priceSupply.notRoundingString(afterPoint: 2)
                priceLabel2.text = String.init(format: "￥%@", value)
                priceLabel2.textColor = PublicColor.emphasizeTextColor
                priceLabel2.isHidden = false
                
            }else {
                //单品判断
                if model?.isOneSell == 1 {
                    singleImgView.isHidden = true
                    originalLabel.text = "销售价"
                    comBuy.isHidden = true
                    if let priceCustom = model?.priceCustom?.doubleValue {
                        let customValue = priceCustom.notRoundingString(afterPoint: 2)
                        priceLabel.text = String.init(format: "￥%@", customValue)
                        priceLabel.textColor = PublicColor.priceTextColor
                    } else if let customValueStr = model?.priceSellMin?.doubleValue {
                        let customValue = customValueStr.notRoundingString(afterPoint: 2)
                        priceLabel.text = String.init(format: "￥%@", customValue)
                        priceLabel.textColor = PublicColor.priceTextColor
                    }
                    if let valueStr = model?.priceShow?.doubleValue {
                        let value = valueStr.notRoundingString( afterPoint: 2)
                        priceLabel2.text = String.init(format: "￥%@", value)
                        priceLabel2.attributedText = priceLabel2.text!.addUnderline()
                        priceLabel2.textColor = PublicColor.placeholderTextColor
                    }
                    priceLabel.isHidden = false
                    priceLabel2.isHidden = false
                    
                    originalLabel.snp.remakeConstraints { (make) in
                        make.centerY.equalTo(priceLabel)
                        make.right.equalToSuperview().offset(-5)
                    }
                    priceLabel2.snp.remakeConstraints { (make) in
                        make.centerY.equalTo(priceLabel)
                        make.left.equalTo(priceLabel.snp.right).offset(10)
                    }
                    priceLabel.removeLabelUnderline()
                }else if model?.isOneSell == 2 {
                    originalLabel.text = "市场价"
                    comBuy.isHidden = false
                    singleImgView.isHidden = true
                    if let valueStr = model?.priceShow?.doubleValue {
                        let value = valueStr.notRoundingString( afterPoint: 2)
                        priceLabel.text = String.init(format: "￥%@", value)
                        priceLabel.setLabelUnderline()
                        priceLabel.textColor = PublicColor.emphasizeColor
                    }
                    priceLabel2.isHidden = true
                    
                    
                    if UserData.shared.sjsEnter && sjsFlag {
                        
                        originalLabel.isHidden = true
                        [displayResultPrice, displayResultTitle].forEach { $0?.isHidden = false }
                        priceLabel2.textColor = displayResultTitle.textColor
                        priceLabel2.isHidden = true
                        if let valueStr = model?.priceCustom?.doubleValue { //
                            let value = valueStr.notRoundingString(afterPoint: 2)
                            priceLabel2.text = String.init(format: "￥%@", value)
                        }
                        if let priceSupply = model?.priceSupply1?.doubleValue {
                            let value = priceSupply.notRoundingString(afterPoint: 2)
                            displayResultPrice.text = String.init(format: "￥%@", value)
                        }
                        
                        brandLabel.snp.remakeConstraints { (make) in
                            make.left.equalTo(showTitleLabel)
                            make.bottom.equalTo(displayResultPrice.snp.top).offset(-1)
                        }
                        
                    }
                    else {
                        priceLabel.isHidden = false
                        if let valueStr = model?.priceCustom?.doubleValue { //
                            let value = valueStr.notRoundingString(afterPoint: 2)
                            priceLabel2.text = String.init(format: "￥%@", value)
                        }
                        priceLabel2.snp.remakeConstraints { (make) in
                            make.left.equalTo(priceLabel.snp.right)
                            make.centerY.equalTo(priceLabel)
                        }
                    }
                    originalLabel.snp.remakeConstraints { (make) in
                        make.centerY.equalTo(priceLabel)
                        make.left.equalTo(priceLabel.snp.right).offset(10)
                    }
                } else {
                    originalLabel.text = "销售价"
                    comBuy.isHidden = true
                    singleImgView.isHidden = true
                    if let valueStr = model?.priceShow?.doubleValue {
                        let value = valueStr.notRoundingString( afterPoint: 2)
                        priceLabel.text = String.init(format: "￥%@", value)
                        priceLabel.attributedText = priceLabel.text!.addUnderline()
                        priceLabel.textColor = PublicColor.emphasizeColor
                    }
                    priceLabel.isHidden = false
                    priceLabel2.isHidden = false
                    if let customValueStr = model?.priceSellMin?.doubleValue {
                        let customValue = customValueStr.notRoundingString( afterPoint: 2)
                        priceLabel2.text = String.init(format: "￥%@", customValue)
                    }
                    
                    priceLabel.snp.remakeConstraints { (make) in
                        make.left.equalTo(priceLabel2.snp.right).offset(10)
                        make.centerY.equalTo(priceLabel2)
                    }
                    
                    originalLabel.snp.remakeConstraints { (make) in
                        make.left.equalTo(priceLabel.snp.right).offset(10)
                        make.centerY.equalTo(priceLabel)
                    }
                    
                    
                    priceLabel2.font(11)
                    priceLabel.font(9).textColor(.kColor66)
                    
                    
                    if UserData.shared.sjsEnter && sjsFlag {
                        
                        originalLabel.isHidden = true
                        [displayResultPrice, displayResultTitle].forEach { $0?.isHidden = false }
                        priceLabel2.textColor = displayResultTitle.textColor
                        priceLabel2.isHidden = true
                        if let valueStr = model?.priceCustom?.doubleValue { //
                            let value = valueStr.notRoundingString(afterPoint: 2)
                            priceLabel2.text = String.init(format: "￥%@", value)
                        }
                        if let priceSupply = model?.priceSupply1?.doubleValue {
                            let value = priceSupply.notRoundingString(afterPoint: 2)
                            displayResultPrice.text = String.init(format: "￥%@", value)
                        }
                        
                        brandLabel.snp.remakeConstraints { (make) in
                            make.left.equalTo(showTitleLabel)
                            make.bottom.equalTo(displayResultPrice.snp.top).offset(-1)
                        }
                        
                    }
                    priceLabel.removeLabelUnderline()
                }
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
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        
        //商品图
        showImageView = UIImageView()
        showImageView.contentMode = .scaleAspectFit
        showImageView.image = UIImage.init(named: "loading")
        contentView.addSubview(showImageView)
        
        showImageView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(contentView.snp.width)
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
        
        comBuy = UIButton()
        comBuy.setImage(UIImage.init(named: "comBuy"), for: .normal)
        showImageView.addSubview(comBuy)
        comBuy.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(54)
            make.height.equalTo(22)
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
            make.top.equalTo(showImageView.snp.bottom).offset(10)
        }
        
        displayResultPrice = UILabel()
        displayResultPrice.textColor = PublicColor.priceTextColor
        displayResultPrice.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(displayResultPrice)
        
        displayResultPrice.snp.makeConstraints { (make) in
            
            make.left.equalTo(showTitleLabel)
            make.bottom.equalTo(-10)
        }
        
        //市场价
        displayResultTitle = UILabel()
        displayResultTitle.text = "会员价"
        displayResultTitle.textColor = PublicColor.minorTextColor
        displayResultTitle.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(displayResultTitle)
        
        displayResultTitle.snp.makeConstraints { (make) in
            make.left.equalTo(displayResultPrice.snp.right).offset(5)
            make.centerY.equalTo(displayResultPrice)
        }
        
        [displayResultPrice, displayResultTitle].forEach { $0?.isHidden = !(UserData.shared.sjsEnter && sjsFlag) }
        
        
        //售价
        priceLabel = UILabel()
        priceLabel.textColor = PublicColor.priceTextColor
        priceLabel.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(showTitleLabel)
            if UserData.shared.sjsEnter {
                make.bottom.equalTo(displayResultPrice.snp.top)
            }
            else {
                make.bottom.equalTo(-10)
            }
        }
        
        //售价
        priceLabel2 = UILabel()
        priceLabel2.textColor = PublicColor.priceTextColor
        priceLabel2.font = UIFont.systemFont(ofSize: 9)
        contentView.addSubview(priceLabel2)
        
        priceLabel2.snp.makeConstraints { (make) in
            make.left.equalTo(showTitleLabel)
            if UserData.shared.sjsEnter {
                make.bottom.equalTo(displayResultPrice.snp.top)
            }
            else {
                make.bottom.equalTo(-10)
            }
        }
        
        //市场价
        originalLabel = UILabel()
        originalLabel.text = "市场价"
        originalLabel.textColor = PublicColor.minorTextColor
        originalLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(originalLabel)
        
        originalLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel2.snp.right).offset(5)
            make.centerY.equalTo(priceLabel2)
        }
        
        //品牌
        brandLabel = UILabel()
        brandLabel.text = "品牌:"
        brandLabel.textColor = PublicColor.minorTextColor
        brandLabel.font = UIFont.systemFont(ofSize: 11)
        contentView.addSubview(brandLabel)
        
        brandLabel.snp.makeConstraints { (make) in
            make.left.equalTo(showTitleLabel)
            make.bottom.equalTo(priceLabel.snp.top).offset(-4)
        }
        
        //加购物车
        addShopBtn = UIButton(type: .custom)
        addShopBtn.setImage(UIImage.init(named: "cart_add"), for: .normal)
        addShopBtn.addTarget(self, action: #selector(addShopaction), for: .touchUpInside)
        addShopBtn.isHidden = true
        contentView.addSubview(addShopBtn)
        
        
        addShopBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(0)
            make.width.height.equalTo(50)
        }
        
        //添加此主材
        addMaterial = UIButton(type: .custom)
        addMaterial.setImage(UIImage.init(named: "menu_add"), for: .normal)
        addMaterial.isHidden = true
        addMaterial.addTarget(self, action: #selector(addMaterialAction), for: .touchUpInside)
        contentView.addSubview(addMaterial)
        
        addMaterial.snp.makeConstraints { (make) in
            make.edges.equalTo(addShopBtn)
        }
    }
    
    //添加才主材
    @objc func addMaterialAction() {
        AppLog("点击了添加此主材按钮")
        
        if let block = addMaterialBlock {
            block()
        }
    }
    
    //加购物车
    @objc func addShopaction() {
        AppLog("点击了添加购物车按钮")
        
        if UserData.shared.userType == .jzgs {
            addCart()
        }else {
        }
        
    }
    
    func addCart() {
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        var parameters: Parameters = ["worker": userId, "store": storeID, "materials": model!.id!, "type": "1"]
        
        if let valueStr = model?.type {
            parameters["materialsType"] = valueStr
        }
        
        self.clearAllNotice()
        self.pleaseWait()
        let urlStr = APIURL.saveCartList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                self.noticeSuccess("添加购物车成功", autoClear: true, autoClearTime: 0.8)
            }
            
        }) { (error) in
            
        }
    }
}
