//
//  IntegralDetailModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/23.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class IntegralDetailModel: NSObject, Mappable {
    
    var id: String?                     //员工id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var changeDetail: String?           //明细
    var changeTime: String?             //时间
    var changeValue: String?            //变化值
    var type: NSNumber?                 //类型
    var worker: WorkerModel?            //员工
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        changeDetail <- map["changeDetail"]
        changeTime <- map["changeTime"]
        changeValue <- map["changeValue"]
        type <- map["type"]
        worker <- map["worker"]
    }
}
