//
//  LDWchatShare.swift
//  CGYC
//
//  Created by Artron_LQQ on 2017/6/8.
//  Copyright © 2017年 Artup. All rights reserved.
//
/* 简书博客: http://www.jianshu.com/u/2846c3d3a974
 Github: https://github.com/LQQZYY
 
 demo地址: https://github.com/LQQZYY/LDThirdShare-Swift
 博文讲解: http://www.jianshu.com/p/1b744a97e63d
 */

import UIKit

typealias LDWechatShare_loginFailClosure = (_ error: String) -> Void
typealias LDWechatShare_loginSuccessClosure = (_ info: [String: Any]) -> Void
typealias LDWechatShare_resultHandle = (_ isSuccess: Bool, _ description: String) -> Void
typealias LDWechatShare_payResultHandle = (_ result: LDWechatPayResult, _ identifier: String) -> Void
class LDWechatShare: NSObject {
    
    static var shared: LDWechatShare = LDWechatShare()
    private override init() { }
    
    fileprivate var appID: String = ""
    fileprivate var appSecret: String = ""
    fileprivate var accessToken: String = ""
    fileprivate var universalLink: String = ""
    
    fileprivate var successClosure: LDWechatShare_loginSuccessClosure? = nil
    fileprivate var failClosure: LDWechatShare_loginFailClosure? = nil
    fileprivate var isShareSuccess: LDWechatShare_resultHandle? = nil
    fileprivate var payResultHandle: LDWechatShare_payResultHandle? = nil
    
    fileprivate var payIdentifier: String = ""
    
    static func registeApp(_ appID: String, universalLink: String, appSecret: String) {
        LDWechatShare.shared.appID = appID
        LDWechatShare.shared.appSecret = appSecret
        LDWechatShare.shared.universalLink = universalLink
        WXApi.registerApp(appID, universalLink: universalLink)
    }
    
    static func handle(_ url: URL) -> Bool {
        
        return WXApi.handleOpen(url, delegate: LDWechatShare.shared)
//        if let host = url.host {
//            if host == "oauth" {
//                // 微信登陆
//                return WXApi.handleOpen(url, delegate: LDWechatShare.shared)
//            } else if host == "platformId=wechat" {
//                // 微信分享
//                return WXApi.handleOpen(url, delegate: LDWechatShare.shared)
//            }
//        }
//        
//        return true
    }
    
    static func handleOpenUniversalLink(_ userActivity: NSUserActivity) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: LDWechatShare.shared)
    }
    
    /// 是否安装微信
    ///
    /// - Returns: true: 安装; false: 未安装
    static func isInstall() -> Bool {
        
        return WXApi.isWXAppInstalled()
    }
    
    /// 当前微信版本是否支持OpenAPI
    ///
    /// - Returns: true: 支持; false: 不支持
    class func isSupportApi() -> Bool {
        
        return WXApi.isWXAppSupport()
    }
    
    static func login(_ success: LDWechatShare_loginSuccessClosure? = nil, failsure: LDWechatShare_loginFailClosure? = nil) {
        
        
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "default_state"
        
        WXApi.send(req)
        
        LDWechatShare.shared.successClosure = success
        LDWechatShare.shared.failClosure = failsure
    }
    
}
// MARK: - 支付
enum LDWechatPayResult {
    case Success, Cancel, Failed
}
extension LDWechatShare {
    
    /// 微信支付--发起方法
    ///
    /// - Parameters:
    ///   - identifier: 当有多个页面可能发起微信支付时, 用于标识是哪个控制器发起的微信支付, 来避免多个控制器同时获取支付结果;
    ///   - dic: 吊起微信支付的参数, 一般是直接从服务器获取, 这里的签名参数"sign"是经过二次签名的
    ///   - resultHandle: 支付的结果回调
    class func pay(to identifier: String, _ dic: [String: String], resultHandle: LDWechatShare_payResultHandle? = nil) {
        
        LDWechatShare.shared.payResultHandle = resultHandle
        LDWechatShare.shared.payIdentifier = identifier
        
        let req = PayReq()
        
        req.partnerId = dic["partnerid"]!
        req.prepayId = dic["prepayid"]!
        req.package = dic["package"]!
        req.nonceStr = dic["noncestr"]!
        req.timeStamp = UInt32(dic["timestamp"]!)!
        req.sign = dic["sign"] ?? ""
        
        WXApi.send(req)
    }
}

// MARK: - 分享
enum LDWechatScene {
    case Session, Timeline, Favorite/*会话, 朋友圈, 收藏*/
}
extension LDWechatShare {
    
    class func shareText(_ text: String, to scene: LDWechatScene, resuleHandle: LDWechatShare_resultHandle?) {
        
