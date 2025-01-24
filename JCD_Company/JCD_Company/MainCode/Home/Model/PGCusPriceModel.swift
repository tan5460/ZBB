//
//  PGCusPriceModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/7/17.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper


class PGCusPriceModel: NSObject, Mappable {
    
    var id: String?                     //套餐id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var packageId: String?              //主材包id
    var materialsId: String?            //主材id
    var cusPrice: NSNumber?             //主材差价
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        packageId <- map["packageId"]
        materialsId <- map["materialsId"]
        cusPrice <- map["cusPrice"]
    }
    
}

