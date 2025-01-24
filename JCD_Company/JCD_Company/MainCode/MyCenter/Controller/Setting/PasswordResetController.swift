//
//  PassWordResetViewController.swift
//  YZB_Company
//
//  Created by 周化波 on 2017/12/19.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Alamofire


class PasswordResetController: BaseViewController, UITextFieldDelegate {
    
    var phoneField: UITextField!            //手机号
    var newPasswordField: UITextField!      //新密码输入框
    var validationView: UIView!             //验证码背景
    var verificationField: UITextField!     //验证码输入框
    var getValidationBtn: UIButton!         //获取验证码
    var saveBtn: UIButton!                  //保存按钮
    
    var verificationTimer: Timer!           //验证码定时器
    var timerCount: NSInteger!              //倒计时
    var codeKey = ""                        //验证码key


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "重置密码"
        
        prepareNormalView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    func prepareNormalView() {
        
        //手机号码图标
        let phoneLogo = UIView(frame: CGRect.init(x: 0, y: 0, width: 43, height: 44))
        let phoneLogoImg = UIImageView()
        phoneLogoImg.contentMode = .center
        phoneLogoImg.frame = CGRect.init(x: 10, y: 0, width: 33, height: 44)
        phoneLogoImg.image = UIImage.init(named: "login_phone")
        phoneLogo.addSubview(phoneLogoImg)
        
        //手机号输入框
        phoneField = UITextField()
        phoneField.isUserInteractionEnabled = false
        phoneField.returnKeyType = .done
        phoneField.placeholder = "请输入手机号"
        phoneField.textColor = PublicColor.commonTextColor
        phoneField.backgroundColor = .white
        phoneField.clearButtonMode = .whileEditing
        phoneField.font = UIFont.systemFont(ofSize: 15)
        phoneField.leftView = phoneLogo
        phoneField.leftViewMode = .always
        phoneField.keyboardType = .phonePad
        view.addSubview(phoneField)
        
        phoneField.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        //修改清除按钮
        let pclearBtn = phoneField.value(forKey: "_clearButton") as! UIButton
        pclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
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
        
        //新密码图标
        let newPasswordLogo = UIView(frame: phoneLogo.frame)
        let newPasswordLogoImg = UIImageView()
        newPasswordLogoImg.contentMode = phoneLogoImg.contentMode
        newPasswordLogoImg.frame = phoneLogoImg.frame
        newPasswordLogoImg.image = UIImage.init(named: "login_oldpw")
        newPasswordLogo.addSubview(newPasswordLogoImg)
        
        //新密码输入框
        newPasswordField = UITextField()
        newPasswordField.delegate = self
        newPasswordField.returnKeyType = .done
        newPasswordField.backgroundColor = .white
        newPasswordField.isSecureTextEntry = true
        newPasswordField.clearButtonMode = .whileEditing
        newPasswordField.placeholder = "请输入新密码"
        newPasswordField.font = phoneField.font
        newPasswordField.leftView = newPasswordLogo
        newPasswordField.leftViewMode = .always
        newPasswordField.keyboardType = .default
        view.addSubview(newPasswordField)
        
        newPasswordField.snp.makeConstraints { (make) in
            make.height.equalTo(phoneField)
            make.left.equalTo(0)
            make.right.equalTo(-40)
            make.top.equalTo(phoneField.snp.bottom).offset(10)
        }
        
        //修改清除按钮
        let nclearBtn = newPasswordField.value(forKey: "_clearButton") as! UIButton
        nclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框右侧按钮
        let nshowpwBtn = UIButton(type: .custom)
        nshowpwBtn.tag = 100
        nshowpwBtn.backgroundColor = .white
        nshowpwBtn.setImage(UIImage.init(named: "login_hidepw"), for: .normal)
        nshowpwBtn.setImage(UIImage.init(named: "login_showpw"), for: .selected)
        nshowpwBtn.addTarget(self, action: #selector(showPwAction(_:)), for: .touchUpInside)
        view.addSubview(nshowpwBtn)
        
        nshowpwBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(newPasswordField)
            make.right.equalTo(0)
            make.width.equalTo(40)
            make.height.equalTo(44)
        }
        
        
        let passwordHint = UILabel()
        passwordHint.text = "6-20位,可使用字母、数字、下划线组合"
        passwordHint.font = UIFont.systemFont(ofSize: 12)
        passwordHint.textColor = PublicColor.placeholderTextColor
        view.addSubview(passwordHint)
        
        passwordHint.snp.makeConstraints { (make) in
            make.left.equalTo(43)
            make.top.equalTo(newPasswordField.snp.bottom).offset(10)
        }
        
        //验证码背景
        validationView = UIView()
        validationView.backgroundColor = .white
        view.addSubview(validationView)
        
        validationView.snp.makeConstraints { (make) in
            make.top.equalTo(passwordHint.snp.bottom).offset(10)
            make.left.right.height.equalTo(phoneField)
        }
        
        //验证码图标
        let verificationCodeLogo = UIView(frame: phoneLogo.frame)
        let verificationCodeLogoImg = UIImageView()
        verificationCodeLogoImg.contentMode = phoneLogoImg.contentMode
        verificationCodeLogoImg.frame = phoneLogoImg.frame
        verificationCodeLogoImg.image = UIImage.init(named: "login_pin")
        verificationCodeLogo.addSubview(verificationCodeLogoImg)
        
        //验证码输入框
        verificationField = UITextField()
        verificationField.keyboardType = .numberPad
        verificationField.delegate = self
        verificationField.returnKeyType = .done
        verificationField.tag = 1003
        verificationField.clearButtonMode = .whileEditing
        verificationField.placeholder = "验证码"
        verificationField.font = phoneField.font
        verificationField.leftView = verificationCodeLogo
        verificationField.leftViewMode = .always
        if #available(iOS 12.0, *) {
            verificationField.textContentType = .oneTimeCode
        }
        validationView.addSubview(verificationField)
        
