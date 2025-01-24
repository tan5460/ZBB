//
//  IMUIOrderViewCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/19.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class IMUIOrderView: UIView, IMUIMessageContentViewProtocol{

    @objc public static var orderTextFont = UIFont.systemFont(ofSize: 15)
    
    var textMessageLabel = UILabel()
    
//    var orderStateLabel = IMUITextView()
    
    var bgImgView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(bgImgView)
        bgImgView.backgroundColor = .white
        
        self.addSubview(textMessageLabel)
        textMessageLabel.textColor = PublicColor.blackBlueTextColor
        textMessageLabel.font = UIFont.systemFont(ofSize: 13)
        textMessageLabel.numberOfLines = 0
        
//        self.addSubview(orderStateLabel)
//        orderStateLabel.font = UIFont.systemFont(ofSize: 15)
//        orderStateLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(textMessageLabel.snp.bottom).offset(8)
//            make.left.equalTo(12)
//            make.height.equalTo(16)
//        }
        
        let label = UILabel()
        label.text = "查看订单详情"
        label.textColor = PublicColor.placeholderTextColor
        label.font = UIFont.systemFont(ofSize: 13)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.right.equalTo(-12)
            make.bottom.equalTo(-16)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        self.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(label.snp.top).offset(-10)
            make.height.equalTo(1)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func layoutContentView(message: IMUIMessageModelProtocol) {
        
        bgImgView.frame = CGRect(origin: CGPoint.zero, size: message.layout.bubbleContentSize)
        
        textMessageLabel.frame = CGRect(x: 15, y: 15, width: bgImgView.frame.width - 26, height: bgImgView.frame.height - 30 - 40)
        
        textMessageLabel.text = message.text()
        
        if let msg = message as? MyMessageModel {
           
            textMessageLabel.attributedText = msg.orderText
            
//            if let valueStr = msg.orderState {
//                if valueStr == "" {return}
//                let statusStr = Utils.getFieldValInDirArr(arr: AppData.purchaseOrderStatusTypeList, fieldA: "value", valA: valueStr, fieldB: "label")
//                orderStateLabel.text = "订单状态："
//                if statusStr.count > 0 {
//                    orderStateLabel.attributedText = ToolsFunc.getMixtureAttributString([MixtureAttr(string: "订单状态：", color: PublicColor.commonTextColor, font: orderStateLabel.font), MixtureAttr(string: "\(statusStr)", color: PublicColor.emphasizeColor, font: orderStateLabel.font)])
//                }
//
//            }
        }
    
    }
    
}
