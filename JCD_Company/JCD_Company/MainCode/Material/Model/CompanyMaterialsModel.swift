//
//  CompanyMaterialsModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/16.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import HandyJSON

class CompanyMaterialsModel: NSObject, Mappable {
    
    var id: String?                     //公司主材id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var yzbMaterials: String?           //优装宝主材
    var price_custom: String?           //家装公司定价
    var vol: NSNumber?                  //成交量
    var hide: String?                   //是否隐藏
    
    var store: StoreModel?              //店铺
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        yzbMaterials <- map["yzbMaterials"]
        price_custom <- map["price_custom"]
        vol <- map["vol"]
        hide <- map["hide"]
        store <- map["store"]
    }

}

struct CompanyMaterialsM: HandyJSON {
    var id: String?                     //公司主材id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var yzbMaterials: String?           //优装宝主材
    var price_custom: String?           //家装公司定价
    var vol: NSNumber?                  //成交量
    var hide: String?                   //是否隐藏
    
    var store: StoreModel?              //店铺
}
