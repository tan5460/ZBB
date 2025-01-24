////
////  LDTencentShare.swift
////  CGYC
////
////  Created by Artron_LQQ on 2017/6/8.
////  Copyright © 2017年 Artup. All rights reserved.
////
///* 简书博客: http://www.jianshu.com/u/2846c3d3a974
// Github: https://github.com/LQQZYY
//
// demo地址: https://github.com/LQQZYY/LDThirdShare-Swift
// 博文讲解: http://www.jianshu.com/p/c8db82d27b11
// */
//
//import UIKit
//
//typealias LDTencentShare_loginFailedhandle = (_ error: String) -> Void
//typealias LDTencentShare_loginSuccessHandle = (_ info: [String: Any]) -> Void
//typealias LDTencentShare_resultHandle = (_ isSuccess: Bool, _ description: String) -> Void
//class LDTencentShare: NSObject {
//
//    static var shared: LDTencentShare = LDTencentShare()
//    private override init() { }
//
//    fileprivate var appID: String = ""
//    fileprivate var appKey: String = ""
//    fileprivate var accessToken: String = ""
//    fileprivate var tencentAuth: TencentOAuth!
//    fileprivate var loginSuccess: LDTencentShare_loginSuccessHandle? = nil
//    fileprivate var loginFailsure: LDTencentShare_loginFailedhandle? = nil
//    fileprivate var shareResult: LDTencentShare_resultHandle? = nil
//
//    /// 是否安装QQ客户端
//    ///
//    /// - Returns: true: 安装; false: 未安装
//    class func isQQInstall() -> Bool {
//
//        return TencentOAuth.iphoneQQInstalled()
//    }
//
//    /// QQ是否支持SSO授权登录
//    ///
//    /// - Returns: true: 支持; false: 不支持
//    class func isQQSupportSSO() -> Bool {
//        return TencentOAuth.iphoneQQSupportSSOLogin()
//    }
//
//    /// 是否安装QZone客户端
//    ///
//    /// - Returns: true: 安装; false: 未安装
//    class func isQZoneIstall() -> Bool {
//        return TencentOAuth.iphoneQZoneInstalled()
//    }
//
//    /// Qzone是否支持SSO授权登陆
//    ///
//    /// - Returns: true: 支持; false: 不支持
//    class func isQZoneSupportSSO() -> Bool {
//        return TencentOAuth.iphoneQZoneSupportSSOLogin()
//    }
//
//    class func registeApp(_ appID: String, appKey: String) {
//
//        LDTencentShare.shared.appID = appID
//        LDTencentShare.shared.appKey = appKey
//        LDTencentShare.shared.tencentAuth = TencentOAuth(appId: appID, andDelegate: LDTencentShare.shared)
//    }
//
//    class func handle(_ url: URL) -> Bool {
//
//        // host: qzapp ; schem: tencent1105013800
//        // response_from_qq    tencent1105013800
//
//        if url.host == "qzapp" {
//            // QQ授权登录
//            return TencentOAuth.handleOpen(url)
//        } else if url.host == "response_from_qq" {
//            // QQ 分享
//            return QQApiInterface.handleOpen(url, delegate: LDTencentShare.shared)
//        }
//
//        return  true
//    }
//
//    class func login(_ success: LDTencentShare_loginSuccessHandle? = nil, failsure: LDTencentShare_loginFailedhandle? = nil) {
//
//        // 需要获取的用户信息
//        let permissions = [kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
//        LDTencentShare.shared.tencentAuth.authorize(permissions)
//
//        LDTencentShare.shared.loginSuccess = success
//        LDTencentShare.shared.loginFailsure = failsure
//    }
//
//
//}
////MARK: - 分享
//enum LDTencentFlag {
//    //  QQl列表 收藏。     电脑。     空间。   禁止分享到空间
//    case QQ, Favorites, Dataline, QZone, QZoneForbid
//}
//extension LDTencentShare {
//
//    class func shareVideo(_ url: URL, preImgUrl: URL? = nil, title: String, description: String? = nil, flag: LDTencentFlag = .QQ, shareResultHandle: LDTencentShare_resultHandle? = nil) {
//
//        LDTencentShare.shared.shareResult = shareResultHandle
//        let obj = QQApiVideoObject(url: url, title: title, description: description, previewImageURL: preImgUrl, targetContentType: QQApiURLTargetTypeVideo)
//
//        switch flag {
//        case .QQ:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShare)
//        case .Favorites:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShareFavorites)
//        case .Dataline:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShareDataline)
//        case .QZone:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareOnStart)
//        case .QZoneForbid:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareForbid)
//        }
//
//        let req = SendMessageToQQReq(content: obj)
//
//        // 分享到QZone
//        if flag == .QZone {
//            QQApiInterface.sendReq(toQZone: req)
//        } else {
//            // 分享到QQ
//            QQApiInterface.send(req)
//        }
//    }
//
//    class func shareMusic(_ url: URL, title: String, description: String, preImgUrl: URL? = nil, flag: LDTencentFlag = .QQ, shareResultHandle: LDTencentShare_resultHandle? = nil) {
//
//        LDTencentShare.shared.shareResult = shareResultHandle
//        let obj = QQApiAudioObject(url: url, title: title, description: description, previewImageURL: preImgUrl, targetContentType: QQApiURLTargetTypeAudio)
//        //        let obj = QQApiAudioObject(url: URL!, title: String!, description: String!, previewImageData: Data!, targetContentType: QQApiURLTargetType)
//
//        switch flag {
//        case .QQ:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShare)
//        case .Favorites:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShareFavorites)
//        case .Dataline:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShareDataline)
//        case .QZone:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareOnStart)
//        case .QZoneForbid:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareForbid)
//        }
//
//        let req = SendMessageToQQReq(content: obj)
//
//        // 分享到QZone
//        if flag == .QZone {
//            QQApiInterface.sendReq(toQZone: req)
//        } else {
//            // 分享到QQ
//            QQApiInterface.send(req)
//        }
//    }
//
//    class func shareNews(_ url: URL, preUrl: URL? = nil, title: String? = nil, description: String? = nil, flag: LDTencentFlag = .QQ, shareResultHandle: LDTencentShare_resultHandle? = nil) {
//
//        LDTencentShare.shared.shareResult = shareResultHandle
//        let obj = QQApiNewsObject(url: url, title: title, description: description, previewImageURL: preUrl, targetContentType: QQApiURLTargetTypeNews)
//
//        switch flag {
//        case .QQ:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShare)
//        case .Favorites:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShareFavorites)
//        case .Dataline:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQQShareDataline)
//        case .QZone:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareOnStart)
//        case .QZoneForbid:
//            obj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareForbid)
//        }
//
//        let req = SendMessageToQQReq(content: obj)
//
//        // 分享到QZone
//        if flag == .QZone {
//            QQApiInterface.sendReq(toQZone: req)
//        } else {
//            // 分享到QQ
//            QQApiInterface.send(req)
//        }
//    }
//
//    class func shareImages(_ images: [Data], preImage: Data? = nil, title: String? = nil, description: String? = nil, shareResultHandle: LDTencentShare_resultHandle? = nil) {
//        LDTencentShare.shared.shareResult = shareResultHandle
//        // 多图不支持分享到QQ, 如果设置, 默认分享第一张
//        // k可以分享多图到QQ收藏
//        guard images.count > 0 else {
//            return
//        }
//
//        let imgObj = QQApiImageObject(data: images.first, previewImageData: preImage, title: title, description: description, imageDataArray: images)
//
//        imgObj?.cflag = UInt64(kQQAPICtrlFlagQQShareFavorites)
//        let req = SendMessageToQQReq(content: imgObj)
//
//        if Thread.current.isMainThread {
//            QQApiInterface.send(req)
//        } else {
//            DispatchQueue.main.async {
//                QQApiInterface.send(req)
//            }
//        }
//    }
//
//    class func shareImage(_ imgData: Data, thumbData: Data? = nil, title: String? = nil, description: String? = nil, flag: LDTencentFlag = .QQ, shareResultHandle: LDTencentShare_resultHandle? = nil) {
//
//        LDTencentShare.shared.shareResult = shareResultHandle
//        // 原图 最大5M
//        // 预览图 最大 1M
//        let imgObj = QQApiImageObject(data: imgData, previewImageData: thumbData, title: title, description: description)
//
//        switch flag {
//        case .QQ:
//            imgObj?.cflag = UInt64(kQQAPICtrlFlagQQShare)
//        case .Favorites:
//            imgObj?.cflag = UInt64(kQQAPICtrlFlagQQShareFavorites)
//        case .Dataline:
//            imgObj?.cflag = UInt64(kQQAPICtrlFlagQQShareDataline)
//        case .QZone:
//            imgObj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareOnStart)
//        case .QZoneForbid:
//            imgObj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareForbid)
//
//        }
//
//        let req = SendMessageToQQReq(content: imgObj)
//
//        if Thread.current.isMainThread {
//
//            if flag == .QZone {
//                QQApiInterface.sendReq(toQZone: req)
//            } else {
//                QQApiInterface.send(req)
//            }
//        } else {
//
//            DispatchQueue.main.async {
//
//                if flag == .QZone {
//                    QQApiInterface.sendReq(toQZone: req)
//                } else {
//                    QQApiInterface.send(req)
//                }
//            }
//        }
//    }
//
//    class func shareText(_ text: String, flag: LDTencentFlag = .QQ, shareResultHandle: LDTencentShare_resultHandle? = nil) {
//
//        LDTencentShare.shared.shareResult = shareResultHandle
//        let textObj = QQApiTextObject(text: text)
//        textObj?.shareDestType = ShareDestTypeQQ // 分享到QQ 还是TIM, 必须指定
//
//        switch flag {
//        case .QQ:
//            textObj?.cflag = UInt64(kQQAPICtrlFlagQQShare)
//        case .Favorites:
//            textObj?.cflag = UInt64(kQQAPICtrlFlagQQShareFavorites)
//        case .Dataline:
//            textObj?.cflag = UInt64(kQQAPICtrlFlagQQShareDataline)
//        case .QZone:
//            textObj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareOnStart)
//        case .QZoneForbid:
//            textObj?.cflag = UInt64(kQQAPICtrlFlagQZoneShareForbid)
//
//        }
//
//        let req = SendMessageToQQReq(content: textObj)
//        req?.message = textObj
//        QQApiInterface.send(req)
//    }
//}
////    MARK: - QQApiInterfaceDelegate
//extension LDTencentShare: QQApiInterfaceDelegate {
//
//    func onReq(_ req: QQBaseReq!) {
//
//    }
//
//    func onResp(_ resp: QQBaseResp!) {
//
//        if resp is SendMessageToQQResp {
//            let rs = resp as! SendMessageToQQResp
//            if rs.type == 2 {
//                // QQ分享返回的回调
//                if rs.result == "0" {
//                    // 分享成功
//                    if let rs = self.shareResult {
//                        rs(true, "分享成功")
//                    }
//                } else if rs.result == "-4" {
//
//                    if let rs = self.shareResult {
//                        rs(false, "取消分享")
//                    }
//                } else {
//                    if let rs = self.shareResult {
//                        rs(false, "分享失败")
//                    }
//                }
//            }
//        }
//    }
//
//    func isOnlineResponse(_ response: [AnyHashable : Any]!) {
//
//    }
//}
//
////    MARK: - TencentSessionDelegate
//extension LDTencentShare: TencentSessionDelegate {
//
//    func tencentDidLogin() {
//
//        self.tencentAuth.getUserInfo()
//        if let accessToken = self.tencentAuth.accessToken {
//            // 获取accessToken
//            self.accessToken = accessToken
//        }
//    }
//
//    func tencentDidNotNetWork() {
//        if let closure = self.loginFailsure {
//            closure("网络异常")
//        }
//    }
//
//    func tencentDidNotLogin(_ cancelled: Bool) {
//
//        if cancelled {
//            // 用户取消登录
//            if let closure = self.loginFailsure {
//                closure("用户取消登录")
//            }
//        } else {
//            // 登录失败
//            if let closure = self.loginFailsure {
//                closure("登录失败")
//            }
//        }
//    }
//
//    func getUserInfoResponse(_ response: APIResponse!) {
//
//        let queue = DispatchQueue(label: "aaLoginQueue")
//        queue.async {
//
//            if response.retCode == 0 {
//
//                if let res = response.jsonResponse {
//
//                    var info: [String: Any] = [:]
//
//                    info["rawData"] = res as? Dictionary<String, Any>
//
//                    if let uid = self.tencentAuth.getUserOpenID() {
//                        info["uid"] = uid
//                    }
//
//                    if let name = res["nickname"] as? String {
//                        info["nickName"] = name
//                    }
//
//                    if let sex = res["gender"] as? String {
//                        info["sex"] = sex
//                    }
//
//                    if let img = res["figureurl_qq_2"] as? String {
//                        info["advatarStr"] = img
//                    }
//
//                    DispatchQueue.main.async {
//                        if let closure = self.loginSuccess {
//
//                            closure(info)
//                        }
//                    }
//                }
//            } else {
//                DispatchQueue.main.async {
//                    if let closure = self.loginFailsure {
//                        closure("获取授权信息异常")
//                    }
//                }
//            }
//        }
//    }
//}
