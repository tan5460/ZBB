//
//  OrderPayNewVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2020/12/17.
//

import UIKit
import ObjectMapper
import TLTransitions

class OrderPayNewVC: BaseViewController {
    var isServiceOrder = false
    var payMoney: Double = 0
    var purchaseModel = PurchaseOrderModel()
    var orderId: String?
    var orderDatas: [PurchaseMaterialModel]?
    private var discountType: Int = 0 // 0: 代金券 1: 优惠券
    private var orderNum: String = ""
    private var mid: String = ""
    private var pop: TLTransition?
    private var pop1: TLTransition?
    private var checkCouponMoney: Double = 0
    private var discountMoney: Double = 0
    private var checkCouponIds = ""
    private var checkCount = 0
    private var couponModels: [CouponModel] = []  // 正常代金券券列表
    private var tjCouponModels: [CouponModel] = [] // 推荐代金券列表
    
    
    private var checkCouponMoney1: Double = 0
    private var discountMoney1: Double = 0
    private var checkCouponIds1 = ""
    private var checkCount1 = 0
    private var couponModels1: [CouponModel] = []  // 正常优惠券券列表
    private var tjCouponModels1: [CouponModel] = [] // 推荐优惠券列表
    
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    private let surePayBtn = UIButton().textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_put_btn"))
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单支付"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        configCollectionViews()
        if isServiceOrder == false {
            if self.couponModels.count == 0 {
                self.loadUseableCouponsPlanData()
            }
            
        } else {
            if self.couponModels1.count == 0 {
                self.loadUseableCouponsData1()
            }
        }
        //添加进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.willEnterForegroundNotification, object: nil)
        //添加进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh1), name: Notification.Name.init("unionpaysResult"), object: nil)
    }
    
    private var isUnipay = false // 是否银联支付
    @objc func refresh() {
        isUnipay = false
        loadOrderData()
    }
    
    @objc func refresh1() {
        isUnipay = true
        self.pleaseWait()
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
            self.clearAllNotice()
            self.loadOrderData()
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
                    self.alertSuccess()
                }
                
            }
        }) { (error) in
            
        }
    }
    
    
    func alertSuccess() {
        let alert = UIAlertController.init(title: "温馨提示", message: "该订单已付款成功", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (action) in
            self.navigationController?.popViewController()
        }))
        self.present(alert, animated: true) {
            
        }
    }
    
    private var current = 1
    private var size = 50
    //MARK: - 获取订单可用代金券券列表
    ///
    func loadUseableCouponsData() {
        
        if UserData.shared.userInfoModel?.yzbVip?.vipType ?? 1 == 1 {
            return
        }
        if purchaseModel.orderStatus != 3 {
            return
        }
        
        var materialsIdStr = ""
        if self.orderDatas?.count == 0 {
            return
        }
        self.orderDatas?.forEach({ (orderData) in
            if !materialsIdStr.isEmpty {
                materialsIdStr.append(",")
            }
            materialsIdStr.append(orderData.materialsId ?? "")
        })
        var parameters = Parameters()
        parameters["orderId"] = orderId
        parameters["materialsIdStr"] = materialsIdStr
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.getUsableCouponList, method: .get, parameters: parameters, success: { (response) in
            self.hud?.hide(animated: true)
            // 结束刷新
            self.collectionView.mj_footer?.endRefreshing()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<CouponModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                var tempCouponModels: [CouponModel] = []
                modelArray.forEach { (model1) in
                    if model1.useStatus == "1" {
                        var isTjModel = false
                        self.tjCouponModels.forEach { (tjModel) in
                            if tjModel.id == model1.id {
                                isTjModel = true
                            }
                        }
                        if isTjModel == false {
                            tempCouponModels.append(model1)
                        }
                    }
                }
                if self.current > 1 {
                    self.couponModels += tempCouponModels
                }
                else {
                    self.couponModels = self.tjCouponModels
                    self.couponModels += tempCouponModels
                }
                self.collectionView.reloadData()
                // self.configDJQScrollView(self.couponScrollView)
                if modelArray.count < self.size {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.collectionView.mj_footer?.resetNoMoreData()
                }
            }else if errorCode == "008" {
                self.couponModels.removeAll()
                self.hud?.hide(animated: true)
            }
            
            if self.couponModels.count <= 0 {
                self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
        }) { (error) in
            self.hud?.hide(animated: true)
            self.clearAllNotice()
            // self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
        }
    }
    
    //MARK: - 获取订单可用优惠券券列表
    private var current1 = 1
    private var size1 = 50
    ///
    func loadUseableCouponsData1() {
        
        if UserData.shared.userInfoModel?.yzbVip?.vipType ?? 1 == 1 {
            return
        }
        if purchaseModel.orderStatus != 3 {
            return
        }
        
        var materialsIdStr = ""
        if self.orderDatas?.count == 0 {
            return
        }
        self.orderDatas?.forEach({ (orderData) in
            if !materialsIdStr.isEmpty {
                materialsIdStr.append(",")
            }
            materialsIdStr.append(orderData.materialsId ?? "")
        })
        var parameters = Parameters()
        parameters["orderId"] = orderId
        parameters["materialsIdStr"] = materialsIdStr
        parameters["current"] = current1
        parameters["size"] = size1
        YZBSign.shared.request(APIURL.getUsableDisCountCouponList, method: .get, parameters: parameters, success: { (response) in
            self.hud?.hide(animated: true)
            // 结束刷新
            self.collectionView1.mj_footer?.endRefreshing()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<CouponModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current > 1 {
                    self.couponModels1 += modelArray
                }
                else {
                    self.couponModels1 = modelArray
                }
                self.collectionView1.reloadData()
                // self.configDJQScrollView(self.couponScrollView)
                if modelArray.count < self.size1 {
                    self.collectionView1.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.collectionView1.mj_footer?.resetNoMoreData()
                }
            }else if errorCode == "008" {
                self.couponModels1.removeAll()
                self.hud?.hide(animated: true)
            }
            
            if self.couponModels1.count <= 0 {
                self.collectionView1.mj_footer?.endRefreshingWithNoMoreData()
            }
            
        }) { (error) in
            self.hud?.hide(animated: true)
            self.clearAllNotice()
            // self.collectionView.mj_header?.endRefreshing()
            self.collectionView1.mj_footer?.endRefreshing()
        }
    }
    
    
    private var hud: MBProgressHUD?
    //MARK: - 获取订单推荐代金券券列表
    /// 获取订单推荐优惠券列表
    func loadUseableCouponsPlanData() {
        if tjCouponModels.count > 0 { //如果推荐优惠券已请求过就不再请求，避免多次调用接口
            return
        }
        if UserData.shared.userInfoModel?.yzbVip?.vipType ?? 1 == 1  {
            return
        }
        if purchaseModel.orderStatus != 3 {
            return
        }
        hud = "".textShowLoading()
        var materialsIdStr = ""
        if self.orderDatas?.count == 0 {
            return
        }
        self.orderDatas?.forEach({ (orderData) in
            if !materialsIdStr.isEmpty {
                materialsIdStr.append(",")
            }
            materialsIdStr.append(orderData.materialsId ?? "")
        })
        
        var parameters = Parameters()
        parameters["orderId"] = orderId
        parameters["materialsIdStr"] = materialsIdStr
        YZBSign.shared.request(APIURL.getUsableCouponPlan, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            // self.collectionView.mj_header?.endRefreshing()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReadArr(data: response as NSDictionary, field: "data")
                let modelArray = Mapper<CouponModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                modelArray.forEach { (model1) in
                    model1.isTJ = true
                }
                self.tjCouponModels = modelArray
                self.checkCouponMoney = 0
                self.checkCouponIds = ""
                self.checkCount = 0
                self.tjCouponModels.forEach { (model) in
                    self.checkCount = self.checkCount + 1
                    self.checkCouponMoney += (model.denomination?.doubleValue ?? 0)
                    
                    if !self.checkCouponIds.isEmpty {
                        self.checkCouponIds.append(",")
                    }
                    self.checkCouponIds.append(model.id ?? "")
                }
                self.discountMoney = self.checkCouponMoney
                self.tableView.reloadData()
                if self.couponModels.count == 0 {
                    self.loadUseableCouponsData()
                }
                
            } else {
                self.clearAllNotice()
                self.hud?.hide(animated: true)
            }
        }) { (error) in
            self.hud?.hide(animated: true)
            self.clearAllNotice()
        }
    }
    
    private var collectionView: UICollectionView!
    private var collectionView1: UICollectionView!
    func configCollectionViews() {
        let layout = UICollectionViewFlowLayout.init()
        let w: CGFloat = view.width
        layout.itemSize = CGSize(width: w, height: 100)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout).backgroundColor(.white)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: PurchaseDetailItem.self)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadUseableCouponsData()
        }
        
        let layout1 = UICollectionViewFlowLayout.init()
        layout1.itemSize = CGSize(width: w, height: 100)
        layout1.sectionInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 10, right: 0)
        layout1.minimumLineSpacing = 10.0
        layout1.minimumInteritemSpacing = 10.0
        collectionView1 = UICollectionView.init(frame: .zero, collectionViewLayout: layout1).backgroundColor(.white)
        collectionView1.delegate = self
        collectionView1.dataSource = self
        collectionView1.register(cellWithClass: PurchaseDetailItem1.self)
        if #available(iOS 11.0, *) {
            collectionView1.contentInsetAdjustmentBehavior = .never
        }
        collectionView1.refreshFooter { [weak self] in
            self?.current1 += 1
            self?.loadUseableCouponsData1()
        }
    }
    //MARK: - 代金券弹框
    private var couponScrollView = UIScrollView()
    private var selectLab = UILabel().text("请选择代金券").textColor(.kColor33).font(12)
    private var noTJYHLabel = UILabel().text("未匹配到合适的优惠方案").textColor(.kColor33).font(12)
    // 已选推荐优惠
    private var selectTJYHLabel = UILabel().text("已选推荐优惠，抵扣金额").textColor(.kColor33).font(12)
    // 已选推荐优惠价格
    private var selectTJPriceLabel = UILabel().text("¥1000.00").textColor(.red).font(12)
    private var userYHBtn = UIButton().text("使用推荐优惠").textColor(.white).font(10)
    private var unUseYHLabel = UILabel().text("不使用代金券").textColor(.kColor33).font(12)
    // #imageLiteral(resourceName: "purchase_uncheck")
    private var unUseYHBtn = UIButton().image(#imageLiteral(resourceName: "purchase_uncheck"))
    func configDJQView() {
        let v = UIView().backgroundColor(.white)
        v.frame = CGRect(x: 0, y: 0, width: view.width, height: 552-PublicSize.kBottomOffset)
        v.corner(byRoundingCorners: [.topLeft, .topRight], radii: 10)
        
        pop = TLTransition.show(v, popType: TLPopTypeActionSheet)
        
        let titleLab = UILabel().text("代金券").textColor(.kColor33).fontBold(16)
        let instructionsBtn = UIButton().text("使用说明").textColor(.kColor99).font(12)
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "plus_close_icon"))
        let line = UIView().backgroundColor(UIColor.hexColor("#DEDEDE"))
        
        let sureBtn = UIButton().text("确定").textColor(.white).font(14).cornerRadius(19).masksToBounds()
        v.sv(titleLab, instructionsBtn, closeBtn, line, selectLab, collectionView, sureBtn, userYHBtn, unUseYHLabel, unUseYHBtn)
        v.layout(
            15,
            |-14-titleLab.height(22.5)-(>=0)-instructionsBtn.width(50).height(30)-6-closeBtn.size(30)-10-|,
            9.5,
            |-14-line.height(0.5)-14-|,
            10.5,
            |-14-selectLab.height(16.5)-(>=0)-userYHBtn.width(70).height(16)-14-|,
            27,
            |-14-unUseYHLabel.height(16.5)-(>=0)-unUseYHBtn.size(40)-14-|,
            15,
            |-0-collectionView-0-|,
            10,
            sureBtn.width(view.width-60).height(38).centerHorizontally(),
            6+PublicSize.kBottomOffset
        )
        v.sv(selectTJYHLabel, selectTJPriceLabel, noTJYHLabel)
        v.layout(
            57.5,
            |-14-selectTJYHLabel.height(16.5)-0-selectTJPriceLabel,
            >=0
        )
        v.layout(
            57.5,
            |-14-noTJYHLabel.height(16.5),
            >=0
        )
        if tjCouponModels.count == 0 {
            userYHBtn.isHidden = true
            if checkCouponMoney > 0 {
                selectLab.isHidden = false
                noTJYHLabel.isHidden = true
                selectTJYHLabel.isHidden = true
                selectTJPriceLabel.isHidden = true
            } else {
                selectLab.isHidden = true
                noTJYHLabel.isHidden = false
                selectTJYHLabel.isHidden = true
                selectTJPriceLabel.isHidden = true
            }
        } else {
            noTJYHLabel.isHidden = true
            if userYHBtn.isHidden {
                selectLab.isHidden = true
                userYHBtn.isHidden = true
                selectTJYHLabel.isHidden = false
                selectTJPriceLabel.isHidden = false
            } else {
                selectLab.isHidden = false
                userYHBtn.isHidden = false
                selectTJYHLabel.isHidden = true
                selectTJPriceLabel.isHidden = true
            }
        }
        
        
        
        sureBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.46, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.23, blue: 0.23, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = sureBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        sureBtn.layer.insertSublayer(bgGradient, at: 0)
        
        instructionsBtn.addTarget(self, action: #selector(instructionsBtnClick(btn:)))
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        closeBtn.addTarget(self, action: #selector(closeBtnClick(btn:)))
        userYHBtn.layoutIfNeeded()
        userYHBtn.corner(radii: 8)
        fillYHBtn(btn: userYHBtn)
        
        userYHBtn.tapped { [weak self] (btn) in
            self?.useTJCoupoonHandle(flag: true)
        }
        
        unUseYHBtn.tapped { [weak self] (btn) in
            self?.unUserCouponHandle()
        }
        if tjCouponModels.count > 0 && isFirstPopDJQPop {
            isFirstPopDJQPop = false
            useTJCoupoonHandle(flag: true)
        }
    }
    
    private var isFirstPopDJQPop = true
    
    //MARK: - 使用推荐优惠券处理
    func useTJCoupoonHandle(flag: Bool) {
        if flag {
            self.couponModels.forEach { (model) in
                model.isCheckBox = model.isTJ
            }
            self.checkCouponMoney = 0
            self.checkCouponIds = ""
            self.checkCount = 0
            self.couponModels.forEach { (model) in
                if model.isCheckBox ?? false {
                    self.checkCount = self.checkCount + 1
                    self.checkCouponMoney += (model.denomination?.doubleValue ?? 0)
                    if !self.checkCouponIds.isEmpty {
                        self.checkCouponIds.append(",")
                    }
                    self.checkCouponIds.append(model.id ?? "")
                }
            }
            self.discountMoney = self.checkCouponMoney
            self.selectTJPriceLabel.text("¥\(checkCouponMoney)")
        }
        self.noTJYHLabel.isHidden = true
        if tjCouponModels.count == 0 {
            self.userYHBtn.isHidden = true
        } else {
            self.userYHBtn.isHidden = flag
        }
        
        self.selectLab.isHidden = flag
        self.selectTJYHLabel.isHidden = !flag
        self.selectTJPriceLabel.isHidden = !flag
        self.collectionView.reloadData()
        
        self.unUseYHBtn.image(#imageLiteral(resourceName: "purchase_uncheck"))
    }
    
    //MARK: - 不使用优惠券处理
    func unUserCouponHandle() {
        self.useTJCoupoonHandle(flag: false)
        self.unUseYHBtn.image(#imageLiteral(resourceName: "purchase_check"))
        self.checkCouponMoney = 0
        self.checkCouponIds = ""
        self.checkCount = 0
        self.discountMoney = 0
        self.couponModels.forEach { (model) in
            model.isCheckBox = false
        }
        self.collectionView.reloadData()
        self.selectLab.text("请选择代金券")
    }
    
    
    func fillYHBtn(btn: UIButton) {
        
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.47, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.24, blue: 0.24, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = btn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        btn.layer.insertSublayer(bgGradient, at: 0)
        btn.layer.cornerRadius = 8;
    }
    
    @objc private func closeBtnClick(btn: UIButton) {
        pop?.dismiss()
    }
    
    /// 去付款
    @objc private func sureBtnClick(btn: UIButton) {
        pop?.dismiss()
        self.tableView.reloadData()
    }
    
    
    //MARK: - 优惠券弹框
    private var unUseYHLabel1 = UILabel().text("不使用优惠券").textColor(.kColor33).font(12)
    private var unUseYHBtn1 = UIButton().image(#imageLiteral(resourceName: "purchase_uncheck"))
    func configYHQView() {
        let v = UIView().backgroundColor(.white)
        v.frame = CGRect(x: 0, y: 0, width: view.width, height: 552-PublicSize.kBottomOffset)
        v.corner(byRoundingCorners: [.topLeft, .topRight], radii: 10)
        
        pop = TLTransition.show(v, popType: TLPopTypeActionSheet)
        
        let titleLab = UILabel().text("优惠券").textColor(.kColor33).fontBold(16)
        let instructionsBtn = UIButton().text("使用说明").textColor(.kColor99).font(12)
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "plus_close_icon"))
        let line = UIView().backgroundColor(UIColor.hexColor("#DEDEDE"))
        
        let sureBtn = UIButton().text("确定").textColor(.white).font(14).cornerRadius(19).masksToBounds()
        v.sv(titleLab, instructionsBtn, closeBtn, line, collectionView1, sureBtn, unUseYHLabel1, unUseYHBtn1)
        v.layout(
            15,
            |-14-titleLab.height(22.5)-(>=0)-instructionsBtn.width(50).height(30)-6-closeBtn.size(30)-10-|,
            9.5,
            |-14-line.height(0.5)-14-|,
            27,
            |-14-unUseYHLabel1.height(16.5)-(>=0)-unUseYHBtn1.size(40)-14-|,
            15,
            |-0-collectionView1-0-|,
            10,
            sureBtn.width(view.width-60).height(38).centerHorizontally(),
            6+PublicSize.kBottomOffset
        )
        sureBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.46, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.23, blue: 0.23, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = sureBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        sureBtn.layer.insertSublayer(bgGradient, at: 0)
        
        instructionsBtn.addTarget(self, action: #selector(instructionsBtnClick1(btn:)))
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        closeBtn.addTarget(self, action: #selector(closeBtnClick(btn:)))
        
        unUseYHBtn1.tapped { [weak self] (btn) in
            self?.unUserCouponHandle1()
        }
    }
    
    private var isFirstPopYHQPop = true
    //MARK: - 不使用优惠券处理
    func unUserCouponHandle1() {
        self.unUseYHBtn1.image(#imageLiteral(resourceName: "purchase_check"))
        self.checkCouponMoney1 = 0
        self.checkCouponIds1 = ""
        self.checkCount1 = 0
        self.discountMoney1 = 0
        self.couponModels1.forEach { (model) in
            model.isCheckBox = false
        }
        
        self.collectionView1.reloadData()
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
            self.noticeOnlyText(messageStr)
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
                  //  self.notice("请安装支付宝APP", autoClear: true, autoClearTime: 2)
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
    
    @objc private func instructionsBtnClick(btn: UIButton) {
        let v = UIView().backgroundColor(.white)
        v.frame = CGRect(x: 0, y: 0, width: 313, height: 390)
        pop1 = TLTransition.show(v, popType: TLPopTypeAlert)
        
        let title = UILabel().text("代金券使用说明").textColor(.kColor33).fontBold(16)
        let sv = UIScrollView()
        let okBtn = UIButton().text("我知道了").textColor(.white).font(14).cornerRadius(15).masksToBounds()
        
        v.sv(title, sv, okBtn)
        v.layout(
            15,
            title.height(22.5).centerHorizontally(),
            20,
            |-0-sv-0-|,
            17.5,
            okBtn.width(130).height(30).centerHorizontally(),
            25
        )
        
        let content = UILabel().text("一、定义\n\n1、全网券：可用于抵扣所有的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n2、天网券：可用于抵扣天网的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n3、地网券：可用于抵扣地网的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n\n二、代金券的使用规则\n\n1、代金券抵扣金额不超过订单金额的10%。\n2、代金券面额为代金券的最高抵扣金额。\n3、代金券的金额大于订单金额的10%时，差额部分不予退回。\n4、服务类商品不享受代金券优惠。\n5、预购产品在尾款阶段，可使用，抵扣金额不超过尾款的10%。\n6、订单中可同时叠加使用代金券。").textColor(.kColor66).font(14)
        content.numberOfLines(0).lineSpace(2)
        sv.sv(content)
        sv.layout(
            10,
            content.width(273).centerHorizontally(),
            10
        )
        okBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.46, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.23, blue: 0.23, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = okBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        okBtn.layer.insertSublayer(bgGradient, at: 0)
        okBtn.addTarget(self, action: #selector(okBtnClick(btn:)))
    }
    
    @objc private func instructionsBtnClick1(btn: UIButton) {
        let v = UIView().backgroundColor(.white)
        v.frame = CGRect(x: 0, y: 0, width: 313, height: 390)
        pop1 = TLTransition.show(v, popType: TLPopTypeAlert)
        
        let title = UILabel().text("优惠券使用说明").textColor(.kColor33).fontBold(16)
        let sv = UIScrollView()
        let okBtn = UIButton().text("我知道了").textColor(.white).font(14).cornerRadius(15).masksToBounds()
        
        v.sv(title, sv, okBtn)
        v.layout(
            15,
            title.height(22.5).centerHorizontally(),
            20,
            |-0-sv-0-|,
            17.5,
            okBtn.width(130).height(30).centerHorizontally(),
            25
        )
        
        let content = UILabel().text("优惠券使用说明\n\n一、如何获得优惠券？\n我们将不定期开展优惠活动，您可参与优惠活动获得相应的优惠券，优惠券发放数量以每次活动规则为准。\n二、优惠券可以在哪里用？优惠券可以在订单支付时使用，每笔订单支付前，符合条件的优惠券就会显示在支付页面，选择优惠券提交订单即可享受相应的优惠。\n三、优惠券使用说明\n1．优惠券不是现金，不允许提现，也不允许转让，只可自己使用。\n2．优惠券使用有效期，即，领取优惠券后，只能在规定的时间内使用，过期自动作废。\n3．优惠券属于一次性消耗品，每笔订单只允许使用一张优惠券，一旦使用，无法撤销。\n4．每张优惠券只能使用一次，抵价金额未用完下次也不能继续使用\n5．订单支付时，优惠券和代金券只能任选一种。").textColor(.kColor66).font(14)
        content.numberOfLines(0).lineSpace(2)
        sv.sv(content)
        sv.layout(
            10,
            content.width(273).centerHorizontally(),
            10
        )
        okBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.46, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.23, blue: 0.23, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = okBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        okBtn.layer.insertSublayer(bgGradient, at: 0)
        okBtn.addTarget(self, action: #selector(okBtnClick(btn:)))
    }
    
    @objc private func okBtnClick(btn: UIButton) {
        pop1?.dismiss()
    }
    
    
    func configDJQScrollView(_ sv: UIScrollView) {
        sv.removeSubviews()
    }
    
}

extension OrderPayNewVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if isServiceOrder {
            switch indexPath.row {
            case 0:
                let line = UIView().backgroundColor(UIColor.hexColor("#FF61D9B9"))
                let titleLabel = UILabel().text("支付信息").textColor(.kColor33).fontBold(14)
                cell.sv(line, titleLabel)
                cell.layout(
                    17.5,
                    |-14-line.width(2).height(15)-5-titleLabel,
                    12.5
                )
            case 1:
                let titleLabel = UILabel().text("商品金额:").textColor(.kColor33).font(12)
                let detailLabel = UILabel().text("¥\(payMoney)").textColor(.kColor33).font(12)
                cell.sv(titleLabel, detailLabel)
                |-14-titleLabel.centerVertically()
                |-88-detailLabel.centerVertically()
            case 2:
                let titleLabel = UILabel().text("服务费:").textColor(.kColor33).font(12)
                let detailLabel = UILabel().text("¥\(purchaseModel.serviceMoney?.doubleValue ?? 0)").textColor(.kColor33).font(12)
                cell.sv(titleLabel, detailLabel)
                |-14-titleLabel.centerVertically()
                |-88-detailLabel.centerVertically()
            case 3:
                let titleLabel = UILabel().text("优惠方式:").textColor(.kColor33).font(12)
                let djqBtn = UIButton().image(#imageLiteral(resourceName: "login_check"))
                let djqLab = UILabel().text("代金券").textColor(.kColor33).font(12)
                let yhqBtn = UIButton().image(#imageLiteral(resourceName: "login_uncheck"))
                let yhqLab = UILabel().text("优惠券").textColor(.kColor33).font(12)
                cell.sv(titleLabel, djqBtn, djqLab, yhqBtn, yhqLab)
                cell.layout(
                    13.75,
                    |-14-titleLabel.height(16.5)-(>=0)-djqBtn.size(26)-0-djqLab-16-yhqBtn.size(26)-0-yhqLab-14-|,
                    13.75
                )
                if discountType == 0 {
                    djqBtn.image(#imageLiteral(resourceName: "login_check"))
                    yhqBtn.image(#imageLiteral(resourceName: "login_uncheck"))
                } else {
                    djqBtn.image(#imageLiteral(resourceName: "login_uncheck"))
                    yhqBtn.image(#imageLiteral(resourceName: "login_check"))
                }
                if isServiceOrder {
                    discountType = 1
                    djqBtn.image(#imageLiteral(resourceName: "login_uncheck"))
                    yhqBtn.image(#imageLiteral(resourceName: "login_check"))
                }
                djqBtn.tapped { [weak self] (btn) in
                    if self?.isServiceOrder ?? false {
                        self?.notice("服务订单不支持代金券抵扣", autoClear: true, autoClearTime: 2)
                        return
                    }
                    self?.discountType = 0
                    self?.tableView.reloadData()
                }
                yhqBtn.tapped { [weak self] (btn) in
                    self?.discountType = 1
                    self?.tableView.reloadData()
                    if self?.couponModels1.count == 0 {
                        self?.loadUseableCouponsData1()
                    }
                }
            case 4:
                let titleLabel = UILabel().text("代金券:").textColor(.kColor33).font(12)
                let detailLabel = UILabel().text("已选择\(checkCount)张(抵扣\(discountMoney)元）").textColor(.kColor33).font(12)
                cell.sv(titleLabel, detailLabel)
                |-14-titleLabel.centerVertically()-(>=0)-detailLabel.centerVertically()-16.5-|
                cell.accessoryType = .disclosureIndicator
                if discountType == 0 {
                    titleLabel.text("代金券")
                    detailLabel.text("已选择\(checkCount)张(抵扣\(discountMoney)元）")
                } else {
                    titleLabel.text("优惠券")
                    detailLabel.text("已选择\(checkCount1)张(抵扣\(discountMoney1)元）")
                }
                if isServiceOrder {
                    titleLabel.text("优惠券")
                    detailLabel.text("已选择\(checkCount1)张(抵扣\(discountMoney1)元）")
                }
            case 5:
                let price1 = Decimal.init(payMoney)
                let price2 = Decimal.init(purchaseModel.serviceMoney?.doubleValue ?? 0)
                var price3 = Decimal.init(discountMoney)
                if discountType == 1 {
                    price3 = Decimal.init(discountMoney1)
                }
                let price = price1 + price2 - price3
                let titleLabel = UILabel().text("实付金额:").textColor(.kColor33).font(12)
                let detailLabel = UILabel().text("¥\(price)").textColor(UIColor.hexColor("#FFEC632A")).font(12)
                cell.sv(titleLabel, detailLabel)
                |-14-titleLabel.centerVertically()
                |-88-detailLabel.centerVertically()
            default:
                break
            }
        } else {
            switch indexPath.row {
            case 0:
                let line = UIView().backgroundColor(UIColor.hexColor("#FF61D9B9"))
                let titleLabel = UILabel().text("支付信息").textColor(.kColor33).fontBold(14)
                cell.sv(line, titleLabel)
                cell.layout(
                    17.5,
                    |-14-line.width(2).height(15)-5-titleLabel,
                    12.5
                )
            case 1:
                let titleLabel = UILabel().text("商品金额:").textColor(.kColor33).font(12)
                let detailLabel = UILabel().text("¥\(payMoney)").textColor(.kColor33).font(12)
                cell.sv(titleLabel, detailLabel)
                |-14-titleLabel.centerVertically()
                |-88-detailLabel.centerVertically()
            case 2:
                let titleLabel = UILabel().text("服务费:").textColor(.kColor33).font(12)
                let detailLabel = UILabel().text("¥\(purchaseModel.serviceMoney?.doubleValue ?? 0)").textColor(.kColor33).font(12)
                cell.sv(titleLabel, detailLabel)
                |-14-titleLabel.centerVertically()
                |-88-detailLabel.centerVertically()
            case 3:
                let titleLabel = UILabel().text("优惠方式:").textColor(.kColor33).font(12)
                let djqBtn = UIButton().image(#imageLiteral(resourceName: "login_check"))
                let djqLab = UILabel().text("代金券").textColor(.kColor33).font(12)
                let yhqBtn = UIButton().image(#imageLiteral(resourceName: "login_uncheck"))
                let yhqLab = UILabel().text("优惠券").textColor(.kColor33).font(12)
                cell.sv(titleLabel, djqBtn, djqLab, yhqBtn, yhqLab)
                cell.layout(
                    13.75,
                    |-14-titleLabel.height(16.5)-(>=0)-djqBtn.size(26)-0-djqLab-16-yhqBtn.size(26)-0-yhqLab-14-|,
                    13.75
                )
                if discountType == 0 {
                    djqBtn.image(#imageLiteral(resourceName: "login_check"))
                    yhqBtn.image(#imageLiteral(resourceName: "login_uncheck"))
                } else {
                    djqBtn.image(#imageLiteral(resourceName: "login_uncheck"))
                    yhqBtn.image(#imageLiteral(resourceName: "login_check"))
                }
                djqBtn.tapped { [weak self] (btn) in
                    self?.discountType = 0
                    self?.tableView.reloadData()
                }
                yhqBtn.tapped { [weak self] (btn) in
                    self?.discountType = 1
                    self?.tableView.reloadData()
                    if self?.couponModels1.count == 0 {
                        self?.loadUseableCouponsData1()
                    }
                }
            case 4:
                let titleLabel = UILabel().text("代金券:").textColor(.kColor33).font(12)
                let detailLabel = UILabel().text("已选择\(checkCount)张(抵扣\(discountMoney)元）").textColor(.kColor33).font(12)
                cell.sv(titleLabel, detailLabel)
                |-14-titleLabel.centerVertically()-(>=0)-detailLabel.centerVertically()-16.5-|
                cell.accessoryType = .disclosureIndicator
                if discountType == 0 {
                    titleLabel.text("代金券")
                    detailLabel.text("已选择\(checkCount)张(抵扣\(discountMoney)元）")
                } else {
                    titleLabel.text("优惠券")
                    detailLabel.text("已选择\(checkCount1)张(抵扣\(discountMoney1)元）")
                }
            case 5:
                let price1 = Decimal.init(payMoney)
                let price2 = Decimal.init(purchaseModel.serviceMoney?.doubleValue ?? 0)
                var price3 = Decimal.init(discountMoney)
                if discountType == 1 {
                    price3 = Decimal.init(discountMoney1)
                }
                let price = price1 + price2 - price3
                let titleLabel = UILabel().text("实付金额:").textColor(.kColor33).font(12)
                let detailLabel = UILabel().text("¥\(price)").textColor(UIColor.hexColor("#FFEC632A")).font(12)
                cell.sv(titleLabel, detailLabel)
                |-14-titleLabel.centerVertically()
                |-88-detailLabel.centerVertically()
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 4 {
            if payMoney < 0.1 {
                if discountType == 0 {
                    noticeOnlyText("订单金额小于0.1元，无法使用代金券")
                } else {
                    noticeOnlyText("订单金额小于0.1元，无法使用优惠券")
                }
                return
            }
            if discountType == 0 {
                configDJQView()
            } else {
                configYHQView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
        v.sv(surePayBtn)
        v.layout(
            >=0,
            surePayBtn.width(280).height(40).centerHorizontally(),
            10
        )
        let price1 = Decimal.init(payMoney)
        let price2 = Decimal.init(purchaseModel.serviceMoney?.doubleValue ?? 0)
        var price3 = Decimal.init(discountMoney)
        if discountType == 1 {
            price3 = Decimal.init(discountMoney1)
        }
        let price = price1 + price2 - price3
        surePayBtn.text("确认支付 ¥\(price)")
        surePayBtn.tapped { [weak self] (btn) in
            self?.toPay()
        }
        return v
    }
    //MARK: - 付款
    func toPay() {
        var parameters = Parameters()
        //parameters["userId"] = UserData1.shared.tokenModel?.userId
        parameters["orderId"] = orderId
        if discountType == 0 {
            parameters["discountMoney"] = discountMoney
            parameters["couponIds"] = checkCouponIds
        } else {
            parameters["discountMoney"] = discountMoney1
            parameters["couponIds"] = checkCouponIds1
        }
        YZBSign.shared.request(APIURL.sandPayOrder, method: .post, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataString = Utils.getReadString(dir: response as NSDictionary, field: "data")
                let responseDic = String.getDictionaryFromJSONString(jsonString: dataString)
                let errorCode = responseDic["errorCode"] as? String
                let errorMsg = responseDic["errorMsg"] as? String
                if errorCode == "000" {
                    if let body = responseDic["body"] as? [String: Any] {
                        if let data = body["data"] as? [String: Any] {
                            let sign = Utils.getReadString(dir: data as NSDictionary, field: "sign")
                            self.vipPayRequest(sign: sign, data: data)
                        }
                    }
                } else {
                    self.notice(errorMsg ?? "", autoClear: true, autoClearTime: 3)
                }
                
            }
        } failure: { (error) in
            
        }
    }
}


extension OrderPayNewVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return self.couponModels.count
        }
        return self.couponModels1.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let model = couponModels[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withClass: PurchaseDetailItem.self, for: indexPath)
            cell.model = model
            cell.checkBtnBlock = { (btn) in
                let payMoney = (self.purchaseModel.payMoney?.doubleValue ?? 0)
                if btn.isSelected && self.checkCouponMoney >= (payMoney / 10) {
                    btn.isSelected = !btn.isSelected
                    self.noticeOnlyText("代金券抵扣金额已达上限")
                    return
                }
                self.useTJCoupoonHandle(flag: false)
                model.isCheckBox = btn.isSelected
                self.checkCouponMoney = 0
                self.checkCouponIds = ""
                self.checkCount = 0
                self.couponModels.forEach { (model) in
                    if model.isCheckBox ?? false {
                        self.checkCount = self.checkCount + 1
                        self.checkCouponMoney += (model.denomination?.doubleValue ?? 0)
                        if !self.checkCouponIds.isEmpty {
                            self.checkCouponIds.append(",")
                        }
                        self.checkCouponIds.append(model.id ?? "")
                    }
                }
                if self.checkCouponMoney >= (payMoney / 10) {
                    self.discountMoney = payMoney / 10
                } else {
                    self.discountMoney = self.checkCouponMoney
                }
                if self.checkCount == 0 {
                    self.selectLab.text("请选择代金券")
                } else {
                    self.unUseYHBtn.image(#imageLiteral(resourceName: "purchase_uncheck"))
                    self.selectLab.text("已选中\(self.checkCount)张代金券,金额:¥\(self.discountMoney)")
                }
            }
            return cell
        }
        let model = couponModels1[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withClass: PurchaseDetailItem1.self, for: indexPath)
        cell.model = model
        cell.checkBtnBlock = { (btn) in
//            if btn.isSelected && self.checkCouponMoney1 >= (payMoney / 10) {
//                btn.isSelected = !btn.isSelected
//                self.noticeOnlyText("优惠券抵扣金额已达上限")
//                return
//            }
            self.couponModels1.forEach { (model1) in
                model1.isCheckBox = false
            }
            model.isCheckBox = btn.isSelected
            self.checkCouponMoney1 = 0
            self.checkCouponIds1 = ""
            self.checkCount1 = 1
            self.checkCouponMoney1 = model.denomination?.doubleValue ?? 0
            self.checkCouponIds1.append(model.id ?? "")
            
            self.discountMoney1 = self.checkCouponMoney1
            self.unUseYHBtn1.image(#imageLiteral(resourceName: "purchase_uncheck"))
            self.collectionView1.reloadData()
        }
        return cell
    }
}


class PurchaseDetailItem: UICollectionViewCell {
    var model: CouponModel? {
        didSet {
            configCell()
        }
    }
    private var bgIV = UIImageView().image(#imageLiteral(resourceName: "purchase_djq_bg_1_1")).backgroundColor(.white)
    private var leftBg = UIImageView().image(#imageLiteral(resourceName: "purchase_djq_bg_1"))
    private var rightBg = UIView().backgroundColor(UIColor.hexColor("#61D9B9"))
    let priceDes = UILabel().text("¥").textColor(.white).font(18)
    let price = UILabel().text("500").textColor(.white).fontBold(28)
    let useBtn = UIButton().text("立即使用").textColor(.k2AC99E).font(10).backgroundColor(.white).cornerRadius(10).masksToBounds()
    let status = UILabel().text("全网券").textColor(.white).font(10)
    let titleDes = UIView().backgroundColor(#colorLiteral(red: 0.1137254902, green: 0.7725490196, blue: 0.5921568627, alpha: 1)).cornerRadius(3).masksToBounds()
    let title = UILabel().text("仅限购买厨房卫浴-厨电品类的产品").textColor(.kColor33).fontBold(12)
    private var time = UILabel().text("有效期至2020.08.18").textColor(.kColor66).font(10)
    private var time1 = UILabel().text("2020.08.18").textColor(.kColor66).font(10)
    let statusIV = UIImageView().image(#imageLiteral(resourceName: "purchase_use_icon"))
    let checkBtn = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgIV.isUserInteractionEnabled = true
        sv(bgIV)
        layout(
            0,
            |-14-bgIV.height(100)-14-|,
            10
        )
        
        bgIV.sv(leftBg, rightBg)
        bgIV.layout(
            0,
            |leftBg.width(105),
            0
        )
        
        bgIV.layout(
            0,
            rightBg.width(60).height(20)-0-|,
            >=0
        )
        bgIV.sv(priceDes, price, useBtn, status, titleDes, title, time, time1, statusIV, checkBtn)
        
        bgIV.layout(
            >=0,
            statusIV.size(55)-6-|,
            6
        )
        bgIV.layout(
            3,
            status.height(14)-15-|,
            >=0
        )
        bgIV.layout(
            35.5,
            |-125-titleDes.size(6),
            >=0,
            |-125-time.height(14),
            1,
            |-166-time1.height(14),
            7
        )
        bgIV.layout(
            30,
            |-135-title-60-|,
            >=0
        )
        bgIV.layout(
            30,
            checkBtn.size(40)-0-|,
            >=0
        )
        bgIV.layout(
            41,
            |-21-priceDes.height(25)-2-price.height(39),
            >=0
        )
        checkBtn.setImage(#imageLiteral(resourceName: "purchase_uncheck"), for: .normal)
        checkBtn.setImage(#imageLiteral(resourceName: "purchase_check"), for: .selected)
        
        checkBtn.addTarget(self, action: #selector(checkBtnClick(btn:)))
        rightBg.corner(byRoundingCorners: [.bottomLeft, .topRight], radii: 4)
        title.numberOfLines(0).lineSpace(2)
        statusIV.isHidden = true
    }
    
    func configCell() {
        checkBtn.isSelected = model?.isCheckBox ?? false
        // checkBtn.isEnabled = model?.isEnable ?? true
        price.text("\(model?.denomination ?? 0)")
        switch model?.type {
        case "1":
            status.text("全网券")
            bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_1_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_1"))
            rightBg.backgroundColor(UIColor.hexColor("#1DC597"))
            titleDes.backgroundColor(UIColor.hexColor("#1DC597"))
        case "2":
            status.text("天网券")
            bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_2_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_2"))
            rightBg.backgroundColor(UIColor.hexColor("#3564F6"))
            titleDes.backgroundColor(UIColor.hexColor("#3564F6"))
        case "3":
            status.text("地网券")
            bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_3_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_3"))
            rightBg.backgroundColor(UIColor.hexColor("#F68235"))
            titleDes.backgroundColor(UIColor.hexColor("#F68235"))
        default:
            break
        }
        switch model?.usableRange {
        case "1":
            title.text("全场通用")
        case "2":
            title.text("仅限购买\(model?.name ?? "")-\(model?.objName ?? "")品类的产品")
        case "3":
            title.text("仅限购买\(model?.objName ?? "")品牌商的产品")
        default:
            break
        }
        time.text("有效期：\(model?.createDate ?? "")")
        time1.text("\(model?.invalidDate ?? "")")
        
        statusIV.isHidden = true
        useBtn.isHidden = true
        
    }
    
    var checkBtnBlock: ((UIButton) -> Void)?
    @objc private func checkBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        checkBtnBlock?(btn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


class PurchaseDetailItem1: UICollectionViewCell {
    var model: CouponModel? {
        didSet {
            configCell()
        }
    }
    var refreshList: (() -> Void)?
    private var bgIV = UIImageView().image(#imageLiteral(resourceName: "purchase_yhq_bg_1_1")).backgroundColor(.white)
    private var leftBg = UIImageView().image(#imageLiteral(resourceName: "purchase_yhq_bg_1"))
    private var priceBg = UIView()
    private var priceDes = UILabel().text("¥").textColor(.white).font(18)
    private var price = UILabel().text("500").textColor(.white).fontBold(28)
    private var mkLabel = UILabel().text("无门槛").textColor(.white).font(12)
    private var useBtn = UIButton().text("立即使用").textColor(.white).font(10)
    private var title = UILabel().text("仅限购买厨房卫浴-厨电品类的产品").textColor(.kColor33).fontBold(12)
    private var time = UILabel().text("有效期至2020.08.18").textColor(.kColor66).font(10)
    private var xxLine = UIImageView().image(#imageLiteral(resourceName: "purchase_yhq_bg_2_2"))
    private var xzLabel = UILabel().text("全场通用").textColor(.kColor33).font(10)
    private var statusIV = UIImageView().image(#imageLiteral(resourceName: "purchase_use_icon"))
    let checkBtn = UIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgIV.addShadowColor()
        sv(bgIV)
        
        layout(
            0,
            |-14-bgIV.height(100)-14-|,
            10
        )
        
        bgIV.sv(leftBg)
        bgIV.layout(
            0,
            |leftBg.width(105),
            0
        )
       // bgIV.isUserInteractionEnabled = true
        bgIV.sv(title, time, xxLine, xzLabel, statusIV, useBtn, checkBtn)
        
        leftBg.sv(priceBg, mkLabel)
        leftBg.layout(
            15,
            priceBg.height(39).centerHorizontally(),
            13.5,
            mkLabel.height(16.5).centerHorizontally(),
            19.5
        )
        priceBg.sv(priceDes, price)
        priceBg.layout(
            10.5,
            |-0-priceDes.height(25),
            >=0
        )
        priceBg.layout(
            0,
            |-13-price.height(39)-0-|,
            0
        )
        leftBg.layout(
            15,
            |-34-price.height(39),
            >=0
        )
        bgIV.layout(
            >=0,
            statusIV.size(55)-6-|,
            6
        )
        bgIV.layout(
            20,
            |-120-title.height(16.5)-20-|,
            7,
            |-120-time.height(14),
            10.25,
            |-120-xxLine.height(0.5)-97.5-|,
            8.25,
            |-120-xzLabel.height(14),
            10
        )
        statusIV.isHidden = true
        time.numberOfLines(0).lineSpace(2)
        bgIV.layout(
            30,
            checkBtn.size(40)-0-|,
            >=0
        )
        bgIV.isUserInteractionEnabled = true
        checkBtn.setImage(#imageLiteral(resourceName: "purchase_uncheck"), for: .normal)
        checkBtn.setImage(#imageLiteral(resourceName: "purchase_check"), for: .selected)
        checkBtn.addTarget(self, action: #selector(checkBtnClick(btn:)))
        title.numberOfLines(0).lineSpace(2)
        statusIV.isHidden = true
    }
    
    func configCell() {
        checkBtn.isSelected = model?.isCheckBox ?? false
        xxLine.image(#imageLiteral(resourceName: "purchase_yhq_bg_2_3"))
        title.text(model?.name ?? "")
        price.text("\(model?.denomination ?? 0)")
        if model?.useThreshold == "1" {
            mkLabel.text("无门槛")
        } else {
            mkLabel.text("满\(model?.withAmount?.doubleValue ?? 0)元可用")
        }
        
        switch model?.usableRange {
        case "1":
            xzLabel.text("全场通用")
        case "2":
            xzLabel.text("仅限购买\(model?.name ?? "")-\(model?.objName ?? "")品类的产品")
        case "3":
            xzLabel.text("仅限购买\(model?.objName ?? "")品牌商的产品")
        default:
            break
        }
        let invalidDate = model?.invalidDate ?? ""
        let invalidDate1 = invalidDate.components(separatedBy: " ").first ?? ""
        time.text("有效期：\(invalidDate1)")
        bgIV.image(#imageLiteral(resourceName: "purchase_yhq_bg_1_1"))
        leftBg.image(#imageLiteral(resourceName: "purchase_yhq_bg_1"))
        statusIV.image(#imageLiteral(resourceName: "purchase_djq_no_1"))
        statusIV.isHidden = true
        useBtn.isHidden = true
        bgIV.bringSubviewToFront(useBtn)
        
    }
    
    var checkBtnBlock: ((UIButton) -> Void)?
    @objc private func checkBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        checkBtnBlock?(btn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

