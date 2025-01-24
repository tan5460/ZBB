//
//  purchaseModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 25.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class PurchaseModel: NSObject, Mappable {
    
    var id: String?                     //采购id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var plusPrice: String?              //套餐价格
    var beginPurchaseTime: NSNumber?    //采购时间
    var orderId: String?                //订单id
    var customTel: String?              //客户电话
    var customName: String?             //客户名字
    
    var custom: CustomModel?            //客户
    var store: StoreModel?              //店铺
    var plus: PlusModel?                //套餐
    var house: HouseModel?              //工地
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        plusPrice <- map["plusPrice"]
        customTel <- map["customTel"]
        beginPurchaseTime <- map["beginPurchaseTime"]
        orderId <- map["orderId"]
        customName <- map["customName"]
        custom <- map["custom"]
        store <- map["store"]
        plus <- map["plus"]
        house <- map["house"]
    }
}