        verificationField.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(-116)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        validationView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(verificationField.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(20)
        }
        
        //获取验证吗按钮
        getValidationBtn = UIButton.init(type: .custom)
        getValidationBtn.setTitle("获取验证码", for: .normal)
        getValidationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        getValidationBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
        getValidationBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        getValidationBtn.setTitleColor(PublicColor.placeholderTextColor, for: .disabled)
        getValidationBtn.addTarget(self, action: #selector(getValidationAction), for: .touchUpInside)
        validationView.addSubview(getValidationBtn)
        
        getValidationBtn.snp.makeConstraints { (make) in
            make.top.height.right.equalToSuperview()
            make.left.equalTo(lineView.snp.right)
        }
        
        //保存
        let bgImg = PublicColor.gradualColorImage
        let bgHighImg = PublicColor.gradualHightColorImage
        saveBtn = UIButton.init(type: .custom)
        saveBtn.layer.cornerRadius = 4
        saveBtn.layer.masksToBounds = true
        saveBtn.setTitle("保存", for: .normal)
        saveBtn.setBackgroundImage(bgImg, for: .normal)
        saveBtn.setBackgroundImage(bgHighImg, for: .highlighted)
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(saveBtn)
        
        saveBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
            make.top.equalTo(verificationField.snp.bottom).offset(35)
        }
    }

    
    //MARK: - 按钮事件
    //密码是否可见
    @objc func showPwAction(_ sender:UIButton) {

        newPasswordField.isSecureTextEntry = sender.isSelected
       
        sender.isSelected = !sender.isSelected
    }
    
    //获取验证码
    @objc func getValidationAction(_ sender: UIButton) {
        
        if phoneField.text == "" {
            self.noticeOnlyText("请输入手机号")
            return
        }
        
        verificationField.text = ""
        
        if Utils_objectC.isMobileNumber2(phoneField.text) {
            
            sender.isEnabled = false
            sendSMSCode()
            
            verificationField.becomeFirstResponder()
            
        }else{
            self.noticeOnlyText("手机号码有误,请检查您输入的手机号是否正确!")
        }
    }

    /// 保存
    @objc func saveAction(_ sender: UIButton) {
        
        if !Utils_objectC.isMobileNumber2(phoneField.text) {
            
            self.noticeOnlyText("手机号码有误,请检查您输入的手机号是否正确!")
            return
        }
        
        if (newPasswordField.text?.count)! < 6 || (newPasswordField.text?.count)! > 20 {
            self.noticeOnlyText("请输入6-20位新密码")
            return
        }
        
        if verificationField.text?.count != 6 {
            self.noticeOnlyText("请输入6位数验证码")
            return
        }
        
        updatePassword(mobile: phoneField.text!, newPassword: newPasswordField.text!, password: verificationField.text!)
    }
    
    //MARK: - 定时器
    @objc func verificationWait() {
        var str: String
        
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
    
    //MARK: - 网络请求
    
    /// 发送短信验证码
    func sendSMSCode(){
        
        var parameters: Parameters = ["mobile": phoneField.text!]
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            parameters["type"] = "g"
        }else {
            parameters["type"] = "2"
        }
        
        let urlStr = APIURL.getSMS + phoneField.text!
        
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
                
                self.getValidationBtn.isEnabled = true
                self.getValidationBtn.setTitle("获取验证码", for: .normal)
                if let timer = self.verificationTimer {
                    if timer.isValid {
                        self.verificationTimer.invalidate()
                    }
                }
            }
            
        }) { (error) in
            
            self.getValidationBtn.isEnabled = true
            self.getValidationBtn.setTitle("获取验证码", for: .normal)
            if let timer = self.verificationTimer {
                if timer.isValid {
                    self.verificationTimer.invalidate()
                }
            }
        }
    }
    
    /// 修改密码
    func updatePassword(mobile: String, newPassword: String="", password: String="") {
        
        var parameters: Parameters = [:]
        parameters["password"] = YZBSign.shared.passwordMd5(password: newPassword)
        parameters["mobile"] = mobile
        parameters["validateCode"] = password
        
        
        self.pleaseWait()
        var urlStr = ""
        
        urlStr = APIURL.resetPassword
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            parameters["userType"] = 5
        case .gys:
            parameters["userType"] = 4
        case .yys:
            parameters["userType"] = 1
        case .fws:
            parameters["userType"] = 4
        }
        
        YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let popup = PopupDialog(title: "密码已重置", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

                let sureBtn = AlertButton(title: "确定") {
                    
                    if let subVCList = self.navigationController?.viewControllers {
                        
                        let vc = subVCList[subVCList.count-3]
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
      
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
       
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        
        if newString.count > 6 && textField.tag == 1003 {
            return false
        }
        return true
    }
}
