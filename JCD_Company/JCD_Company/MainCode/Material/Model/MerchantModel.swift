//
//  MerchantModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/16.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import HandyJSON

class MerchantModel: NSObject, Mappable {
    
    var id: String?                     //材料商id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var merchantNo: NSNumber?           //材料商编号
    var userName: String?               //材料商名字
    var type: NSNumber?                 //类型
    var realName: String?               //真实名字
    var sex: NSNumber?                  //性别
    var mobile: String?                 //电话
    var servicePhone: String?           //客服电话
    var servicephone: String?
    var email: String?                  //邮箱
    var qq: String?                     //qq
    var headUrl: String?                //头像
    var money: NSNumber?                //钱
    var birthday: String?               //生日
    var personal: String?               //
    var address: String?                //地址
    var longitude: String?              //经度
    var latitude: String?               //纬度
    var vol: NSNumber?                  //成交量
    var evaluate: NSNumber?             //评价
    var evaluateScore: String?          //评分
    var regIp: String?                  //注册ip
    var lastLoginTime: String?          //最后登录时间
    var lastLoginIp: String?            //最后登录ip
    var isActive: NSNumber?             //是否是活动
    var idCard: String?                 //身份证
    var idcardpicUrlF: String?          //身份证正面
    var idcardpicUrlB: String?          //身份证反面
    var devicename: String?             //设备名字
    var appversion: String?             //设备版本
    var devicetype: String?             //设备类型
    var devicesystem: String?           //设备系统
    var name: String?                   //供应商名字
    var telphone: String?               //公司电话
    var companySize: NSNumber?          //公司大小
    var companyType: NSNumber?          //公司类型
    var companyCert: String?            //公司证书
    var companyCode: String?            //公司代码
    var distance: String?               //公司距离
    var brandName: String?              //品牌名字
    var brandImg: String?               //品牌图片
    var brandId: String?                //品牌id
    var brandType: String?              //品牌类型
    var isshow: NSNumber?               //是否展示
    var logoUrl: String?                //logo图标
    var isCheck: Bool?              //是否审核
    var certCode: String?               //营业执照号
    var legalRepresentative: String?    //法人代表
    var registeredCapital: String?      //注册资本
    var businessScope: String?          //经营范围
    var businessTermStart: String?    //营业起始时间
    var businessTermEnd: String?      //营业结束时间
    var substationId: String?           //分站id
    
    var provice: CityModel?             //省
    var city: CityModel?                //市
    var district: CityModel?            //区
    var category: CategoryModel?        //类别
    var substation: SubstationModel?    //运营商
    
    var cityId: String?
    var priceSellXs: String?
    var categoryaId: String?
    var relatedQualifications: String?
    var tgUserId: Any?
    var createBy: String?
    var tgUserName: String?
    var safepassword: String?
    var provId: String?
    
    var checkStatus : String!
    var citySubstation : AnyObject!
    var content : String!
    var createTime : AnyObject!
    var delFlag : AnyObject!
    var merchantId : String!
    var sortNo : AnyObject!
    var updateTime : AnyObject!
    var upperStatus : String!
    var url: String?
    
   
    var businessTermEndStr : AnyObject?
    var businessTermStartStr : AnyObject?
    var certpicUrl : String?
    var cityName : String?
    var contacts : AnyObject?
    var contactsTel : AnyObject?
    var distId : AnyObject?
    var groupName : String?
    var idcardTermEnd : AnyObject?
    var idcardTermEndStr : AnyObject?
    var idcardTermStart : AnyObject?
    var idcardTermStartStr : AnyObject?
    var invoiceType : AnyObject?
    var isComFlag : String?
    var isFz : AnyObject?
    var ishide : AnyObject?
    
    var materialsList : AnyObject?
    var merchantType : Int?
    var no : Int?
    var password : String?
    var priceShowXs : AnyObject?
    var provName : String?
    var salesAmount : AnyObject?
    var serviceType : Int?
    var size : AnyObject?
    var startDate : AnyObject?
    var storeId : AnyObject?
    var tgStatus : String?
    
