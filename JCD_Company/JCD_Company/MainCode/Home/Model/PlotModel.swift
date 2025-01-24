//
//  PlotModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/9.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class PlotModel: NSObject, Mappable {
    
    var id: String?                     //小区id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //小区名字
    var address: String?                //地址
    var lon: String?                    //经度
    var lat: String?                    //纬度
    var headUrl: String?                //头像
    
    var store: StoreModel?              //店铺
    var prov: CityModel?                //省
    var city: CityModel?                //市
    var dist: CityModel?                //区
    
    
    override init() {
        super.init()
        
        prov = CityModel()
        city = CityModel()
        dist = CityModel()
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
        address <- map["address"]
        lon <- map["lon"]
        lat <- map["lat"]
        prov <- map["prov"]
        city <- map["city"]
        dist <- map["dist"]
        headUrl <- map["headUrl"]
        store <- map["store"]
    }
    
    
}
