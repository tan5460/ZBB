//
//  MembershipLevelsVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/20.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ZJTableViewManager
import ObjectMapper

class MembershipLevelsVC: BaseViewController {
    var openMembershipSusccess: (() -> Void)? // 开通会员后回调。直接登录
    var orderId: String = ""
    var substationId = ""
    var userId = ""
    var infoModel: MembershipInfoModel?
    
    var orderNum: String = ""
    var mid: String = ""
    private var currentIndex = 0
    private var tableView: UITableView = UITableView.init(frame: .zero, style: .grouped)
    private var sureBtn = UIButton().cornerRadius(5).masksToBounds()
    private var manager: ZJTableViewManager!
    private var section: ZJTableViewSection!
    private var lastOpenItem: MembershipLevelsCellItem?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "请选择会员等级"
        
        let qyBtn = UIButton().text("会员权益").textColor(.kColor66).font(14)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: qyBtn)
        qyBtn.tapped { [weak self] (tapBtn) in
            let vc = UIBaseWebViewController()
            vc.isShare = true
            vc.urlStr = "https://www.jcdcbm.com/Agreement/memberEquities.html"
            self?.navigationController?.pushViewController(vc)
        }
        
        
        tableView.separatorStyle = .none
        view.sv(tableView, sureBtn)
        view.layout(
            0,
            |tableView|,
            9.5,
            |-20-sureBtn.height(50)-20-|,
            10+PublicSize.kBottomOffset
        )
        tableView.backgroundColor(.clear)
        manager = ZJTableViewManager(tableView: tableView)
        manager.register(MembershipLevelsCell.self, MembershipLevelsCellItem.self)
        section = ZJTableViewSection()
        section.headerHeight = 15
        manager.add(section: section)
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        loadData()
        
        
        //添加进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.willEnterForegroundNotification, object: nil)
        //添加进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh1), name: Notification.Name.init("unionpaysResult"), object: nil)
    }
    
    private var isUnipay = false // 是否银联支付
    @objc func refresh() {
        isUnipay = false
        getUserInfoRequest()
    }
    
    @objc func refresh1() {
        isUnipay = true
        self.pleaseWait()
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.clearAllNotice()
            self.getUserInfoRequest()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getUserInfoRequest() {
        pleaseWait()
        YZBSign.shared.request(APIURL.getUserInfo, method: .get, parameters: Parameters(), success: { (response) in
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
            UserData.shared.userInfoModel = infoModel
            if self.isUnipay {
                self.alertSuceess()
            } else {
                self.loadOrderData()
            }
            
        }) { (error) in
            
        }
    }
    
    func loadData() {
        var parameters = [String: Any]()
        parameters["substationId"] = substationId
        YZBSign.shared.request(APIURL.getMemberLevelList, method: .get, parameters: parameters, success: { (res) in
            let errorCode = Utils.getReadString(dir: res as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: res as AnyObject)
                self.infoModel = Mapper<MembershipInfoModel>().map(JSON: dataDic as! [String : Any])
                 self.updateUI()
            }
        }) { (error) in
            
        }
    }
    
    func loadOrderData() {
        var parameters = [String: Any]()
        parameters["orderNum"] = orderNum
        parameters["mid"] = mid
        YZBSign.shared.request(APIURL.sandOrderQuery, method: .get, parameters: parameters, success: { (res) in
            let errorCode = Utils.getReadString(dir: res as NSDictionary, field: "code")
            if errorCode == "0" {
                let bodyStr = Utils.getReadString(dir: res as NSDictionary, field: "data")
                let bodyDic = String.getDictionaryFromJSONString(jsonString: bodyStr)
                let bodyDic1 = bodyDic["body"] as? [String: Any]
                let dataDicStr = bodyDic1?["data"] as? String
                let dataDic = String.getDictionaryFromJSONString(jsonString: dataDicStr ?? "")
                let orderStatus = dataDic["orderStatus"] as? String
                if orderStatus == "00" {
                    self.alertSuceess()

                }
            }
        }) { (error) in
            
        }
    }
    
    func alertSuceess() {
        let alert = UIAlertController.init(title: "温馨提示", message: "该会员等级开通成功", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
            self.navigationController?.popViewController()
        }))
        self.present(alert, animated: true) {
            
        }
    }
    //MARK: - 付款
    @objc private func sureBtnClick(btn: UIButton) {
        let memberLevelId = infoModel?.memberLevelList?[currentIndex].id ?? ""

        var parameters = Parameters()
        parameters["userId"] = UserData1.shared.tokenModel?.userId
        parameters["memberLevelId"] = memberLevelId
        parameters["frontUrl"] = "subian"
       YZBSign.shared.request(APIURL.sandPayVip, method: .post, parameters: parameters) { (response) in
           let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
           if code == "0" {
               let dataString = Utils.getReadString(dir: response as NSDictionary, field: "data")
               let responseDic = String.getDictionaryFromJSONString(jsonString: dataString)
               if let body = responseDic["body"] as? [String: Any] {
                   if let data = body["data"] as? [String: Any] {
                       let sign = Utils.getReadString(dir: data as NSDictionary, field: "sign")
                      self.vipPayRequest(sign: sign, data: data)
                   }
               }
           }
       } failure: { (error) in

       }
//        if currentIndex == 6 {
//            openToFreeRequest()
//        } else {
//            //vipPayRequest(sign: "", data: "")
//            // let payMoney1 = Double.init(string: "\(payMoney)")
//
//
//        }
    }
    
    func vipPayRequest(sign: String, data: [String: Any]) {
        /// 自己生成的订单号
        ///  所有 参数
        let model = XHPayParameterModel.init()
        model.sign_type = data["sign_type"] as? String ?? ""
        model.jump_scheme = data["jump_scheme"] as? String ?? ""
        model.order_amt = data["order_amt"] as? String ?? ""
        model.clear_cycle = data["clear_cycle"] as? String ?? ""
        ///return_url 为空时 不参与签名 有值必须参与签名 必须参与签名的字段都是这个规则
        model.return_url = data["return_url"] as? String ?? ""
        model.accsplit_flag = data["accsplit_flag"] as? String ?? ""
        ///  多种支付方式 支付方式 多个就支持多种 一个就支持一种  微信02010005 支付宝02020004  银联02030001  链接02000002 杉德宝02040001
        model.product_code = data["product_code"] as? String ?? ""
        model.notify_url = data["notify_url"] as? String ?? ""
        /// 不可为空
        model.create_time = data["create_time"] as? String ?? ""
        model.expire_time = data["expire_time"] as? String ?? ""
        model.mer_key = data["mer_key"] as? String ?? ""
        model.goods_name = data["goods_name"] as? String ?? ""
        model.store_id = data["store_id"] as? String ?? ""
        model.create_ip = data["create_ip"] as? String ?? ""
        // 单号
        model.mer_order_no =  data["mer_order_no"] as? String ?? ""
        
        model.mer_no = data["mer_no"] as? String ?? ""
        model.version = data["version"] as? String ?? ""
        
        
        /// 营销活动编码 非必传 最大30位 渠道测试的 MP20201228132838216
        if let activity_no = data["activity_no"] as? String {
            model.activity_no = activity_no
        }
    ////    /// 优惠金额 例子：000000000020 分位单位
        if let benefit_amount = data["benefit_amount"] as? String {
            model.benefit_amount = benefit_amount
        }
        
        orderNum = model.mer_order_no
        mid = model.mer_no
        /// 链接支付提示语
        model.linkTips = "";
        debugPrint(model.description)
        
        let pay_extraStr = data["pay_extra"] as? String ?? ""
        let pay_extraDic = String.getDictionaryFromJSONString(jsonString: pay_extraStr)
        
        let payExaModel =  XHPayParameterPayExtraModel.init()
        payExaModel.mer_app_id = pay_extraDic["mer_app_id"] as? String ?? ""
        payExaModel.openid = pay_extraDic["openid"] as? String ?? ""
        payExaModel.buyer_id = pay_extraDic["buyer_id"] as? String ?? ""
        payExaModel.wx_app_id = pay_extraDic["wx_app_id"] as? String ?? ""
        payExaModel.gh_ori_id = pay_extraDic["gh_ori_id"] as? String ?? ""
        payExaModel.path_url = pay_extraDic["path_url"] as? String ?? ""
        payExaModel.miniProgramType = pay_extraDic["miniProgramType"] as? String ?? ""
        model.pay_extra = payExaModel
        
        
        

        model.sign = sign;
        let pay = PySdkViewController.init()
        pay.requestMultiplePay(with: model)
        pay.payfailureBlock = { (messageStr, typeStr) in
            debugPrint("调取统一 支付  错误 信息 -- 错误类型 - - \(messageStr)- -\(typeStr)")
            ///  关闭页面 防止 订单号缓存造成问题
            self.dismiss(animated: true, completion: nil)
        }
        //用 PayTypeBlock回调 ，里面参数typeStr 代表的是支付类型，用户可以根据这里tokenid也添加进去，方便使用 可取可不取，在别的bkock里也可以获取。
        
        pay.payTypeBlock = { (typeStr, tokenid) in
            debugPrint("调取统一 支付 参数--类型- \(tokenid)---\(typeStr)")
            if typeStr == "wxpays" {
                debugPrint("调取统一微信支付 参数 \(tokenid)")
                self.selectWxPay(tokenId: tokenid)
            } else if typeStr == "alipays" {
                debugPrint("调取统一支付宝支付 参数 \(tokenid)")
                /// 微信支付 需要组装参数
                ///  关闭页面 防止 订单号缓存造成问题
                
                if UIApplication.shared.canOpenURL(URL.init(string: "alipays://")!) {
                    self.dismiss(animated: true, completion: nil)
                    self.saveAliTokenForAueryResult(tokenId: tokenid)
                } else {
                    self.notice("请安装支付宝APP", autoClear: true, autoClearTime: 2)
                }
            } else if typeStr == "unionpays" {
                debugPrint("调取统一云闪付支付 参数 \(tokenid)")
                /// 正确拿到银联的Tn 消除收银台页面
                 // 00 生产
                UPPaymentControl.default()?.startPay(tokenid, fromScheme: "jcdCompany://", mode: "00", viewController: self)
            }
            self.dismiss(animated: true, completion: nil)
        }
        self.present(pay, animated: true, completion: nil)
    }
    
    
    func getPublicIP(backBlock: @escaping ((_ ipStr:String)->())){
            let queue = OperationQueue()
            let blockOP = BlockOperation.init {
                if let url = URL(string: "http://pv.sohu.com/cityjson?ie=utf-8") ,
                    let s = try? String(contentsOf: url, encoding: String.Encoding.utf8) {
                   // DDLOG(message: "data:\(s)")
                    let subArr = s.components(separatedBy: ":")
                    if subArr.count > 1  {
                        let ipStr = subArr[1].replacingOccurrences(of: "\"", with: "")
                        let ipSubArr = ipStr.components(separatedBy: ",")
                        if ipSubArr.count > 0 {
                            let ip = ipSubArr[0].trimmingCharacters(in: CharacterSet.whitespaces)
                           // DDLOG(message: "公网IP:\(ip), Thread = \(Thread.current)")
                            DispatchQueue.main.async {
                                backBlock(ip)
                            }
                            return
                        }
                    }
                }else {
                  //  DDLOG(message: "获得公网IP URL 转换失败")
                }
                DispatchQueue.main.async {
//                    JYLogsModel.JYLog(logType: JYLogsModel.JYLogType.errorType, logStr: "获取公网IP失败")
                    backBlock("")
                }
                 
            }
            queue.addOperation(blockOP)
        }
    
    func saveAliTokenForAueryResult(tokenId: String) {
        /// 存储token_id字段，用来调取查询支付结果的接口。
        debugPrint("调取支付宝支付tokenid=\(tokenId)")
        let userDefault = UserDefaults.standard
        userDefault.set(object: "tokenId", forKey: "alipaytoken_id")
    }
    
    func selectWxPay(tokenId: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(object: tokenId, forKey: "wxtoken_id")
        
        let allPath = "pages/zf/index?token_id=\(tokenId)"
        let launchMiniProgramReq = WXLaunchMiniProgramReq.object()
        launchMiniProgramReq.userName = "gh_8f69bbed2867"
        launchMiniProgramReq.path = allPath
        launchMiniProgramReq.miniProgramType = .release
        WXApi.send(launchMiniProgramReq, completion: nil)
    }
    
    func openToFreeRequest() {
        var parameters = Parameters()
        parameters["levelId"] = infoModel?.memberLevelList?[currentIndex].id
        let url = APIURL.openForFree
        YZBSign.shared.request(url, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("会员开通成功")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.openMembershipSusccess?()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }) { (error) in
            
        }
    }
    
    func payRequest(type: Int, memberLevelId: String, payMoney: Double) {
        var payType = "upacp"
        switch type {
        case 1:
            payType = "upacp"
            break
        case 2:
            payType = "wx"
            break
        case 3:
            payType = "alipay"
            break
        default:
            payType = "upacp"
        }
        var parameters = [String: Any]()
        parameters["payType"] = payType
        parameters["memberLevelId"] = memberLevelId
        if userId == "" {
            parameters["userId"] = UserData.shared.userInfoModel?.worker?.id
        } else {
            parameters["userId"] = userId
        }
        
        let url = APIURL.membershipPay
        YZBSign.shared.request(url, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataString = Utils.getReadString(dir: response as NSDictionary, field: "data")
                let dataDic = String.getDictionaryFromJSONString(jsonString: dataString)
                if let body = dataDic["body"] as? [String: Any] {
                    if let data = body["data"] as? [String: Any] {
                        if let charges = data["charges"] as? [String: Any] {
                            var jdataArray: Any!
                            if let jdata = charges["data"] as? [[String: Any]] {
                               jdataArray = jdata[0]
                            }
                            else if let jdata = charges["data"] as? [String: Any] {
                                jdataArray = jdata
                            }
                            let date = try! JSONSerialization.data(withJSONObject: jdataArray as Any, options: [])
                            let charge = NSString(data: date, encoding: String.Encoding.utf8.rawValue)
                            AppLog(charge!)
                            
                            self.switchThird(charge)
                            
                        }
                        
                    }
                }
                
            }
            else if errorCode == "001" {
                self.noticeOnlyText("订单号错误")
            }
        }) { (error) in
            
        }
    }
    
    // 第三方支付
    private func switchThird(_ charge: NSString!) {
        Pingpp.createPayment(charge as NSObject, viewController: self, appURLScheme: kAppURLScheme) { (result, error) -> Void in
            AppLog("=======: \(result!)")
            if error != nil {
                print(error!.getMsg()!)
                if error?.getMsg() == "用户取消操作" {
                    self.noticeOnlyText("支付取消")
                } else {
                    self.noticeOnlyText("支付失败")
                }
                return
            }
            self.noticeOnlyText("支付成功")
            self.openMembershipSusccess?()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateUI() {
        let count = infoModel?.memberLevelList?.count ?? 0
        section.removeAllItems()
        for index in 0 ..< count {
            let item = MembershipLevelsCellItem()
            section.add(item: item)
            item.zPosition = CGFloat(index)
            item.levelModel = infoModel?.memberLevelList?[index]
            item.infoModel = infoModel
            // cell tap event
            item.setSelectionHandler { [unowned self] (selectItem: MembershipLevelsCellItem) in
                self.cellTapEvent(item: selectItem)
            }
        }
        if let lastItem = section.items.last as? MembershipLevelsCellItem {
            // Last cell keep open and don't respond to the tap event
            lastItem.openCard()
           // lastItem.selectionHandler = nil
        }
        manager.reload()
        if count > 0 {
            didChangeSureBtn(count - 1)
        }
        
    }
    
    func cellTapEvent(item: MembershipLevelsCellItem) {
        
        item.isOpen = !item.isOpen
        if item.isOpen {
            item.openCard()
            if lastOpenItem != item { // 关闭上一次打开的cell/ close the cell that was last opened
                lastOpenItem?.closeCard()
                lastOpenItem = item
            }
        } else {
            item.closeCard()
        }
        didChangeSureBtn(item.indexPath.row)
        // 注意：Xcode11.3.1 模拟器上tableview update height存在bug
        // 如果cell是透明的，动画过程中透明部分会变成不透明，影响动画的效果。
        // 真机上面是正常的
       // manager.updateHeight()
        
        if #available(iOS 11.0, *) {
            UIView.animate(withDuration: 0.3) {
                self.tableView.performBatchUpdates({
                    self.tableView.reloadData()
                }) { (flag) in
                }
                self.tableView.endUpdates()
            }
        } else {
            manager.updateHeight()
        }
    }
    private var payMoney = Decimal.init(0)
    func didChangeSureBtn(_ index: Int) {
        currentIndex = index
        let levelModels = infoModel?.memberLevelList
        let count = levelModels?.count ?? 0
        if count == 0 {
            return
        }
        let lab1 = UILabel().text("免费开通").textColor(.white).fontBold(14)
        let lab2 = UILabel().text("前\(infoModel?.totalQuota ?? 0)名开通会员立减\(infoModel?.discountMoney ?? 0)元").textColor(.white).font(12)
        let lab3 = UILabel().text("（剩余名额：\(infoModel?.lastQuota ?? 0)个）").textColor(.white).font(10)
        let bottomLabBg = UIView()
        sureBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.locations = [0, 1]
        bgGradient.frame = sureBtn.bounds
        bgGradient.startPoint = CGPoint(x: 1, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 0, y: 0.5)
        sureBtn.layer.addSublayer(bgGradient)
        let vipType = UserData.shared.userInfoModel?.yzbVip?.vipType ?? -1
        let level = Int(infoModel?.memberLevelList?[index].level ?? "0") ?? 0
        if level <= vipType && level != 0  {
            sureBtn.isEnabled = false
            lab1.text("该会员等级已开通")
            sureBtn.sv(lab1)
            lab1.centerInContainer()
            
        } else {
            if (vipType > 1 && level == 0) || (vipType == 0 && level == 1) {
                sureBtn.isEnabled = false
                lab1.text("该会员等级已开通")
                sureBtn.sv(lab1)
                lab1.centerInContainer()
            }
            else {
                sureBtn.isEnabled = true
                if index < count {
                    let discountMoney = Decimal.init(infoModel?.discountMoney?.doubleValue ?? 0)
                    let totalMoney = Decimal.init(levelModels?[offset: index].memberFee?.doubleValue ?? 0)
                    
                    if infoModel?.lastQuota ?? 0 > 0 {
                        payMoney = totalMoney - discountMoney
                    } else {
                        payMoney = totalMoney
                    }
                    
                    lab1.text("确认支付 ¥\(payMoney)")
                    if (infoModel?.lastQuota ?? 0) == 0 {
                        sureBtn.sv(lab1)
                        lab1.centerInContainer()
                    } else {
                        sureBtn.sv(lab1, bottomLabBg)
                        sureBtn.layout(
                            5,
                            lab1.height(20).centerHorizontally(),
                            3.5,
                            bottomLabBg.height(16.5).centerHorizontally(),
                            5
                        )
                        bottomLabBg.sv(lab2, lab3)
                        bottomLabBg.layout(
                            0,
                            |-0-lab2.height(16.5)-4-lab3-0-|,
                            0
                        )
                    }
                } else {
                    sureBtn.sv(lab1)
                    lab1.centerInContainer()
                }
            }
            
        }
        
        switch index {
        case 0:
            bgGradient.colors = [UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1).cgColor, UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1).cgColor]
        case 1:
            bgGradient.colors = [UIColor(red: 0.91, green: 0.71, blue: 0.42, alpha: 1).cgColor, UIColor(red: 0.5, green: 0.27, blue: 0.11, alpha: 1).cgColor]
        case 2:
            bgGradient.colors = [UIColor(red: 0.78, green: 0.64, blue: 0.48, alpha: 1).cgColor, UIColor(red: 0.49, green: 0.44, blue: 0.39, alpha: 1).cgColor]
        case 3:
            bgGradient.colors = [UIColor(red: 0.78, green: 0.76, blue: 0.86, alpha: 1).cgColor, UIColor(red: 0.54, green: 0.52, blue: 0.6, alpha: 1).cgColor]
        case 4:
            bgGradient.colors = [UIColor(red: 0.89, green: 0.69, blue: 0.54, alpha: 1).cgColor, UIColor(red: 0.67, green: 0.44, blue: 0.28, alpha: 1).cgColor]
        case 5:
            bgGradient.colors = [UIColor(red: 0.45, green: 0.8, blue: 0.69, alpha: 1).cgColor, UIColor(red: 0.13, green: 0.55, blue: 0.42, alpha: 1).cgColor]
        case 6:
            bgGradient.colors = [UIColor(red: 0.94, green: 0.76, blue: 0.24, alpha: 1).cgColor, UIColor(red: 0.95, green: 0.78, blue: 0.36, alpha: 1).cgColor]
        default:
            break
        }
    }
}


