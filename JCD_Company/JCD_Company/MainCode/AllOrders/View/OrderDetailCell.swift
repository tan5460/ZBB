//
//  OrderDetailCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/2/28.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class OrderDetailCell: UITableViewCell {
    
    var showImageView: UIImageView!                     //图片
    var singleImage: UIImageView!                       //单品角标
    var comBuy: UIButton!                               //组合购标
    var nameBtn: UIButton!                              //标题
    var priceTitle: UILabel!                            //价格标题
    var priceLabel: UILabel!                            //市场价
    var unitLabel: UILabel!                             //单位
    var brandLabel: UILabel!                            //品牌
    var remarkView: UIView!                             //备注背景
    var remarkTitle: UILabel!                           //备注标题
    var remarksLabel: UILabel!                          //备注
    var openBtn: UIButton!                              //展开收起按钮
    var countLabel: UILabel!                            //数量
    var orderType: NSNumber = 2                         //订单类型 1、自由组合 2、套餐下单 3、自由开单
    
    var detailBlock: (()->())?                          //详情block
    var openBlock: (()->())?                            //展开收起block
    let textFont = UIFont.systemFont(ofSize: 12)
    
    var isMaterials = true
    var isOpen: Bool = false {
        didSet {
            updateOpenFrame()
        }
    }
    
    var materialModel: MaterialsModel? {
        
        didSet {
            
            isMaterials = true
            showImageView.image = UIImage.init(named: "loading")
            priceTitle.text = "市场价:"
            priceLabel.text = "未定价"
            nameBtn.setTitle("产品名", for: .normal)
            nameBtn.isEnabled = false
            unitLabel.text = "单位: 无"
            brandLabel.text = "品牌: 无"
            countLabel.text = "数量: 1"
            remarksLabel.text = "无"
            
            if showImageView.addImage(materialModel?.materialsImageUrl) {
                 
            } else {
                showImageView.image = UIImage.init(named: "loading")
            }
            
            singleImage.image = UIImage.init(named: "built_mark")
            singleImage.isHidden = true
            
            if materialModel?.isOneSell == 1 {
                singleImage.isHidden = true
                comBuy.isHidden = true
                
            } else if materialModel?.isOneSell == 2 {
                singleImage.isHidden = true
                comBuy.isHidden = false
            } else {
                singleImage.isHidden = true
                comBuy.isHidden = true
            }
                     
            if let valueStr = materialModel?.materialsName {
                nameBtn.setTitle(valueStr, for: .normal)
                nameBtn.isEnabled = true
            }
            
            if materialModel?.isOneSell == 2 {
                priceTitle.text = "市场价:"
                if let value = materialModel?.materialsPriceShow {
                    let value1 = Double.init(string: value)
                    let valueStr = value1?.notRoundingString(afterPoint: 2)
                    priceLabel.text = String.init(format: "￥%@", valueStr ?? "0")
                }
                priceLabel.setLabelUnderline()
            } else {
                priceTitle.text = "销售价:"
                if let value = materialModel?.materialsPriceCustom {
                    let value1 = Double.init(string: value)
                    let valueStr = value1?.notRoundingString(afterPoint: 2)
                    priceLabel.text = String.init(format: "￥%@", valueStr ?? "")
                }
            }
            
            unitLabel.text = "单位: \(materialModel?.materialsUnitTypeName ?? "")"
            
            if let valueStr = materialModel?.brandName {
                brandLabel.text = "品牌: \(valueStr)"
            }
            
            if let valueStr = materialModel?.materialsCount {
                let value = Double(valueStr)
                let values = value.notRoundingString(afterPoint: 2)
                countLabel.text = String.init(format: "数量: %@", values)
            }
            
            if let valueStr = materialModel?.remarks {
                if valueStr != "" {
                    remarksLabel.text = valueStr
                }
                
                let strWidth: Int = Int(valueStr.getLabWidth(font: textFont))
                let labelWidth: Int = Int(PublicSize.screenWidth) - 15  - 38 - 5 - 15
                
                if strWidth < labelWidth {
                    openBtn.isHidden = true
                }else {
                    openBtn.isHidden = false
                }
            }
            
            if let valueStr = materialModel?.remarkIsOpen {
                isOpen = valueStr
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
        self.selectionStyle = .none
        createSubView()
    }
    
    func createSubView() {
        
        //自定义分割线
        let separatorView = UIView()
        separatorView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
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
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.width.height.equalTo(70)
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
        
        comBuy = UIButton()
        comBuy.setBackgroundImage(UIImage.init(named: "comBuy"), for: .normal)
        showImageView.addSubview(comBuy)
        comBuy.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        
        //商品标题
        nameBtn = UIButton(type: .custom)
        nameBtn.contentHorizontalAlignment = .left
        nameBtn.titleLabel?.numberOfLines = 2
        nameBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        nameBtn.setTitle("产品名", for: .normal)
        nameBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        nameBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        nameBtn.addTarget(self, action: #selector(detailAction), for: .touchUpInside)
        contentView.addSubview(nameBtn)
        
        nameBtn.snp.makeConstraints { (make) in
            make.top.equalTo(showImageView)
            make.left.equalTo(showImageView.snp.right).offset(10)
            make.right.equalTo(-15)
        }
        
        //品牌
        brandLabel = UILabel()
        brandLabel.text = "品牌: 东鹏瓷砖"
        brandLabel.textColor = PublicColor.minorTextColor
        brandLabel.font = textFont
        contentView.addSubview(brandLabel)
        
        brandLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameBtn)
            make.top.equalTo(nameBtn.snp.bottom).offset(5)
            make.right.equalTo(contentView.snp.right).offset(-130)
        }
        
        //市场价
        priceTitle = UILabel()
        priceTitle.text = "市场价:"
        priceTitle.textColor = PublicColor.minorTextColor
        priceTitle.font = textFont
        contentView.addSubview(priceTitle)
        
        priceTitle.snp.makeConstraints { (make) in
            make.left.equalTo(brandLabel)
            make.bottom.equalTo(showImageView)
        }
        
        //价格
        priceLabel = UILabel()
        priceLabel.text = ""
        priceLabel.textColor = priceTitle.textColor
        priceLabel.font = textFont
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceTitle.snp.right)
            make.centerY.equalTo(priceTitle)
            make.width.equalTo(80)
        }
        
        //单位
        unitLabel = UILabel()
        unitLabel.text = "单位:"
        unitLabel.textColor = priceTitle.textColor
        unitLabel.font = textFont
        contentView.addSubview(unitLabel)
        
        unitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView.snp.right).offset(-110)
            make.centerY.equalTo(brandLabel)
        }
        
        
        
        //数量
        countLabel = UILabel()
        countLabel.text = "数量: 1"
        countLabel.textColor = priceTitle.textColor
        countLabel.font = textFont
        contentView.addSubview(countLabel)
        
        countLabel.snp.makeConstraints { (make) in
            make.left.equalTo(unitLabel)
            make.centerY.equalTo(priceTitle)
        }
        
        //备注背景
        remarkView = UIView()
        remarkView.backgroundColor = .white
        contentView.addSubview(remarkView)
        remarkView.clipsToBounds = true
        
        remarkView.snp.makeConstraints { (make) in
            make.left.equalTo(showImageView)
            make.right.equalTo(nameBtn)
            make.top.equalTo(showImageView.snp.bottom).offset(15)
            make.bottom.equalTo(-6)

        }
        
        let sepaView = UIView()
        sepaView.backgroundColor = PublicColor.partingLineColor
        remarkView.addSubview(sepaView)
        
        sepaView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        //备注
        remarkTitle = UILabel()
        remarkTitle.text = "备注："
        remarkTitle.textColor = UIColor.colorFromRGB(rgbValue: 0x747474)
        remarkTitle.font = textFont
        remarkView.addSubview(remarkTitle)
        
        remarkTitle.snp.makeConstraints { (make) in
            make.left.equalTo(5)
            make.top.equalTo(12)
            make.width.equalTo(38)
        }
        
        remarksLabel = UILabel()
        remarksLabel.numberOfLines = 1
        remarksLabel.textColor = remarkTitle.textColor
        remarksLabel.font = textFont
        remarkView.addSubview(remarksLabel)
        
        remarksLabel.snp.makeConstraints { (make) in
            make.left.equalTo(remarkTitle.snp.right)
            make.top.equalTo(remarkTitle)
            make.right.equalTo(-30)
            make.bottom.equalTo(-11)
        }
        
        //展开
        openBtn = UIButton(type: .custom)
        openBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        openBtn.setImage(UIImage.init(named: "remark_down_icon"), for: .normal)
        openBtn.setImage(UIImage.init(named: "remark_up_icon"), for: .selected)
        openBtn.addTarget(self, action: #selector(openAction), for: .touchUpInside)
        remarkView.addSubview(openBtn)
        
        openBtn.snp.makeConstraints { (make) in
            make.height.equalTo(30)
            make.width.equalTo(30)
            make.right.equalTo(0)
            make.bottom.equalTo(-5)
        }
        

    }
    
    func updateOpenFrame() {
        
        if self.isOpen {
            self.remarksLabel.numberOfLines = 0
            self.openBtn.isSelected = true
        }
        else {
            self.remarksLabel.numberOfLines = 1
            self.openBtn.isSelected = false
        }
        self.layoutSubviews()
    }
    
    @objc func detailAction() {
        AppLog("点击了主材详情")
        if let block = detailBlock {
            block()
        }
    }
    
    @objc func openAction() {
        
        let newIsOpen = !isOpen
        
        materialModel?.remarkIsOpen = newIsOpen
        
        if let block = openBlock {
            block()
        }
    }
    
}
