//
//  PayMethodVC.swift
//  YZB_Company
//
//  Created by yzb_ios on 26.03.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import SwiftyJSON

class PayMethodVC: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var moneyLabel: UILabel!
    var serviceLabel: UILabel!
    var payBtn: UIButton!
    var moneyValue: Double = 0
    var selectedRow: Int = 0
    var purchaseModel: PurchaseOrderModel?
    var workerModel: WorkerModel?
    var isMembership = false                        //是否是会员费
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        AppLog(">>>>>>>>>>>>>>>>>>>>> 支付页面释放 <<<<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if isMembership {
            self.title = "支付会员费"
        }else {
            self.title = "请选择支付方式"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(wxPayCallback), name: Notification.Name.init("WXPayNotification"), object: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        prepareSubView()
        
        if isMembership {
            loadData()
            payBtn.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func backAction() {
        
        if isMembership {
            if let viewControllers = self.navigationController?.viewControllers {
                let vc = viewControllers[1]
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func prepareSubView() {
        
        //支付
        payBtn = UIButton()
        payBtn.setBackgroundImage(PublicColor.gradualColorImage, for: .normal)
        payBtn.setBackgroundImage(PublicColor.gradualHightColorImage, for: .highlighted)
        payBtn.setBackgroundImage(PublicColor.gradualHightColorImage, for: .disabled)
        payBtn.setTitle("确认支付", for: .normal)
        payBtn.setTitleColor(UIColor.white, for: .normal)
        payBtn.layer.cornerRadius = 4
        payBtn.layer.masksToBounds = true
        payBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        payBtn.addTarget(self, action: #selector(payBtnClickAction), for: .touchUpInside)
        view.addSubview(payBtn)
        
        payBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(-20)
            make.left.equalTo(20)
            make.height.equalTo(44)
        }
        
        //头视图
        let headView = UIView(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 160))
        view.addSubview(headView)
        
        //支付金额
        moneyLabel = UILabel()
        moneyLabel.text = moneyValue.notRoundingString(afterPoint: 2)
        moneyLabel.font = UIFont.boldSystemFont(ofSize: 34)
        headView.addSubview(moneyLabel)
        
        moneyLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        //金额单位
        let unityLabel = UILabel()
        unityLabel.text = "￥"
        unityLabel.font = UIFont.boldSystemFont(ofSize: 24)
        headView.addSubview(unityLabel)
        
        unityLabel.snp.makeConstraints { (make) in
            make.right.equalTo(moneyLabel.snp.left)
            make.bottom.equalTo(moneyLabel).offset(-3)
        }
        
        tableView = UITableView()
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = headView
        tableView.backgroundColor = .clear
        tableView.register(PayMethodCell.self, forCellReuseIdentifier: PayMethodCell.self.description())
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(payBtn.snp.top)
        }
        
        if isMembership {
            tableView.tableFooterView = UIView()
            return
        }
        
        let footerView = UIView(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 100))
        tableView.tableFooterView = footerView
        
        let footerLabel = UILabel()
        footerLabel.numberOfLines = 0
        footerLabel.text = "1.我们采用第三方托管平台进行支付，故支付会产生一定的手续费\n2.目前的服务费由平台承担，自2019年7月1号起将按0.35%收取支付服务费"
        footerLabel.attributedText = footerLabel.text?.changeLineSpaceForLabel(lineSpacing: 5)
        footerLabel.font = UIFont.systemFont(ofSize: 13)
        footerLabel.textColor = PublicColor.minorTextColor
        footerView.addSubview(footerLabel)
        
        footerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(10)
            make.right.equalTo(-20)
        }
        
        //金额单位
        let serviceValue = (moneyValue*0.0035).notRoundingString(afterPoint: 2)
        serviceLabel = UILabel()
        serviceLabel.text = "（服务费: ￥\(serviceValue)，平台优惠: ￥-\(serviceValue)）"
        serviceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        headView.addSubview(serviceLabel)
        
        serviceLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(moneyLabel.snp.bottom).offset(5)
        }
    }
    
    //支付
    @objc func payBtnClickAction() {
        
//        if isMembership {
//            guard let storeId = workerModel?.store?.id else { return }
//
////            let quickPayUrl = "http://192.168.1.19/NewYzb/yzbPurchaseOrder/port/payAppVipSave"
//            let quickPayUrl = APIURL.payAppVipSave
//            let merchantParams = "{\"goodsDesc\": \"湖南优装宝网络科技有限公司\", \"storeId\": \"\(storeId)\", \"buyerId\": \"2019040263718826\"}"
//
//            if selectedRow == 0 {
//                //微信支付
//                ZFJSDKPlugin.SharedPlugin().weChatPayWith(merchantUrl: quickPayUrl, merchantParams: merchantParams)
//            }
//            else if selectedRow == 1 {
//                //支付宝支付
//                ZFJSDKPlugin.SharedPlugin().aliPayWith(merchantUrl: quickPayUrl, merchantParams: merchantParams, naviController: self.navigationController!) { (payResult) in
//                    AppLog("支付宝payResult == \(payResult)")
//
//                    if let viewControllers = self.navigationController?.viewControllers {
//                        if let vc = viewControllers[1] as? LoginViewController {
//                            vc.isPaySuccess = true
//                            self.navigationController?.popToViewController(vc, animated: true)
//                        }
//                    }
//                }
//            }
//
//        }else {
//            guard let orderId = purchaseModel?.id else { return }
//            guard let storeId = UserData.shared.workerModel?.store?.id else { return }
//
////            let quickPayUrl = "http://192.168.1.19/NewYzb/yzbPurchaseOrder/port/appPurchaseOrderPay"
//            let quickPayUrl = APIURL.appPurchaseOrderPay
//            let merchantParams = "{\"orderId\": \"\(orderId)\", \"goodsDesc\": \"湖南优装宝网络科技有限公司\", \"storeId\": \"\(storeId)\", \"buyerId\": \"2019040263718826\"}"
//
//            if selectedRow == 0 {
//                //快捷支付
//                queryAccount()
//            }
//            else if selectedRow == 1 {
//                //微信支付
//                ZFJSDKPlugin.SharedPlugin().weChatPayWith(merchantUrl: quickPayUrl, merchantParams: merchantParams)
//            }
//            else if selectedRow == 2 {
//                //支付宝支付
//                ZFJSDKPlugin.SharedPlugin().aliPayWith(merchantUrl: quickPayUrl, merchantParams: merchantParams, naviController: self.navigationController!) { (payResult) in
//                    AppLog("支付宝payResult == \(payResult)")
//
//                    if let viewControllers = self.navigationController?.viewControllers {
//                        if let vc = viewControllers[viewControllers.count-2] as? PurchaseDetailController {
//                            vc.isPayQuery = true
//                        }
//                    }
//                    self.navigationController?.popViewController(animated: true)
//                }
//            }
//        }
    }
    
    //微信支付回调
    @objc func wxPayCallback(nofi : Notification) {
        
        if let errCode = nofi.userInfo!["errCode"] as? Int32 {
            
            var popuTitle = ""
            var popuMsg = ""
            
            if errCode == 0 {
                popuTitle = "支付成功"
                
                if let viewControllers = self.navigationController?.viewControllers {
                    if let vc = viewControllers[viewControllers.count-2] as? PurchaseDetailController {
                        vc.isPayQuery = true
                    }
                }
                
            }else {
                popuTitle = "支付失败"
                popuMsg = nofi.userInfo!["errStr"] as! String
            }
            
            let popup = PopupDialog(title: popuTitle, message: popuMsg, tapGestureDismissal: false, panGestureDismissal: false, completion: nil)
            
            let sureBtn = AlertButton(title: "确定") {
                
                if errCode == 0 {
                    
                    if self.isMembership {
                        
                        if let viewControllers = self.navigationController?.viewControllers {
                            if let vc = viewControllers[1] as? LoginViewController {
                                vc.isPaySuccess = true
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - 网络请求
    func loadData() {
        
        guard let storeId = workerModel?.store?.id else { return }
        
        let parameters: Parameters = ["storeId": storeId]
        let urlStr = APIURL.getVipMoney
//        let urlStr = "http://192.168.1.19/NewYzb/yzbPurchaseOrder/port/getVipMoney"
        self.pleaseWait()
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let moneyStr = Utils.getReadString(dir: dataDic, field: "money")
                self.moneyLabel.text = moneyStr
                self.payBtn.isEnabled = true
            }
            
        }) { (error) in
            
        }
    }
    
    //MARK: - tableviewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isMembership {
            return 2
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PayMethodCell.self.description(), for: indexPath) as! PayMethodCell
        cell.selectIcon.image = UIImage.init(named: "pay_unselected")
        
        if indexPath.row == selectedRow {
            cell.selectIcon.image = UIImage.init(named: "pay_selected")
        }
        
        if isMembership {
            
            if indexPath.row == 0 {
                cell.payIcon.image = UIImage.init(named: "wx_pay_icon")
                cell.payTitle.text = "微信支付"
            }
            else if indexPath.row == 1 {
                cell.payIcon.image = UIImage.init(named: "ali_pay_icon")
                cell.payTitle.text = "支付宝支付"
            }
        }else {
            
            if indexPath.row == 0 {
                cell.payIcon.image = UIImage.init(named: "quick_pay_icon")
                cell.payTitle.text = "快捷支付"
            }
            else if indexPath.row == 1 {
                cell.payIcon.image = UIImage.init(named: "wx_pay_icon")
                cell.payTitle.text = "微信支付"
            }
            else if indexPath.row == 2 {
                cell.payIcon.image = UIImage.init(named: "ali_pay_icon")
                cell.payTitle.text = "支付宝支付"
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRow = indexPath.row
        tableView.reloadData()
    }
}
