//
//  PackageCell.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/2.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class PlusCell: UITableViewCell {

    var packageImageView: UIImageView!
    var titleLabel: UILabel!
    var priceLabel: UILabel!
    var unitLabel: UILabel!                     //单位
    
    func setModelWithTableView(_ model:PlusModel,_ tableView:UITableView) {
        self.titleLabel.text = "套餐名"
        self.priceLabel.text = "套餐单价"
        self.unitLabel.text = "/无"

        if let valueStr = model.name {
            self.titleLabel.text = valueStr
        }
        
        if let valueStr = model.price?.doubleValue {
            let priceStr = valueStr.notRoundingString(afterPoint: 2)
            self.priceLabel.text = String.init(format: "%@元", priceStr)
            
            if let unitValue = model.unitType?.intValue {
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                if unitStr.count > 0 {
                    self.unitLabel.text = String.init(format: "/%@", unitStr)
                }
            }
        }
        
        if let picUrl = model.picUrl {
            let imgUrlStr = APIURL.ossPicUrl + picUrl
            if let imageUrl = URL(string: imgUrlStr) {
                self.packageImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "plus_backImage"), options: nil, progressBlock: nil) { (image, error, cacheType, url) in
                    if image != nil {
                        XHWebImageAutoSize.storeImageSize(image!, for: url!, completed: { (result) in
                            if result {
                                
                                tableView.xh_reloadData(for: url)
                            }
                        })
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
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.clipsToBounds = true
        bgView.layer.borderWidth = 0.5
        bgView.layer.borderColor = PublicColor.navigationLineColor.cgColor
        bgView.layer.cornerRadius = 5
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(-10)
        }
        
        //套餐图片
        packageImageView = UIImageView()
        packageImageView.clipsToBounds = true
        packageImageView.image = UIImage.init(named: "plus_backImage")
        bgView.addSubview(packageImageView)
        
        packageImageView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(-40)
        }
        
        //标题
        titleLabel = UILabel()
        titleLabel.text = "豪华品牌产品套餐"
        titleLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x333333)
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        bgView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-13)
            make.width.equalToSuperview().offset(PublicSize.screenWidth/2-12)
        }
        
        //单位
        unitLabel = UILabel()
        unitLabel.text = "/平方"
        unitLabel.font = UIFont.systemFont(ofSize: 11)
        unitLabel.textColor = PublicColor.minorTextColor
        bgView.addSubview(unitLabel)
        
        unitLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-13)
            
        }
        //价格
        priceLabel = UILabel()
        priceLabel.text = "套餐单价999元"
        priceLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xE2470F)
        priceLabel.font = UIFont.boldSystemFont(ofSize: 15)
        bgView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(unitLabel.snp.bottom)
            make.right.equalTo(unitLabel.snp.left)
        }
       
    }

}
