//
//  CarouselModel.swift
//  YZB_Company
//
//  Created by liuyi on 2018/12/7.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class CarouselModel: NSObject, Mappable {
    
    var id: String?
    var no: String?
    var imgUrl: String?
    var createTime: String?
    var updateTime: String?
    var title: String?
    var url: String?
    var img: String?
    
    var store: StoreModel?              //店铺
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        no <- map["no"]
        imgUrl <- map["imgUrl"]
        createTime <- map["createTime"]
        updateTime <- map["updateTime"]
        title <- map["title"]
        url <- map["url"]
        store <- map["store"]
        img <- map["img"]
    }

}
