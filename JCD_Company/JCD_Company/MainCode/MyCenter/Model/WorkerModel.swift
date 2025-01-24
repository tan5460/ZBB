//
//  SalesmanModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/9.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class WorkerModel: NSObject, Mappable {
    
    var id: String?                     //员工id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var userName: String?               //名字
    var password: String?               //密码
    var realName: String?               //真实名字
    var growth: NSNumber?               //会员成长值
    var integration: NSNumber?          //会员积分
    var bonusPoint: NSNumber?           //邀请奖励积分
    var jobType: NSNumber?              //职务
    var sex: NSNumber?                  //性别
    var mobile: String?                 //电话
    var cityMobile: String?             //当地运营商电话
    var qq: String?                     //qq
    var birthday: String?               //生日
    var headUrl: String?                //头像
    var intro: String?                  //简介
    var dealCount: NSNumber?            //交易笔数
    var evalCount: NSNumber?            //评价次数
    var evalScore: NSNumber?            //评分
    var intoDate: String?               //入行时间
    var idcardNo: String?               //身份证号码
    var idcardpicUrlF: String?          //身份证正面
    var idcardpicUrlB: String?          //身份证反面
    var address: String?                //地址
    var longitude: String?              //经度
    var latitude: String?               //纬度
    var isCheck: NSNumber?              //账号类型 1、已通过 2、未通过 3、待审核 4、未完成
    var costMoneyLookFlag: String?      //设计师是否显示主材商城 0不可 1可
    var appUid: String?                 //vr
    
    var store: StoreModel?              //店铺
    var yzbRegister: RegisterModel?     //注册信息
    var yzbWorkerLv: WorkerLvModel?     //员工等级
    
    var substation: SubstationModel?    //运营商
    
    var voucher:VoucherModel?
    
    var storeName: String?
    
    override init() {
        super.init()
        
        store = StoreModel()
        yzbRegister = RegisterModel()
        yzbWorkerLv = WorkerLvModel()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        store <- map["store"]
        userName <- map["userName"]
        realName <- map["realName"]
        growth <- map["growth"]
        integration <- map["integration"]
        bonusPoint <- map["bonusPoint"]
        jobType <- map["jobType"]
        mobile <- map["mobile"]
        cityMobile <- map["cityMobile"]
        sex <- map["sex"]
        qq <- map["qq"]
        birthday <- map["birthday"]
        headUrl <- map["headUrl"]
        intro <- map["intro"]
        dealCount <- map["dealCount"]
        evalCount <- map["evalCount"]
        evalScore <- map["evalScore"]
        intoDate <- map["intoDate"]
        idcardNo <- map["idcardNo"]
        idcardpicUrlF <- map["idcardpicUrlF"]
        idcardpicUrlB <- map["idcardpicUrlB"]
        address <- map["address"]
        longitude <- map["longitude"]
        latitude <- map["latitude"]
        isCheck <- map["isCheck"]
        yzbRegister <- map["yzbRegister"]
        yzbWorkerLv <- map["yzbWorkerLv"]
        substation <- map["susSubstation"]
        voucher <- map["voucher"]
        costMoneyLookFlag <- map["costMoneyLookFlag"]
        appUid <- map["appUid"]
        storeName <- map["storeName"]
    }
}
class VoucherModel: NSObject, Mappable {
    
    var id: String?
    var remarks: String?
    
    override init() {
        super.init()
        
       
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        remarks <- map["remarks"]

    }
}
