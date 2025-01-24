//
//  CompanyDetailModel.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/13.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class CompanyDetailModel: NSObject , Mappable {
    
    var houseCaseList: [HouseCaseModel]?
    var workerCount: Int?
    var certificateList: [CertificateModel]?
    var licenseUrl: String?
    var store: StoreDetailModel?
    var workerList: [RegisterModel]?
    var bannerList: [CertificateModel]?
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        houseCaseList <- map["houseCaseList"]
        workerCount <- map["workerCount"]
        certificateList <- map["certificateList"]
        licenseUrl <- map["licenseUrl"]
        store <- map["store"]
        workerList <- map["workerList"]
        bannerList <- map["bannerList"]
    }
}


class CertificateModel: NSObject , Mappable {
    
    var certificateType : String?
    var createBy : String?
    var createDate : String?
    var fileType : String?
    var fileUrl : String?
    var id : String?
    var isShow : String?
    var linkUrl : String?
    var remarks : String?
    var sortNo : String?
    var storeId : String?
    var title : String?
    var updateBy : String?
    var updateDate : String?
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        certificateType <- map["certificateType"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        fileType <- map["fileType"]
        fileUrl <- map["fileUrl"]
        id <- map["id"]
        isShow <- map["isShow"]
        linkUrl <- map["linkUrl"]
        remarks <- map["remarks"]
        sortNo <- map["sortNo"]
        storeId <- map["storeId"]
        title <- map["title"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
    }
    
    
}


class StoreDetailModel: NSObject , Mappable {
    
    var businessYears : String?
    var houseCaseCount : Int?
    var houseCount : Int?
    var storeAddress : String?
    var storeConsult : Int?
    var storeIntro : String?
    var storeLogo : String?
    var storeMobile : String?
    var storeName : String?
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        businessYears <- map["businessYears"]
        houseCaseCount <- map["houseCaseCount"]
        houseCount <- map["houseCount"]
        storeAddress <- map["storeAddress"]
        storeConsult <- map["storeConsult"]
        storeIntro <- map["storeIntro"]
        storeLogo <- map["storeLogo"]
        storeMobile <- map["storeMobile"]
        storeName <- map["storeName"]
    }
    
    
}


class CasePriceModel: NSObject , Mappable {
    
    var caseId : String?
    var constructionAddPrice : NSNumber?
    var constructionPrice : NSNumber?
    var createDate : String?
    var houseArea : String?
    var id : String?
    var materialAddPrice : NSNumber?
    var materialPrice : NSNumber?
    var singlePrice : NSNumber?
    var totalPrice : NSNumber?
    var type : String?
    var updateDate : String?
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        caseId <- map["caseId"]
        constructionAddPrice <- map["constructionAddPrice"]
        constructionPrice <- map["constructionPrice"]
        createDate <- map["createDate"]
        houseArea <- map["houseArea"]
        id <- map["id"]
        materialAddPrice <- map["materialAddPrice"]
        materialPrice <- map["materialPrice"]
        singlePrice <- map["singlePrice"]
        totalPrice <- map["totalPrice"]
        type <- map["type"]
        updateDate <- map["updateDate"]
    }
    
    
}


class CertificateListModel: NSObject , Mappable {
    
    var licenseUrl : String?
    var qualificationCertificate : [CertificateDetailModel]?
    var other : [CertificateDetailModel]?
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        licenseUrl <- map["licenseUrl"]
        qualificationCertificate <- map["qualificationCertificate"]
        other <- map["other"]
    }
    
    
}

class CertificateDetailModel: NSObject , Mappable {
    
    var certificateType : String?
    var createBy : AnyObject?
    var createDate : String?
    var fileType : String?
    var fileUrl : String?
    var id : String?
    var isShow : String?
    var linkUrl : AnyObject?
    var remarks : AnyObject?
    var sortNo : AnyObject?
    var storeId : String?
    var title : String?
    var updateBy : AnyObject?
    var updateDate : AnyObject?
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        certificateType <- map["certificateType"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        fileType <- map["fileType"]
        fileUrl <- map["fileUrl"]
        id <- map["id"]
        isShow <- map["isShow"]
        linkUrl <- map["linkUrl"]
        remarks <- map["remarks"]
        sortNo <- map["sortNo"]
        storeId <- map["storeId"]
        title <- map["title"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
    }
    
    
}
