//
//  CouponModel.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/25.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class CouponModel: NSObject, Mappable {
    var count : Int?
    var couponId : String?
    var createBy : String?
    var createDate : String?
    var delFlag : String?
    var denomination : NSNumber? // 面额
    var distributionMethod : Int?
    var id : String? // 优惠券id
    var invalidDate : String?
    var levelId : String? // 会员等级id
    var name : String? // 代金券名称
    var no : String?
    var objId : String? // 二级分类id或品牌商id，可使用范围是2或3时必传
    var objName : String? // 二级分类名称或品牌商名称，可使用范围是2或3时必传
    var orderNo : String?
    var remarks : String?
    var storeId : String?
    var type : String? // 代金券类型 1: 全网券， 2: 天网券， 3: 地网券
    var updateBy : String?
    var updateDate : String?
    var usableRange : String? // 可使用范围： 1 ： 全场通用， 2: 指定分类 3: 指定商家
    var useDate : String?
    var useStatus : String? // 状态：代金券列表页面为1: 未使用 2: 已使用 3: 已失效 下单页面为1: 可用 2: 不可用
    var userName : String?
    var useThreshold: String?
    
    var isCheckBox: Bool? = false
    var isEnable: Bool? = true
    var isTakeEffect: Int? // 是否生效(0:未生效 1:已生效)
    var isTJ: Bool = false // 是否推荐优惠券，默认不是
    var withAmount: NSNumber? // 优惠券
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        withAmount <- map["withAmount"]
        useThreshold <- map["useThreshold"]
        isTakeEffect <- map["isTakeEffect"]
        isTJ <- map["isTJ"]
        isCheckBox <- map["isCheckBox"]
        isEnable <- map["isEnable"]
        count <- map["count"]
        couponId <- map["couponId"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        denomination <- map["denomination"]
        distributionMethod <- map["distributionMethod"]
        id <- map["id"]
        invalidDate <- map["invalidDate"]
        levelId <- map["levelId"]
        name <- map["name"]
        no <- map["no"]
        objId <- map["objId"]
        objName <- map["objName"]
        orderNo <- map["orderNo"]
        remarks <- map["remarks"]
        storeId <- map["storeId"]
        type <- map["type"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        usableRange <- map["usableRange"]
        useDate <- map["useDate"]
        useStatus <- map["useStatus"]
        userName <- map["userName"]
    }
    
    
}
