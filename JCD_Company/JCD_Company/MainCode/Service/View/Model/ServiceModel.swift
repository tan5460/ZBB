//
//  ServiceModel.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/11/1.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class ServiceModel: NSObject, Mappable {
    
    var id: String?                     //施工id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String = "无"                //备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //施工名
    var intro: String?                  //简介
    var unitType: NSNumber?             //单位类型
    var cusPrice: NSNumber?             //售价
    var roomType: NSNumber?             //房间类型
    var count: NSNumber?                //数量
    var type: NSNumber?                 //施工类型
    var category: NSNumber?             //施工分类
    var buyCount: NSNumber = 100        //购买数量
    
    //非返回参数，自定义添加
    var serviceType: Int = 1            //施工类型  1.套餐施工 2.常规施工 3.套餐施工增项 4.自定义施工
    var isCheck = false                 //是否选中
    
    //自定义 备注是否展开
    var remarkIsOpen = false
    
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
        intro <- map["intro"]
        unitType <- map["unitType"]
        cusPrice <- map["cusPrice"]
        roomType <- map["roomType"]
        count <- map["count"]
        type <- map["type"]
        category <- map["category"]
        buyCount <- map["buyCount"]
        serviceType <- map["serviceType"]
    }
    
}
