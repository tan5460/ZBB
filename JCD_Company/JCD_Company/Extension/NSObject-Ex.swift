//
//  NSObject-Ex.swift
//  ChalkTalks
//
//  Created by 巢云 on 2019/9/4.
//  Copyright © 2019 巢云. All rights reserved.
//

import Foundation
extension NSObject {
    static  var className: String {
        let name =  self.description()
        if name.contains(".") {
            return name.components(separatedBy: ".")[1]
        } else {
            return name
        }
    }
    
    public func getCurrentVC() -> UIViewController {
        let rootVc = UIApplication.shared.keyWindow?.rootViewController
        let vc = getCurrentVCFrom(rootVc!)
        return vc
    }
    
    
    private func getCurrentVCFrom(_ rootVc:UIViewController) -> UIViewController {
        var currentVc:UIViewController
        var rootCtr = rootVc
        if (rootCtr.presentedViewController != nil) {
            rootCtr = rootVc.presentedViewController!
        }
        if rootVc.isKind(of:UITabBarController.classForCoder()) {
            currentVc = getCurrentVCFrom((rootVc as! UITabBarController).selectedViewController!)
        }else if rootVc.isKind(of:UINavigationController.classForCoder()){
            currentVc = getCurrentVCFrom((rootVc as! UINavigationController).visibleViewController!)
        }else{
            currentVc = rootCtr
        }
        return currentVc
    }


}
