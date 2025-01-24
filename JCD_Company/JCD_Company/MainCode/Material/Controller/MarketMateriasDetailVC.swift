//
//  MarketMateriasDetailVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/11.
//

import UIKit
import Stevia
import WebKit
import TLTransitions
import MBProgressHUD
import ObjectMapper


class MarketMateriasDetailVC: BaseViewController {
    // 以前遗留属性
    var shelfFlag = 0
    var isDismiss = false
    var sjsFlag = false
    var detailType: MaterialsDetailType = .nomarl
    /// 是否是从首页进入
    var isMainPageEnter = false
    var materialsModel = MaterialsModel()
    var currentSKUModel = MaterialsSkuListModel()
    var currentBuyNum = 1
    private var pop: TLTransition!
    private var sharePop: TLTransition?
    private var loadingView = UIView().backgroundColor(.black).alpha(0.6)
    private var loadingIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
    // 现有属性
    private var backBtn = UIButton().image(#imageLiteral(resourceName: "detail_back"))
    private var shareBtn = UIButton().image(#imageLiteral(resourceName: "detail_share"))
    private var messageBtn = UIButton().image(#imageLiteral(resourceName: "detail_message"))
    private var webViewHeight: CGFloat = 0
    private var addText: String {
        get {
            return "立即购买"
        }
    }
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = UIImage()
        cycleScrollView.placeHolderImage = UIImage()
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
    }
    private var countLabel = UILabel().text("1/3").textColor(.white).font(12).cornerRadius(9).backgroundColor(.black).masksToBounds().alpha(0.3)
    private var priceLabel = UILabel().text("￥1786.00").textColor(
        .kRedColor).font(22, weight: .bold)
    private var discountMoneyBtn = UIButton().text("会员预计可省¥1200元 >").textColor(.k2FD4A7).font(12)
    private var nameLabel = UILabel().text("东鹏智能坐便器W8121D").textColor(#colorLiteral(red: 0.1176470588, green: 0.1176470588, blue: 0.1176470588, alpha: 1)).font(18, weight: .bold)
    private var categoryNameLabel = UILabel().text("厨房卫浴·卫浴·智能马桶").textColor(.kColor66).font(13)
    private var sendGoodsLabel = UILabel().text("发货").textColor(.kColor99).font(13)
    private var sendGoodsTimeLabel = UILabel().text("付款后3天内发货").textColor(.kColor1F).font(13)
    
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    private var tableViewHeight: CGFloat = 0.0
    private var bottomView = UIView().backgroundColor(.white)
    private var bottomOffsetView = UIView().backgroundColor(.white)
    private var webView = WKWebView()
    
    /// 特惠
    private var entranceType: String?  // 入口(1:清仓处理  2:每周特惠 ) 为空时正常处理
    var skuId: String? // 清仓处理时必传
    var activityId: String? // 每周特惠时必传
    
    
    // MARK: - 计时器
    var dayLabel = UILabel()
    var hourLabel = UILabel()
    var minuteLabel = UILabel()
    var secondLabel = UILabel()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clearAllNotice()
    }
    private var timer: Timer?
    private var distanceEnds: Int?
    private func starTimerCount() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (seconds) in
            self.distanceEnds = (self.distanceEnds ?? 0) - 1000
            self.dayLabel.text("\(String.secondsToDay(seconds: self.distanceEnds ?? 0))")
            self.hourLabel.text("\(String.secondsToHour(seconds: self.distanceEnds ?? 0))")
            self.minuteLabel.text("\(String.secondsToMinutes(seconds: self.distanceEnds ?? 0))")
            self.secondLabel.text("\(String.secondsToSecond(seconds: self.distanceEnds ?? 0))")
            if self.distanceEnds == 0 {
                self.getMaterialsRequest()
                return
            }
        })
        if let timer1 = timer {
            RunLoop.current.add(timer1, forMode: .common)
        }
        
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "商品详情"
        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 44)
        backBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        let backBarItem = UIBarButtonItem.init(customView: backBtn)
        navigationItem.leftBarButtonItem = backBarItem
        
        let shareBarItem = UIBarButtonItem.init(customView: shareBtn)
        let spaceItem = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        spaceItem.width = 20
        let messageBarItem = UIBarButtonItem.init(customView: messageBtn)
        navigationItem.rightBarButtonItems = [messageBarItem, spaceItem, shareBarItem]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.refreshHeader { [weak self] in
            self?.getMaterialsRequest()
            self?.refreshUserData()
        }
        getMaterialsRequest()
        backBtn.addTarget(self, action: #selector(backBtnClick(btn:)))
        shareBtn.addTarget(self, action: #selector(shareBtnClick(btn:)))
        messageBtn.addTarget(self, action: #selector(messageBtnClick(btn:)))
        
        GlobalNotificationer.add(observer: self, selector: #selector(refresh), notification: .purchaseRefresh)
    }
    
    /// 获取用户数据
    func refreshUserData() {
        let parameters: Parameters = [:]
        var urlStr = ""
        urlStr = APIURL.getUserInfo
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                //储存用户数据
                AppUtils.setUserData(response: response)
                
            }
        }) { (error) in
            
        }
    }
    
    @discardableResult
    private func toAuth() -> Bool {
        
        // 1. 已认证 2.认证失败 3.认证中 4.未认证
        guard let isCheck = UserData.shared.userInfoModel?.register?.isCheck else {
            return false
        }
        switch isCheck {
        case 1:
            return true
        case 2:
            authFailPopView()
        case 3:
            authingPopView()
        case 4:
            smrzPopView()
        default:
            break
        }
        return false
    }
    
    //MARK: - 立即认证(实名认证)
    func smrzPopView() {
        let v = UIView.init(frame: CGRect(x: 0, y: 0, width: 272, height: 222)).backgroundColor(.white)
        let iv = UIImageView().image(#imageLiteral(resourceName: "detail_smrz"))
        let desLabel = UILabel().text("很抱歉！您尚未实名认证，认证后即可购买产品哦~").textColor(.kColor66).font(12)
        desLabel.numberOfLines(2).lineSpace(2)
        desLabel.textAligment(.center)
        let hLine = UIView().backgroundColor(.kColor220)
        let vLine = UIView().backgroundColor(.kColor220)
        
        let unRZBtn = UIButton().text("暂不认证").textColor(.kColor33).font(14)
        let rzBtn = UIButton().text("立即认证").textColor(.k1DC597).font(14)
        
        v.sv(iv, desLabel, hLine, vLine, unRZBtn, rzBtn)
        v.layout(
            15.5,
            iv.width(152).height(105).centerHorizontally(),
            4.5,
            |-24-desLabel-24-|,
            15,
            |hLine.height(0.5)|,
            0,
            |unRZBtn.height(48.5)-0-vLine.width(0.5).height(48.5)-0-rzBtn.height(48.5)|,
            0
        )
        equal(widths: unRZBtn, rzBtn)
        
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop.cornerRadius = 5
        
        unRZBtn.tapped { [weak self] (tapBtn) in
            self?.pop.dismiss()
        }
        rzBtn.tapped { [weak self] (tapBtn) in
            self?.pop.dismiss(completion: {
                let vc = MemberAuthVC()
                self?.navigationController?.pushViewController(vc)
            })
        }
    }
    
    //MARK: - 认证中
    func authingPopView() {
        let v = UIView.init(frame: CGRect(x: 0, y: 0, width: 272, height: 222)).backgroundColor(.white)
        let iv = UIImageView().image(#imageLiteral(resourceName: "detail_authing"))
        let desLabel = UILabel().text("很抱歉！您的认证信息还在审核中，请稍后再试！").textColor(.kColor66).font(12)
        desLabel.numberOfLines(2).lineSpace(2)
        desLabel.textAligment(.center)
        let sureBtn = UIButton().text("确定").textColor(.white).font(14)
        
        
        v.sv(iv, desLabel, sureBtn)
        v.layout(
            15.5,
            iv.width(152).height(105).centerHorizontally(),
            4.5,
            |-24-desLabel-24-|,
            9,
            sureBtn.width(130).height(30).centerHorizontally(),
            25
        )
        
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop.cornerRadius = 5
        
        sureBtn.corner(radii: 15).fillGreenColorLF()
        
        sureBtn.tapped { [weak self] (tapBtn) in
            self?.pop.dismiss()
        }
    }
    
    //MARK: - 认证失败
    func authFailPopView() {
        let v = UIView.init(frame: CGRect(x: 0, y: 0, width: 272, height: 222)).backgroundColor(.white)
        let iv = UIImageView().image(#imageLiteral(resourceName: "detail_auth_fail"))
        let desLabel = UILabel().text("很抱歉！你认证信息审核未通过。").textColor(.kColor66).font(12)
        desLabel.numberOfLines(2).lineSpace(2)
        
        let sureBtn = UIButton().text("查看").textColor(.white).font(14)
        
        desLabel.textAligment(.center)
        v.sv(iv, desLabel, sureBtn)
        v.layout(
            15.5,
            iv.width(152).height(105).centerHorizontally(),
            4.5,
            |-24-desLabel-24-|,
            25.5,
            sureBtn.width(130).height(30).centerHorizontally(),
            25
        )
        
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop.cornerRadius = 5
        
        sureBtn.corner(radii: 15).fillRedColorLF()
        
        sureBtn.tapped { [weak self] (tapBtn) in
            self?.pop.dismiss(completion: {
                let vc = ServiceRegiestFailVC()
                vc.isRZ = true
                vc.regiestModel = UserData.shared.userInfoModel?.register
                vc.reason = UserData.shared.userInfoModel?.register?.remarks
                self?.navigationController?.pushViewController(vc)
            })
        }
    }
    
    @objc func refresh() {
      //  getMaterialsRequest()
    }
    
    // MARK: - 接口请求
    func getMaterialsRequest() {
        let parameters = Parameters()
        self.pleaseWait()
        let urlStr = APIURL.marketingMaterial + (materialsModel.id ?? "")
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { response in
            self.clearAllNotice()
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model1 = Mapper<MaterialsModel>().map(JSON: dataDic as! [String: Any])
                self.materialsModel = model1 ?? MaterialsModel()
                
                if self.materialsModel.upperFlag != "0" { // 产品下架弹窗确认返回
                    self.alertInvalidMaterialView()
                }
                
                if self.detailType == .th {
                    self.distanceEnds = self.materialsModel.promotionalTime
                    self.starTimerCount()
                }
                if self.detailType == .qc || self.detailType == .new {
                    self.currentSKUModel = self.materialsModel.marketingMaterialsSkuList?.first ?? MaterialsSkuListModel()
                }
                self.updateUI()
            } else {
                self.noticeOnlyText(msg)
                self.loadingIndicator.stopAnimating()
                self.loadingView.alpha = 0
            }
        }) { (error) in
            self.updateUI()
            self.loadingIndicator.stopAnimating()
            self.loadingView.alpha = 0
        }
    }
    
    
    func alertInvalidMaterialView() {
        let bgV = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height)).backgroundColor(.clear)
        let v = UIView().backgroundColor(.white)
        bgV.sv(v)
        v.width(272).height(115).centerInContainer()
        let titleLabel = UILabel().text("该产品已下架").textColor(.kColor33).fontBold(14)
        let lineView = UIView().backgroundColor(.kColor220)
        let sureBtn = UIButton().text("知道了").textColor(UIColor.hexColor("#2FD4A7")).font(16)
        v.sv(titleLabel, lineView, sureBtn)
        v.layout(
            22.5,
            titleLabel.height(20).centerHorizontally(),
            22.5,
            |lineView.height(0.5)|,
            0,
            |sureBtn|,
            0
        )
        pop = TLTransition.show(bgV, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
        
        sureBtn.tapped { [weak self] (btn) in
            self?.sureBtnClick()
        }
    }
    
    @objc func sureBtnClick() {
        self.pop?.dismiss(completion: {
            self.navigationController?.popViewController()
        })
    }
    
    
    
    func updateUI() {
        self.tableView.endHeaderRefresh()
        toAuth() // 去认证
        view.sv(tableView, bottomView, bottomOffsetView)
        view.layout(
            0,
            |tableView|,
            0,
            |bottomView.height(50)|,
            0,
            |bottomOffsetView| ~ PublicSize.kBottomOffset,
            0
        )
        configCycleScrollView()
        configBottomView()
        
         let config = WKWebViewConfiguration.init()
         let wkUController = WKUserContentController.init()
         config.userContentController = wkUController
         // 自适应屏幕宽度js
         let jSString = "var imgs = document.getElementsByTagName('img');for(let i = 0; i < imgs.length; i++) {imgs[i].style.height = 'auto'}"
         let wkUseScript = WKUserScript.init(source: jSString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
         // 添加js调用
         wkUController.addUserScript(wkUseScript)
         
         webView = WKWebView.init(frame: .zero, configuration: config)
         webView.scrollView.delegate = self
         webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
         if #available(iOS 11.0, *) {
             webView.scrollView.contentInsetAdjustmentBehavior = .never
         }
        if let urlStr = materialsModel.url, let url = URL.init(string: APIURL.ossPicUrl+urlStr) {
            let request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
            webView.load(request)
        }
        view.sv(loadingView)
        loadingView.size(80).centerInContainer()
        loadingView.cornerRadius(15).masksToBounds()
        loadingView.sv(loadingIndicator)
        loadingIndicator.centerInContainer()
        loadingIndicator.startAnimating()
        
    }
    
    private func configCycleScrollView() {
        cycleScrollView.delegate = self
    }
    private let buyBtn = UIButton().text("立即购买").textColor(.white).font(15)
    func configBottomView() {
        let kfBtn = UIButton().image(#imageLiteral(resourceName: "icon_service")).text("客服").textColor(.kColor66).font(10)
        let ppsBtn = UIButton().image(#imageLiteral(resourceName: "icon_Brand-Owner")).text("品牌").textColor(.kColor66).font(10)
        
        if UserData.shared.userType == .cgy {
            bottomView.sv(kfBtn, ppsBtn, buyBtn)
            bottomView.layout(
                0,
                |kfBtn.width(45).height(50)-0-ppsBtn.width(45).height(50)-10-buyBtn.height(40).centerVertically()-15-|,
                0
            )
        } else if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
            bottomView.sv(buyBtn)
            bottomView.layout(
                0,
                |-40-buyBtn.height(40).centerVertically()-40-|,
                0
            )
            buyBtn.text("查看规格")
        } else {
            bottomView.sv(kfBtn, buyBtn)
            bottomView.layout(
                0,
                |kfBtn.width(45).height(50)-10-buyBtn.height(40).centerVertically()-15-|,
                0
            )
        }
        
        kfBtn.layoutButton(imageTitleSpace: 5)
        ppsBtn.layoutButton(imageTitleSpace: 5)
        
        kfBtn.addTarget(self, action: #selector(kfBtnClick(btn:)))
        ppsBtn.addTarget(self, action: #selector(ppsBtnClick(btn:)))
        buyBtn.addTarget(self, action: #selector(buyBtnClick(btn:)))
        
        
        buyBtn.fillGreenColor()
        buyBtn.corner(radii: 20)
        
        if sjsFlag {
            bottomView.isHidden = true
            shareBtn.isHidden = true
            messageBtn.isHidden = true
        }
        
        if isDismiss {
            bottomView.isHidden = true
            shareBtn.isHidden = false
            messageBtn.isHidden = false
        }
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
            bottomView.isHidden = false
        }
        
    }
}

// MARK: - Button Click Actions
extension MarketMateriasDetailVC {
    /// 返回
    @objc private func backBtnClick(btn: UIButton) {
        if isDismiss {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    /// 分享
    @objc private func shareBtnClick(btn: UIButton) {
//        let manager = ShareManager.init(title: self.materialsModel.name, imageStr: self.materialsModel.transformImageURL, urlStr: self.materialsModel.url, vc: self)
//        manager.share()
        let urlStr = APIURL.webUrl + "/other/jcd-active-h5/#/invitationDetail?id=\(materialsModel.id ?? "")"
        configShareSelectView(title: materialsModel.name, des: "我发现个好东西推荐给你，赶快来看看吧。", imageStr: materialsModel.transformImageURL, urlStr: urlStr, vc: self)
    }
    
    /// 消息
    @objc private func messageBtnClick(btn: UIButton) {
//        let vc = ChatViewController()
//        vc.title = "消息"
//        navigationController?.pushViewController(vc, animated: true)
        let vc = ChatVC()
        vc.title = "消息"
        navigationController?.pushViewController(vc)
    }
    /// 参数点击
    @objc private func paraBtnClick(btn: UIButton) {
        let brand = ("品牌", materialsModel.brandName ?? "无")
        let gg = ("参数", materialsModel.productParamAttr ?? "无")
        let unit = ("单位", materialsModel.unitTypeName ?? "无")
        let weight =  ("重量", materialsModel.sWeight ?? "无")
        let wgg = ("外包装规格", materialsModel.gg ?? "无")
        let tj = ("体积", materialsModel.sExPackagingSize ?? "暂无")
        let zx = ("整箱率", materialsModel.sCapacity ?? "无")
        var arrs = [brand, gg, unit, weight, wgg, tj, zx]
        if materialsModel.unitTypeName != "箱" {
            arrs.removeLast()
        } else {
            let area = ("适用面积", "\(materialsModel.applicableArea ?? "")m²")
            arrs.append(area)
        }
        materialsModel.attrClassification?.attrDataList?.forEach({ (brandModel) in
            var attrs = ""
            brandModel.attrDataValueList?.forEach({ (brandModel1) in
                if !attrs.isEmpty {
                    attrs.append(",")
                }
                attrs.append(brandModel1.attrName ?? "无")
            })
            let attSet = (brandModel.attrName ?? "无", attrs)
            arrs.append(attSet)
        })
        let popView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 44.0*CGFloat(arrs.count+2)+30))
        popView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.text = "产品参数"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.init(netHex: 0x1E1E1E)
        popView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        var upLabel: UILabel = titleLabel
        arrs.forEach {
            let label = UILabel()
            label.text = $0.0
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor.init(netHex: 0x999999)
            popView.addSubview(label)
            
            label.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(20)
                make.height.equalTo(44)
                make.top.equalTo(upLabel.snp.bottom)
                make.width.equalTo(88)
            }
            
            upLabel = label
            
            let subLabel = UILabel()
            subLabel.text = $0.1
            subLabel.font = UIFont.systemFont(ofSize: 14)
            subLabel.textColor = UIColor.init(netHex: 0x1E1E1E)
            popView.addSubview(subLabel)
            
            subLabel.snp.makeConstraints { (make) in
                make.left.equalTo(label.snp.right)
                make.centerY.equalTo(label)
            }
        }
        
        let doneButton = UIButton(type: .custom)
        doneButton.setTitle("完成", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        doneButton.layer.cornerRadius = 4
        doneButton.layer.masksToBounds = true
        doneButton.setBackgroundImage(PublicColor.gradualColorImage, for: .normal)
        popView.addSubview(doneButton)
        doneButton.snp.makeConstraints { (make) in
            make.top.equalTo(upLabel.snp.bottom).offset(8)
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        
        pop = TLTransition.show(popView, popType: TLPopTypeActionSheet)
    }
    
    // 弹框完成
    @objc private func done() {
        pop?.dismiss()
    }
    
    /// 点击客服
    @objc private func kfBtnClick(btn: UIButton) {
        kfClick()
    }
    
    // 客服
    private func kfClick() {
        if materialsModel.id == nil {
            return
        }
        var userId = ""
        var userName = ""
        var storeName = ""
        var headUrl = ""
        var nickname = ""
        var tel1 = ""
        let tel2 = ""
        let storeType = "2"
        
        if let valueStr = materialsModel.merchantId {
            userId = valueStr
        }
        if let valueStr = materialsModel.merchantUserName {
            userName = valueStr
        }
        if let valueStr = materialsModel.merchantName {
            storeName = valueStr
        }
        if let valueStr = materialsModel.merchantHeadUrl {
            headUrl = valueStr
        }
        if let valueStr = materialsModel.merchantRealName {
            nickname = valueStr
        }
        if let valueStr = materialsModel.merchantServicephone {
            tel1 = valueStr
        }
        
        let ex: NSDictionary = ["detailTitle": storeName, "headUrl":headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
        
        let user = JMSGUserInfo()
        user.nickname = nickname
        user.extras = ex as! [AnyHashable : Any]
        YZBChatRequest.shared.createSingleMessageConversation(username: userName) { (conversation, error) in
            
            if error == nil {
                
                if let userInfo = conversation?.target as? JMSGUser {
                    
                    let userName = userInfo.username
                    self.pleaseWait()
                    
                    YZBChatRequest.shared.getUserInfo(with: userName) { (user, error) in
                        self.clearAllNotice()
                        if error == nil {
                            let vc = ChatMessageController(conversation: conversation!)
                            vc.convenUser = user
                            vc.materialModel = self.materialsModel
                
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                
            }else {
                if error!._code == 898002 {
                    
                    YZBChatRequest.shared.register(with: userName, pwd: YZBSign.shared.passwordMd5(password: userName), userInfo: user, errorBlock: { (error) in
                        if error == nil {
                            self.kfClick()
                        }
                    })
                }
            }
        }
    }
    /// 点击品牌商
    @objc private func ppsBtnClick(btn: UIButton) {
        let vc = MaterialSearchController()
        vc.isSecondSearch = true
        vc.isBrand = true
        vc.brandId = materialsModel.brandId ?? ""
        vc.brandName = materialsModel.brandName ?? ""
        vc.title = materialsModel.brandName ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 点击购物车
    @objc private func carBtnClick(btn: UIButton) {
        if UserData.shared.userType == .cgy {
            let vc = WantPurchaseController()
            navigationController?.pushViewController(vc, animated: true)
            
        }
        else if UserData.shared.userType == .jzgs {
            let viewController = ShopCartViewController()
            viewController.isRootVC = false
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    /// 点击添加购物车
    @objc private func addCarBtnClick(btn: UIButton) {
        if !toAuth() {
            return
        }
        if materialsModel.id == nil {
            self.noticeOnlyText("产品读取失败")
            return
        }
        if materialsModel.marketingMaterialsSkuList?.count ==  0  {
            if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
                self.noticeOnlyText("商品信息不全，无法查看规格")
            } else {
                self.noticeOnlyText("商品信息不全，无法添加\(addText)")
            }
            return
        }
        
        let window = UIApplication.shared.windows.first
        let popView = MarketMaterialsDetailRuleView.init(frame: window!.frame, detailModel: materialsModel, currentSKUModel: currentSKUModel, type: .addCart, num: currentBuyNum, detailType: detailType).backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3))
        popView.ruleBtnBlock = { [weak self] (num, detailResult) in
            self?.currentSKUModel = detailResult
            self?.currentBuyNum = num
        }
        popView.addCarBtnBlock = { [weak self] (num, detailResult) in
            self?.currentSKUModel = detailResult
            self?.currentBuyNum = num
            self?.addCartRequest()
        }
        window?.addSubview(popView)
    }
    
    
    func addCartRequest() {
        var parameters = [String: Any]()
        parameters["skuId"] = currentSKUModel.id
        parameters["num"] = "\(currentBuyNum)"
        parameters["operType"] = 2
        
        self.pleaseWait()
        let urlStr = APIURL.saveCartList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("添加\(self.addText)成功", autoClear: true, autoClearTime: 0.8)
            }
        }) { (error) in  }
    }
    
    /// 点击购买
    @objc private func buyBtnClick(btn: UIButton) {
        if !toAuth() {
            return
        }
        if materialsModel.isOneSell == 2 && UserData.shared.userType != .gys && UserData.shared.userType != .yys {
            self.noticeOnlyText("需选两个或以上同一品牌下组合购产品一同下单")
            return
        }
        
        if materialsModel.marketingMaterialsSkuList?.count ==  0 {
            self.noticeOnlyText("商品信息不全，无法购买")
            return
        }
        
        let window = UIApplication.shared.windows.first
        let popView = MarketMaterialsDetailRuleView.init(frame: window!.frame, detailModel: materialsModel, currentSKUModel: currentSKUModel, type: .buy, num: currentBuyNum, detailType: detailType).backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3))
        popView.ruleBtnBlock = { [weak self] (num, detailResult) in
            self?.currentSKUModel = detailResult
            self?.currentBuyNum = num
        }
        popView.addCarBtnBlock = { [weak self] (num, detailResult) in
            self?.currentSKUModel = detailResult
            self?.currentBuyNum = num
            self?.tableView.reloadData()
            self?.buy()
        }
        window?.addSubview(popView)
        
        
    }

    private func buy() {
        materialsModel.buyCount = NSNumber(value: currentBuyNum)
        let vc = PlaceOrderController()
        vc.enterType = .fromDetail
        vc.currentSKUModel = currentSKUModel
        vc.rowsData = [materialsModel]
        vc.activityId = materialsModel.marketId
        vc.detailType = .hyzx
        navigationController?.pushViewController(vc, animated: true)
    }
}



// MARK: - LLCycleScrollViewDelegate
extension MarketMateriasDetailVC: LLCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        var urls: [URL] = [];
        let fileUrls = cycleScrollView.imagePaths
        fileUrls.forEach({ (fileUrl) in
            let urlStr = fileUrl
            let url = URL.init(string: urlStr)
            if let url1 = url {
                urls.append(url1)
            }
        })
        let phoneVC = IMUIImageBrowserController()
        phoneVC.imageArr = urls
        phoneVC.imgCurrentIndex = index
        phoneVC.title = "查看大图"
        phoneVC.modalPresentationStyle = .overFullScreen
        self.present(phoneVC, animated: true, completion: nil)
    }
    
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, scrollTo index: NSInteger) {
        print("index: \(index)")
        print("index:count: \(index):\(cycleScrollView.imagePaths.count)")
        countLabel.text = " \(index+1)/\(cycleScrollView.imagePaths.count) "
    }
}

