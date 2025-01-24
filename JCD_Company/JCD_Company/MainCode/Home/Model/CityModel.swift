//
//  CityModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/9/1.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class CityModel: NSObject, Mappable {
    
    var id: String?                     //城市id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var parentIds: String?              //所有父级编号
    var name: String?          //城市名字
    var sort: String?                   //排序
    var zipcode: String?                //
    var longitude: String?              //纬度
    var latitude: String?               //经度
    var pinyin: String?                 //拼音
    var pinyins: String?                //全拼
    var type: NSNumber?                 //类型
    var parentId: String?               //父级id
    
    var createBy : String?
    var delFlag : String?
    var descriptionField : String?
    var label : String?
    var updateBy : String?
    var value : String?
    var shortName: String?
    var areaName: String?
    
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        areaName <- map["areaName"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        parentIds <- map["parentIds"]
        shortName <- map["shortName"]
        name <- map["name"]
        sort <- map["sort"]
        zipcode <- map["zipcode"]
        longitude <- map["longitude"]
        latitude <- map["latitude"]
        pinyin <- map["pinyin"]
        pinyins <- map["pinyins"]
        type <- map["type"]
        parentId <- map["parentId"]
    }
    
}
