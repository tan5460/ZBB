//
//  Util.swift
//  ShiXue
//
//  Created by 喻学文 on 15/7/4.
//  Copyright (c) 2015年 喻学文. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import PopupDialog
import ObjectMapper

///常用类
struct AppUtils{
    
    ///获取基础数据
    static func getBaseInfo(resData:NSDictionary){
        
        AppData.isBaseDataLoaded = true
        AppData.styleTypeList=Utils.getReadArrDic(data: resData, field: "styleTypeList")
        AppData.sexList=Utils.getReadArrDic(data: resData, field: "sexList")
        AppData.roomTypeList=Utils.getReadArrDic(data: resData, field: "roomTypeList")
        AppData.unitTypeList=Utils.getReadArrDic(data: resData, field: "unitTypeList")
        AppData.purchaseOrderStatusTypeList=Utils.getReadArrDic(data: resData, field: "purchaseOrderStatusTypeList")
        AppData.purchaseOrderPayStatusList=Utils.getReadArrDic(data: resData, field: "purchaseOrderPayStatusList")
        AppData.plusOrderStatusTypeList=Utils.getReadArrDic(data: resData, field: "plusOrderStatusTypeList")
        AppData.serviceCategoryList=Utils.getReadArrDic(data: resData, field: "serviceCategoryList")
        AppData.houseAreaList=Utils.getReadArrDic(data: resData, field: "houseAreaList")
        AppData.houseTypesList=Utils.getReadArrDic(data: resData, field: "houseTypesList")
        AppData.yzbStrategyList=Utils.getReadArrDic(data: resData, field: "yzbStrategyList")
        AppData.yzbSendTermList=Utils.getReadArrDic(data: resData, field: "yzbSendTermList")
        AppData.serviceTypes = Utils.getReadArrDic(data: resData, field: "serviceType")
        AppData.workTypes = Utils.getReadArrDic(data: resData, field: "workType")
        AppData.brandProtectionList = Utils.getReadArrDic(data: resData, field: "brandProtectionList")
        let yzbWarning = Utils.getReadArrDic(data: resData, field: "yzbWarningList")
        if let dic = yzbWarning.first {
            AppData.yzbWarning = Utils.getReadString(dir: dic, field: "value")
        }
        let yzbIntegral = Utils.getReadArrDic(data: resData, field: "yzbIntegralRateList")
        if let dic = yzbIntegral.first {
            AppData.yzbIntegral = Utils.getReadString(dir: dic, field: "value")
        }
    }
    
    fileprivate enum UserDefaultKey: String {
        case UserKey     = "UserKey"
        case UserType    = "UserType"
        case JZUserData  = "JZUserData"
        case GYSUserData = "GYSUserData"
        case YYSUserData = "YYSUserData"
    }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
    ///切换身份存储用户类型
    static func setUserType(type: LoginType) {
        UserDefaults.standard.set(type.rawValue, forKey: UserDefaultKey.UserType.rawValue)
        UserDefaults.standard.synchronize()
    }
    static func getUserType() -> Int {
        return UserDefaults.standard.integer(forKey: UserDefaultKey.UserType.rawValue)
    }
    
    /// 储存用户数据
    static func setUserData(response: [String : AnyObject]) {
        UserDefaults.standard.set(UserData.shared.userType.rawValue, forKey: UserDefaultKey.UserType.rawValue)
        let userDic = DeleteEmpty.deleteEmpty(response)!
        let dataDic = Utils.getReqDir(data: userDic as AnyObject)
        let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
        UserData.shared.userInfoModel = infoModel
        //本地缓存用户数据
        UserDefaults.standard.set(userDic, forKey: UserDefaultKey.JZUserData.rawValue)
    }
    
    /// 读取本地数据
    static func getLocalUserData(){
        
        if let valueStr = UserDefaults.standard.object(forKey: UserDefaultKey.UserKey.rawValue) as? String {
            
            UserData.shared.key = valueStr
        }
        
        if let response = UserDefaults.standard.object(forKey: UserDefaultKey.JZUserData.rawValue) as? [String : AnyObject] {
            
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            let userModel = Mapper<WorkerModel>().map(JSON: dataDic as! [String : Any])
            UserData.shared.workerModel = userModel
        }
        
        if let response = UserDefaults.standard.object(forKey: UserDefaultKey.GYSUserData.rawValue) as? [String : AnyObject] {
            
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            let userModel = Mapper<MerchantModel>().map(JSON: dataDic as! [String : Any])
            UserData.shared.merchantModel = userModel
        }
        
        if let response = UserDefaults.standard.object(forKey: UserDefaultKey.YYSUserData.rawValue) as? [String : AnyObject] {
            
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            let userModel = Mapper<SubstationModel>().map(JSON: dataDic as! [String : Any])
            UserData.shared.substationModel = userModel
        }
    }
    
    /// 清除本地数据
    static func cleanUserData() {
        
        [
            UserDefaultKey.UserKey,
            .UserType,
            .JZUserData,
            .GYSUserData,
            .YYSUserData
            ].forEach { UserDefaults.standard.removeObject(forKey: $0.rawValue) }
        
//        setUserType(type: .cgy)
        UserData.shared.key = ""
        UserData.shared.workerModel = nil
        UserData.shared.merchantModel = nil
        UserData.shared.substationModel = nil
        UserData.shared.userInfoModel = nil
        UserDefaults.standard.removeObject(forKey: UserDefaultStr.tokenModel)
    }
}
