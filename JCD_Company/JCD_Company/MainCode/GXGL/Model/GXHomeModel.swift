//
//  GXHomeModel.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/23.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class GXHomeModel: NSObject, Mappable{
    var newProductsMaterials: [MaterialsModel]?
    var clearanceActivities : [GXClearanceActivityModel]?
    var orderCount : Int?
    var promotion : GXPromotionModel?
    var publishCount: Int?
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        newProductsMaterials <- map["newProductsMaterials"]
        clearanceActivities <- map["clearanceActivities"]
        orderCount <- map["orderCount"]
        publishCount <- map["publishCount"]
        promotion <- map["promotion"]
        
    }
    
}

class GXPromotionModel: NSObject, Mappable{
    var promotionMaterials : [MaterialsModel]?
    var promotionTime : Int?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        promotionMaterials <- map["promotionMaterials"]
        promotionTime <- map["promotionTime"]
        
    }
    
}

class GXClearanceActivityModel: NSObject, Mappable{
    var brandName : AnyObject?
    var categoryaId : AnyObject?
    var createBy : String?
    var createDate : AnyObject?
    var id : String?
    var isCheck : Int?
    var materials : MaterialsModel?
    var materialsCount : Int?
    var materialsId : String?
    var materialsName : String?
    var merchantName : String?
    var price : Int?
    var priceSort : AnyObject?
    var priceSupply : Int?
    var remarks : AnyObject?
    var shelfFlag : Int?
    var skuAttr : String?
    var skuId : String?
    var sortNo : Int?
    var unitTypeId : AnyObject?
    var unitTypeName : String?
    var updateBy : String?
    var updateDate : String?
    var userId : String?

    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        brandName <- map["brandName"]
        categoryaId <- map["categoryaId"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        id <- map["id"]
        isCheck <- map["isCheck"]
        materials <- map["materials"]
        materialsCount <- map["materialsCount"]
        materialsId <- map["materialsId"]
        materialsName <- map["materialsName"]
        merchantName <- map["merchantName"]
        price <- map["price"]
        priceSort <- map["priceSort"]
        priceSupply <- map["priceSupply"]
        remarks <- map["remarks"]
        shelfFlag <- map["shelfFlag"]
        skuAttr <- map["skuAttr"]
        skuId <- map["skuId"]
        sortNo <- map["sortNo"]
        unitTypeId <- map["unitTypeId"]
        unitTypeName <- map["unitTypeName"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        userId <- map["userId"]
        
    }
    
}
