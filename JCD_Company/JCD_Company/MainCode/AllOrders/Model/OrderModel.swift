//
//  OrderModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/24.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class OrderModel: NSObject, Mappable {
    
    var id: String?                     //订单id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var payType: NSNumber?              //支付类型
    var payStatus: NSNumber?            //支付状态
    var orderStatus: NSNumber?          //订单状态（1：等待商家确认，2：等待商家确认，3：商家已确认，4: 完成付款， 5: 上家发货， 6：已确认收货， 7: 已评价， 8: 订单取消， 9: 已付款待审核， 10： 付款审核拒绝）
    var payMoney: NSNumber?             //需支付金额
    var orderTime: String?              //下单时间
    var orderOkTime: String?            //订单成交时间
    var orderEndtime: String?           //订单结束时间
    var billNo: String?                 //微信或支付宝对账单号
    var materialsList: String?          //主材列表
    var materialsplusDetails: String?   //套餐详情
    var orderNo: String?                //订单号
    var plusType: NSNumber?             //套餐类型
    var orderType: NSNumber?            //订单类型 1、自由组合 2、套餐下单 3、自由开单
    
    var msize: NSNumber?                //主材数量
    var sSize: NSNumber?                //施工数量
    var storeId: String?                //店铺
    var workerId: String?               //员工
    var house: HouseModel?              //工地
    var plus: PlusModel?                //套餐
    
    var address : String?
    var beginOrderTime : String?
    var createBy : String?
    var customHeadUrl : String?
    var customId : String?
    var customName : String?
    var customeMobile : String?
    var delFlag : String?
    var endOrderTime : String?
    var expressAdd : String?
    var shippingAddress : String?
    var expressName : String?
    var expressPhone : String?
    var expressTel : String?
    var houseId : String?
    var houseSpace : NSNumber?
    var isPurchase : Int?
    var isPurchaseName : String?
    var jobTypeName : String?
    var lat : String?
    var lon : String?
    var orderStatusName : String?
    var plotName : String?
    var plusId : String?
    var roomNo : String?
    var sex : NSNumber?
    var updateBy : String?
    var workerName : String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    
    
    func mapping(map: Map) {
        id <- map["id"]
        shippingAddress <- map["shippingAddress"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        payType <- map["payType"]
        payStatus <- map["payStatus"]
        orderStatus <- map["orderStatus"]
        payMoney <- map["payMoney"]
        orderTime <- map["orderTime"]
        orderOkTime <- map["orderOkTime"]
        orderEndtime <- map["orderEndtime"]
        billNo <- map["billNo"]
        materialsList <- map["materialsList"]
        materialsplusDetails <- map["materialsplusDetails"]
        orderNo <- map["orderNo"]
        storeId <- map["storeId"]
        workerId <- map["workerId"]
        house <- map["house"]
        plus <- map["plus"]
        plusType <- map["plusType"]
        orderType <- map["orderType"]
        msize <- map["msize"]
        sSize <- map["sSize"]
        
        
        workerName <- map["workerName"]
        updateBy <- map["updateBy"]
        sex <- map["sex"]
        roomNo <- map["roomNo"]
        plusId <- map["plusId"]
        plotName <- map["plotName"]
        orderStatusName <- map["orderStatusName"]
        lon <- map["lon"]
        lat <- map["lat"]
        jobTypeName <- map["jobTypeName"]
        isPurchaseName <- map["isPurchaseName"]
        isPurchase <- map["isPurchase"]
        houseSpace <- map["houseSpace"]
        houseId <- map["houseId"]
        expressTel <- map["expressTel"]
        expressPhone <- map["expressPhone"]
        expressName <- map["expressName"]
        expressAdd <- map["expressAdd"]
        endOrderTime <- map["endOrderTime"]
        delFlag <- map["delFlag"]
        customeMobile <- map["customeMobile"]
        customName <- map["customName"]
        customId <- map["customId"]
        customHeadUrl <- map["customHeadUrl"]
        createBy <- map["createBy"]
        beginOrderTime <- map["beginOrderTime"]
        address <- map["address"]
        
    }
}
