//
//  PlaceOrderCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/1.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class PlaceOrderCell: UITableViewCell {
    var showImageView: UIImageView!             //图片
    var singleImage: UIImageView!               //单品角标
    var combinationBtn: UIButton!            //组合购标
    var nameBtn: UIButton!                      //主材名
    var brandLabel: UILabel!                    //品牌
    var priceTitleLabel: UILabel!               //价格标题
    var priceLabel: UILabel!                    //价格
    var unitLabel: UILabel!                     //单位
    var countLabel: UILabel!                    //数量
    var remarksBtn: UIButton!                   //备注按钮
    var detailBlock: (()->())?                  //详情block
    var remarkBlock: (()->())?                  //备注block
    var indexPath: IndexPath!                   //单元格下标
    var enterType: ShopCartEnterType = .fromCart
    var activityType = 0
    var detailType: MaterialsDetailType?
    var currentSKUModel: MaterialsSkuListModel?
    var isOneKey: Bool = false
    var materialsModel: MaterialsModel? {
        didSet {
            showImageView.image = UIImage.init(named: "order_material_back")
            nameBtn.setTitle("产品名缺失", for: .normal)
            nameBtn.isEnabled = true
            brandLabel.isHidden = false
            unitLabel.text = "单位:无"
            priceTitleLabel.text = "销售价:"
            
            priceLabel.text = " "
            remarksBtn.setTitle("点击添加备注", for: .normal)
            remarksBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0xB3B3B3), for: .normal)
            
