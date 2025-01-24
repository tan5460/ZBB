//
//  SpecificationModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/9/18.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import HandyJSON

class SpecificationModel: NSObject, Mappable {
    
    var id: String?                     //主材规格id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //规格名
    var transformName: String? {
        get {
            return self.name?.replacingOccurrences(of: "x", with: "*").replacingOccurrences(of: "&times;", with: "*")
        }
    }
    var createBy: String? // null,
    var updateBy: String? // null,
    var delFlag: String? // "0",
    var sort: String? // null
    required init?(map: Map) {
        
    }
    override init() {
        super.init()
        
    }
    
    func mapping(map: Map) {
        id <- map["id"] //"",
        isNewRecord <- map["isNewRecord"] //true,
        remarks <- map["remarks"] //null,
        createBy <- map["createBy"] //null,
        createDate <- map["createDate"] //null,
        updateBy <- map["updateBy"] //null,
        updateDate <- map["updateDate"] //null,
        delFlag <- map["delFlag"] //"0",
        name <- map["name"] //null,
        sort <- map["sort"] //null
    }
}


struct SpecificationM: HandyJSON {
    
    var id: String?                     //主材规格id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //规格名
    var transformName: String? {
        get {
            return self.name?.replacingOccurrences(of: "x", with: "*").replacingOccurrences(of: "&times;", with: "*")
        }
    }
    var createBy: String? // null,
    var updateBy: String? // null,
    var delFlag: String? // "0",
    var sort: String? // null
}
