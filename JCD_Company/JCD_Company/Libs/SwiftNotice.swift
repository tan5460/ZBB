//
//  SwiftNotice.swift
//  SwiftNotice
//
//  Created by JohnLui on 15/4/15.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift

private let sn_topBar: Int = 1001

extension UIResponder {
    /// wait with your own animated images
    func getWindow() -> UIWindow {
        return UIApplication.shared.windows.first ?? UIWindow()
    }
    
    @discardableResult
    func noticeTop(_ text: String, autoClear: Bool = true, autoClearTime: Int = 1) -> UIWindow {
        let window = getWindow()
        window.makeToast(text, duration: TimeInterval(autoClearTime), position: .top)
        return window
    }
    
    // new apis from v3.3
    @discardableResult
    func noticeSuccess(_ text: String, autoClear: Bool = true, autoClearTime: Float = 1) -> UIWindow{
        let window = getWindow()
        window.makeToast(text, duration: TimeInterval(autoClearTime), position: .center)
        return window
    }
    @discardableResult
    func noticeError(_ text: String, autoClear: Bool = true, autoClearTime: Float = 1) -> UIWindow{
        let window = getWindow()
        window.makeToast(text, duration: TimeInterval(autoClearTime), position: .center)
        return window
    }
    @discardableResult
    func noticeInfo(_ text: String, autoClear: Bool = true, autoClearTime: Float = 1) -> UIWindow{
        let window = getWindow()
        window.makeToast(text, duration: TimeInterval(autoClearTime), position: .center)
        return window
    }
    
    // old apis
    @discardableResult
    func successNotice(_ text: String, autoClear: Bool = true) -> UIWindow{
        let window = getWindow()
        window.makeToast(text, position: .center)
        return window
    }
    @discardableResult
    func errorNotice(_ text: String, autoClear: Bool = true) -> UIWindow{
        let window = getWindow()
        window.makeToast(text, duration: 3,  position: .center)
        return window
    }
    @discardableResult
    func infoNotice(_ text: String, autoClear: Bool = true) -> UIWindow{
        let window = getWindow()
        window.makeToast(text, duration: 3,  position: .center)
        return window
    }
    @discardableResult
    func notice(_ text: String, autoClear: Bool, autoClearTime: Float = 3) -> UIWindow{
        let window = getWindow()
        window.makeToast(text, duration: TimeInterval(autoClearTime),  position: .center)
        return window
    }
    @discardableResult
    func pleaseWait() -> UIWindow{
        let window = UIApplication.shared.windows.first
        window?.makeToastActivity(.center)
        return window!
    }
    
    @discardableResult
    func noticeOnlyText(_ text: String) -> UIWindow{
        let window = UIApplication.shared.windows.first
        window?.makeToast(text, duration: 1, position: .center)
        return window!
    }
    func clearAllNotice() {
        let window = UIApplication.shared.windows.first
        window?.hideAllToasts(includeActivity: true, clearQueue: true)
    }
}