//            unitLabel.snp.remakeConstraints { (make) in
//                make.left.equalTo(brandLabel.snp.right).offset(20)
//                make.centerY.equalTo(brandLabel)
//            }
            if isOneKey { /// vr模式一键下单采购流程
                if let imageStr = materialsModel?.image, let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
                    showImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "order_material_back"))
                } else {
                    showImageView.image = UIImage.init(named: "order_material_back")
                }
                
                singleImage.image = UIImage.init(named: "built_mark")
                singleImage.isHidden = true
                combinationBtn.isHidden = true
                countLabel.text("数量: \(materialsModel?.buyCount ?? 0)")
                
                if let nameStr = materialsModel?.materialsName {
                    nameBtn.setTitle(nameStr, for: .normal)
                }
                
                if let valueStr = materialsModel?.brandName {
                    brandLabel.text = "品牌:\(valueStr)"
                }
                if let value = materialsModel?.priceSell?.doubleValue {
                    let valueStr = value.notRoundingString( afterPoint: 2)
                    priceLabel.text = "¥ \(valueStr)"
                }
                unitLabel.text = "单位:" + (materialsModel?.unitTypeName ?? "无")
                
                if let valueStr = materialsModel?.remarks, !valueStr.isEmpty {
                    remarksBtn.setTitle(valueStr, for: .normal)
                    remarksBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x808080), for: .normal)
                }
                else {
                    remarksBtn.setTitle("点击添加备注", for: .normal)
                }
            } else {
                if enterType == .fromCart {
                    if let imageStr = materialsModel?.image, let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
                        showImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "order_material_back"))
                    } else {
                        showImageView.image = UIImage.init(named: "order_material_back")
                    }
                    
                    singleImage.image = UIImage.init(named: "built_mark")
                    if materialsModel?.materials?.isOneSell == 1 {
                        singleImage.isHidden = true
                        combinationBtn.isHidden = true
                        priceTitleLabel.text = "销售价:"
                    }else if materialsModel?.materials?.isOneSell == 2 {
                        singleImage.isHidden = true
                        combinationBtn.isHidden = false
                        priceTitleLabel.text = "市场价:"
                    } else {
                        singleImage.isHidden = true
                        combinationBtn.isHidden = true
                        priceTitleLabel.text = "销售价:"
                    }
                    
                    countLabel.text("数量: \(materialsModel?.count ?? 0)")
                    
                    if let nameStr = materialsModel?.materials?.name {
                        nameBtn.setTitle(nameStr, for: .normal)
                    }
                    
                    if let valueStr = materialsModel?.brandName {
                        brandLabel.text = "品牌:\(valueStr)"
                    }
                    if let value = materialsModel?.priceSell?.doubleValue {
                        let valueStr = value.notRoundingString( afterPoint: 2)
                        priceLabel.text = "¥ \(valueStr)"
                    }
                    if materialsModel?.materials?.isOneSell == 2 {
                        if let value = materialsModel?.priceShow?.doubleValue {
                            let valueStr = value.notRoundingString( afterPoint: 2)
                            priceLabel.text = "¥ \(valueStr)"
                        }
                        priceLabel.setLabelUnderline()
                    }
                    unitLabel.text = "单位:" + (materialsModel?.unitTypeName ?? "无")
                    
                    if let valueStr = materialsModel?.remarks, !valueStr.isEmpty {
                        remarksBtn.setTitle(valueStr, for: .normal)
                        remarksBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x808080), for: .normal)
                    }
                    else {
                        remarksBtn.setTitle("点击添加备注", for: .normal)
                    }
                } else if enterType == .fromDetail { // fromDetail
                    let skuModel = currentSKUModel
                    if showImageView.addImage(skuModel?.image) {
                        
                    } else {
                        showImageView.image = UIImage.init(named: "order_material_back")
                    }
                    singleImage.image = UIImage.init(named: "built_mark")
                    if materialsModel?.isOneSell == 2 {
                        singleImage.isHidden = true
                        combinationBtn.isHidden = false
                        priceTitleLabel.text = "市场价:"
                    } else {
                        singleImage.isHidden = true
                        combinationBtn.isHidden = true
                        priceTitleLabel.text = "销售价:"
                        if activityType == 2 {
                            priceTitleLabel.text = "一口价:"
                        } else if activityType == 3 {
                            priceTitleLabel.text = "特惠价:"
                        }
                        if detailType == .hyzx {
                            priceTitleLabel.text("专享价:")
                        }
                    }
                    
                    countLabel.text("数量: \(materialsModel?.buyCount ?? 0)")
                    
                    if let nameStr = materialsModel?.name {
                        nameBtn.setTitle(nameStr, for: .normal)
                    }
                    
                    if let valueStr = materialsModel?.brandName {
                        brandLabel.text = "品牌:\(valueStr)"
                    }
                    if activityType == 0 {
                        if let value = skuModel?.priceSell?.doubleValue {
                            let valueStr = value.notRoundingString( afterPoint: 2)
                            priceLabel.text = "¥ \(valueStr)"
                        }
                    } else {
                        if let value = skuModel?.price?.doubleValue {
                            let valueStr = value.notRoundingString( afterPoint: 2)
                            priceLabel.text = "¥ \(valueStr)"
                        }
                    }
                    if detailType == .hyzx {
                        priceTitleLabel.text("专享价:")
                        priceLabel.text = "¥ \(Decimal.init(skuModel?.activityPrice?.doubleValue ?? 0))"
                    }
                    
                    if materialsModel?.isOneSell == 2 {
                        if let value = skuModel?.priceShow?.doubleValue {
                            let valueStr = value.notRoundingString( afterPoint: 2)
                            priceLabel.text = "¥ \(valueStr)"
                        }
                        priceLabel.setLabelUnderline()
                    }
                    unitLabel.text = "单位:" + (materialsModel?.unitTypeName ?? "无")
                    
                    if let valueStr = materialsModel?.remarks, !valueStr.isEmpty {
                        remarksBtn.setTitle(valueStr, for: .normal)
                        remarksBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x808080), for: .normal)
                    }
                    else {
                        remarksBtn.setTitle("点击添加备注", for: .normal)
                    }
                } else if enterType == .fromOrderDetail { // fromDetail
                    if !showImageView.addImage(materialsModel?.materialsImageUrl) {
                        showImageView.image = UIImage.init(named: "order_material_back")
                    }
                    singleImage.image = UIImage.init(named: "built_mark")
                    if materialsModel?.materials?.isOneSell == 1 {
                        singleImage.isHidden = true
                        combinationBtn.isHidden = true
                        priceTitleLabel.text = "销售价:"
                    }else if materialsModel?.materials?.isOneSell == 2 {
                        singleImage.isHidden = true
                        combinationBtn.isHidden = false
                        priceTitleLabel.text = "市场价:"
                    } else {
                        singleImage.isHidden = true
                        combinationBtn.isHidden = true
                        priceTitleLabel.text = "销售价:"
                    }
                    
                    countLabel.text("数量: \(materialsModel?.materialsCount ?? 0)")
                    
                    if let nameStr = materialsModel?.materialsName {
                        nameBtn.setTitle(nameStr, for: .normal)
                    }
                    
                    if let valueStr = materialsModel?.brandName {
                        brandLabel.text = "品牌:\(valueStr)"
                    }
                    if let value = Double.init(string: materialsModel?.materialsPriceCustom ?? "0") {
                        let valueStr = value.notRoundingString( afterPoint: 2)
                        priceLabel.text = "¥ \(valueStr)"
                    }
                    if materialsModel?.materials?.isOneSell == 2 {
                        if let value = Double.init(string: materialsModel?.materialsPriceShow ?? "0") {
                            let valueStr = value.notRoundingString( afterPoint: 2)
                            priceLabel.text = "¥ \(valueStr)"
                        }
                        priceLabel.setLabelUnderline()
                    }
                    unitLabel.text = "单位:" + (materialsModel?.materialsUnitTypeName ?? "无")
                    
                    if let valueStr = materialsModel?.remarks, !valueStr.isEmpty {
                        remarksBtn.setTitle(valueStr, for: .normal)
                        remarksBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x808080), for: .normal)
                    }
                    else {
                        remarksBtn.setTitle("点击添加备注", for: .normal)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        //图片
        showImageView = UIImageView()
        showImageView.isUserInteractionEnabled = true
        showImageView.contentMode = .scaleAspectFit
        showImageView.layer.cornerRadius = 5
        showImageView.layer.masksToBounds = true
        showImageView.image = UIImage.init(named: "order_material_back")
        contentView.addSubview(showImageView)
        
        showImageView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.width.height.equalTo(83)
        }
        
        //图片点击手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(detailAction))
        tapOne.numberOfTapsRequired = 1
        showImageView.addGestureRecognizer(tapOne)
        
        //单品角标
        singleImage = UIImageView()
        singleImage.isHidden = true
