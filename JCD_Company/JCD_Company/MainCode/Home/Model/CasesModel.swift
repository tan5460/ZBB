//
//  CasesModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/9.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class CasesModel: NSObject, Mappable {
    
    var id: String?                     //案例id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var store: StoreModel?              //店铺
    var title: String?                  //案例名字
    var nameArr: NSArray?               //名字数组
    var picurlArr: NSArray?             //图片数组
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        store <- map["store"]
        title <- map["title"]
        nameArr <- map["nameArr"]
        picurlArr <- map["picurlArr"]
    }
    
}