let openHeight: CGFloat = 210
let closeHeight: CGFloat = 50
class MembershipLevelsCellItem: ZJTableViewItem {
    var isOpen = false
    var zPosition: CGFloat = 0
    var levelModel: MembershipLevelModel?
    var infoModel: MembershipInfoModel?
    override init() {
        super.init()
        cellHeight = closeHeight
        selectionStyle = .none
    }

    func openCard() {
        isOpen = true
        cellHeight = openHeight
    }

    func closeCard() {
        isOpen = false
        cellHeight = closeHeight
    }
}

class MembershipLevelsCell: UITableViewCell, ZJCellProtocol {
    var item: MembershipLevelsCellItem!
    typealias ZJCelltemClass = MembershipLevelsCellItem
    private var cardView: UIView = UIView().backgroundColor(.clear)
    private var cardImg = UIImageView().image(#imageLiteral(resourceName: "Company_detail_banner_default")).backgroundColor(.clear)
    private var cardContent = UIView()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor(.clear)
        contentView.backgroundColor(.clear)
        sv(cardView)
        layout(
            0,
            |-14-cardView-14-|,
            0
        )
        cardView.width(PublicSize.kScreenWidth)
        cardView.backgroundColor(.clear)
        
        let v = UIView().backgroundColor(.red)
        v.frame = CGRect(x: 0, y: 0, width: PublicSize.kScreenWidth-28, height: 200)
        cardView.addSubview(v)
        cardContent = v
        v.cornerRadius(10).masksToBounds()
        v.layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private let lab1 = UILabel().text("至尊会员").textColor(.white).fontBold(18)
    private let lab2 = UILabel().text("¥1998000/年").textColor(.white).fontBold(18)
    private let lab3Bg = UIView()
    private let lab3 = UILabel().text("¥2000000/年").textColor(.white).font(10)
    private let btn1 = UIButton().image(#imageLiteral(resourceName: "level_xtsyqx")).backgroundColor(#colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)).cornerRadius(20)
    private let btnLab1 = UILabel().text("系统使用权限").textColor(.kColor33).fontBold(12)
    private let btn2 = UIButton().image(#imageLiteral(resourceName: "level_hyzh")).backgroundColor(#colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)).cornerRadius(20)
    private let btnLab2 = UILabel().text("酷家乐VIP账号3个").textColor(.kColor33).fontBold(12)
    private let btn3 = UIButton().image(#imageLiteral(resourceName: "level_pzzh2")).backgroundColor(#colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)).cornerRadius(20)
    private let btnLab3 = UILabel().text("酷家乐普通账号5个").textColor(.kColor33).fontBold(12)
    private let btn4 = UIButton().image(#imageLiteral(resourceName: "level_djq")).backgroundColor(#colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)).cornerRadius(20)
    private let btnLab4 = UILabel().text("赠送4600张面额500元代金券").textColor(.kColor33).fontBold(12)
    
    func cellWillAppear() {
        layer.zPosition = item.zPosition
        if item.zPosition == 6 {
            configExprienceLevel()
        } else {
            configLevel()
        }
        
    }
    
    //MARK: - 配置体验卡片
    func configExprienceLevel() {
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.98, green: 0.95, blue: 0.76, alpha: 1).cgColor, UIColor(red: 0.97, green: 0.84, blue: 0.38, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame =
            cardContent.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.53)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.53)
        cardContent.layer.addSublayer(bgGradient)
        
        let bottomView = UIView().backgroundColor(.white)
        bottomView.frame = CGRect(x: 0, y: 50, width: cardContent.width, height: 150)
        bottomView.cornerRadius(10)
        cardContent.addSubview(bottomView)
        let bgGradient1 = CAGradientLayer()
        bgGradient1.colors = [UIColor(red: 0.94, green: 0.76, blue: 0.24, alpha: 1).cgColor, UIColor(red: 0.95, green: 0.78, blue: 0.36, alpha: 1).cgColor]
        bgGradient1.locations = [0, 1]
        bgGradient1.frame = bottomView.bounds
        bgGradient1.startPoint = CGPoint(x: 1, y: 0.41)
        bgGradient1.endPoint = CGPoint(x: 0, y: 0.5)
        bottomView.layer.insertSublayer(bgGradient1, at: 0)
        bottomView.layer.cornerRadius = 10;
        bottomView.corner(radii: 10)
        
        let icon = UIImageView().image(#imageLiteral(resourceName: "level_ty_icon_title"))
        cardContent.sv(icon)
        cardContent.layout(
            17,
            icon.height(16).centerHorizontally(),
            >=0
        )
        
        let itemW: CGFloat = CGFloat(cardContent.width-59)/3
        let itemH: CGFloat = bottomView.height
        [1, 2, 3].enumerated().forEach { (item) in
            let index = item.offset
            let qyView = UIView()
            let offsetX: CGFloat = 15+CGFloat(itemW+14.5)*CGFloat(index)
            qyView.frame = CGRect(x: offsetX, y: 0, width: itemW, height: itemH)
            bottomView.addSubview(qyView)
            
            let qyBG = UIView(frame: CGRect(x: 0, y: 19, width: itemW, height: itemH-34))
            qyView.addSubview(qyBG)
            qyBG.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
            qyBG.layer.shadowOffset = CGSize(width: 1, height: 1)
            qyBG.layer.shadowOpacity = 1
            qyBG.layer.shadowRadius = 3
            // fill
            let bgGradient = CAGradientLayer()
            bgGradient.colors = [UIColor(red: 1, green: 0.93, blue: 0.78, alpha: 1).cgColor, UIColor(red: 1, green: 0.89, blue: 0.65, alpha: 1).cgColor]
            bgGradient.locations = [0, 1]
            bgGradient.frame = qyBG.bounds
            bgGradient.startPoint = CGPoint(x: 0.12, y: 0.05)
            bgGradient.endPoint = CGPoint(x: 0.93, y: 0.94)
            qyBG.layer.addSublayer(bgGradient)
            qyBG.layer.cornerRadius = 10;
            qyBG.cornerRadius(10).masksToBounds()
            qyBG.corner(byRoundingCorners: [.topLeft, .bottomRight], radii: 20)
            
            let qyLabel = UILabel().text("权益一").textColor(UIColor.hexColor("#FEECC4")).fontBold(10).backgroundColor(UIColor.hexColor("#3E3D6B")).textAligment(.center).cornerRadius(9).masksToBounds()
            let qyIV = UIImageView().image(#imageLiteral(resourceName: "level_ty_icon_1"))
            let qyLabel1 = UILabel().text("查看聚材道平台所有商品的会员价").textColor(UIColor.hexColor("#393010")).fontBold(12)
            qyLabel1.numberOfLines(3).lineSpace(2)
            qyView.sv(qyLabel, qyIV, qyLabel1)
            qyView.layout(
                10,
                qyLabel.width(50).height(18).centerHorizontally(),
                5,
                qyIV.width(46).height(39.69).centerHorizontally(),
                3,
                qyLabel1.width(itemW-20).centerHorizontally(),
                >=0
            )
            qyLabel1.textAligment(.center)
            if index == 0 {
                qyLabel.text("权益一")
                qyIV.image(#imageLiteral(resourceName: "level_ty_icon_1"))
                qyLabel1.text("查看聚材道平台所有商品的会员价")
            } else if index == 1 {
                qyLabel.text("权益二")
                qyIV.image(#imageLiteral(resourceName: "level_ty_icon_2"))
                qyLabel1.text("一次性获取800元购物优惠券")
            } else if index == 2 {
                qyLabel.text("权益三")
                qyIV.image(#imageLiteral(resourceName: "level_ty_icon_3"))
                qyLabel1.text("享受新会员专区特供商品购买权限")
            }
        }
    }
    
    func configLevel() {
        let model = item.levelModel
        lab1.text(model?.levelName ?? "")
        let memberFee = model?.memberFee?.doubleValue ?? 0
    
        let discountMoney = Decimal.init(item.infoModel?.discountMoney?.doubleValue ?? 0)
        let totalMoney = Decimal.init(model?.memberFee?.doubleValue ?? 0)
        
        var money = totalMoney - discountMoney
        if money < 0 {
            money = 0
        }
        if (item.infoModel?.lastQuota ?? 0) == 0 {
            lab3.isHidden = true
            lab2.text("¥\(memberFee)/年")
        } else {
            lab2.text("¥\(money)/年")
            lab3.text("¥\(memberFee)/年")
            lab3.isHidden = false
        }
        
        btnLab2.text("酷家乐VIP账号\(model?.vipNum ?? 0)个")
        btnLab3.text("酷家乐普通账号\(model?.commonNum ?? 0)个")
        let couponAmount = model?.couponAmount?.intValue ?? 0
        let couponNum = model?.couponNum ?? 0
        var couponValue: Int = 0
        if couponNum > 0 {
            couponValue = couponAmount / couponNum
        }
        btnLab4.text("赠送\(couponNum)张面额\(couponValue)元代金券")
        let bgGradient = CAGradientLayer()
        
        bgGradient.locations = [0, 1]
        bgGradient.frame = cardContent.bounds
        bgGradient.startPoint = CGPoint(x: 1, y: 0.18)
        bgGradient.endPoint = CGPoint(x: 0, y: 0.18)
        cardContent.layer.addSublayer(bgGradient)
                
        let bottomView = UIView().backgroundColor(.white)
        bottomView.frame = CGRect(x: 0, y: 50, width: cardContent.width, height: 150)
        bottomView.cornerRadius(10)
        cardContent.addSubview(bottomView)
        
        
        btnLab2.numberOfLines(0).lineSpace(2)
        btnLab3.numberOfLines(0).lineSpace(2)
        btnLab4.numberOfLines(0).lineSpace(2)
        cardContent.sv(lab1, lab2, lab3Bg)
        cardContent.layout(
            15,
            |-15-lab1.height(25)-10-lab2.height(25)-4-lab3Bg.height(25),
            >=0
        )
        lab3Bg.sv(lab3)
        lab3Bg.layout(
            >=0,
            |-0-lab3.height(14),
            0
        )
        let space = cardContent.width/2
        bottomView.sv(btn1, btnLab1, btn2, btnLab2, btn3, btnLab3, btn4, btnLab4)
        bottomView.layout(
           25,
           |-20-btn1.size(40)-10-btnLab1-(space+14)-|,
           20,
           |-20-btn3.size(40)-10-btnLab3-(space+14)-|,
           25
        )
        
        bottomView.layout(
           25,
           |-(space+20)-btn2.size(40)-10-btnLab2-(14)-|,
           20,
           |-(space+20)-btn4.size(40)-10-btnLab4-(14)-|,
           25
        )
        
        let levelIV = UIImageView().image(#imageLiteral(resourceName: "level_zzhy"))
        cardContent.sv(levelIV)
        cardContent.layout(
            20,
            levelIV.width(43).height(52)-15-|,
            >=0
        )
        
        switch item.zPosition {
        case 0:
            bgGradient.colors = [UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1).cgColor, UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1).cgColor]
            [btn1, btn2, btn3, btn4].forEach {
                $0.backgroundColor(#colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1))
            }
            levelIV.image(#imageLiteral(resourceName: "level_zzhy"))
        case 1:
            bgGradient.colors = [UIColor(red: 0.91, green: 0.71, blue: 0.42, alpha: 1).cgColor, UIColor(red: 0.5, green: 0.27, blue: 0.11, alpha: 1).cgColor]
            [btn1, btn2, btn3, btn4].forEach {
                $0.backgroundColor(#colorLiteral(red: 0.1647058824, green: 0.07450980392, blue: 0.03921568627, alpha: 1))
            }
            levelIV.image(#imageLiteral(resourceName: "level_jzhy"))
        case 2:
            bgGradient.colors = [UIColor(red: 0.78, green: 0.64, blue: 0.48, alpha: 1).cgColor, UIColor(red: 0.49, green: 0.44, blue: 0.39, alpha: 1).cgColor]
            [btn1, btn2, btn3, btn4].forEach {
                $0.backgroundColor(#colorLiteral(red: 0.2274509804, green: 0.2039215686, blue: 0.1803921569, alpha: 1))
            }
            levelIV.image(#imageLiteral(resourceName: "level_zshy"))
        case 3:
            bgGradient.colors = [UIColor(red: 0.78, green: 0.76, blue: 0.86, alpha: 1).cgColor, UIColor(red: 0.54, green: 0.52, blue: 0.6, alpha: 1).cgColor]
            [btn1, btn2, btn3, btn4].forEach {
                $0.backgroundColor(#colorLiteral(red: 0.3803921569, green: 0.3529411765, blue: 0.4705882353, alpha: 1))
            }
            levelIV.image(#imageLiteral(resourceName: "level_bjhy"))
        case 4:
            bgGradient.colors = [UIColor(red: 0.89, green: 0.69, blue: 0.54, alpha: 1).cgColor, UIColor(red: 0.67, green: 0.44, blue: 0.28, alpha: 1).cgColor]
            [btn1, btn2, btn3, btn4].forEach {
                $0.backgroundColor(#colorLiteral(red: 0.4196078431, green: 0.2862745098, blue: 0.1882352941, alpha: 1))
            }
            levelIV.image(#imageLiteral(resourceName: "level_viphy"))
        case 5:
            bgGradient.colors = [UIColor(red: 0.45, green: 0.8, blue: 0.69, alpha: 1).cgColor, UIColor(red: 0.13, green: 0.55, blue: 0.42, alpha: 1).cgColor]
            [btn1, btn2, btn3, btn4].forEach {
                $0.backgroundColor(#colorLiteral(red: 0.06274509804, green: 0.3411764706, blue: 0.2588235294, alpha: 1))
            }
            levelIV.image(#imageLiteral(resourceName: "level_zjhy"))
        case 6:
            bgGradient.colors = [UIColor(red: 0.7, green: 0.93, blue: 0.87, alpha: 1).cgColor, UIColor(red: 0.16, green: 0.67, blue: 0.53, alpha: 1).cgColor]
            lab2.isHidden = true
            [btn1, btn2, btn3, btn4].forEach {
                $0.backgroundColor(#colorLiteral(red: 0.06274509804, green: 0.5607843137, blue: 0.4274509804, alpha: 1))
            }
            levelIV.image(#imageLiteral(resourceName: "level_pthy"))
            [btn2, btnLab2, btn4, btnLab4].forEach {
                $0.isHidden = true
            }
            [lab3, lab3Bg].forEach {
                $0.isHidden = true
            }
        default:
            break
        }
        
    }
    
}
