//
//  PurchaseDetailCell.swift
//  YZB_Company
//
//  Created by Cloud on 2019/11/26.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Then

class PurchaseDetailCell: UITableViewCell {
    
    private let orderLabel = UILabel().text("订单号：").textColor(PublicColor.minorTextColor).font(13)
    private let statusLabel = UILabel().text("订单状态：").textColor(PublicColor.minorTextColor).font(13)
    private let timeLabel = UILabel().text("下单时间：").textColor(PublicColor.minorTextColor).font(13)
    private let limitLabel = UILabel().text("发货期限：").textColor(PublicColor.minorTextColor).font(13)
    private let inValidLabel = UILabel().text("订单失效时间：").textColor(PublicColor.minorTextColor).font(13)
    private let remarkLabel = UILabel().text("备注：").textColor(PublicColor.minorTextColor).font(13)
    
    private let order = UILabel().textColor(PublicColor.commonTextColor).font(13)
    private let status = UILabel().textColor(PublicColor.commonTextColor).font(13)
    private let time = UILabel().textColor(PublicColor.commonTextColor).font(13)
    private let limit = UILabel().textColor(PublicColor.commonTextColor).font(13)
    private let invalidTime = UILabel().textColor(PublicColor.commonTextColor).font(13)
    private let remark = UILabel().textColor(PublicColor.commonTextColor).font(13)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.sv(orderLabel, order, statusLabel, status, timeLabel, time, limitLabel, limit, remarkLabel, remark, inValidLabel, invalidTime)
        contentView.layout(
            10,
            |-15-orderLabel-1-order-(>=0)-| ~ 15,
            12,
            |-15-statusLabel-1-status-(>=0)-| ~ 15,
            12,
            |-15-timeLabel-1-time-(>=0)-| ~ 15,
            12,
            |-15-limitLabel-1-limit-(>=0)-| ~ 15,
            12,
            |-15-inValidLabel-1-invalidTime-(>=0)-| ~ 15,
            12,
            |-15-remarkLabel-1-remark-(>=0)-| ~ 15,
            15
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(model: PurchaseOrderModel?) {
        order.text(model?.orderNo ?? "无")
        if let valueStr = model?.orderStatus?.intValue {
            let statusStr = Utils.getFieldValInDirArr(arr: AppData.purchaseOrderStatusTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
            if statusStr.count > 0 {
                status.text = statusStr
            }
            if valueStr >= 3 {
                limit.text = model?.recevingTerm ?? "无"
                if let valueStr = model?.orderUneffectiveTime {
                    invalidTime.text = valueStr
                } else {
                    inValidLabel.isHidden = true
                    invalidTime.isHidden = true
                    remarkLabel.Top == limitLabel.Bottom + 12
                }
            } else {
                limit.isHidden = true
                limitLabel.isHidden = true
                if let valueStr = model?.orderUneffectiveTime {
                    invalidTime.text = valueStr
                    inValidLabel.Top == timeLabel.Bottom + 12

                } else {
                    inValidLabel.isHidden = true
                    invalidTime.isHidden = true
                    remarkLabel.Top == timeLabel.Bottom + 12
                }
            }
        }
        remark.text = model?.remarks ?? "无"
        time.text = model?.orderTime ?? ""
    }
    
}
