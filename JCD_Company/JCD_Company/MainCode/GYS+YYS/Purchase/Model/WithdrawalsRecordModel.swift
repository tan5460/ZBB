//
//  WithdrawalsRecordModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 24.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class WithdrawalsRecordModel: NSObject, Mappable {
    
    var operAmount: NSNumber?             //提现金额
    var transactionNo: String?              //交易号
    var orderNo: String? // 暂用订单号做交易号
    var status: String?                 //提现状态
    
    var amountFee : AnyObject?
    var channel : String?
    var chargeId : String?
    var createBy : String?
    var createTime : String?
    var currency : String?
    var divideAmount : AnyObject?
    var eventId : AnyObject?
    var failureMsg : AnyObject?
    var id : String?
    var livemode : Bool?
    var queryBeginDate : AnyObject?
    var queryEndDate : AnyObject?
    var remarks : AnyObject?
    var returnUrl : String?
    var serviceCharge : Int?
    var type : String?
    var updateTime : AnyObject?
    var userId : String?

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        createTime <- map["createTime"]
        operAmount <- map["operAmount"]
        transactionNo <- map["transactionNo"]
        status <- map["status"]
        orderNo <- map["orderNo"]
        amountFee <- map["amountFee"]
        channel <- map["channel"]
        chargeId <- map["chargeId"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        currency <- map["currency"]
        divideAmount <- map["divideAmount"]
        eventId <- map["eventId"]
        failureMsg <- map["failureMsg"]
        id <- map["id"]
        livemode <- map["livemode"]
        operAmount <- map["operAmount"]
        orderNo <- map["orderNo"]
        queryBeginDate <- map["queryBeginDate"]
        queryEndDate <- map["queryEndDate"]
        remarks <- map["remarks"]
        returnUrl <- map["returnUrl"]
        serviceCharge <- map["serviceCharge"]
        status <- map["status"]
        transactionNo <- map["transactionNo"]
        type <- map["type"]
        updateTime <- map["updateTime"]
        userId <- map["userId"]
    }
}
