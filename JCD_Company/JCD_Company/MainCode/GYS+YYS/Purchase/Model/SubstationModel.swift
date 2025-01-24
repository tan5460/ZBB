//
//  SubstationModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 11.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class SubstationModel: NSObject, Mappable {
    
    var id: String?                     //分站id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var userName: String?               //用户名
    var realName: String?               //真实名
    var fzName: String?                 //分站名字
    var distId: String?                 //区
    var birthday: String?               //生日
    var sex: NSNumber?                  //性别
    var proportion: NSNumber?           //分佣系数
    var balance: NSNumber?              //总资产
    var mobile: String?                 //电话
    var idcardNo: NSNumber?             //身份证号码
    var idcardpicUrlF: String?          //身份证正面
    var idcardpicUrlB: String?          //身份证反面
    var qq: String?                     //qq
    var headUrl: String?                //头像
    var distName: String?               //区名
    var lastLoginTime: String?          //最后登录时间
    var cityName: String?               //城市名
    var intro:String?                   //介绍
    
    var city: CityModel?                //市
    
    var cityId : String?
    var companyPrice : Int?
    var delFlag : String?
    var groupName : String?
    var invoiceType : String?
    var personalPrice : Int?
    var provId : String?
    var serviceProportion : String?
    var vipCompanyPrice : Int?
    var wechat : String?
    
    
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
        userName <- map["userName"]
        realName <- map["realName"]
        fzName <- map["fzName"]
        distId <- map["distId"]
        birthday <- map["birthday"]
        sex <- map["sex"]
        proportion <- map["proportion"]
        balance <- map["balance"]
        mobile <- map["mobile"]
        idcardNo <- map["idcardNo"]
        idcardpicUrlF <- map["idcardpicUrlF"]
        idcardpicUrlB <- map["idcardpicUrlB"]
        qq <- map["qq"]
        headUrl <- map["headUrl"]
        distName <- map["distName"]
        lastLoginTime <- map["lastLoginTime"]
        cityName <- map["cityName"]
        intro <- map["intro"]
        city <- map["city"]
        cityId <- map["cityId"]
        wechat <- map["wechat"]
        vipCompanyPrice <- map["vipCompanyPrice"]
        serviceProportion <- map["serviceProportion"]
        provId <- map["provId"]
        personalPrice <- map["personalPrice"]
        invoiceType <- map["invoiceType"]
        groupName <- map["groupName"]
        delFlag <- map["delFlag"]
        companyPrice <- map["companyPrice"]
    }
}
