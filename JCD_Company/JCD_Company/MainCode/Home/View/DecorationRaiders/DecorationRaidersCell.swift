//
//  DecorationRaidersCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/12/7.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class DecorationRaidersCell: UITableViewCell {

    var bImageView: UIImageView!
    var titleLabel: UILabel!
    var subTitleLabel: UILabel!
    
    var drModel: DecorationModel? {
        didSet {
            if let title = drModel?.title {
                titleLabel.text = title
            }
            if let remarks = drModel?.remarks {
                subTitleLabel.text = remarks
            }
            
            if let imgUrl = drModel?.imgUrl {
                bImageView.backgroundColor = .clear
                if let imageUrl = URL(string: APIURL.ossPicUrl + "/" + imgUrl) {
                    bImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "loading_rectangle"))
                }
            }else {
                bImageView.image = UIImage(named: "loading_rectangle")
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
        bImageView.backgroundColor = PublicColor.backgroundViewColor
        bImageView.image = UIImage(named: "loading_rectangle")
        bImageView.contentMode = .scaleAspectFit
        bImageView.layer.cornerRadius = 4
        bImageView.layer.masksToBounds = true
        contentView.addSubview(bImageView)
        
        bImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(70)
            make.width.equalTo(100)
        }
        
        //标题
        titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bImageView.snp.top).offset(4)
            make.right.equalTo(bImageView.snp.left).offset(-15)
            make.left.equalToSuperview().offset(15)
            
        }
        
        //标题
        subTitleLabel = UILabel()
        subTitleLabel.text = ""
        subTitleLabel.textColor = PublicColor.minorTextColor
        subTitleLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(subTitleLabel)
        
        subTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(bImageView.snp.bottom).offset(-4)
            make.right.equalTo(bImageView.snp.left).offset(-15)
            make.left.equalToSuperview().offset(15)
            
        }
        
    }
}
