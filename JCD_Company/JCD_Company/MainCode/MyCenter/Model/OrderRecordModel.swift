//
//  OrderRecordModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/12.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class OrderRecordModel: NSObject, Mappable {
    
    var month: NSNumber?                //月份
    var orderList: Array<OrderModel>?  //订单数组
    var payCount: NSNumber?             //月成交额
    
    var isShow = false                //是否正在展示
    var totalAmount: NSNumber?
    var size: Int?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        month <- map["month"]
        orderList <- map["orderList"]
        payCount <- map["payCount"]
        totalAmount <- map["totalAmount"]
        size <- map["size"]
    }
}
