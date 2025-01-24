//
//  CategoryModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/16.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import HandyJSON

class CategoryModel: NSObject, Mappable {
    
    var id: String?                     //分类id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var parentId: String?               //父级编号
    var parentIds: String?              //所有父级编号
    var name: String?                   //分类名称
    var sort: String?                   //排序
    var remark: String?                 //备注
    var type: NSNumber?                 //类型
    
    var specification: SpecificationModel?       //主材规格
    
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
        parentId <- map["parentId"]
        parentIds <- map["parentIds"]
        name <- map["name"]
        sort <- map["sort"]
        remark <- map["remark"]
        type <- map["type"]
        specification <- map["specification"]
    }

}


struct CategoryM: HandyJSON {
    var id: String?                     //分类id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var parentId: String?               //父级编号
    var parentIds: String?              //所有父级编号
    var name: String?                   //分类名称
    var sort: String?                   //排序
    var remark: String?                 //备注
    var type: NSNumber?                 //类型
    var specification: SpecificationModel?       //主材规格
}
