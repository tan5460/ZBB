//
//  CorrectingHomeImageCell.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class CorrectingHomeImageCell: UITableViewCell {

    var packageImageView: UIImageView!
    
    func setImageWithTableView(_ imageUrl:String?,_ tableView:UITableView) {
        
        if let picUrl = imageUrl {
            let imgUrlStr = APIURL.ossPicUrl + picUrl
            if let imageUrl = URL(string: imgUrlStr) {
                self.packageImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "banner_icon"), options: nil, progressBlock: nil) { (image, error, cacheType, url) in
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
            make.bottom.equalTo(-10)
        }
        
        //套餐图片
        packageImageView = UIImageView()
        packageImageView.clipsToBounds = true
        packageImageView.image = UIImage.init(named: "banner_icon")
        bgView.addSubview(packageImageView)
        
        packageImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
    }
}
