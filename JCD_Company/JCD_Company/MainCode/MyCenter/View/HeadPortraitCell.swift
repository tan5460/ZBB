//
//  HeadPortraitCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/9.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class HeadPortraitCell: UITableViewCell {

    var titleLb : UILabel!
    var iconImgView : UIImageView!
    var arrowImgView : UIImageView!
    
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
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {

        //标签
        titleLb = UILabel()
        titleLb.text = "头像"
        titleLb.textColor = UIColor.colorFromRGB(rgbValue: 0x1E1E1E)
        titleLb.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(titleLb)
        
        titleLb.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        //箭头
        arrowImgView = UIImageView()
        arrowImgView.image = UIImage(named: "arrow_right")
        arrowImgView.contentMode = .scaleAspectFit
        self.contentView.addSubview(arrowImgView)
        
        arrowImgView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(14)
            make.width.equalTo(7)
        }
        
        //头像
        iconImgView = UIImageView()
        iconImgView.image = UIImage(named: "imageRow_camera")
        iconImgView.contentMode = .scaleAspectFill
        iconImgView.layer.cornerRadius = 55/2
        iconImgView.layer.masksToBounds = true
        self.contentView.addSubview(iconImgView)
        
        iconImgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalTo(arrowImgView.snp.left).offset(-8)
            make.height.width.equalTo(55)
        }
        
        let line = UIView()
        line.backgroundColor = PublicColor.partingLineColor
        self.contentView.addSubview(line)
        
        line.snp.makeConstraints { (make) in
            make.right.equalTo(arrowImgView.snp.right)
            make.height.equalTo(1)
            make.left.equalTo(titleLb.snp.left)
            make.bottom.equalToSuperview().offset(-1)
        }
    }
}

