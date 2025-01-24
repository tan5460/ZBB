//
//  MyUser.swift
//  IMUIChat
//
//  Created by oshumini on 2017/4/9.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import Foundation
import UIKit

class MessageUser: NSObject, IMUIUserProtocol {
 
    var userModel : JMSGUser?

    public override init() {
        super.init()
    }
    
    func userId() -> String {
        return ""
    }
    func displayName() -> String {
        if let displayName = userModel?.displayName() {
            return displayName
        }
        return ""
    }
    
    func detailTitle() -> String {
        if let exdic = userModel?.extras {
            
            if let detailTitle = exdic["detailTitle"] as? String {
                return detailTitle
               
            }
        }
        return ""
    }
    
    func Avatar() -> UIImage? {
        return UIImage(named: "headerImage_man")!
    }
    
    func avatarUrlString() -> String? {
        
        if let exdic = userModel?.extras {
            
            var userName = ""
            var userHead = ""
            
            switch UserData.shared.userType {
            case .jzgs, .cgy:
                if let valueStr = UserData.shared.workerModel?.userName {
                    userName = valueStr
                }
                if let valueStr = UserData.shared.workerModel?.headUrl {
                    userHead = valueStr
                }
            case .gys:
                if let valueStr = UserData.shared.merchantModel?.userName {
                    userName = valueStr
                }
                if let valueStr = UserData.shared.merchantModel?.headUrl {
                    userHead = valueStr
                }
            case .yys:
                if let valueStr = UserData.shared.substationModel?.userName {
                    userName = valueStr
                }
                if let valueStr = UserData.shared.substationModel?.headUrl {
                    userHead = valueStr
                }
            case .fws:
                if let valueStr = UserData.shared.merchantModel?.userName {
                    userName = valueStr
                }
                if let valueStr = UserData.shared.merchantModel?.headUrl {
                    userHead = valueStr
                }
            }
            
            if let valueStr = userModel?.username {
                if userName == valueStr {
                    return APIURL.ossPicUrl + userHead
                }
            }
            
            if let headUrl = exdic["headUrl"] as? String {
                return APIURL.ossPicUrl + headUrl
            }
        }
        
        return ""
    }
}
