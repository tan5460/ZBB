//
//  MainViewController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/22.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import Eureka
import PopupDialog
import ObjectMapper
import Kingfisher


class MainViewController: UITabBarController, UITabBarControllerDelegate, MainTabBarDelegate {
    
    private var activityIconImg: String?
    private var activeMyIconImg: String?
    private var notActiveMyIconImg: String?
    
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("\(type(of: self).className) 释放了")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTabBar()
        self.createSubController()
        self.delegate = self
        self.loadRenewUserBase()
        self.selectedIndex = 0
                
        //添加进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(loadRenewUserBase), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    
    private func setupTabBar() {
        tabBar.isTranslucent = false
        let normalColor: UIColor = PublicColor.minorTextColor
        let selectedColor: UIColor = #colorLiteral(red: 0.1529411765, green: 0.6352941176, blue: 0.4901960784, alpha: 1)
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            let normal = appearance.stackedLayoutAppearance.normal
            normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: normalColor]
            let selected = appearance.stackedLayoutAppearance.selected
            selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: selectedColor]
            self.tabBar.standardAppearance = appearance
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: normalColor], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedColor], for: .selected)
        }
    }
    
    
    
    /// 通知调用方法
    @objc private func loadRenewUserBase() {
        //获取基础数据
        YZBSign.shared.getBaseInfo()
        //获取版本号
        LoadRenew()
        //获取用户信息
        refreshUserData()
    }
    
    private func createSubController() {
//        switch UserData.shared.userType {
//        case .jzgs:
//            setupJZGSViewController()
//        case .cgy:
            setupCGYViewController()
//        case .gys, .yys:
//            setupGYSViewController()
//        case .fws:
//            setupFWSViewController()
//        }
    }
    
    private func setupJZGSViewController() {
        let v1 = setController(HomeVC(), imageName: "home", selectImgName: "home_sel", title: "首页", tag: 0)
        let v2 = setController(ServiceMallVC(), imageName: "search", selectImgName: "search_sel", title: "找服务", tag: 1)
        let v3 = setController(StoreViewController(), imageName: "search_jj", selectImgName: "search_jj_sel", title: "找家居", tag: 2)
        let v4 = setController(ShopCartViewController(), imageName: "shopping", selectImgName: "shopping_sel", title: "购物车", tag: 3)
        let v5 = setController(MyCenterVC(), imageName: "mycenter", selectImgName: "mycenter_sel", title: "我的", tag: 4)
        self.viewControllers = [v1, v2, v3, v4, v5]
    }
    
    private func setupCGYViewController() {
        //UIDocumentPickerViewController.self
        tabBar.layerShadow()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
//        let v1 = setController(PurchaseHomeVC(), imageName: "home", selectImgName: "home_sel", title: "首页", tag: 0)
        let v1 = setController(ZBBHomeViewController(), imageName: "home", selectImgName: "home_sel", title: "首页", tag: 0)
//        let v2 = setController(ServiceMallVC(), imageName: "mall", selectImgName: "mall_sel", title: "服务商城", tag: 1)
        let v3 = setController(StoreViewController(), imageName: "shop", selectImgName: "shop_sel", title: "商城", tag: 2)
        let v4 = setController(WantPurchaseController(), imageName: "shopping", selectImgName: "shopping_sel", title: "购物车", tag: 3)
        let v5 = setController(ZBBMyViewController(), imageName: "me", selectImgName: "me_sel", title: "我的", tag: 4)
        
        self.viewControllers = [v1, v3, v4, v5]
    }
 
    private func setupGYSViewController() {
        
        tabBar.layerShadow()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
        let ms = MaterialSearchController()
        ms.brandNameIsNeeded = false
        
        let v1 = setController(ChatViewController(), imageName: "message", selectImgName: "message_sel", title: "消息", tag: 0)
        let v2 = setController(ms, imageName: "shop", selectImgName: "shop_sel", title: "商城", tag: 1)
        let v3 = setController(PurchaseViewController(), imageName: "purchase", selectImgName: "purchase_sel", title: "采购订单", tag: 2)
        let v4 = setController(MyPurchaseController(), imageName: "me", selectImgName: "me_sel", title: "我的", tag: 3)
        
        self.viewControllers = [v1, v2, v3, v4]
    }
    
    
    private func setupFWSViewController() {
        
        tabBar.layerShadow()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
        let v1 = setController(ChatViewController(), imageName: "service_mall_tabbar_xx_0", selectImgName: "service_mall_tabbar_xx_1", title: "消息", tag: 0)
        let v2 = setController(ServiceOrderVC(), imageName: "service_mall_tabbar_dd_0", selectImgName: "service_mall_tabbar_dd_1", title: "订单", tag: 1)
        let v3 = setController(ServiceMallServiceManagerVC(), imageName: "service_mall_tabbar_fw_0", selectImgName: "service_mall_tabbar_fw_1", title: "服务", tag: 2)
        let v4 = setController(ServiceMallCenterVC(), imageName: "service_mall_tabbar_wd_0", selectImgName: "service_mall_tabbar_wd_1", title: "我的", tag: 3)
        
        self.viewControllers = [v1, v2, v3, v4]
    }
    
    private func setupYYSViewController() {
        
        tabBar.layerShadow()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
        let v1 = setController(ChatViewController(), imageName: "message", selectImgName: "message_sel", title: "消息", tag: 0)
        let v2 = setController(PurchaseViewController(), imageName: "purchase", selectImgName: "purchase_sel", title: "采购订单", tag: 1)
        let v3 = setController(MyPurchaseController(), imageName: "me", selectImgName: "me_sel", title: "我的", tag: 2)
        
        self.viewControllers = [v1, v2, v3]
    }
    
    private func setController(_ vc: UIViewController, imageName: String, selectImgName: String, title: String, tag: Int) -> BaseNavigationController {
        
        let img = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        let selectImg = UIImage(named: selectImgName)?.withRenderingMode(.alwaysOriginal)
        vc.tabBarItem = UITabBarItem(title: title, image: img, selectedImage: selectImg)
        vc.tabBarItem.tag = tag

        return BaseNavigationController(rootViewController: vc)
    }
    
    //MARK: -  UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if let vcNav = viewController as? BaseNavigationController {
            
            if UserData1.shared.tokenModel == nil, let index = tabBarController.viewControllers?.firstIndex(of: vcNav), (index == 2 || index == 3) {
                ToolsFunc.showLoginVC()
                return false
            }
            
            if UserData.shared.userType == .jzgs {
                
                if let vc = vcNav.viewControllers[0] as? ShopCartViewController {
                    if !vc.isFirstLoad {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                            vc.pleaseWait()
                            vc.loadData()
                        }
                    }
                }
                
                if let vc = vcNav.viewControllers[0] as? MaterialViewController {
                    if vc.filtrateView?.isHidden == false {
                        vc.filtrateView?.hiddenMenu()
                    }
                    if vc.buildFiltrateView?.isHidden == false {
                        vc.buildFiltrateView?.hiddenMenu()
                    }
                }
            }
        }
        return true
    }
    
    // 当点击tabBar的时候,自动执行该代理方法(不需要手动设置代理)
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 把tabBarButton取出来
        UserData.shared.tabbarItemIndex = item.tag
        var tabbarbuttonArray:[Any] = [Any]()
        
        for tabBarBtn in self.tabBar.subviews {
            if tabBarBtn.isKind(of: NSClassFromString("UITabBarButton")!) {
                tabbarbuttonArray.append(tabBarBtn)
            }
        }
        
        animationWithIndex(index: item.tag, withButtonArray: tabbarbuttonArray)
    }

    // 动画方法
    func animationWithIndex(index:Int, withButtonArray btnArray:[Any]){
        
        //动画效果
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        pulse.duration = 0.12
        pulse.repeatCount = 1
        pulse.autoreverses = true
        pulse.fromValue = 0.8
        pulse.toValue = 1.2
        
        // 给tabBarButton添加动画效果
//        let tabBarLayer = (btnArray[index] as AnyObject).layer
//        tabBarLayer?.add(pulse, forKey: nil)
        
    }
    
    //MARK: - MainTabBarDelegate
    
    func centerButtonClick(tabBar:MainTabBar, centerBtn:UIButton) {
        animationWithIndex(index: 0, withButtonArray: [centerBtn])
        
        let scVC = ScanCodeController()
        scVC.hidesBottomBarWhenPushed = true
        let VC:BaseNavigationController = self.selectedViewController as! BaseNavigationController
        VC.pushViewController(scVC, animated: true)
     
        if let vc = VC.viewControllers[0] as? ShopCartViewController {
            vc.isFirstLoad = true
        }
    
    }
    
    //MARK: - 横竖屏支持
    
    override var shouldAutorotate: Bool {
        return (selectedViewController?.shouldAutorotate)!
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (selectedViewController?.supportedInterfaceOrientations)!
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return (selectedViewController?.preferredInterfaceOrientationForPresentation)!
    }
    
    
    /// 版本验证
    func LoadRenew()  {
        let urlStr = APIURL.getVersion
        
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let versionModel = Mapper<VersionModel>().map(JSON: dataDic as! [String: Any])
                if versionModel?.ischeck != 0 || versionModel?.ver == nil || versionModel?.title == nil || versionModel?.isonline == nil || versionModel?.info == nil || versionModel?.isrequired == nil || versionModel?.downloadurl == nil {
                    return
                }
                
                AppData.isExamine = (versionModel?.ischeck)!
                AppData.isOnLine = (versionModel?.isonline)!
                
                //获取本地软件版本号
                let infoDictionary = Bundle.main.infoDictionary
                let systemVersion: String = infoDictionary! ["CFBundleShortVersionString"] as! String
                let newVersion = versionModel?.ver ?? "1.0"
                
                AppLog("服务器版本号: \(newVersion)")
                AppLog("本地版本号: \(systemVersion)")
                
                var updata:Bool=false
                var newVersionValue = newVersion.replacingOccurrences(of: ".", with: "")
                var systemVersionValue = systemVersion.replacingOccurrences(of: ".", with: "")
                
                let newVersionCount = newVersionValue.count
                let systemVersionCount = systemVersionValue.count
                let changCount = newVersionCount - systemVersionCount
                var absolute = changCount
                
                if changCount < 0 {
                    absolute = -changCount
                }
                
                for _ in 0..<absolute {
                    
                    if changCount > 0 {
                        systemVersionValue += "0"
                    }else {
                        newVersionValue += "0"
                    }
                }
                
                let newVersionValueInt = Int(newVersionValue) ?? 10
                let systemVersionValueInt = Int(systemVersionValue) ?? 10
                if newVersionValueInt > systemVersionValueInt {
                    updata = true
                }
                
                if updata {
                    if let timeInterval = UserDefaults.standard.object(forKey: "VersionHintTime") as? Double {
                        let date = Date.init(timeIntervalSince1970: TimeInterval(timeInterval))
                        if date.isToday() && versionModel?.isrequired != 1 {
                            return
                            
                        }else {
                            let timeInterval = Date().timeIntervalSince1970
                            UserDefaults.standard.set(Int(timeInterval), forKey: "VersionHintTime")
                        }
                    }else {
                        let timeInterval = Date().timeIntervalSince1970
                        UserDefaults.standard.set(Double(timeInterval), forKey: "VersionHintTime")
                    }
                    
                    let cancelAlert = UIAlertController.init(title: versionModel?.title, message: versionModel?.info, preferredStyle: .alert)
                    let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (cancelAction) in
                        
                    })
                    
                    let sure = UIAlertAction.init(title: "立即更新", style: .default, handler: { (sureAction) in
                        
                        let appUrl = URL.init(string: versionModel!.downloadurl!)!
                        if UIApplication.shared.canOpenURL(appUrl) {
                            UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
                        }
                        
//                        if versionModel?.isrequired == 1 {
//                            //强制更新则退出程序
//                            exit(0)
//                        }
                    })
                    
                    cancelAlert.addAction(sure)
                    
                    if versionModel?.isrequired != 1 {
                        cancelAlert.addAction(cancel)
                    }
                    let subViews1 = cancelAlert.view.subviews.first
                    let subViews2 = subViews1?.subviews.first
                    let subViews3 = subViews2?.subviews.first
                    let subViews4 = subViews3?.subviews.first
                    let subViews5 = subViews4?.subviews.first
                    if subViews5?.subviews.count ?? 0 > 2 {
                        if let titleLabel = subViews5?.subviews[0] as? UILabel {
                            let messageLabel = subViews5?.subviews[1] as? UILabel
                            titleLabel.textAlignment = .center
                            messageLabel?.textAlignment = .left
                        } else {
                            let titleLabel = subViews5?.subviews[1] as? UILabel
                            let messageLabel = subViews5?.subviews[2] as? UILabel
                            titleLabel?.textAlignment = .center
                            messageLabel?.textAlignment = .left
                        }
                    }
                    let titleLabel = subViews5?.subviews[1] as? UILabel
                    let messageLabel = subViews5?.subviews[2] as? UILabel
                    titleLabel?.textAlignment = .center
                    messageLabel?.textAlignment = .left
                    self.present(cancelAlert, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.removeObject(forKey: "VersionHintTime")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "VersionHintTime")
            }
            
        }) { (error) in
            UserDefaults.standard.removeObject(forKey: "VersionHintTime")
        }
    }
    
    /// 获取用户数据
    func refreshUserData() {
        
        if UserData1.shared.tokenModel == nil {
            return
        }
        
        let parameters: Parameters = [:]
        var urlStr = ""
        
        urlStr = APIURL.getUserInfo
        
        AppLog(parameters)
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                
                //储存用户数据
                AppUtils.setUserData(response: response)
                var userName = UserData.shared.userInfoModel?.userName
                if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
                    userName = UserData.shared.userInfoModel?.merchant?.userName
                } else if UserData.shared.userType == .yys {
                    userName = UserData.shared.userInfoModel?.userInfo?.yzbUser?.loginName
                } else {
                    if userName == "" {
                        self.noticeOnlyText("用户信息异常~")
                        return
                    }
                    
                }
                //登录极光
                let pwd = YZBSign.shared.passwordMd5(password: userName)
                YZBChatRequest.shared.login(with: userName ?? "", pwd: pwd, errorBlock: { (error) in
                    if error == nil {
                        //发送进入前台通知x
                        NotificationCenter.default.post(name: Notification.Name.init("RefreshUnread"), object: nil)
                    }
                })
            }
            else if errorCode == "018" {
                
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "您的公司会员已过期，续费后才能恢复使用，请联系管理员前往后台续费！", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确认") {
                    ToolsFunc.showLoginVC()
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            else if errorCode == "019" {
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let workerModel = Mapper<WorkerModel>().map(JSON: dataDic as! [String : Any])
                
                var cityMobile = ""
                if let valueStr = workerModel?.cityMobile {
                    cityMobile = valueStr
                }
                
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "您的公司暂未开通会员，请前往后台交费后使用，详情请咨询当地运营商（电话：\(cityMobile)）", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    ToolsFunc.showLoginVC()
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
    }
    
    func getActivityIconsRequest() {
        YZBSign.shared.request(APIURL.activityIcon, method: .get, parameters: Parameters(), success: { (response) in
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            self.activityIconImg = dataDic["activityIconImg"] as? String
            self.activeMyIconImg = dataDic["activeMyIconImg"] as? String
            self.notActiveMyIconImg = dataDic["notActiveMyIconImg"] as? String
            self.setupTabBar()
            self.createSubController()
            self.delegate = self
            self.loadRenewUserBase()
            self.selectedIndex = 0
        }) { (error) in
            
        }
    }
    
    func prepareEurekaRow() {
        
        let rowFont = UIFont.systemFont(ofSize: 16)
        
        ButtonRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = rowFont
            cell.accessoryType = .none
            cell.textLabel?.textColor = cell.tintColor.withAlphaComponent(1.0)
        }
        
        IntRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = rowFont
            cell.textField.font = rowFont
        }
        
        DecimalRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = rowFont
            cell.textField.font = rowFont
        }
        
        TextRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = rowFont
            cell.textField.font = rowFont
        }
        
        TextAreaRow.defaultCellUpdate = { cell, row in
            cell.textView.font = rowFont
            cell.placeholderLabel?.font = rowFont
        }
        
        PickerInlineRow<String>.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = rowFont
            cell.detailTextLabel?.font = rowFont
        }
        
        DateInlineRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = rowFont
            cell.detailTextLabel?.font = rowFont
        }
        
    }
    
    func tabBarbgImgView() {
        
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint.zero)
        bezier.addLine(to: CGPoint(x: PublicSize.screenWidth * 0.5 - 20, y: 0))
        
        let startAngle = -CGFloat.pi/7
        let endAngle = CGFloat.pi-startAngle
        
        bezier.append(UIBezierPath(arcCenter: CGPoint(x: PublicSize.screenWidth * 0.5-0.5, y: 13), radius: 24, startAngle: startAngle, endAngle: endAngle, clockwise: false))
        
        bezier.move(to: CGPoint(x: PublicSize.screenWidth * 0.5 + 20, y: 0))
        bezier.addLine(to: CGPoint(x: PublicSize.screenWidth, y: 0))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezier.cgPath
        shapeLayer.lineWidth = 0
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        tabBar.backgroundColor = UIColor.white
        tabBar.layer.insertSublayer(shapeLayer, at: 0)
        
        tabBar.layerShadow()
        
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
    }
}
