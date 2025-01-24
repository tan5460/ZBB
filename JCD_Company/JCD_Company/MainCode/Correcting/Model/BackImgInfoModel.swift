//
//  BackImgInfoModel.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class BackImgInfoModel: NSObject, Mappable {
    
    var cityBackImg: String?
    var backImg: String?
    var storeBackImg: String?
    var downloadurl: String?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        cityBackImg <- map["cityBackImg"]
        backImg <- map["backImg"]
        storeBackImg <- map["storeBackImg"]
        downloadurl <- map["downloadurl"]
    }
    
}
