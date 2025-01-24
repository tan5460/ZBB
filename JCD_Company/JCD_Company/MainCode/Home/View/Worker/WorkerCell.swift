//
//  WorkerCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 5.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class WorkerCell: UITableViewCell {

    var nameLabel: UILabel!             //客户名字
    var userLabel: UILabel!             //用户名
    var phoneLabel: UILabel!            //客户电话
    var headerView: UIImageView!        //头像
    var sexLabel: UILabel!              //性别
    var jobLabel: UILabel!              //职位
    var bgView: UIView!                 //底部视图
    
    var workerModel: WorkerModel? {
        
        didSet {
            nameLabel.text = "姓名未知"
            phoneLabel.text = "电话未知"
            userLabel.text = "用户名: 未知"
            sexLabel.text = "性别: 未知"
            jobLabel.text = "职位: 未知"
            
            var headerImage = UIImage.init(named: "headerImage_man")
            
            if let valueStr = workerModel?.realName {
                nameLabel.text = valueStr
            }
            
            if let valueStr = workerModel?.mobile {
                phoneLabel.text = valueStr
            }
            
            if let valueStr = workerModel?.userName {
                userLabel.text = "用户名: \(valueStr)"
            }
            
            if let valueType = workerModel?.sex?.intValue {
                
                if valueType == 2 {
                    headerImage = UIImage.init(named: "headerImage_woman")
                }
                
                if valueType > 0 && valueType <= AppData.sexList.count {
                    let array = Utils.getFieldArrInDirArr(arr: AppData.sexList, field: "label")
                    sexLabel.text = "性别: \(array[valueType-1])"
                }
            }
            
            if let valueStr = workerModel?.jobType {
                
                if valueStr == 999 {
                    jobLabel.text = "职位: 管理员"
                }
                else if valueStr == 1 {
                    jobLabel.text = "职位: 工长"
                }
                else if valueStr == 2 {
                    jobLabel.text = "职位: 客户经理"
                }
                else if valueStr == 3 {
                    jobLabel.text = "职位: 设计师"
                }
                else if valueStr == 4 {
                    jobLabel.text = "职位: 采购员"
                }
            }
            
            headerView.image = headerImage
            if let imageStr = workerModel?.headUrl {
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
        nameLabel.textColor = PublicColor.commonTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        bgView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.top).offset(4)
            make.left.equalTo(headerView.snp.right).offset(12)
        }
        
        //电话
        phoneLabel = UILabel()
        phoneLabel.textColor = PublicColor.commonTextColor
        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        bgView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(20)
            make.centerY.equalTo(nameLabel)
        }
        
        //用户名
        userLabel = UILabel()
        userLabel.textColor = PublicColor.minorTextColor
        userLabel.font = UIFont.systemFont(ofSize: 12)
        bgView.addSubview(userLabel)
        
        userLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        //性别
        sexLabel = UILabel()
        sexLabel.textColor = PublicColor.minorTextColor
        sexLabel.font = UIFont.systemFont(ofSize: 12)
        bgView.addSubview(sexLabel)
        
        sexLabel.snp.makeConstraints { (make) in
            make.left.equalTo(userLabel.snp.right).offset(20)
            make.centerY.equalTo(userLabel)
        }
        
        //职位
        jobLabel = UILabel()
        jobLabel.textColor = PublicColor.minorTextColor
        jobLabel.font = UIFont.systemFont(ofSize: 12)
        bgView.addSubview(jobLabel)
        
        jobLabel.snp.makeConstraints { (make) in
            make.left.equalTo(sexLabel.snp.right).offset(20)
            make.centerY.equalTo(userLabel)
        }
    }
    
}
