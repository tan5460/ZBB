//
//  PlusModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/8.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class PlusModel: NSObject, Mappable {
    
    var id: String?                     //套餐id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //套餐名字
    var price: NSNumber?                //套餐价格
    var vol: NSNumber?                  //成交量
    var status: NSNumber?               //状态
    var unitType: NSNumber?             //单位类型
    var picUrl: String?                 //广告图片
    var detailsUrl: String?             //富文本内容
    var url: String?                    //套餐详情url
    var type: NSNumber?                 //套餐类型
    var plusType: NSNumber?             //套餐类型
    
    var store: StoreModel?              //店铺
    
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
        vol <- map["vol"]
        status <- map["status"]
        unitType <- map["unitType"]
        picUrl <- map["picUrl"]
        detailsUrl <- map["detailsUrl"]
        url <- map["url"]
        store <- map["store"]
        type <- map["type"]
        plusType <- map["plusType"]
    }
    
}