        let req = SendMessageToWXReq()
        req.text = text
        req.bText = true
        
        switch scene {
        case .Session:
            req.scene = Int32(WXSceneSession.rawValue)
        case .Timeline:
            req.scene = Int32(WXSceneTimeline.rawValue)
        case .Favorite:
            req.scene = Int32(WXSceneFavorite.rawValue)
        }
        
        WXApi.send(req)
        LDWechatShare.shared.isShareSuccess = resuleHandle
    }
    
    class func shareImage(_ data: Data, thumbImage: UIImage? = nil, title: String? = nil, description: String? = nil, to scene: LDWechatScene = .Session, resuleHandle: LDWechatShare_resultHandle? = nil) {
        
        LDWechatShare.shared.isShareSuccess = resuleHandle
        let message = WXMediaMessage()
        // 大小不能超过32k
        message.setThumbImage(thumbImage ?? UIImage())
        message.title = title ?? ""
        message.description = description ?? ""
        
        let obj = WXImageObject()
        // 大小不能超过10M
        obj.imageData = data
        message.mediaObject = obj
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        
        switch scene {
        case .Session:
            req.scene = Int32(WXSceneSession.rawValue)
        case .Timeline:
            req.scene = Int32(WXSceneTimeline.rawValue)
        case .Favorite:
            req.scene = Int32(WXSceneFavorite.rawValue)
        }
        
        
        if Thread.current.isMainThread {
            WXApi.send(req)
        } else {
            DispatchQueue.main.async {
                WXApi.send(req)
            }
        }
    }
    
    class func shareMusic(_ url: String, dataUrl: String? = nil, title: String? = nil, description: String? = nil, thumbImg: UIImage? = nil,to scene: LDWechatScene = .Session, resuleHandle: LDWechatShare_resultHandle? = nil) {
        
        LDWechatShare.shared.isShareSuccess = resuleHandle
        let message = WXMediaMessage()
        message.title = title ?? ""
        message.description = description ?? ""
        message.setThumbImage(thumbImg ?? UIImage())
        
        let obj = WXMusicObject()
        obj.musicUrl = url
        obj.musicLowBandUrl = obj.musicUrl
        
        obj.musicDataUrl = dataUrl ?? ""
        obj.musicLowBandDataUrl = obj.musicDataUrl
        message.mediaObject = obj
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        switch scene {
        case .Session:
            req.scene = Int32(WXSceneSession.rawValue)
        case .Timeline:
            req.scene = Int32(WXSceneTimeline.rawValue)
        case .Favorite:
            req.scene = Int32(WXSceneFavorite.rawValue)
        }
        
        WXApi.send(req)
        
    }
    
    class func shareVideo(_ url: String, lowBandUrl: String? = nil, title: String? = nil, description: String? = nil, thumbImg: UIImage? = nil, to scene: LDWechatScene = .Session, resuleHandle: LDWechatShare_resultHandle? = nil) {
        
        LDWechatShare.shared.isShareSuccess = resuleHandle
        let message = WXMediaMessage()
        message.title = title ?? ""
        message.description = description ?? ""
        message.setThumbImage(thumbImg ?? UIImage())
        
        let obj = WXVideoObject()
        obj.videoUrl = url
        obj.videoLowBandUrl = lowBandUrl ?? ""
        message.mediaObject = obj
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        
        switch scene {
        case .Session:
            req.scene = Int32(WXSceneSession.rawValue)
        case .Timeline:
            req.scene = Int32(WXSceneTimeline.rawValue)
        case .Favorite:
            req.scene = Int32(WXSceneFavorite.rawValue)
        }
        
        WXApi.send(req)
        
    }
    
    class func shareURL(_ url: String, title: String? = nil, description: String? = nil, thumbImg: UIImage? = nil, to scene: LDWechatScene = .Session, resuleHandle: LDWechatShare_resultHandle? = nil) {
        
        LDWechatShare.shared.isShareSuccess = resuleHandle
        let message = WXMediaMessage()
        message.title = title ?? ""
        message.description = description ?? ""
        message.setThumbImage(thumbImg ?? UIImage())
        
        let obj = WXWebpageObject()
        obj.webpageUrl = url
        message.mediaObject = obj
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        
        switch scene {
        case .Session:
            req.scene = Int32(WXSceneSession.rawValue)
        case .Timeline:
            req.scene = Int32(WXSceneTimeline.rawValue)
        case .Favorite:
            req.scene = Int32(WXSceneFavorite.rawValue)
        }
        
        WXApi.send(req)
        
    }
}

//    MARK: - WXApiDelegate
extension LDWechatShare: WXApiDelegate {
    
    func onReq(_ req: BaseReq) {
        
    }
    
