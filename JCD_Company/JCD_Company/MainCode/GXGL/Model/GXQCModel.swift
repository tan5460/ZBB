//
//  GXQCModel.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/24.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class GXQCModel: NSObject, Mappable{
    var brandName : [String]?
    var category : [GXQCCategoryModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        brandName <- map["brandName"]
        category <- map["category"]
    }
    
}



class GXQCCategoryModel: NSObject, Mappable{
    var id : String?
    var name : String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        
    }
    
}

