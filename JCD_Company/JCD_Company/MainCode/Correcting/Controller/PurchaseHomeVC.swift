//
//  PurchaseHomeVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import TLTransitions

class PurchaseHomeVC: BaseViewController, LLCycleScrollViewDelegate {
    var pop: TLTransition?
    var guideView = UIView()
    var canLoadMsgCountSelf = false // 是否不通过通知刷新通知未读数量
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshUserData()
        if canLoadMsgCountSelf {
            self.loadMsgCounData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.canLoadMsgCountSelf = true

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var tableView = UITableView.init(frame: .zero, style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        NotificationCenter.default.addObserver(self, selector: #selector(loadMsgCounData), name: Notification.Name.init("RefreshUnread"), object: nil)
        
        let topIV = UIImageView().image(#imageLiteral(resourceName: "service_mall_top"))
        view.sv(topIV)
        view.layout(
            0,
            |topIV.height(156.5)|,
            >=0
        )
        
        let topToolView = UIView().backgroundColor(.clear)
        
        tableView.backgroundColor(.clear)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(topToolView, tableView)
        view.layout(
            0,
            topToolView.width(view.width).height(91),
            0,
            |tableView|,
            0
        )
        configHeaderView(v: topToolView)
        tableView.refreshHeader { [weak self] in
            self?.requestAdvertList()
            self?.loadData()
        }
        loadData()
//        if UserDefaults.standard.bool(forKey: UserDefaultStr.firstGuide1) {
//            if !UserDefaults.standard.bool(forKey: UserDefaultStr.firstHomeShare) {
//                UserDefaults.standard.set(true, forKey: UserDefaultStr.firstHomeShare)
//                loadShareView()
//            }
//        } else {
//            UserDefaults.standard.set(true, forKey: UserDefaultStr.firstGuide1)
//            loadGuideView()
//        }
        getActivityIconsRequest()
        requestAdvertList()
        
    
        
        tipInvitaFriendsPopView()
    }
    
    
    
    //MARK: - 获取广告图列表
    private var advertModel: AdvertModel?
    func requestAdvertList()  {
        YZBSign.shared.request(APIURL.advertList, method: .get, parameters: Parameters()) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.advertModel = Mapper<AdvertModel>().map(JSON: dataDic as! [String : Any])
                if self.advertModel?.myList?.count ?? 0 > 0 {
                    UserData1.shared.isHaveMyList = true
                }
                self.tableView.reloadData()
            }
        } failure: { (error) in
            
        }
    }
    
    /// 获取用户数据
    func refreshUserData() {
        let parameters: Parameters = [:]
        var urlStr = ""
        
        urlStr = APIURL.getUserInfo
        
        AppLog(parameters)
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                //储存用户数据
                AppUtils.setUserData(response: response)
                self.tableView.reloadData()
            }
        }) { (error) in
            
        }
    }
    
    //MARK: - 提醒成为体验会员弹框
    func tipToExperienceMemberPopView() {
        
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 247, height: 310))
        let tyBtn = UIButton().image(#imageLiteral(resourceName: "icon_tyhy"))
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "icon_tyhy_close"))
        v.sv(tyBtn, closeBtn)
        v.layout(
            0,
            |tyBtn|,
            0
        )
        v.layout(
            0,
            closeBtn.size(22)|,
            >=0
        )
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 0
        
        tyBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss(completion: {
                let vc = MembershipLevelsVC()
                self?.navigationController?.pushViewController(vc)
            })
        }
        
        closeBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss()
        }
    }
    
    //MARK: - 邀请好友弹框
    private let inviteView = UIView().backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
    func tipInvitaFriendsPopView() {
        
        if isSHAccountUserId {
            return
        }
        
        let popTag = "VersionHintTime1\(UserData1.shared.tokenModel?.userId ?? "")"
        if let timeInterval = UserDefaults.standard.object(forKey: popTag) as? Double {
            let date = Date.init(timeIntervalSince1970: TimeInterval(timeInterval))
            if date.isToday() {
                return
            }else {
                let timeInterval = Date().timeIntervalSince1970
                UserDefaults.standard.set(Double(timeInterval), forKey: popTag)
            }
        }else {
            let timeInterval = Date().timeIntervalSince1970
            UserDefaults.standard.set(Double(timeInterval), forKey: popTag)
        }
        
        let window = UIApplication.shared.windows.first
        inviteView.frame = window!.frame
        window?.addSubview(inviteView)
                
        let v = UIView().backgroundColor(.clear).cornerRadius(10)
        inviteView.sv(v)
        v.width(247).height(310).centerInContainer()
        
        let tyBtn = UIButton().image(#imageLiteral(resourceName: "icon_yqhy"))
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "icon_tyhy_close"))
        v.sv(tyBtn, closeBtn)
        v.layout(
            0,
            |tyBtn|,
            0
        )
        v.layout(
            0,
            closeBtn.size(22)|,
            >=0
        )
        
        inviteView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapGesContent)))
        
        tyBtn.tapped { [weak self] (tapBtn) in
            self?.inviteView.removeFromSuperview()
            let vc = UIBaseWebViewController()
            vc.isShare = true
            vc.urlStr = APIURL.webUrl + "/other/jcd-active-h5/#/invite-friends?isApp=1"
            self?.navigationController?.pushViewController(vc)
        }
        
        closeBtn.tapped { [weak self] (tapBtn) in
            self?.inviteView.removeFromSuperview()
        }
    }
    
    @objc func tapGesContent() {
        inviteView.removeFromSuperview()
    }
    
    
    private var activityIconImg: String?
    private var activeMyIconImg: String?
    private var notActiveMyIconImg: String?
    func getActivityIconsRequest() {
        YZBSign.shared.request(APIURL.activityIcon, method: .get, parameters: Parameters(), success: { (response) in
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            self.activityIconImg = dataDic["activityIconImg"] as? String
            self.activeMyIconImg = dataDic["activeMyIconImg"] as? String
            self.notActiveMyIconImg = dataDic["notActiveMyIconImg"] as? String
            self.refreshTabbar()
        }) { (error) in
            
        }
    }
    
    func refreshTabbar() {
        if let activeMyIconImg1 = activeMyIconImg  {
            let imgStr = APIURL.ossPicUrl + activeMyIconImg1
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 23, height: 23))
            imageView.sd_setImage(with: URL.init(string: imgStr)) { (image, error, tyoe, url) in
                let image1 = image?.scaled(to: CGSize(width: 23, height: 23))
                let tabbarItem1 = self.tabBarController?.tabBar.items?.last
                tabbarItem1?.image = image1?.withRenderingMode(.alwaysOriginal)
                tabbarItem1?.selectedImage = image1?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func loadGuideView() {
        guideView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        guideView.backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        UIApplication.shared.windows.first?.addSubview(guideView)
        let icon = UIView().backgroundColor(.clear)
        let searchBtn = UIButton().backgroundColor(UIColor.hexColor("#DBF1E7")).cornerRadius(15.5).masksToBounds()
        let searchIcon = UIImageView().image(#imageLiteral(resourceName: "item_search"))
        let searchLabel = UILabel().text("搜索你想要的内容").textColor(.kColor99).font(12)
        let messageBtn = UIButton().image(#imageLiteral(resourceName: "purchase_home_message"))
        guideView.sv(icon, searchBtn, messageBtn)
        guideView.layout(
            43,
            |-15-icon.width(37).height(45)-21-searchBtn.height(31)-21-messageBtn.size(40)-11-|,
            >=0
        )
        searchBtn.sv(searchIcon, searchLabel)
        searchBtn.layout(
            8.5,
            |-15-searchIcon.size(15)-5-searchLabel,
            7.5
        )
        
        let icons = [#imageLiteral(resourceName: "purchase_item-0"),#imageLiteral(resourceName: "purchase_item-1"),#imageLiteral(resourceName: "purchase_item-2"),#imageLiteral(resourceName: "purchase_item-3"),#imageLiteral(resourceName: "purchase_item-4"),#imageLiteral(resourceName: "purchase_item-5"),#imageLiteral(resourceName: "purchase_item-6"),#imageLiteral(resourceName: "purchase_item-7"), #imageLiteral(resourceName: "purchase_item-8"),#imageLiteral(resourceName: "purchase_item-9")]
        let titles = ["品牌产品", "区域产品", "装饰公司", "设计机构", "工长工人", "仓储物流", "VR设计", "供需信息", "保险金融", "会员专区"]
        titles.enumerated().forEach { (item) in
            let title = item.element
            let index = item.offset
            let icon = icons[index]
            let btnH: CGFloat = 68
            let btnW: CGFloat = view.width/5
            let offsetX: CGFloat = btnW * (CGFloat(index%5))
            let offsetY: CGFloat = 280 + btnH * (CGFloat(index/5))
            let btn = UIButton().image(icon).text(title).textColor(.clear).font(10)
            guideView.sv(btn)
            guideView.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=10
            )
            btn.layoutButton(imageTitleSpace: -1)
            if index == 0 || index == 1 || index == 6 {
                btn.isHidden = false
            } else {
                btn.isHidden = true
            }
        }
        
        let qcBtn = UIButton().image(#imageLiteral(resourceName: "home_btn_qc")).backgroundColor(UIColor.hexColor("#F4FBF8")).cornerRadius(10).masksToBounds()
        let tgBtn = UIButton().image(#imageLiteral(resourceName: "home_btn_tg")).backgroundColor(UIColor.hexColor("#F4FBF8")).cornerRadius(10).masksToBounds()
        let pgBtn = UIButton().image(#imageLiteral(resourceName: "home_btn_pg")).backgroundColor(UIColor.hexColor("#F4FBF8")).cornerRadius(10).masksToBounds()
        guideView.sv(qcBtn, tgBtn, pgBtn)
        guideView.layout(
            448,
            |-26-qcBtn.height(70)-6.5-tgBtn.height(70)-6.5-pgBtn.height(70)-26-|,
            10
        )
        equal(widths: qcBtn, tgBtn, pgBtn)
        
        let tabbarW: CGFloat = view.width/5
        let tabbarH: CGFloat = 45
        let tabbarBtn = UIButton().image(#imageLiteral(resourceName: "guide_1_white")).text("产品商城").textColor(.white).font(10)
        guideView.sv(tabbarBtn)
        guideView.layout(
            >=0,
            |-(tabbarW*2)-tabbarBtn.width(tabbarW).height(tabbarH),
            PublicSize.kBottomOffset
        )
        tabbarBtn.layoutButton(imageTitleSpace: 8)
        
        let guideIV1 = UIImageView().image(#imageLiteral(resourceName: "guide_1_1"))
        let guideIV2 = UIImageView().image(#imageLiteral(resourceName: "guide_1_2"))
        let guideIV3 = UIImageView().image(#imageLiteral(resourceName: "guide_1_3"))
        let guideIV4 = UIImageView().image(#imageLiteral(resourceName: "guide_1_4"))
        let guideIV5 = UIImageView().image(#imageLiteral(resourceName: "guide_1_5"))
        let guideIV6 = UIImageView().image(#imageLiteral(resourceName: "guide_1_6"))
        let guideIV7 = UIImageView().image(#imageLiteral(resourceName: "guide_1_7"))
        let guideIV8 = UIImageView().image(#imageLiteral(resourceName: "guide_5_5"))
        guideView.sv(guideIV1, guideIV2, guideIV3, guideIV4, guideIV5, guideIV6, guideIV7)
        guideView.layout(
            85.4,
            |-43-guideIV2.width(144).height(104.6),
            64,
            |-41.36-guideIV3.width(274.62).height(26.51),
            1,
            |-138-guideIV4.width(181).height(56.5),
            1,
            |-142-guideIV5.width(181).height(76),
            100.5,
            |-50-guideIV6.width(300).height(45),
            >=0
        )
        guideView.sv(guideIV8)
        guideView.layout(
            >=0,
            guideIV8.width(23).height(16)-65-|,
            PublicSize.kTabBarHeight-22.5
        )
        
        guideView.layout(
            83,
            guideIV1.width(150).height(60)-28-|,
            >=0
        )
        guideView.layout(
            >=0,
            guideIV7.width(185).height(75)-20-|,
            PublicSize.kTabBarHeight-3
        )
        
        let nextBtn = UIButton().text("下一步").textColor(.white).font(14).borderColor(.white).borderWidth(1).cornerRadius(15)
        guideView.sv(nextBtn)
        guideView.layout(
            >=0,
            nextBtn.width(90).height(30)-82.5-|,
            PublicSize.kTabBarHeight-13
        )
        nextBtn.tapped {  [weak self] (btn) in
            self?.guideView.removeFromSuperview()
            self?.tabBarController?.selectedIndex = 2
        }
    }
    
    func loadShareView() {
        let v = ShareAdInviateView.init(frame: CGRect(x: 0, y: 0, width: 301.5, height: 330)).backgroundColor(.clear)
        v.sureBtnAction = {
            self.pop?.dismiss(completion: {
                //let vc = ShareInviateVC()
                let vc = UIBaseWebViewController()
                let urlStr = APIURL.webUrl + "/other/jcd-active-h5/index.html"
                vc.urlStr = urlStr
                vc.isShare = true
                self.navigationController?.pushViewController(vc)
            })
        }
        v.cancelBtnAction = {
            self.pop?.dismiss()
        }
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
    }
    
    private var exchangeData: MaterialsCorrcetModel?
    private var exchangeImagePaths:Array<String> = []
    //MARK: - 网络请求
    @objc func reloadConversationList() {
        AppLog(">>>>>>>>>>>>>>>>>>>>> 收到聊天消息 <<<<<<<<<<<<<<<<<<<<")
        YZBChatRequest.shared.getAllConversationList(errorBlock:{(convers,error) in
            // 结束刷新
            if error == nil {
                self.msgUnReadCount += convers.unreadCount
                if self.msgUnReadCount > 0 {
                    self.msgCountLabel.text("\(self.msgUnReadCount)")
                    self.msgCountLabel.isHidden = false
                } else {
                    self.msgCountLabel.text("\(self.msgUnReadCount)")
                    self.msgCountLabel.isHidden = true
                }
                
            }
        })
    }
    private var msgUnReadCount = 0
    @objc func loadMsgCounData() {
        if canLoadMsgCountSelf == false {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.refreshMsgCount()
            }
        } else {
            refreshMsgCount()
        }
    }
    
    func refreshMsgCount() {
        YZBSign.shared.request(APIURL.msgCount, method: .get, parameters: Parameters()) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let msgCount = dataDic["msgCount"] as? Int
                self.msgUnReadCount = msgCount ?? 0
                self.reloadConversationList()
                
            }
        } failure: { (error) in
            
        }
    }
    
    func loadData() {
        let urlStr = APIURL.getMaterialsList
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            self.tableView.endHeaderRefresh()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.exchangeData = Mapper<MaterialsCorrcetModel>().map(JSON: dataDic as! [String : Any])
            }
            self.tableView.reloadData()
            
        }) { (error) in
            
            // 结束刷新
            self.tableView.endHeaderRefresh()
        }
    }
    //MARK: - 头部搜索，消息待办按钮
    var msgCountLabel = UILabel().textColor(.kDF2F2F).font(10).textAligment(.center).backgroundColor(.white).cornerRadius(7).masksToBounds()
    func configHeaderView(v: UIView) {
        let icon = UIImageView().image(#imageLiteral(resourceName: "purchase_home_icon"))
        let searchBtn = UIButton().backgroundColor(UIColor.hexColor("#DBF1E7")).cornerRadius(15.5).masksToBounds()
        let searchIcon = UIImageView().image(#imageLiteral(resourceName: "item_search"))
        let searchLabel = UILabel().text("搜索你想要的内容").textColor(.kColor99).font(12)
        let messageBtn = UIButton().image(#imageLiteral(resourceName: "purchase_home_message"))
        v.sv(icon, searchBtn, messageBtn)
        v.layout(
            43,
            |-15-icon.width(37).height(45)-21-searchBtn.height(31)-21-messageBtn.size(40)-11-|,
            3
        )
        messageBtn.sv(msgCountLabel)
        messageBtn.layout(
            0,
            msgCountLabel.size(14)-0-|,
            >=0
        )
        msgCountLabel.isHidden = true
        searchBtn.sv(searchIcon, searchLabel)
        searchBtn.layout(
            8.5,
            |-15-searchIcon.size(15)-5-searchLabel,
            7.5
        )
        searchBtn.tapped { [weak self] (btn) in
            let vc = CurrencySearchController()
            self?.navigationController?.pushViewController(vc, animated: false)
        }
        messageBtn.tapped { [weak self] (btn) in
            //let vc = ChatViewController()
            let vc = MessageNotiVC()
            self?.navigationController?.pushViewController(vc)
        }
    }
    //
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = UIImage()
        cycleScrollView.placeHolderImage = UIImage()
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    func configSection0(cell: UITableViewCell) {
        cell.sv(cycleScrollView)
        cell.layout(
            5,
            |-14-cycleScrollView.height(170)-14-|,
            5
        )
        cycleScrollView.delegate = self
        if isSHAccountUserId {
            cycleScrollView.imagePaths = ["http://formal.jcdcbm.com/jcdFile/540ecd6bcdc14423bdb6cca59c44f4db/file/0b729e892d8247c08f7fad2bd7157211.jpg"]
        } else {
            var paths = [String]()
            advertModel?.carouselList?.forEach({ (model) in
                paths.append("\(APIURL.ossPicUrl)/\(model.advertImg ?? "")")
            })
            cycleScrollView.imagePaths = paths
        }
        
    }
    
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        if isSHAccountUserId {
            return
        }
        if cycleScrollView == self.cycleScrollView {
            let model = advertModel?.carouselList?[index]
            if let advertLink = model?.advertLink {
                let vc = UIBaseWebViewController()
                vc.urlStr = advertLink
                if model?.whetherCanShare == "2" {
                    vc.isShare = false
                } else {
                    vc.isShare = true
                }
                navigationController?.pushViewController(vc)
            }
        } else if cycleScrollView == bannerScrollView {
            if let urlStr = advertModel?.indexBottomList?.first?.advertLink {
                let vc = UIBaseWebViewController()
                if advertModel?.indexBottomList?.first?.whetherCanShare == "2" {
                    vc.isShare = false
                } else {
                    vc.isShare = true
                }
                vc.urlStr = urlStr
                navigationController?.pushViewController(vc)
            }
        }
    }
    
    //MARK: - 菜单栏
    func configSection1(cell: UITableViewCell) {
        let icons = [#imageLiteral(resourceName: "purchase_item-0"),#imageLiteral(resourceName: "purchase_item-1"),#imageLiteral(resourceName: "purchase_item-2"),#imageLiteral(resourceName: "purchase_item-3"),#imageLiteral(resourceName: "purchase_item-4"),#imageLiteral(resourceName: "purchase_item-5"),#imageLiteral(resourceName: "purchase_item-6"),#imageLiteral(resourceName: "purchase_item-7"), #imageLiteral(resourceName: "purchase_item-8"),#imageLiteral(resourceName: "purchase_item-9")]
        let titles = ["品牌产品", "区域产品", "装饰公司", "设计机构", "工长工人", "仓储物流", "VR设计", "供需信息", "保险金融", "其他服务"]
        titles.enumerated().forEach { (item) in
            let title = item.element
            let index = item.offset
            let icon = icons[index]
            let btnH: CGFloat = 68
            let btnW: CGFloat = view.width/5
            let offsetX: CGFloat = btnW * (CGFloat(index%5))
            let offsetY: CGFloat = 10 + btnH * (CGFloat(index/5))
            let btn = UIButton().image(icon).text(title).textColor(.kColor33).font(10)
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=10
            )
            btn.layoutButton(imageTitleSpace: -1)
            btn.tag = index
            btn.tapped { [weak self] (tapBtn) in
                self?.toItemVC(tag: tapBtn.tag)
            }
        }
    }
    
    func toItemVC(tag: Int) {
        switch tag {
        case 0:
            toBrandHouse(isFz: 0)
        case 1:
            showEventsAcessDeniedAlert()
            
        case 2:
            toGSGSVC()
        case 3:
            toSJSVC()
        case 4:
            toGRVC()
        case 5:
            if isSHAccountUserId {
                toCCWLVC()
            } else {
                self.noticeOnlyText("开发中，敬请期待～")
            }
        case 6:
            toVR()
        case 7:
            toGXManager()
        case 8:
            toBXJRVC()
        case 9:
            if isSHAccountUserId {
                let vc = GRVC()
                vc.title = "其他服务"
                vc.serviceType = 10001
                navigationController?.pushViewController(vc, animated: true)
            } else {
                self.noticeOnlyText("开发中，敬请期待～")
//                let vc = MembershipDiscountVC()
//                navigationController?.pushViewController(vc)
            }
        default:
            break
        }
    }
    
    // 跳转到设置界面获得位置授权
        func showEventsAcessDeniedAlert() {
            if(CLLocationManager.authorizationStatus() != .denied) {
                print("应用拥有定位权限")
                let vc = DistHomeVC()
                navigationController?.pushViewController(vc)
            }else {
                let alertController = UIAlertController(title: "打开定位开关",
                                                        message: "定位服务未开启,请进入系统设置>隐私>定位服务中打开开关,并允许App使用定位服务",
                                                        preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "设置", style: .default) { (alertAction) in
                    if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)

            }
        }
    
    /// 9.9元成为体验会员，享会员特权
    func vipDistTipPopView1() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 272, height: 188)).backgroundColor(.white)
        let icon = UIImageView().image(#imageLiteral(resourceName: "purchase_icon_vip_tip"))
        let titleLab = UILabel().text("很抱歉，会员专区是新用户专属福利，老用户福利即将上线，敬请期待~").textColor(.kColor66).font(12)
        titleLab.numberOfLines(2).lineSpace(2)
        let ktBtn = UIButton().text("我知道了").textColor(.white).font(14)
        v.sv(icon, titleLab, ktBtn)
        v.layout(
            20,
            icon.size(50).centerHorizontally(),
            10,
            titleLab.width(236).centerHorizontally(),
            >=0,
            ktBtn.width(130).height(30).centerHorizontally(),
            25
        )
        
        ktBtn.corner(radii: 15).fillGreenColorLF()
        ktBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss()
        }
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
    }
    
    
    /// 品牌馆
    func toBrandHouse(isFz: Int) {
        let vc = BrandIntroductionController()
        vc.isFz = isFz
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 装饰公司
    func toGSGSVC() {
        let vc = CompanysVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 设计师
    @objc func toSJSVC() {
        let vc = ServiceMallDesignResourceVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 工人
    @objc func toGRVC() {
        let vc = ServiceMallWorkerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 仓储物流
    func toCCWLVC() {
        let vc = GRVC()
        vc.title = "仓储物流"
        vc.serviceType = 2
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// VR
    func toVR() {
        let vc = VRDesignController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///供需市场
    func toGXManager() {
        let vc = GXGLVC()
        navigationController?.pushViewController(vc)
    }
    
    ///保险金融
    func toBXJRVC() {
        if isSHAccountUserId {
            let vc = GRVC()
            vc.title = "保险金融"
            vc.serviceType = 3
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = BXJRVC()
            navigationController?.pushViewController(vc)
        }
    }
    
    
    //MARK: - 清仓，团购，拼购
    func configSection2(cell: UITableViewCell) {
        let bgIV = UIImageView().image(#imageLiteral(resourceName: "home_bg_2"))
        bgIV.isUserInteractionEnabled = true
        cell.sv(bgIV)
        cell.layout(
            10,
            |-14-bgIV.height(90)-14-|,
            15
        )
        let qcBtn = UIButton().image(#imageLiteral(resourceName: "home_btn_qc")).backgroundColor(UIColor.hexColor("#F4FBF8")).cornerRadius(10).masksToBounds()
        let tgBtn = UIButton().image(#imageLiteral(resourceName: "home_btn_tg")).backgroundColor(UIColor.hexColor("#F4FBF8")).cornerRadius(10).masksToBounds()
        let pgBtn = UIButton().image(#imageLiteral(resourceName: "home_btn_pg")).backgroundColor(UIColor.hexColor("#F4FBF8")).cornerRadius(10).masksToBounds()
        bgIV.sv(qcBtn, tgBtn, pgBtn)
        bgIV.layout(
            10,
            |-12-qcBtn.height(70)-6.5-tgBtn.height(70)-6.5-pgBtn.height(70)-12-|,
            10
        )
        equal(widths: qcBtn, tgBtn, pgBtn)
        qcBtn.tapped { [weak self] (btn) in
            self?.toGXManager()
        }
        tgBtn.tapped { [weak self] (btn) in
            self?.toGXManager()
        }
        pgBtn.tapped { [weak self] (btn) in
            self?.toGXManager()
        }
    }
    
    
    //MARK: - 广告位
    func configSection3(cell: UITableViewCell) {
        if !isSHAccountUserId && (advertModel?.indexTopList?.count ?? 0 > 0) {
            let model = advertModel?.indexTopList?.first
            let btn = UIButton().image(#imageLiteral(resourceName: "home_bg_3")).cornerRadius(5).masksToBounds()
            if let advertImg = model?.advertImg {
                btn.addImage(advertImg)
            }
            
            cell.sv(btn)
            let btnH: CGFloat = 60
            cell.layout(
                10,
                |-14-btn.height(btnH)-14-|,
                10
            )

            btn.tapped { [weak self ] (tapBtn) in
                if let advertLink = model?.advertLink {
                    let vc = UIBaseWebViewController()
                    if model?.whetherCanShare == "2" {
                        vc.isShare = false
                    } else {
                        vc.isShare = true
                    }
                    vc.urlStr = APIURL.webUrl + advertLink
                    self?.navigationController?.pushViewController(vc)
                } else {
                    let vc = MembershipLevelsVC()
                    self?.navigationController?.pushViewController(vc)
                }
            }
        } else {
            let v = UIView()
            cell.sv(v)
            cell.layout(
                0,
                |v.height(1)|,
                0
            )
        }
    }
    
    //MARK: - 会员专区
    func configSection4(cell: UITableViewCell) {
        let content = UIButton().backgroundImage(#imageLiteral(resourceName: "home_icon_hyzq_1"))
        if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
            content.backgroundImage(#imageLiteral(resourceName: "home_icon_hyzq_0"))
        }
        cell.sv(content)
        let iconH: CGFloat = 210 / 375 * view.width
        cell.layout(
            0,
            |-12-content.height(iconH)-12-|,
            10
        )
        
        let titleLabel = UILabel().text("会员专区").textColor(.white).fontBold(18)
        content.sv(titleLabel)
        content.layout(
            8,
            titleLabel.height(25).centerHorizontally(),
            >=0
        )
        
        content.tapped { [weak self] (tapBtn) in
            let vc = UIBaseWebViewController()
            vc.urlStr = APIURL.webUrl + "/other/jcd-active-h5/#/activity?id=8365d861b394bedfe0966eaecc739018&isApp=1"
            vc.isShare = true
            self?.navigationController?.pushViewController(vc)
        }
    }
    
    
    func fillRedColor(v: UIView) {
        v.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.75, green: 0.07, blue: 0.15, alpha: 1).cgColor, UIColor(red: 0.87, green: 0.27, blue: 0.27, alpha: 1).cgColor, UIColor(red: 1, green: 0.46, blue: 0.38, alpha: 1).cgColor]
        bgGradient.locations = [0, 0.25, 1]
        bgGradient.frame = v.bounds
        bgGradient.startPoint = CGPoint(x: 0.52, y: -0.25)
        bgGradient.endPoint = CGPoint(x: 0.48, y: 1.25)
        v.layer.insertSublayer(bgGradient, at: 0)
        v.layer.cornerRadius = 10;
    }
    
    
    //MARK: - 新品专区
    func configSection5(cell: UITableViewCell) {
        
        let content = UIButton().backgroundImage(#imageLiteral(resourceName: "home_icon_thzq"))
        
        content.isUserInteractionEnabled = true
        cell.sv(content)
        let iconH: CGFloat = 246 / 375 * view.width
        let btnW: CGFloat = 107 / 375 * view.width
        let btnH: CGFloat = 155 / 375 * view.width
        cell.layout(
            0,
            |-12-content.height(iconH)-12-|,
            10
        )
        
        let titleLabel = UILabel().text("新品专区").textColor(.white).fontBold(18)
        content.sv(titleLabel)
        content.layout(
            8,
            titleLabel.height(25).centerHorizontally(),
            >=0
        )
        
        exchangeData?.data3?.enumerated().forEach { (item) in
            let index = item.offset
            if index > 2 {
                return
            }
            let model = item.element
            let btn = UIButton().backgroundColor(.white).cornerRadius(10).masksToBounds()
            let offsetX: CGFloat = 10 + (btnW + 5) * CGFloat(index)
            content.sv(btn)
            content.layout(
                57,
                |-offsetX-btn.width(btnW).height(btnH),
                >=0
            )
            let icon = UIImageView().image(#imageLiteral(resourceName: "home_case_btn_iv4")).backgroundColor(.kBackgroundColor)
            icon.contentMode = .scaleAspectFit
            if !icon.addImage(model.imageUrl) {
                icon.image(#imageLiteral(resourceName: "loading"))
            }
            let lab1 = UILabel().text("NEW").textColor(.white).font(8).backgroundColor(UIColor.hexColor("#FF3C2F"))
            lab1.isHidden = true
            let lab2 = UILabel().text("\(model.name ?? "")").textColor(.kColor33).font(12)
            let lab3 = UILabel().text("¥\(model.priceSupplyMin1?.doubleValue ?? 0)").textColor(UIColor.hexColor("#FF3C2F")).font(10)
            
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                lab3.text("¥\(model.priceSupplyMin1?.doubleValue ?? 0)")
            }
            
            if model.isOneSell == 2 {
                lab3.text("¥***")
            }
            btn.sv(icon, lab1, lab2, lab3)
            btn.layout(
                0,
                |icon.height(btnW)|,
                6,
                |-5-lab2.height(12)-5-|,
                6,
                lab3.height(14).centerHorizontally(),
                >=0
            )
            lab2.textAligment(.center)
            btn.layout(
                0,
                lab1.width(26).height(14)-0-|,
                >=0
            )
            lab1.textAligment(.center)
            lab1.corner(byRoundingCorners: [.bottomLeft, .topRight], radii: 5)
            btn.tapped { [weak self] (tapBtn) in
                let vc = MaterialsDetailVC()
                vc.materialsModel = model
                self?.navigationController?.pushViewController(vc)
            }
        }
        
        let moreBtn = UIButton().text("查看更多>>>").textColor(.white).font(10)
        content.sv(moreBtn)
        content.layout(
            >=0,
            moreBtn.height(34).centerHorizontally(),
            0
        )
        moreBtn.tapped { [weak self] (tapBtn) in
            let vc = MaterialsVC()
            vc.type = 1
            self?.navigationController?.pushViewController(vc)
        }
    }
    
    //MARK: - 底部广告位
    private var bannerScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .system
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "service_mall_banner_bg")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "service_mall_banner_bg")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    func configSection6(cell: UITableViewCell) {
        if exchangeData?.advertList?.count != 0 {
            cell.sv(bannerScrollView)
            cell.layout(
                5,
                |-14-bannerScrollView.height(80)-14-|,
                15
            )
            var imagePaths: [String] = []
            exchangeData?.advertList?.forEach({ (model) in
                let imagePath = APIURL.ossPicUrl + (model.advertImg ?? "")
                imagePaths.append(imagePath)
            })
            bannerScrollView.delegate = self
            bannerScrollView.imagePaths = imagePaths
        } else {
            let v = UIView()
            cell.sv(v)
            cell.layout(
                0,
                |v.height(0.5)|,
                0
            )
        }
    }
    
    //MARK: - 特惠专区
    func configSection7(cell: UITableViewCell) {
        
        let btnW: CGFloat = 168 * view.width / 375
        let btnH: CGFloat = 230
        
        let content = UIImageView().image(#imageLiteral(resourceName: "home_th_bg"))
        cell.sv(content)
                
        cell.layout(
            0,
            |-14.5-content.height(40)-14.5-|,
            >=10
        )
        
        let titleLabel = UILabel().text("特惠专区").textColor(.white).fontBold(18)
        content.sv(titleLabel)
        titleLabel.centerInContainer()
        
        exchangeData?.data2?.enumerated().forEach { (item) in
            let index = item.offset
            let model = item.element
            let offsetX: CGFloat = 14 + (btnW+11)*CGFloat(index%2)
            let offsetY: CGFloat = 55 + (btnH+15)*CGFloat(index/2)
            let btn = UIButton().backgroundColor(.white)
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=15
            )
            btn.cornerRadius(5).addShadowColor()
            let icon = UIImageView().image(#imageLiteral(resourceName: "service_mall_banner_bg")).backgroundColor(.kBackgroundColor)
            icon.contentMode = .scaleAspectFit
            if !icon.addImage(model.imageUrl) {
                icon.image(#imageLiteral(resourceName: "loading"))
            }
            let lab1 = UILabel().text("\(model.name ?? "")").textColor(.kColor33).font(12)
            lab1.numberOfLines(2).lineSpace(2)
            let lab2 = UILabel().text("市场价：¥\(model.priceShow?.doubleValue ?? 0)").textColor(.kColor66).font(8.8)
            let lab3 = UILabel().text("会员价：").textColor(.kColor33).font(12)

            let lab4 = UILabel().text("¥\(model.priceSupplyMin1?.doubleValue ?? 0)").textColor(UIColor.hexColor("#DF2F2F")).font(12)
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                lab3.text("销售价：")
            }
            let buyBtn = UIButton().image(#imageLiteral(resourceName: "purchase_home_2"))
            lab2.setLabelUnderline()
            if model.isOneSell == 2 {
                lab3.text("¥***")
            }
            buyBtn.isUserInteractionEnabled = false
            btn.sv(icon, lab1, lab2, lab3, lab4, buyBtn)
            btn.layout(
                0,
                |icon.height(137)|,
                10,
                |-11.5-lab1-11-|,
                >=8,
                |-11.5-lab2.height(8.5)-5-|,
                10.5,
                |-11.5-lab3.height(12)-0-lab4,
                12
            )
            btn.layout(
                >=0,
                buyBtn.size(26)-12-|,
                12
            )
            btn.tapped { [weak self] (tapBtn) in
                let vc = MaterialsDetailVC()
                vc.isMainPageEnter = true
                vc.materialsModel = model
                self?.navigationController?.pushViewController(vc)
            }
        }
    }
}

extension PurchaseHomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            cell.backgroundColor(.clear)
            configSection0(cell: cell)
        case 1:
            configSection1(cell: cell)
        case 2:
            configSection2(cell: cell)
        case 3:
            configSection3(cell: cell)
        case 4:
            configSection4(cell: cell)
        case 5:
            configSection5(cell: cell)
        case 6:
            configSection6(cell: cell)
        case 7:
            configSection7(cell: cell)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.01
        default:
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return UIView()
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


class AdvertModel : NSObject, Mappable {
    var carouselList : [AdvertListModel]?  // 5:轮播图
    var indexBottomList : [AdvertListModel]? // 1:首页-底部
    var indexPopupList : [AdvertListModel]? // 6:首页弹窗
    var indexTopList : [AdvertListModel]? // 3:首页-头部
    var indexWaistList : [AdvertListModel]? // 4:首页-腰部
    var myList : [AdvertListModel]? // 2:我的

    required init?(map: Map){}
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        carouselList <- map["carouselList"]
        indexBottomList <- map["indexBottomList"]
        indexPopupList <- map["indexPopupList"]
        indexTopList <- map["indexTopList"]
        indexWaistList <- map["indexWaistList"]
        myList <- map["myList"]
        
    }

}

