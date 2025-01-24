//
//  RetailDetailController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/27.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import WebKit
import ObjectMapper
import PopupDialog
import JWNetAutoCache

enum DetailType {
    
    case detail             //主材详情
    case addCart            //详情+购物车
    case scanAddCart        //扫码详情+购物车
    case select             //详情+主材包选材
    case scanSelect         //扫码详情+主材包选材
    case scanFree           //扫码详情+主材包选材(自由开单)
    case addShop            //详情+自由组合选材
    case scanAddShop        //扫码详情+自由组合选材
}


class MaterialDetailController: BaseViewController, WKNavigationDelegate, UIScrollViewDelegate {

    var detailType: DetailType = .detail
    
    var navView: UIView!                    //自定义导航栏
    var backBtn: UIButton!                  //返回按钮
    var cartBtn: UIButton!                  //购物车
    var shareBtn: UIButton!                 //分享
    var titleLabel: UILabel!                //标题
    var switchPriceBtn: UIButton!           //切换价格显示
    var selectBtn: UIButton!                //选择
    var addBtn: UIButton!                   //添加
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var priceShowLabel: UILabel!
    var priceShowTitle: UILabel!
    var addCartBtn: UIButton!                       //添加购物车
    var buyNowBtn: UIButton!                        //单品立即购买
    var singleLabel: UILabel!                       //支持单品购买
    var contactSellerBtn: UIButton!                 //联系卖家
    var materialsModel: MaterialsModel?
    var materialsId = ""
    var imageUrl: URL?
    var selectBlock: ((_ materialsModel: MaterialsModel)->())?
    
    var packageModel: PackageModel?                 //主材包模型
    var addPlusMaterialBlock: (()->())?             //选择block
    var queryPlusMaterialBlock: ((_ materialsId: String)->(MaterialsModel?))?       //查询是否是主材包主推
    var isPlusMaterial = false                      //是否是主材包主推
    
    var isHome = false //是否是首页跳过，显示查看全部主材
    
    deinit {
        JWCacheURLProtocol.cancelListeningNetWorking()
        AppLog(">>>>>>>>>>>>>>>>>>> 主材详情页释放 <<<<<<<<<<<<<<<<<<")
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.uiDelegate = nil
            webView.navigationDelegate = nil
            webView.scrollView.delegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        createSubView()
        prepareNavigationItem()
        
        if materialsId != "" {
            if detailType == .scanSelect {
                
                if let block = queryPlusMaterialBlock {
                    if let material = block(materialsId) {
                        materialsModel = material
                        isPlusMaterial = true
                    }else {
                        loadData()
                    }
                }
            }else {
                loadData()
            }
        }
        
        if materialsModel != nil {
            paddingData()
        }
        
        ///采购员
        if UserData.shared.userType == .cgy {
            loadisExistPurList()
        }
        else {
            loadisExistCartList()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isTranslucent = true
        self.statusStyle = .default
        
        navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
       navigationController?.setNavigationBarHidden(false, animated: true)

    }
    //MARK: - 自定义导航栏
    func prepareNavigationItem() {
        
        navView = UIView.init()
        navView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xFFFFFF, alpha: 0)
        navView.layerShadow()
        view.addSubview(navView)

        navView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            } else {
                make.bottom.equalTo(view.snp.top).offset(64)
            }
        }

        //返回按钮
        backBtn = UIButton.init()
        backBtn.setImage(UIImage(named: "back_white"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
        backBtn.layer.cornerRadius = 15
        backBtn.layer.masksToBounds = true
        navView.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-7)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(30)
        }
        
        //标题
        titleLabel = UILabel.init()
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.text = ""
        titleLabel.alpha = 0
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        navView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn)
            make.right.equalTo(-80)
            make.left.equalTo(80)
        }
        
        
        shareBtn = UIButton.init()
        shareBtn.setImage(UIImage(named: "share_nav_white"), for: .normal)
        shareBtn.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        shareBtn.backgroundColor = backBtn.backgroundColor
        shareBtn.layer.cornerRadius = 15
        shareBtn.layer.masksToBounds = true
        
        switch detailType {
        case .addCart, .scanAddCart:
            
//            navView.addSubview(shareBtn)
//
//            shareBtn.snp.makeConstraints { (make) in
//                make.centerY.equalTo(backBtn)
//                make.right.equalToSuperview().offset(-8)
//                make.width.height.equalTo(30)
//            }
            
            cartBtn = UIButton.init()
            cartBtn.setImage(UIImage(named: "icon_shop_white"), for: .normal)
            cartBtn.addTarget(self, action: #selector(goCartAction), for: .touchUpInside)
            cartBtn.backgroundColor = backBtn.backgroundColor
            cartBtn.layer.cornerRadius = 15
            cartBtn.layer.masksToBounds = true
            navView.addSubview(cartBtn)
            cartBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(backBtn)
//                make.right.equalTo(shareBtn.snp.left).offset(-8)
                make.right.equalToSuperview().offset(-8)
                make.width.height.equalTo(30)
            }
            if UserData.shared.userType == .cgy {
               cartBtn.isHidden = true
            }
            break
            
        case .select, .scanSelect, .scanFree:
            
            selectBtn = UIButton(type: .custom)
            selectBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
            selectBtn.setTitle("选择", for: .normal)
            selectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            selectBtn.setTitleColor(UIColor.white, for: .normal)
            selectBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
            selectBtn.layer.cornerRadius = 12.5
            selectBtn.layer.masksToBounds = true
            selectBtn.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
            navView.addSubview(selectBtn)
            selectBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(backBtn)
                make.right.equalToSuperview().offset(-8)
                make.width.equalTo(45)
                make.height.equalTo(25)
            }

            break
            
        case .detail:
            
