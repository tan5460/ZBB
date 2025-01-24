//
//  PuechaseOrderModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 11.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class PurchaseOrderModel: NSObject, Mappable {
    
    var id: String?                     //采购订单id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var orderNo: String?                //订单号
    var orderTime: String?            //订单时间
    var timeLimit: String?         // 服务订单所需工期
    var orderUneffectiveTime: String? ///订单失效时间
    var orderStatus: NSNumber?          //订单状态    // 2: 等待商家确认 3: 商家已确认 4: 完成付款 5: 商家出货 6: 已确认收货 8: 订单取消 9: 已付款待审核  10: 付款审核拒绝 11: 已失效
    var payStatus: NSNumber?            //支付状态
    var payType: NSNumber?              //支付类型
    var orderPayTime: String?         //订单支付时间
    var payMoney: NSNumber?             //订单平台价
    var qualityMoney: NSNumber?         //质保金
    var costMoney: NSNumber?            //订单成本价
    var supplyMoney: NSNumber?          //商品总价
    var serviceMoney: NSNumber?         //服务费
    var tel: String?                    //收货电话
    var expressPhone: String?           //座机
    var address: String?                //收货地址
    var contact: String?                //收货人
    var sendTerm: String?               //发货期限
    var serviceRemarks: String?         //备注
    var citySubstationId: String?
    var platformTradServiceMoney: NSNumber?//": 3.00, // 平台交易服务佣金
    var platServiceMoneyRate: NSNumber?    //": 0.03, 佣金费率
    
    var voucher: VoucherModel?          //支付信息
    var purchase: PurchaseModel?        //采购信息
    var worker: WorkerModel?            //下单员工
    var store: StoreModel?              //采购店铺
    var merchant: MerchantModel?        //供应商
    var house: HouseModel?              //工地
    var materialsList: Array<PurchaseMaterialModel>?
    var cusMaterialsList: Array<PurchaseMaterialModel>?
    
    var commissionMoneyAll : Float?
    var commissionRate : Float?
    var confirm : Int?
    var content : String?
    var costServiceMoney : Int?
    var delFlag : String?
    var divideAmount : Int?
    var houseId : String?
    var isChange : Int?
    var merchantId : String?
    var merchantName : String?
    var premiumMoneyAll : Float?
    var premiumRate : Float?
    var purchaseId : String?
    var rebateStatus : Int?
    var recevingTerm : String?
    var serviceCharge : Int?
    var storeId : String?
    var storeName : String?
    var workerName : String?
    var workerId: String?
    
    var activityType : Int? // 1 清仓处理  2:每周特惠
    var count : Int?
    var customName : String?
    var imageUrl : String?
    var merchantType : Int?
    var name : String?
    var orderType : Int?
    var updateBy : String?
    var isCheck: Int?
    
    var discountMoney: NSNumber?
    var operReason: String?
    var logisticsCompany: String?
    var logisticsNo: String?
    var logisticsRemarks: String?
    var orderAutomaticReceiptTime: String?
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        orderAutomaticReceiptTime <- map["orderAutomaticReceiptTime"]
        logisticsCompany <- map["logisticsCompany"]
        logisticsNo <- map["logisticsNo"]
        logisticsRemarks <- map["logisticsRemarks"]
        operReason <- map["operReason"]
        discountMoney <- map["discountMoney"]
        isCheck <- map["isCheck"]
        activityType <- map["activityType"]
        count <- map["count"]
        customName <- map["customName"]
        imageUrl <- map["imageUrl"]
        merchantType <- map["merchantType"]
        name <- map["name"]
        orderType <- map["orderType"]
        updateBy <- map["updateBy"]
        
        qualityMoney <- map["qualityMoney"]//": 3.00,
        platformTradServiceMoney <- map["platformTradServiceMoney"]//": 3.00,
        orderUneffectiveTime <- map["orderUneffectiveTime"]
        platServiceMoneyRate <- map["platServiceMoneyRate"]
        citySubstationId <- map["citySubstationId"]
        serviceRemarks <- map["serviceRemarks"]
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        orderNo <- map["orderNo"]
        orderTime <- map["orderTime"]
        orderStatus <- map["orderStatus"]
        payStatus <- map["payStatus"]
        payType <- map["payType"]
        orderPayTime <- map["orderPayTime"]
        payMoney <- map["payMoney"]
        costMoney <- map["costMoney"]
        supplyMoney <- map["supplyMoney"]
        serviceMoney <- map["serviceMoney"]
        tel <- map["tel"]
        address <- map["address"]
        contact <- map["contact"]
        sendTerm <- map["sendTerm"]
        purchase <- map["purchase"]
        worker <- map["worker"]
        store <- map["store"]
        merchant <- map["merchant"]
        house <- map["house"]
        voucher <- map["voucher"]
        materialsList <- map["materialsList"]
        cusMaterialsList <- map["cusMaterialsList"]
        expressPhone <- map["expressPhone"]
        
        
        address <- map["address"]
        commissionMoneyAll <- map["commissionMoneyAll"]
        commissionRate <- map["commissionRate"]
        confirm <- map["confirm"]
        contact <- map["contact"]
        content <- map["content"]
        costMoney <- map["costMoney"]
        costServiceMoney <- map["costServiceMoney"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        divideAmount <- map["divideAmount"]
        houseId <- map["houseId"]
        id <- map["id"]
        isChange <- map["isChange"]
        merchantId <- map["merchantId"]
        merchantName <- map["merchantName"]
        orderNo <- map["orderNo"]
        orderStatus <- map["orderStatus"]
        orderTime <- map["orderTime"]
        payMoney <- map["payMoney"]
        payStatus <- map["payStatus"]
        premiumMoneyAll <- map["premiumMoneyAll"]
        premiumRate <- map["premiumRate"]
        purchaseId <- map["purchaseId"]
        rebateStatus <- map["rebateStatus"]
        recevingTerm <- map["recevingTerm"]
        remarks <- map["remarks"]
        serviceCharge <- map["serviceCharge"]
        serviceMoney <- map["serviceMoney"]
        storeId <- map["storeId"]
        storeName <- map["storeName"]
        supplyMoney <- map["supplyMoney"]
        tel <- map["tel"]
        updateDate <- map["updateDate"]
        workerId <- map["workerId"]
        workerName <- map["workerName"]
        timeLimit <- map["timeLimit"]
    }
}
