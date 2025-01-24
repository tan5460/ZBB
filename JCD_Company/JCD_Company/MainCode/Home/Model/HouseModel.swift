//
//  HouseModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/9.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class HouseModel: NSObject , Mappable {
    
    var isNewRecord: NSNumber?          //是否新建
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var remarks: String?                //备注、评论
    var id: String?                     //工地id
    var space: NSNumber?                //面积
    var roomNo: String?                 //房间号
    var plotName: String?               //小区名
    var lon: String?                    //经度
    var lat: String?                    //纬度
    var houseStatus: NSNumber?          //客户状态
    var address: String?                //地址
    
    var expressName: String?            //收货人
    var expressTel: String?             //收货人电话
    var expressPhone: String?           //收货人座机
    var expressAdd: String?             //收货人地址
    var shippingAddress: String?        //收货人省市区加详细地址
    var provinceName: String? // 省
    var cityName: String? // 市
    var areaName: String? // 区
    var provinceId: String? // 省
    var cityId: String? // 市
    var areaId: String? // 区
    
    var store: StoreModel?              //店铺
    var custom: CustomModel?            //客户
    var plot: PlotModel?                //小区
    
    var caseTypeName : String?
    var casesId : String?
    var createBy : String?
    var customId : String?
    var customMobile : String?
    var customName : String?
    var customSex : String?
    var customSexName : String?
    var delFlag : String?
    var designerId : String?
    var houseAreaName : String?
    var houseType : String?
    var houseTypeName : String?
    var housepicUrl : String?
    var intro : String?
    var jobType : String?
    var jobTypeName : String?
    var layout : String?
    var plotId : String?
    var pmId : String?
    var salesmanId : String?
    var status : String?
    var storeId : String?
    var storeName : String?
    var styleType : String?
    var updateBy : String?
    var workerId : String?
    var workerName : String?
    var headUrl: String?
    
    

    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        shippingAddress <- map["shippingAddress"]
        provinceName <- map["provinceName"]
        cityName <- map["cityName"]
        areaName <- map["areaName"]
        provinceId <- map["provinceId"]
        cityId <- map["cityId"]
        areaId <- map["areaId"]
        isNewRecord <- map["isNewRecord"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        remarks <- map["remarks"]
        id <- map["id"]
        space <- map["space"]
        roomNo <- map["roomNo"]
        plotName <- map["plotName"]
        lon <- map["lon"]
        lat <- map["lat"]
        houseStatus <- map["customStatus"]
        address <- map["address"]
        store <- map["store"]
        custom <- map["custom"]
        plot <- map["plot"]
        expressName <- map["expressName"]
        expressTel <- map["expressTel"]
        expressAdd <- map["expressAdd"]
        expressPhone <- map["expressPhone"]
        
        headUrl <- map["headUrl"]
        casesId <- map["casesId"]
        createBy <- map["createBy"]
        customId <- map["customId"]
        customMobile <- map["customMobile"]
        customName <- map["customName"]
        customSex <- map["customSex"]
        customSexName <- map["customSexName"]
        
        caseTypeName <- map["caseTypeName"]
        workerName <- map["workerName"]
        workerId <- map["workerId"]
        updateBy <- map["updateBy"]
        styleType <- map["styleType"]
        storeName <- map["storeName"]
        storeId <- map["storeId"]
        status <- map["status"]
        salesmanId <- map["salesmanId"]
        pmId <- map["pmId"]
        plotId <- map["plotId"]
        layout <- map["layout"]
        jobType <- map["jobType"]
        intro <- map["intro"]
        housepicUrl <- map["housepicUrl"]
        houseTypeName <- map["houseTypeName"]
        houseType <- map["houseType"]
        houseAreaName <- map["houseAreaName"]
        designerId <- map["designerId"]
        delFlag <- map["delFlag"]
    }
    
}
