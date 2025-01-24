/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *    *    Redistributions of source code must retain the above copyright notice, this
 *        list of conditions and the following disclaimer.
 *
 *    *    Redistributions in binary form must reproduce the above copyright notice,
 *        this list of conditions and the following disclaimer in the documentation
 *        and/or other materials provided with the distribution.
 *
 *    *    Neither the name of CosmicMind nor the names of its
 *        contributors may be used to endorse or promote products derived from
 *        this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import ObjectMapper

class UserData {
    
    ///单例模式
    static let shared = UserData()
    
    var registrationId = ""
    var rwParameters: [String: String] = [String: String]()
    
    var userType: LoginType {
        get {
             return LoginType.init(rawValue: AppUtils.getUserType()) ?? .cgy
        }
    }
    
    var sjsEnter: Bool {
        get {
            return UserData.shared.workerModel?.jobType != 999 && UserData.shared.workerModel?.jobType != 4 && UserData.shared.workerModel?.costMoneyLookFlag == "1"
        }
    }
    
    var userInfoModel: BaseUserInfoModel? {
        didSet {
            workerModel = userInfoModel?.worker
            storeModel = userInfoModel?.store
            merchantModel = userInfoModel?.merchant
            if UserData.shared.userType == .yys {
                substationModel = userInfoModel?.substation
            } else {
                substationModel = userInfoModel?.citySubstation
            }
        }
    }
    var workerModel: WorkerModel?
    var storeModel: StoreModel?
    var merchantModel: MerchantModel?
    var substationModel: SubstationModel?
    var key: String = ""
    var tabbarItemIndex = 0
    
    private init(){}
    
}


class UserData1 {
    ///单例模式
    static let shared = UserData1()
    
    var tokenModel: TokenModel1?
    var isNew: Bool = false
    var isHaveMyList: Bool = false
    private init(){}
    
}

class TokenModel1: NSObject, Mappable {
    
    var accessToken: String?
    var substationName: String?
    var substationId: String?
    var userId: String?
    var userType: String?
    var ossUrl: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        accessToken <- map["accessToken"]
        substationName <- map["substationName"]
        substationId <- map["substationId"]
        userId <- map["userId"]
        userType <- map["userType"]
        ossUrl <- map["ossUrl"]
    }
}


class RegisterBaseModel: NSObject, Mappable {
    
    var registerRData: RegisterModel?
    var cityMobile: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        registerRData <- map["registerRData"]
        cityMobile <- map["cityMobile"]
    }
}








class BaseUserInfoModel: NSObject, Mappable {
    var qualityMoney: NSNumber?
    var openAcctStatus: String?
    var canUseCoupon: Int? // (0:不能使用 1:可以使用)
    var invoiceType: String?
    var worker: WorkerModel?
    var store: StoreModel?
    var merchant: MerchantModel?
    var citySubstation: SubstationModel?
    var substation: SubstationModel?
    var userName: String?
    var userInfo: SubstationUserInfoModel?
    var order: PurchaseOrderModel?
    var orderData: [PurchaseMaterialModel]?
    var orderTempData: [PurchaseMaterialModel]?
    var nodeDataList: [NodeDataListModel]?
    var yzbVip: YzbVipModel?
    var isNewUser: Bool?
    var jcdAdvertColumn: [PurchaseCenterBannerModel]?
    var register: RegisterModel?
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        register <- map["register"]
        isNewUser <- map["isNewUser"]
        canUseCoupon <- map["canUseCoupon"]
        openAcctStatus <- map["openAcctStatus"]
        jcdAdvertColumn <- map["jcdAdvertColumn"]
        qualityMoney <- map["qualityMoney"]
        invoiceType <- map["invoiceType"]
        worker <- map["worker"]
        store <- map["store"]
        merchant <- map["merchant"]
        citySubstation <- map["citySubstation"]
        substation <- map["substation"]
        userName <- map["userName"]
        order <- map["order"]
        orderData <- map["orderData"]
        orderTempData <- map["orderTempData"]
        userInfo <- map["userInfo"]
        nodeDataList <- map["nodeDataList"]
        yzbVip <- map["yzbVip"]
    }

}


//MARK: - 采购我的页面广告banner model
class PurchaseCenterBannerModel : NSObject, Mappable{
    
    var advertImg : String?
    var advertLink : String?
    var advertLoc : String?
    var belongUserId : String?
    var createBy : String?
    var createTime : String?
    var id : String?
    var remarks : AnyObject?
    var sortNo : AnyObject?
    var title : String?
    var updateBy : AnyObject?
    var updateTime : AnyObject?
    
    required init?(map: Map){}
    private override init(){
        super.init()
    }
    
    func mapping(map: Map)
    {
        advertImg <- map["advertImg"]
        advertLink <- map["advertLink"]
        advertLoc <- map["advertLoc"]
        belongUserId <- map["belongUserId"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        id <- map["id"]
        remarks <- map["remarks"]
        sortNo <- map["sortNo"]
        title <- map["title"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        
    }
}

class NodeDataListModel: NSObject, Mappable {
    var createBy : String?
    var createDate : String?
    var delFlag : String?
    var fileUrls : String?
    var id : String?
    var nodeMoney : Int?
    var nodeName : String?
    var nodeType : String?
    var orderId : String?
    var percent : Int?
    var remarks : String?
    var status : Int?  // status 状态(1待完成(等待上传图片) 2待验收(已上传图片，待验收)  3已完成   4拒绝)
    var updateBy : String?
    var updateDate : String?
    
    class func newInstance(map: Map) -> Mappable?{
        return NodeDataListModel()
    }
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        fileUrls <- map["fileUrls"]
        id <- map["id"]
        nodeMoney <- map["nodeMoney"]
        nodeName <- map["nodeName"]
        nodeType <- map["nodeType"]
        orderId <- map["orderId"]
        percent <- map["percent"]
        remarks <- map["remarks"]
        status <- map["status"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        
    }
}


class SubstationUserInfoModel: NSObject, Mappable {
    
    var yzbUser: YZBUserInfoModel?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        yzbUser <- map["yzbUser"]
    }

}


class YZBUserInfoModel: NSObject, Mappable {
    
    var createDate : String?
    var delFlag : String?
    var deviceId : String?
    var id : String?
    var invoiceType : String?
    var loginName : String?
    var mobile : String?
    var password : String?
    var userName : String?
    var updateDate : String?
    var userType : String?
    
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        deviceId <- map["deviceId"]
        id <- map["id"]
        invoiceType <- map["invoiceType"]
        loginName <- map["loginName"]
        userName <- map["userName"]
        mobile <- map["mobile"]
        password <- map["password"]
        updateDate <- map["updateDate"]
        userType <- map["userType"]
    }

}


class YzbVipModel: NSObject, Mappable {
    
    var commonCount : Int?
    var count : Int?
    var id : String?
    var isGive : String?
    var isValid : Int?
    var levelId : String?
    var levelName : String?
    var memberFee : String?
    var storeId : String?
    var validEndDate : String?
    var validStartDate : String?
    var vipType : Int?  // 0: 体验会员 '1:普通 2:中级 3:vip 4:白金 5:钻石 6:金钻 7:至尊',

    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        commonCount <- map["commonCount"]
        count <- map["count"]
        id <- map["id"]
        isGive <- map["isGive"]
        isValid <- map["isValid"]
        levelId <- map["levelId"]
        levelName <- map["levelName"]
        memberFee <- map["memberFee"]
        storeId <- map["storeId"]
        validEndDate <- map["validEndDate"]
        validStartDate <- map["validStartDate"]
        vipType <- map["vipType"]

    }

}