    var updateBy : AnyObject?
    var wechat : AnyObject?
    var workType : AnyObject?
    var workingYears : AnyObject?
    
    
    override init() {
        super.init()
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        url <- map["url"]
        substationId <- map["substationId"]
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        merchantNo <- map["merchantNo"]
        userName <- map["userName"]
        type <- map["type"]
        realName <- map["realName"]
        sex <- map["sex"]
        mobile <- map["mobile"]
        servicePhone <- map["servicePhone"]
        servicephone <- map["servicephone"]
        email <- map["email"]
        qq <- map["qq"]
        headUrl <- map["headUrl"]
        money <- map["money"]
        birthday <- map["birthday"]
        personal <- map["personal"]
        address <- map["address"]
        longitude <- map["longitude"]
        latitude <- map["latitude"]
        vol <- map["vol"]
        evaluate <- map["evaluate"]
        evaluateScore <- map["evaluateScore"]
        regIp <- map["regIp"]
        lastLoginTime <- map["lastLoginTime"]
        lastLoginIp <- map["lastLoginIp"]
        isActive <- map["isActive"]
        category <- map["category"]
        idCard <- map["idCard"]
        idcardpicUrlF <- map["idcardpicUrlF"]
        idcardpicUrlB <- map["idcardpicUrlB"]
        devicename <- map["devicename"]
        appversion <- map["appversion"]
        devicetype <- map["devicetype"]
        devicesystem <- map["devicesystem"]
        name <- map["name"]
        telphone <- map["telphone"]
        companySize <- map["companySize"]
        companyType <- map["companyType"]
        companyCert <- map["companyCert"]
        companyCode <- map["companyCode"]
        distance <- map["distance"]
        brandName <- map["brandName"]
        brandImg <- map["brandImg"]
        brandId <- map["brandId"]
        brandType <- map["brandType"]
        isshow <- map["isshow"]
        logoUrl <- map["logoUrl"]
        isCheck <- map["isCheck"]
        certCode <- map["certCode"]
        legalRepresentative <- map["legalRepresentative"]
        registeredCapital <- map["registeredCapital"]
        businessScope <- map["businessScope"]
        businessTermStart <- map["businessTermStart"]
        businessTermEnd <- map["businessTermEnd"]
        
        provice <- map["provice"]
        city <- map["city"]
        district <- map["district"]
        substation <- map["substation"]
        
        cityId <- map["cityId"]
        priceSellXs <- map["priceSellXs"]
        categoryaId <- map["categoryaId"]
        relatedQualifications <- map["relatedQualifications"]
        tgUserId <- map["tgUserId"]
        createBy <- map["createBy"]
        tgUserName <- map["tgUserName"]
        safepassword <- map["safepassword"]
        provId <- map["provId"]
        checkStatus <- map["checkStatus"]
        citySubstation <- map["citySubstation"]
        content <- map["content"]
        createTime <- map["createTime"]
        delFlag <- map["delFlag"]
        merchantId <- map["merchantId"]
        sortNo <- map["sortNo"]
        updateTime <- map["updateTime"]
        upperStatus <- map["upperStatus"]
        
        address <- map["address"]
        appversion <- map["appversion"]
        brandName <- map["brandName"]
        businessScope <- map["businessScope"]
        businessTermEnd <- map["businessTermEnd"]
        businessTermEndStr <- map["businessTermEndStr"]
        businessTermStart <- map["businessTermStart"]
        businessTermStartStr <- map["businessTermStartStr"]
        categoryaId <- map["categoryaId"]
        certCode <- map["certCode"]
        certpicUrl <- map["certpicUrl"]
        cityId <- map["cityId"]
        cityName <- map["cityName"]
        companyType <- map["companyType"]
        contacts <- map["contacts"]
        contactsTel <- map["contactsTel"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        devicename <- map["devicename"]
        devicesystem <- map["devicesystem"]
        devicetype <- map["devicetype"]
        distId <- map["distId"]
        email <- map["email"]
        evaluate <- map["evaluate"]
        evaluateScore <- map["evaluateScore"]
        groupName <- map["groupName"]
        headUrl <- map["headUrl"]
        id <- map["id"]
        idCard <- map["idCard"]
        idcardTermEnd <- map["idcardTermEnd"]
        idcardTermEndStr <- map["idcardTermEndStr"]
        idcardTermStart <- map["idcardTermStart"]
        idcardTermStartStr <- map["idcardTermStartStr"]
        idcardpicUrlB <- map["idcardpicUrlB"]
        idcardpicUrlF <- map["idcardpicUrlF"]
        invoiceType <- map["invoiceType"]
        isActive <- map["isActive"]
        isCheck <- map["isCheck"]
        isComFlag <- map["isComFlag"]
        isFz <- map["isFz"]
        ishide <- map["ishide"]
        isshow <- map["isshow"]
        lastLoginIp <- map["lastLoginIp"]
        lastLoginTime <- map["lastLoginTime"]
        latitude <- map["latitude"]
        legalRepresentative <- map["legalRepresentative"]
        logoUrl <- map["logoUrl"]
        longitude <- map["longitude"]
        materialsList <- map["materialsList"]
        merchantNo <- map["merchantNo"]
        merchantType <- map["merchantType"]
        mobile <- map["mobile"]
        money <- map["money"]
        name <- map["name"]
        no <- map["no"]
        password <- map["password"]
        personal <- map["personal"]
        priceSellXs <- map["priceSellXs"]
        priceShowXs <- map["priceShowXs"]
        provId <- map["provId"]
        provName <- map["provName"]
        qq <- map["qq"]
        realName <- map["realName"]
        regIp <- map["regIp"]
        registeredCapital <- map["registeredCapital"]
        relatedQualifications <- map["relatedQualifications"]
        remarks <- map["remarks"]
        safepassword <- map["safepassword"]
        salesAmount <- map["salesAmount"]
        serviceType <- map["serviceType"]
        servicephone <- map["servicephone"]
        size <- map["size"]
        startDate <- map["startDate"]
        storeId <- map["storeId"]
        substationId <- map["substationId"]
        tgStatus <- map["tgStatus"]
        tgUserId <- map["tgUserId"]
        tgUserName <- map["tgUserName"]
        type <- map["type"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        userName <- map["userName"]
        vol <- map["vol"]
        wechat <- map["wechat"]
        workType <- map["workType"]
        workingYears <- map["workingYears"]
    }
    
}

struct MerchantM: HandyJSON {
    var id: String?                     //材料商id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var merchantNo: NSNumber?           //材料商编号
    var userName: String?               //材料商名字
    var type: NSNumber?                 //类型
    var realName: String?               //真实名字
    var sex: NSNumber?                  //性别
    var mobile: String?                 //电话
    var servicephone: String?           //客服电话
    var email: String?                  //邮箱
    var qq: String?                     //qq
    var headUrl: String?                //头像
    var money: NSNumber?                //钱
    var birthday: String?               //生日
    var personal: String?               //
    var address: String?                //地址
    var longitude: String?              //经度
    var latitude: String?               //纬度
    var vol: NSNumber?                  //成交量
    var evaluate: NSNumber?             //评价
    var evaluateScore: String?          //评分
    var regIp: String?                  //注册ip
    var lastLoginTime: String?          //最后登录时间
    var lastLoginIp: String?            //最后登录ip
    var isActive: NSNumber?             //是否是活动
    var idCard: String?                 //身份证
    var idcardpicUrlF: String?          //身份证正面
    var idcardpicUrlB: String?          //身份证反面
    var devicename: String?             //设备名字
    var appversion: String?             //设备版本
    var devicetype: String?             //设备类型
    var devicesystem: String?           //设备系统
    var name: String?                   //供应商名字
    var telphone: String?               //公司电话
    var companySize: NSNumber?          //公司大小
    var companyType: NSNumber?          //公司类型
    var companyCert: String?            //公司证书
    var companyCode: String?            //公司代码
    var distance: String?               //公司距离
    var brandName: String?              //品牌名字
    var brandImg: String?               //品牌图片
    var brandId: String?                //品牌id
    var brandType: String?              //品牌类型
    var isshow: NSNumber?               //是否展示
    var logoUrl: String?                //logo图标
    var isCheck: NSNumber?              //是否审核
    var certCode: String?               //营业执照号
    var legalRepresentative: String?    //法人代表
    var registeredCapital: String?      //注册资本
    var businessScope: String?          //经营范围
    var businessTermStart: NSNumber?    //营业起始时间
    var businessTermEnd: NSNumber?      //营业结束时间
    var substationId: String?           //分站id
    
    var provice: CityModel?             //省
    var city: CityModel?                //市
    var district: CityModel?            //区
    var category: CategoryModel?        //类别
    var substation: SubstationModel?    //运营商
}
