//
//  AppDelegate.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/22.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import IQKeyboardManagerSwift
import Kingfisher
import ObjectMapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, JPUSHRegisterDelegate, WXApiDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //键盘
        IQKeyboardManager.shared.enable = true // 控制整个功能是否启用
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true // 控制点击背景是否收起键盘
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 50 // 输入框距离键盘的距离
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        //window
        window = UIWindow(frame: UIScreen.main.bounds)
        // 屏蔽13系统以后的暗黑模式
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        window?.backgroundColor = UIColor.white
//        let nav = BaseNavigationController.init(rootViewController: ZBBBTVC())
//        window?.rootViewController = BaseNavigationController.init(rootViewController: ZBBLoginViewController())
//        window?.rootViewController = MainViewController()
        selectTestEnvironment()
        window?.makeKeyAndVisible()
        
//        if let vluueStr = UserDefaults.standard.object(forKey: "AppStartPage")  as? String {
//            let backImg = UIImageView()
//            backImg.contentMode = .scaleAspectFill
//            backImg.cornerRadius(0).masksToBounds()
//            if let imageUrl = URL(string: APIURL.ossPicUrl + vluueStr) {
//                backImg.kf.setImage(with: imageUrl, placeholder: UIImage())
//            } else {
//                backImg.image = UIImage()
//            }
//            window?.addSubview(backImg)
//
//            backImg.snp.makeConstraints { (make) in
//                make.edges.equalToSuperview()
//            }
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
//
//                //选择测试环境
//                self.selectTestEnvironment()
//                backImg.removeFromSuperview()
//            }
//        }else {
//            //选择测试环境
//            selectTestEnvironment()
//        }
//        ///极光IM
//        // 关闭SDK的日志
//        JMessage.setLogOFF()
////        JMessage.setDebugMode()
//        
//        //极光 设置
//        ///极光推送
//        // 关闭SDK的日志
//        JPUSHService.setLogOFF()
//       // JPUSHService.setDebugMode()
//        /// Required - 启动 JMessage SDK  启动 JPush SDK
//        if APIURL.environmentType != .online {
//            //高德地图 jcdios-test
//            AMapServices.shared().apiKey = "3517ca1bf6aae135bae47d3a05e6c9ab"
//            //极光
//            let jIMKey = "318e8bbb7a997b30d55341ad"
//           // let jmKey = "14adfb24c5326d1ff0e33d8e"
//            JMessage.setupJMessage(launchOptions, appKey: jIMKey, channel: "test", apsForProduction: false, category: nil, messageRoaming: true)
//            JPUSHService.setup(withOption: launchOptions, appKey: jIMKey, channel: "test", apsForProduction: false)
//        }else {
//            //高德地图
//            AMapServices.shared().apiKey = "d14a5407d320cc98c7f680999bb721b1"
//            //极光
//            let jmKey = "092aec02f7efdd052e94c0aa"
//            JMessage.setupJMessage(launchOptions, appKey: jmKey, channel: "App Store", apsForProduction: true, category: nil, messageRoaming: true)
//            JPUSHService.setup(withOption: launchOptions, appKey: jmKey, channel: "App Store", apsForProduction: true)
//        }
//
//        let entity = JPUSHRegisterEntity()
//        if #available(iOS 12.0, *) {
//            entity.types = 1 << 0 | 1 << 1 | 1 << 2 | 1 << 5
//        } else {
//            entity.types = 1 << 0 | 1 << 1 | 1 << 2
//        }
//        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
//
//        //获取registrationID
//        JPUSHService.registrationIDCompletionHandler { (resCode, registrationID) in
//
//            let deviceId = registrationID ?? "1a1018970ac7c78a1d7"
//            AppLog("registrationID:\(deviceId)")
//            UserData.shared.registrationId = deviceId
//        }
//    
//        // Required - 注册 APNs 通知
//        JMessage.register(forRemoteNotificationTypes: UNAuthorizationOptions.badge.rawValue |
//            UNAuthorizationOptions.sound.rawValue |
//            UNAuthorizationOptions.alert.rawValue, categories: nil)
        
        
        
        return true
    }
    
    func regiestTestSharePlatform() {
        LDWechatShare.registeApp("wxdf2026ea53f20b46", universalLink: "https://test.jcdcbm.com/", appSecret: "249b1475f8e1bf885cfd62ea2b7e979a")
        //LDTencentShare.registeApp("101488246", appKey: "35e87f38da45a50d946e8e74a1563c78")
        LDSinaShare.registeApp("3206767916", appSecret: "28a0726ceffd228593075cff2d8b89b3", oredirectUri: "新浪微博授权回调URI")
    }
    
    func regiestSharePlatform() {
        LDWechatShare.registeApp("wx6de7f1609a73e17d", universalLink: "https://www.jcdcbm.com/", appSecret: "5f296dad17806fb64eb7e9024b1862fc")
        //LDTencentShare.registeApp("101488246", appKey: "35e87f38da45a50d946e8e74a1563c78")
        LDSinaShare.registeApp("3206767916", appSecret: "28a0726ceffd228593075cff2d8b89b3", oredirectUri: "新浪微博授权回调URI")
    }
    
    //MARK: - 选择测试环境
    func selectTestEnvironment() {
        
        //获取用户本地信息
        AppUtils.getLocalUserData()
//        AppUtils.cleanUserData()
        
//        if APIURL.environmentType == .test {
//            let popup = PopupDialog(title: "请选择测试环境", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
//            
//            let cancelBtn = AlertButton(title: "测试") {
//                self.regiestTestSharePlatform()
//                AppData.isBaseDataLoaded = false
//                APIURL.serverUrl = APIURL.serverTest
//                APIURL.ossPicUrl = APIURL.ossPicTest
//                APIURL.webUrl = APIURL.webTest
//                APIURL.jzUrl = APIURL.jzTest
//                APIURL.gysUrl = APIURL.gysTest
//                APIURL.zfUrl = APIURL.zfTest
//                self.setRootVC()
//            }
//            let sureBtn = AlertButton(title: "预生产") {
//                self.regiestTestSharePlatform()
//                AppData.isBaseDataLoaded = false
//                APIURL.serverUrl = APIURL.serverPre
//                APIURL.ossPicUrl = APIURL.ossPicTest
//                APIURL.webUrl = APIURL.webPre
//                APIURL.jzUrl = APIURL.jzTest
//                APIURL.gysUrl = APIURL.gysPre
//                APIURL.zfUrl = APIURL.zfPre
//                self.setRootVC()
//            }
//            let regulationBtn = AlertButton(title: "正式") {
//                self.regiestSharePlatform()
//                AppData.isBaseDataLoaded = false
//                APIURL.serverUrl = APIURL.serverOnline
//                APIURL.ossPicUrl = APIURL.ossPicOnline
//                APIURL.webUrl = APIURL.webOnline
//                APIURL.jzUrl = APIURL.jzOnline
//                APIURL.gysUrl = APIURL.gysOnline
//                APIURL.zfUrl = APIURL.zfOnline
//                self.setRootVC()
//            }
//            popup.addButtons([cancelBtn, sureBtn,regulationBtn])
//            window?.rootViewController?.present(popup, animated: true, completion: nil)
//        }  else if APIURL.environmentType == .pre {
//            regiestTestSharePlatform()
//            APIURL.serverUrl = APIURL.serverPre
//            APIURL.ossPicUrl = APIURL.ossPicTest
//            APIURL.webUrl = APIURL.webPre
//            APIURL.jzUrl = APIURL.jzTest
//            APIURL.gysUrl = APIURL.gysPre
//            APIURL.zfUrl = APIURL.zfPre
//            setRootVC()
//        } else if APIURL.environmentType == .online {
//            regiestSharePlatform()
//            APIURL.serverUrl = APIURL.serverOnline
//            APIURL.ossPicUrl = APIURL.ossPicOnline
//            APIURL.webUrl = APIURL.webOnline
//            APIURL.jzUrl = APIURL.jzOnline
//            APIURL.gysUrl = APIURL.gysOnline
//            APIURL.zfUrl = APIURL.zfOnline
//            setRootVC()
//        }
        setRootVC()
        //获取基础数据
        if let dic = UserDefaults.standard.object(forKey: "baseData") as? NSDictionary {
            AppUtils.getBaseInfo(resData: dic)
            AppData.isBaseDataLoaded = false
        }
    }
    
    func setRootVC() {
//        let isFristOpen = UserDefaults.standard.object(forKey: "isFristOpenApp")
//        if isFristOpen == nil {
//            window?.rootViewController = GuideViewController()
//            UserDefaults.standard.set("isFristOpenApp", forKey: "isFristOpenApp")
//        } else {
            let tokenModel = UserDefaults.standard.object(forKey: UserDefaultStr.tokenModel)
            if let tokenModel = tokenModel {
                UserData1.shared.tokenModel = Mapper<TokenModel1>().map(JSON: tokenModel as! [String: Any])
            }
            window?.rootViewController = MainViewController()
//        }
    }

    //MARK: - 极光IM，推送
    //注册 DeviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JMessage.registerDeviceToken(deviceToken)
    }
    
    //实现注册APNs失败接口
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //可选
        NSLog("did Fail To Register For Remote Notifications With Error: \(error)")
    }
    
    //MARK: - 通知处理
    
    //前台得到的的通知对象
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {

        let userInfo = notification.request.content.userInfo
        AppLog(userInfo as! [String: Any])

        if notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }

        if let type = userInfo["_j_type"] as? String {

            if type == "jmessage" {//聊天消息在前台时不弹推送
                completionHandler(Int(UNNotificationPresentationOptions.sound.rawValue))

                NotificationCenter.default.post(name: Notification.Name.init("ReceiveNotification"), object: nil, userInfo: ["msgType": "聊天"])
            }
        }else {

            if let msgType = userInfo["messageType"] as? String {

                if msgType == "待办" {
                    completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
                }else if msgType == "通知" {
                    //需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
                    completionHandler(Int(UNNotificationPresentationOptions.sound.rawValue))
                }

                NotificationCenter.default.post(name: Notification.Name.init("ReceiveNotification"), object: nil, userInfo: ["msgType": msgType])
            }else {
                completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
            }
        }
    }
    
    ///从通知界面进入前台后调用
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {

        let userInfo = response.notification.request.content.userInfo
        AppLog(userInfo as! [String: Any])

        if response.notification.request.trigger is UNPushNotificationTrigger {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        // 系统要求执行这个方法
        completionHandler()

        //返回根控制器
        goBackRootViewController(userInfo)
    }
    
    ///处理跳转
    func setWhowVC(_ userInfo: [AnyHashable: Any]) {

//        if let tabbarVC = window?.rootViewController as? UITabBarController {
//
//            tabbarVC.selectedIndex = 0
//
//            if let naVC = tabbarVC.selectedViewController as? UINavigationController {
//
//                if let vc = naVC.topViewController as? ChatViewController {
//
//                    if let type = userInfo["_j_type"] as? String {
//
//                        if type == "jmessage" {//聊天消息
//
//                            if vc.changeTitleView.segmentView.selectedSegmentIndex == 1 {
//
//                                vc.changeTitleView.segmentView.selectedSegmentIndex = 0
//                                vc.changeTitleView.selectItemIndex?(0)
//                            }
//                        }
//                    }else {
//
//                        if let msgType = userInfo["messageType"] as? String {
//
//                            if msgType == "待办" {
//
//                                if vc.changeTitleView.segmentView.selectedSegmentIndex == 0 {
//
//                                    vc.changeTitleView.segmentView.selectedSegmentIndex = 1
//                                    vc.changeTitleView.selectItemIndex?(1)
//                                    vc.changeTitleView.unReadView2.isHidden = true
//                                }
//
//                                vc.pleaseWait()
//                                vc.headerRefresh()
//
//                            }else if msgType == "通知" {
//
//                                if vc.changeTitleView.segmentView.selectedSegmentIndex == 1 {
//
//                                    vc.changeTitleView.segmentView.selectedSegmentIndex = 0
//                                    vc.changeTitleView.selectItemIndex?(0)
//                                }
//
//                                var detailUrl = ""
//                                if let valueStr = userInfo["id"] as? String {
//                                    detailUrl = APIURL.msgDetail + valueStr
//                                }
//
//                                let detailVC = BrandDetailController()
//                                detailVC.title = "通知详情"
//                                detailVC.detailUrl = detailUrl
//                                vc.navigationController?.pushViewController(detailVC, animated: true)
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
    ///返回根控制器
    func goBackRootViewController(_ userInfo: [AnyHashable: Any]) {

        let currentVC = UIViewController.getCurrentVC()

        if currentVC?.presentingViewController != nil {

            var rootVC = currentVC?.presentingViewController
            while (rootVC?.presentingViewController != nil) {
                rootVC = rootVC?.presentingViewController
            }
            rootVC?.dismiss(animated: false, completion: {
                let vc = UIViewController.getCurrentVC()
                vc?.navigationController?.popToRootViewController(animated: false)
                self.setWhowVC(userInfo)
            })

        }else {
            currentVC?.navigationController?.popToRootViewController(animated: false)
            setWhowVC(userInfo)
        }
    }

    //ios12新特性 通知管理
    @available(iOS 12.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification?) {

        if (notification != nil) && (notification?.request.trigger?.isKind(of: UNPushNotificationTrigger.self))! {

        }else{

        }
    }

    //点推送进来执行这个方法
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // 将要进入后台
        if let unreadCount = UserDefaults.standard.object(forKey: "unreadCount") as? Int {
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
            JMessage.setBadge(unreadCount)
            JPUSHService.setBadge(unreadCount)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        JPUSHService.setBadge(0)
        JMessage.setBadge(0)
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    /// 分享回调
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        AppLog(url.absoluteString)
        AppLog(url.scheme)
        if url.host == "safepay" {
            AlipaySDK().processAuth_V2Result(url) { (back) in
                AliPayUtils.loginBack(resultDic: back! as [NSObject: AnyObject])
            }
            return true
        }
        if url.scheme == "jcdCompany" {
            NotificationCenter.default.post(name: NSNotification.Name.init("unionpaysResult"), object: nil)
            return true
        }
        if let urlKey: String = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String {
            if urlKey == "com.tencent.xin"
            {
                // 微信 的回调
                return LDWechatShare.handle(url)
            } else if urlKey == "com.tencent.mqq" {
                // QQ 的回调
              //  return LDTencentShare.handle(url)
            } else if urlKey == "com.sina.weibo" {
                // 新浪微博 的回调
               // return LDSinaShare.handle(url)
            }
        }
        return Pingpp.handleOpen(url, withCompletion: nil)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        switch url.scheme {
        case "aliauth":
            AlipaySDK().processAuth_V2Result(url) { (back) in
                AliPayUtils.loginBack(resultDic: back! as [NSObject: AnyObject])
            }
            return true
        default:
            return WXApi.handleOpen(url, delegate: self)
        }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // 这里的URL Schemes是配置在 info -> URL types中, 添加的新浪微博的URL schemes
        // 例如: 你的新浪微博的AppKey为: 123456789, 那么这个值就是: wb123456789
        if url.scheme == "wx6de7f1609a73e17d" {
            return LDWechatShare.handle(url)
        } else if url.scheme == "wb2267950711" {
          //  return LDSinaShare.handle(url)
        } else if url.scheme == "aliauth" {
            AlipaySDK().processAuth_V2Result(url) { (back) in
                AliPayUtils.loginBack(resultDic: back! as [NSObject: AnyObject])
            }
        }
        return true
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return LDWechatShare.handleOpenUniversalLink(userActivity)
    }
    
//    func onReq(_ req: BaseReq) {
//
////        if req.isKind(of: GetMessageFromWXReq.self) {
////            let strTitle = "微信请求App提供内容"
////            let strMsg = "微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信"
////            let alert = UIAlertController.init(title: strTitle, message: strMsg, preferredStyle: .alert)
////            alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (aciton) in
////            }))
////            window?.rootViewController?.present(alert, animated: true, completion: nil)
////        } else if req.isKind(of: ShowMessageFromWXReq.self) {
////            let temp = req as! ShowMessageFromWXReq
////            let message = temp.message
////            let obj = message.mediaObject as! WXAppExtendObject
////            //显示微信传过来的内容
////            let strTitle = "微信请求App显示内容"
////            let strMsg = "标题：\(message.title) \n内容：\(message.description) \n附带信息：\(obj.extInfo ?? "") \n缩略图:\(message.thumbData?.count ?? 0) bytes\n\n"
////            let alert = UIAlertController.init(title: strTitle, message: strMsg, preferredStyle: .alert)
////            alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (aciton) in
////            }))
////            window?.rootViewController?.present(alert, animated: true, completion: nil)
////        } else if req.isKind(of: LaunchFromWXReq.self) {
////            let strTitle = "从微信启动"
////            let strMsg = "这是从微信启动的消息"
////            //显示微信传过来的内容
////            let alert = UIAlertController.init(title: strTitle, message: strMsg, preferredStyle: .alert)
////            alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (aciton) in
////            }))
////            window?.rootViewController?.present(alert, animated: true, completion: nil)
////        }
//    }
//
//    func onResp(_ resp: BaseResp) {
//        if resp.isKind(of: SendMessageToWXResp.self) {
//            let strMsg = "errorcode: \(resp.errCode)"
//            if resp.errCode == 0 {
//                let alert = UIAlertController.init(title: "分享成功", message: nil, preferredStyle: .alert)
//                alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (aciton) in
//                }))
//                window?.rootViewController?.present(alert, animated: true, completion: nil)
//            } else {
//                //显示微信传过来的内容
//                let alert = UIAlertController.init(title: "提示", message: strMsg, preferredStyle: .alert)
//                alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (aciton) in
//                }))
//                window?.rootViewController?.present(alert, animated: true, completion: nil)
//            }
//        }
//    }
}

