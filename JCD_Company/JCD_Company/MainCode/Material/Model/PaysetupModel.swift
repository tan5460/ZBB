//
//  PaysetupModel.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/9/25.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class PaysetupModel: NSObject, Mappable {
    
    var id: String?                     //分步付款id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //付款批次名
    var price: NSNumber?                //付款金额
    var status: NSNumber?               //付款状态
    var sort: String?                   //排序
    
    var order: OrderModel?              //订单
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        name <- map["name"]
        price <- map["price"]
        status <- map["status"]
        sort <- map["sort"]
        order <- map["order"]
    }
}
