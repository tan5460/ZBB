//
//  VersionModel.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/9/21.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class VersionModel: NSObject, Mappable {
    var id: String?
    var createBy: String?
    var createDate: String?
    var updateBy: String?
    var updateDate: String?
    var remarks: String?
    var delFlag: String?
    var ver: String?                    //版本号
    var isrequired: NSNumber?           //是否强制更新 0.否 1.是
    var systemType: NSNumber?           //系统类型 1.苹果 2.安卓
    var ischeck: NSNumber?              //是否审核 0.否 1.是
    var isonline: NSNumber?             //是否上线 0.否 1.是
    var appname: String?                //app名
    var downloadurl: String?            //更新网址
    var title: String?                  //更新标题
    var info: String?                   //更新提示消息

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        id <- map["id"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        remarks <- map["remarks"]
        delFlag <- map["delFlag"]
        ver <- map["ver"]
        isrequired <- map["isrequired"]
        systemType <- map["systemType"]
        ischeck <- map["ischeck"]
        isonline <- map["isonline"]
        appname <- map["appname"]
        downloadurl <- map["downloadurl"]
        title <- map["title"]
        info <- map["info"]
    }
}