//        singleImage.image = UIImage.init(named: "single_icon")
        singleImage.contentMode = .scaleAspectFit
        showImageView.addSubview(singleImage)
        
        singleImage.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(26)
        }
        
        combinationBtn = UIButton()
        combinationBtn.setBackgroundImage(UIImage.init(named: "comBuy"), for: .normal)
        showImageView.addSubview(combinationBtn)
        combinationBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        
        //名称
        nameBtn = UIButton(type: .custom)
        nameBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        nameBtn.contentHorizontalAlignment = .left
        nameBtn.setTitle("产品名", for: .normal)
        nameBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        nameBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        nameBtn.addTarget(self, action: #selector(detailAction), for: .touchUpInside)
        contentView.addSubview(nameBtn)
        
        nameBtn.snp.makeConstraints { (make) in
            make.top.equalTo(showImageView).offset(-2)
            make.left.equalTo(showImageView.snp.right).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(22)
        }
        
        //品牌
        brandLabel = UILabel()
        brandLabel.text = "品牌:品牌名"
        brandLabel.font = UIFont.systemFont(ofSize: 11)
        brandLabel.textColor = PublicColor.minorTextColor
        contentView.addSubview(brandLabel)
        
        brandLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameBtn.snp.bottom).offset(2)
            make.left.equalTo(nameBtn)
        }
        
        //单位
        unitLabel = UILabel()
        unitLabel.text = "单位:"
        unitLabel.font = UIFont.systemFont(ofSize: 11)
        unitLabel.textColor = PublicColor.minorTextColor
        contentView.addSubview(unitLabel)
        
        unitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(brandLabel.snp.right).offset(20)
            make.centerY.equalTo(brandLabel)
        }
        
        //价格标题
        priceTitleLabel = UILabel()
        priceTitleLabel.text = "加减价:"
        priceTitleLabel.font = UIFont.systemFont(ofSize: 11)
        priceTitleLabel.textColor = PublicColor.minorTextColor
        contentView.addSubview(priceTitleLabel)
        
        priceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameBtn)
            make.top.equalTo(brandLabel.snp.bottom).offset(5)
        }
        
        //价格
        priceLabel = UILabel()
        priceLabel.text = "0.00"
        priceLabel.font = UIFont.systemFont(ofSize: 11)
        priceLabel.textColor = PublicColor.emphasizeColor
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceTitleLabel)
            make.left.equalTo(priceTitleLabel.snp.right).offset(1)
        }
        
        countLabel = UILabel().text("数量：1")
        countLabel.font = UIFont.systemFont(ofSize: 11)
        countLabel.textColor = PublicColor.minorTextColor
        contentView.addSubview(countLabel)
        
        countLabel.snp.makeConstraints { (make) in
            make.top.equalTo(priceTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(priceTitleLabel)
        }
        
        //虚线分割
        let dashedView = UIView()
        dashedView.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "dashed_img")!)
        contentView.addSubview(dashedView)
        
        dashedView.snp.makeConstraints { (make) in
            make.top.equalTo(showImageView.snp.bottom).offset(15)
            make.left.equalTo(showImageView)
            make.right.equalTo(nameBtn)
            make.height.equalTo(0.5)
        }
        
        //备注
        let remarksTitle = UILabel()
        remarksTitle.text = "备注："
        remarksTitle.font = UIFont.systemFont(ofSize: 12)
        remarksTitle.textColor = UIColor.colorFromRGB(rgbValue: 0x808080)
        contentView.addSubview(remarksTitle)
        
        remarksTitle.snp.makeConstraints { (make) in
            make.top.equalTo(dashedView.snp.bottom).offset(13)
            make.left.equalTo(dashedView)
            make.width.equalTo(38)
        }
        
        //备注按钮
        remarksBtn = UIButton(type: .custom)
        remarksBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        remarksBtn.contentHorizontalAlignment = .left
        remarksBtn.setTitle("点击添加备注", for: .normal)
        remarksBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0xB3B3B3), for: .normal)
        remarksBtn.addTarget(self, action: #selector(remarkAction), for: .touchUpInside)
        contentView.addSubview(remarksBtn)
        
        remarksBtn.snp.makeConstraints { (make) in
            make.left.equalTo(remarksTitle.snp.right)
            make.centerY.equalTo(remarksTitle)
            make.right.equalTo(nameBtn)
            make.height.equalTo(24)
        }
        
        //下分割线
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xDBDBDB)
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    //详情
    @objc func detailAction() {
        
        if let block = detailBlock {
            block()
        }
    }
    
    
    //备注
    @objc func remarkAction() {
        
        if let block = remarkBlock {
            block()
        }
    }
}
