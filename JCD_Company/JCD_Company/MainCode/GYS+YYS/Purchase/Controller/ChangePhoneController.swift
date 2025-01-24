//
//  ChangePhoneController.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/19.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Alamofire
import ObjectMapper

class ChangePhoneController: BaseViewController, UITextFieldDelegate {

    var phoneField: UITextField!            //手机输入框
    var verificationField: UITextField!     //验证码输入框
    var getValidationBtn: UIButton!         //获取验证码
    
    var newPhoneField: UITextField!         //手机输入框
    var newVerificationField: UITextField!  //验证码输入框
    var newGetValidationBtn: UIButton!      //获取验证码
    
    var verificationTimer: Timer!           //验证码定时器
    var timerCount: NSInteger!              //倒计时
    var newVerificationTimer: Timer!        //验证码定时器
    var newTimerCount: NSInteger!           //倒计时
    
    var codeKey = ""                        //验证码key
    var oldCodeKey = ""                     //旧验证码key
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "修改手机号"
        
        prepareSubView()
    }
    

    func prepareSubView() {
        
        //手机号码图标
        let phoneLogo = UIView(frame: CGRect.init(x: 0, y: 0, width: 43, height: 44))
        let phoneLogoImg = UIImageView()
        phoneLogoImg.contentMode = .center
        phoneLogoImg.frame = CGRect.init(x: 10, y: 0, width: 33, height: 44)
        phoneLogoImg.image = UIImage.init(named: "login_phone")
        phoneLogo.addSubview(phoneLogoImg)
        
        //手机号输入框
        phoneField = UITextField()
        phoneField.delegate = self
        phoneField.returnKeyType = .done
        phoneField.tag = 1000
        phoneField.backgroundColor = .white
        phoneField.clearButtonMode = .whileEditing
        phoneField.placeholder = "请输入旧手机号"
        phoneField.isUserInteractionEnabled = false
        phoneField.font = UIFont.systemFont(ofSize: 15)
        phoneField.leftView = phoneLogo
        phoneField.leftViewMode = .always
        phoneField.keyboardType = .phonePad
        view.addSubview(phoneField)
        
        phoneField.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(10)
        }
        
        //修改清除按钮
        let phclearBtn = phoneField.value(forKey: "_clearButton") as! UIButton
        phclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        var userMobile = ""
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            if let valueStr = UserData.shared.workerModel?.mobile {
                userMobile = valueStr
            }
        case .gys:
            if let valueStr = UserData.shared.merchantModel?.mobile {
                userMobile = valueStr
            }
        case .yys:
            if let valueStr = UserData.shared.substationModel?.mobile {
                userMobile = valueStr
            }
        case .fws:
            if let valueStr = UserData.shared.merchantModel?.mobile {
                userMobile = valueStr
            }
        }
        phoneField.text = userMobile
        
