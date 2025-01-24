//
//  StoreModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/8.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class StoreModel: NSObject, Mappable {
    var invitationCode: String?         //6位数随机邀请码
    var isNewRecord: NSNumber?          //是否新建
    var id: String?                     //店铺id
    var name: String?                   //店铺名字
    var mobile: String?                 //店铺手机号码
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var company: String?                //公司
    var intro: String?                  //简介
    var setuptime: String?              //建立时间
    var size: String?                   //大小
    var address: String?                //地址
    var lon: String?                    //经度
    var lat: String?                    //纬度
    var tel1: String?                   //电话1
    var tel2: String?                   //电话2
    var tel3: String?                   //电话3
    var licenseUrl: String?             //许可证地址
    var licenseNo: String?              //许可证号
    var headUrl: String?                //头像
    var backgroundUrl: String?          //背景墙
    var no: NSNumber?                    //编号
    var loginName: String?               //登录用户名
    var citySubstation: String?
    
    var prov: CityModel?                //省
    var city: CityModel?                //市
    var dist: CityModel?                //区
    
    var cityId : String?
    var delFlag : String?
    var distId : String?
    var provId : String?
    var type : Int?
    var upgradeStatus : Int?
    var vrAccountCount : Int?
    
    override init() {
        super.init()
        
        prov = CityModel()
        city = CityModel()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        invitationCode <- map["invitationCode"]
        cityId <- map["cityId"]
        distId <- map["distId"]
        delFlag <- map["delFlag"]
        provId <- map["provId"]
        type <- map["type"]
        upgradeStatus <- map["upgradeStatus"]
        vrAccountCount <- map["vrAccountCount"]
        citySubstation <- map["citySubstation"]
        isNewRecord <- map["isNewRecord"]
        id <- map["id"]
        name <- map["name"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        company <- map["company"]
        intro <- map["intro"]
        setuptime <- map["setuptime"]
        size <- map["size"]
        address <- map["address"]
        lon <- map["lon"]
        lat <- map["lat"]
        prov <- map["prov"]
        city <- map["city"]
        dist <- map["dist"]
        tel1 <- map["tel1"]
        tel2 <- map["tel2"]
        tel3 <- map["tel3"]
        licenseUrl <- map["licenseUrl"]
        licenseNo <- map["licenseNo"]
        headUrl <- map["headUrl"]
        backgroundUrl <- map["backgroundUrl"]
        no <- map["no"]
        loginName <- map["loginName"]
    }
    
    
}
