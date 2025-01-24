//
//  HouseCaseModel.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/5.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class HouseCaseModel: NSObject , Mappable {

    var caseNo: String?                 //案例编号
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var caseRemarks: String?            //案例标签
    var caseStyle: String?              //风格
    var casePrice: CasePriceModel?            //装修报价
    var caseStyleName: String?          //风格名称
    var communityName: String?          //小区名称
    var communityId: String?            //小区ID
    var createBy: String?
    var createTime: String?
    var delFlag: String?
    var houseArea: String?              //面积
    var houseAreaName: String?          //面积名称
    
    var houseType: String?              //户型
    var houseTypeName: String?          //户型名称
    var id: String?
    var isNewRecord: String?
    var mainImgUrl: String?             //案例主图
    var mainImgUrl1: String?   {    //案例主图
        get {
            return mainImgUrl?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
        
    }
    var remarks: String?
    var showFlag: String?               //是否显示
    var updateBy: String?
    var updateTime: String?
    var userId: String?                 //家装公司id
    var userName: String?
    var url: String?                    //链接
    var village: PlotModel?             //地址
    var type: String?
    
    
    
    
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        userName <- map["userName"]
        type <- map["type"]
        casePrice <- map["casePrice"]
        caseNo <- map["caseNo"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        caseRemarks <- map["caseRemarks"]
        caseStyle <- map["caseStyle"]
        caseStyleName <- map["caseStyleName"]
        communityName <- map["communityName"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        delFlag <- map["delFlag"]
        houseArea <- map["houseArea"]
        houseAreaName <- map["houseAreaName"]
        houseType <- map["houseType"]
        houseTypeName <- map["houseTypeName"]
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        mainImgUrl <- map["mainImgUrl"]
        showFlag <- map["showFlag"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        userId <- map["userId"]
        url <- map["url"]
        village <- map["village"]
        communityId <- map["communityId"]
    }
}
