//
//  IntegralMallModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/22.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class IntegralMallModel: NSObject, Mappable {
    
    var id: String?                     //员工id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var goodsCount: NSNumber?           //库存
    var integration: String?            //兑换积分
    var goodsName: String?              //商品名
    var goodsUrl: String?               //商品图片
    var needLv: String?                 //兑换所需等级
    var exchangeCount: NSNumber?        //已兑换次数
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        goodsCount <- map["goodsCount"]
        integration <- map["integration"]
        goodsName <- map["goodsName"]
        goodsUrl <- map["goodsUrl"]
        needLv <- map["needLv"]
        exchangeCount <- map["exchangeCount"]
    }
}
