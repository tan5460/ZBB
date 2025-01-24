//
//  MaterialsModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/16.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class MaterialsModel: NSObject, Mappable {
    
    var id: String?                     //全部主材id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String = "无"               //备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //主材名
    var no: String?                     //主材编号
    var imageUrl: String?               //主图
    var transformImageURL: String? {    //对主图片中的异常字符进行转化
        get {
            guard let urlStr = imageUrl else { return nil }
            return urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
    }
    var images: String?                 //图片数组
    var status: NSNumber?               //上下架状态
    var intro: String?                  //主材简介
    var keywords: String?               //关键字数组
    var unitType: NSNumber?             //单位类型
    var unitTypeName: String?           //单位
    var applicableArea: String?         //适用面积
    var count: NSNumber?                //数量
    var weight: String?                 //重量
    var price: NSNumber?                //秒杀价
    var price1: NSNumber? {
        get {
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                return priceSellMin
            } else {
                return price
            }
        }
    }
    var priceShow: NSNumber?            //市场价
    var priceShowMin: NSNumber?            //市场价最小值
    var priceShowMax: NSNumber?            //市场价最大值
    var priceCustom: NSNumber?          //自定义价格(销售价)
    var cusPrice: NSNumber?             //差价
    var priceSell: NSNumber?
    var priceCost: NSNumber?            //成本价
    var beforePriceCost: NSNumber?      //片的成本价
    var priceSupply: NSNumber?          //进货价
    var priceSupply1: NSNumber? {
        get {
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                return priceSellMin
            } else {
                return priceSupply
            }
        }
    }
    var beforeUnitType: NSNumber?       //单位：片
    var beforePriceSupply: NSNumber?    //片的价格
    var ishide: NSNumber?               //是否隐藏
    var materialSizetype: NSNumber?     //规格
    var url: String?                    //详情介绍网址
    var content: String?                //详情内容
    var beginPriceCustom: String?       //价格范围前
    var endPriceCustom: String?         //价格范围后
    var sort: NSNumber?                 //排序号
    var isCheck: Int?            //是否审核通过
    var isCheckBtn: Bool = false   // 是否选中
    var zdyprice: NSNumber?             //自定义销售价
    var brandName: String?      //品牌名
    var merchantId: String?             //品牌id
    var type: NSNumber?                 //类型 1.平台主材，2.自建主材，3.临时主材
    var buyCount: NSNumber = 100        //购买数量
    var buyRemarks: String?       //购买数量
    var isOneSell: NSNumber?            //是否可单卖 1:单卖
    var capacity: NSNumber?             //几片每箱
    
    var recevingTerm: String?           //发货期限
    var installationFlag: String?       //是否提供安装服务 1不提供 2提供
    var upstairsFlag: String?           //是否上楼 1不 2上
    var allDeliverFlag: String?         //是否整箱发货 1不 2是
    var logisticsFlag: String?          //是否包含物流费 1否 2是
    var exPackagingSize: String?        //规格
    var exPackagingHigh: String?        //高
    var exPackagingLong: String?//" :   //长
    var exPackagingWide: String?        //宽
    var customizeFlag: String?          //自定义规格标记 1否 2是
    var merchant: MerchantModel?        //材料商
    var companymaterials: CompanyMaterialsModel?    //公司材料
    var categorya: CategoryModel?       //一级分类
    var categoryb: CategoryModel?       //二级分类
    var categoryc: CategoryModel?       //三级分类
    var categoryd: CategoryModel?       //四级分类
    var categorys: CategoryModel?       //订单储存的分类
    var yzbSpecification: SpecificationModel?       //主材规格
    
    var yzbMerchant: MerchantModel?        //供应商
    var materialsType: NSNumber?  // 产品： 1  服务： 2
    //自定义 备注是否展开
    var remarkIsOpen = false
    var areaRemark = ""                  //使用区域
    
    var priceSupplyMin: NSNumber?
    var priceSupplyMin1: NSNumber? {
        get {
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                return priceSellMin
            } else {
                return priceSupplyMin
            }
        }
    }
    var isTop: String?
    var createBy: String?
    var categorycId: String?
    var priceSellMax: NSNumber?
    var isQc: String?
    var cityId: String?
    var priceSellMin: NSNumber?
    var isTj: String?
    var attrdataId: String?
    var materialsSkuList: [MaterialsSkuListModel]?
    var marketingMaterialsSkuList: [MaterialsSkuListModel]?
    var priceSupplyMax: NSNumber?
    var priceSupplyMax1: NSNumber? {
        get {
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                return priceSellMax
            } else {
                return priceSupplyMax
            }
        }
    }
    var sortNum: Int?
    var proArea: String?
    var specification: String?
    var categorybId: String?
    var categoryaId: String?
    var categorydId: String?
    var qrCode: String?
    var classificationId: String?
    var skuFlag: NSNumber?
    var updateBy: String?
    var delFlag: String?
    var upperFlag: String?
    var code: Int?
    var topFlag: String?
    var isNew: String?
    var sortNo: Int?
    
    var categoryaName: String?
    var categorybName: String?
    var categorycName: String?
    var categorydName: String?
    
    
    var worker: WorkerModel?            //员工
    var store: StoreModel?              //店铺
    var materials: MaterialsModel?      //主材
    var service: ServiceModel?          //施工
    
    
    var alertNum : Int?
    var image : String?
    var isDefault : AnyObject?
    var materialsId : String?
    var activityId: String?
    var merchantName : String?
    var brandImg: String?
    var saleNum : Int?
    var sellNum: Int?
    var skuAttr : String?
    var skuAttr1: String? {
        get {
            let arr = skuAttr?.getArrayByJsonString()
            var str = ""
            for dic in (arr ?? [[String: Any]]()) {
                let dic1 = dic as! [String: Any]
                let value =  dic1["skuValue"] as? String
                str.append("\(value ?? "") ")
            }
            return str
        }
    }
    var skuCode : String?
    var skuName : String?
    var stockNum : Int?
    
    var categoryAName : String?
    var materialsCount : NSNumber?
    var materialsImageUrl : String?
    var materialsName : String?
    var materialsPriceCustom : String?
    var materialsPriceSupply: String?
    var materialsPriceSupply1: String? {
        get {
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                return materialsPriceCustom
            } else {
                return materialsPriceSupply
            }
        }
    }
    var materialsPriceShow : String?
    var materialsSizeTypeName : String?
    var materialsUnitType : String?
    var materialsUnitTypeName : String?
    var orderDataId : String?
    var orderId : String?
    var skuId : String?
    /// 品牌馆
    var attrClassification : HoBrandModel?
    var attrDataList : AnyObject?
    var brandId : String?
    var groupName : AnyObject?
    
    var isFz : AnyObject?
    var materialsSortIsUpper : AnyObject?
    var materialsSortSortNo : AnyObject?
    var materialsSortUserId : AnyObject?
    var merchantType : String?
    
    var page : AnyObject?
    var sortType : AnyObject?
    var specName : AnyObject?
    var storeId : AnyObject?
    var substationId : AnyObject?
    var productParamAttr: String?
    
    var merchantRealName: String?
    var merchantUserName: String?
    var merchantMobile: String?
    var merchantServicephone:  String?
    var merchantAddress: String?
    var merchantHeadUrl: String?
    var promotionPrice: NSNumber?
    var activityTitle: String?
    var promotionalTime: Int?
    var shelfFlag: Int? // 1 上架 2下架
    
    
    /// 团购邀请
    var alreadyGroupNum : Int?  // 已组团数量
    var groupNum : Int?
    var groupPrice : Int?
    var isMe : Int?  // 我发起:0 我参与：1  status: status状态（0:报名中 1:拼团成功）
    var openDate : String?
    var title : String?
    var userId : String?
    var userName : String?
    var version : AnyObject?
    
    
    var activityPriceMax : NSNumber?
    var activityPriceMin : NSNumber?
    var activityPrice : NSNumber?
    var marketId : String?
    var marketMaterialsId : String?
    var marketingMaterialsSkuId : String?
    
    //产品类型标识(0:天网 1:地网)
    var productTypeIdentification: Int?
    //补贴限额
    var maxSubsidyAmount: Double?
    //补贴比例
    var subsidyRatio: Double?
    
    
    override init() {
        super.init()
        merchant = MerchantModel()
        categorya = CategoryModel()
        categoryb = CategoryModel()
        categoryc = CategoryModel()
        categoryd = CategoryModel()
        
        yzbMerchant = MerchantModel()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        buyRemarks <- map["buyRemarks"]
        activityPrice <- map["activityPrice"]
        activityPriceMax <- map["activityPriceMax"]
        activityPriceMin <- map["activityPriceMin"]
        marketId <- map["marketId"]
        marketMaterialsId <- map["marketMaterialsId"]
        marketingMaterialsSkuId <- map["marketingMaterialsSkuId"]
        
        priceShowMin <- map["priceShowMin"]
        priceShowMax <- map["priceShowMax"]
        alreadyGroupNum <- map["alreadyGroupNum"]
        groupNum <- map["groupNum"]
        groupPrice <- map["groupPrice"]
        isMe <- map["isMe"]
        openDate <- map["openDate"]
        title <- map["title"]
        userId <- map["userId"]
        userName <- map["userName"]
        version <- map["version"]
        
        brandImg <- map["brandImg"]
        sellNum <- map["sellNum"]
        shelfFlag <- map["shelfFlag"]
        promotionalTime <- map["promotionalTime"]
        activityTitle <- map["activityTitle"]
        activityId <- map["activityId"]
        promotionPrice <- map["promotionPrice"]
        productParamAttr <- map["productParamAttr"]
        capacity <- map["capacity"]
        materialsType <- map["materialsType"]
        unitTypeName <- map["unitTypeName"]
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        name <- map["name"]
        no <- map["no"]
        imageUrl <- map["imageUrl"]
        images <- map["images"]
        status <- map["status"]
        intro <- map["intro"]
        keywords <- map["keywords"]
        unitType <- map["unitType"]
        count <- map["count"]
        weight <- map["weight"]
        priceShow <- map["priceShow"]
        priceCustom <- map["priceCustom"]
        cusPrice <- map["cusPrice"]
        priceCost <- map["priceCost"]
        beforePriceCost <- map["beforePriceCost"]
        priceSupply <- map["priceSupply"]
        beforeUnitType <- map["beforeUnitType"]
        beforePriceSupply <- map["beforePriceSupply"]
        ishide <- map["ishide"]
        materialSizetype <- map["materialSizetype"]
        url <- map["url"]
        content <- map["content"]
        beginPriceCustom <- map["beginPriceCustom"]
        endPriceCustom <- map["endPriceCustom"]
        sort <- map["sort"]
        // isCheck <- map["isCheck"]
        isCheckBtn <- map["isCheckBtn"]
        zdyprice <- map["zdyprice"]
        brandName <- map["brandName"]
        merchantId <- map["merchantId"]
        type <- map["type"]
        buyCount <- map["buyCount"]
        isOneSell <- map["isOneSell"]
        
        recevingTerm <- map["recevingTerm"]           //发货期限
        installationFlag <- map["installationFlag"]//: String?       //是否提供安装服务 1不提供 2提供
        upstairsFlag <- map["upstairsFlag"]//: String?           //是否上楼 1不 2上
        allDeliverFlag <- map["allDeliverFlag"]//: String?         //是否整箱发货 1不 2是
        logisticsFlag <- map["logisticsFlag"]//: String?          //是否包含物流费 1否 2是
        exPackagingHigh <- map["exPackagingHigh"]//: String?        //高
        exPackagingLong <- map["exPackagingLong"]//: String?//" :   //长
        exPackagingWide <- map["exPackagingWide"]//: String?        //宽
        exPackagingSize <- map["exPackagingSize"]
        customizeFlag <- map["customizeFlag"]//: String?          //自定义规格标记 1否 2是
        yzbMerchant <- map["yzbMerchant"]
        companymaterials <- map["companymaterials"]
        categorya <- map["categorya"]
        categoryb <- map["categoryb"]
        categoryc <- map["categoryc"]
        categoryd <- map["categoryd"]
        categorys <- map["categorys"]
        yzbSpecification <- map["yzbSpecification"]
        
        
        skuFlag <- map["skuFlag"]
        classificationId <- map["classificationId"]
        qrCode <- map["qrCode"]
        categorydId <- map["categorydId"]
        categoryaId <- map["categoryaId"]
        categorybId <- map["categorybId"]
        specification <- map["specification"]
        proArea <- map["proArea"]
        sortNum <- map["sortNum"]
        priceSupplyMax <- map["priceSupplyMax"]
        materialsSkuList <- map["materialsSkuList"]
        marketingMaterialsSkuList <- map["marketingMaterialsSkuList"]
        
        attrdataId <- map["attrdataId"]
        isTj <- map["isTj"]
        priceSellMin <- map["priceSellMin"]
        cityId <- map["cityId"]
        isQc <- map["isQc"]
        priceSellMax <- map["priceSellMax"]
        categorycId <- map["categorycId"]
        createBy <- map["createBy"]
        isTop <- map["isTop"]
        priceSupplyMin <- map["priceSupplyMin"]
        
        updateBy <- map["updateBy"]
        
        delFlag <- map["delFlag"]
        upperFlag <- map["upperFlag"]
        code <- map["code"]
        topFlag <- map["topFlag"]
        isNew <- map["isNew"]
        sortNo <- map["sortNo"]
        categoryaName <- map["categoryaName"]
        categorybName <- map["categorybName"]
        categorycName <- map["categorycName"]
        categorydName <- map["categorydName"]
        
        id <- map["id"]
        isNewRecord <- map["isNewRecord"]
        remarks <- map["remarks"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        buyCount <- map["buyCount"]
        worker <- map["worker"]
        store <- map["store"]
        materials <- map["materials"]
        merchant <- map["merchant"]
        service <- map["service"]
        type <- map["type"]
        materialsType <- map["materialsType"]
        
        alertNum <- map["alertNum"]
        count <- map["count"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        id <- map["id"]
        image <- map["image"]
        images <- map["images"]
        isDefault <- map["isDefault"]
        materials <- map["materials"]
        materialsId <- map["materialsId"]
        merchantId <- map["merchantId"]
        merchantName <- map["merchantName"]
        price <- map["price"]
        priceCost <- map["priceCost"]
        priceSell <- map["priceSell"]
        priceShow <- map["priceShow"]
        remarks <- map["remarks"]
        saleNum <- map["saleNum"]
        skuAttr <- map["skuAttr"]
        skuCode <- map["skuCode"]
        skuName <- map["skuName"]
        stockNum <- map["stockNum"]
        unitTypeName <- map["unitTypeName"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        brandName <- map["brandName"]
        categoryAName <- map["categoryAName"]
        isOneSell <- map["isOneSell"]
        materialsCount <- map["materialsCount"]
        materialsId <- map["materialsId"]
        materialsImageUrl <- map["materialsImageUrl"]
        materialsName <- map["materialsName"]
        materialsPriceCustom <- map["materialsPriceCustom"]
        materialsPriceSupply <- map["materialsPriceSupply"]
        materialsPriceShow <- map["materialsPriceShow"]
        materialsSizeTypeName <- map["materialsSizeTypeName"]
        materialsUnitType <- map["materialsUnitType"]
        materialsUnitTypeName <- map["materialsUnitTypeName"]
        merchantId <- map["merchantId"]
        merchantName <- map["merchantName"]
        orderDataId <- map["orderDataId"]
        orderId <- map["orderId"]
        remarks <- map["remarks"]
        skuAttr <- map["skuAttr"]
        skuId <- map["skuId"]
        
        allDeliverFlag <- map["allDeliverFlag"]
        attrClassification <- map["attrClassification"]
        attrDataList <- map["attrDataList"]
        attrdataId <- map["attrdataId"]
        brandId <- map["brandId"]
        brandName <- map["brandName"]
        buyCount <- map["buyCount"]
        capacity <- map["capacity"]
        categoryaId <- map["categoryaId"]
        categoryaName <- map["categoryaName"]
        categorybId <- map["categorybId"]
        categorybName <- map["categorybName"]
        categorycId <- map["categorycId"]
        categorycName <- map["categorycName"]
        categorydId <- map["categorydId"]
        categorydName <- map["categorydName"]
        cityId <- map["cityId"]
        classificationId <- map["classificationId"]
        code <- map["code"]
        content <- map["content"]
        count <- map["count"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        customizeFlag <- map["customizeFlag"]
        delFlag <- map["delFlag"]
        exPackagingHigh <- map["exPackagingHigh"]
        exPackagingLong <- map["exPackagingLong"]
        exPackagingWide <- map["exPackagingWide"]
        groupName <- map["groupName"]
        id <- map["id"]
        imageUrl <- map["imageUrl"]
        images <- map["images"]
        installationFlag <- map["installationFlag"]
        intro <- map["intro"]
        isCheck <- map["isCheck"]
        isFz <- map["isFz"]
        isNew <- map["isNew"]
        isOneSell <- map["isOneSell"]
        isQc <- map["isQc"]
        isTj <- map["isTj"]
        isTop <- map["isTop"]
        ishide <- map["ishide"]
        keywords <- map["keywords"]
        logisticsFlag <- map["logisticsFlag"]
        materialsSortIsUpper <- map["materialsSortIsUpper"]
        materialsSortSortNo <- map["materialsSortSortNo"]
        materialsSortUserId <- map["materialsSortUserId"]
        materialsType <- map["materialsType"]
        merchantId <- map["merchantId"]
        merchantName <- map["merchantName"]
        merchantType <- map["merchantType"]
        name <- map["name"]
        no <- map["no"]
        page <- map["page"]
        priceCost <- map["priceCost"]
        priceSell <- map["priceSell"]
        priceSellMax <- map["priceSellMax"]
        priceSellMin <- map["priceSellMin"]
        priceShow <- map["priceShow"]
        priceSupply <- map["priceSupply"]
        priceSupplyMax <- map["priceSupplyMax"]
        priceSupplyMin <- map["priceSupplyMin"]
        proArea <- map["proArea"]
        qrCode <- map["qrCode"]
        recevingTerm <- map["recevingTerm"]
        remarks <- map["remarks"]
        skuFlag <- map["skuFlag"]
        sort <- map["sort"]
        sortNo <- map["sortNo"]
        sortNum <- map["sortNum"]
        sortType <- map["sortType"]
        specName <- map["specName"]
        specification <- map["specification"]
        status <- map["status"]
        storeId <- map["storeId"]
        substationId <- map["substationId"]
        topFlag <- map["topFlag"]
        type <- map["type"]
        unitType <- map["unitType"]
        unitTypeName <- map["unitTypeName"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        upperFlag <- map["upperFlag"]
        upstairsFlag <- map["upstairsFlag"]
        url <- map["url"]
        weight <- map["weight"]
        yzbMerchant <- map["yzbMerchant"]
        
        merchantRealName <- map["merchantRealName"]
        merchantUserName <- map["merchantUserName"]
        merchantMobile <- map["merchantMobile"]
        merchantServicephone <- map["merchantServicephone"]
        merchantAddress <- map["merchantAddress"]
        merchantHeadUrl <- map["merchantHeadUrl"]
        
        productTypeIdentification <- map["productTypeIdentification"]
        maxSubsidyAmount <- map["maxSubsidyAmount"]
        subsidyRatio <- map["subsidyRatio"]
    }
    
}


class MaterialsSkuListModel : NSObject, Mappable{
    
    var alertNum : Int?
    var createDate : String?
    var delFlag : String?
    var id : String?
    var image : String?
    var images : String?
    var isDefault : String?
    var materialsId : String?
    var price : NSNumber?
    var price1 : NSNumber? {
        get {
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                return priceSell
            } else {
                return price
            }
        }
    }
    var priceCost : NSNumber?
    var priceSell : NSNumber?
    var priceShow : NSNumber?
    var remarks : String?
    var saleNum : Int?
    var skuAttr : String?
    var skuAttr1: String? {
        get {
            let arr = skuAttr?.getArrayByJsonString()
            var str = ""
            arr?.forEach({ (item) in
                let dic = item as? [String: Any]
                let value =  dic?["skuValue"] as? String
                str.append("\(value ?? "") ")
            })
            if str.isEmpty {
                return "未知"
            }
            return str
        }
    }
    var skuCode : String?
    var skuName : String?
    var stockNum : Int?
    var updateBy : String?
    var updateDate : String?
    var buyCount: Int?
    var activityPrice : NSNumber?
    var marketId : String?
    var marketMaterialsId : String?
    var marketingMaterialsSkuId : String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map)
    {
        activityPrice <- map["activityPrice"]
        marketId <- map["marketId"]
        marketMaterialsId <- map["marketMaterialsId"]
        marketingMaterialsSkuId <- map["marketingMaterialsSkuId"]
        alertNum <- map["alertNum"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        id <- map["id"]
        image <- map["image"]
        images <- map["images"]
        isDefault <- map["isDefault"]
        materialsId <- map["materialsId"]
        price <- map["price"]
        priceCost <- map["priceCost"]
        priceSell <- map["priceSell"]
        priceShow <- map["priceShow"]
        remarks <- map["remarks"]
        saleNum <- map["saleNum"]
        skuAttr <- map["skuAttr"]
        skuCode <- map["skuCode"]
        skuName <- map["skuName"]
        stockNum <- map["stockNum"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
    }
}
