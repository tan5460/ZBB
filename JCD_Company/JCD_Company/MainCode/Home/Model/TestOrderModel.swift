//
//  TestOrderModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/9/12.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class TestOrderModel: NSObject, Mappable {
    
    var id: String?                     //预购订单id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var materialslist: String?          //主材数组
    var selArrPackageId: String?        //主材包数组
    var selArrMaterialsId: String?      //主材包选主材数组
    var selCurArrRoom: String?          //主材房间类型数组
    var selCurArrCategory: String?      //主材包分类数组
    var selCurArrName: String?          //主材名数组
    var selCurArrprice: String?         //主材价格数组
    var selCurArrPic: String?           //主材图片数组
    var selCurArrUnit: String?          //主材单位数组
    var selArrPriceAdd: String?         //主材加减价数组
    var selArrMaterialsCount: String?   //主材选购数量数组
    var selArrMaterialsRemarks: String? //主材备注数组
    
    var arrServicesId: String?          //施工id
    var arrServicesCount: String?       //施工数量
    var arrServicesCusPrice: String?    //施工自定义价
    var arrServicesIntro: String?       //施工简介
    var arrServicesName: String?        //施工名
    var arrServicesRoomType: String?    //房间类型
    var arrServicesType: String?        //施工类型
    var arrServicesUnitType: String?    //施工单位
    
    var worker: WorkerModel?            //员工
    var store: StoreModel?              //店铺
    var custom: CustomModel?            //客户
    var house: HouseModel?              //工地
    var plus: PlusModel?                //套餐
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        materialslist <- map["materialslist"]
        selArrPackageId <- map["selArrPackageId"]
        selArrMaterialsId <- map["selArrMaterialsId"]
        selCurArrRoom <- map["selCurArrRoom"]
        selCurArrCategory <- map["selCurArrCategory"]
        selCurArrName <- map["selCurArrName"]
        selCurArrprice <- map["selCurArrprice"]
        selCurArrPic <- map["selCurArrPic"]
        selCurArrUnit <- map["selCurArrUnit"]
        selArrPriceAdd <- map["selArrPriceAdd"]
        selArrMaterialsCount <- map["selArrMaterialsCount"]
        selArrMaterialsRemarks <- map["selArrMaterialsRemarks"]
        
        arrServicesId <- map["arrServicesId"]
        arrServicesCount <- map["arrServicesCount"]
        arrServicesCusPrice <- map["arrServicesCusPrice"]
        arrServicesIntro <- map["arrServicesIntro"]
        arrServicesName <- map["arrServicesName"]
        arrServicesRoomType <- map["arrServicesRoomType"]
        arrServicesType <- map["arrServicesType"]
        arrServicesUnitType <- map["arrServicesUnitType"]
        
        worker <- map["worker"]
        store <- map["store"]
        custom <- map["custom"]
        house <- map["house"]
        plus <- map["plus"]
    }
}
