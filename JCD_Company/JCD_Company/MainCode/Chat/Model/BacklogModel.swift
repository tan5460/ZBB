//
//  BacklogModel.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class BacklogModel: NSObject, Mappable {
   
    var id: String?                     //待办id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var orderNo: String?                //订单号
    var createTime: String?           //订单时间
    var orderId: String?                //订单id
    var comName: String?                //公司名
    var comId: String?                  //公司 id
    var substationId: String?           //分站id
    var mName: String?                  //供应商名
    var isRead: NSNumber?               //是否已读
    var type: NSNumber?                 //类型
    var message: String?                //消息
    var delFlag: NSNumber?              //供应商名
    var msgType: String?                //待办类型 1：采购；2：客户
    
    var city: CityModel?               //城市
    var isNewLog = false
    
    
    var isDealwith : Int?
    var merchantName : String?
    var messageType : Int?
    
    var orderType : Int?
    var purchaseOrderType: String?
    var page : AnyObject?
    var storeName : String?
    var storeContacts : String?

    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        storeContacts <- map["storeContacts"]
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        remarks <- map["remarks"]
        orderNo <- map["orderNo"]
        createTime <- map["createTime"]
        orderId <- map["orderId"]
        comName <- map["comName"]
        comId <- map["comId"]
        substationId <- map["substationId"]
        mName <- map["mName"]
        isRead <- map["isRead"]
        type <- map["type"]
        message <- map["message"]
        delFlag <- map["delFlag"]
        city <- map["city"]
        isNewLog <- map["isNewLog"]
        msgType <- map["msgType"]
        
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
        purchaseOrderType <- map["purchaseOrderType"]
        page <- map["page"]
        storeName <- map["storeName"]
        substationId <- map["substationId"]
        type <- map["type"]
    }
}
