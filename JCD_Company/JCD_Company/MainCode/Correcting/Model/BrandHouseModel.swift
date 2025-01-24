//
//  asd.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//
import UIKit
import ObjectMapper

class BrandHouseModel: NSObject, Mappable {
    
    var sortNo: Int?
    var categoryId: String? = "0"
    var categoryName: String? = "全部"
    var brandList: [BrandListItem]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        sortNo <- map["sortNo"]
        categoryId <- map["categoryId"]
        categoryName <- map["categoryName"]
        brandList <- map["brandList"]
       
        
        //let jsonStr = "{\"categoryIdName\": \"全部\",\"categoryId\":\"0\"}"
        
    }
    
}

class MerchantBrandListModel: NSObject, Mappable {

    var categoryId: String?
    var categoryIdName: String?
    var merchantList:[MerchantModel]?
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        categoryId <- map["categoryId"]
        categoryIdName <- map["categoryIdName"]
        merchantList <- map["merchantList"]
    
        merchantList = merchantList?.filterDuplicates({$0.id})
        
        
    }
    
}

//直接给Array扩展一个去重方法
extension Array {
    
    // 去重
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
}
