//
//  MaterialsCorrcetModel.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class MaterialsCorrcetModel: NSObject, Mappable {
    
    var isStart: Int?
    var second: Int?
    var banner1: String?
    var banner2: String?
    var data1:[MaterialsModel]?
    var data2:[MaterialsModel]?
    var data3:[MaterialsModel]?
    var data4:[MaterialsModel]?
    var timeSet: TimeSetModel?
    var advertList: [AdvertListModel]?
    
    required init?(map: Map) {
        
    }
    
    
    func mapping(map: Map) {
        advertList <- map["advertList"]
        isStart <- map["isStart"]
        second <- map["second"]
        banner1 <- map["banner1"]
        banner2 <- map["banner2"]
        data1 <- map["data1"]
        data1 <- map["materList"]
        data2 <- map["data2"]
        data3 <- map["data3"]
        data4 <- map["data4"]
        timeSet <- map["timeSet"]
        
    }
    
}

class TimeSetModel:NSObject,Mappable {
    
    var id: String?
    var remarks: String?
    var createBy: String?
    var delFlag: String?
    var startTime: String?
    var updateBy: String?
    var isNewRecord: Bool?
    var createDate: String?
    var endTime: String?
    var value: String?
    var updateDate: String?
    var name: String?
    var belongId: String?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        remarks <- map["remarks"]
        createBy <- map["createBy"]
        delFlag <- map["delFlag"]
        startTime <- map["startTime"]
        updateBy <- map["updateBy"]
        isNewRecord <- map["isNewRecord"]
        createDate <- map["createDate"]
        endTime <- map["endTime"]
        value <- map["value"]
        updateDate <- map["updateDate"]
        name <- map["name"]
        belongId <- map["belongId"]
        
    }
}


class AdvertListModel : NSObject, Mappable{
    var whetherCanShare: String? // 是否可分享(1:不可分享 2:可分享)
    var advertImg : String? // 广告图
    var advertLink : String? // 广告链接
    var advertLoc : String? // 广告位置
    var belongUserId : String?
    var createBy : String?
    var createTime : String?
    var id : String?
    var remarks : AnyObject?
    var sortNo : AnyObject?
    var title : String? // 标题
    var updateBy : String?
    var updateTime : String?
    var onlineTimeEnd : String? // 上线时间-开始
    var onlineTimeStart : String? // 上线时间-结束
    
    
    required init?(map: Map){}
    private override init(){
        super.init()
    }
    
    func mapping(map: Map)
    {
        whetherCanShare <- map["whetherCanShare"]
        onlineTimeEnd <- map["onlineTimeEnd"]
        onlineTimeStart <- map["onlineTimeStart"]
        advertImg <- map["advertImg"]
        advertLink <- map["advertLink"]
        advertLoc <- map["advertLoc"]
        belongUserId <- map["belongUserId"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        id <- map["id"]
        remarks <- map["remarks"]
        sortNo <- map["sortNo"]
        title <- map["title"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        
    }
}
