//
//  HoBrandModel.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/8.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class HoBrandModel: NSObject, Mappable, NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let model = HoBrandModel()
        model.id = self.id
        model.brandName = self.brandName
        model.brandImg = self.brandImg
        model.brandType = self.brandType
        model.brandId = self.brandId
        model.isSelected = self.isSelected
        return model
    }
    

    var id: String?
    var brandName: String?
    var brandImg: String?
    var brandType: String?
    var brandId: String?
    
    var allDeliverFlag : String?
    var attrClassification : AnyObject?
    var attrDataList : [HoBrandModel]?
    var attrdataId : AnyObject?
    var buyCount : AnyObject?
    var capacity : AnyObject?
    var categoryaId : String?
    var categoryaName : String?
    var categorybId : String?
    var categorybName : String?
    var categorycId : String?
    var categorycName : String?
    var categorydId : String?
    var categorydName : AnyObject?
    var cityId : AnyObject?
    var classificationId : AnyObject?
    var code : AnyObject?
    var content : String?
    var count : Int?
    var createBy : String?
    var createDate : String?
    var customizeFlag : String?
    var delFlag : String?
    var exPackagingHigh : String?
    var exPackagingLong : String?
    var exPackagingWide : String?
    var groupName : AnyObject?
    var imageUrl : String?
    var images : String?
    var installationFlag : String?
    var intro : AnyObject?
    var isCheck : Int?
    var isFz : AnyObject?
    var isNew : String?
    var isOneSell : AnyObject?
    var isQc : String?
    var isTj : String?
    var isTop : String?
    var ishide : AnyObject?
    var keywords : String?
    var logisticsFlag : String?
    var materialsSkuList : AnyObject?
    var materialsSortIsUpper : AnyObject?
    var materialsSortSortNo : AnyObject?
    var materialsSortUserId : AnyObject?
    var materialsType : Int?
    var merchantId : String?
    var merchantName : String?
    var merchantType : String?
    var name : String?
    var no : Int?
    var page : AnyObject?
    var priceCost : Float?
    var priceSell : AnyObject?
    var priceSellMax : Int?
    var priceSellMin : Int?
    var priceShow : Int?
    var priceSupply : AnyObject?
    var priceSupplyMax : Int?
    var priceSupplyMin : AnyObject?
    var proArea : AnyObject?
    var qrCode : AnyObject?
    var recevingTerm : AnyObject?
    var remarks : String?
    var skuFlag : NSNumber?
    var sort : AnyObject?
    var sortNo : Int?
    var sortNum : AnyObject?
    var sortType : AnyObject?
    var specName : AnyObject?
    var specification : String?
    var status : AnyObject?
    var storeId : AnyObject?
    var substationId : AnyObject?
    var topFlag : AnyObject?
    var type : AnyObject?
    var unitType : Int?
    var unitTypeName : String?
    var updateBy : String?
    var updateDate : String?
    var upperFlag : String?
    var upstairsFlag : String?
    var url : String?
    var weight : String?
    var yzbMerchant : AnyObject?
    
    var isSelected = false
    
    
    var attrName: String?
    var attrDataId: String?
    var attrDataValueList: [HoBrandModel]?
    var isShowMore: Bool? = false
    var isCheckItem: Bool? = false
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        attrName <- map["attrName"]
        attrDataId <- map["attrDataId"]
        attrDataValueList <- map["attrDataValueList"]
        brandName <- map["brandName"]
        brandImg <- map["brandImg"]
        brandType <- map["brandType"]
        brandId <- map["brandId"]
        
        allDeliverFlag <- map["allDeliverFlag"]
        attrClassification <- map["attrClassification"]
        attrDataList <- map["attrDataList"]
        attrdataId <- map["attrdataId"]
        brandId <- map["brandId"]
        brandName <- map["brandName"]
        buyCount <- map["buyCount"]
        capacity <- map["capacity"]
        categoryaId <- map["categoryaId"]
        categoryaName <- map["categoryaName"]
        categorybId <- map["categorybId"]
        categorybName <- map["categorybName"]
        categorycId <- map["categorycId"]
        categorycName <- map["categorycName"]
        categorydId <- map["categorydId"]
        categorydName <- map["categorydName"]
        cityId <- map["cityId"]
        classificationId <- map["classificationId"]
        code <- map["code"]
        content <- map["content"]
        count <- map["count"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        customizeFlag <- map["customizeFlag"]
        delFlag <- map["delFlag"]
        exPackagingHigh <- map["exPackagingHigh"]
        exPackagingLong <- map["exPackagingLong"]
        exPackagingWide <- map["exPackagingWide"]
        groupName <- map["groupName"]
        id <- map["id"]
        imageUrl <- map["imageUrl"]
        images <- map["images"]
        installationFlag <- map["installationFlag"]
        intro <- map["intro"]
        isCheck <- map["isCheck"]
        isFz <- map["isFz"]
        isNew <- map["isNew"]
        isOneSell <- map["isOneSell"]
        isQc <- map["isQc"]
        isTj <- map["isTj"]
        isTop <- map["isTop"]
        ishide <- map["ishide"]
        keywords <- map["keywords"]
        logisticsFlag <- map["logisticsFlag"]
        materialsSkuList <- map["materialsSkuList"]
        materialsSortIsUpper <- map["materialsSortIsUpper"]
        materialsSortSortNo <- map["materialsSortSortNo"]
        materialsSortUserId <- map["materialsSortUserId"]
        materialsType <- map["materialsType"]
        merchantId <- map["merchantId"]
        merchantName <- map["merchantName"]
        merchantType <- map["merchantType"]
        name <- map["name"]
        no <- map["no"]
        page <- map["page"]
        priceCost <- map["priceCost"]
        priceSell <- map["priceSell"]
        priceSellMax <- map["priceSellMax"]
        priceSellMin <- map["priceSellMin"]
        priceShow <- map["priceShow"]
        priceSupply <- map["priceSupply"]
        priceSupplyMax <- map["priceSupplyMax"]
        priceSupplyMin <- map["priceSupplyMin"]
        proArea <- map["proArea"]
        qrCode <- map["qrCode"]
        recevingTerm <- map["recevingTerm"]
        remarks <- map["remarks"]
        skuFlag <- map["skuFlag"]
        sort <- map["sort"]
        sortNo <- map["sortNo"]
        sortNum <- map["sortNum"]
        sortType <- map["sortType"]
        specName <- map["specName"]
        specification <- map["specification"]
        status <- map["status"]
        storeId <- map["storeId"]
        substationId <- map["substationId"]
        topFlag <- map["topFlag"]
        type <- map["type"]
        unitType <- map["unitType"]
        unitTypeName <- map["unitTypeName"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        upperFlag <- map["upperFlag"]
        upstairsFlag <- map["upstairsFlag"]
        url <- map["url"]
        weight <- map["weight"]
        yzbMerchant <- map["yzbMerchant"]
    }
    
}
class HoSpecModel: NSObject, Mappable {

    var category: String?
    var specificationDatas: [HoSpecSubModel]?

    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        category <- map["category"]
        specificationDatas <- map["specificationDatas"]
    }
}
class HoSpecSubModel: NSObject, Mappable, NSCopying {
   
    var id: String?
    var name: String?
    var transformName: String? {
        get {
            return self.name?.replacingOccurrences(of: "x", with: "*").replacingOccurrences(of: "&times;", with: "*")
        }
    }
    var isSelected = false

    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        name <- map["name"]
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let model = HoSpecSubModel()
        model.id = self.id
        model.name = self.name
        model.isSelected = self.isSelected
        return model
    }
    

}
