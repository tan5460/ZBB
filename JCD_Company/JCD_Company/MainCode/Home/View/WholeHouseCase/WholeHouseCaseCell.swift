//
//  WholeHouseCaseCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/1.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class WholeHouseCaseCell: UITableViewCell {

    var caseImageView: UIImageView!
    var titleLabel: UILabel!
    var tagLabel: UILabel!
    
    func setModelWithTableView(_ caseModel:HouseCaseModel,_ tableView:UITableView) {
        if let caseRemarks = caseModel.caseRemarks {
            titleLabel.text = caseRemarks
        }
        
        var labelString = ""

        if let areaName = caseModel.communityName {
            labelString = areaName
        }
        
        if let houseTyName = caseModel.houseTypeName {
            if labelString.count > 0 {
                labelString += "   " + houseTyName
            }else {
                labelString += houseTyName
            }
        }
        if let houseAreaName = caseModel.houseAreaName {
            if labelString.count > 0 {
                labelString += "   " + houseAreaName
            }else {
                labelString += houseAreaName
            }
        }
        if let caseStyleName = caseModel.caseStyleName {
            if labelString.count > 0 {
                labelString += "   " + caseStyleName
            }else {
                labelString += caseStyleName
            }
        }
        
        tagLabel.text = labelString
        
        if let mainImgUrl = caseModel.mainImgUrl {
            let imgUrlStr = APIURL.ossPicUrl + "/" + mainImgUrl
            if let imageUrl = URL(string: imgUrlStr) {
                self.caseImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading_vr"), options: nil, progressBlock: nil) { (image, error, cacheType, url) in
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
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(0)
        }
        
        //套餐图片
        caseImageView = UIImageView()
        caseImageView.clipsToBounds = true
        caseImageView.contentMode = .scaleAspectFit
        caseImageView.image = UIImage.init(named: "loading_rectangle")
        bgView.addSubview(caseImageView)
        
        caseImageView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(-76)
        }
        
        //标题
        titleLabel = UILabel()
        titleLabel.text = "他家的配色灵感来源于一块复古小花砖！"
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        bgView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.top.equalTo(caseImageView.snp.bottom).offset(19)
            
        }
        
        //价格
        tagLabel = UILabel()
        tagLabel.text = "丽都院  三居  120㎡  北欧"
        tagLabel.textColor = PublicColor.minorTextColor
        tagLabel.font = UIFont.boldSystemFont(ofSize: 12)
        bgView.addSubview(tagLabel)
        
        tagLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
        }
        
    }

}
