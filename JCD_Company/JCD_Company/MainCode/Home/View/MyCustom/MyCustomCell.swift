//
//  MyCustomCell.swift
//  YZB_Company
//
//  Created by 周化波 on 2018/1/11.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher


class MyCustomCell: UITableViewCell {
    var nameLabel: UILabel!             //客户名字
    var phoneLabel: UILabel!            //客户电话
    var headerView: UIImageView!        //头像
    var sexLabel: UILabel!              //性别
    var telBtn: UIButton!               //打电话
    var bgView: UIView!                 //底部视图
    
    var delBtn: UIButton!
    var operationType = ""
    var callPhoneBlock: (()->())?       //打电话

    var customModel: CustomModel? {
        
        didSet {
            nameLabel.text = "未知"
            phoneLabel.text = "未知"
            sexLabel.text = "未知"
            
            var headerImage = UIImage.init(named: "headerImage_man")
            
            if let valueStr = customModel?.realName {
                nameLabel.text = valueStr
            }
            
            if let valueStr = customModel?.tel {
                phoneLabel.text = valueStr
            }
            
            if let valueType = customModel?.sex?.intValue {
                
                if valueType == 2 {
                    headerImage = UIImage.init(named: "headerImage_woman")
                }
                
                if valueType > 0 && valueType <= AppData.sexList.count {
                    let array = Utils.getFieldArrInDirArr(arr: AppData.sexList, field: "label")
                    sexLabel.text = array[valueType-1]
                }
            }
            
            
            headerView.image = headerImage
            if let imageStr = customModel?.headUrl {
                if let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func createSubView() {
        
        //圆角背景
        bgView = UIView()
        bgView.backgroundColor = .white
        contentView.addSubview(bgView)
        
        bgView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
        //头像
        let headerHeight: CGFloat = 45
        headerView = UIImageView()
        headerView.contentMode = .scaleAspectFit
        headerView.image = UIImage.init(named: "headerImage_man")
        headerView.layer.cornerRadius = headerHeight/2
        headerView.layer.masksToBounds = true
        headerView.backgroundColor = UIColor.init(red: 186.0/255, green: 185.0/255, blue: 186.0/255, alpha: 1)
        bgView.addSubview(headerView)
        
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(headerHeight)
        }
        
        //名字
        nameLabel = UILabel()
        nameLabel.text = "王健林"
        nameLabel.textColor = PublicColor.commonTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        bgView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.top).offset(4)
            make.left.equalTo(headerView.snp.right).offset(12)
        }
        
        sexLabel = UILabel()
        sexLabel.text = "男"
        sexLabel.textColor = PublicColor.minorTextColor
        sexLabel.font = UIFont.systemFont(ofSize: 12)
        bgView.addSubview(sexLabel)
        
        sexLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(12)
            make.bottom.equalTo(nameLabel.snp.bottom)
        }
        
        //电话
        let phoneTitle = UILabel()
        phoneTitle.text = "电话:  "
        phoneTitle.textColor = PublicColor.minorTextColor
        phoneTitle.font = UIFont.systemFont(ofSize: 12)
        bgView.addSubview(phoneTitle)
        
        phoneTitle.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        phoneLabel = UILabel()
        phoneLabel.text = "18800560021"
        phoneLabel.textColor = PublicColor.minorTextColor
        phoneLabel.font = UIFont.systemFont(ofSize: 12)
        bgView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(phoneTitle.snp.right)
            make.centerY.equalTo(phoneTitle)
        }
        
        ///打电话
        telBtn = UIButton(type: .custom)
        telBtn.setImage(UIImage.init(named: "order_tel"), for: .normal)
        telBtn.addTarget(self, action: #selector(telAction), for: .touchUpInside)
        bgView.addSubview(telBtn)
        
        telBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerY.equalTo(headerView.snp.centerY)
            make.right.equalTo(-16)
        }
        
    }
    
    ///拨打电话
    @objc func telAction(){
        
        if let block = callPhoneBlock {
            block()
        }
    }

}
