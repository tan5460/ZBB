//
//  WKWebview+Ex.swift
//  ChalkTalks
//
//  Created by 巢云 on 2019/9/20.
//  Copyright © 2019 巢云. All rights reserved.
//

import WebKit
fileprivate final class InputAccessoryHackHelper: NSObject {
    @objc var inputAccessoryView: AnyObject? { return nil }
}

typealias OlderClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Any?) -> Void
typealias NewerClosureType =  @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void

extension WKWebView {
    
    /// 隐藏键盘上面的工具栏
    func hack_removeInputAccessory() {
        guard let target = scrollView.subviews.first(where: {
            String(describing: type(of: $0)).hasPrefix("WKContent")
        }), let superclass = target.superclass else {
            return
        }
        
        let noInputAccessoryViewClassName = "\(superclass)_NoInputAccessoryView"
        var newClass: AnyClass? = NSClassFromString(noInputAccessoryViewClassName)
        
        if newClass == nil, let targetClass = object_getClass(target), let classNameCString = noInputAccessoryViewClassName.cString(using: .ascii) {
            newClass = objc_allocateClassPair(targetClass, classNameCString, 0)
            
            if let newClass = newClass {
                objc_registerClassPair(newClass)
            }
        }
        
        guard let noInputAccessoryClass = newClass, let originalMethod = class_getInstanceMethod(InputAccessoryHackHelper.self, #selector(getter: InputAccessoryHackHelper.inputAccessoryView)) else {
            return
        }
        class_addMethod(noInputAccessoryClass.self, #selector(getter: InputAccessoryHackHelper.inputAccessoryView), method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        object_setClass(target, noInputAccessoryClass)
    }
    
    /// ，WKWebView要自己实现
    var keyboardDisplayRequiresUserAction: Bool? {
        get {
            return self.keyboardDisplayRequiresUserAction
        }
        set {
            setKeyboardRequiresUserInteraction(newValue ?? true)
        }
    }
    
    func setKeyboardRequiresUserInteraction( _ value: Bool) {
        
        guard
            let WKContentViewClass: AnyClass = NSClassFromString("WKContentView") else {
                print("Cannot find the WKContentView class")
                return
        }
        
        let olderSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:")
        let newSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        let newerSelector: Selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")
        let ios13Selector: Selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:")
        
        if let method = class_getInstanceMethod(WKContentViewClass, olderSelector) {
            
            let originalImp: IMP = method_getImplementation(method)
            let original: OlderClosureType = unsafeBitCast(originalImp, to: OlderClosureType.self)
            let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Any?) -> Void = { (mee, arg0, arg1, arg2, arg3) in
                original(mee, olderSelector, arg0, !value, arg2, arg3)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }
        
        if let method = class_getInstanceMethod(WKContentViewClass, newSelector) {
            swizzleAutofocusMethod(method, newSelector, value)
        }
        
        if let method = class_getInstanceMethod(WKContentViewClass, newerSelector) {
            swizzleAutofocusMethod(method, newerSelector, value)
        }
        
        if let method = class_getInstanceMethod(WKContentViewClass, ios13Selector) {
            swizzleAutofocusMethod(method, ios13Selector, value)
        }
    }
    
    func swizzleAutofocusMethod(_ method: Method, _ selector: Selector, _ value: Bool) {
        let originalImp: IMP = method_getImplementation(method)
        let original: NewerClosureType = unsafeBitCast(originalImp, to: NewerClosureType.self)
        let block : @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void = { (mee, arg0, arg1, arg2, arg3, arg4) in
            original(mee, selector, arg0, !value, arg2, arg3, arg4)
        }
        let imp: IMP = imp_implementationWithBlock(block)
        method_setImplementation(method, imp)
    }
}
