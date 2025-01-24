//
//  SystemMsgModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 28.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class SystemMsgModel: NSObject, Mappable {
    
    var id: String?                     //id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var sendType: String?               //推送类型
    var messageContentS: String?        //消息内容（富文本）
    var noTitle: String?                //推送标题
    var pushTime: NSNumber?             //推送时间
    var messageTitle: String?           //消息标题
    var pushImg: String?                //消息图片
    
    var isNewMsg = false
    
    
    var page: String?
    var messageType: Int?
    var comName: String?
    var isRead: Int?
    var type: Int?
    var isDealwith: Int?
    var message: String?
    var comId: String?
    var orderId: String?
    var createTime: String?
    
    var merchantName : String?
    var orderNo : String?
    var orderType : Int?
    var storeName : String?
    var substationId : AnyObject?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        sendType <- map["sendType"]
        messageContentS <- map["messageContentS"]
        noTitle <- map["noTitle"]
        pushTime <- map["pushTime"]
        messageTitle <- map["messageTitle"]
        pushImg <- map["pushImg"]
        isNewMsg <- map["isNewMsg"]
        
        page <- map["page"]
        messageType <- map["messageType"]
        comName <- map["comName"]
        isRead <- map["isRead"]
        type <- map["type"]
        isDealwith <- map["isDealwith"]
        message <- map["message"]
        comId <- map["comId"]
        orderId <- map["orderId"]
        createTime <- map["createTime"]
        
        comId <- map["comId"]
        createTime <- map["createTime"]
        id <- map["id"]
        isDealwith <- map["isDealwith"]
        isRead <- map["isRead"]
        merchantName <- map["merchantName"]
        message <- map["message"]
        messageType <- map["messageType"]
        orderId <- map["orderId"]
        orderNo <- map["orderNo"]
        orderType <- map["orderType"]
        page <- map["page"]
        storeName <- map["storeName"]
        substationId <- map["substationId"]
        type <- map["type"]
    }
}
