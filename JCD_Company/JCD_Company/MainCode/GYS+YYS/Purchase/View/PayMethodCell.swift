//
//  PayMethodCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 26.03.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class PayMethodCell: UITableViewCell {
    
    var payIcon: UIImageView!           //支付图标
    var payTitle: UILabel!              //支付标题
    var selectIcon: UIImageView!        //选中图标
    var lineView: UIView!               //分割线

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        
        self.selectionStyle = .none
        self.backgroundColor = UIColor.white
        createSubView()
    }
    
    func createSubView() {
        
        //支付图标
        payIcon = UIImageView()
        payIcon.contentMode = .scaleAspectFit
        contentView.addSubview(payIcon)
        
        payIcon.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        //支付标题
        payTitle = UILabel()
        payTitle.text = ""
        payTitle.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(payTitle)
        
        payTitle.snp.makeConstraints { (make) in
            make.left.equalTo(payIcon.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        //是否选中
        selectIcon = UIImageView()
        selectIcon.contentMode = .scaleAspectFit
        contentView.addSubview(selectIcon)
        
        selectIcon.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        //分割线
        lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(payIcon)
            make.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
}
