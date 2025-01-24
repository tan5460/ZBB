//
//  PurchaseDetailController.swift
//  YZB_Company
//
//  Created by yzb_ios on 14.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import PopupDialog
import ObjectMapper
import MJRefresh
import TLTransitions


class PurchaseDetailController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    private var pop: TLTransition?
    private var pop1: TLTransition?
    //底部栏
    var bottomView: UIView!             //底部栏
    var subsidiaryBtn: UIButton!        //添加补差价产品按钮
    var addMaterialBtn: UIButton!       //添加主材
    var modifyServiceBtn: UIButton!     //修改服务费
    var delayDeliveryLabel: UILabel!    //延长收货描述
    var delayDeliveryBtn: UIButton!     //延长收货
    var sureOrderBtn: UIButton!         //确认订单
    var rePurchaseBtn: UIButton!        //重新下单
    
    //订单信息
    var orderNoLabel: UILabel!          //订单号
    var orderStatusLabel: UILabel!      //订单状态
    var orderRemarksLabel: UILabel!     //订单备注
    var orderTimeLabel: UILabel!        //订单时间
    
    //收货信息
    var displayStroeName: UILabel!      //采购员
    var storeNameLabel: UILabel!        //采购单位
    var merchantLabel: UILabel!         //供应商
    var consigneecLabel: UILabel!       //收货人
    var telLabel: UILabel!              //收货电话
    var addressLabel: UILabel!          //地址
    var chatBtn: UIButton!              //聊天
    var callBtn: UIButton!              //打电话
    
    //支付信息
    var orderMoneyLabel: UILabel!       //结算金额
    var systemMoneyLabel: UILabel!      //平台金额
    var payStatusLabel: UILabel!        //支付状态
    var payTimeLabel: UILabel!          //支付时间
    
    //商品列表
    var tableView: UITableView!
    var purchaseModel: PurchaseOrderModel?
    var infoModel: BaseUserInfoModel?
    
    var orderId = ""                    //订单id
    var removeId = ""                   //移除id
    var goBackBlock: ((_ orderModel: PurchaseOrderModel?)->())?
    var isPayQuery = false
    private var delayTimeModel: DelayTimeModel?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isPayQuery {
            self.isPayQuery = false
            
            let popup = PopupDialog(title: "提示", message: "支付结果查询可能会延迟，如支付成功但是订单状态未改变，请尝试下拉刷新重新查看订单状态！", buttonAlignment: .horizontal, tapGestureDismissal: false)
            let sureBtn = AlertButton(title: "确认") {
                self.pleaseWait()
                self.loadData()
                
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
            
        }else {
            //  self.pleaseWait()
            self.loadData()  
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单详情"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        
        prepareBottomView()
        prepareTableView()
        loadDelayTimeData()
        
        
    }
    
    func loadDelayTimeData() {
        
        YZBSign.shared.request(APIURL.getDelayTimeInfo, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.delayTimeModel = Mapper<DelayTimeModel>().map(JSON: dataDic as! [String : Any])
            }
        }) { (error) in
            
        }
    }
    
        
    ///底部栏
    func prepareBottomView() {
        
        //底部栏
        bottomView = UIView()
        bottomView.isHidden = true
        bottomView.backgroundColor = .white
        bottomView.layerShadow(color: .black, offsetSize: CGSize(width: 0, height: -1), opacity: 0.1, radius: 2)
        view.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
            } else {
                make.height.equalTo(44)
            }
        }
        
        //确认订单
        sureOrderBtn = UIButton()
        sureOrderBtn.layer.borderWidth = 0.5
        sureOrderBtn.layer.borderColor = PublicColor.placeholderTextColor.cgColor
        sureOrderBtn.layer.cornerRadius = 2
        sureOrderBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        sureOrderBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        sureOrderBtn.setTitle("确认订单", for: .normal)
        sureOrderBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        sureOrderBtn.titleLabel?.sizeToFit()
        
        sureOrderBtn.addTarget(self, action: #selector(sureOrderAction), for: .touchUpInside)
        bottomView.addSubview(sureOrderBtn)
        
        sureOrderBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalTo(8)
            make.width.equalTo(66)
            make.height.equalTo(28)
        }
        
        rePurchaseBtn = UIButton().text("重新下单").textColor(.white).font(12).backgroundColor(UIColor.hexColor("#FD9C3B")).cornerRadius(4)
        bottomView.addSubview(rePurchaseBtn)
        rePurchaseBtn.snp.makeConstraints { (make) in
            make.right.equalTo(sureOrderBtn.snp.left).offset(-10)
            make.centerY.height.equalTo(sureOrderBtn)
            make.width.equalTo(80)
        }
        rePurchaseBtn.tapped { [weak self] (btn) in
            self?.configRePurchasePopView()
        }
        rePurchaseBtn.isHidden = true
        
        
        //修改服务费
        modifyServiceBtn = UIButton()
        modifyServiceBtn.layer.borderWidth = sureOrderBtn.layer.borderWidth
        modifyServiceBtn.layer.borderColor = sureOrderBtn.layer.borderColor
        modifyServiceBtn.layer.cornerRadius = sureOrderBtn.layer.cornerRadius
        modifyServiceBtn.setTitle("修改服务费", for: .normal)
        modifyServiceBtn.titleLabel?.font = sureOrderBtn.titleLabel?.font
        modifyServiceBtn.titleLabel?.sizeToFit()
        modifyServiceBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        modifyServiceBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        modifyServiceBtn.addTarget(self, action: #selector(modifyServiceAction), for: .touchUpInside)
        bottomView.addSubview(modifyServiceBtn)
        
        modifyServiceBtn.snp.makeConstraints { (make) in
            make.right.equalTo(sureOrderBtn.snp.left).offset(-10)
            make.centerY.height.equalTo(sureOrderBtn)
            make.width.equalTo(76)
        }
        
        //延长收货
        delayDeliveryBtn = UIButton().text("延长收货").textColor(UIColor.hexColor("#FD9C3B")).font(12).borderColor(UIColor.hexColor("#FD9C3B")).borderWidth(0.5).cornerRadius(2)
        delayDeliveryBtn.addTarget(self, action: #selector(delayDeliveryBtnClick(btn:)), for: .touchUpInside)
        bottomView.addSubview(delayDeliveryBtn)
        
        delayDeliveryBtn.snp.makeConstraints { (make) in
            make.right.equalTo(sureOrderBtn.snp.left).offset(-14)
            make.centerY.height.equalTo(sureOrderBtn)
            make.width.equalTo(80)
        }
        delayDeliveryBtn.isHidden = true
        
        delayDeliveryLabel = UILabel().text("\(purchaseModel?.orderAutomaticReceiptTime ?? "")订单将自动确认收货").textColor(UIColor.hexColor("#FD9C3B")).font(10)
        bottomView.addSubview(delayDeliveryLabel)
        delayDeliveryLabel.snp.makeConstraints { (make) in
            make.left.equalTo(14)
            make.right.equalTo(delayDeliveryBtn.snp.left).offset(-20)
            make.centerY.height.equalTo(sureOrderBtn)
        }
        delayDeliveryLabel.numberOfLines(0).lineSpace(2)
        delayDeliveryLabel.isHidden = true
        //添加主材
        addMaterialBtn = UIButton()
        addMaterialBtn.layer.borderWidth = sureOrderBtn.layer.borderWidth
        addMaterialBtn.layer.borderColor = sureOrderBtn.layer.borderColor
        addMaterialBtn.layer.cornerRadius = sureOrderBtn.layer.cornerRadius
        addMaterialBtn.setTitle("添加产品", for: .normal)
        addMaterialBtn.titleLabel?.font = sureOrderBtn.titleLabel?.font
        addMaterialBtn.titleLabel?.sizeToFit()
        addMaterialBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        addMaterialBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        addMaterialBtn.addTarget(self, action: #selector(addMaterialAction), for: .touchUpInside)
        bottomView.addSubview(addMaterialBtn)
        
        addMaterialBtn.snp.makeConstraints { (make) in
            make.right.equalTo(modifyServiceBtn.snp.left).offset(-10)
            make.centerY.height.equalTo(sureOrderBtn)
            make.width.equalTo(sureOrderBtn)
        }
        
        //添加补差价产品
        subsidiaryBtn = UIButton()
        subsidiaryBtn.layer.borderWidth = sureOrderBtn.layer.borderWidth
        subsidiaryBtn.layer.borderColor = sureOrderBtn.layer.borderColor
        subsidiaryBtn.layer.cornerRadius = sureOrderBtn.layer.cornerRadius
        
        
        subsidiaryBtn.titleLabel?.font = sureOrderBtn.titleLabel?.font
        subsidiaryBtn.titleLabel?.sizeToFit()
        subsidiaryBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        subsidiaryBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        
        subsidiaryBtn.setTitle("修改订单金额", for: .normal)
        subsidiaryBtn.addTarget(self, action: #selector(editOrderPriceAction), for: .touchUpInside)
        
        
        bottomView.addSubview(subsidiaryBtn)
        
        subsidiaryBtn.snp.makeConstraints { (make) in
            make.right.equalTo(addMaterialBtn.snp.left).offset(-10)
            make.centerY.height.equalTo(sureOrderBtn)
            make.width.equalTo(98)
        }
    }
    
    //MARK: - 重新下单
    func configRePurchasePopView() {
        let v = CommonAlertView(frame: CGRect(x: 0, y: 0, width: 272, height: 164)).backgroundColor(.white)
        v.configPopView(title: "重新下单", message: "重新下单，自动将当前订单的产品加入到购物车，请问是否重新下单？") {
            self.rePurchaseRequest()
        }
    }
    
    func rePurchaseRequest() {
        var parameters = Parameters()
        if let valueStr = self.purchaseModel?.id {
            parameters["orderId"] = valueStr
        } else {
            parameters["orderId"] = orderId
        }
        YZBSign.shared.request(APIURL.restoreShoppingCart, method: .post, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                self.navigationController?.pushViewController(WantPurchaseController())
//                if self.purchaseModel?.payType == 2 {
//                    self.navigationController?.pushViewController(PlaceOrderController())
//                } else {
//
//                }
                
            }
        }) { (error) in
            
        }
    }
    
    ///tableView
    func prepareTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 160
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PurchaseDetailCell1.self, forCellReuseIdentifier: PurchaseDetailCell1.self.description())
        tableView.register(PurchaseDetailCell2.self, forCellReuseIdentifier: PurchaseDetailCell2.self.description())
        view.insertSubview(tableView, belowSubview: bottomView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //--注册组头
        tableView.register(PurchaseDetailHeader.self, forHeaderFooterViewReuseIdentifier: PurchaseDetailHeader.self.description())
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(loadData))
        tableView.mj_header = header
    }
    
    func updateBottomView() {
        bottomView.isHidden = true
        modifyServiceBtn.setTitle("修改服务费", for: .normal)
        tableView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
            
            //待确认
            if purchaseModel?.orderStatus == 1 || purchaseModel?.orderStatus == 2 {
                subsidiaryBtn.isHidden = false
                addMaterialBtn.isHidden = false
                modifyServiceBtn.isHidden = false
                sureOrderBtn.isHidden = false
                rePurchaseBtn.isHidden = true
                delayDeliveryBtn.isHidden = true
                delayDeliveryLabel.isHidden = true
                sureOrderBtn.setTitle("确认订单", for: .normal)
                
                bottomView.isHidden = false
                tableView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-44)
                }
            }
            
            //待发货
            if  purchaseModel?.orderStatus == 4 {
                subsidiaryBtn.isHidden = true
                addMaterialBtn.isHidden = true
                modifyServiceBtn.isHidden = true
                sureOrderBtn.isHidden = false
                rePurchaseBtn.isHidden = true
                delayDeliveryBtn.isHidden = true
                delayDeliveryLabel.isHidden = true
                sureOrderBtn.setTitle("确认发货", for: .normal)
                
                bottomView.isHidden = false
                tableView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.bottom.equalTo(self.bottomView.snp.top)
                }
            }
            
            //待发货
            if  purchaseModel?.orderStatus == 5 {
                subsidiaryBtn.isHidden = true
                addMaterialBtn.isHidden = true
                modifyServiceBtn.isHidden = true
                sureOrderBtn.isHidden = false
                rePurchaseBtn.isHidden = true
                delayDeliveryBtn.isHidden = true
                delayDeliveryLabel.isHidden = true
                sureOrderBtn.text("修改物流信息")
                sureOrderBtn.snp.remakeConstraints { (make) in
                    make.right.equalTo(-15)
                    make.top.equalTo(8)
                    make.width.equalTo(80)
                    make.height.equalTo(28)
                }
                
                bottomView.isHidden = false
                tableView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.bottom.equalTo(self.bottomView.snp.top)
                }
            }
            
        }else if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
            
            //待付款
            if purchaseModel?.orderStatus == 3 {
                subsidiaryBtn.isHidden = true
                addMaterialBtn.isHidden = true
                modifyServiceBtn.isHidden = false
                delayDeliveryBtn.isHidden = true
                delayDeliveryLabel.isHidden = true
                modifyServiceBtn.setTitle("取消订单", for: .normal)
                sureOrderBtn.isHidden = false
                rePurchaseBtn.isHidden = true
                sureOrderBtn.setTitle("付款", for: .normal)
                sureOrderBtn.backgroundColor = UIColor.hexColor("#FF61D9B9")
                sureOrderBtn.borderWidth(0.5).borderColor(UIColor.hexColor("#FF61D9B9"))
                sureOrderBtn.cornerRadius(4).textColor(.white)
                
                bottomView.isHidden = false
                tableView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.bottom.equalTo(self.bottomView.snp.top)
                }
            } else {
                sureOrderBtn.layer.borderWidth = 0.5
                sureOrderBtn.layer.borderColor = PublicColor.placeholderTextColor.cgColor
                sureOrderBtn.layer.cornerRadius = 2
                sureOrderBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
                sureOrderBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
            }
            
            //待收货
            if purchaseModel?.orderStatus == 5 {
                subsidiaryBtn.isHidden = true
                addMaterialBtn.isHidden = true
                modifyServiceBtn.isHidden = true
                delayDeliveryBtn.isHidden = false
                delayDeliveryLabel.isHidden = false
                delayDeliveryLabel.text("\(purchaseModel?.orderAutomaticReceiptTime ?? "")订单将自动确认收货")
                
                sureOrderBtn.isHidden = false
                rePurchaseBtn.isHidden = true
                sureOrderBtn.setTitle("确认收货", for: .normal)
                        
                bottomView.isHidden = false
                if purchaseModel?.isChange == 1 {
                    delayDeliveryBtn.isHidden = false
                    delayDeliveryLabel.snp.remakeConstraints { (make) in
                        make.left.equalTo(14)
                        make.right.equalTo(delayDeliveryBtn.snp.left).offset(-20)
                        make.centerY.height.equalTo(sureOrderBtn)
                    }
                    delayDeliveryLabel.snp.updateConstraints { (make) in
                        make.right.equalTo(delayDeliveryBtn.snp.left).offset(20)
                    }
                } else {
                    delayDeliveryBtn.isHidden = true
                    delayDeliveryLabel.snp.remakeConstraints { (make) in
                        make.left.equalTo(14)
                        make.right.equalTo(sureOrderBtn.snp.left).offset(-20)
                        make.centerY.height.equalTo(sureOrderBtn)
                    }
                }
                tableView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.bottom.equalTo(self.bottomView.snp.top)
                }
            }
            
            //取消
            if purchaseModel?.orderStatus == 1 || purchaseModel?.orderStatus == 2 {
                subsidiaryBtn.isHidden = true
                addMaterialBtn.isHidden = true
                modifyServiceBtn.isHidden = true
                sureOrderBtn.isHidden = false
                delayDeliveryBtn.isHidden = true
                delayDeliveryLabel.isHidden = true
                sureOrderBtn.setTitle("取消订单", for: .normal)
                rePurchaseBtn.isHidden = true
                bottomView.isHidden = false
                tableView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.bottom.equalTo(self.bottomView.snp.top)
                }
            }
            
            //删除
            if purchaseModel?.orderStatus == 8 {
                subsidiaryBtn.isHidden = true
                addMaterialBtn.isHidden = true
                modifyServiceBtn.isHidden = true
                sureOrderBtn.isHidden = false
                delayDeliveryBtn.isHidden = true
                delayDeliveryLabel.isHidden = true
                sureOrderBtn.setTitle("删除订单", for: .normal)
                if purchaseModel?.isChange == 1 {
                    rePurchaseBtn.isHidden = false
                    if purchaseModel?.payType == 2 {
                        rePurchaseBtn.isHidden = true
                    }
                } else {
                    rePurchaseBtn.isHidden = true
                }
                bottomView.isHidden = false
                tableView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.bottom.equalTo(self.bottomView.snp.top)
                }
            }
            
            //审核再付款
            if purchaseModel?.orderStatus == 10 {
                subsidiaryBtn.isHidden = true
                addMaterialBtn.isHidden = true
                modifyServiceBtn.isHidden = false
                delayDeliveryBtn.isHidden = true
                delayDeliveryLabel.isHidden = true
                modifyServiceBtn.setTitle("取消订单", for: .normal)
                sureOrderBtn.isHidden = false
                rePurchaseBtn.isHidden = true
                sureOrderBtn.setTitle("付款", for: .normal)
                
                bottomView.isHidden = false
                tableView.snp.remakeConstraints { (make) in
                    make.left.right.top.equalToSuperview()
                    make.bottom.equalTo(self.bottomView.snp.top)
                }
            }
        }
        
        if purchaseModel?.activityType == 2 || purchaseModel?.activityType == 3 {
            addMaterialBtn.isHidden = true
            subsidiaryBtn.snp.remakeConstraints { (make) in
                make.right.equalTo(modifyServiceBtn.snp.left).offset(-10)
                make.centerY.height.equalTo(sureOrderBtn)
                make.width.equalTo(98)
            }
        }
    }
    
    
    //MARK: - 按钮事件
    
    ///返回
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 确认发货弹窗及请求
    func configSureSendGoods() {
        let v = PurchaseSureSendView(frame: CGRect(x: 0, y: 0, width: 272, height: 315))
        if UserData.shared.userType == .gys {
            v.titleLabel.text("修改物流信息")
        }
        v.companyTextField.text(purchaseModel?.logisticsCompany ?? "")
        v.numTextField.text(purchaseModel?.logisticsNo ?? "")
        v.remarkTextView.placeHolderExLabel?.isHidden = true
        v.remarkTextView.text = purchaseModel?.logisticsRemarks ?? ""
        
        v.sureBtnBlock = { [weak self] (company, no, remark) in
            if self?.purchaseModel?.orderStatus == 5 {
                self?.editLogisticsInfoRequest(company: company, no: no, remark: remark)
            } else {
                self?.confirmShipmentRequest(company: company, no: no, remark: remark)
            }
        }
    }
    
    func confirmShipmentRequest(company: String, no: String, remark: String) {
        var parameters = Parameters()
        parameters["id"] = orderId
        parameters["logisticsCompany"] = company
        parameters["logisticsNo"] = no
        parameters["logisticsRemarks"] = remark
        YZBSign.shared.request(APIURL.confirmShipment, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                GlobalNotificationer.post(notification: .purchaseRefresh)
                self.pleaseWait()
                self.loadData()
            }
        }) { (error) in
            
        }
    }
    
    func editLogisticsInfoRequest(company: String, no: String, remark: String) {
        var parameters = Parameters()
        parameters["orderId"] = orderId
        parameters["logisticsCompany"] = company
        parameters["logisticsNo"] = no
        parameters["logisticsRemarks"] = remark
        YZBSign.shared.request(APIURL.editLogisticsInfo, method: .put, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                GlobalNotificationer.post(notification: .purchaseRefresh)
                self.pleaseWait()
                self.loadData()
            }
        }) { (error) in
            
        }
    }
    
    //MARK: - 取消订单弹窗
    func cancelOrderReasonPop() {
        let v = CancelOrderReasonView.init(frame: CGRect(x: 0, y: 0, width: 272, height: 422)).backgroundColor(.white)
        v.cancelBtnBlock = { [weak self] in
            self?.pop?.dismiss()
        }
        v.sureBtnBlock = { [weak self] (reason) in
            self?.cancelOrderRequest(reason: reason)
            self?.pop?.dismiss()
        }
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
    }
    
    func cancelOrderRequest(reason: String) {
        var parameters: Parameters = [:]
        parameters["orderStatus"] = "8"
        parameters["operReason"] = reason
        if let valueStr = self.purchaseModel?.id {
            parameters["id"] = valueStr
        } else {
            parameters["id"] = orderId
        }
        let method: HTTPMethod = .put
        let urlStr = APIURL.purchaseOrderStatus
        self.pleaseWait()
        
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                GlobalNotificationer.post(notification: .purchaseRefresh)
                self.pleaseWait()
                self.loadData()
            }
        }) { (error) in
        }
    }
    
    ///确认订单
    @objc func sureOrderAction(isCancel: Bool = false) {
        if purchaseModel == nil {
            self.noticeOnlyText("未读取到订单数据~")
            return
        }
        if purchaseModel?.orderStatus == 4 {
            configSureSendGoods()
            return
        }
        
        var msgStr = ""
        
        if self.purchaseModel?.orderStatus == 1 || self.purchaseModel?.orderStatus == 2 {
            
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                cancelOrderReasonPop()
                return
               // msgStr = "是否取消订单？"
            }else {
                msgStr = "订单确认后不可再编辑，是否继续？"
            }
        }
        
        if self.purchaseModel?.orderStatus == 3 || self.purchaseModel?.orderStatus == 10 {
            if isCancel {
                msgStr = "是否取消订单？"
                cancelOrderReasonPop()
                return
            } else {
                
                var payMoney: Double = 0
                var purchaseOrderId = ""
                
                if let valueStr = self.purchaseModel?.payMoney?.doubleValue {
                    payMoney = valueStr
                }
                if let valueStr = self.purchaseModel?.id {
                    purchaseOrderId = valueStr
                }
                
                if payMoney == 0 {
                    self.noticeOnlyText("支付金额为0")
                    return
                }
                if purchaseOrderId == "" {
                    self.noticeOnlyText("采购订单信息异常")
                    return
                }
                self.toPay()
                return
            }
        }
        
        if self.purchaseModel?.orderStatus == 4 {
            msgStr = "是否确认发货？"
        }
        
        if self.purchaseModel?.orderStatus == 5 {
            if UserData.shared.userType == .gys {
                configSureSendGoods()
                return
            }
            msgStr = "是否确认收货？"
        }
        
        if self.purchaseModel?.orderStatus == 8 {
            msgStr = "是否删除此订单？"
        }
        
        if (self.purchaseModel?.orderStatus == 1 ||
            self.purchaseModel?.orderStatus == 2) &&
            (UserData.shared.userType == .gys ||
                UserData.shared.userType == .yys) {
            
            var btnArray: [PopupDialogButton] = []
            
            let popup = PopupDialog(title: "请选择发货期限（以付款时间计算）", message: nil, buttonAlignment: .vertical)
            
            for dic in AppData.yzbSendTermList {
                
                let title = Utils.getReadString(dir: dic, field: "label")
                
                let btn = AlertButton(title: title) {
                    self.changeOrderStatus(isCancel: isCancel, sendTerm: title)
                }
                btnArray.append(btn)
            }
            
            let cancelBtn = CancelButton(title: "取消") {
            }
            
            btnArray.append(cancelBtn)
            popup.addButtons(btnArray)
            self.present(popup, animated: true, completion: nil)
            
        }else {
                let popup = PopupDialog(title: "提示", message: msgStr, buttonAlignment: .horizontal)
                let sureBtn = AlertButton(title: "确认") {
                    
                    self.changeOrderStatus(isCancel: isCancel)
                }
                let cancelBtn = CancelButton(title: "取消") {
                }
                popup.addButtons([cancelBtn,sureBtn])
                self.present(popup, animated: true, completion: nil)
        }
    }
    
    func changeOrderStatus(isCancel: Bool = false, sendTerm: String = "") {
        
        
        var parameters: Parameters = [:]
        
        if self.purchaseModel?.orderStatus == 8 {
            //删除订单
            if let orderId = self.purchaseModel?.id {
                parameters["id"] = orderId
            }
        }else {
            if self.purchaseModel?.orderStatus == 1 || self.purchaseModel?.orderStatus == 2 {
                
                if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                    parameters["orderStatus"] = "8"
                }else {
                    //  parameters["orderStatus"] = "3"
                    parameters["recevingTerm"] = sendTerm
                }
            }
            if self.purchaseModel?.orderStatus == 3 {
                if isCancel {
                    parameters["orderStatus"] = "8"
                }else {
                    
                }
            }
            
            if self.purchaseModel?.orderStatus == 4 {
                parameters["orderStatus"] = "5"
            }
            
            if self.purchaseModel?.orderStatus == 5 {
                parameters["orderStatus"] = "6"
            }
            
            if let valueStr = self.purchaseModel?.id {
                parameters["id"] = valueStr
            } else {
                parameters["id"] = orderId
            }
        }
        
        var method: HTTPMethod = .put
        var urlStr = APIURL.purchaseOrderStatus
        self.pleaseWait()
        
        if self.purchaseModel?.orderStatus == 8 {
            method = .delete
            urlStr = APIURL.delPurchaseOrder + (self.purchaseModel?.id ?? "")
        }
        
        if !sendTerm.isEmpty {
            method = .post
            urlStr = APIURL.surePurchaseOrder
        }
        
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                if self.purchaseModel?.orderStatus == 8 {
                    let popup = PopupDialog(title: "提示", message: "删除成功！", buttonAlignment: .horizontal)
                    let sureBtn = AlertButton(title: "确认") {
                        self.purchaseModel = nil
                        self.goBackBlock?(nil)
                        self.backAction()
                    }
                    popup.addButtons([sureBtn])
                    self.present(popup, animated: true, completion: nil)
                    
                } else if self.purchaseModel?.orderStatus == 1 || self.purchaseModel?.orderStatus == 2 {
                    GlobalNotificationer.post(notification: .purchaseRefresh)
                    self.pleaseWait()
                    self.loadData()
                }
                else {
                    if UserData.shared.userType == .yys || UserData.shared.userType == .cgy  {
                        self.removeOrder()
                    }
                    else {
                        GlobalNotificationer.post(notification: .purchaseRefresh)
                    }
                    self.pleaseWait()
                    self.loadData()
                }
                
                
            }
            
        }) { (error) in
            
        }
    }
    
    ///合伙人移除待办消息
    private func removeOrder() {
        if removeId == "" {
            return
        }
        let parameters: Parameters = ["id": removeId]
        
        self.pleaseWait()
        let urlStr =  APIURL.deleteSysMessage
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                GlobalNotificationer.post(notification: .yysSureOrderRefresh)
                // self.goBackBlock?(self.purchaseModel)
            }
            
        }) { (error) in
            
        }
    }
    // MARK: - 延长收获弹出视图
    @objc private func delayDeliveryBtnClick(btn: UIButton) {
        var extended = ""
        if delayTimeModel?.orderExtendedType == "1" {
            extended = "\(delayTimeModel?.orderExtendedValue ?? "0")天"
        } else if delayTimeModel?.orderExtendedType == "2" {
            extended = "\(delayTimeModel?.orderExtendedValue ?? "0")小时"
        } else if delayTimeModel?.orderExtendedType == "3" {
            extended = "\(delayTimeModel?.orderExtendedValue ?? "0")分钟"
        }
        let v = UIView.init(frame: CGRect(x: 0, y: 0, width: 272, height: 184)).backgroundColor(.white)
        let titleLabel = UILabel().text("延长收货").textColor(.kColor33).fontBold(14)
        let desLabel = UILabel().text("注意：每笔订单只能进行一次延长收货操作，可延长为\(extended)，是否确认延迟收货？").textColor(.kColor33).font(13)
        desLabel.numberOfLines(0).lineSpace(2)
        let delayCancelBtn = UIButton().text("取消").textColor(.k1DC597).font(14).borderColor(.kColor220).borderWidth(0.5)
        // 取消
        delayCancelBtn.tapped { [weak self] (btn) in
            self?.pop?.dismiss()
        }
        // 确认
        let delaySureBtn = UIButton().text("确认").textColor(.kColor33).font(14).borderColor(.kColor220).borderWidth(0.5)
        delaySureBtn.tapped { [weak self] (btn) in
            self?.pop?.dismiss()
            self?.delayReceivedGoods()
        }
        v.sv(titleLabel, desLabel, delayCancelBtn, delaySureBtn)
        v.layout(
            25,
            titleLabel.height(20).centerHorizontally(),
            15,
            desLabel.width(224).centerHorizontally(),
            >=0,
            |-0-delayCancelBtn.height(48.5)-0-delaySureBtn.height(48.5)-0-|,
            0
        )
        equal(widths: delayCancelBtn, delaySureBtn)
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
        
    }
    
    func delayReceivedGoods() {
        var parameters = Parameters()
        parameters["id"] = orderId
        YZBSign.shared.request(APIURL.delayReceivedGoods, method: .post, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                self.noticeSuccess("延长收货成功")
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    GlobalNotificationer.post(notification: .purchaseRefresh)
                    self.loadData()
                }
            }
        }) { (error) in
            
        }
    }
    
    ///修改服务费
    @objc func modifyServiceAction() {
        
        if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            sureOrderAction(isCancel: true)
            return
        }
        
        let moneyStr = purchaseModel?.serviceMoney?.stringValue ?? "0"
        let serviceStr = purchaseModel?.serviceRemarks ?? ""
        let remarkVC = RemarksViewController(title: "修改服务费",money: moneyStr, remark: serviceStr)
        remarkVC.remarksType = .service
        remarkVC.doneBlock = { (remarks, remarks2) in
            if let remarksStr = remarks {
                var parameters: Parameters = ["editServiceMoney": remarksStr, "remarks": remarks2 ?? ""]
                if let valueStr = self.purchaseModel?.id {
                    parameters["orderId"] = valueStr
                }
                
                AppLog("传参: \(parameters)")
                
                let urlStr = APIURL.editServiceMoney
                self.pleaseWait()
                
                YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
                    let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                    if errorCode == "0" {
                        self.pleaseWait()
                        self.loadData()
                    }
                }) { (error) in
                    
                }
            }else {
                self.noticeOnlyText("未填写服务费，放弃修改~")
            }
        }
        self.present(remarkVC, animated: true, completion:nil)
    }
    
    ///添加主材
    @objc func addMaterialAction() {
        
        let vc = AddPurchMatController()
        vc.orderId = orderId
        vc.doneHandler = {
            self.loadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///修改订单价
    @objc func editOrderPriceAction() {
        let money = self.purchaseModel?.payMoney?.doubleValue
        let moneyStr = "\(money ?? 0)"
        let remarkVC = RemarksViewController(title: "修改订单金额",money: moneyStr, remark: moneyStr)
        remarkVC.remarksType = .tel
        remarkVC.doneBlock = { (remarks, remarks2) in
            if let remarksStr = remarks {
                let  parameters: Parameters = ["payMoney": remarksStr, "id": self.orderId]
                AppLog("传参: \(parameters)")
                let urlStr = APIURL.editServiceOrderMoney
                self.pleaseWait()
                
                YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
                    
                    let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                    if errorCode == "0" {
                        self.noticeTop("修改成功", autoClear: true, autoClearTime: 1)
                        self.loadData()
                    }
                    
                }) { (error) in
                    
                }
            } else {
                self.noticeOnlyText("未填写订单金额，放弃修改~")
            }
        }
        self.present(remarkVC, animated: true, completion:nil)
    }
    
    func editSpread(_ purchaseMaterial: PurchaseMaterialModel?) {
        
        let vc = AddSpreadController()
        vc.title = "修改补差价产品"
        vc.orderId =  orderId
        vc.purchaseMaterial = purchaseMaterial
        
        if (purchaseModel?.orderStatus == 1 || purchaseModel?.orderStatus == 2) && (UserData.shared.userType != .jzgs && UserData.shared.userType != .cgy) {
            vc.spreadType = .edit
        }else {
            vc.spreadType = .look
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func contactAction1() {
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
            contactBuyers()
        }else {
            contactSeller()
        }
    }
    
    @objc func contactAction2() {
        
        AppLog("点击了联系卖家")
        
        if UserData.shared.userType == .yys {
            contactSeller()
        }else if UserData.shared.userType == .gys {
            //拨打买家电话
            var name = ""
            var phone = ""
            
            if let valueStr = infoModel?.order?.workerName {
                name = valueStr
            }
            if let valueStr = infoModel?.worker?.mobile {
                phone = valueStr
            }
            
            houseListCallTel(name: name, phone: phone)
        }else {
            //拨打卖家电话
            var name = ""
            var phone = ""
            
            if let valueStr = infoModel?.merchant?.name {
                name = valueStr
            }
            if let valueStr = infoModel?.merchant?.mobile {
                phone = valueStr
            }
            
            houseListCallTel(name: name, phone: phone)
        }
    }
    
    ///联系买家
    func contactBuyers() {
        
        if let storeId = purchaseModel?.storeId {
            let urlStr = APIURL.getAppointUserInfo + storeId
            self.pleaseWait()
            YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                if errorCode == "0" {
                    let dataDic = Utils.getReqDir(data: response as AnyObject)
                    
                    let workerModel = Mapper<WorkerModel>().map(JSON: dataDic as! [String: Any])
                    var userId = ""
                    var userName = ""
                    var storeName = ""
                    var headUrl = ""
                    var nickname = ""
                    var tel1 = ""
                    var tel2 = ""
                    let storeType = "1"
                    
                    if let valueStr = workerModel?.id {
                        userId = valueStr
                    }
                    if let valueStr = workerModel?.userName {
                        userName = valueStr
                    }
                    if let valueStr = workerModel?.storeName {
                        storeName = valueStr
                    }
                    if let valueStr = workerModel?.headUrl {
                        headUrl = valueStr
                    }
                    if let valueStr = workerModel?.realName {
                        nickname = valueStr
                    }
                    if let valueStr = workerModel?.mobile {
                        tel1 = valueStr
                    }
                    if let valueStr = workerModel?.mobile {
                        tel2 = valueStr
                    }
                    
                    let ex: NSDictionary = [
                        "detailTitle": storeName,
                        "headUrl":headUrl,
                        "tel1": tel1,
                        "tel2": tel2,
                        "storeType": storeType,
                        "userId": userId]
                    
                    let user = JMSGUserInfo()
                    user.nickname = nickname
                    user.extras = ex as! [AnyHashable : Any]
                    self.updConsultNumRequest(id: userId)
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
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                            
                        }else {
                            if error!._code == 898002 {
                                
                                YZBChatRequest.shared.register(with: userName, pwd: YZBSign.shared.passwordMd5(password: userName), userInfo: user, errorBlock: { (error) in
                                    if error == nil {
                                        self.contactAction1()
                                    }
                                })
                            }
                        }
                    }
                }
            }) { (error) in
                
            }
        }
    }
    
    ///联系卖家
    func contactSeller() {
        
        var userId = ""
        var userName = ""
        var storeName = ""
        var headUrl = ""
        var nickname = ""
        var tel1 = ""
        var tel2 = ""
        let storeType = "2"
        let merchant = infoModel?.merchant
        if let valueStr = purchaseModel?.merchantId{
            userId = valueStr
        }
        if let valueStr = merchant?.userName {
            userName = valueStr
        }
        if let valueStr = merchant?.name {
            storeName = valueStr
        }
        if let valueStr = merchant?.headUrl {
            headUrl = valueStr
        }
        if let valueStr = merchant?.realName {
            nickname = valueStr
        }
        if let valueStr = merchant?.servicephone {
            tel1 = valueStr
        }
        if let valueStr = merchant?.mobile {
            tel2 = valueStr
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
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                
            }else {
                if error!._code == 898002 {
                    
                    YZBChatRequest.shared.register(with: userName, pwd: YZBSign.shared.passwordMd5(password: userName), userInfo: user, errorBlock: { (error) in
                        if error == nil {
                            self.contactSeller()
                        }
                    })
                }
            }
        }
    }
    
    
    //MARK: - 网络请求2
    
    //检查订单状态 为已确认收货移除待办
    func checkStatus() {
        
        if self.purchaseModel?.orderStatus == 6 && (UserData.shared.userType == .yys || UserData.shared.userType == .gys) {
            self.removeOrder()
        }
    }
    
    var orderDatas: [PurchaseMaterialModel]?
    @objc func loadData() {
        let parameters = Parameters()
        AppLog("订单id: \(parameters)")
        let urlStr = APIURL.getYYSPurchaseOrderData + orderId
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String : Any])
                self.purchaseModel = self.infoModel?.order
                self.orderDatas = self.infoModel?.orderData
                self.tableView.reloadData()
                self.updateBottomView()
                self.checkStatus()
            }
            
        }) { (error) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
        }
    }
    /// 去使用代金券
    @objc func toPay() {
        sureBtnClick(btn: UIButton())
        
        
//        if couponModels.count > 0 {
//            configDJQView()
//        } else {
//
//        }
    }
    
    /// 去付款
    @objc private func sureBtnClick(btn: UIButton) {
        pop?.dismiss()
        // PayTableViewController
        let payMoney = (self.purchaseModel?.payMoney?.doubleValue ?? 0)
//        let vc = OrderPayVC()
//        vc.payMoney = payMoney
//        if checkCouponMoney > (payMoney / 10) {
//            vc.couponMoney = payMoney / 10
//            vc.isTip = true
//        } else {
//            vc.isTip = false
//            vc.couponMoney = checkCouponMoney
//        }
//        vc.allCouponMoney = checkCouponMoney
//        vc.couponIds = checkCouponIds
//        vc.purchaseModel = self.purchaseModel
//        vc.purchaseOrderId = self.orderId
//        self.navigationController?.pushViewController(vc, animated: true)
        let vc = OrderPayNewVC()
        vc.payMoney = payMoney
        vc.purchaseModel = self.purchaseModel ?? PurchaseOrderModel()
        vc.orderId = self.orderId
        vc.orderDatas = orderDatas
        self.navigationController?.pushViewController(vc)
    }
    
    
    //MARK: - tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if purchaseModel == nil {
            return 0
        }
        var count = 3
        if let orderData = orderDatas {
            if orderData.count > 0 {
                count += 1
            }
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            configSection0(cell)
            return cell
//            let cell = PurchaseDetailCell()
//            cell.configCell(model: purchaseModel)
//            return cell
        }
        else if indexPath.section == 1 {
            let cell = UITableViewCell()
            configSection1(cell)
            return cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseDetailCell1.self.description(), for: indexPath) as! PurchaseDetailCell1
