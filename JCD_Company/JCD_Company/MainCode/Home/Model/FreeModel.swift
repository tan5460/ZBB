//
//  FreeModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/3/6.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper


class FreeModel: NSObject, Mappable {
    
    var id: String?                     //模板id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //模板名字
    var thumbUrl: String?               //缩略图
    
    var city: CityModel?                //城市
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
        thumbUrl <- map["thumbUrl"]
        city <- map["city"]
        store <- map["store"]
    }
}
