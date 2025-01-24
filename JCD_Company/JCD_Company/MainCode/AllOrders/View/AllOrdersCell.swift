//
//  AllOrdersCell.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/23.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class AllOrdersCell: UITableViewCell {
    
    var orderTitle: UILabel!            //订单名
    var orderState: UILabel!            //订单状态
    var headerView: UIImageView!        //头像
    var nameLabel: UILabel!             //名字
    var plotLabel: UILabel!             //小区
    var dateLabel: UILabel!             //日期
    var priceLabel: UILabel!            //价格
    
    var mCountLabel:UILabel!           //主材数量
    
    var orderModel: OrderModel? {
        didSet {
            orderTitle.text = "订单标题"
            orderState.text = "未知"
            nameLabel.text = "姓名: 未知"
            plotLabel.text = "小区: 未知"
            dateLabel.text = "时间"
            priceLabel.text = " "
            
            orderTitle.text = "自由组合"
            
            orderState.text = orderModel?.orderStatusName
            
            var headerImage = UIImage.init(named: "headerImage_man")
            
            if let valueType = orderModel?.sex?.intValue {
                if valueType == 2 {
                    headerImage = UIImage.init(named: "headerImage_woman")
                }
            }
            
            headerView.image = headerImage
            if let imageStr = orderModel?.customHeadUrl {
                if let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
                    headerView.kf.setImage(with: imageUrl, placeholder: headerImage)
                }
            }
            
            if let valueStr = orderModel?.customName {
                nameLabel.text = "姓名: \(valueStr)"
            }
            
            if let valueStr = orderModel?.plotName {
                plotLabel.text = "小区: \(valueStr)"
            }
            
            dateLabel.text = orderModel?.createDate ?? ""
            var m = 0
            if let mN = orderModel?.msize?.intValue {
                m = mN
            }
            mCountLabel.text = "产品（\(m)）   订单总额:"
            if let valueStr = orderModel?.payMoney?.doubleValue {
                let value = valueStr.notRoundingString(afterPoint: 2)
                priceLabel.text = String(format: "￥%@", value)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func createSubView() {
        
        //背景
        let backView = UIView()
        backView.backgroundColor = .white
        contentView.addSubview(backView)
        
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.right.left.bottom.equalToSuperview()
        }
        
        //订单标题
        orderTitle = UILabel()
        orderTitle.text = ""
        orderTitle.textColor = PublicColor.commonTextColor
        orderTitle.font = UIFont.systemFont(ofSize: 14)
        backView.addSubview(orderTitle)
        
        orderTitle.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(14)
        }
        
        //订单状态
        orderState = UILabel()
        orderState.text = ""
        orderState.textColor = PublicColor.minorTextColor
        orderState.font = UIFont.systemFont(ofSize: 14)
        backView.addSubview(orderState)
        
        orderState.snp.makeConstraints { (make) in
            make.right.equalTo(-13)
            make.centerY.equalTo(orderTitle)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        backView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(orderTitle.snp.bottom).offset(14)
            make.height.equalTo(1)
        }
        
        //头像
        let headerHeight: CGFloat = 45
        headerView = UIImageView()
        headerView.contentMode = .scaleAspectFit
        headerView.layer.borderWidth = 1
        headerView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        headerView.image = UIImage.init(named: "headerImage_man")
        headerView.layer.cornerRadius = headerHeight/2
        headerView.layer.masksToBounds = true
        headerView.backgroundColor = UIColor.init(red: 234.0/255, green: 233.0/255, blue: 234.0/255, alpha: 1)
        backView.addSubview(headerView)
        
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(orderTitle)
            make.top.equalTo(lineView.snp.bottom).offset(15)
            make.width.height.equalTo(headerHeight)
        }
        
        //名字
        nameLabel = UILabel()
        nameLabel.text = "姓名:"
        nameLabel.textColor = PublicColor.commonTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        backView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headerView.snp.right).offset(12)
            make.top.equalTo(headerView).offset(3)
            make.width.equalTo(120)
        }

        //日期
        dateLabel = UILabel()
        dateLabel.text = "时间"
        dateLabel.textColor = PublicColor.minorTextColor
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        backView.addSubview(dateLabel)
        
        dateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-13)
            make.centerY.equalTo(nameLabel)
        }
        //小区
        plotLabel = UILabel()
        plotLabel.text = "小区:"
        plotLabel.textColor = PublicColor.minorTextColor
        plotLabel.font = UIFont.systemFont(ofSize: 12)
        backView.addSubview(plotLabel)
        
        plotLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalTo(nameLabel)
            make.right.equalTo(dateLabel)
        }
        
        //分割线
        let lineView2 = UIView()
        lineView2.backgroundColor = PublicColor.partingLineColor
        backView.addSubview(lineView2)
        
        lineView2.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.height.equalTo(1)
        }
        
        //数量
        mCountLabel = UILabel()
        mCountLabel.text = "产品（0） 施工（0）   订单总额:"
        mCountLabel.textColor = PublicColor.minorTextColor
        mCountLabel.font = UIFont.systemFont(ofSize: 12)
        backView.addSubview(mCountLabel)
        
        mCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(lineView2.snp.bottom).offset(14)
        }
        //价格
        priceLabel = UILabel()
        priceLabel.text = "¥0.00"
        priceLabel.textColor = PublicColor.emphasizeColor
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        backView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(mCountLabel.snp.right).offset(0)
            make.bottom.equalTo(mCountLabel.snp.bottom)
        }
        
        
    }

}