//            cell.purchaseCellType = .contactInfo
//            cell.purchaseModel = purchaseModel
//            cell.contactBtn1.addTarget(self, action: #selector(contactAction1), for: .touchUpInside)
//            cell.contactBtn2.addTarget(self, action: #selector(contactAction2), for: .touchUpInside)
//            return cell
        }
        else if indexPath.section == 2 {
            let cell = UITableViewCell()
            configSection2(cell)
            return cell
        }
        else if indexPath.section == 3 {
            let cell = UITableViewCell()
            configSection3(cell)
//            let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseDetailCell2.self.description(), for: indexPath) as! PurchaseDetailCell2
//            cell.detailBlock = nil
//            if let orderData = orderDatas {
//                let purchaseMaterial = orderData[indexPath.row]
//                cell.isCusMaterials = false
//                cell.activityType = purchaseModel?.activityType ?? 1
//                cell.purchaseMaterial = purchaseMaterial
//                cell.detailBlock = { [weak self] in
//                    let rootVC = MaterialsDetailVC()
//                    rootVC.isDismiss = true
//                    let materials = MaterialsModel()
//                    materials.id = purchaseMaterial.materialsId
//                    rootVC.materialsModel = materials
//                    let vc = BaseNavigationController.init(rootViewController: rootVC)
//                    vc.modalPresentationStyle = .fullScreen
//                                                   self?.present(vc, animated: true, completion: nil)
//                }
//            }
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    //MARK: - 订单信息
    func configSection0(_ cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let v = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
        cell.sv(v)
        cell.layout(
            10,
            |-14-v-14-|,
            5
        )
        let titleLine = UIView()
        let titleLabel = UILabel().text("订单信息").textColor(.kColor33).fontBold(14)
        v.sv(titleLine, titleLabel)
        v.layout(
            17.5,
            |-15-titleLine.width(2).height(15)-5-titleLabel,
            >=0
        )
        titleLine.layoutIfNeeded()
        fillTitleLineColor(v: titleLine)
        
        let lab1 = UILabel().textColor(.kColor66).font(12)
        let lab1_1 = UILabel().textColor(.kColor66).font(12)
        let lab2 = UILabel().textColor(.kColor66).font(12)
        let lab2_1 = UILabel().textColor(.kColor66).font(12)
        let lab3 = UILabel().textColor(.kColor66).font(12)
        let lab3_1 = UILabel().textColor(.kColor66).font(12)
        let lab4 = UILabel().textColor(.kColor66).font(12)
        let lab4_1 = UILabel().textColor(.kColor66).font(12)
        let lab5 = UILabel().textColor(.kColor66).font(12)
        let lab5_1 = UILabel().textColor(.kColor66).font(12)
        let lab6 = UILabel().textColor(.kColor66).font(12)
        let lab6_1 = UILabel().textColor(.kColor66).font(12)
        let lab7 = UILabel().textColor(.kColor66).font(12)
        let lab7_1 = UILabel().textColor(.kColor66).font(12)
        let lab8 = UILabel().textColor(.kColor66).font(12)
        let lab8_1 = UILabel().textColor(.kColor66).font(12)
        // 订单号复制按钮
        let copyOrderNoBtn = UIButton().text(" 复制").textColor(.k1DC597).font(12).image(#imageLiteral(resourceName: "purchase_copy"))
        copyOrderNoBtn.tapped { [weak self] (btn) in
            if let valueStr = self?.purchaseModel?.orderNo {
                let paste = UIPasteboard.general
                paste.string = valueStr
                self?.noticeSuccess("订单号已复制")
            }else {
                self?.noticeOnlyText("订单号为空")
            }
        }
        // 物流单号复制按钮
        let copyWLNoBtn = UIButton().text(" 复制").textColor(.k1DC597).font(12).image(#imageLiteral(resourceName: "purchase_copy"))
        copyWLNoBtn.tapped { [weak self] (btn) in
            if let valueStr = self?.purchaseModel?.logisticsNo {
                let paste = UIPasteboard.general
                paste.string = valueStr
                self?.noticeSuccess("物流单号已复制")
            }else {
                self?.noticeOnlyText("物流单号为空")
            }
        }
        var status = ""
        let statusStr = Utils.getFieldValInDirArr(arr: AppData.purchaseOrderStatusTypeList, fieldA: "value", valA: "\(purchaseModel?.orderStatus?.intValue ?? 0)", fieldB: "label")
        if statusStr.count > 0 {
            status = statusStr
        }
        switch purchaseModel?.orderStatus {
        case 2:
            lab1.text("订单号：")
            lab1_1.text(purchaseModel?.orderNo ?? "")
            lab2.text("订单状态：")
            lab2_1.text(status)
            lab3.text("备注：")
            lab3_1.text(purchaseModel?.remarks ?? "无")
            lab4.text("下单时间：")
            lab4_1.text(purchaseModel?.orderTime ?? "")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, copyOrderNoBtn)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                15
            )
        case 3:
            lab1.text("订单号：")
            lab1_1.text(purchaseModel?.orderNo ?? "")
            lab2.text("订单状态：")
            lab2_1.text(status)
            lab3.text("下单时间：")
            lab3_1.text(purchaseModel?.orderTime ?? "")
            lab4.text("发货期限：")
            lab4_1.text(purchaseModel?.recevingTerm ?? "无")
            lab5.text("订单失效时间：")
            lab5_1.text(purchaseModel?.orderUneffectiveTime ?? "")
            lab6.text("备注：")
            lab6_1.text(purchaseModel?.remarks ?? "无")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, lab5, lab5_1, lab6, lab6_1, copyOrderNoBtn)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                5,
                |-15-lab5.width(86).height(16.5)-0-lab5_1,
                5,
                |-15-lab6.width(86).height(16.5)-0-lab6_1,
                15
            )
        case 4:
            lab1.text("订单号：")
            lab1_1.text(purchaseModel?.orderNo ?? "")
            lab2.text("订单状态：")
            lab2_1.text(status)
            lab3.text("下单时间：")
            lab3_1.text(purchaseModel?.orderTime ?? "")
            lab4.text("发货期限：")
            lab4_1.text(purchaseModel?.recevingTerm ?? "无")
            lab5.text("备注：")
            lab5_1.text(purchaseModel?.remarks ?? "无")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, lab5, lab5_1, copyOrderNoBtn)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                5,
                |-15-lab5.width(86).height(16.5)-0-lab5_1,
                15
            )
        case 5, 6:
            lab1.text("订单号：")
            lab1_1.text(purchaseModel?.orderNo ?? "")
            lab2.text("订单状态：")
            lab2_1.text(status)
            lab3.text("下单时间：")
            lab3_1.text(purchaseModel?.orderTime ?? "")
            lab4.text("发货期限：")
            lab4_1.text(purchaseModel?.recevingTerm ?? "无")
            lab5.text("物流公司：")
            lab5_1.text(purchaseModel?.logisticsCompany ?? "无")
            lab6.text("物流单号：")
            lab6_1.text(purchaseModel?.logisticsNo ?? "无")
            lab7.text("物流备注：")
            lab7_1.text(purchaseModel?.logisticsRemarks ?? "无")
            lab8.text("备注：")
            lab8_1.text(purchaseModel?.remarks ?? "无")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, lab5, lab5_1, lab6, lab6_1, lab7, lab7_1, lab8, lab8_1, copyOrderNoBtn, copyWLNoBtn)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                5,
                |-15-lab5.width(86).height(16.5)-0-lab5_1,
                5,
                |-15-lab6.width(86).height(16.5)-0-lab6_1-10-copyWLNoBtn.width(42).height(20),
                5,
                |-101-lab7_1-15-|,
                5,
                |-101-lab8_1-15-|,
                15
            )
            lab7_1.numberOfLines(0).lineSpace(2)
            lab8_1.numberOfLines(0).lineSpace(2)
            |-15-lab7.width(86).height(16.5)
            lab7.Top == lab7_1.Top
            |-15-lab8.width(86).height(16.5)
            lab8.Top == lab8_1.Top
        case 8:
            lab1.text("订单号：")
            lab1_1.text(purchaseModel?.orderNo ?? "")
            lab2.text("订单状态：")
            lab2_1.text(status)
            lab3.text("备注：")
            lab3_1.text(purchaseModel?.remarks ?? "无")
            lab4.text("下单时间：")
            lab4_1.text(purchaseModel?.orderTime ?? "")
            lab5.text("取消原因：")
            lab5_1.text(purchaseModel?.operReason ?? "")
            lab6.text("取消时间：")
            lab6_1.text(purchaseModel?.updateDate ?? "")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, lab5, lab5_1, lab6, lab6_1, copyOrderNoBtn)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                5,
                |-15-lab5.width(86).height(16.5)-0-lab5_1,
                5,
                |-15-lab6.width(86).height(16.5)-0-lab6_1,
                15
            )
        case 11:
            lab1.text("订单号：")
            lab1_1.text(purchaseModel?.orderNo ?? "")
            lab2.text("订单状态：")
            lab2_1.text(status)
            lab3.text("备注：")
            lab3_1.text(purchaseModel?.remarks ?? "无")
            lab4.text("下单时间：")
            lab4_1.text(purchaseModel?.orderTime ?? "")
            lab5.text("订单失效时间：")
            lab5_1.text(purchaseModel?.orderUneffectiveTime ?? "")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, lab5, lab5_1, copyOrderNoBtn)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                5,
                |-15-lab5.width(86).height(16.5)-0-lab5_1,
                15
            )
        default:
            lab1.text("订单号：")
            lab1_1.text(purchaseModel?.orderNo ?? "")
            lab2.text("订单状态：")
            lab2_1.text(status)
            lab3.text("备注：")
            lab3_1.text(purchaseModel?.remarks ?? "无")
            lab4.text("下单时间：")
            lab4_1.text(purchaseModel?.orderTime ?? "")
            lab5.text("订单失效时间：")
            lab5_1.text(purchaseModel?.orderUneffectiveTime ?? "")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, lab5, lab5_1, copyOrderNoBtn)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                5,
                |-15-lab5.width(86).height(16.5)-0-lab5_1,
                15
            )
        }
    }
    
    func fillTitleLineColor(v: UIView) {
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.12, green: 0.78, blue: 0.6, alpha: 1).cgColor, UIColor(red: 0.39, green: 0.86, blue: 0.73, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = v.bounds
        bgGradient.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 1)
        v.layer.addSublayer(bgGradient)
    }
    //MARK: - 收货信息
    func configSection1(_ cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let v = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        let titleLine = UIView()
        let titleLabel = UILabel().text("收货信息").textColor(.kColor33).fontBold(14)
        let chatBtn = UIButton().image(#imageLiteral(resourceName: "purchase_chat")).text("联系卖家").textColor(.k2FD4A7).font(10).borderColor(.k2FD4A7).borderWidth(0.5).cornerRadius(2)
        let phoneBtn = UIButton().image(#imageLiteral(resourceName: "purchase_phone")).text("拨打卖家电话").textColor(.k2FD4A7).font(10).borderColor(.k2FD4A7).borderWidth(0.5).cornerRadius(2)
        v.sv(titleLine, titleLabel, chatBtn, phoneBtn)
        v.layout(
            17.5,
            |-15-titleLine.width(2).height(15)-5-titleLabel,
            >=0,
            |-15-chatBtn.width(69).height(24)-25-phoneBtn.width(89).height(24),
            15
        )
        titleLine.layoutIfNeeded()
        fillTitleLineColor(v: titleLine)
        chatBtn.tapped { [weak self] (tapBtn) in
            self?.contactAction1()
        }
        phoneBtn.tapped { [weak self] (tapBtn) in
            self?.contactAction2()
        }
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
            chatBtn.text("联系买家")
            phoneBtn.text("拨打买家电话")
        }
        
        let lab1 = UILabel().textColor(.kColor66).font(12)
        let lab1_1 = UILabel().textColor(.kColor66).font(12)
        let lab2 = UILabel().textColor(.kColor66).font(12)
        let lab2_1 = UILabel().textColor(.kColor66).font(12)
        let lab3 = UILabel().textColor(.kColor66).font(12)
        let lab3_1 = UILabel().textColor(.kColor66).font(12)
        let lab4 = UILabel().textColor(.kColor66).font(12)
        let lab4_1 = UILabel().textColor(.kColor66).font(12)
        let lab5 = UILabel().textColor(.kColor66).font(12)
        let lab5_1 = UILabel().textColor(.kColor66).font(12)
        let lab6 = UILabel().textColor(.kColor66).font(12)
        let lab6_1 = UILabel().textColor(.kColor66).font(12)
        
        switch purchaseModel?.orderStatus {
        case 8:
            lab1.text("采购人：")
            lab1_1.text(purchaseModel?.workerName ?? "")
            lab2.text("采购单位：")
            lab2_1.text(purchaseModel?.storeName ?? "")
            lab3.text("供应商：")
            lab3_1.text(purchaseModel?.merchantName ?? "")
            lab4.text("收货人：")
            lab4_1.text(purchaseModel?.contact ?? "")
            lab5.text("手机号：")
            lab5_1.text(purchaseModel?.tel ?? "")
            lab6.text("地址：")
            lab6_1.text(purchaseModel?.address ?? "")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, lab5, lab5_1, lab6, lab6_1)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1,
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                5,
                |-15-lab5.width(86).height(16.5)-0-lab5_1,
                5,
                |-101-lab6_1-15-|,
                49
            )
            |-15-lab6
            lab6.Top == lab6_1.Top
            lab6_1.numberOfLines(0).lineSpace(2)
        default:
            lab1.text("采购人：")
            lab1_1.text(purchaseModel?.workerName ?? "")
            lab2.text("采购单位：")
            lab2_1.text(purchaseModel?.storeName ?? "")
            lab3.text("供应商：")
            lab3_1.text(purchaseModel?.merchantName ?? "")
            lab4.text("收货人：")
            lab4_1.text(purchaseModel?.contact ?? "")
            lab5.text("手机号：")
            lab5_1.text(purchaseModel?.tel ?? "")
            lab6.text("地址：")
            lab6_1.text(purchaseModel?.address ?? "")
            v.sv(lab1, lab1_1, lab2, lab2_1, lab3, lab3_1, lab4, lab4_1, lab5, lab5_1, lab6, lab6_1)
            v.layout(
                45,
                |-15-lab1.width(86).height(16.5)-0-lab1_1,
                5,
                |-15-lab2.width(86).height(16.5)-0-lab2_1,
                5,
                |-15-lab3.width(86).height(16.5)-0-lab3_1,
                5,
                |-15-lab4.width(86).height(16.5)-0-lab4_1,
                5,
                |-15-lab5.width(86).height(16.5)-0-lab5_1,
                5,
                |-101-lab6_1-15-|,
                49
            )
            |-15-lab6
            lab6.Top == lab6_1.Top
            lab6_1.numberOfLines(0).lineSpace(2)
            break
        }
    }
    //MARK: - 商品信息
    func configSection2(_ cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let v = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        let titleLine = UIView()
        let titleLabel = UILabel().text("商品信息").textColor(.kColor33).fontBold(14)
        v.sv(titleLine, titleLabel)
        v.layout(
            17.5,
            |-15-titleLine.width(2).height(15)-5-titleLabel,
            >=0
        )
        titleLine.layoutIfNeeded()
        fillTitleLineColor(v: titleLine)
        
        orderDatas?.enumerated().forEach { (item) in
            let index = item.offset
            let model = item.element
            let btnH: CGFloat = 60
            let btnW: CGFloat = view.width-28
            let offsetX: CGFloat = 0
            let offsetY: CGFloat = 45 + (btnH+10) * CGFloat(index)
            let btn = UIButton()
            v.sv(btn)
            v.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=24
            )
            let icon = UIImageView().image(#imageLiteral(resourceName: "service_mall_sj_2")).cornerRadius(2).masksToBounds()
            icon.contentMode = .scaleAspectFit
            if !icon.addImage(model.image) {
                icon.image = UIImage.init(named: "loading")
            }
            let titleLabel = UILabel().text(model.materialsName ?? "").textColor(.kColor33).font(13)
            //titleLabel.numberOfLines(2).lineSpace(2)
            let priceLabel = UILabel().text("￥1250.00").textColor(UIColor.hexColor("#FD9C3B")).font(12)
            if purchaseModel?.activityType == 2 || purchaseModel?.activityType == 3 || purchaseModel?.payType == 2 {
                priceLabel.text("￥\(model.moneyMaterials?.doubleValue ?? 0)")
            } else {
                priceLabel.text("￥\(model.price1?.doubleValue ?? 0)")
            }
            let brandLabel = UILabel().text("品牌：\(model.brandName ?? "")").textColor(.kColor33).font(10)
            let ruleLabel = UILabel().text("\(model.skuAttr1 ?? "无")").textColor(.kColor33).font(10)
            if model.skuAttr1 == "" {
                ruleLabel.text("无")
            }
            let materialsCount = Int(model.materialsCount ?? "0") ?? 0
            let numLabel = UILabel().text("×\(materialsCount)").textColor(.kColor66).font(12)
            priceLabel.textAligment(.right)
            
            let arrowIV = UIImageView().image(#imageLiteral(resourceName: "arrow_right"))
//            let remarkBtn = UIButton().text("备注").textColor(.kColor66).font(12).cornerRadius(13).borderWidth(0.5).borderColor(.kColor99)
//            let fileBtn = UIButton().text("附件").textColor(.kColor66).font(12).cornerRadius(13).borderWidth(0.5).borderColor(.kColor99)
            
            btn.sv(icon, titleLabel, priceLabel, brandLabel, ruleLabel, numLabel, arrowIV)
            btn.layout(
                0,
                |-15-icon.size(60),
                0
            )
            btn.layout(
                0,
                |-85-titleLabel-86-|,
                >=0,
                |-85-brandLabel.height(14)-(>=0)-numLabel-25-|,
                5,
                |-85-ruleLabel.height(14),
                0
            )
            arrowIV.centerVertically()-5-|
//            btn.layout(
//                >=0,
//                remarkBtn.width(60).height(26)-10-fileBtn.width(60).height(26)-12.5-|,
//                10
//            )
            priceLabel-25-|
            priceLabel.Top == titleLabel.Top
            
            btn.tag = index
            btn.tapped { [weak self] (tapBtn) in
                let vc = PurchaseEnclosureController()
                var purchaseMaterial = self?.orderDatas?[index]
                vc.activityType = self?.purchaseModel?.activityType ?? 1
                vc.purchaseMaterial = purchaseMaterial
                vc.saveModelBlock = { [weak self] (model) in
                    purchaseMaterial = model ?? PurchaseMaterialModel()
                    self?.loadData()
                }
                if let valueStr = self?.purchaseModel?.orderStatus {
                    vc.orderStatus = valueStr
                }
                self?.navigationController?.pushViewController(vc, animated: true)
                
            }
//            remarkBtn.tag = index
//            fileBtn.tag = index
            icon.isUserInteractionEnabled = true
            icon.tag = index
            icon.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(materialIconTap(tap:))))
            
            
//            remarkBtn.tapped { [weak self] (tapBtn) in
//                let orderData = self?.orderDatas?[tapBtn.tag]
//                let alert = UIAlertController.init(title: "备注", message: orderData?.remarks, preferredStyle: .alert)
//                alert.addAction(UIAlertAction.init(title: "知道了", style: .default, handler: { (alert) in
//
//                }))
//                self?.present(alert, animated: true, completion: nil)
//            }
//
//            fileBtn.tapped { [weak self] (tapBtn) in
//                var urls: [URL] = [];
//                let fileUrls = self?.orderDatas?[tapBtn.tag].fileUrls?.components(separatedBy: ",")
//
//                fileUrls?.forEach({ (fileUrl) in
//                    let urlStr = APIURL.ossPicUrl + fileUrl
//                    let url = URL.init(string: urlStr)
//                    if let url1 = url {
//                        urls.append(url1)
//                    }
//                })
//                let phoneVC = IMUIImageBrowserController()
//                phoneVC.imageArr = urls
//                phoneVC.imgCurrentIndex = 0
//                phoneVC.title = "查看附件"
//                phoneVC.modalPresentationStyle = .overFullScreen
//                self?.navigationController?.pushViewController(phoneVC)
//            }
        }
    }
    
    @objc func materialIconTap(tap: UITapGestureRecognizer) {
        let tag = tap.view?.tag ?? 0
        let model = orderDatas?[tag]
        let rootVC = MaterialsDetailVC()
        rootVC.isDismiss = true
        let materials = MaterialsModel()
        materials.id = model?.materialsId
        rootVC.materialsModel = materials
        let vc = BaseNavigationController.init(rootViewController: rootVC)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: - 支付信息
    func configSection3(_ cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let v = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        let titleLine = UIView()
        let titleLabel = UILabel().text("支付信息").textColor(.kColor33).fontBold(14)
        v.sv(titleLine, titleLabel)
        v.layout(
            17.5,
            |-15-titleLine.width(2).height(15)-5-titleLabel,
            >=0
        )
        titleLine.layoutIfNeeded()
        fillTitleLineColor(v: titleLine)
        
        let orderPriceDes = UILabel().text("订单金额:").textColor(.kColor66).font(12)
        let orderPrice = UILabel().text("¥\(purchaseModel?.payMoney?.doubleValue ?? 0)").textColor(UIColor.hexColor("#DF2F2F")).font(12)
        let goodsPriceDes = UILabel().text("商品总价:").textColor(.kColor66).font(12)
        let goodsPrice = UILabel().text("¥\(purchaseModel?.supplyMoney?.doubleValue ?? 0)").textColor(.kColor66).font(12)
        let discountPriceDes = UILabel().text("金额抵扣:").textColor(.kColor66).font(12)
        let discountPrice = UILabel().text("¥\(purchaseModel?.discountMoney?.doubleValue ?? 0)").textColor(.kColor66).font(12)
        let servicePriceDes = UILabel().text("服务费:").textColor(.kColor66).font(12)
        let servicePrice = UILabel().text("¥\(purchaseModel?.serviceMoney?.doubleValue ?? 0)").textColor(.kColor66).font(12)
        
        let payMoney1 = purchaseModel?.payMoney?.doubleValue ?? 0
        let discountMoney = purchaseModel?.discountMoney?.doubleValue ?? 0
        let realPrice = payMoney1 - discountMoney
        
        let payMoneyDes = UILabel().text("实付金额:").textColor(.kColor66).font(12)
        let payMoney = UILabel().text("¥\(realPrice)").textColor(.kColor66).font(12)
        let serviceRemarkDes = UILabel().text("服务费备注:").textColor(.kColor66).font(12)
        let serviceRemark = UILabel().text("\(purchaseModel?.serviceRemarks ?? "无")").textColor(.kColor66).font(12)
        let payStatusDes = UILabel().text("支付状态:").textColor(.kColor66).font(12)
        let payStatus = UILabel().text("已支付").textColor(.kColor66).font(12)
        let payTimeDes = UILabel().text("支付时间:").textColor(.kColor66).font(12)
        let payTime = UILabel().text(purchaseModel?.orderPayTime ?? "").textColor(.kColor66).font(12)
        if let valueStr = purchaseModel?.payStatus {
            let statusStr = Utils.getFieldValInDirArr(arr: AppData.purchaseOrderPayStatusList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
            if statusStr.count > 0 {
                payStatus.text = statusStr
            }
        }
         // 2: 等待商家确认 3: 商家已确认 4: 完成付款 5: 商家出货 6: 已确认收货 8: 订单取消 9: 已付款待审核  10: 付款审核拒绝 11: 已失效
        let orderStatus = purchaseModel?.orderStatus?.intValue ?? 0
        if orderStatus == 4 ||  orderStatus == 5 ||  orderStatus == 6 ||  orderStatus == 9  {
            v.sv(orderPriceDes, orderPrice, goodsPriceDes, goodsPrice, discountPriceDes, discountPrice, servicePriceDes, servicePrice, payMoneyDes, payMoney, serviceRemarkDes, serviceRemark, payStatusDes, payStatus, payTimeDes, payTime)
            v.layout(
                45,
                |-15-orderPriceDes.width(73).height(16.5)-2-orderPrice,
                5,
                |-15-goodsPriceDes.width(73).height(16.5)-2-goodsPrice,
                5,
                |-15-discountPriceDes.width(73).height(16.5)-2-discountPrice,
                5,
                |-15-payMoneyDes.width(73).height(16.5)-2-payMoney,
                5,
                |-15-servicePriceDes.width(73).height(16.5)-2-servicePrice,
                5,
                |-15-serviceRemarkDes.width(73).height(16.5)-2-serviceRemark,
                5,
                |-15-payStatusDes.width(73).height(16.5)-2-payStatus,
                5,
                |-15-payTimeDes.width(73).height(16.5)-2-payTime,
                15.5
            )
        } else {
            v.sv(orderPriceDes, orderPrice, goodsPriceDes, goodsPrice, servicePriceDes, servicePrice, serviceRemarkDes, serviceRemark, payStatusDes, payStatus)
            v.layout(
                45,
                |-15-orderPriceDes.width(73).height(16.5)-2-orderPrice,
                5,
                |-15-goodsPriceDes.width(73).height(16.5)-2-goodsPrice,
                5,
                |-15-servicePriceDes.width(73).height(16.5)-2-servicePrice,
                5,
                |-15-serviceRemarkDes.width(73).height(16.5)-2-serviceRemark,
                5,
                |-15-payStatusDes.width(73).height(16.5)-2-payStatus,
                15.5
            )
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 || indexPath.section == 1 || indexPath.section == 2 {
            return
        }
        
        if indexPath.section == 3 {
            if let materialsList = orderDatas {
                if materialsList.count > 0 {
                    let vc = PurchaseEnclosureController()
                    var purchaseMaterial = materialsList[indexPath.row]
                    vc.activityType = purchaseModel?.activityType ?? 1
                    vc.purchaseMaterial = purchaseMaterial
                    vc.saveModelBlock = { [weak self] (model) in
                        purchaseMaterial = model ?? PurchaseMaterialModel()
                        self?.loadData()
                    }
                    if let valueStr = purchaseModel?.orderStatus {
                        vc.orderStatus = valueStr
                    }
                    navigationController?.pushViewController(vc, animated: true)
                    return
                }
            }
        }
    }
    
    //左滑删除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var materialCount = 0
        
        if let materialsList = purchaseModel?.materialsList {
            materialCount += materialsList.count
        }
        if let cusMaterialsList = purchaseModel?.cusMaterialsList {
            materialCount += cusMaterialsList.count
        }
        
        if materialCount <= 1 {
            self.noticeOnlyText("至少保留一个商品~")
            return
        }
        
        if indexPath.section == 3 {
            if let materialsList = infoModel?.orderData {
                if materialsList.count > 0 {
                    let purchaseMaterial = materialsList[indexPath.row]
                    
                    var parameters: Parameters = [:]
                    parameters["orderDataId"] = purchaseMaterial.id
                    let urlStr = APIURL.deletePurchaseMar
                    self.pleaseWait()
                    
                    YZBSign.shared.request(urlStr, method: .delete, parameters: parameters, success: { (response) in
                        let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                        if errorCode == "0" {
                            self.pleaseWait()
                            self.loadData()
                        }
                    }) { (error) in
                        
                    }
                    return
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        if indexPath.section == 3 || indexPath.section == 4 {
            
        }
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 || indexPath.section == 4 {
            return true
        }
        return false
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: PurchaseDetailHeader.self.description()) as! PurchaseDetailHeader
//
//        if section == 0 {
//            header.headerTitleLabel.text = "订单信息"
//        }else if section == 1 {
//            header.headerTitleLabel.text = "收货信息"
//        }else if section == 2 {
//            header.headerTitleLabel.text = "支付信息"
//        }else if section == 3 {
//            if let orderData = orderDatas {
//                if orderData.count > 0 {
//                    header.headerTitleLabel.text = "商品信息"
//                    return header
//                }
//            }
//            header.headerTitleLabel.text = "补差价产品"
//        }else {
//            header.headerTitleLabel.text = "补差价产品"
//        }
        return UIView()
    }
}




class DelayTimeModel : NSObject, Mappable{
    
    var commissionRate : Float?
    var id : Int?
    var kjlCommissionRate : Int?
    var kjlCommonCost : Float?
    var kjlVipCost : Float?
    var orderCompleteType : String?
    var orderCompleteValue : String?
    var orderExtendedType : String?  //订单延长收货类型 (1：天 2:小时  3:分钟)
    var orderExtendedValue : String? //订单延长收货值
    var orderOvertimeType : String?
    var orderOvertimeValue : String?
    var premiumRate : Float?
    
    required init?(map: Map){}
    private override init(){
        super.init()
    }
    
    func mapping(map: Map)
    {
        commissionRate <- map["commissionRate"]
        id <- map["id"]
        kjlCommissionRate <- map["kjlCommissionRate"]
        kjlCommonCost <- map["kjlCommonCost"]
        kjlVipCost <- map["kjlVipCost"]
        orderCompleteType <- map["orderCompleteType"]
        orderCompleteValue <- map["orderCompleteValue"]
        orderExtendedType <- map["orderExtendedType"]
        orderExtendedValue <- map["orderExtendedValue"]
        orderOvertimeType <- map["orderOvertimeType"]
        orderOvertimeValue <- map["orderOvertimeValue"]
        premiumRate <- map["premiumRate"]
        
    }
}
