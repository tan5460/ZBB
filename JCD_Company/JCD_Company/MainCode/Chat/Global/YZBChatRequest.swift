//
//  YZBChatRequest.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/3.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class YZBChatRequest {
    ///单例模式
    static let shared = YZBChatRequest()
    
    // MARK: 登录注册
    ///注册
//    func register(with account: String, pwd: String, errorBlock:@escaping (Error?) -> ()) {
//
//        JMSGUser.register(withUsername: account, password: pwd) { (resultObject, error) in
//            if error == nil {
//                AppLog("JMS注册成功")
//                self.login(with: account, pwd: pwd, errorBlock: { (error) in
//                    if error == nil {
//                        errorBlock(nil)
//                    }else {
//                        errorBlock(error)
//                    }
//                })
//            }else {
//                errorBlock(error)
//                AppLog("jMSError:" + String.errorAlert(error!))
//            }
//        }
//    }
    
    ///带用户信息的注册
    func register(with account: String, pwd: String, userInfo: JMSGUserInfo, isNeedLogin: Bool = false, errorBlock:@escaping (Error?) -> ()) {
        
        if userInfo.nickname == "" {
            userInfo.nickname = account
        }
        
        JMSGUser.register(withUsername: account, password: pwd, userInfo: userInfo) { (resultObject, error) in
            if error == nil {
                errorBlock(nil)
                AppLog("JMS注册成功")
                if isNeedLogin {
                    self.login(with: account, pwd: pwd, errorBlock: { (error) in
                        if error == nil {
                            errorBlock(nil)
                        }else {
                            errorBlock(error)
                        }
                    })
                }
            }else {
                errorBlock(error)
                AppLog("jMSError:" + String.errorAlert(error!))
            }
        }
    }
    ///登录
    func login(with account: String, pwd: String, errorBlock:@escaping (Error?) -> ()) {

        // 如果pwd MD5加密 => YZBSign.shared.passwordMd5(password: pwd)
        JMSGUser.login(withUsername: account, password: pwd) { (resultObject, error) in
            if error == nil {
                AppLog("JMS登录成功")
                errorBlock(nil)
                
                YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                    
                })
               
            }else {
                errorBlock(error)
                AppLog("jMSError:" + String.errorAlert(error!))
                if error!._code == 801003 {
                    let userInfo = self.getMyUserInfo()
                    self.register(with: account, pwd: pwd, userInfo: userInfo, isNeedLogin: true, errorBlock: { (error) in
                        
                    })
                }
            }
        }
       
    }
    ///退出登录
    func logout(errorBlock:@escaping (Error?) -> ()) {
        
        JMSGUser.logout { (resultObject, error) in
            if error == nil {
                AppLog("JMS退出登录成功")
                errorBlock(nil)
            }else {
                errorBlock(error)
                AppLog("jMSError:" + String.errorAlert(error!))
            }
        }
    }
    
    // MARK: IM用户信息
    ///获取IM用户信息
    func getUserInfo(with account: String, errorBlock:@escaping (JMSGUser?,Error?) -> ()) {
        
        JMSGUser.userInfoArray(withUsernameArray: [account]) { (resultObject, error) in
            if error == nil {
                AppLog("JMS获取用户信息成功")
                if let users = resultObject as? [JMSGUser] {
                    if let user = users.first {
                        
                        errorBlock(user,nil)
                    }else {
                        errorBlock(nil,nil)
                    }
                }else {
                    errorBlock(nil,nil)
                }
                
            }else {
                errorBlock(nil,error)
                AppLog("jMSError:" + String.errorAlert(error!))
            }
        }
    }
    
    //更新用户单个扩展信息
