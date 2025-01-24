//
//  WorkerLvModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/21.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class WorkerLvModel: NSObject, Mappable {
    
    var id: String?                     //员工id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var growthEnd: NSNumber?            //结束积分
    var growthStart: NSNumber?          //开始积分
    var lv: NSNumber?                   //会员等级
    
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
        growthEnd <- map["growthEnd"]
        growthStart <- map["growthStart"]
        lv <- map["lv"]
    }
}
