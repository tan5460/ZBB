//
//  PayOrderController.swift
//  YZB_Company
//
//  Created by yzb_ios on 25.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PopupDialog

class PayOrderController: BaseViewController, UITextFieldDelegate {

    var bankCardModel: BankCardModel?
    var userCustId = ""
    var purchaseOrderId = ""
    var payMoney: Double = 0
    
    var orderId = ""
    var orderDate = ""
    
    var verificationTimer: Timer!       //验证码定时器
    var timerCount: NSInteger!          //倒计时
    
    var sureBtn: UIButton!              //确认提现
    var codeField: UITextField!         //验证码输入框
    var vCodeBtn: UIButton!             //获取验证码
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "付款"
        
        prepareSubView()
    }
    
    func prepareSubView() {
        
        //支付金额
        let payMoneyView = UIView()
        payMoneyView.backgroundColor = .white
        view.addSubview(payMoneyView)
        
        payMoneyView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        //金额标题
        let moneyTitle = UILabel()
        moneyTitle.font = UIFont.systemFont(ofSize: 15)
        moneyTitle.text = "订单金额:"
        moneyTitle.textColor = PublicColor.commonTextColor
        payMoneyView.addSubview(moneyTitle)
        
        moneyTitle.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        //订单金额
        let payMoneyLabel = UILabel()
        payMoneyLabel.font = moneyTitle.font
        payMoneyLabel.text = String.init(format: "%.2f元", payMoney)
        payMoneyLabel.textColor = PublicColor.emphasizeColor
        payMoneyView.addSubview(payMoneyLabel)
        
        payMoneyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(moneyTitle.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        //银行卡背景
        let selCardView = UIView()
        selCardView.backgroundColor = .white
        view.addSubview(selCardView)
        
        selCardView.snp.makeConstraints { (make) in
            make.top.equalTo(payMoneyView.snp.bottom).offset(1)
            make.left.right.equalToSuperview()
            make.height.equalTo(payMoneyView)
        }
        
        //银行卡标题
        let bankTitle = UILabel()
        bankTitle.font = moneyTitle.font
        bankTitle.text = "银行卡:"
        bankTitle.textColor = moneyTitle.textColor
        selCardView.addSubview(bankTitle)
        
        bankTitle.snp.makeConstraints { (make) in
            make.left.equalTo(moneyTitle)
            make.centerY.equalToSuperview()
        }
        
        //银行卡
        let bankLabel = UILabel()
        bankLabel.font = moneyTitle.font
        bankLabel.text = ""
        bankLabel.textColor = PublicColor.minorTextColor
        selCardView.addSubview(bankLabel)
        
        bankLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bankTitle.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        //手机号背景
        let phoneView = UIView()
        phoneView.backgroundColor = .white
        view.addSubview(phoneView)
        
        phoneView.snp.makeConstraints { (make) in
            make.top.equalTo(selCardView.snp.bottom).offset(1)
            make.left.right.equalToSuperview()
            make.height.equalTo(payMoneyView)
        }
        
        //手机号标题
        let phoneTitle = UILabel()
        phoneTitle.font = moneyTitle.font
        phoneTitle.text = "手机号:"
        phoneTitle.textColor = moneyTitle.textColor
        phoneView.addSubview(phoneTitle)
        
        phoneTitle.snp.makeConstraints { (make) in
            make.left.equalTo(moneyTitle)
            make.centerY.equalToSuperview()
        }
        
        //手机号
        let phoneLabel = UILabel()
        phoneLabel.font = moneyTitle.font
        phoneLabel.text = ""
        phoneLabel.textColor = bankLabel.textColor
        phoneView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(phoneTitle.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        //验证码背景
        let codeView = UIView()
        codeView.backgroundColor = .white
        view.addSubview(codeView)
        
        codeView.snp.makeConstraints { (make) in
            make.top.equalTo(phoneView.snp.bottom).offset(1)
            make.left.right.equalToSuperview()
            make.height.equalTo(payMoneyView)
        }
        
        //手机号标题
        let codeTitle = UILabel()
        codeTitle.font = moneyTitle.font
        codeTitle.text = "验证码:"
        codeTitle.textColor = moneyTitle.textColor
        codeView.addSubview(codeTitle)
        
        codeTitle.snp.makeConstraints { (make) in
            make.left.equalTo(moneyTitle)
            make.centerY.equalToSuperview()
        }
        
        //验证码
        codeField = UITextField()
        codeField.returnKeyType = .done
        codeField.delegate = self
        codeField.tag = 1001
        codeField.clearButtonMode = .whileEditing
        codeField.textColor = .black
        codeField.placeholder = "请输入验证码"
        codeField.font = moneyTitle.font
        codeView.addSubview(codeField)
        
        codeField.snp.makeConstraints { (make) in
            make.left.equalTo(codeTitle.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        
        //获取验证码
        vCodeBtn = UIButton.init(type: .custom)
        vCodeBtn.setTitle("获取验证码", for: .normal)
        vCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        vCodeBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x4B66C0), for: .normal)
        vCodeBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        vCodeBtn.setTitleColor(PublicColor.placeholderTextColor, for: .disabled)
        vCodeBtn.addTarget(self, action: #selector(getVCodeAction), for: .touchUpInside)
        codeView.addSubview(vCodeBtn)
        
        vCodeBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(100)
            make.right.equalTo(-15)
            make.height.equalTo(30)
        }
        
        //确认提现
        let sureBackImg = UIColor.colorFromRGB(rgbValue: 0xDE5D4B).image()
        let sureBackImgHig = UIColor.colorFromRGB(rgbValue: 0xC24E3E).image()
        sureBtn = UIButton(type: .custom)
        sureBtn.layer.cornerRadius = 4
        sureBtn.layer.masksToBounds = true
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.setBackgroundImage(sureBackImg, for: .normal)
        sureBtn.setBackgroundImage(sureBackImgHig, for: .highlighted)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        view.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.top.equalTo(codeView.snp.bottom).offset(40)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
        
        //赋值
        var bankcardNo = ""
        
//        if let valueStr = bankCardModel?.bankCompanyName {
//            bankcardNo = valueStr
//        }
//        
//        if let valueStr = bankCardModel?.bankcardNo {
//            let index = valueStr.index(valueStr.endIndex, offsetBy: -4)
//            let suffixStr = String(valueStr.suffix(from: index))
//            bankcardNo += " (****  ****  ****  \(suffixStr))"
//        }
//        
//        bankLabel.text = bankcardNo
//        
//        if let valueStr = bankCardModel?.mobile {
//            phoneLabel.text = valueStr
//        }
    }
    
    
    //MARK: - 触发事件
    //获取验证码
    @objc func getVCodeAction() {
        
        codeField.becomeFirstResponder()
        vCodeBtn.isEnabled = false
        sendSMSCode()
    }
    
    //提现
    @objc func sureAction() {
        
        if codeField.text?.count != 6 {
            self.noticeOnlyText("请输入6位验证码")
            return
        }
        if orderId == "" || orderDate == "" {
            self.noticeOnlyText("请先获取验证码~")
            return
        }
        
        sureBtn.isEnabled = false
        payment()
    }
    
    
    //MARK: - 定时器
    
    @objc func verificationWait() {
        var str: String
        
        if timerCount <= 0 {
            str = "获取验证码"
            vCodeBtn.isEnabled = true
            if let timer = verificationTimer {
                if timer.isValid {
                    verificationTimer.invalidate()
                }
            }
        }else {
            timerCount = timerCount-1
            str = "获取验证码(\(String(timerCount)))"
        }
        
        vCodeBtn.setTitle(str, for: .normal)
    }
    
    
    //MARK: - 网络请求
    
    //发送短信验证码
    func sendSMSCode() {
        
        var parameters: Parameters = [:]
        parameters["payMoney"] = payMoney
        parameters["purchaseOrderId"] = purchaseOrderId
        parameters["userCustId"] = userCustId
        
//        if let valueStr = bankCardModel?.cashBindCardId {
//            parameters["cardId"] = valueStr
//        }
        
        if let valueStr = UserData.shared.workerModel?.store?.id {
            parameters["storeId"] = valueStr
        }
        
        self.pleaseWait()
        let urlStr = APIURL.getValidPay
//        let urlStr = "http://192.168.1.19/NewYzb/yzbPurchaseOrder/port/validPay"
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let orderId = Utils.getReadString(dir: dataDic, field: "order_id")
                let orderDate = Utils.getReadString(dir: dataDic, field: "order_date")
                self.orderId = orderId
                self.orderDate = orderDate
                
                self.noticeOnlyText("发送成功,请查收")
                self.timerCount = 60
                
                if let timer = self.verificationTimer {
                    if timer.isValid {
                        timer.invalidate()
                    }
                }
                self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.verificationWait), userInfo: nil, repeats: true)
            }
            else{
                
                self.vCodeBtn.isEnabled = true
                self.vCodeBtn.setTitle("获取验证码", for: .normal)
                if let timer = self.verificationTimer {
                    if timer.isValid {
                        self.verificationTimer.invalidate()
                    }
                }
            }
            
        }) { (error) in
            
            self.vCodeBtn.isEnabled = true
            self.vCodeBtn.setTitle("获取验证码", for: .normal)
            if let timer = self.verificationTimer {
                if timer.isValid {
                    self.verificationTimer.invalidate()
                }
            }
        }
    }
    
    /// 快捷支付
    func payment() {
        
        var parameters: Parameters = [:]
        parameters["orderId"] = purchaseOrderId
        parameters["smsOrderId"] = orderId
        parameters["smsOrderDate"] = orderDate
        parameters["smsCode"] = codeField.text!
        parameters["userCastId"] = userCustId
//        
//        if let valueStr = bankCardModel?.cashBindCardId {
//            parameters["bindCardId"] = valueStr
//        }
        
        if let valueStr = UserData.shared.workerModel?.store?.id {
            parameters["storeId"] = valueStr
        }
        
        self.pleaseWait()
        let urlStr = APIURL.purchaseOrderPay
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            self.sureBtn.isEnabled = true
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "body")
                let urlStr = Utils.getReadString(dir: dataDic, field: "data")
                
                let vc = BrandDetailController()
                vc.title = "请耐心等待支付回调"
                vc.detailUrl = urlStr
                vc.isOrderPay = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }) { (error) in
            
            self.sureBtn.isEnabled = true
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //积分只允许输入数字
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newString.count > 6 {
            return false
        }
        
        if newString == "" {
            return true
        }
        
        let expression = "^[0-9]*$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        
        if numberOfMatches == 0 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder()
        return true
    }
    
}