//            navView.addSubview(shareBtn)
//            
//            shareBtn.snp.makeConstraints { (make) in
//                make.centerY.equalTo(backBtn)
//                make.right.equalToSuperview().offset(-8)
//                make.width.height.equalTo(30)
//            }

            break
            
        case .scanAddShop, .addShop:
            
            //添加
            addBtn = UIButton(type: .custom)
            addBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
            addBtn.setTitle("添加", for: .normal)
            addBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            addBtn.setTitleColor(UIColor.white, for: .normal)
            addBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
            addBtn.layer.cornerRadius = 12.5
            addBtn.layer.masksToBounds = true
            addBtn.addTarget(self, action: #selector(addShopAction), for: .touchUpInside)
            navView.addSubview(addBtn)
            
            addBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(backBtn)
                make.right.equalToSuperview().offset(-8)
                make.width.equalTo(45)
                make.height.equalTo(25)
            }
            break
        }
    }
    
    func createSubView() {
        
        //底部结算栏
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
            } else {
                make.height.equalTo(44)
            }
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        bottomView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //立即购买
        let backgroundImg = PublicColor.gradualColorImage_buyBtn
        let backgroundHImg = PublicColor.gradualHightColorImage_buyBtn
        buyNowBtn = UIButton.init(type: .custom)
        buyNowBtn.setTitle("立即购买", for: .normal)
        buyNowBtn.setTitleColor(UIColor.white, for: .normal)
        buyNowBtn.setBackgroundImage(backgroundImg, for: .normal)
        buyNowBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        buyNowBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        buyNowBtn.addTarget(self, action: #selector(buyNowAction), for: .touchUpInside)
        bottomView.addSubview(buyNowBtn)
        
        buyNowBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(0)
            make.height.equalTo(44)
        }
        
        //加入购物车
        let backgroundImgb = PublicColor.gradualColorImage
        let backgroundHImgb = PublicColor.gradualHightColorImage
        addCartBtn = UIButton.init(type: .custom)
        addCartBtn.setBackgroundImage(backgroundImgb, for: .normal)
        addCartBtn.setBackgroundImage(backgroundHImgb, for: .highlighted)
        addCartBtn.setTitle("加入\(addText)", for: .normal)
        addCartBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        addCartBtn.setTitleColor(UIColor.white, for: .normal)
        addCartBtn.addTarget(self, action: #selector(addCartAction), for: .touchUpInside)
        bottomView.addSubview(addCartBtn)
        
        addCartBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalTo(buyNowBtn.snp.left)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(44)
        }
        
        //联系卖家
        contactSellerBtn = UIButton.init(type: .custom)
        contactSellerBtn.isHidden = true
        contactSellerBtn.setImage(UIImage.init(named: "contact_seller"), for: .normal)
        contactSellerBtn.addTarget(self, action: #selector(contactSellerAction), for: .touchUpInside)
        bottomView.addSubview(contactSellerBtn)

        contactSellerBtn.snp.makeConstraints { (make) in
            make.right.equalTo(addCartBtn.snp.left).offset(-2)
            make.top.equalTo(3)
            make.width.equalTo(50)
            make.height.equalTo(40)
        }
        
        if isHome {
            let allBtn = UIButton.init(type: .custom)
            allBtn.setTitle("查看所有产品", for: .normal)
            allBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
            allBtn.addTarget(self, action: #selector(lookAllMaterialAction), for: .touchUpInside)
            allBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            bottomView.addSubview(allBtn)
           
            allBtn.snp.makeConstraints { (make) in
                make.right.equalTo(addCartBtn.snp.left).offset(-2)
                make.centerY.equalTo(addCartBtn)
            }
        }
        
        if materialsModel?.type == 1 {
            contactSellerBtn.isHidden = false
        }
        
        //价格
        priceShowLabel = UILabel()
        priceShowLabel.text = "未定价"
        priceShowLabel.font = UIFont.systemFont(ofSize: 16)
        priceShowLabel.textColor = PublicColor.emphasizeTextColor
        bottomView.addSubview(priceShowLabel)
        
        priceShowLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.equalTo(4)
        }
        
        //切换价格显示
        switchPriceBtn = UIButton()
        switchPriceBtn.isHidden = true
        switchPriceBtn.setImage(UIImage.init(named: "login_hidepw"), for: .normal)
        switchPriceBtn.setImage(UIImage.init(named: "login_showpw"), for: .selected)
        switchPriceBtn.addTarget(self, action: #selector(switchPriceAction), for: .touchUpInside)
        bottomView.addSubview(switchPriceBtn)
        
        switchPriceBtn.snp.makeConstraints { (make) in
            make.left.equalTo(priceShowLabel.snp.right)
            make.centerY.equalTo(priceShowLabel)
            make.width.height.equalTo(30)
        }
        
        //市场价
        priceShowTitle = UILabel()
        priceShowTitle.text = "市场价"
        priceShowTitle.font = UIFont.systemFont(ofSize: 11)
        priceShowTitle.textColor = UIColor.colorFromRGB(rgbValue: 0x4D4D4D)
        bottomView.addSubview(priceShowTitle)
        
        priceShowTitle.snp.makeConstraints { (make) in
            make.left.equalTo(priceShowLabel)
            make.top.equalTo(priceShowLabel.snp.bottom).offset(2)
        }
        
        //支持单品购买
        singleLabel = UILabel()
        singleLabel.font = UIFont.systemFont(ofSize: 11)
        singleLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x4D4D4D)
        
        let atString = NSMutableAttributedString.init(string: " 可单买")
        let image = UIImage(named: "single_buy")
        let chment = NSTextAttachment.init()
        chment.image = image
        let imageString = NSAttributedString.init(attachment: chment)
        atString.insert(imageString, at: 0)
        singleLabel.attributedText = atString
        
//        bottomView.addSubview(singleLabel)
//
//        singleLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(priceShowTitle.snp.right).offset(8)
//            make.centerY.equalTo(priceShowTitle)
//        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //webView
        JWCacheURLProtocol.startListeningNetWorking()
        webView = WKWebView()
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        view.addSubview(webView)
        webView.shouldHideToolbarPlaceholder = true
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        if detailType == .addCart || detailType == .scanAddCart {
            bottomView.isHidden = false
            webView.snp.makeConstraints { (make) in
                make.left.right.top.equalToSuperview()
                make.bottom.equalTo(bottomView.snp.top)
            }
        }
        else {
            bottomView.isHidden = true
            webView.snp.makeConstraints({ (make) in
                make.right.top.left.bottom.equalToSuperview()
            })
        }
        
        //进度条
        progressView = UIProgressView()
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = PublicColor.progressColor
        progressView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        progressView.progress = 0.02 //设置初始值，防止网页加载过慢时没有进度
        view.addSubview(progressView)
        
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(webView)
//            make.bottom.equalTo(webView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        
            
        contactSellerBtn.removeFromSuperview()
        view.addSubview(contactSellerBtn)
        contactSellerBtn.snp.remakeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(-8)
            make.centerY.equalTo(view)
        }
    }
    
    ///填充数据
    func paddingData(){
        
        titleLabel.text = materialsModel?.name
        
        if UserData.shared.userType == .jzgs {
            
            buyNowBtn.isHidden = false
            buyNowBtn.snp.remakeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.25)
                make.height.equalTo(44)
            }
            
            addCartBtn.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.right.equalTo(buyNowBtn.snp.left)
                make.height.equalTo(44)
                make.width.equalToSuperview().multipliedBy(0.25)
            }
        }else {
            buyNowBtn.isHidden = true
        }
        
        switchPriceBtn.isHidden = true
        singleLabel.isHidden = true
        if UserData.shared.userType == .jzgs {
            
            if materialsModel?.type == 1 {
                contactSellerBtn.isHidden = false
            }
            
            if materialsModel?.isOneSell == 1 {
                singleLabel.isHidden = false
                priceShowTitle.text = "销售价"
                
                if let valueStr = materialsModel?.priceCustom?.doubleValue {
                    let totalStr = valueStr.notRoundingString(afterPoint: 2)
                    priceShowLabel.text = String.init(format: "%@元", totalStr)
                    
                    if let unitValue = materialsModel?.unitType {
                        let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                        priceShowLabel.text = priceShowLabel.text! + "/" + unitStr
                        
                        
                    }
                }
            }else {
                switchPriceBtn.isHidden = false
                priceShowTitle.text = "市场价"
                
                if let valueStr = materialsModel?.priceShow?.doubleValue {
                    let totalStr = valueStr.notRoundingString(afterPoint: 2)
                    priceShowLabel.text = String.init(format: "%@元", totalStr)
                    
                    if let unitValue = materialsModel?.unitType {
                        let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                        priceShowLabel.text = priceShowLabel.text! + "/" + unitStr
                    }
                    
                    priceShowLabel.attributedText = priceShowLabel.text?.addUnderline()
                    priceShowLabel.textColor = PublicColor.emphasizeTextColor
                }
            }
        }
        else if UserData.shared.userType == .cgy {
            
            if materialsModel?.type == 1 {
                contactSellerBtn.isHidden = false
            }
            
            priceShowTitle.text = "会员价"
            
            var valuePrice: Double = 0
            if let valueStr = materialsModel?.beforePriceSupply?.doubleValue {
                let value = valueStr.notRoundingString(afterPoint: 2)
                valuePrice = valueStr
                priceShowLabel.text = String.init(format: "%@元", value)
                
            }else if let valueStr = materialsModel?.priceSupply1?.doubleValue {
                let value = valueStr.notRoundingString(afterPoint: 2)
                valuePrice = valueStr
                priceShowLabel.text = String.init(format: "%@元", value)
            }
            
            if let unitValue = materialsModel?.beforeUnitType {
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                priceShowLabel.text = priceShowLabel.text! + "/" + unitStr
            }
            else if let unitValue = materialsModel?.unitType {
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                priceShowLabel.text = priceShowLabel.text! + "/" + unitStr
            }
            
            
        }
        else if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
            
            if UserData.shared.userType == .gys  || UserData.shared.userType == .fws {
                contactSellerBtn.isHidden = true
            }
            
            priceShowTitle.text = "会员价"
            
            var priceValue: Double = 0
            
            if let valueStr = materialsModel?.beforePriceCost?.doubleValue {
                priceValue = valueStr
            }
            else if let valueStr = materialsModel?.priceSupply1?.doubleValue {
                priceValue = valueStr
            }
            
            let totalStr = priceValue.notRoundingString(afterPoint: 2)
            priceShowLabel.text = String.init(format: "%@元", totalStr)
            
            if let unitValue = materialsModel?.beforeUnitType {
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                priceShowLabel.text = priceShowLabel.text! + "/" + unitStr
            }
            else if let unitValue = materialsModel?.unitType {
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                priceShowLabel.text = priceShowLabel.text! + "/" + unitStr
            }
        }
        
        if imageUrl != nil {
            let request = URLRequest.init(url:  imageUrl!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
            webView.load(request)
        }
        else {
            if let urlStr = materialsModel?.url {
                
                let request = URLRequest.init(url:  URL.init(string: APIURL.ossPicUrl+urlStr)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
                webView.load(request)
            }
        }
    }
    
    //MARK: - 按钮事件
    
    @objc func contactSellerAction() {
        
        if materialsModel == nil {
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
        
        if let valueStr = materialsModel?.yzbMerchant?.id {
            userId = valueStr
        }
        if let valueStr = materialsModel?.yzbMerchant?.userName {
            userName = valueStr
        }
        if let valueStr = materialsModel?.yzbMerchant?.name {
            storeName = valueStr
        }
        if let valueStr = materialsModel?.yzbMerchant?.headUrl {
            headUrl = valueStr
        }
        if let valueStr = materialsModel?.yzbMerchant?.realName {
            nickname = valueStr
        }
        if let valueStr = materialsModel?.yzbMerchant?.servicePhone {
            tel1 = valueStr
        }
        
        let ex: NSDictionary = ["detailTitle": storeName, "headUrl":headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
        
        let user = JMSGUserInfo()
        user.nickname = nickname
        user.extras = ex as! [AnyHashable : Any]
        updConsultNumRequest(id: userId)
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
                            self.contactSellerAction()
                        }
                    })
                }
            }
        }
    }
    
    @objc func shareAction() {
        var storeName = ""
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            if let valueStr = UserData.shared.merchantModel?.name {
                storeName = valueStr
            }
        }else {
            if let valueStr = UserData.shared.workerModel?.store?.name {
                storeName = valueStr
            }
        }
        
        guard let shareUrl = self.materialsModel?.url else { return }
        
        let shareTitle = (self.materialsModel?.name)!
        _ = "来自 \(storeName) 分享的产品"
        var shareImage: Any!
        
        shareImage = UIImage.init(named: "shareImage")!
        if let valueStr = self.materialsModel?.transformImageURL {
            if valueStr != "" {
                shareImage = APIURL.ossPicUrl + valueStr
            }
        }
        let items = [shareTitle, shareImage as Any, shareUrl] as [Any]
         let activityVC = UIActivityViewController(
             activityItems: items,
             applicationActivities: nil)
        activityVC.completionWithItemsHandler =  { activity, success, items, error in
            print(activity as Any)
             print(success)
            print(items as Any)
            print(error as Any)
             
             
         }
         self.present(activityVC, animated: true, completion: { () -> Void in
             
         })
