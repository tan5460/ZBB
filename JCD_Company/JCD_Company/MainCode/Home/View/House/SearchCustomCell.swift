//
//  SearchCustomCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2017/12/20.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class SearchCustomCell: UITableViewCell {

    var nameLabel: UILabel!             //客户名字
    var detailLabel: UILabel!           //客户电话
    var headerView: UIImageView!        //头像
    let headerHeight: CGFloat = 54
    
    var customModel: CustomModel? {
        
        didSet {
            
            nameLabel.text = ""
            detailLabel.text = ""
            
            nameLabel.text = customModel?.realName
            detailLabel.text = customModel?.tel
            
            var headerImage = UIImage.init(named: "headerImage_man")
            headerView.contentMode = .scaleAspectFit
            headerView.layer.borderWidth = 1
            headerView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            headerView.layer.cornerRadius = headerHeight/2
            headerView.layer.masksToBounds = true
            headerView.backgroundColor = UIColor.init(red: 234.0/255, green: 233.0/255, blue: 234.0/255, alpha: 1)
            
            if let valueType = customModel?.sex?.intValue {
                
                if valueType == 2 {
                    headerImage = UIImage.init(named: "headerImage_woman")
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
    
    var merchantModel: MerchantModel? {
        
        didSet {
            
            nameLabel.text = ""
            detailLabel.text = ""
            
            nameLabel.text = merchantModel?.brandName
            detailLabel.text = merchantModel?.name
            
            let headerImage = UIImage.init(named: "brand_logo")
            headerView.contentMode = .scaleAspectFit
            headerView.layer.borderWidth = 0
            headerView.layer.cornerRadius = 0
            headerView.layer.masksToBounds = false
            headerView.backgroundColor = UIColor.clear
            
            headerView.image = headerImage
            if let imageStr = merchantModel?.logoUrl {
                if let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
                    headerView.kf.setImage(with: imageUrl, placeholder: headerImage)
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
        
        self.backgroundColor = UIColor.white
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //头像
        headerView = UIImageView()
        headerView.image = UIImage.init(named: "headerImage_man")
        headerView.contentMode = .scaleAspectFit
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        headerView.layer.cornerRadius = headerHeight/2
        headerView.layer.masksToBounds = true
        headerView.backgroundColor = UIColor.init(red: 234.0/255, green: 233.0/255, blue: 234.0/255, alpha: 1)
        contentView.addSubview(headerView)
        
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(headerHeight)
            make.height.equalTo(headerHeight)
        }
        
        //名字
        nameLabel = UILabel()
        nameLabel.text = "姓名"
        nameLabel.textColor = PublicColor.commonTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerView.snp.right).offset(10)
            make.top.equalTo(headerView.snp.top).offset(6)
        }
        
        //电话
        detailLabel = UILabel()
        detailLabel.text = "电话"
        detailLabel.textColor = PublicColor.minorTextColor
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.bottom.equalTo(headerView.snp.bottom).offset(-6)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
    }
}
