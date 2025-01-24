//
//  ServiceCell.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/11/1.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog

class ServiceCell: UITableViewCell {
    
    var nameLabel: UILabel!                 //施工名
    var categoryLabel: UILabel!             //分类
    var priceLabel: UILabel!                //价格
    var unitLabel: UILabel!                 //单位
    var addShopBtn: UIButton!               //加入购物车
    var addServiceBtn: UIButton!            //添加此施工
    var imgView: UIImageView!                //施工图片
    var imageType: String = "0" {
        didSet {
            var imgName = ""
            switch imageType {
            case "1":
                imgName = "reorganization_img"
            case "2":
                imgName = "soilpave_img"
            case "3":
                imgName = "ceiling_img"
            case "4":
                imgName = "wallspace_img"
            case "5":
                imgName = "woodworking_img"
            case "6":
                imgName = "painter_img"
            case "7":
                imgName = "bricklayer_img"
            case "8":
                imgName = "waterproofing_img"
            case "9":
                imgName = "administrative_img"
            case "10":
                imgName = "whitefuel_img"
            case "11":
                imgName = "other_img"
            default:
                imgName = "other_img"
            }
            imgView.image = UIImage(named: imgName)
        }
    }
    
    var addServiceBlock: (()->())?          //添加施工block
    
    var addServiceType: AddServiceType? {
        
        didSet {
            if addServiceType == .service {
                addShopBtn.isHidden = false
                addServiceBtn.isHidden = true
            }
            else {
                addShopBtn.isHidden = true
                addServiceBtn.isHidden = false
            }
        }
    }
    
    var serviceModel: ServiceModel? {
        
        didSet {
            nameLabel.text = ""
            categoryLabel.text = ""
            priceLabel.text = "未定价"
            
            if let valueStr = serviceModel?.name {
                nameLabel.text = valueStr
            }
            
            if let valueType = serviceModel?.category?.stringValue {
                if AppData.serviceCategoryList.count > 0 {
                    categoryLabel.text = "类别：" + Utils.getFieldValInDirArr(arr: AppData.serviceCategoryList, fieldA: "value", valA: valueType, fieldB: "label")
                    
                    imageType = valueType
                }
            }
            
            if let value = serviceModel?.cusPrice?.doubleValue {
                let valueStr = value.notRoundingString( afterPoint: 2)
                priceLabel.text = String.init(format: "￥%@", valueStr)
                
                if let unitValue = serviceModel?.unitType?.intValue {
                    let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                    if unitStr.count > 0 {
                        priceLabel.text = String.init(format: "￥%@", valueStr)
                        unitLabel.text = String.init(format: "/%@", unitStr)
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
        
        //圆角背景
        let backView = UIView()
        backView.layer.cornerRadius = 10
        backView.backgroundColor = .white
        contentView.addSubview(backView)
        
        backView.snp.makeConstraints { (make) in
            make.top.left.equalTo(5)
            make.right.equalTo(-5)
            make.bottom.equalToSuperview()
        }
        
        //施工图标
        imgView = UIImageView()
        imgView.image = UIImage.init(named: "other_img")
        backView.addSubview(imgView)
        
        imgView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(75)
        }
        
        //名称
        nameLabel = UILabel()
        nameLabel.text = "施工名"
        nameLabel.numberOfLines = 2
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.textColor = PublicColor.commonTextColor
        backView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imgView.snp.right).offset(14)
            make.top.equalTo(imgView.snp.top).offset(3)
            make.right.equalTo(-65)
            
        }
        
        //分类
        categoryLabel = UILabel()
        categoryLabel.text = "水电及安装"
        categoryLabel.font = UIFont.systemFont(ofSize: 11)
        categoryLabel.textColor = PublicColor.minorTextColor
        backView.addSubview(categoryLabel)
        
        categoryLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(nameLabel)
            make.centerY.equalTo(imgView).offset(5)
        }
        
        //价格
        priceLabel = UILabel()
        priceLabel.text = "￥30.00"
        priceLabel.font = UIFont.boldSystemFont(ofSize: 15)
        priceLabel.textColor =  PublicColor.emphasizeTextColor
        backView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.bottom.equalTo(imgView.snp.bottom).offset(-5)
        }
        
        //单位
        unitLabel = UILabel()
        unitLabel.text = "/平米"
        unitLabel.font = UIFont.systemFont(ofSize: 11)
        unitLabel.textColor = PublicColor.minorTextColor
        backView.addSubview(unitLabel)
        
        unitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right)
            make.bottom.equalTo(imgView.snp.bottom).offset(-6)
        }
        
        //加购物车
        addShopBtn = UIButton(type: .custom)
        addShopBtn.setImage(UIImage.init(named: "cart_add"), for: .normal)
        addShopBtn.addTarget(self, action: #selector(addShopAction), for: .touchUpInside)
        backView.addSubview(addShopBtn)
        
        addShopBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-9)
            make.bottom.equalTo(-10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        //加施工
        addServiceBtn = UIButton(type: .custom)
        addServiceBtn.setImage(UIImage.init(named: "menu_add"), for: .normal)
        addServiceBtn.isHidden = true
        addServiceBtn.addTarget(self, action: #selector(addServiceAction), for: .touchUpInside)
        backView.addSubview(addServiceBtn)
        
        addServiceBtn.snp.makeConstraints { (make) in
            make.center.size.equalTo(addShopBtn)
        }
    }
    
    @objc func addShopAction() {
        AppLog("点击了加购物车")
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        //materialsType 默认传1， 自建主材时传2
        let parameters: Parameters = ["worker": userId, "store": storeID, "service": serviceModel!.id!, "materialsType": "1", "type": "2"]
        
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
    
    @objc func addServiceAction() {
        AppLog("点击了添加施工")
        
        if let block = addServiceBlock {
            block()
        }
    }
}
