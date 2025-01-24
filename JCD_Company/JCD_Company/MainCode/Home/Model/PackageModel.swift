//
//  PackageModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/9.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class PackageModel: NSObject, Mappable {
    
    var id: String?                     //主材包id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //主材包名
    var roomType: NSNumber?             //房间类型
    var costPrice: NSNumber?            //成本费
    var type: NSNumber?                 //主材包类型
    var unitType: NSNumber?             //单位类型
    var count: String?                  //数量
    var category: CategoryModel?        //分类
    var materials: MaterialsModel?      //主材
    var packageType: NSNumber = 1       //主材包类型  1.套餐主材包 2.新增主材商城 3.新增临时主材
    
    var plus: PlusModel?                //套餐
    var store: StoreModel?              //店铺
    var yzbFreeTemplate: FreeModel?     //自由模板
    
    //非数据返回、自定义添加
    var isCheck = false                 //是否选中
    var isEditCheck = false             //是否在编辑中选中
    
    override init() {
        super.init()
        plus = PlusModel()
        category = CategoryModel()
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
        roomType <- map["roomType"]
        costPrice <- map["costPrice"]
        type <- map["type"]
        unitType <- map["unitType"]
        count <- map["count"]
        plus <- map["materialsplus"]
        category <- map["category"]
        materials <- map["materials"]
        packageType <- map["packageType"]
        store <- map["store"]
        yzbFreeTemplate <- map["yzbFreeTemplate"]
    }
    
    
}