// MARK: - tableview delegate datasource
extension MarketMateriasDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if materialsModel.materialsType == 2 {
            return 2
        }
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        let section = indexPath.section
        //let row = indexPath.row
        if section == 0 {
            configSection0(cell)
        }
        if section == 1 {
            configSection1(cell)
        }
        if section == 2 {
            configSection2(cell)
        }
        if section == 3 {
            configSection3(cell)
        }
        if section == 4 {
            configSection4(cell)
        }
        return cell
    }
    
    func configSection0(_ cell: UITableViewCell) {
        let v = UIView().backgroundColor(.red)
        cell.sv(v)
        cell.layout(
            0,
            |v| ~ PublicSize.kScreenWidth,
            0
        )
        v.sv(cycleScrollView, countLabel)
        cycleScrollView.followEdges(v)
        if materialsModel.scrollImages.count > 0 {
            self.cycleScrollView.imagePaths = materialsModel.scrollImages
        }
        v.layout(
            >=0,
            countLabel.width(35).height(18)-20-|,
            15
        )
        countLabel.textAlignment = .center
        countLabel.text = "1/\(cycleScrollView.imagePaths.count)"
    }
    
    //正常
    func configSection1(_ cell: UITableViewCell) {
        let tipLabel = UILabel().text("需选两个或以上同一品牌下组合购产品一同下单").textColor(.red).font(14)
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            0,
            |v|,
            0
        )
        v.sv(priceLabel, nameLabel, categoryNameLabel, tipLabel,  discountMoneyBtn)
        v.layout(
            20,
            |-18-priceLabel.height(22)-(>=0)-discountMoneyBtn.height(25)-14-|,
            15,
            |-18-nameLabel-18-|,
            14,
            |-18-categoryNameLabel.height(13),
            >=15
        )
        nameLabel.numberOfLines(0).lineSpace(2)
        v.layout(
            >=0,
            |-18-tipLabel.height(16),
            5
        )
        if materialsModel.isOneSell == 2 && UserData.shared.userType != .gys && UserData.shared.userType != .yys {
            tipLabel.isHidden = false
            categoryNameLabel.isHidden = true
        } else {
            tipLabel.isHidden = true
            categoryNameLabel.isHidden = false
        }
        nameLabel.text(materialsModel.name ?? "")
        categoryNameLabel.text(materialsModel.cate ?? "")
        discountMoneyBtn.isHidden = true
        if UserData.shared.userType == .jzgs {
            if let valueStr1 = materialsModel.priceSellMin?.doubleValue, let valueStr2 = materialsModel.priceSellMax?.doubleValue {
                let totalStr1 = valueStr1.notRoundingString(afterPoint: 2)
                let totalStr2 = valueStr2.notRoundingString(afterPoint: 2)
                if totalStr1 == totalStr2 {
                    priceLabel.text = String.init(format: "￥%@", totalStr1)
                } else {
                    priceLabel.text = String.init(format: "￥%@-%@", totalStr1, totalStr2)
                }
            } else {
                priceLabel.text = "￥0"
            }
        }
        else if UserData.shared.userType == .cgy {
            if let valueStr1 = materialsModel.activityPriceMin?.doubleValue, let valueStr2 = materialsModel.activityPriceMax?.doubleValue {
                let totalStr1 = valueStr1.notRoundingString(afterPoint: 2)
                let totalStr2 = valueStr2.notRoundingString(afterPoint: 2)
                if totalStr1 == totalStr2 {
                    priceLabel.text = String.init(format: "￥%@", totalStr1)
                } else {
                    priceLabel.text = String.init(format: "￥%@-%@", totalStr1, totalStr2)
                }
            } else {
                priceLabel.text = "￥0"
            }
        }
        else if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
            if let valueStr1 = materialsModel.activityPriceMin?.doubleValue, let valueStr2 = materialsModel.activityPriceMax?.doubleValue {
                let totalStr1 = valueStr1.notRoundingString(afterPoint: 2)
                let totalStr2 = valueStr2.notRoundingString(afterPoint: 2)
                priceLabel.text = String.init(format: "￥%@-%@", totalStr1, totalStr2)
            } else {
                priceLabel.text = "￥0"
            }
        }
        
    }
    
    
    func configSection2(_ cell: UITableViewCell) {
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            0,
            |v| ~ 96,
            0
        )
        let v2 = UIView()
        let v3 = UIButton()
        v.sv(v2, v3)
        v.layout(
            0,
            |v2| ~ 48,
            0,
            |v3| ~ 48,
            0
        )
        // 发货
        let can1IV = UIImageView().image(#imageLiteral(resourceName: "icon_tag_allow"))
        let can1Lab = UILabel().text("整箱发货").textColor(.kColor99).font(11)
        let can2IV = UIImageView().image(#imageLiteral(resourceName: "icon_tag_allow"))
        let can2Lab = UILabel().text("包运费").textColor(.kColor99).font(11)
        let can3IV = UIImageView().image(#imageLiteral(resourceName: "icon_tag_allow"))
        let can3Lab = UILabel().text("不上楼").textColor(.kColor99).font(11)
        let can4IV = UIImageView().image(#imageLiteral(resourceName: "icon_tag_allow"))
        let can4Lab = UILabel().text("提供安装").textColor(.kColor99).font(11)
        v2.sv(sendGoodsLabel, sendGoodsTimeLabel, can1IV, can2IV, can3IV, can4IV, can1Lab, can2Lab, can3Lab, can4Lab)
        |-20-sendGoodsLabel.centerVertically()-10-sendGoodsTimeLabel.centerVertically()
        
        let time = Utils.getFieldValInDirArr(arr: AppData.yzbSendTermList, fieldA: "value", valA: "\(materialsModel.recevingTerm ?? "")", fieldB: "label")
        sendGoodsTimeLabel.text = time
        if let unitType = materialsModel.unitType{
            let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitType)", fieldB: "label")
            if unitStr == "箱" {
                v2.layout(
                    >=0,
                    |-55-can1IV.size(10)-3-can1Lab-11-can2IV.size(10)-3-can2Lab-11-can3IV.size(10)-3-can3Lab-11-can4IV.size(10)-3-can4Lab,
                    0
                )
                can1Lab.text = materialsModel.remake1
                if materialsModel.allDeliverFlag?.isTrue ?? false {
                    can1IV.image(#imageLiteral(resourceName: "icon_tag_allow"))
                } else {
                    can1IV.image(#imageLiteral(resourceName: "icon_tag_unallowed"))
                }
                
            }
            else {
                [can1Lab,can1IV].forEach { $0?.isHidden = true }
                v2.layout(
                    >=0,
                    |-55-can2IV.size(10)-3-can2Lab-11-can3IV.size(10)-3-can3Lab-11-can4IV.size(10)-3-can4Lab,
                    0
                )
            }
        }
        else {
            [can1Lab,can1IV].forEach { $0?.isHidden = true }
            v2.layout(
                >=0,
                |-55-can2IV.size(10)-3-can2Lab-11-can3IV.size(10)-3-can3Lab-11-can4IV.size(10)-3-can4Lab,
                0
            )
        }
        can2Lab.text = materialsModel.remake2
        can3Lab.text = materialsModel.remake3
        can4Lab.text = materialsModel.remake4
        if materialsModel.logisticsFlag?.isTrue ?? false {
            can2IV.image(#imageLiteral(resourceName: "icon_tag_allow"))
        } else {
            can2IV.image(#imageLiteral(resourceName: "icon_tag_allow"))
        }
        if materialsModel.upstairsFlag?.isTrue ?? false {
            can3IV.image(#imageLiteral(resourceName: "icon_tag_allow"))
        } else {
            can3IV.image(#imageLiteral(resourceName: "icon_tag_allow"))
        }
        if materialsModel.installationFlag?.isTrue ?? false {
            can4IV.image(#imageLiteral(resourceName: "icon_tag_allow"))
        } else {
            can4IV.image(#imageLiteral(resourceName: "icon_tag_allow"))
        }
        // 参数
        let paraLabel = UILabel().text("参数").textColor(.kColor99).font(13)
        let paraDetailLabel = UILabel().text("品牌 规格...").textColor(.kColor1F).font(13)
        let paraIV = UIImageView().image(#imageLiteral(resourceName: "order_arrow"))
        v3.sv(paraLabel, paraDetailLabel, paraIV)
        |-20-paraLabel.centerVertically()-10-paraDetailLabel.centerVertically()-(>=0)-paraIV.width(6).height(10).centerVertically()-20-|
        v3.addTarget(self, action: #selector(paraBtnClick(btn:)))
    }
    
    func configSection3(_ cell: UITableViewCell) {
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            0,
            |v.height(141)|,
            0
        )
        let icon = UIImageView().image(#imageLiteral(resourceName: "icon_tag_unallowed"))
        let lab1 = UILabel().text("购买须知").textColor(.kColor33).fontBold(14)
        let lab2 = UILabel().text("服务项：").textColor(.kColor33).fontBold(12)
        let lab3 = UILabel().text("不含物流费、不提供安装、不支持送货上楼、非整箱发货").textColor(.kColor66).font(12)
        let lab4 = UILabel().text("其他规则：").textColor(.kColor33).fontBold(12)
        let lab5 = UILabel().text("如需定制，请联系客服人员").textColor(.kColor66).font(12)
        v.sv(icon, lab1, lab2,lab3, lab4, lab5)
        v.layout(
            18,
            |-14-icon.size(14)-3-lab1,
            13,
            |-14-lab2.height(16.5),
            5,
            |-14-lab3.height(16.5)-14-|,
            5,
            |-14-lab4.height(16.5),
            5,
            |-14-lab5.height(16.5),
            15
        )
    }
    
    func configSection4(_ cell: UITableViewCell) {
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            0,
            |v|,
            0
        )
        v.sv(webView)
        v.layout(
            0,
            |webView.height(webViewHeight)|,
            0
        )
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 3  {
            return 5.0
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.kBackgroundColor)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - WKNavigationDelegate
extension MarketMateriasDetailVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight") { (result, error) in
            self.webViewHeight = result as? CGFloat ?? 0
        }
        tableView.reloadData {
            webView.alpha = 1
            self.loadingIndicator.stopAnimating()
            self.loadingView.alpha = 0
        }
    }
}


private extension String {
    
    // 扩展字段，判断返回字段是否为是
    var isTrue: Bool {
        get {
            return self == "2"
        }
    }
}



// MARK: - 爆款弹出框视图
class MarketMaterialsDetailRuleView: UIView {
    enum MaterialsDetailBtnType {
        case addCart
        case buy
    }
    
    var detailModel: MaterialsModel?
    var currentSKUModel = MaterialsSkuListModel()
    var btnType: MaterialsDetailBtnType = .buy
    var detailType: MaterialsDetailType = .nomarl
    private let popView = UIView().backgroundColor(.white)
    private let h: CGFloat = 590
    private var productNum = 1
    init(frame: CGRect, detailModel: MaterialsModel?, currentSKUModel: MaterialsSkuListModel?, type: MaterialsDetailBtnType, num: Int, detailType: MaterialsDetailType) {
        super.init(frame: frame)
        self.detailModel = detailModel
        self.currentSKUModel = currentSKUModel ?? MaterialsSkuListModel()
        self.productNum = num
        self.btnType = type
        self.detailType = detailType
        popView.frame = CGRect(x: 0, y: frame.height, width: frame.width, height: h)
        popView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 10)
        addSubview(popView)
        UIView.animate(withDuration: 0.3) {
            self.popView.frame.origin.y -= self.h
        }
        addTopView()
        addScrollView()
        addBottomView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private let goodsIV = UIImageView().backgroundColor(.kBackgroundColor)
    private let price = UILabel().text("￥1699.00").textColor(.kDF2F2F).font(14)
    private let price1 = UILabel().text("￥1699.00").textColor(.kColor99).font(12)
    private let num = UILabel().text("库存34530件").textColor(.kColor66).font(10)
    private let rule = UILabel().text("选择 规格").textColor(.kColor33).font(12)
    private let closeBtn = UIButton().image(#imageLiteral(resourceName: "plus_close_icon"))
    private func addTopView() {
        popView.sv(goodsIV, price, price1, num, rule, closeBtn)
        popView.layout(
            14,
            |-14-goodsIV.size(100),
            >=0
        )
        popView.layout(
            39.5,
            |-124-price.height(20)-15-price1,
            5,
            |-124-num.height(14),
            5,
            |-124-rule.height(16.5),
            >=0
        )
        popView.layout(
            5,
            closeBtn.size(40)-5-|,
            >=0
        )
        goodsIV.contentMode = .scaleAspectFit
        goodsIV.cornerRadius(5).masksToBounds()
        closeBtn.addTarget(self, action: #selector(closeBtnClick))
        price1.isHidden = true
        if detailModel?.isOneSell == 2 && UserData.shared.userType != .gys && UserData.shared.userType != .yys {
            goodsIV.addImage(detailModel?.imageUrl)
            price.text("￥\(detailModel?.priceShow ?? 0)")
            price.setLabelUnderline()
        } else {
            if currentSKUModel.id != nil {
                goodsIV.addImage(currentSKUModel.image)
                price1.isHidden = true
                if UserData.shared.userType == .cgy {
                    price.text("￥\(currentSKUModel.activityPrice ?? 0)")
                } else {
                    if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
                        price.text("￥\(currentSKUModel.activityPrice ?? 0)")
                    } else {
                        price.text("￥\(currentSKUModel.activityPrice ?? 0)")
                    }
                    
                }
                num.text("库存\(currentSKUModel.stockNum ?? 0)")
                if detailModel?.skuFlag == 2 || detailModel?.marketingMaterialsSkuList?.count == 0 {
                    rule.isHidden = true
                } else {
                    rule.isHidden = false
                }
                rule.text("已选：”\(currentSKUModel.skuAttr1 ?? "未知")“")
                
            } else {
                goodsIV.addImage(detailModel?.imageUrl)
                price1.isHidden = true
                if UserData.shared.userType == .cgy {
                    if detailModel?.activityPriceMin == detailModel?.activityPriceMax {
                        price.text("￥\(detailModel?.activityPriceMin ?? 0)")
                    } else {
                        price.text("￥\(detailModel?.activityPriceMin ?? 0)-\(detailModel?.activityPriceMax ?? 0)")
                    }
                    
                } else {
                    if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
                        price.text("￥\(detailModel?.activityPriceMin ?? 0)")
                    } else {
                        if detailModel?.activityPriceMin == detailModel?.activityPriceMax {
                            price.text("￥\(detailModel?.activityPriceMin ?? 0)")
                        } else {
                            price.text("￥\(detailModel?.activityPriceMin ?? 0)-\(detailModel?.activityPriceMax ?? 0)")
                        }
                    }
                }
                var stockNum: Int = 0
                detailModel?.marketingMaterialsSkuList?.forEach({ (item) in
                    stockNum += (item.stockNum ?? 0)
                })
                num.text("库存\(stockNum)")
                if detailModel?.skuFlag == 2 || detailModel?.marketingMaterialsSkuList?.count == 0 {
                    rule.isHidden = true
                } else {
                    rule.isHidden = false
                }
            }
            
        }
    }
    
    @objc func closeBtnClick() {
        hide()
    }
    
    private let scrollView = UIScrollView().backgroundColor(.white)
    private let ruleLabel = UILabel().text("规格").textColor(.kColor33).font(14)
    private let ruleBGView = UIView()
    private var ruleBtns = [UIButton]()
    private let line = UIView().backgroundColor(.kColor230)
    private let buyNumDesLabel = UILabel().text("购买数量").textColor(.kColor33).font(14)
    private let minusBtn = UIButton().image(#imageLiteral(resourceName: "detail_minute"))
    private let buyNumLabel = UILabel().text("1").textColor(.kColor33).font(14).textAligment(.center).backgroundColor(.kColorEE)
    private let plusBtn = UIButton().image(#imageLiteral(resourceName: "detail_plus"))
    private func addScrollView() {
        popView.sv(scrollView)
        popView.layout(
            128,
            |scrollView.width(PublicSize.screenWidth)|,
            98
        )
        scrollView.layoutIfNeeded()
        scrollView.sv(ruleLabel, ruleBGView, line, buyNumDesLabel, minusBtn, buyNumLabel, plusBtn)
        scrollView.layout(
            11,
            |-14-ruleLabel.height(20),
            0,
            |ruleBGView.width(PublicSize.screenWidth)|,
            0,
            |-14-line.height(1)-14-|,
            21,
            |-14-buyNumDesLabel.width(100).height(20)-(>=0)-minusBtn.size(22)-1-buyNumLabel.width(31).height(22)-1-plusBtn.size(22)-14-|,
            20
        )
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys || detailType == .qc {
            buyNumDesLabel.isHidden = true
            minusBtn.isHidden = true
            buyNumLabel.isHidden = true
            plusBtn.isHidden = true
        }
        buyNumLabel.text("\(productNum)")
        if productNum == 1 {
            minusBtn.image(#imageLiteral(resourceName: "detail_minute"))
            minusBtn.isUserInteractionEnabled = false
        } else {
            minusBtn.image(#imageLiteral(resourceName: "detail_minute"))
            minusBtn.isUserInteractionEnabled = true
        }
        minusBtn.addTarget(self, action: #selector(minusBtnClick(btn:)))
        plusBtn.addTarget(self, action: #selector(plusBtnClick(btn:)))
        configView()
        
    }
    var ruleBtnBlock: ((Int, MaterialsSkuListModel) -> Void)?
    var addCarBtnBlock: ((Int, MaterialsSkuListModel) -> Void)?
    @objc private func ruleBtnClick(btn: UIButton) {
        self.currentSKUModel = detailModel?.marketingMaterialsSkuList?[btn.tag] ?? MaterialsSkuListModel()
        ruleBtns.forEach { (ruleBtn) in
            if ruleBtn.tag == btn.tag {
                ruleBtn.textColor(#colorLiteral(red: 0.003921568627, green: 0.5333333333, blue: 0.3019607843, alpha: 1)).backgroundColor(#colorLiteral(red: 0.8509803922, green: 0.9294117647, blue: 0.8941176471, alpha: 1)).borderColor(#colorLiteral(red: 0.003921568627, green: 0.5333333333, blue: 0.3019607843, alpha: 1))
            } else {
                ruleBtn.textColor(.kColor33).backgroundColor(.kBackgroundColor).borderColor(.kBackgroundColor)
            }
        }
        goodsIV.addImage(currentSKUModel.image)
        if UserData.shared.userType == .cgy {
            price.text("￥\(currentSKUModel.activityPrice ?? 0)")
        } else if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
            price.text("￥\(currentSKUModel.activityPrice ?? 0)")
        }
        else {
            price.text("￥\(currentSKUModel.activityPrice ?? 0)")
        }
        num.text("库存\(currentSKUModel.stockNum ?? 0)件")
        rule.text("已选:“\(currentSKUModel.skuAttr1 ?? "未知")”")
        ruleBtnBlock?(productNum, currentSKUModel)
    }
    
    @objc private func minusBtnClick(btn: UIButton) {
        productNum -= 1
        buyNumLabel.text("\(productNum)")
        if productNum == 1{
            minusBtn.image(#imageLiteral(resourceName: "detail_minute"))
            minusBtn.isUserInteractionEnabled = false
        }
        ruleBtnBlock?(productNum, currentSKUModel)
        
    }
    
    @objc private func plusBtnClick(btn: UIButton) {
        productNum += 1
        buyNumLabel.text("\(productNum)")
        if productNum > 1{
            minusBtn.image(#imageLiteral(resourceName: "detail_minute"))
            minusBtn.isUserInteractionEnabled = true
        }
        ruleBtnBlock?(productNum, currentSKUModel)
    }
    
    private let groupBuyBtn = UIButton().text("加入购物车").textColor(.white).font(14)
    private func addBottomView() {
        popView.sv(groupBuyBtn)
        popView.layout(
            >=0,
            |-58.5-groupBuyBtn.height(34)-52.5-|,
            42
        )
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
            groupBuyBtn.isHidden = true
        }
        groupBuyBtn.addTarget(self, action: #selector(groupBuyBtnClick))
        if btnType == .addCart {
            if UserData.shared.userType == .cgy {
                groupBuyBtn.text("加入预购清单")
            }
            groupBuyBtn.fillYelloColor()
        } else {
            groupBuyBtn.text("立即购买").fillGreenColor()
        }
        groupBuyBtn.cornerRadius(17).masksToBounds()
    }
    
    @objc private func groupBuyBtnClick() {
        if currentSKUModel.id == nil && detailModel?.skuFlag == 1 {
            noticeOnlyText("请选择规格")
            return
        }
        addCarBtnBlock?(productNum, currentSKUModel)
        hide()
    }
    
    func configView() {
        if detailModel?.skuFlag == 2 || detailModel?.isOneSell == 2 && UserData.shared.userType != .gys && UserData.shared.userType != .yys {
            ruleLabel.isHidden = true
            currentSKUModel = detailModel?.marketingMaterialsSkuList?.first ?? MaterialsSkuListModel()
        } else {
            if detailModel?.marketingMaterialsSkuList?.count == 0 {
                ruleLabel.isHidden = true
            }
            detailModel?.marketingMaterialsSkuList?.enumerated().forEach { (item) in
                let index = item.offset
                let ruleModel = item.element
                let w: CGFloat = (PublicSize.kScreenWidth-15-28)/2
                let h: CGFloat = 35
                let offsetX: CGFloat = 14+(w+15)*CGFloat((index%2))
                let offsetY: CGFloat = 14+CGFloat(45*(index/2))
                let btn = UIButton().text(ruleModel.skuAttr1 ?? "未知").textColor(.kColor33).font(12).backgroundColor(.kBackgroundColor).borderColor(.kColorF8).borderWidth(0.5).cornerRadius(6)
                ruleBGView.sv(btn)
                ruleBGView.layout(
                    offsetY,
                    |-offsetX-btn.width(w).height(h),
                    >=20
                )
                if ruleModel.id == currentSKUModel.id {
                    btn.textColor(#colorLiteral(red: 0.003921568627, green: 0.5333333333, blue: 0.3019607843, alpha: 1)).backgroundColor(#colorLiteral(red: 0.8509803922, green: 0.9294117647, blue: 0.8941176471, alpha: 1)).borderColor(#colorLiteral(red: 0.003921568627, green: 0.5333333333, blue: 0.3019607843, alpha: 1))
                }
                btn.tag = index
                ruleBtns.append(btn)
                if detailType != .qc {
                    btn.addTarget(self, action: #selector(ruleBtnClick(btn:)))
                }
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.enumerated().forEach { (item) in
            if item.element.view == self {
                self.hide()
            }
        }
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popView.frame.origin.y += self.h
        }) { (animted) in
            self.removeFromSuperview()
        }
    }
}

