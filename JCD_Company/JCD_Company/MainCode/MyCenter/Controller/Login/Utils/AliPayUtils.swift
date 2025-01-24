//
//  AliPayUtils.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/10/13.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

class AliPayUtils {

    private static var aliAuthBack: AliPayBack?
    private static var aliPayBack: AliPayBack?
    
    static func login(signStr: String, aliAuthBack: AliPayBack?) {
        AliPayUtils.aliAuthBack = aliAuthBack
        AlipaySDK.defaultService()?.auth_V2(withInfo: signStr, fromScheme: "aliauth", callback: { (resp) in
            loginBack(resultDic: resp! as [NSObject: AnyObject])
        })
    }

    static func loginBack(resultDic: [NSObject: AnyObject]) {
        if let Alipayjson: [String: AnyObject] = resultDic as? [String: AnyObject] {
            let resultStatus = Alipayjson["resultStatus"] as! String
            print("loginBack resultStatus=\(resultStatus)")
            if resultStatus == "9000" {//   请求处理成功
                aliAuthBack?.finish(Alipayjson["result"] as? String)
            } else {
                aliAuthBack?.failed()
            }
        }
    }

    static func pay(signStr: String, aliPayBack: AliPayBack?) {
        AliPayUtils.aliPayBack = aliPayBack
        AlipaySDK().payOrder(signStr, fromScheme: NSLocalizedString("alipayback", comment: ""), callback: { (resp) in
            payBack(resultDic: resp! as [NSObject: AnyObject])
        })
    }

    static func payBack(resultDic: [NSObject: AnyObject]) {
        if let Alipayjson: [String: AnyObject] = resultDic as? [String: AnyObject] {
            let resultStatus = Alipayjson["resultStatus"] as! String
            print("payBack resultStatus=\(resultStatus)")
            if resultStatus == "9000" || resultStatus == "8000" {//   订单支付成功或正在处理中
                aliPayBack?.finish(Alipayjson["result"] as? String)
            } else {
                aliPayBack?.failed()
            }
        }
    }

}

protocol AliPayBack {
    func finish(_ result: String?)

    func failed()
}
