//
//  HoNotificationCenter.swift
//  swift-tools
//
//  Created by 叶长生 on 2018/12/19.
//  Copyright © 2018 Hoa. All rights reserved.
//

import Foundation

/*
 
 Usage:
 step 1: 创建监听类
 
 class Line: HoNotificationer {
    enum HoNotification: String {
        case text
    }
 }
 
 step 2: 发送
    Line.post(notification: .text, object: nil, userInfo: nil)
 step 3: 添加
    Line.add(observer: self, selector: Selector(), notification: .text)
 step 4: 移除
    Line.remove(observer: self, notification: .text)

 */

public protocol HoNotificationer {
    associatedtype HoNotification: RawRepresentable
}

public extension HoNotificationer where HoNotification.RawValue == String {
    
    private static func nameFor(_ notification: HoNotification) -> String {
        return "\(self).\(notification.rawValue)"
    }
    
    func post(notification: HoNotification, object: AnyObject? = nil) {
        Self.post(notification: notification, object: object)
    }
    
    func post(notification: HoNotification, object: AnyObject? = nil, userInfo: [AnyHashable: AnyObject]? = nil) {
        Self.post(notification: notification, object: object, userInfo: userInfo)
    }
    
    /// 发送通知
    static func post(notification: HoNotification, object: AnyObject? = nil, userInfo: [AnyHashable: AnyObject]? = nil) {
        
        let name = nameFor(notification)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: object, userInfo: userInfo)
    }
    
    /// 添加Observer
    ///
    /// - parameter observer: Selector绑定对象
    /// - parameter selector: 通知回调method
    /// - parameter notification: 监听的通知
    static func add(observer: AnyObject, selector: Selector, notification: HoNotification) {
        let name = nameFor(notification)
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
    
    /// 移除通知
    ///
    /// - parameter observer: 通知绑定对象
    /// - parameter notification: 通知
    /// - parameter object: 参数
    static func remove(observer: AnyObject, notification: HoNotification, object: AnyObject? = nil) {
        let name = nameFor(notification)
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue: name), object: object)
    }
}