//        //验证码背景
//        let validationView = UIView()
//        validationView.backgroundColor = .white
//        view.addSubview(validationView)
//
//        validationView.snp.makeConstraints { (make) in
//            make.top.equalTo(phoneField.snp.bottom).offset(1)
//            make.left.right.height.equalTo(phoneField)
//        }
//
//        //验证码图标
//        let verificationCodeLogo = UIView(frame: phoneLogo.frame)
//        let verificationCodeLogoImg = UIImageView()
//        verificationCodeLogoImg.contentMode = phoneLogoImg.contentMode
//        verificationCodeLogoImg.frame = phoneLogoImg.frame
//        verificationCodeLogoImg.image = UIImage.init(named: "login_pin")
//        verificationCodeLogo.addSubview(verificationCodeLogoImg)
//
//        //验证码输入框
//        verificationField = UITextField()
//        verificationField.delegate = self
//        verificationField.returnKeyType = .done
//        verificationField.keyboardType = .numberPad
//        verificationField.tag = 1001
//        verificationField.clearButtonMode = .whileEditing
//        verificationField.placeholder = "旧手机验证码"
//        verificationField.font = phoneField.font
//        verificationField.leftView = verificationCodeLogo
//        verificationField.leftViewMode = .always
//        if #available(iOS 12.0, *) {
//            verificationField.textContentType = .oneTimeCode
//        }
//        validationView.addSubview(verificationField)
//
//        verificationField.snp.makeConstraints { (make) in
//            make.left.top.bottom.equalToSuperview()
//            make.right.equalTo(-116)
//        }
//
//        //修改清除按钮
//        let vclearBtn = verificationField.value(forKey: "_clearButton") as! UIButton
//        vclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
//        //分割线
//        let lineView = UIView()
//        lineView.backgroundColor = PublicColor.partingLineColor
//        validationView.addSubview(lineView)
//
//        lineView.snp.makeConstraints { (make) in
//            make.left.equalTo(verificationField.snp.right)
//            make.centerY.equalToSuperview()
//            make.width.equalTo(1)
//            make.height.equalTo(20)
//        }
//
//        //获取验证吗按钮
//        getValidationBtn = UIButton.init(type: .custom)
//        getValidationBtn.tag = 101
//        getValidationBtn.setTitle("获取验证码", for: .normal)
//        getValidationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
//        getValidationBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
//        getValidationBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
//        getValidationBtn.setTitleColor(PublicColor.placeholderTextColor, for: .disabled)
//        getValidationBtn.addTarget(self, action: #selector(getValidationAction), for: .touchUpInside)
//        validationView.addSubview(getValidationBtn)
//
//        getValidationBtn.snp.makeConstraints { (make) in
//            make.top.height.right.equalToSuperview()
//            make.left.equalTo(lineView.snp.right)
//        }
        

        //新手机号码图标
        let nphoneLogo = UIView(frame: CGRect.init(x: 0, y: 0, width: 43, height: 44))
        let nphoneLogoImg = UIImageView()
        nphoneLogoImg.contentMode = .center
        nphoneLogoImg.frame = CGRect.init(x: 10, y: 0, width: 33, height: 44)
        nphoneLogoImg.image = UIImage.init(named: "login_phone")
        nphoneLogo.addSubview(nphoneLogoImg)
        
        //新手机号输入框
        newPhoneField = UITextField()
        newPhoneField.delegate = self
        newPhoneField.returnKeyType = .done
        newPhoneField.tag = 1002
        newPhoneField.backgroundColor = .white
        newPhoneField.clearButtonMode = .whileEditing
        newPhoneField.placeholder = "请输入新手机号"
        newPhoneField.font = UIFont.systemFont(ofSize: 15)
        newPhoneField.leftView = nphoneLogo
        newPhoneField.leftViewMode = .always
        newPhoneField.keyboardType = .phonePad
        view.addSubview(newPhoneField)
        
        newPhoneField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneField.snp.bottom).offset(10)
            make.left.right.height.equalTo(phoneField)
        }
        
        //修改清除按钮
        let newPhclearBtn = newPhoneField.value(forKey: "_clearButton") as! UIButton
        newPhclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //新手机验证码背景
        let newValidationView = UIView()
        newValidationView.backgroundColor = .white
        view.addSubview(newValidationView)
        
        newValidationView.snp.makeConstraints { (make) in
            make.top.equalTo(newPhoneField.snp.bottom).offset(1)
            make.left.right.height.equalTo(phoneField)
        }
        
        //验证码图标
        let nverificationCodeLogo = UIView(frame: phoneLogo.frame)
        let nverificationCodeLogoImg = UIImageView()
        nverificationCodeLogoImg.contentMode = phoneLogoImg.contentMode
        nverificationCodeLogoImg.frame = phoneLogoImg.frame
        nverificationCodeLogoImg.image = UIImage.init(named: "login_pin")
        nverificationCodeLogo.addSubview(nverificationCodeLogoImg)
        
        //验证码输入框
        newVerificationField = UITextField()
        newVerificationField.delegate = self
        newVerificationField.returnKeyType = .done
        newVerificationField.keyboardType = .numberPad
        newVerificationField.tag = 1003
        newVerificationField.clearButtonMode = .whileEditing
        newVerificationField.placeholder = "新手机验证码"
        newVerificationField.font = phoneField.font
        newVerificationField.leftView = nverificationCodeLogo
        newVerificationField.leftViewMode = .always
        if #available(iOS 12.0, *) {
            newVerificationField.textContentType = .oneTimeCode
        }
        newValidationView.addSubview(newVerificationField)
        
        newVerificationField.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(-116)
        }
        
        //修改清除按钮
        let newVclearBtn = newVerificationField.value(forKey: "_clearButton") as! UIButton
        newVclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //分割线
        let lineView1 = UIView()
        lineView1.backgroundColor = PublicColor.partingLineColor
        newValidationView.addSubview(lineView1)
        
        lineView1.snp.makeConstraints { (make) in
            make.left.equalTo(newVerificationField.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(20)
        }
        
        //获取验证吗按钮
        newGetValidationBtn = UIButton.init(type: .custom)
        newGetValidationBtn.tag = 102
        newGetValidationBtn.setTitle("获取验证码", for: .normal)
        newGetValidationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        newGetValidationBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
        newGetValidationBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        newGetValidationBtn.setTitleColor(PublicColor.placeholderTextColor, for: .disabled)
        newGetValidationBtn.addTarget(self, action: #selector(getValidationAction), for: .touchUpInside)
        newValidationView.addSubview(newGetValidationBtn)
        
        newGetValidationBtn.snp.makeConstraints { (make) in
            make.top.height.right.equalToSuperview()
            make.left.equalTo(lineView1.snp.right)
        }
        
        
        //注册
        let bgImg = PublicColor.gradualColorImage
        let bgHighImg = PublicColor.gradualHightColorImage
        let sureChangeBtn = UIButton.init(type: .custom)
        sureChangeBtn.layer.cornerRadius = 4
        sureChangeBtn.layer.masksToBounds = true
        sureChangeBtn.setTitle("确认修改", for: .normal)
        sureChangeBtn.setTitleColor(.white, for: .normal)
        sureChangeBtn.setBackgroundImage(bgImg, for: .normal)
        sureChangeBtn.setBackgroundImage(bgHighImg, for: .highlighted)
        sureChangeBtn.addTarget(self, action: #selector(sureChangeBtnAction), for: .touchUpInside)
        sureChangeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(sureChangeBtn)
        
        sureChangeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
            make.top.equalTo(newValidationView.snp.bottom).offset(50)
        }
    }
    
    //MARK: 按钮点击事件
    @objc func sureChangeBtnAction() {
        
        if !Utils_objectC.isMobileNumber2(phoneField.text) {
            
            self.noticeOnlyText("请检查旧手机号是否正确!")
            return
        }
        
//        if verificationField.text?.count != 6 {
//            self.noticeOnlyText("请输入6位数旧手机验证码")
//            return
//        }
        
        if !Utils_objectC.isMobileNumber2(newPhoneField.text) {
            
            self.noticeOnlyText("请检查新手机号是否正确!")
            return
        }
        
        if newVerificationField.text?.count != 6 {
            self.noticeOnlyText("请输入6位数新手机验证码")
            return
        }
        
        modifyMobile(phoneStr: phoneField.text!, codeStr: "", newPhoneStr: newPhoneField.text!, newCodeStr: newVerificationField.text!)
    }
    
    
    //获取验证码
    @objc func getValidationAction(_ sender: UIButton) {
        
        var phoneStr = ""
        if sender.tag == 101 {
            
            if phoneField.text == "" {
                self.noticeOnlyText("旧手机号为空")
                return
            }
            verificationField.text = ""
            phoneStr = phoneField.text!
        }
        else if sender.tag == 102 {
            
            if newPhoneField.text == "" {
                self.noticeOnlyText("新手机号为空")
                return
            }
            newVerificationField.text = ""
            phoneStr = newPhoneField.text!
        }
        
        if Utils_objectC.isMobileNumber2(phoneStr) {
            
            if sender.tag == 101 {
                getValidationBtn.isEnabled = false
                verificationField.becomeFirstResponder()
            }
            else if sender.tag == 102 {
                newGetValidationBtn.isEnabled = false
                newVerificationField.becomeFirstResponder()
            }
            sendSMSCode(phoneStr: phoneStr, btnTag: sender.tag)
            
        }else{
            let popup = PopupDialog(title: phoneStr, message: "手机号码有误,请检查您输入的手机号是否正确!", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
            
            let sureBtn = AlertButton(title: "确定") {
                
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
    }
   
    //MARK: - 定时器
    @objc func verificationWait(_ timer: Timer) {
        var str: String
        
        if let btnTag = timer.userInfo as? Int {
            
            if btnTag == 101 {
                
                if timerCount <= 0 {
                    str = "获取验证码"
                    getValidationBtn.isEnabled = true
                    if let timer = verificationTimer {
                        if timer.isValid {
                            verificationTimer.invalidate()
                        }
                    }
                }else {
                    timerCount = timerCount-1
                    str = "获取验证码(\(String(timerCount)))"
                }
                
                getValidationBtn.setTitle(str, for: .normal)
                
            }
            else if btnTag == 102 {
                
                if newTimerCount <= 0 {
                str = "获取验证码"
                newGetValidationBtn.isEnabled = true
                if timer.isValid {
                    newVerificationTimer.invalidate()
                }
            }else {
                newTimerCount = newTimerCount-1
                str = "获取验证码(\(String(newTimerCount)))"
                }
                
                newGetValidationBtn.setTitle(str, for: .normal)
            }
        }
    }
    
    //MARk: - 网络请求
    
    func sendSMSCode(phoneStr: String, btnTag: Int){
        
        var parameters: Parameters = ["mobile": phoneStr]
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            if btnTag == 101 {
                parameters["type"] = "g"
            }else {
                parameters["type"] = "gys"
            }
        }else {
            if btnTag == 101 {
                parameters["type"] = "1"
            }else {
                parameters["type"] = "updateMobile"
            }
        }
        
        let urlStr = APIURL.getSMS + phoneStr
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let body = Utils.getReadDic(data: response as NSDictionary, field: "data")
                let codeKey = Utils.getReadString(dir: body, field: "codeKey")
                
                if btnTag == 101 {
                    self.oldCodeKey = codeKey
                }else {
                    self.codeKey = codeKey
                }
                
                self.noticeOnlyText("发送成功,请查收")
                
                if btnTag == 101 {
                    
                    self.timerCount = 60
                    if let timer = self.verificationTimer {
                        if timer.isValid {
                            timer.invalidate()
                        }
                    }
                    self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.verificationWait), userInfo: btnTag, repeats: true)
                }
                else if btnTag == 102 {
                    
                    self.newTimerCount = 60
                    if let timer = self.newVerificationTimer {
                        if timer.isValid {
                            timer.invalidate()
                        }
                    }
                    self.newVerificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.verificationWait), userInfo: btnTag, repeats: true)
                }
                
            }
            else{
                if btnTag == 101 {
                    self.getValidationBtn.isEnabled = true
                }
                else if btnTag == 102 {
                    self.newGetValidationBtn.isEnabled = true
                }
            }
            
        }) { (error) in
            
            if btnTag == 101 {
                self.getValidationBtn.isEnabled = true
            }
            else if btnTag == 102 {
                self.newGetValidationBtn.isEnabled = true
            }
        }
    }
    
    func modifyMobile(phoneStr: String = "", codeStr: String = "", newPhoneStr: String = "", newCodeStr: String = "") {
        
        var parameters: Parameters = [:]
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            parameters["oldMobile"] = phoneStr
            parameters["codeKey"] = oldCodeKey
            parameters["newMobile"] = newPhoneStr
            parameters["validateCode"] = newCodeStr
        }else {
            parameters["oldMobile"] = phoneStr
            parameters["oldValidateCode"] = codeStr
            parameters["oldCodeKey"] = oldCodeKey
            parameters["newMobile"] = newPhoneStr
            parameters["newValidateCode"] = newCodeStr
            parameters["newCodeKey"] = codeKey
        }
        
        self.pleaseWait()
        var urlStr = ""
        
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            break
//            if let valueStr = UserData.shared.workerModel?.id {
//                parameters["id"] = valueStr
//            }
//            urlStr = APIURL.updateMobile
        case .gys:
            if let valueStr = UserData.shared.merchantModel?.id {
                parameters["merchantId"] = valueStr
            }
            urlStr = APIURL.editGysMobile
        case .yys:
            break
        case .fws:
            if let valueStr = UserData.shared.merchantModel?.id {
                parameters["merchantId"] = valueStr
            }
            urlStr = APIURL.editGysMobile
        }
        
        YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let popup = PopupDialog(title: "手机号修改成功", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    self.navigationController?.popViewController(animated: true)
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
        
    }
    
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString == "" {
            return true
        }
        
        if  textField.tag == 1000 || textField.tag == 1001 {
            
            //手机号、验证码只允许输入数字
            if newString.count > 11 && textField.tag == 1000 {
                return false
            }
            
            if newString.count > 6 && textField.tag == 1001 {
                return false
            }
            
            let expression = "^[0-9]*$"
            let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
            let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
            
            if numberOfMatches == 0 {
                return false
            }
        }
        
        return true
    }
}
