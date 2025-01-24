//
//  VRdesignModel.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/30.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class VRdesignModel: NSObject , Mappable{
    
    var area: NSNumber?             //套内面积
    var city: String?               //城市名
    var commName: String?           //小区名
    var coverPic: String?           //封面图
    var transformCoverPic: String? {    //封面图进行转化
        get {
            guard let urlStr = coverPic else { return nil }
            return urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
    }
    var createTime: String?
    var created: String?
    var createBy: String?
    var updateTime: String?
    var designId: String?           //方案id，status=1时有值
    var modifiedTime: String?       //面积
    var name: String?               //户型名
    var planId: String?             //酷家乐户型图ID
    var planPic: String?            //户型图
    var specName: String?           //房型
    var srcArea: String?            //建筑面积
    var status: String?             //0：户型阶段，1：装修阶段
    var renderpicPanoUrl: String?   //漫游图链接
    var listingId: String?          //清单id

    
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        area <- map["area"]
        city <- map["city"]
        commName <- map["commName"]
        coverPic <- map["coverPic"]
        createTime <- map["createTime"]
        created <- map["created"]
        createBy <- map["createBy"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        designId <- map["designId"]
        listingId <- map["listingId"]
        modifiedTime <- map["modifiedTime"]
        name <- map["name"]
        planId <- map["planId"]
        planPic <- map["planPic"]
        specName <- map["specName"]
        srcArea <- map["srcArea"]
        status <- map["status"]
        updateTime <- map["updateTime"]
        renderpicPanoUrl <- map["renderpicPanoUrl"]
    }
}
