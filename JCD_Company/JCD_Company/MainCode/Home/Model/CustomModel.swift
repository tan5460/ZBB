//
//  CustomModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/9.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class CustomModel: NSObject, Mappable {
    
    var isNewRecord: NSNumber?          //是否新建
    var id: String?                     //客户id
    var userName: String?               //用户名
    var realName: String?               //真实名字
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var tel: String?                    //电话
    var sex: NSNumber?                  //性别
    var qq: String?                     //qq
    var email: String?                  //邮箱
    var headUrl: String?                //头像
    var money: NSNumber?                //钱
    var birthday: String?               //生日
    var intro: String?                  //简介
    var address: String?                //地址
    var lon: String?                    //经度
    var lat: String?                    //纬度
    var dealCount: NSNumber?            //交易笔数
    var evalCount: NSNumber?            //评价次数
    var evalScore: NSNumber?            //评分
    var lastlogintime: String?          //最后登录时间
    var store: StoreModel?              //店铺
    
    var prov: CityModel?                //省
    var city: CityModel?                //市
    var dist: CityModel?                //区
    
    //自定义添加
    var intoDate: String?               //入行时间
    
    var createBy : String?
    var delFlag : String?
    var house : AnyObject?
    var mobile : String?
    var plot : AnyObject?
    var storeId : String?
    var storeName : String?
    var updateBy : AnyObject?
    var workerId : String?
    var workerRealName : String?
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        isNewRecord <- map["isNewRecord"]
        id <- map["id"]
        userName <- map["userName"]
        realName <- map["realName"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        tel <- map["mobile"]
        sex <- map["sex"]
        qq <- map["qq"]
        email <- map["email"]
        headUrl <- map["headUrl"]
        money <- map["money"]
        birthday <- map["birthday"]
        intro <- map["intro"]
        address <- map["address"]
        lon <- map["lon"]
        lat <- map["lat"]
        prov <- map["prov"]
        city <- map["city"]
        dist <- map["dist"]
        dealCount <- map["dealCount"]
        evalCount <- map["evalCount"]
        evalScore <- map["evalScore"]
        lastlogintime <- map["lastlogintime"]
        store <- map["store"]
        intoDate <- map["intoDate"]
        
        createBy <- map["createBy"]
        delFlag <- map["delFlag"]
        house <- map["house"]
        mobile <- map["mobile"]
        plot <- map["plot"]
        storeId <- map["storeId"]
        storeName <- map["storeName"]
        updateBy <- map["updateBy"]
        workerId <- map["workerId"]
        workerRealName <- map["workerRealName"]
        
    }
    
    
}
