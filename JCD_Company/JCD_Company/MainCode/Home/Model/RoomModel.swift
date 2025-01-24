//
//  RoomModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2017/12/28.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class RoomModel: NSObject, Mappable {
    
    var id: String?                     //套餐id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var value: String?                  //键值
    var label: String?                  //房间名
    var type: String?                   //字典名
    var descriptionStr: String?         //备注 房间类型
    var sort: NSNumber?                 //排序号
    var parentId: String?               //父类id
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        value <- map["value"]
        label <- map["label"]
        type <- map["type"]
        descriptionStr <- map["description"]
        sort <- map["sort"]
        parentId <- map["parentId"]
    }
}
