//
//  ProviceModel.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/11.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import HandyJSON

struct ProviceModel: HandyJSON {
    var areaName : AnyObject?
    var id : String?
    var lat : String?
    var level : Int?
    var lng : String?
    var parentId : String?
    var positio : String?
    var shortName : String?
    var sort : Int?
}
