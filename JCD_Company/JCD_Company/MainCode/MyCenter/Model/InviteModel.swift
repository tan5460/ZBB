//
//  InviteModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/29.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class InviteModel: NSObject, Mappable {
    
    var id: String?                     //id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var countWorker: NSNumber?          //邀请数量
    var sumIntegral: NSNumber?          //交易总额
    var workerList: Array<WorkerModel>?            //成员列表
    
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
        countWorker <- map["countWorker"]
        sumIntegral <- map["sumIntegral"]
        workerList <- map["workerList"]
    }
}

