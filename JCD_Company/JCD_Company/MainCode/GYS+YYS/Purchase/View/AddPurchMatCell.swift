//
//  AddPurchMatCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 19.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class AddPurchMatCell: UITableViewCell {

    var nameLabel: UILabel!                     //标题
    var showImageView: UIImageView!             //图片
    var brandLabel: UILabel!                    //品牌
    var unitLabel: UILabel!                     //单位
    var specificationLabel: UILabel!            //规格
    var costLabel: UILabel!                     //会员价
    var priceLabel: UILabel!                    //平台价
    
    let textFont = UIFont.systemFont(ofSize: 11)
    var addBlock: (()->())?
    
    var materialModel: MaterialsModel? {
        didSet {
            
            prepareLabelText()
            
            if let valueStr = materialModel?.materials?.name {
                nameLabel.text = valueStr
            }
            if !showImageView.addImage(materialModel?.image) {
                showImageView.image = UIImage.init(named: "loading")
            }
            if let valueStr = materialModel?.brandName {
                brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
            }
            
            //单位
            unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: materialModel?.unitTypeName ?? "无", color: PublicColor.commonTextColor, font: textFont)])
            
            if let valueStr = materialModel?.skuAttr1 {
                specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: textFont)])
            }
            
            //会员价
            var priceCost: Double = 0
            
            if let valueStr = materialModel?.price?.doubleValue {
                priceCost = valueStr
            }
            let priceCostStr = priceCost.notRoundingString(afterPoint: 2)
            costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: priceCostStr, color: PublicColor.orangeLabelColor, font: textFont)])
            
            //进货价
            var priceSupply: Double = 0
            
            if let valueStr = materialModel?.priceCustom?.doubleValue {
                priceSupply = valueStr
            }
            
            let moneyStr = priceSupply.notRoundingString(afterPoint: 2)
            priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "销售价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: moneyStr, color: PublicColor.minorTextColor, font: textFont)])
            priceLabel.isHidden = true
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
            make.left.equalTo(12)
            make.width.height.equalTo(70)
        }
        
        
        //商品标题
        nameLabel = UILabel()
        nameLabel.text = "产品名未知"
        nameLabel.textColor = PublicColor.commonTextColor
        nameLabel.font = UIFont.boldSystemFont(ofSize: 13)
        contentView.addSubview(nameLabel)
        
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
            make.width.equalTo(120)
        }
        
        //单位
        unitLabel = UILabel()
        unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(unitLabel)
        
        unitLabel.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(brandLabel)
            make.left.equalTo(brandLabel.snp.right).offset(5)
            make.right.equalTo(-60)
        }
        
        //规格
        specificationLabel = UILabel()
        specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(specificationLabel)
        
        specificationLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(brandLabel)
            make.top.equalTo(brandLabel.snp.bottom).offset(5)
            make.right.equalTo(unitLabel)
        }
        
        //会员价
        costLabel = UILabel()
        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        contentView.addSubview(costLabel)
        
        costLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(brandLabel)
            make.top.equalTo(specificationLabel.snp.bottom).offset(5)
        }
        
        //平台销售价
        priceLabel = UILabel()
        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "销售价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont)])
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(costLabel.snp.right).offset(20)
            make.centerY.height.equalTo(costLabel)
        }
        
        //添加
        let addBtn = UIButton()
        addBtn.setImage(UIImage.init(named: "sureOrder_add"), for: .normal)
        addBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        contentView.addSubview(addBtn)
        
        addBtn.snp.makeConstraints { (make) in
            make.right.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
    }
    
    func prepareLabelText() {
        
        showImageView.image = UIImage.init(named: "loading")
        nameLabel.text = "产品名未知"
        brandLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "品牌: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        unitLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "单位: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        specificationLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "规格: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.commonTextColor, font: textFont)])
        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "销售价: ", color: PublicColor.minorTextColor, font: textFont), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont)])
    }
    
    //添加才主材
    @objc func addAction() {
        
        if let block = addBlock {
            block()
        }
    }
}
