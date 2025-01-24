//
//  MyPurchaseCenter.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/8.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import PopupDialog
import ObjectMapper
import TLTransitions

class MyPurchaseCenter: BaseViewController, LLCycleScrollViewDelegate {
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    private var pop: TLTransition?
    private var merchantType: String?
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .system
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = UIImage()
        cycleScrollView.placeHolderImage = UIImage()
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(2).masksToBounds()
    }
    
    private var modeTitle: String {
        get {
            return UserData.shared.userType == .jzgs ? "采购下单" : "客户下单"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfoRequest()
        getActivityIconsRequest()
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - 获取广告图列表
    private var advertModel: AdvertModel?
    func requestAdvertList()  {
        YZBSign.shared.request(APIURL.advertList, method: .get, parameters: Parameters()) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.advertModel = Mapper<AdvertModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
            }
        } failure: { (error) in
            
        }
    }
    
    private var activeMyIconImg: String?
    private var hasNewActive: String?
    func getActivityIconsRequest() {
        YZBSign.shared.request(APIURL.activityIcon, method: .get, parameters: Parameters(), success: { (response) in
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            self.activeMyIconImg = dataDic["activeMyIconImg"] as? String
            self.hasNewActive = dataDic["hasNewActive"] as? String
            self.refreshTabbar()
            self.tableView.reloadData()
        }) { (error) in
            
        }
    }
    
    func refreshTabbar() {
        if let activeMyIconImg1 = activeMyIconImg  {
            let imgStr = APIURL.ossPicUrl + activeMyIconImg1
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 23, height: 23))
            imageView.sd_setImage(with: URL.init(string: imgStr)) { (image, error, tyoe, url) in
                let image1 = image?.scaled(to: CGSize(width: 23, height: 23))
                self.tabBarItem.image = image1?.withRenderingMode(.alwaysOriginal)
                self.tabBarItem.selectedImage = image1?.withRenderingMode(.alwaysOriginal)
            }
        }
        
        
    }
    
    func getUserInfoRequest() {
        YZBSign.shared.request(APIURL.getUserInfo, method: .get, parameters: Parameters(), success: { (response) in
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
            UserData.shared.userInfoModel = infoModel
            self.tableView.reloadData()
            self.refresh()
        }) { (error) in
            
        }
    }
    //MARK: - 主要为了切换供应商
    func getUserInfoRequest1() {
        pleaseWait()
        YZBSign.shared.request(APIURL.getUserInfo, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
                UserData.shared.userInfoModel = infoModel
                if self.merchantType == "1" {
                    AppUtils.setUserType(type: .gys)
                } else if self.merchantType == "2" {
                    AppUtils.setUserType(type: .fws)
                }
                self.enterMainController()
            }
        }) { (error) in
            
        }
    }
    
    func enterMainController() {
        if let window = UIApplication.shared.keyWindow {
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = MainViewController()
                UIView.setAnimationsEnabled(oldState)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalNotificationer.add(observer: self, selector: #selector(refreshUserData), notification: .user)
        configTableView()
        if !UserDefaults.standard.bool(forKey: UserDefaultStr.firstGuide5) {
            UserDefaults.standard.set(true, forKey: UserDefaultStr.firstGuide5)
//            loadGuideView()
        }
        requestAdvertList()
    }
    
    func loadGuideView() {
        let guideView = UIView()
        guideView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        guideView.backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        UIApplication.shared.windows.first?.addSubview(guideView)
        
        let guideLab1 = UILabel().text("客户订单").textColor(.white).fontBold(12)
        let guideLab2 = UILabel().text("采购订单").textColor(.white).fontBold(12)
        
        let guideIV1 = UIImageView().image(#imageLiteral(resourceName: "guide_5_1"))
        let guideIV2 = UIImageView().image(#imageLiteral(resourceName: "guide_5_2"))
        let guideIV3 = UIImageView().image(#imageLiteral(resourceName: "guide_5_3"))
        let guideIV4 = UIImageView().image(#imageLiteral(resourceName: "guide_5_4"))
        let guideIV5 = UIImageView().image(#imageLiteral(resourceName: "guide_5_5"))
        let guideBtn1 = UIButton().image(#imageLiteral(resourceName: "purchase_sale"))
        let guideBtn2 = UIButton().image(#imageLiteral(resourceName: "purchase_share"))
        let btnW: CGFloat = view.width/4
        guideView.sv(guideLab1, guideLab2, guideBtn1, guideBtn2)
        guideView.layout(
            221,
            |-25-guideLab1.height(16.5),
            30,
            |-25-guideLab2.height(16.5),
            >=0
        )
        let doneBtn = UIButton().text("完成").textColor(.white).font(14).borderColor(.white).borderWidth(1).cornerRadius(15)
        guideView.sv(guideIV1, guideIV2, guideIV3, guideIV4, guideIV5, guideBtn1, guideBtn2, doneBtn)
        var offsetH: CGFloat = 184
        if UserData1.shared.isHaveMyList {
            offsetH = 184
        } else {
            offsetH = 75
        }
        guideView.layout(
            174.5,
            |-68-guideIV1.width(225).height(59),
            9,
            |-69.5-guideIV2.width(175.68).height(54.1),
            offsetH,
            guideIV3.width(224.69).height(38)-46-|,
            6.5,
            |-btnW-guideBtn1.width(btnW).height(45)-(btnW)-guideBtn2.width(btnW).height(45),
            >=0
        )
        var offsetH2: CGFloat = 460
        if UserData1.shared.isHaveMyList {
            offsetH2 = 460
        } else {
            offsetH2 = 351
        }
        guideView.layout(
            offsetH2,
            |-(btnW+btnW/2)-guideIV4.width(182.5).height(65),
            0,
            doneBtn.width(90).height(30)-92-|,
            >=0
        )
        
        var offsetH1 = 541
        if UserData1.shared.isHaveMyList {
            offsetH1 = 541
        } else {
            offsetH1 = 432
        }
        guideView.layout(
            offsetH1,
            guideIV5.width(23).height(16)-72-|,
            >=0
        )
        guideBtn2.isHidden = true
        guideIV3.isHidden = true
        doneBtn.tapped { (btn) in
            guideView.removeFromSuperview()
        }
    }
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>> 我的界面释放 <<<<<<<<<<<<<<<<<")
        NotificationCenter.default.removeObserver(self)
        [GlobalNotificationer.HoNotification.user].forEach { GlobalNotificationer.remove(observer: self, notification: $0) }
    }
    
    private func configTableView() {
        view.backgroundColor = .white
        
        let topIV = UIImageView().image(#imageLiteral(resourceName: "purchase_top_bg"))
        view.sv(topIV)
        view.layout(
            0,
            |topIV| ~ 156,
            >=0
        )
        
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        tableView.refreshHeader { [weak self] in
            self?.refreshUserData()
            self?.getActivityIconsRequest()
            self?.requestAdvertList()
        }
        configHeaderView()
    }
    
    
    // MARK: - 网络请求
    //获取用户信息
    @objc func refreshUserData() {
        let urlStr = APIURL.getUserInfo
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            self.tableView.endHeaderRefresh()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                //储存用户数据
                AppUtils.setUserData(response: response)
                self.refresh()
                //更新极光信息
                YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                    
                })
            }
            else if errorCode == "018" {
                
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "您的公司会员已过期，续费后才能恢复使用，请联系管理员前往后台续费！", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion:nil)
                
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
            self.tableView.endHeaderRefresh()
        }
    }
    
    private let avatar = UIImageView().cornerRadius(30).masksToBounds()
    private let levelIcon = UIImageView()
    private let name = UILabel().textColor(.kColor33).font(18, weight: .bold)
    private let levelBtn = UIButton().cornerRadius(7.5).masksToBounds()
    private let dateLab = UILabel().text("2021/01/29到期").textColor(.white).font(10)
    private let msgBtn = UIButton().image(#imageLiteral(resourceName: "purchase_set"))
    private let setBtn = UIButton().image(#imageLiteral(resourceName: "purchase_set"))
    private let subsidyView = UIView().cornerRadius(11).masksToBounds()
    private let subsidyLabel = UILabel().textColor(.white).font(12, weight: .bold)
    
    private func configHeaderView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 156))
//        v.sv(avatar, name, setBtn, levelIcon, levelBtn, dateLab)
//        v.sv(avatar, name, setBtn)
//        v.layout(
//            61.5,
//            |-25-avatar.size(60)-(>=0)-setBtn.size(40)-3-|,
//            >=0
//        )
//        v.layout(
//            67,
//            |-95-name.height(28)-4-levelBtn.width(50).height(15),
//            4,
//            |-95-dateLab.height(14),
//            >=0
//        )
//        v.layout(
//            67,
//            |-95-name.height(28),
//            >=0
//        )
//        v.layout(
//            97,
//            |-66-levelIcon.width(19).height(23),
//            >=0
//        )
        
        v.addSubview(avatar)
        avatar.snp.makeConstraints { make in
            make.top.equalTo(60)
            make.left.equalTo(25)
            make.width.height.equalTo(60)
        }
        
        v.addSubview(name)
        name.snp.makeConstraints { make in
            make.left.equalTo(avatar.snp.right).offset(10)
            make.top.equalTo(avatar).offset(5)
            make.height.equalTo(25)
            make.right.lessThanOrEqualTo(-90)
        }
        
        v.addSubview(setBtn)
        setBtn.snp.makeConstraints { make in
            make.centerY.equalTo(name)
            make.right.equalTo(-7.5)
            make.width.height.equalTo(37)
        }
        
        v.addSubview(msgBtn)
        msgBtn.snp.makeConstraints { make in
            make.centerY.equalTo(name)
            make.right.equalTo(setBtn.snp.left)
            make.width.height.equalTo(37)
        }
        
        
        
        tableView.tableHeaderView = v
        refresh()
        //
        avatar.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickAvatar))
        avatar.addGestureRecognizer(tap)
        levelBtn.addTarget(self, action: #selector(levelBtnClick(btn:)))
        setBtn.addTarget(self , action: #selector(setBtnClick(btn:)))
    }
    
    func refresh() {
        let levelTitles = ["普通会员", "中级会员", "VIP会员", "白金会员", "钻石会员", "金钻会员", "至尊会员"]
        let levelColors = [#colorLiteral(red: 0.8823529412, green: 1, blue: 0.968627451, alpha: 1), #colorLiteral(red: 0.8509803922, green: 1, blue: 0.9568627451, alpha: 1), #colorLiteral(red: 1, green: 0.9333333333, blue: 0.8823529412, alpha: 1), #colorLiteral(red: 1, green: 0.9333333333, blue: 0.8823529412, alpha: 1), #colorLiteral(red: 0.9647058824, green: 0.9137254902, blue: 0.8549019608, alpha: 1), #colorLiteral(red: 1, green: 0.9254901961, blue: 0.8235294118, alpha: 1), #colorLiteral(red: 1, green: 0.9490196078, blue: 0.8941176471, alpha: 1)]
        let levelIcons = [#imageLiteral(resourceName: "level_pthy_1"), #imageLiteral(resourceName: "level_zjhy_1"), #imageLiteral(resourceName: "level_viphy_1"), #imageLiteral(resourceName: "level_bjhy_1"), #imageLiteral(resourceName: "level_zshy_1"), #imageLiteral(resourceName: "level_jzhy_1"), #imageLiteral(resourceName: "level_zzhy_1")]
        let userModel = UserData.shared.workerModel
        name.text(userModel?.realName ?? "")
        
        if !avatar.addImage(userModel?.headUrl) {
            if userModel?.sex?.intValue == 2 {
                avatar.image(#imageLiteral(resourceName: "headerImage_woman"))
            } else {
                avatar.image(#imageLiteral(resourceName: "headerImage_man"))
            }
        }
        let vipInfoModel = UserData.shared.userInfoModel?.yzbVip
        let type = vipInfoModel?.vipType ?? 1
        let validEndDate = vipInfoModel?.validEndDate ?? ""
        let validEndDate1 = validEndDate.components(separatedBy: " ").first
        let validEndDate2 = validEndDate1?.replacingOccurrences(of: "-", with: "/")
        dateLab.text("\(validEndDate2 ?? "")到期")
        if type == 0 || type == 999 {
            levelIcon.image(#imageLiteral(resourceName: "level_icon_ty"))
            levelBtn.text("体验会员").textColor(UIColor.hexColor("#4B3C11")).font(10).backgroundColor(UIColor.hexColor("#FFF7DC"))
        } else {
            levelIcon.image(levelIcons[type-1])
            levelBtn.text(levelTitles[type-1]).textColor(#colorLiteral(red: 0.2156862745, green: 0.2117647059, blue: 0.1960784314, alpha: 1)).font(10).backgroundColor(levelColors[type-1])
        }
    }
    
    @objc private func levelBtnClick(btn: UIButton) {
        let vc = MembershipListVC()
        navigationController?.pushViewController(vc)
    }
}
// MARK: - 按钮点击方法
extension MyPurchaseCenter {
    /// 设置
    @objc private func setBtnClick(btn: UIButton) {
        let vc = MoreViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 点击头像
    @objc func clickAvatar() {
        navigationController?.pushViewController(UserInfoController(), animated: true)
    }
    
    @objc private func toolBtnsClick(btn: UIButton) {
        if isSHAccountUserId {
            switch btn.tag {
            case 0:
                let vc = HouseViewController()
                vc.title = "我的工地"
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                let tip = "是否切换为\"\(modeTitle)\"模式"
                
                let popup = PopupDialog(title: "切换模式", message: tip, buttonAlignment: .horizontal)
                let sureBtn = AlertButton(title: "确认") {
                    
                    if let window = UIApplication.shared.keyWindow {
                        
                        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                            let oldState: Bool = UIView.areAnimationsEnabled
                            UIView.setAnimationsEnabled(false)
                            
                            if UserData.shared.userType == .jzgs {
                                AppUtils.setUserType(type: .cgy)
                            }else {
                                AppUtils.setUserType(type: .jzgs)
                            }
                            
                            //更新极光用户信息
                            YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                            })
                            
                            window.rootViewController = MainViewController()
                            UIView.setAnimationsEnabled(oldState)
                        })
                    }
                }
                let cancelBtn = CancelButton(title: "取消") {
                }
                popup.addButtons([cancelBtn,sureBtn])
                self.present(popup, animated: true, completion: nil)
            case 2:
                let vc = MyDJQVC()
                navigationController?.pushViewController(vc)
            case 3:
                let userModel = UserData.shared.substationModel
                houseListCallTel(name: userModel?.realName ?? "", phone: userModel?.mobile ?? "")
            default:
                break
            }
        } else {
            switch btn.tag {
            case 0:
                let vc = HouseViewController()
                vc.title = "我的工地"
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                let tip = "是否切换为\"\(modeTitle)\"模式"
                
                let popup = PopupDialog(title: "切换模式", message: tip, buttonAlignment: .horizontal)
                let sureBtn = AlertButton(title: "确认") {
                    
                    if let window = UIApplication.shared.keyWindow {
                        
                        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                            let oldState: Bool = UIView.areAnimationsEnabled
                            UIView.setAnimationsEnabled(false)
                            
                            if UserData.shared.userType == .jzgs {
                                AppUtils.setUserType(type: .cgy)
                            }else {
                                AppUtils.setUserType(type: .jzgs)
                            }
                            
                            //更新极光用户信息
                            YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                            })
                            
                            window.rootViewController = MainViewController()
                            UIView.setAnimationsEnabled(oldState)
                        })
                    }
                }
                let cancelBtn = CancelButton(title: "取消") {
                }
                popup.addButtons([cancelBtn,sureBtn])
                self.present(popup, animated: true, completion: nil)
            case 2:
                // let vc = SystemNotiVC()
                 let vc = MyCenterActivityVC()
                navigationController?.pushViewController(vc)
            case 3:
                let vc = MyMoneyBagVC()
                self.navigationController?.pushViewController(vc)
//                let vc = UIBaseWebViewController()
//                let urlStr = APIURL.webUrl + "/other/jcd-active-h5/index.html"
//                vc.urlStr = urlStr
//                vc.isShare = true
//                self.navigationController?.pushViewController(vc)
            case 4:
                //noticeOnlyText("我的代金券～")
                let vc = MyDJQVC()
                navigationController?.pushViewController(vc)
            case 5:
                selectMerchantSysPopView() //进入商户系统
            default:
                break
            }
        }
        
    }
    //MARK: - 选择商户系统
    private func selectMerchantSysPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 272, height: 222)).backgroundColor(.white)
        let titleLabel = UILabel().text("选择商户系统").textColor(.kColor33).fontBold(14)
        
        let brandBtn = UIButton().backgroundColor(UIColor.hexColor("#EFF4FD")).cornerRadius(11)
        let serviceBtn = UIButton().backgroundColor(UIColor.hexColor("#F6F5FF")).cornerRadius(11)
        v.sv(titleLabel, brandBtn, serviceBtn)
        v.layout(
            20,
            titleLabel.height(20).centerHorizontally(),
            15,
            |-17-brandBtn.width(110).height(150)-18-serviceBtn.width(110).height(150)-17-|,
            17
        )
        let brandIcon = UIImageView().image("icon_pps")
        let brandLab1 = UILabel().text("品牌商").textColor(.kColor33).font(12, weight: .bold)
        let brandLab2 = UILabel().text("客户、订单管理系统").textColor(.kColor66).font(10)
        brandLab1.textAligment(.center)
        brandLab2.textAligment(.center)
        brandBtn.sv(brandIcon, brandLab1, brandLab2)
        brandBtn.layout(
            24,
            brandIcon.size(48).centerHorizontally(),
            10,
            |brandLab1.height(16.5)|,
            8,
            |brandLab2.height(14)|,
            >=0
        )
        let serviceIcon = UIImageView().image("icon_fws")
        let serviceLab1 = UILabel().text("服务商").textColor(.kColor33).font(12, weight: .bold)
        let serviceLab2 = UILabel().text("装饰行业服务管家").textColor(.kColor66).font(10)
        serviceLab1.textAligment(.center)
        serviceLab2.textAligment(.center)
        serviceBtn.sv(serviceIcon, serviceLab1, serviceLab2)
        serviceBtn.layout(
            24,
            serviceIcon.size(48).centerHorizontally(),
            10,
            |serviceLab1.height(16.5)|,
            8,
            |serviceLab2.height(14)|,
            >=0
        )
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
        
        brandBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss(completion: {
                self?.merchantType = "1"
                self?.switchMerchantRequest()
            })
            
        }
        
        serviceBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss(completion: {
                self?.merchantType = "2"
                self?.switchMerchantRequest()
            })
        }
    }
    //MARK: - 会员切换品牌商供应商
    func switchMerchantRequest() {
        pleaseWait()
        var parameters = Parameters()
        parameters["merchantType"] = merchantType
        YZBSign.shared.request(APIURL.switchMerchant, method: .post, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let memberTokenModel = UserDefaults.standard.object(forKey: UserDefaultStr.tokenModel)
                UserDefaults.standard.set(memberTokenModel, forKey: UserDefaultStr.tokenModel1)
                ToolsFunc.clearData()
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let tokenModel = Mapper<TokenModel1>().map(JSON: dataDic as! [String: Any])
                UserData1.shared.tokenModel = tokenModel
                self.getUserInfoRequest1()
            } else if code == "10000" { // 未绑定对应账号
                if self.merchantType == "1" {
                    self.toRegiestPPS()
                } else if self.merchantType == "2" {
                    self.toRegiestFWS()
                }
            } else if code == "23" {
                if self.merchantType == "2" {
                    let dataDic = Utils.getReqDir(data: response as AnyObject)
                    let regiestModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String: Any])
                    if regiestModel?.serviceType == 5 {
                        let vc = ServiceRegiestWorkerVC()
                        vc.regiestId = regiestModel?.id
                        self.navigationController?.pushViewController(vc)
                    } else if regiestModel?.serviceType == 6 {
                        let vc = ServiceRegiestDesignVC()
                        vc.regiestId = regiestModel?.id
                        self.navigationController?.pushViewController(vc)
                    } else if regiestModel?.serviceType == 7 {
                        let vc = ServiceRegiestForemanVC()
                        vc.regiestId = regiestModel?.id
                        self.navigationController?.pushViewController(vc)
                    }
                } else if  self.merchantType == "1" {
                    let dataDic = Utils.getReqDir(data: response as AnyObject)
                    
                    let regiestBaseModel = RegisterBaseModel()
                    let regiestModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String: Any])
                    regiestBaseModel.registerRData = regiestModel
                    let vc = PPSRegiestSecondVC()
                    vc.regiestBaseModel = regiestBaseModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if code == "21" {
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "资料已上传，请耐心等待审核！", tapGestureDismissal: false, panGestureDismissal: false)
                let sureBtn = AlertButton(title: "确定") {
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            } else if code == "22" {
                self.clearAllNotice()
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                
                if self.merchantType == "2" {
                    let regiestModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String: Any])
                    let vc = ServiceRegiestFailVC()
                    vc.regiestModel = regiestModel
                    vc.reason = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else if self.merchantType == "1" {
                    let regiestModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String: Any])
                    let vc = ServiceRegiestFailVC()
                    vc.regiestModel = regiestModel
                    vc.reason = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } failure: { (error) in
            
        }
    }
    
    private func toRegiestPPS() {
        let vc = PPSRegiestVC()
        vc.title = "基本信息"
        self.navigationController?.pushViewController(vc)
    }
    
    private func toRegiestFWS() {
        let vc = ServiceRegiestPersonVC()
        vc.title = "基本信息"
        self.navigationController?.pushViewController(vc)
    }
        
    /// 客户订单
    @objc private func kfOrderClick() {
        let vc = AllOrdersViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 采购订单
    @objc private func cgOrderClick() {
        let vc = PurchaseViewController()
        vc.orderDetailType = .cg
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 服务订单
    @objc private func fwOrderClick() {
        let vc = ServiceOrderVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func exitAction() {
        let popup = PopupDialog(title: "退出登录", message: "是否确定退出当前登录账号?", buttonAlignment: .horizontal)
        let sureBtn = AlertButton(title: "确认") {
            
            ToolsFunc.logout()
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
}

extension MyPurchaseCenter: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            configSection0(cell, indexPath: indexPath)
        default:
            configSection1(cell)
        }
        return cell
    }
    
    func configSection0(_ cell: UITableViewCell, indexPath: IndexPath) {
        let title = UILabel().textColor(.kColor33).font(12, weight: .bold)
        let arrow = UIImageView().image(#imageLiteral(resourceName: "purchase_arrow"))
        let line = UIView().backgroundColor(#colorLiteral(red: 0.7568627451, green: 0.9725490196, blue: 0.8784313725, alpha: 1))
        cell.sv(title, arrow, line)
        cell.layout(
            15,
            |-25-title.height(16.5)-(>=0)-arrow-25-|,
            >=0,
            |-20-line.height(0.5)-25-|,
            0
        )
        switch indexPath.row {
        case 0:
            title.text("客户订单")
        case 1:
            title.text("采购订单")
        default:
            title.text("服务订单")
        }
    }
    
    func configSection1(_ cell: UITableViewCell) {
        var titles = ["地址管理", "切换模式", "活动中心", "我的钱包", "领券中心", "商户系统", ]
        var images = [#imageLiteral(resourceName: "purchase_address"), #imageLiteral(resourceName: "purchase_sale"), #imageLiteral(resourceName: "purchase_hdzx"), #imageLiteral(resourceName: "purchase_qb"), #imageLiteral(resourceName: "purchase_djq"), #imageLiteral(resourceName: "purchase_shxt")]
        if isSHAccountUserId {
            titles = ["地址管理", "切换模式", "代金券", "联系客服"]
            images = [#imageLiteral(resourceName: "purchase_address"), #imageLiteral(resourceName: "purchase_sale"), #imageLiteral(resourceName: "purchase_djq"), #imageLiteral(resourceName: "purchase_kf")]
        }
        let btnW: CGFloat = view.width/4
        let btnH: CGFloat = 72
        titles.enumerated().forEach { (item) in
            let index = item.offset
            let title = item.element
            let image = images[index]
            let offsetX: CGFloat = btnW * CGFloat((index % 4))
            let offsetY: CGFloat = CGFloat(87*(index/4) + 20)
            let btn = UIButton().image(image).text(title).textColor(.kColor33).font(12)
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=0
            )
            if title == "活动中心" && hasNewActive == "1" {
                let redView = UIView().backgroundColor(.kDF2F2F).cornerRadius(5)
                btn.sv(redView)
                redView.size(10).centerHorizontally(18.5).centerVertically(-25)
            }
            btn.layoutButton(imageTitleSpace: 10)
            btn.tag = index
            btn.addTarget(self , action: #selector(toolBtnsClick(btn:)))
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 46.5
        default:
            return 180
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                kfOrderClick()
            } else if indexPath.row == 1 {
                cgOrderClick()
            } else if indexPath.row == 2 {
                fwOrderClick()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        let title = UILabel().textColor(#colorLiteral(red: 0.003921568627, green: 0.5333333333, blue: 0.3019607843, alpha: 1)).font(14, weight: .bold)
        if section == 0 {
            title.text("订单管理")
        } else if section == 1 {
            title.text("工具与服务")
        }
        v.sv(title)
        v.layout(
            25,
            |-14-title.height(20),
            >=0
        )
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            if advertModel?.myList?.count ?? 0 > 0 {
                return 104.5
            } else {
                return 0.01
            }
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let bannerModels = advertModel?.myList
            if bannerModels?.count == 0 {
                return UIView()
            }
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 104.5))
            v.sv(cycleScrollView)
            v.layout(
                24.5,
                |-14-cycleScrollView.height(80)-14-|,
                >=0
            )
            
            var imagePaths: [String] = []
            bannerModels?.forEach({ (model) in
                let imagePath = APIURL.ossPicUrl + (model.advertImg ?? "")
                imagePaths.append(imagePath)
            })
            cycleScrollView.delegate = self
            cycleScrollView.imagePaths = imagePaths
            return v
        }
        return UIView()
    }
    
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        let bannerModels = advertModel?.myList
        if let advertLink = bannerModels?[index].advertLink {
            let vc = UIBaseWebViewController()
            if bannerModels?[index].whetherCanShare == "2" {
                vc.isShare = false
            } else {
                vc.isShare = true
            }
            vc.urlStr =  advertLink
            navigationController?.pushViewController(vc)
        }
    }
}



