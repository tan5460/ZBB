//
//  PlusDataModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2017/12/28.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class PlusDataModel: NSObject, Mappable {
    
    var roomType: NSNumber?                         //房间类型
    var packageList: Array<PackageModel> = []       //主材包列表
    var serviceList: Array<ServiceModel> = []       //施工列表
    
    var isCheck = false                             //是否选中此房间
    var isShow = false                              //是否正在展示
    
    override init() {
        super.init()
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        roomType <- map["roomType"]
        packageList <- map["packageList"]
        serviceList <- map["serviceList"]
    }
}