    func onResp(_ resp: BaseResp) {
        if resp is SendAuthResp {
            // 微信登录
            let sendRes: SendAuthResp? = resp as? SendAuthResp
            let queue = DispatchQueue(label: "wechatLoginQueue")
            queue.async {
                
                if let sd = sendRes {
                    if sd.errCode == WXSuccess.rawValue {
                        
                        guard (sd.code) != nil else {
                            return
                        }
                        
                        self.requestAccessToken((sd.code)!)
                    } else {
                        
                        DispatchQueue.main.async {
                            if let closure = self.failClosure {
                                closure(sd.errStr)
                            }
                        }
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        if let closure = self.failClosure {
                            closure("授权失败")
                        }
                    }
                }
            }
        } else if resp is SendMessageToWXResp {
            let send = resp as? SendMessageToWXResp
            if let sm = send {
                
                if sm.errCode == WXSuccess.rawValue {

                    if let rs = self.isShareSuccess {
                        rs(true, "分享成功")
                        "分享成功".textShow()
                    }
                } else {
                    if let rs = self.isShareSuccess {
                        rs(false, "分享失败")
                        "分享失败".textShow()
                    }
                }
            }
        } else if resp is PayResp {
            
            // 支付
            var rs: LDWechatPayResult = .Failed
            
            switch resp.errCode {
            case WXSuccess.rawValue:
                rs = .Success
            case WXErrCodeUserCancel.rawValue:
                rs = .Cancel
            default:
                rs = .Failed
            }
            
            if let handle = self.payResultHandle {
                handle(rs, self.payIdentifier)
            }
        }
    }
    
}

//MARK: - 授权登录(异步)
fileprivate extension LDWechatShare {
    
    func requestAccessToken(_ code: String) {
        
        let urlStr = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(self.appID)&secret=\(self.appSecret)&code=\(code)&grant_type=authorization_code"
        
        let url = URL(string: urlStr)
        
        do {
            //                    let responseStr = try String.init(contentsOf: url!, encoding: String.Encoding.utf8)
            
            let responseData = try Data.init(contentsOf: url!, options: Data.ReadingOptions.alwaysMapped)
            
            let dict = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any>
            
            guard let dic = dict else {
                DispatchQueue.main.async {
                    if let closure = self.failClosure {
                        closure("获取授权信息异常")
                    }
                }
                return
            }
            
            guard let accessToken = dic["access_token"] else {
                DispatchQueue.main.async {
                    if let closure = self.failClosure {
                        closure("获取授权信息异常")
                    }
                }
                return
            }
            
            guard let openid = dic["openid"] else {
                DispatchQueue.main.async {
                    if let closure = self.failClosure {
                        closure("获取授权信息异常")
                    }
                }
                return
            }
            
            self.requestUserInfo(accessToken as! String, openID: openid as! String)
        } catch {
            DispatchQueue.main.async {
                if let closure = self.failClosure {
                    closure("获取授权信息异常")
                }
            }
        }
    }
    
    func requestUserInfo(_ accessToken: String, openID: String) {
        
        self.accessToken = accessToken
        let urlStr = "https://api.weixin.qq.com/sns/userinfo?access_token=\(accessToken)&openid=\(openID)"
        
        let url = URL(string: urlStr)
        
        do {
            //                    let responseStr = try String.init(contentsOf: url!, encoding: String.Encoding.utf8)
            
            let responseData = try Data.init(contentsOf: url!, options: Data.ReadingOptions.alwaysMapped)
            
            let dict = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any>
            
            guard let dic = dict else {
                DispatchQueue.main.async {
                    if let closure = self.failClosure {
                        closure("获取授权信息异常")
                    }
                }
                
                return
            }
            
            self.userInfoFromDic(dic)
        } catch {
            DispatchQueue.main.async {
                if let closure = self.failClosure {
                    closure("获取授权信息异常")
                }
            }
        }
    }
    
    func userInfoFromDic(_ dic: Dictionary<String, Any>) {
        
        var info: [String: Any] = [:]
        
        info["rawData"] = dic
        
        if let openid = dic["openid"] as? String {
            // 普通用户的标识，对当前开发者帐号唯一
            info["openid"] = openid
        }
        
        if let unionid = dic["unionid"] as? String {
            //unionid 用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的unionid是唯一的
            info["uid"] = unionid
        }
        
        if let nickname = dic["nickname"] as? String {
            info["nickname"] = nickname
        }
        
        if let sex = dic["sex"] as? Int {
            info["sex"] = sex == 1 ? "男": "女"
        }
        
        if let headimgurl = dic["headimgurl"] as? String {
            info["headimgurl"] = headimgurl
        }
        
        DispatchQueue.main.async {
            if let closure = self.successClosure {
                
                closure(info)
            }
        }
    }
}
