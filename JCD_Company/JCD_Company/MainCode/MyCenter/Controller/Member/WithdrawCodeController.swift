//
//  WithdrawCodeController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/27.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PopupDialog

class WithdrawCodeController: BaseViewController, UITextFieldDelegate {

    var scoreValue = ""                 //提现积分
    var telValue = ""                   //电话
    var codeKey = ""                    //验证码key
    var verificationTimer: Timer!       //验证码定时器
    var timerCount: NSInteger!          //倒计时
    
    var codeField: UITextField!         //验证码输入框
    var vCodeBtn: UIButton!             //获取验证码
    var sureBtn: UIButton!              //确认提现
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "积分提现"
        
        prepareSubView()
        
        sendSMSCode()
        vCodeBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func prepareSubView() {
        
        //验证码发送至
        let telLabel = UILabel()
        telLabel.text = "验证码已发送至 +86 \(telValue)"
        telLabel.textColor = PublicColor.minorTextColor
        telLabel.font = UIFont.systemFont(ofSize: 13)
        view.addSubview(telLabel)
        
        telLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(15)
        }
        
        //验证码背景
        let codeView = UIView()
        codeView.backgroundColor = .white
        view.addSubview(codeView)
        
        codeView.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.top.equalTo(telLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
        }
        
        //验证码
        codeField = UITextField()
        codeField.returnKeyType = .done
        codeField.delegate = self
        codeField.tag = 1001
        codeField.clearButtonMode = .whileEditing
        codeField.textColor = .black
        codeField.placeholder = "请输入验证码"
        codeField.font = UIFont.systemFont(ofSize: 15)
        codeView.addSubview(codeField)
        
        codeField.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.right.equalTo(-135)
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
            make.left.equalTo(codeField.snp.right).offset(10)
            make.right.equalTo(-15)
            make.height.equalTo(30)
        }
        
        //确认提现
        let sureBackImg = UIColor.colorFromRGB(rgbValue: 0xDE5D4B).image()
        let sureBackImgHig = UIColor.colorFromRGB(rgbValue: 0xC24E3E).image()
        sureBtn = UIButton(type: .custom)
        sureBtn.layer.cornerRadius = 4
        sureBtn.layer.masksToBounds = true
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.setBackgroundImage(sureBackImg, for: .normal)
        sureBtn.setBackgroundImage(sureBackImgHig, for: .highlighted)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        view.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.top.equalTo(codeView.snp.bottom).offset(20)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
    }
    
    
    //MARK: - 触发事件
    
    @objc func getVCodeAction() {
        
        codeField.becomeFirstResponder()
        vCodeBtn.isEnabled = false
        sendSMSCode()
    }
    
    //确认提现
    @objc func sureAction() {
        
        if codeField.text?.count != 6 {
            self.noticeOnlyText("请输入6位验证码")
            return
        }
        
        sureBtn.isEnabled = false
        sendExchangeGoods()
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
        
        self.pleaseWait()
        let parameters: Parameters = ["mobile": telValue, "type": "tx"]
        let urlStr = APIURL.getSMS + telValue
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                
                let body = Utils.getReadDic(data: response as NSDictionary, field: "data")
                let codeKey = Utils.getReadString(dir: body, field: "codeKey")
                self.codeKey = codeKey
                
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
    
    //提现
    func sendExchangeGoods() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        
        var parameters: Parameters = [:]
        parameters["worker.id"] = userId
        parameters["type"] = "2"
        parameters["goodsCount"] = "1"
        parameters["goods.id"] = ""
        parameters["address"] = ""
        parameters["contact"] = ""
        parameters["mobile"] = telValue
        parameters["validateCode"] = codeField.text!
        parameters["codeKey"] = codeKey
        parameters["money"] = scoreValue
        parameters["tel"] = telValue
        
        self.pleaseWait()
        let urlStr = APIURL.exchangeGoods
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            self.sureBtn.isEnabled = true
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let popup = PopupDialog(title: "提交成功", message: "提现申请需要审核，请耐心等待!", buttonAlignment: .vertical)
                let sureBtn = AlertButton(title: "确认") {
                    
                    if let viewControllers = self.navigationController?.viewControllers {
                        let vc = viewControllers[viewControllers.count-3]
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
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
