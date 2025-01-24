//
//  WantPurchaseCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/24.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class WantPurchaseCell: UITableViewCell {

    var selectedBtn: UIButton!                  //选择按钮
    var nameLabel: UILabel!                     //标题
    var showImageView: UIImageView!             //图片
    var combinationBtn: UIButton!               //组合购标
    var brandLabel: UILabel!                    //品牌
    var countLabel: UILabel!                    //数量
    var unitLabel: UILabel!                     //单位
    var specificationLabel: UILabel!            //规格
    var costLabel: UILabel!                     //进货价
    var priceLabel: UILabel!                    //总价
    
    var isCusMaterials = false //是否是补差价
    
    let textFont = UIFont.systemFont(ofSize: 11)

    var detailBlock: (()->())?                          //详情block
    var selectedBlock: ((_ isCheck: Bool)->())?         //选中block
    var isOneKeyBuy = false
    var purchaseMaterial: PurchaseMaterialModel? {
        
        didSet {
            prepareLabelText()
            var materialsCount: Double = 0
            
            selectedBtn.isSelected = purchaseMaterial?.isSelectCheck ?? false
            
            if let valueStr = purchaseMaterial?.countInt {
                
                materialsCount = valueStr
                let countStr = valueStr.notRoundingString(afterPoint: 2)
                
                countLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "数量: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "\(countStr)", color: PublicColor.commonTextColor, font: textFont)])
            }
            if isOneKeyBuy {
                if let valueStr = purchaseMaterial?.materials?.materialsName {
                    nameLabel.text = valueStr
                }
                
                if !showImageView.addImage(purchaseMaterial?.materials?.materialsImageUrl) {
                    showImageView.image = UIImage.init(named: "loading")
                }
                if let valueStr = purchaseMaterial?.materials?.brandName {
                    brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
                }
                if let valueStr = purchaseMaterial?.materials?.skuAttr1 {
                    specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
                }
                
                //单位
                var unitType: Int = 0
                unitType = Int.init(string: purchaseMaterial?.materials?.materialsUnitType ?? "0") ?? 0
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitType)", fieldB: "label")
                if unitStr.count > 0 {
                    unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: unitStr, color: PublicColor.commonTextColor, font: textFont)])
                }
                
                //进货价
                var priceSupply: Double = 0
                
                if let valueStr = Double.init(string: purchaseMaterial?.materials?.materialsPriceSupply1 ?? "0")  {
                    priceSupply = valueStr
                }
                
                if purchaseMaterial?.materials?.isOneSell == 2 {
                    combinationBtn.isHidden = false
                    costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "***", color: PublicColor.commonTextColor, font: textFont)])
                    
                    priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "***", color: PublicColor.orangeLabelColor, font: textFont)])
                } else {
                    combinationBtn.isHidden = true
                    let moneyStr = priceSupply.notRoundingString(afterPoint: 2)
                    if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "销售价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                        
                        let moneySumStr = (priceSupply*materialsCount).notRoundingString(afterPoint: 2)
                        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneySumStr, color: PublicColor.orangeLabelColor, font: textFont)])
                    } else {
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                        
                        let moneySumStr = (priceSupply*materialsCount).notRoundingString(afterPoint: 2)
                        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneySumStr, color: PublicColor.orangeLabelColor, font: textFont)])
                    }
                    
                }
            } else {
                if let valueStr = purchaseMaterial?.materials?.materials?.name {
                    nameLabel.text = valueStr
                }
                
                if !showImageView.addImage(purchaseMaterial?.materials?.image) {
                    showImageView.image = UIImage.init(named: "loading")
                }
                if let valueStr = purchaseMaterial?.materials?.brandName {
                    brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
                }
                if let valueStr = purchaseMaterial?.materials?.skuAttr1 {
                    specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
                }
                
                //单位
                unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: purchaseMaterial?.materials?.unitTypeName ?? "无", color: PublicColor.commonTextColor, font: textFont)])
                
                //进货价
                var priceSupply: Double = 0
                
                if let valueStr = purchaseMaterial?.materials?.price1?.doubleValue  {
                    priceSupply = valueStr
                }
                
                if purchaseMaterial?.materials?.materials?.isOneSell == 2 {
                    combinationBtn.isHidden = false
                    costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "***", color: PublicColor.commonTextColor, font: textFont)])
                    
                    priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "***", color: PublicColor.orangeLabelColor, font: textFont)])
                } else {
                    combinationBtn.isHidden = true
                    if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                        if let valueStr = purchaseMaterial?.materials?.priceSell?.doubleValue  {
                            priceSupply = valueStr
                        }
                        let moneyStr = priceSupply.notRoundingString(afterPoint: 2)
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "销售价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                        
                        let moneySumStr = (priceSupply*materialsCount).notRoundingString(afterPoint: 2)
                        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneySumStr, color: PublicColor.orangeLabelColor, font: textFont)])
                    } else {
                        let moneyStr = priceSupply.notRoundingString(afterPoint: 2)
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.commonTextColor, font: textFont)])
                        
                        let moneySumStr = (priceSupply*materialsCount).notRoundingString(afterPoint: 2)
                        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneySumStr, color: PublicColor.orangeLabelColor, font: textFont)])
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
        
        //自定义分割线
        let separatorView = UIView()
        separatorView.backgroundColor = PublicColor.backgroundViewColor
        contentView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //选中按钮
        selectedBtn = UIButton.init(type: .custom)
        selectedBtn.setImage(UIImage.init(named: "car_unchecked"), for: .normal)
        selectedBtn.setImage(UIImage.init(named: "car_checked"), for: .selected)
        selectedBtn.addTarget(self, action: #selector(selectedAction(_:)), for: .touchUpInside)
        contentView.addSubview(selectedBtn)
        
        selectedBtn.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(50)
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
            make.centerY.equalToSuperview()
            make.left.equalTo(selectedBtn.snp.right)
            make.width.height.equalTo(70)
        }
        
        combinationBtn = UIButton()
        combinationBtn.setBackgroundImage(UIImage.init(named: "comBuy"), for: .normal)
        showImageView.addSubview(combinationBtn)
        combinationBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        combinationBtn.isHidden = true
        
        //图片点击手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(detailAction))
        tapOne.numberOfTapsRequired = 1
        showImageView.addGestureRecognizer(tapOne)
        
        //商品标题
        nameLabel = UILabel()
        nameLabel.text = "产品名未知"
        nameLabel.isUserInteractionEnabled = true
        nameLabel.textColor = PublicColor.commonTextColor
        nameLabel.font = UIFont.boldSystemFont(ofSize: 13)
        contentView.addSubview(nameLabel)
        
        let tapOne1 = UITapGestureRecognizer(target: self, action: #selector(detailAction))
        tapOne1.numberOfTapsRequired = 1
        nameLabel.addGestureRecognizer(tapOne1)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(showImageView.snp.right).offset(10)
            make.top.equalTo(showImageView).offset(-1)
            make.right.lessThanOrEqualTo(-30)
            make.height.equalTo(15)
        }
        
        //品牌
        brandLabel = UILabel()
        brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(brandLabel)
        
        brandLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.height.equalTo(13)
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
            make.left.height.equalTo(brandLabel)
            make.top.equalTo(brandLabel.snp.bottom).offset(5)
