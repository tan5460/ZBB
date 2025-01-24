//
//  DecorationModel.swift
//  YZB_Company
//
//  Created by liuyi on 2018/12/7.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class DecorationModel: NSObject , Mappable {
    
    var id: String?
    var imgUrl: String?
    var createTime: String?
    var updateTime: String?
    var title: String?
    var url: String?
    var content: String?
    var remarks: String?
    var isNewRecord: NSNumber?
    var category: String?
    var categoryName: String?
    var delFlag: NSNumber?
    
    var store: StoreModel?              //店铺
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        imgUrl <- map["imgUrl"]
        createTime <- map["createTime"]
        updateTime <- map["updateTime"]
        title <- map["title"]
        url <- map["url"]
        content <- map["content"]
        remarks <- map["remarks"]
        category <- map["category"]
        isNewRecord <- map["isNewRecord"]
        categoryName <- map["categoryName"]
        delFlag <- map["delFlag"]
        store <- map["store"]
    }
    
}

class DecorationRaiderModel: NSObject , Mappable{
    
    var label: String?
    var value: String?
    
    var page: Int = 1
    var raiders: Array<DecorationModel> = []
    var button:UIButton?
    var tableview:UITableView?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        label <- map["label"]
        value <- map["value"]
        
    }
}
