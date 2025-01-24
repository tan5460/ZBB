//
//  PurchaseDetaiCell2.swift
//  YZB_Company
//
//  Created by yzb_ios on 15.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class PurchaseDetailCell2: UITableViewCell {
    
    var nameBtn: UIButton!                      //标题
    var showImageView: UIImageView!             //图片
    var comBuyBtn: UIButton!                    //组合购标
    var brandLabel: UILabel!                    //品牌
    var countLabel: UILabel!                    //数量
    var unitLabel: UILabel!                     //单位
    var specificationLabel: UILabel!            //规格
    var costLabel: UILabel!                     //会员价
    var priceLabel: UILabel!                    //平台价
    var costSumLabel: UILabel!                  //结算总价
    var priceSumLabel: UILabel!                 //平台总价
    let textFont = UIFont.systemFont(ofSize: 11)
    
    var isCusMaterials = false                 ////是否是补差价
    var activityType = 1 // 2 清仓 3 特惠
    var detailBlock: (()->())?                          //详情block
    
    var purchaseMaterial: PurchaseMaterialModel? {
        
        didSet {
            prepareLabelText()
            var materialsCount: Double = 0
            if let valueStr = purchaseMaterial?.materialsCount {
                
                materialsCount = Double.init(string: valueStr) ?? 0
                let countStr = materialsCount.notRoundingString(afterPoint: 2)
                
                countLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "数量: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "\(countStr)", color: PublicColor.commonTextColor, font: textFont)])
            }
            if let valueStr = purchaseMaterial?.materialsName {
                nameBtn.setTitle(valueStr, for: .normal)
            }
            
            if !showImageView.addImage(purchaseMaterial?.image) {
                showImageView.image = UIImage.init(named: "loading")
            }
            if let valueStr = purchaseMaterial?.brandName {
                brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
            }
            if let valueStr = purchaseMaterial?.materialsUnitTypeName {
                unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
            }
            if let valueStr = purchaseMaterial?.skuAttr1, !valueStr.isEmpty {
                specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
            } else  {
                specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "默认", color: PublicColor.commonTextColor, font: textFont)])
            }
            
            if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                
                priceLabel.isHidden = true
                priceSumLabel.isHidden = true
                
                if activityType == 2 {
                    comBuyBtn.isHidden =  true
                    let moneyStr = purchaseMaterial?.moneyMaterials?.doubleValue.notRoundingString(afterPoint: 2) ?? "0"
                    costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "一口价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                    
                    costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: .red, font: textFont)])
                } else if activityType == 3 {
                    if let valueStr = purchaseMaterial?.moneyMaterials?.doubleValue {
                        costSumLabel.isHidden = false
                            comBuyBtn.isHidden =  true
                            let moneyStr = valueStr.notRoundingString(afterPoint: 2)
                            costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "特惠价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                            
                            let moneySumStr = (valueStr*Double(materialsCount)).notRoundingString(afterPoint: 2)
                            costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneySumStr, color: .red, font: textFont)])
                    }

                } else {
                    if let valueStr = purchaseMaterial?.price?.doubleValue {
                        costSumLabel.isHidden = false
                        if purchaseMaterial?.materials?.isOneSell ==  2 {
                            comBuyBtn.isHidden = false
                            costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "***", color: PublicColor.commonTextColor, font: textFont)])
                            
                            costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "***", color: .red, font: textFont)])
                        } else {
                            comBuyBtn.isHidden =  true
                            let moneyStr = valueStr.notRoundingString(afterPoint: 2)
                            costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                            
                            let moneySumStr = (valueStr*Double(materialsCount)).notRoundingString(afterPoint: 2)
                            costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneySumStr, color: .red, font: textFont)])
                        }
                    }
                }
            }else {
                if activityType == 2 || activityType == 3 {
                    if let valueStr = purchaseMaterial?.moneyMaterials?.doubleValue {
                        let moneyStr = valueStr.notRoundingString(afterPoint: 2)
                        var titleStr = "会员价: "
                        if activityType == 2 {
                            titleStr = "一口价: "
                        } else if activityType == 3 {
                            titleStr = "特惠价: "
                        }
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: titleStr, color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                        
                        let moneySumStr = (valueStr*Double(materialsCount)).notRoundingString(afterPoint: 2)
                        if activityType == 2 {
                            priceSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.minorTextColor, font: textFont)])
                            
                        } else if activityType == 3  {
                            priceSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneySumStr, color: PublicColor.minorTextColor, font: textFont)])
                        }
                        costSumLabel.isHidden = true
                        priceLabel.isHidden = true
                        
                    }
                } else {
                    if let valueStr = purchaseMaterial?.price?.doubleValue {
                        let moneyStr = valueStr.notRoundingString(afterPoint: 2)
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                        
                        let moneySumStr = (valueStr*Double(materialsCount)).notRoundingString(afterPoint: 2)
                        priceSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneySumStr, color: PublicColor.minorTextColor, font: textFont)])
                        costSumLabel.isHidden = true
                        priceLabel.isHidden = true
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        createSubView()
    }
    
    func createSubView() {
        
        //商品标题
        nameBtn = UIButton(type: .custom)
        nameBtn.contentHorizontalAlignment = .left
        nameBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        nameBtn.setTitle("产品名", for: .normal)
        nameBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        nameBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        nameBtn.addTarget(self, action: #selector(detailAction), for: .touchUpInside)
        contentView.addSubview(nameBtn)
        
        nameBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.right.lessThanOrEqualTo(-15)
            make.height.equalTo(20)
        }
        
        //商品图片
        showImageView = UIImageView()
        showImageView.isUserInteractionEnabled = true
        showImageView.contentMode = .scaleAspectFit
        showImageView.layer.cornerRadius = 5
        showImageView.layer.masksToBounds = true
        showImageView.image = UIImage.init(named: "loading")
        contentView.addSubview(showImageView)
        
        showImageView.snp.makeConstraints { (make) in
            make.top.equalTo(nameBtn.snp.bottom).offset(10)
            make.left.equalTo(nameBtn)
            make.width.height.equalTo(70)
        }
        
        comBuyBtn = UIButton()
        comBuyBtn.setImage(UIImage(named: "comBuy"), for: .normal)
        showImageView.addSubview(comBuyBtn)
        comBuyBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        comBuyBtn.isHidden = true
        
        
        //图片点击手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(detailAction))
        tapOne.numberOfTapsRequired = 1
        showImageView.addGestureRecognizer(tapOne)
        
        //品牌
        brandLabel = UILabel()
        brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(brandLabel)
        
        brandLabel.snp.makeConstraints { (make) in
            make.left.equalTo(showImageView.snp.right).offset(15)
            make.top.equalTo(showImageView)
            make.height.equalTo(13)
            //            make.width.lessThanOrEqualTo(110)
        }
        
        //数量
        countLabel = UILabel()
        countLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "数量: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(countLabel)
        
        countLabel.snp.makeConstraints { (make) in
            make.left.equalTo(brandLabel.snp.right).offset(10)
            make.centerY.height.equalTo(brandLabel)
        }
        
        //单位
        unitLabel = UILabel()
        unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(unitLabel)
        
        unitLabel.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(brandLabel)
            make.left.equalTo(countLabel.snp.right).offset(10)
            //            make.right.equalTo(-20)
        }
        
        //规格
        specificationLabel = UILabel()
        specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(specificationLabel)
        
        specificationLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(brandLabel)
            make.top.equalTo(brandLabel.snp.bottom).offset(7)
            make.right.equalTo(unitLabel)
        }
        
        //会员价
        costLabel = UILabel()
        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(costLabel)
        
        costLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(brandLabel)
            make.top.equalTo(specificationLabel.snp.bottom).offset(7)
            //            make.width.lessThanOrEqualTo(110)
        }
        
        //平台销售价
        priceLabel = UILabel()
        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "销售价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont)])
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(costLabel.snp.right).offset(10)
            make.centerY.height.equalTo(costLabel)
            //            make.right.equalTo(unitLabel)
        }
        priceLabel.isHidden = true
        
        //结算总价
        costSumLabel = UILabel()
        costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "结算总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.orangeLabelColor, font: textFont)])
        contentView.addSubview(costSumLabel)
        
        costSumLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(costLabel)
            make.top.equalTo(costLabel.snp.bottom).offset(7)
            make.bottom.equalTo(-20)
        }
        costSumLabel.isHidden = true
        
        //平台销售价
        priceSumLabel = UILabel()
        priceSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont)])
        contentView.addSubview(priceSumLabel)
        
        priceSumLabel.snp.makeConstraints { (make) in
            make.left.equalTo(costSumLabel)
            make.centerY.height.equalTo(costSumLabel)
        }
        
        //箭头
        let arrowView = UIImageView()
        arrowView.image = UIImage.init(named: "arrow_right")
        arrowView.contentMode = .center
        contentView.addSubview(arrowView)
        
        arrowView.snp.makeConstraints { (make) in
            make.width.equalTo(8)
            make.height.equalTo(15)
            make.centerY.equalTo(showImageView)
            make.right.equalTo(-15)
        }
    }
    
    func prepareLabelText() {
        
        nameBtn.setTitle("产品名未知", for: .normal)
        showImageView.image = UIImage.init(named: "loading")
        brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        countLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "数量: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "销售价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont)])
        costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "结算总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        priceSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont)])
    }
    
    @objc func detailAction() {
        AppLog("点击了主材详情")
        if let block = detailBlock {
            block()
        }
    }
}
