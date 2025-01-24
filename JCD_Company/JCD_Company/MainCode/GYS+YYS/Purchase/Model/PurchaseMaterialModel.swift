//
//  PurchaseMaterial.swift
//  YZB_Company
//
//  Created by yzb_ios on 15.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class PurchaseMaterialModel: NSObject, Mappable {
    
    var id: String?                     //id
    var isNewRecord: NSNumber?          //是否新建
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //主材名
//    var price: NSNumber?                //总价
    var costPrice: NSNumber?            //单价
    var spec: String?                   //规格
    var transformSpec: String? {
        get {
            return self.spec?.replacingOccurrences(of: "x", with: "*").replacingOccurrences(of: "&times;", with: "*")
        }
    }
    var unitType: String?               //单位
    var remarks: String? = nil              //备注
    var remarks2: String? = nil               //颜色和样式
    var remarks3: String? = nil               //使用区域
    var fileUrls: String?               //附件
    var materialsCount: String?         //数量
    
    var materials: MaterialsModel?
    var orderTemp: PurchaseMaterialModel?
    
    //自定义参数
    var isSelectCheck = false           //是否勾选
    var countInt: Double = 0            //整数数量
    var count: NSNumber = 0            //整数数量
    var brandName : String?
    var createBy : String?
    var cusCostMoney : AnyObject?
    var cusMoney : AnyObject?
    var cusMoneyRemarks : AnyObject?
    var delFlag : String?
    var image : String?
    var isOnesell : Int?
    var materialsId : String?
    var materialsImageUrl : String?
    var materialsMoney : AnyObject?
    var materialsName : String?
    var materialsPriceSupply : AnyObject?
    var materialsPurMoney : AnyObject?
    var materialsSpecification : AnyObject?
    var materialsSpecificationName : AnyObject?
    var materialsUnitType : Int?
    var materialsUnitTypeName : String?
    var merchantId : AnyObject?
    var merchantName : String?
    var moneyAll : AnyObject?
    var moneyExpress : AnyObject?
    var moneyInstall : AnyObject?
    var moneyMaterials : NSNumber?
    var moneyMaterialsCost : NSNumber?
    var moneyMaterialsCustom : NSNumber?
    var moneyMeasure : AnyObject?
    var moneyOther : AnyObject?
    var orderNo : AnyObject?
    var orderPayTime : NSNumber?
    var orderStatus : AnyObject?
    var price : NSNumber?
    var price1 : NSNumber? {
        get {
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                return moneyMaterialsCustom
            } else {
                return price
            }
        }
    }
    var purchaseOrderId : String?
    var queryBeginTime : AnyObject?
    var queryEndTime : AnyObject?
    var skuAttr : String?
    var skuAttr1: String? {
        get {
            let arr = skuAttr?.getArrayByJsonString()
            var str = ""
            for dic in (arr ?? [[String: Any]]()) {
                let dic1 = dic as! [String: Any]
                let value =  dic1["skuValue"] as? String
                str.append("\(value ?? "") ")
            }
            return str
        }
    }
    var skuId : String?
    var skuSnapshot : String?
    var storeId : AnyObject?
    var storeName : AnyObject?
    var substationId : AnyObject?
    var timeExpress : AnyObject?
    var timeInstall : AnyObject?
    var timeMeasure : AnyObject?
    var updateBy : AnyObject?
    
    
    
    
    override init() {
        super.init()
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        count <- map["count"]
        isNewRecord <- map["isNewRecord"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        name <- map["name"]
//        price <- map["price"]
        costPrice <- map["costPrice"]
        spec <- map["spec"]
        unitType <- map["unitType"]
        remarks <- map["remarks"]
        remarks2 <- map["remarks2"]
        remarks3 <- map["remarks3"]
        fileUrls <- map["fileUrls"]
        materialsCount <- map["materialsCount"]
        materials <- map["materials"]
        orderTemp <- map["orderTemp"]
        
        brandName <- map["brandName"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        cusCostMoney <- map["cusCostMoney"]
        cusMoney <- map["cusMoney"]
        cusMoneyRemarks <- map["cusMoneyRemarks"]
        delFlag <- map["delFlag"]
        fileUrls <- map["fileUrls"]
        id <- map["id"]
        image <- map["image"]
        isOnesell <- map["isOnesell"]
        materialsCount <- map["materialsCount"]
        materialsId <- map["materialsId"]
        materialsImageUrl <- map["materialsImageUrl"]
        materialsMoney <- map["materialsMoney"]
        materialsName <- map["materialsName"]
        materialsPriceSupply <- map["materialsPriceSupply"]
        materialsPurMoney <- map["materialsPurMoney"]
        materialsSpecification <- map["materialsSpecification"]
        materialsSpecificationName <- map["materialsSpecificationName"]
        materialsUnitType <- map["materialsUnitType"]
        materialsUnitTypeName <- map["materialsUnitTypeName"]
        merchantId <- map["merchantId"]
        merchantName <- map["merchantName"]
        moneyAll <- map["moneyAll"]
        moneyExpress <- map["moneyExpress"]
        moneyInstall <- map["moneyInstall"]
        moneyMaterials <- map["moneyMaterials"]
        moneyMaterialsCost <- map["moneyMaterialsCost"]
        moneyMaterialsCustom <- map["moneyMaterialsCustom"]
        moneyMeasure <- map["moneyMeasure"]
        moneyOther <- map["moneyOther"]
        orderNo <- map["orderNo"]
        orderPayTime <- map["orderPayTime"]
        orderStatus <- map["orderStatus"]
        price <- map["price"]
        purchaseOrderId <- map["purchaseOrderId"]
        queryBeginTime <- map["queryBeginTime"]
        queryEndTime <- map["queryEndTime"]
        remarks <- map["remarks"]
        remarks2 <- map["remarks2"]
        remarks3 <- map["remarks3"]
        skuAttr <- map["skuAttr"]
        skuId <- map["skuId"]
        skuSnapshot <- map["skuSnapshot"]
        storeId <- map["storeId"]
        storeName <- map["storeName"]
        substationId <- map["substationId"]
        timeExpress <- map["timeExpress"]
        timeInstall <- map["timeInstall"]
        timeMeasure <- map["timeMeasure"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
    }
}
