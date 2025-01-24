//
//  CustomerCell.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/28.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class HouseCell: UITableViewCell {

    var nameLabel: UILabel!             //客户名字
    var phoneLabel: UILabel!            //客户电话
    var selectedLabel: UILabel!         //选中地址
    var editBtn: UIButton!              //编辑
    var deleteBtn: UIButton!            //删除
    var headerView: UIImageView!        //头像
    var acreageLabel: UILabel!          //面积
    var plotLabel: UILabel!             //小区
    var addressLabel: UILabel!          //地址
    var roomNumberLabel: UILabel!       //房间号
    
    var deleteBlock: (()->())?          //删除block
    var editHouseBlock: (()->())?       //编辑block
    
    var houseModel: HouseModel? {
        
        didSet {
            
            nameLabel.text = "姓名"
            phoneLabel.text = "电话"
            acreageLabel.text = "面积: 未知"
            plotLabel.text = "小区: 未知"
            roomNumberLabel.text = "房间号: 未知"
            addressLabel.text = "地址: 未知"
            
            if let valueStr = houseModel?.customName {
                nameLabel.text = valueStr
            }
            
            if let valueStr = houseModel?.customMobile {
                phoneLabel.text = valueStr
            }
            
            if let acreageStr = houseModel?.space?.doubleValue {
                let acreage = acreageStr.notRoundingString(afterPoint: 2)
                acreageLabel.text = String.init(format: "面积: %@㎡", acreage)
            }
            
            if let valueStr = houseModel?.plotName {
                plotLabel.text = "小区: \(valueStr)"
            }
            
            if let roomStr = houseModel?.roomNo {
                roomNumberLabel.text = "房间号: \(roomStr)"
            }
            
            if let valueStr = houseModel?.address {
                addressLabel.text = "地址: \(valueStr)"
            }
            
            var headerImage = UIImage.init(named: "headerImage_man")
            
            if let valueType = Int(houseModel?.customSex ?? "0"){
                if valueType == 2 {
                    headerImage = UIImage.init(named: "headerImage_woman")
                }
            }
            
            headerView.image = headerImage
            if let imageStr = houseModel?.headUrl {
                if let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
//                    headerView.kf.setImage(with: imageUrl, placeholder: headerImage)
                    headerView.kf.setImage(with: imageUrl, placeholder: headerImage)
                }
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
            make.height.equalTo(150)
            make.left.right.bottom.equalToSuperview()
        }
        
        //名字
        nameLabel = UILabel()
        nameLabel.text = "姓名"
        nameLabel.textColor = textColor
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        cornerView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.top.equalToSuperview().offset(13)
        }
        
        //电话
        phoneLabel = UILabel()
        phoneLabel.text = "电话"
        phoneLabel.textColor = PublicColor.minorTextColor
        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        cornerView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(13)
            make.top.equalTo(nameLabel)
        }
        
        //选中地址
        selectedLabel = UILabel()
        selectedLabel.isHidden = true
        selectedLabel.text = "选中工地"
        selectedLabel.textColor = PublicColor.emphasizeTextColor
        selectedLabel.textAlignment = .center
        selectedLabel.font = UIFont.systemFont(ofSize: 10)
        selectedLabel.layer.borderWidth = 1
        selectedLabel.layer.borderColor = selectedLabel.textColor.cgColor
        selectedLabel.layer.cornerRadius = 4
        cornerView.addSubview(selectedLabel)
        
        selectedLabel.snp.makeConstraints { (make) in
            make.left.equalTo(phoneLabel.snp.right).offset(20)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(50)
            make.height.equalTo(15)
        }
        
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
            make.centerY.equalTo(nameLabel)
            make.right.equalTo(-10)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        deleteBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        deleteBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        
        //编辑
        editBtn = UIButton(type: .custom)
        editBtn.setTitle("编辑", for: .normal)
        editBtn.titleLabel?.font = deleteBtn.titleLabel?.font
        editBtn.setTitleColor(textColor, for: .normal)
        editBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        editBtn.setImage(UIImage.init(named: "house_edit"), for: .normal)
        editBtn.addTarget(self, action: #selector(editHouseAction), for: .touchUpInside)
        cornerView.addSubview(editBtn)
        
        editBtn.snp.makeConstraints { (make) in
            make.centerY.width.height.equalTo(deleteBtn)
            make.right.equalTo(deleteBtn.snp.left).offset(-10)
        }
        
        editBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        editBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.navigationLineColor
        cornerView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(13)
            make.height.equalTo(1)
        }
        
        //头像
        let headerHeight: CGFloat = 45
        headerView = UIImageView()
        headerView.contentMode = .scaleAspectFit
        headerView.image = UIImage.init(named: "headerImage_man")
        headerView.layer.cornerRadius = headerHeight/2
        headerView.layer.masksToBounds = true
        headerView.backgroundColor = UIColor.init(red: 234.0/255, green: 233.0/255, blue: 234.0/255, alpha: 1)
        cornerView.addSubview(headerView)
        
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(lineView.snp.bottom).offset(15)
            make.width.equalTo(headerHeight)
            make.height.equalTo(headerHeight)
        }
        
       
        //小区
        plotLabel = UILabel()
        plotLabel.text = "小区:"
        plotLabel.textColor = textColor
        plotLabel.font = UIFont.systemFont(ofSize: 13)
        cornerView.addSubview(plotLabel)
        
        plotLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.top).offset(3)
            make.left.equalTo(headerView.snp.right).offset(16)
            make.right.equalTo(-16)
        }
        
        //地址
        addressLabel = UILabel()
        addressLabel.text = "地址:"
        addressLabel.textColor = textColor
        addressLabel.font = UIFont.systemFont(ofSize: 13)
        cornerView.addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(plotLabel)
            make.top.equalTo(plotLabel.snp.bottom).offset(3)
            make.right.equalTo(plotLabel)
        }
        
        //面积
        acreageLabel = UILabel()
        acreageLabel.text = "面积:"
        acreageLabel.textColor = PublicColor.minorTextColor
        acreageLabel.font = UIFont.systemFont(ofSize: 11)
        cornerView.addSubview(acreageLabel)
        
        acreageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(14)
            make.left.equalTo(plotLabel)
            make.width.equalTo(110)
        }
        
        //房间号
        roomNumberLabel = UILabel()
        roomNumberLabel.text = "房间号:"
        roomNumberLabel.textColor = PublicColor.minorTextColor
        roomNumberLabel.font = acreageLabel.font
        cornerView.addSubview(roomNumberLabel)
        
        roomNumberLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(acreageLabel)
            make.left.equalTo(acreageLabel).offset(120)
            make.right.equalTo(-10)
        }
        
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
