//
//  MemberCenterModel.swift
//  YZB_Company
//
//  Created by Mac on 17.10.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//



import Foundation
import ObjectMapper

class MemberCenterModel: NSObject, Mappable {
    
 
    var delFlag: String? // "0",
    var name: String? // "普通会员",
    var isNewRecord: String? // false,
    var rate: String? // 3,
    var updateDate: String? // "2019-10-15 11:33:23",
    var updateBy: String? // null,
    var remarks: String? // null,
    var createBy: String? // null,
    var createDate: String? // "2019-10-11 11:38:27",
    var minInterval: Int = 0 // 0,
    var id: String? // "1",
    var maxInterval: Int = 0 // 500000
    var totalPurchasesMoney: NSNumber!
    var rateName: String!
    var rateId: String!
    var storeName: String!
    var nextRateName: String!
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        nextRateName <- map["nextRateName"]
        storeName <- map["storeName"]
        rateId <- map["rateId"]
        rateName <- map["rateName"]
        totalPurchasesMoney <- map["totalPurchasesMoney"]
        delFlag <- map["delFlag"]
        name <- map["name"]
        isNewRecord <- map["isNewRecord"]
        rate <- map["rate"]
        updateDate <- map["updateDate"]
        updateBy <- map["updateBy"]
        remarks <- map["remarks"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        minInterval <- map["minInterval"]
        id <- map["id"]
        maxInterval <- map["maxInterval"]
    }
}

