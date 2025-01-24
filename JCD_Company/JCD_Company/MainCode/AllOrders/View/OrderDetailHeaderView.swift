//
//  OrderDetailHeaderView
//  YZB_Company
//
//  Created by yzb_ios on 2018/1/15.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

class OrderDetailHeaderView: UITableViewHeaderFooterView {
    
    var titleLabel: UILabel!                        //组标题
    var upOrDownBtn: UIButton!
    var upOrDownClickBtn: UIButton!
    var upOrDownBlock: (()->())?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //自定义分割线
        let separatorView = UIView()
        separatorView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
       
        //组名
        titleLabel = UILabel()
        titleLabel.text = "产品"
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        
        //展开
        upOrDownBtn = UIButton(type: .custom)
        upOrDownBtn.setImage(UIImage.init(named: "order_icon_down"), for: .normal)
        upOrDownBtn.setImage(UIImage.init(named: "order_icon_up"), for: .selected)
        contentView.addSubview(upOrDownBtn)
        
        upOrDownBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
        }

        upOrDownClickBtn = UIButton(type: .custom)
        upOrDownClickBtn.addTarget(self, action: #selector(tapClickAction), for: .touchUpInside)
        contentView.addSubview(upOrDownClickBtn)
        
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
