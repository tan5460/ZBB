//
//  HoStoreModel.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/7.
//  Copyright © 2019 WZKJ. All rights reserved.
//

/*
 "id: String? //"80942a00c5ae4ca087fc599007428419",
 "isNewRecord: String? //false,
 "remarks: String? //null,
 "createBy: String? //"",
 "createDate: String? //"2019-09-16 09:55:52",
 "updateBy: String? //"",
 "updateDate: String? //"2019-11-06 10:35:20",
 "delFlag: String? //"0",
 "parentIds: String? //"0,",
 "name: String? //"厨房卫浴",
 "sort: String? //10,
 "remark: String? //"",
 "type: String? //1,
 "specification: String? //{
 var id: String? //"cb855a495ed34ded89f9b3bcb6fba0a6",
 var isNewRecord: String? //false,
 var remarks: String? //null,
 var createBy: String? //null,
 var createDate: String? //null,
 var updateBy: String? //null,
 var updateDate: String? //null,
 var delFlag: String? //"0",
 var name: String? //null,
 var sort: String? //null
 },
 "parentId: String? //"0",
 "logoUrl: String? //"",
 "categoryList: String? //[
 
 */
import UIKit
import ObjectMapper

class HoStoreModel: NSObject,Mappable, NSCopying {
    
    
    var id: String? //"80942a00c5ae4ca087fc599007428419",
    var isNewRecord: Bool? //false,
    var remarks: String? //null,
    var createBy: String? //"",
    var createDate: String? //"2019-09-16 09:55:52",
    var updateBy: String? //"",
    var updateDate: String? //"2019-11-06 10:35:20",
    var delFlag: String? //"0",
    var parentIds: String? //"0,",
    var name: String? //"厨房卫浴",
    var sort: NSNumber? //10,
    var remark: String? //"",
    var type: NSNumber? //1,
    var specification: HoStoreSpecification? //HoStoreSpecification,
    var parentId: String? //"0",
    var logoUrl: String? //"",
    var categoryList: [HoStoreModel]? //[HoStoreModel]
    var specDataList: [HoSpecData]?
    
    var isSelected: Bool = false // 默认非选中
    var isMoreItem: Bool = false // 扩展字段 是否为更多字样
    var isOpen:     Bool = false // 扩展字段 是否展开
    
    var categoryType : String?
    var isOneSell : String?
    var no : String?
    var specificationId : String?
    var isShowMore: Bool = false
    var isCheckItem: Bool = false
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        id <- map["id"] //String? //"80942a00c5ae4ca087fc599007428419",
        isNewRecord <- map["isNewRecord"] //Bool? //false,
        remarks <- map["remarks"] //String? //null,
        createBy <- map["createBy"] //String? //"",
        createDate <- map["createDate"] //String? //"2019-09-16 09:55:52",
        updateBy <- map["updateBy"] //String? //"",
        updateDate <- map["updateDate"] //String? //"2019-11-06 10:35:20",
        delFlag <- map["delFlag"] //String? //"0",
        parentIds <- map["parentIds"] //String? //"0,",
        name <- map["name"] //String? //"厨房卫浴",
        sort <- map["sort"] //NSNumber? //10,
        remark <- map["remark"] //String? //"",
        type <- map["type"] //NSNumber? //1,
        specification <- map["specification"] //HoStoreSpecification? //HoStoreSpecification,
        parentId <- map["parentId"] //String? //"0",
        logoUrl <- map["logoUrl"] //String? //"",
        categoryList <- map["categoryList"] //[HoStoreModel]? //[HoStoreModel]
        specDataList <- map["specDataList"] //[HoStoreModel]? //[HoStoreModel]
        categoryType <- map["categoryType"] //String? //"0",
        isOneSell <- map["isOneSell"] //String? //"",
        no <- map["no"] //[HoStoreModel]? //[HoStoreModel]
        specificationId <- map["specificationId"] //[HoStoreModel]? //[HoStoreModel]
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let model = HoStoreModel()
        var mos = [HoStoreModel]()
        self.categoryList?.forEach({ mo in
            mos.append(mo.copy() as! HoStoreModel)
        })
        model.categoryList = mos
        model.parentIds = self.parentIds
        model.id = self.id
        model.name = self.name
        model.type = self.type
        model.logoUrl = self.logoUrl
        return model
    }
}

class HoSpecData: NSObject,Mappable,NSCopying {
    
    var isSelected: Bool = false // 默认非选中
    var isMoreItem: Bool = false // 扩展字段 是否为更多字样
    var isOpen:     Bool = false // 扩展字段 是否展开
    
    var name: String? //null
    var id: String? //null
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"] //String? //"cb855a495ed34ded89f9b3bcb6fba0a6",
        name <- map["name"] //
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let model = HoSpecData()
        model.name = self.name
        model.id = self.id
        model.isOpen = self.isOpen
        model.isMoreItem = self.isMoreItem
        model.isSelected = self.isSelected
        return model
    }
}

class HoStoreSpecification: NSObject {
    var id: String? //"cb855a495ed34ded89f9b3bcb6fba0a6",
    var isNewRecord: Bool? //false,
    var remarks: String? //null,
    var createBy: String? //null,
    var createDate: String? //null,
    var updateBy: String? //null,
    var updateDate: String? //null,
    var delFlag: String? //"0",
    var name: String? //null,
    var sort: NSNumber? //null
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        id <- map["id"] //String? //"cb855a495ed34ded89f9b3bcb6fba0a6",
        isNewRecord <- map["isNewRecord"] //String? //false,
        remarks <- map["remarks"] //String? //null,
        createBy <- map["createBy"] //String? //null,
        createDate <- map["createDate"] //String? //null,
        updateBy <- map["updateBy"] //String? //null,
        updateDate <- map["updateDate"] //String? //null,
        delFlag <- map["delFlag"] //String? //"0",
        name <- map["name"] //String? //null,
        sort <- map["sort"] //String? //null
    }
}