//    func updataMyUserInfo(keyStr: String, valueStr: String) {
//
//        let userInfo = JMSGUser.myInfo()
//        if var userDic = userInfo.extras {
//
//            if keyStr != "" && valueStr != "" {
//                userDic[keyStr] = valueStr
//
//                let newUserInfo = JMSGUserInfo()
//                newUserInfo.nickname = userInfo.nickname!
//                newUserInfo.extras = userDic
//
//                JMSGUser.updateMyInfo(with: newUserInfo) { (resultObject, error) in
//                    if error == nil {
//                        AppLog("JMS修改用户信息成功")
//                    }else {
//                        AppLog("jMSError:" + String.errorAlert(error!))
//                    }
//                }
//            }
//        }
//    }
   
    //获取当前登录用户信息
    func getMyUserInfo() -> JMSGUserInfo {
        
        var userId = ""
        var nickName = ""
        var storeName = ""
        var headUrl = ""
        var tel1 = ""
        var tel2 = ""
        var storeType = "1"           //1：采购员；2：供应商；3：运营商；4：设计师
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            storeType = "1"
            if UserData.shared.userType == .jzgs {
                storeType = "4"
            }
            if let valueStr = UserData.shared.workerModel?.id {
                userId = valueStr
            }
            if let valueStr = UserData.shared.workerModel?.realName {
                nickName = valueStr
            }
            if let valueStr = UserData.shared.storeModel?.name {
                storeName = valueStr
            }
            if let valueStr = UserData.shared.workerModel?.headUrl {
                headUrl = valueStr
            }
            if let valueStr = UserData.shared.storeModel?.tel1 {
                tel1 = valueStr
            }
            if let valueStr = UserData.shared.storeModel?.tel2 {
                tel2 = valueStr
            }
        case .gys:
            storeType = "2"
            if let valueStr = UserData.shared.merchantModel?.id {
                userId = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.realName {
                nickName = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.name {
                storeName = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.headUrl {
                headUrl = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.servicephone {
                tel1 = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.mobile {
                tel2 = valueStr
            }
        case .yys:
            storeType = "3"
            if let valueStr = UserData.shared.substationModel?.id {
                userId = valueStr
            }
            if let valueStr = UserData.shared.substationModel?.realName {
                nickName = valueStr
            }
            if let valueStr = UserData.shared.substationModel?.groupName {
                storeName = valueStr
            }
            if let valueStr = UserData.shared.substationModel?.headUrl {
                headUrl = valueStr
            }
            if let valueStr = UserData.shared.substationModel?.mobile {
                tel1 = valueStr
            }
        case .fws:
            storeType = "2"
            if let valueStr = UserData.shared.merchantModel?.id {
                userId = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.realName {
                nickName = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.name {
                storeName = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.headUrl {
                headUrl = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.servicePhone {
                tel1 = valueStr
            }
        }
        
        let ex: NSDictionary = ["detailTitle": storeName, "headUrl": headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
        
        if nickName == "" {
            nickName = JMSGUser.myInfo().username
        }
        
        let userInfo = JMSGUserInfo()
        userInfo.nickname = nickName
        userInfo.extras = ex as! [String: String]
        
        return userInfo
    }
    
    ///更新用户信息
    func updateUserInfo(errorBlock:@escaping (Error?) -> ()) {
        
        let userInfo = self.getMyUserInfo()
        
        JMSGUser.updateMyInfo(with: userInfo) { (resultObject, error) in
            if error == nil {
                AppLog("JMS修改用户信息成功")
                errorBlock(nil)
                
            }else {
                errorBlock(error)
                AppLog("jMSError:" + String.errorAlert(error!))
                
            }
        }
    }
    
    // MARK: 会话
    ///创建单聊会话
    func createSingleMessageConversation(username:String, errorBlock:@escaping (JMSGConversation?,Error?) -> ()) {
        
        JMSGConversation.createSingleConversation(withUsername: username) { (resultObject, error) in
            if error == nil {
                AppLog("JMS创建单聊会话成功")
                if let conversation = resultObject as? JMSGConversation {
                   
                    errorBlock(conversation,nil)
                   
                }else {
                    errorBlock(nil,nil)
                }
            }else {
                errorBlock(nil,error)
                AppLog("jMSError:" + String.errorAlert(error!))
            }
        }
    }
    
    ///获取会话列表
    func getAllConversationList(errorBlock:@escaping ([JMSGConversation],Error?) -> ()) {
        JMSGConversation.allConversations { (resultObject, error) in
            if error == nil {
                AppLog("JMS获取会话列表成功")
                var conversations:[JMSGConversation] = []
                if let arr = resultObject as? [JMSGConversation] {
                    conversations = arr
                }
                errorBlock(conversations,nil)
                
            }else {
                errorBlock([],error)
                AppLog("jMSError:" + String.errorAlert(error!))
                
            }
        }
    }

    ///获取会话消息
    func getAllMessage(conversation:JMSGConversation, errorBlock:@escaping ([JMSGMessage],Error?) -> ()) {
        conversation.allMessages { (resultObject, error) in
            if error == nil {
                AppLog("JMS获取会话全部消息成功")
                var messages:[JMSGMessage] = []
                if let arr = resultObject as? [JMSGMessage] {
                    messages = arr
                }
                errorBlock(messages,nil)
                
            }else {
                errorBlock([],error)
                AppLog("jMSError:" + String.errorAlert(error!))
                if error!._code == 863004 {
                    
                }
            }
        }

    }

}
