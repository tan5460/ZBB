//
//  WorkTeamModel.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/10.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import HandyJSON

struct WorkDataModel: HandyJSON {
    var team: [WorkTeamModel]?
    var cases: [WorkCaseModel]?
}

struct WorkTeamModel: HandyJSON {
    var address : String?
    var appversion : String?
    var brandName : String?
    var businessScope : String?
    var businessTermEnd : String?
    var businessTermEndStr : String?
    var businessTermStart : String?
    var businessTermStartStr : String?
    var caseList : [WorkCaseModel]?
    var caseNum : Int?
    var categoryaId : String?
    var certCode : String?
    var certpicUrl : String?
    var cityId : String?
    var cityName : String?
    var companyType : Int?
    var contacts : String?
    var contactsTel : String?
    var createBy : String?
    var createDate : String?
    var delFlag : String?
    var designStyle : String?
    var designType : String?
    var devicename : String?
    var devicesystem : String?
    var devicetype : String?
    var distId : String?
    var email : String?
    var evaluate : String?
    var evaluateScore : String?
    var groupName : String?
    var headUrl : String?
    var headImg: String?
    var id : String?
    var idCard : String?
    var idcardTermEnd : String?
    var idcardTermEndStr : String?
    var idcardTermStart : String?
    var idcardTermStartStr : String?
    var idcardpicUrlB : String?
    var idcardpicUrlF : String?
    var individualLabels : String?
    var invoiceType : String?
    var isActive : Int?
    var isCheck : Int?
    var isComFlag : String?
    var isFz : String?
    var ishide : String?
    var isshow : Int?
    var lastLoginIp : String?
    var lastLoginTime : String?
    var latitude : String?
    var legalRepresentative : String?
    var logoUrl : String?
    var longitude : String?
    var materialsList : String?
    var merchantNo : String?
    var merchantType : Int?
    var mobile : String?
    var money : String?
    var name : String?
    var no : Int?
    var password : String?
    var personal : String?
    var priceSellXs : String?
    var priceShowXs : String?
    var provId : String?
    var provName : String?
    var qq : String?
    var realName : String?
    var regIp : String?
    var registeredCapital : String?
    var relatedQualifications : String?
    var remarks : String?
    var safepassword : String?
    var salesAmount : String?
    var serviceType : String?
    var serviceTypes : String?
    var servicephone : String?
    var size : String?
    var sortType : String?
    var startDate : String?
    var storeId : String?
    var substationId : String?
    var tgStatus : String?
    var tgUserId : String?
    var tgUserName : String?
    var type : String?
    var updateBy : String?
    var updateDate : String?
    var userName : String?
    var vol : String?
    var wechat : String?
    var workType : String?
    var workerData : [WorkerDataModel]?
    var workerTypeNames : [String]?
    var workingYears : Int?
}

struct WorkCaseModel: HandyJSON {
    var areaId : String?
    var caseNo : String?
    var caseRemarks : String?
    var caseStyle : String?
    var cityId : String?
    var citySubstation : String?
    var communityId : String?
    var communityName : String?
    var createTime : String?
    var houseArea : String?
    var houseType : String?
    var id : String?
    var latitude : String?
    var longitude : String?
    var mainImgUrl : String?
    var provinceId : String?
    var showFlag : String?
    var type : String?
    var updateTime : String?
    var userId : String?
    
    var caseStyleName : String?
    var headUrl : String?
    var houseAreaName : String?
    var houseTypeName : String?
    var name : String?
    var url : String?
    var userName : String?
}


struct WorkerDataModel: HandyJSON {
    var cityId : String?
    var createBy : String?
    var createDate : String?
    var delFlag : String?
    var headImg : String?
    var id : String?
    var merchantId : String?
    var merchantName : String?
    var name : String?
    var provId : String?
    var remarks : String?
    var substationId : String?
    var updateBy : String?
    var updateDate : String?
    var workerType : String?
    var workerTypeName : String?
}

struct WorkTeamDetailModel: HandyJSON {
    var cases : [WorkCaseModel]?
    var info : WorkTeamModel?
    var materials : [MaterialsM]?
    var workerData : [WorkerDataModel]?
    var workerNum : Int?
}