//            make.centerY.height.equalTo(brandLabel)
//            make.left.equalTo(countLabel.snp.right).offset(5)
//            make.right.equalTo(-20)
        }
        
        //规格
        specificationLabel = UILabel()
        specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(specificationLabel)
        
        specificationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(unitLabel.snp.right).offset(10)
            make.centerY.height.equalTo(unitLabel)
//            make.left.height.equalTo(brandLabel)
//            make.top.equalTo(brandLabel.snp.bottom).offset(5)
//            make.right.equalTo(unitLabel)
        }
        
        //进货价
        costLabel = UILabel()
        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(costLabel)
        
        costLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(brandLabel)
            make.top.equalTo(specificationLabel.snp.bottom).offset(5)
        }
        
        //总价
        priceLabel = UILabel()
        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.emphasizeTextColor, font: textFont)])
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(costLabel.snp.right).offset(20)
            make.centerY.height.equalTo(costLabel)
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
        
        showImageView.image = UIImage.init(named: "loading")
        nameLabel.text = "产品名未知"
        brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "无", color: PublicColor.commonTextColor, font: textFont)])
        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont)])
    }

    
    //选中
    @objc func selectedAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
 
        if let block = selectedBlock {
            block(sender.isSelected)
        }
    }
    
    @objc func detailAction() {
        AppLog("点击了主材详情")
        if let block = detailBlock {
            block()
        }
    }
}
