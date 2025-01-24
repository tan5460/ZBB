//
//  MaterialRelationModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/10.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class MaterialRelationModel: NSObject, Mappable {
    
    var id: String?                     //关联id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var cusPrice: NSNumber?             //自定义加减价
    
    var materialsPackage: PackageModel?    //主材包
    var materials: MaterialsModel?          //主材
    
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
        materialsPackage <- map["materialspackage"]
        materials <- map["materials"]
        cusPrice <- map["cusPrice"]
    }
    
    
}
