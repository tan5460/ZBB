//
//  PurchaseHouseCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/25.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class PurchaseHouseCell: UITableViewCell {

    var nameLabel: UILabel!             //客户名字
    var phoneLabel: UILabel!            //客户电话
    var editBtn: UIButton!              //编辑
    var deleteBtn: UIButton!            //删除
    var acreageLabel: UILabel!          //面积
    var plotLabel: UILabel!             //小区
    
    var consigneeView: UIView!                       //收货人视图
    var complementBtn: UIButton!                      //补全按钮
    var consigneeNameLabel: UILabel!                 //收货人
    var consigneePhoneLabel: UILabel!                //收货人电话
    var consigneePlotLabel: UILabel!                 //收货人地址
    
    var deleteBlock: (()->())?          //删除block
    var editHouseBlock: (()->())?       //编辑block
    
    var isComplement: Bool = false {
        didSet {
            if isComplement {
                
                complementBtn.isHidden = false
                consigneeView.isHidden = true
                consigneeView.snp.updateConstraints { (make) in
                    make.height.equalTo(38)
                }
            }else {
                complementBtn.isHidden = true
                
                consigneeView.isHidden = false
                consigneeView.snp.updateConstraints { (make) in
                    make.height.equalTo(55)
                }
            }
        }
    }
    
    var houseModel: HouseModel? {
        
        didSet {
            
            nameLabel.text = "客户姓名："
            phoneLabel.text = "客户电话："
            plotLabel.text = "小区："

            consigneeNameLabel.text = "收货人："
            consigneePhoneLabel.text = "收货人电话："
            consigneePlotLabel.text = "收货地址："
            
            if let valueStr = houseModel?.customName {
                 nameLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "客户姓名: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            if let valueStr = houseModel?.customMobile {
                phoneLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "客户电话: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            var plotName = ""
            if let valueStr = houseModel?.plotName {
                plotName = valueStr
                
                if let roomNoStr = houseModel?.roomNo {
                    plotName += roomNoStr
                    plotLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "小区: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: plotName, color: PublicColor.commonTextColor, font: nameLabel.font)])
                }
            }
            
            if let valueStr = houseModel?.expressName, !valueStr.isEmpty{
                isComplement = false
                consigneeNameLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货人: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }else {
                isComplement = true
            }
            
            if let valueStr = houseModel?.expressTel {
                consigneePhoneLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货人电话: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
        
            if let valueStr = houseModel?.shippingAddress {
              
                consigneePlotLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货地址: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
             
            }
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func createSubView() {
        
        let textColor =  PublicColor.commonTextColor
        
        //圆角背景
        let cornerView = UIView()
        cornerView.backgroundColor = .white
        contentView.addSubview(cornerView)
        
        cornerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.right.bottom.equalToSuperview()
        }
        
        //名字
        nameLabel = UILabel()
        nameLabel.text = "姓名"
        nameLabel.textColor = textColor
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        cornerView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(18)
            make.width.equalTo(130)
        }
        
        //电话
        phoneLabel = UILabel()
        phoneLabel.text = "电话"
        phoneLabel.textColor = PublicColor.minorTextColor
        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        cornerView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.centerY.equalTo(nameLabel)
            make.right.equalTo(-15)
        }
        
        //小区
        plotLabel = UILabel()
        plotLabel.text = "小区:"
        plotLabel.textColor = textColor
        plotLabel.font = UIFont.systemFont(ofSize: 13)
        cornerView.addSubview(plotLabel)
        
        plotLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(15)
            make.width.height.equalTo(15)
            make.right.equalTo(-15)
        }
        
        complementBtn = UIButton(type: .custom)
        complementBtn.setTitle("补全收货信息", for: .normal)
        complementBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        complementBtn.setTitleColor(PublicColor.emphasizeColor, for: .normal)
        complementBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        complementBtn.layer.cornerRadius = 3
        complementBtn.layer.borderColor = PublicColor.emphasizeColor.cgColor
        complementBtn.layer.borderWidth = 1
        complementBtn.isHidden = true
        complementBtn.addTarget(self, action: #selector(editHouseAction), for: .touchUpInside)
        cornerView.addSubview(complementBtn)
        
        complementBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.width.equalTo(85)
            make.height.equalTo(25)
            make.top.equalTo(plotLabel.snp.bottom).offset(15)
        }
        
        //收货人背景
        consigneeView = UIView()
        consigneeView.backgroundColor = .white
        contentView.addSubview(consigneeView)
        
        consigneeView.snp.makeConstraints { (make) in
            make.top.equalTo(plotLabel.snp.bottom).offset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(55)
        }
       
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.navigationLineColor
        consigneeView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(15)
            make.height.equalTo(1)
            make.right.equalTo(-15)
        }
        
        //收货人
        consigneeNameLabel = UILabel()
        consigneeNameLabel.text = "收货人"
        consigneeNameLabel.textColor = PublicColor.minorTextColor
        consigneeNameLabel.font = UIFont.systemFont(ofSize: 13)
        consigneeView.addSubview(consigneeNameLabel)
        
        consigneeNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(12)
            make.width.equalTo(130)
        }
        
        //收货人电话
        consigneePhoneLabel = UILabel()
        consigneePhoneLabel.text = "收货人电话"
        consigneePhoneLabel.textColor = PublicColor.minorTextColor
        consigneePhoneLabel.font = nameLabel.font
        consigneeView.addSubview(consigneePhoneLabel)
        
        consigneePhoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(consigneeNameLabel.snp.right).offset(5)
            make.centerY.equalTo(consigneeNameLabel)
            make.right.equalTo(-15)
        }
        
        //收货人小区
        consigneePlotLabel = UILabel()
        consigneePlotLabel.text = "收货地址"
        consigneePlotLabel.textColor = PublicColor.minorTextColor
        consigneePlotLabel.font = UIFont.systemFont(ofSize: 13)
        consigneeView.addSubview(consigneePlotLabel)
        
        consigneePlotLabel.snp.makeConstraints { (make) in
            make.top.equalTo(consigneeNameLabel.snp.bottom).offset(5)
            make.left.equalTo(15)
            make.width.equalTo(15)
            make.right.equalTo(-15)
        }
        
        
        //编辑
        editBtn = UIButton(type: .custom)
        editBtn.setTitle("编辑", for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        editBtn.setTitleColor(textColor, for: .normal)
        editBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        editBtn.setImage(UIImage.init(named: "house_edit"), for: .normal)
        editBtn.addTarget(self, action: #selector(editHouseAction), for: .touchUpInside)
        cornerView.addSubview(editBtn)
        
        editBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-10)
            make.left.equalTo(15)
            make.width.equalTo(50)
            make.height.equalTo(30)
            make.top.equalTo(consigneeView.snp.bottom).offset(3)
        }
        
        editBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        editBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        
        
        //删除
        deleteBtn = UIButton(type: .custom)
        deleteBtn.setTitle("删除", for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        deleteBtn.setTitleColor(textColor, for: .normal)
        deleteBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        deleteBtn.setImage(UIImage.init(named: "house_delete"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        cornerView.addSubview(deleteBtn)
        
        deleteBtn.snp.makeConstraints { (make) in
            make.centerY.width.height.equalTo(editBtn)
            make.left.equalTo(editBtn.snp.right).offset(10)
        }
        
        deleteBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        deleteBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
    }
    
    //删除工地
    @objc func deleteAction() {
        
        if let block = deleteBlock {
            block()
        }
    }
    
    //编辑工地
    @objc func editHouseAction() {
        
        if let block = editHouseBlock {
            block()
        }
    }

}
