//
//  PlusOrderEditCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/27.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class PlusOrderEditCell: UITableViewCell {

    var titleLabel: UILabel!                        
    var iconImgView: UIImageView!
    var selectedBtn: UIButton!
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        self.selectionStyle = .none
        //选中按钮
        selectedBtn = UIButton.init(type: .custom)
        selectedBtn.setImage(UIImage.init(named: "car_unchecked"), for: .normal)
        selectedBtn.setImage(UIImage.init(named: "car_checked"), for: .selected)
        selectedBtn.isUserInteractionEnabled = false
        contentView.addSubview(selectedBtn)
        
        selectedBtn.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        iconImgView = UIImageView()
        iconImgView.contentMode = .scaleAspectFit
        iconImgView.image = UIImage(named: "plus_material_icon")
        contentView.addSubview(iconImgView)
        
        iconImgView.snp.makeConstraints { (make) in
            make.centerY.equalTo(selectedBtn)
            make.left.equalTo(selectedBtn.snp.right)
            make.width.height.equalTo(20)
        }
        
        
        //组名
        titleLabel = UILabel()
        titleLabel.text = "产品"
        titleLabel.textColor = PublicColor.minorTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(selectedBtn)
            make.left.equalTo(iconImgView.snp.right)
            make.right.equalTo(-20)
        }
        
      
    }

}
