//
//  MessgecContentModel.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/9.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class MessgecContentModel: NSObject ,Mappable{
   
    var text: String?

    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        text <- map["text"]
        
    }
    
   

}
