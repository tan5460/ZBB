//
//  OrderRecordHeaderView.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/12.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

class OrderRecordHeaderView: UITableViewHeaderFooterView {

    var titleLabel: UILabel!
    var detailLabel: UILabel!
    var lineView: UIView!
    
    var upOrDownBtn: UIButton!
    var upOrDownClickBtn: UIButton!
    var upOrDownBlock: (()->())?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = PublicColor.backgroundViewColor
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        let backView = UIView()
        backView.backgroundColor = .white
        contentView.addSubview(backView)
        
        backView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(10)
        }
        
        //标题
        titleLabel = UILabel()
        titleLabel.text = "本月成交额:"
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont .systemFont(ofSize: 14)
        backView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        //订单名
        detailLabel = UILabel()
        detailLabel.text = "￥56,012.00"
        detailLabel.textColor = PublicColor.commonTextColor
        detailLabel.font = UIFont .systemFont(ofSize: 14)
        backView.addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(5)
        }
        
        //分割线
        lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        backView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        //展开
        upOrDownBtn = UIButton(type: .custom)
        upOrDownBtn.setImage(UIImage.init(named: "order_icon_down"), for: .normal)
        upOrDownBtn.setImage(UIImage.init(named: "order_icon_up"), for: .selected)
        backView.addSubview(upOrDownBtn)
        
        upOrDownBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        
        upOrDownClickBtn = UIButton(type: .custom)
        upOrDownClickBtn.addTarget(self, action: #selector(tapClickAction), for: .touchUpInside)
        backView.addSubview(upOrDownClickBtn)
        
        upOrDownClickBtn.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
            
        }
    }
    @objc func tapClickAction() {
        if let block = upOrDownBlock {
            self.upOrDownBtn.isSelected = !self.upOrDownBtn.isSelected
            block()
        }
    }

}