//        UMSocialUIManager.showShareMenuViewInWindow { (platformType, userInfo) in
//
//            var storeName = ""
//
//            if UserData.shared.userType == .gys {
//                if let valueStr = UserData.shared.merchantModel?.name {
//                    storeName = valueStr
//                }
//            }else {
//                if let valueStr = UserData.shared.workerModel?.store?.name {
//                    storeName = valueStr
//                }
//            }
//
//            guard let shareUrl = self.materialsModel?.url else { return }
//
//            let shareTitle = (self.materialsModel?.name)!
//            let shareDescr = "来自 \(storeName) 分享的产品"
//            var shareImage: Any!
//
//            shareImage = UIImage.init(named: "shareImage")!
//            if let valueStr = self.materialsModel?.transformImageURL {
//                if valueStr != "" {
//                    shareImage = APIURL.ossPicUrl + valueStr
//                }
//            }
//
//            let messageObject = UMSocialMessageObject()
//            let shareObject = UMShareWebpageObject.shareObject(withTitle: shareTitle, descr: shareDescr, thumImage: shareImage)
//            shareObject?.webpageUrl = APIURL.ossPicUrl + shareUrl
//            messageObject.shareObject = shareObject
//
//            UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self, completion: { (data, error) in
//
//                if error != nil {
//                    AppLog("************Share fail with error \(error!)************")
//
//                }else {
//
//                    if let resp = data as? UMSocialShareResponse {
//
//                        AppLog("response message is \(String(describing: resp.message))")
//                        AppLog("response originalResponse data is \(String(describing: resp.originalResponse))")
//
//                    }else {
//                        AppLog("response data is \(data!)")
//                    }
//                }
//            })
//        }
    }
    
    @objc func switchPriceAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            priceShowTitle.text = "销售价"
            
            if let valueStr = materialsModel?.priceCustom?.doubleValue {
                let totalStr = valueStr.notRoundingString(afterPoint: 2)
                priceShowLabel.text = String.init(format: "%@元", totalStr)
                
                if let unitValue = materialsModel?.unitType {
                    let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                    priceShowLabel.text = priceShowLabel.text! + "/" + unitStr
                    priceShowLabel.attributedText = priceShowLabel.text?.removeUnderline()
                }
            }
        }else {
            priceShowTitle.text = "市场价"
            
            if let valueStr = materialsModel?.priceShow?.doubleValue {
                let totalStr = valueStr.notRoundingString(afterPoint: 2)
                priceShowLabel.text = String.init(format: "%@元", totalStr)
                
                if let unitValue = materialsModel?.unitType {
                    let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                    priceShowLabel.text = priceShowLabel.text! + "/" + unitStr
                }
                
                priceShowLabel.attributedText = priceShowLabel.text?.addUnderline()
                priceShowLabel.textColor = PublicColor.emphasizeTextColor
            }
        }
    }
    
    //跳转购物车
    @objc func goCartAction() {
        
        let viewController = ShopCartViewController()
        viewController.isRootVC = false
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    //加购物车
    @objc func addCartAction() {
        
        if materialsModel?.id == nil {
            self.noticeOnlyText("产品读取失败")
            return
        }
        if UserData.shared.userType == .cgy {
            return
        }
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        var parameters: Parameters = ["worker": userId, "store": storeID, "materials": materialsModel!.id!, "type": "1"]
        
        if let valueStr = materialsModel?.type {
            parameters["materialsType"] = valueStr
        }
        
        self.pleaseWait()
        let urlStr = APIURL.saveCartList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                self.noticeSuccess("添加\(self.addText)成功", autoClear: true, autoClearTime: 0.8)
                let backgroundImgb = PublicColor.gradualHightColorImage
                self.addCartBtn.setBackgroundImage(backgroundImgb, for: .normal)
                self.addCartBtn.setTitle("已加入\(self.addText)", for: .normal)
                self.addCartBtn.isUserInteractionEnabled = false
            }
            
        }) { (error) in
            
        }
    }
    
    // 添加按钮文字
    private var addText: String {
        get {
            return UserData.shared.userType == .cgy ? "预购清单" : "购物车"
        }
    }
    
    
    //立即购买
    @objc func buyNowAction() {
        
        var dataArray: Array<PlusDataModel> = []
        
        let packageDataModel = PlusDataModel()
        packageDataModel.roomType = 1
        packageDataModel.isShow = true
        dataArray.append(packageDataModel)
        
        let serviceDataModel = PlusDataModel()
        serviceDataModel.roomType = 2
        dataArray.append(serviceDataModel)
        
        let packageModel = PackageModel()
        packageModel.packageType = 2
        packageModel.materials = materialsModel
        packageDataModel.packageList.append(packageModel)
        
        let vc = PlaceOrderController()
//        vc.rowsData = dataArray
//        vc.selectedModel = packageDataModel
        navigationController?.pushViewController(vc, animated: true)
    }
    //返回
    @objc func backAction() {
        
        if detailType == .detail || detailType == .select {
            
            if navigationController?.presentingViewController != nil {
                navigationController?.dismiss(animated: true, completion: nil)
            }else {
                navigationController?.popViewController(animated: true)
            }
        }
        else if detailType == .scanSelect {
            
            if let vcArray = self.navigationController?.viewControllers {
                let popVC = vcArray[vcArray.count-3]
                self.navigationController?.popToViewController(popVC, animated: true)
            }
        }
        else if detailType == .scanFree {
            
            if let vcArray = self.navigationController?.viewControllers {
                let popVC = vcArray[vcArray.count-4]
                self.navigationController?.popToViewController(popVC, animated: true)
            }
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //添加
    @objc func addShopAction() {
        
        if let block = selectBlock {
            block(materialsModel!)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //选择
    @objc func selectAction() {
        
        if materialsModel == nil {
            self.noticeOnlyText("产品读取失败")
            return
        }
        
        if let block = addPlusMaterialBlock {
            
            if detailType == .scanSelect {
                
                if isPlusMaterial {
                    packageModel?.materials = materialsModel
                    block()
                    backAction()
                }
                else {
                    var titleStr = "该商品不属于当前产品包的可选产品"
                    if let valueStr = packageModel?.name {
                        titleStr = "该商品不属于“\(valueStr)”的可选产品"
                    }
                    let popup = PopupDialog(title: titleStr, message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                    
                    let sureBtn = DefaultButton.init(title: "确认", action: {
                        self.backAction()
                    })
                    popup.addButton(sureBtn)
                    self.present(popup, animated: true, completion: nil)
                }
                
            }else {
                
                //自由开单扫码选材
                if packageModel?.category?.id == materialsModel?.categorya?.id || packageModel?.category?.id == materialsModel?.categoryb?.id || packageModel?.category?.id == materialsModel?.categoryc?.id || packageModel?.category?.id == materialsModel?.categoryd?.id {
                    
                    packageModel?.materials = materialsModel
                    block()
                    backAction()
                    
                }else {
                    
                    var titleStr = "该商品不属于当前产品包的分类"
                    if let valueStr = packageModel?.category?.name {
                        titleStr = "该商品不属于'\(valueStr)'产品"
                    }
                    let popup = PopupDialog(title: titleStr, message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                    
                    let sureBtn = DefaultButton.init(title: "确认", action: {
                        self.backAction()
                    })
                    popup.addButton(sureBtn)
                    self.present(popup, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func lookAllMaterialAction() {
        if let model = self.materialsModel {
            
            let vc = MaterialSearchController()
            vc.isSecondSearch = true
            vc.isBrand = true
            
            vc.merchantId = model.merchantId ?? ""
            vc.brandName = model.brandName ?? ""
            vc.title = model.brandName ?? ""
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    //MARK: - 网络请求
    func loadData() {
        
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        addCartBtn.isEnabled = false
        
        var parameters: Parameters = ["id": materialsId, "storeId": storeID]
        
        if let packageId = packageModel?.id, detailType == .scanSelect {
            parameters["packageId"] = packageId
        }
        
        self.pleaseWait()
        let urlStr = APIURL.getSingleMaterials
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { [weak self] response in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                self?.addCartBtn.isEnabled = true
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model = Mapper<MaterialsModel>().map(JSON: dataDic as! [String : Any])
                self?.materialsModel = model
                
                self?.paddingData()
                self?.loadisExistCartList()
                
            }else if errorCode == "008" {
                let popup = PopupDialog(title: "无产品对应记录", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: .bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

                let sureBtn = DefaultButton.init(title: "确认", action: {
                    self?.navigationController?.popViewController(animated: true)
                })
                popup.addButton(sureBtn)
                self?.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
        
    }
    
    func loadisExistPurList() {
        
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        guard let workerId = UserData.shared.workerModel?.id else{
            AppLog("UserData.shared.workerModel?.id: 参数异常")
            return
        }
        guard let materialsId = materialsModel?.id else {
            AppLog("materialsModel.id: 参数异常")
            return
        }
        
        let parameters: Parameters = ["storeId": storeID, "id": materialsId, "workerId": workerId]
        
        self.clearAllNotice()
        self.pleaseWait()
        let urlStr = APIURL.isAddPurchase
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { [unowned self](response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let isExist = Utils.getReadString(dir: response["body"] as! NSDictionary, field: "isExist")
                if isExist == "1" {
                    let backgroundImgb = PublicColor.gradualHightColorImage
                    self.addCartBtn.setBackgroundImage(backgroundImgb, for: .normal)
                    self.addCartBtn.setTitle("已加入\(self.addText)", for: .normal)
                    self.addCartBtn.isUserInteractionEnabled = false
                }else {
                    let backgroundImgb = PublicColor.gradualColorImage
                    self.addCartBtn.setBackgroundImage(backgroundImgb, for: .normal)
                    self.addCartBtn.setTitle("加入\(self.addText)", for: .normal)
                    self.addCartBtn.isUserInteractionEnabled = true
                }
            }
            
        }) { (error) in
            
        }
    }
    
    func loadisExistCartList() {
       
        if materialsModel?.id == nil {
            self.noticeOnlyText("产品读取失败")
            return
        }
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        let parameters: Parameters = ["worker": userId, "store": storeID, "materials": materialsModel!.id!]
        let urlStr = APIURL.isExistCartList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                let isExist = Utils.getReadString(dir: response["body"] as! NSDictionary, field: "isExist")
                
                if isExist == "1" {
                    let backgroundImgb = PublicColor.gradualHightColorImage
                    self.addCartBtn.setBackgroundImage(backgroundImgb, for: .normal)
                    self.addCartBtn.setTitle("已加入\(self.addText)", for: .normal)
                    self.addCartBtn.isUserInteractionEnabled = false
                }else {
                    let backgroundImgb = PublicColor.gradualColorImage
                    self.addCartBtn.setBackgroundImage(backgroundImgb, for: .normal)
                    self.addCartBtn.setTitle("加入\(self.addText)", for: .normal)
                    self.addCartBtn.isUserInteractionEnabled = true
                }
            }
            
        }) { (error) in
            
        }
    }
    
    
    //MARK: - webView
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress"{
            progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("开始获取网页内容")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("加载完成")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("加载失败")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow);
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        let maxAlphaOffset: CGFloat = PublicSize.screenHeight/2
        let offset: CGFloat = scrollView.contentOffset.y
        let alpha: CGFloat = offset/maxAlphaOffset
        
        if offset >= maxAlphaOffset * 0.8 {
            
            backBtn.setImage(UIImage(named: "back_nav"), for: .normal)
            backBtn.backgroundColor = UIColor.clear
            
            switch detailType {
            case .addCart, .scanAddCart:
                
                cartBtn.setImage(UIImage(named: "icon_shop_black"), for: .normal)
                cartBtn.backgroundColor = UIColor.clear
                shareBtn.setImage(UIImage(named: "share_nav"), for: .normal)
                shareBtn.backgroundColor = UIColor.clear
                break
                
            case .select, .scanSelect, .scanFree:
                
                selectBtn.setTitleColor(UIColor.black, for: .normal)
                selectBtn.backgroundColor = UIColor.clear
                break
                
            case .detail:
                shareBtn.setImage(UIImage(named: "share_nav"), for: .normal)
                shareBtn.backgroundColor = UIColor.clear
                break
                
            case .scanAddShop, .addShop:
                
                addBtn.setTitleColor(UIColor.black, for: .normal)
                addBtn.backgroundColor = UIColor.clear
                break
            }
        }else {
            
            backBtn.setImage(UIImage(named: "back_white"), for: .normal)
            backBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
            
            switch detailType {
            case .addCart, .scanAddCart:
                
                cartBtn.setImage(UIImage(named: "icon_shop_white"), for: .normal)
                cartBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
                shareBtn.setImage(UIImage(named: "share_nav_white"), for: .normal)
                shareBtn.backgroundColor = backBtn.backgroundColor
                break
                
            case .select, .scanSelect, .scanFree:
                
                selectBtn.setTitleColor(UIColor.white, for: .normal)
                selectBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
                break
                
            case .detail:
                shareBtn.setImage(UIImage(named: "share_nav_white"), for: .normal)
                shareBtn.backgroundColor = backBtn.backgroundColor
                break
                
            case .scanAddShop, .addShop:
                
                addBtn.setTitleColor(UIColor.white, for: .normal)
                addBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
                break
            }
            if alpha == 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.05) {
                    self.navView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xFFFFFF, alpha: 0)
                }
            }
        }
        
        if offset >= maxAlphaOffset {

            self.navView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xFFFFFF, alpha: 1)
            titleLabel.alpha = 1
            
        }else {
            titleLabel.alpha = alpha
            navView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xFFFFFF, alpha: alpha)
        }
    }
    
    
}
