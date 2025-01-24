//
//  PayViewModel.swift
//  YZB_Company
//
//  Created by Mac on 16.10.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

let kAppURLScheme = "jucaidao1125" // 这个是你定义的 URL Scheme，支付宝、微信支付和测试模式需要。

@objc protocol PayViewModelDelegate {
    
    func updateUI()
    
    func alert(_ info: String)
    
    func pushCodeAlert(_ params: [String: Any])
    
    func clearNotice()
}

private protocol PayViewModelInterface {
    
    var delegate: PayViewModelDelegate? { set get }
    var exchangeButton: UIButton? { set get }
    
    func payMethod(_ sender: UIButton)
    func pay(_ sender: UIButton?,isContinue: Bool)
    
    var lessMoney: String? { get }
}

class PayViewModel: NSObject, PayViewModelInterface {
    weak var vc: UIViewController!
    private var canSelected: Bool {
        get {
            if self.exchangeLessMoney == "未开户" {
                return false
            }
            return (exchangeLessMoney as NSString).doubleValue >= payMoney
        }
    }

    var orderId: String = ""
    var payMoney: Double = 0
    var registerID: String?
    var params: [String: Any] = [:]
    private var payMethod = "upacp" // alipay wx balance
    
    private var exchangeLessMoney: String = "未开户"
    
    var lessMoney: String? {
        get {
            
            if exchangeLessMoney == "未开户" {
                return exchangeLessMoney
            }
            
            return "剩余：￥\(((exchangeLessMoney as NSString?)?.doubleValue ?? 0).notRoundingString(afterPoint: 2))元" }
    }
    
    override init() {
        super.init()
    }
    
    // 加载余额
    func loadLessMoeny() {
        
        if isRegister { return }
        
        let urlStr = APIURL.lessMoney
              
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { [unowned self](response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "008" {
                // 未开户
                self.exchangeLessMoney = "未开户"
            }
            else if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let accountModel = Mapper<OpenAccountInfoModel>().map(JSON: dataDic as! [String : Any])
                
                let balance = accountModel?.availableBalance?.doubleValue ?? 0
                self.exchangeLessMoney = "\(balance)"
            }
            self.delegate?.updateUI()
            AppLog(response)
            
        }) { (error) in
            
        }
    }
    
    var exchangeButton: UIButton?
    var isRegister = false
    
    weak var delegate: PayViewModelDelegate?
  
    
    // 获取会员w费
    func fetchVipMoney(_ stationID: String) {
        
        if isRegister == false { return }
        
        YZBSign.shared.request(APIURL.getVipMoney, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let money = Utils.getReadString(dir: response as NSDictionary, field: "data")
                self.payMoney = (Double.init(string: money) ?? 0)
                self.delegate?.updateUI()
            }
        }) { (r) in
            
        }
        
    }
    
    func payMethod(_ sender: UIButton) {
        
        if sender.tag == 40 && !canSelected {
            return
        }
        
        if exchangeButton != sender {
            exchangeButton?.isSelected = false
            exchangeButton = sender
            exchangeButton?.isSelected = true
        }
        
        switch exchangeButton!.tag {
        case 10: payMethod = "upacp"
        case 20: payMethod = "wx"
        case 30: payMethod = "alipay"
        case 40: payMethod = "balance"
        default:
            payMethod = "upacp" // alipayNoUTDID wx
        }
    }
   
    func pay(_ sender: UIButton?, isContinue: Bool = false) {
        
        AppLog("支付")

        // wx alipay 
        var params: Parameters = ["payType": payMethod]
        var url = APIURL.orderPay
        
        if isContinue {
            params = self.params
        }
        else {
            if isRegister {
                params["userId"] = registerID ?? ""
                url = APIURL.vipPay
            }
            else {
                params["orderId"] = orderId
            }
            
            if payMethod == "balance" {
                delegate?.pushCodeAlert(params)
                return
            }
        }
        YZBSign.shared.request(url, method: .post, parameters: params, success: { (response) in
            AppLog(response)
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            let errorMsg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
            self.delegate?.clearNotice()
            if errorCode == "0" {
                
                if self.payMethod == "balance" {
                    AppLog("展示结果")
                    self.delegate?.alert("余额支付成功")
                    self.updateOrder()
                    return
                }
                let dataString = Utils.getReadString(dir: response as NSDictionary, field: "data")
                let responseDic = String.getDictionaryFromJSONString(jsonString: dataString)
                if let body = responseDic["body"] as? [String: Any] {
                    if let data = body["data"] as? [String: Any] {
                        if let charges = data["charges"] as? [String: Any] {
                            var jdataArray: Any!
                            if let jdata = charges["data"] as? [[String: Any]] {
                               jdataArray = jdata[0]
                            }
                            else if let jdata = charges["data"] as? [String: Any] {
                                jdataArray = jdata
                            }
                            if jdataArray == nil {
                                self.delegate?.alert("获取支付状态异常，请重试")
                            }
                            let date = try! JSONSerialization.data(withJSONObject: jdataArray as Any,options: [])
                            let charge = NSString(data: date, encoding: String.Encoding.utf8.rawValue)
                            AppLog(charge!)
                            
                            if self.payMethod != "balance" {
                                self.switchThird(charge)
                            }
                        }
                    }
                }
            }
            else if errorCode == "001" {
                self.delegate?.alert("订单号错误")
            } else {
                UIApplication.shared.windows.first?.noticeOnlyText(errorMsg)
            }
        }) { (erro) in
            AppLog(erro)
        }
    }
    
    // 更新支付状态
    private func updateOrder() {
        var parameters = Parameters()
        parameters["id"] = orderId
        parameters["payStatus"] = 3
        YZBSign.shared.request(APIURL.updatePurchaseStatus, method: .put, parameters: ["id": orderId], success: { (response) in
           // self.vc.navigationController?.popViewController(animated: true)
            
        }) { (err) in
            
        }
    }
    
    // 第三方支付
    private func switchThird(_ charge: NSString!) {
        Pingpp.createPayment(charge as NSObject, viewController: vc, appURLScheme: kAppURLScheme) { (result, error) -> Void in
            AppLog("=======: \(result!)")
            if error != nil {
                print(error!.getMsg()!)
                if error?.getMsg() == "用户取消操作" {
                    self.delegate?.alert("支付取消")
                } else {
                    self.delegate?.alert("支付失败")
                }
                return
            }
            self.delegate?.alert("支付成功")
            self.updateOrder()
        }
    }
    
}

