//
//  BrandIntroductionCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/12/6.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class BrandIntroductionCell: UITableViewCell {
    
    var bImageView: UIImageView!
    var titleLabel: UILabel!

    var merchantModel: MerchantModel? {
        didSet {
            if let brandName = merchantModel?.brandName {
                titleLabel.text = brandName
            }
            
            if let logoUrl = merchantModel?.brandImg {
                bImageView.backgroundColor = .clear
                if let imageUrl = URL(string: APIURL.ossPicUrl + logoUrl) {
                    bImageView.kf.setImage(with: imageUrl, placeholder: UIImage())
                }
            }else {
                bImageView.image = UIImage()
                bImageView.backgroundColor = PublicColor.backgroundViewColor
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
        
        
        //套餐图片
        bImageView = UIImageView()
        bImageView.clipsToBounds = true
        bImageView.backgroundColor = PublicColor.backgroundViewColor
        bImageView.contentMode = .scaleAspectFit
        contentView.addSubview(bImageView)
        
        bImageView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(35)
            make.width.equalTo(55)
        }
        
        //标题
        titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-11)
            make.left.equalTo(bImageView.snp.right).offset(10)
            
        }
        
    }
}
