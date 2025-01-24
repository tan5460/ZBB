//
//  RegisModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/3/15.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class RegisterModel: NSObject, Mappable {
    
    var id: String?                     //员工id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String?                //评论、备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var userName: String?               //登录名
    var comName: String?                //公司名字
    var comAddress: String?             //地址
    var contacts: String?               //联系人
    var idcardNo: String?               //身份证
    var licenseNo: String?              //营业执照号
    var isCheck: NSNumber?              //审核状态 // 审核状态(0:未提交审核 1：已通过 2：未通过 3: 审核中)
    var mobile: String?                 //电话
    var output: String?                 //年产值
    var setUpTime: String?              //从业时长
    var size: String?                   //规模
    var type: NSNumber?                 //类型
    var licenseUrl: String?             //营业执照
    var storeLogo: String?                //logo
    var idcardpicUrlF: String?          //身份证正面
    var idcardpicUrlB: String?          //身份证反面
    var idcardpicUrlFGR: String?          //身份证正面
    var idcardpicUrlBGR: String?          //身份证反面
    var idcardpicUrlFQY: String?          //身份证正面
    var idcardpicUrlBQY: String?          //身份证反面
    var citySubstation: String?
    var province: CityModel?            //省
    var city: CityModel?                //市
    var district: CityModel?            //区
    
    var cityId : String?
    var delFlag : String?
    var distId : String?
    var graduationSchool : String?
    var icBeginTime : String?
    var icEndTime : String?
    var password : String?
    var payImg : String?
    var practitionersTime : String?
    var provId : String?
    var refereePhone : String?
    var setuptime : String?
    var storeType : Int?
    var updateBy : String?
    var createBy : String?
    var workCom : String?
    
    var address : String?
    var appversion : String?
    var brandName : String?
    var businessScope : String?
    var businessTermEnd : String?
    var businessTermStart : String?
    var categoryaId : String?
    var certCode : String?
    var certpicUrl : String?
    var companyType : String?
    var consultNum : Int?
    var contactsTel : String?
    var designStyle : String?
    var designType : String?
    var devicename : String?
    var devicesystem : String?
    var devicetype : String?
    var email : String?
    var evaluate : String?
    var evaluateScore : String?
    var headUrl : String?
    var idCard : String?
    var idcardTermEnd : String?
    var idcardTermStart : String?
    var individualLabels : String?
    var isActive : Int?
    var isComFlag : String?
    var ishide : String?
    var isshow : Int?
    var lastLoginIp : String?
    var lastLoginTime : String?
    var latitude : String?
    var legalRepresentative : String?
    var logoUrl : String?
    var longitude : String?
    var merchantNo : String?
    var merchantType : Int?
    var money : String?
    var name : String?
    var no : Int?
    var personal : String?
    var priceSellXs : String?
    var priceShowXs : String?
    var qq : String?
    var realName : String?
    var regIp : String?
    var registeredCapital : String?
    var relatedQualifications : String?
    var safepassword : String?
    var salesAmount : String?
    var serviceType : Int?
    var servicephone : String?
    var sex : Int?
    var startDate : String?
    var storeId : String?
    var substationId : String?
    var tgStatus : String?
    var tgUserId : String?
    var tgUserName : String?
    var vol : String?
    var wechat : String?
    var workType : String?
    var workingYears : Int?
    var workingYear: String?
    var jobType: Int?
    var openId: String?
    var zfbOpenId : String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        zfbOpenId <- map["zfbOpenId"]
        id <- map["id"]
        workingYear <- map["workingYear"]
        jobType <- map["jobType"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        userName <- map["userName"]
        comName <- map["comName"]
        comAddress <- map["comAddress"]
        contacts <- map["contacts"]
        idcardNo <- map["idcardNo"]
        licenseNo <- map["licenseNo"]
        isCheck <- map["isCheck"]
        mobile <- map["mobile"]
        output <- map["output"]
        setUpTime <- map["setUpTime"]
        size <- map["size"]
        type <- map["type"]
        licenseUrl <- map["licenseUrl"]
        idcardpicUrlF <- map["idcardpicUrlF"]
        idcardpicUrlB <- map["idcardpicUrlB"]
        province <- map["province"]
        city <- map["city"]
        district <- map["district"]
        citySubstation <- map["citySubstation"]
        cityId <- map["cityId"]
        citySubstation <- map["citySubstation"]
        comAddress <- map["comAddress"]
        comName <- map["comName"]
        contacts <- map["contacts"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        distId <- map["distId"]
        graduationSchool <- map["graduationSchool"]
        icBeginTime <- map["icBeginTime"]
        icEndTime <- map["icEndTime"]
        id <- map["id"]
        idcardNo <- map["idcardNo"]
        idcardpicUrlB <- map["idcardpicUrlB"]
        idcardpicUrlF <- map["idcardpicUrlF"]
        isCheck <- map["isCheck"]
        licenseNo <- map["licenseNo"]
        licenseUrl <- map["licenseUrl"]
        mobile <- map["mobile"]
        output <- map["output"]
        password <- map["password"]
        payImg <- map["payImg"]
        practitionersTime <- map["practitionersTime"]
        provId <- map["provId"]
        refereePhone <- map["refereePhone"]
        remarks <- map["remarks"]
        setuptime <- map["setuptime"]
        size <- map["size"]
        storeLogo <- map["storeLogo"]
        storeType <- map["storeType"]
        type <- map["type"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        userName <- map["userName"]
        workCom <- map["workCom"]
        address <- map["address"]
        appversion <- map["appversion"]
        brandName <- map["brandName"]
        businessScope <- map["businessScope"]
        businessTermEnd <- map["businessTermEnd"]
        businessTermStart <- map["businessTermStart"]
        categoryaId <- map["categoryaId"]
        certCode <- map["certCode"]
        certpicUrl <- map["certpicUrl"]
        cityId <- map["cityId"]
        companyType <- map["companyType"]
        consultNum <- map["consultNum"]
        contacts <- map["contacts"]
        contactsTel <- map["contactsTel"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        designStyle <- map["designStyle"]
        designType <- map["designType"]
        devicename <- map["devicename"]
        devicesystem <- map["devicesystem"]
        devicetype <- map["devicetype"]
        distId <- map["distId"]
        email <- map["email"]
        evaluate <- map["evaluate"]
        evaluateScore <- map["evaluateScore"]
        headUrl <- map["headUrl"]
        id <- map["id"]
        idCard <- map["idCard"]
        idcardTermEnd <- map["idcardTermEnd"]
        idcardTermStart <- map["idcardTermStart"]
        idcardpicUrlB <- map["idcardpicUrlB"]
        idcardpicUrlF <- map["idcardpicUrlF"]
        individualLabels <- map["individualLabels"]
        isActive <- map["isActive"]
        isCheck <- map["isCheck"]
        isComFlag <- map["isComFlag"]
        ishide <- map["ishide"]
        isshow <- map["isshow"]
        lastLoginIp <- map["lastLoginIp"]
        lastLoginTime <- map["lastLoginTime"]
        latitude <- map["latitude"]
        legalRepresentative <- map["legalRepresentative"]
        logoUrl <- map["logoUrl"]
        longitude <- map["longitude"]
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
        sex <- map["sex"]
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
