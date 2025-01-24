//
//  BrandList.swift
//  YZB_Company
//
//  Created by Mac on 16.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class BrandListItem: NSObject, Mappable {

    var merchant : [MerchantItem]? //
    var id : String? = "0"//  "8F4772F0D338483C9C40DA824F026022",
    var isNewRecord : String? //  false,
    var remarks : String? //  null,
    var createBy : String? //  null,
    var createDate : String? //  null,
    var updateBy : String? //  null,
    var updateDate : String? //  null,
    var delFlag : String? //  "0",
    var brandImg : String? //  "/webfile/430100/company/203/plus/image/8457c32ad515459a82bcfd0807a83bb1.jpg",
    var transformImageURL: String? {    //对主图片中的异常字符进行转化
        get {
            guard let urlStr = brandImg else { return nil }
            return urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
    }
    var brandName : String? = "全部"//  "贝朗卫浴",
    var brandType : String? //  "80942a00c5ae4ca087fc599007428419,b1d583e8cc5c4ca5875e5b7b2358ff9d,",
    var checkStatus : String? //  "1",
    var upperStatus : String? //  "0",
    var createTime : String? //  null,
    var updateTime : String? //  null,
    var content : String? //
    var contents : String? //  null,
    var substationId : String? //  null,
    var categoryId : String? //  null,
    var brandId : String?  = "0"//  "8F4772F0D338483C9C40DA824F026022"
    
    required init?(map: Map) {
        
    }
    override init() {
        super.init()
        
    }
    
    func mapping(map: Map) {
        merchant <- map["merchant"]
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        delFlag <- map["delFlag"]
        brandImg <- map["brandImg"]
        brandName <- map["brandName"]
        brandType <- map["brandType"]
        checkStatus <- map["checkStatus"]
        upperStatus <- map["upperStatus"]
        createTime <- map["createTime"]
        updateTime <- map["updateTime"]
        content <- map["content"]
        contents <- map["contents"]
        substationId <- map["substationId"]
        categoryId <- map["categoryId"]
        brandId <- map["brandId"]
    }
}
