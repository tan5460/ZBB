//
//  ActivityModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/9.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class ActivityModel: NSObject, Mappable {
    
    var id: String?                     //活动id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var store: StoreModel?              //店铺
    var startDate: String?              //开始时间
    var endDate: String?                //结束时间
    var title: String?                  //活动名字
    var picurlArr: NSArray?             //图片数组
    var content: String?                //内容
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        store <- map["store"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        title <- map["title"]
        picurlArr <- map["picurlArr"]
        content <- map["content"]
    }
    
}
