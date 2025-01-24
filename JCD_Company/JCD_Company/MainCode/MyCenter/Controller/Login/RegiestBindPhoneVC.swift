//
//  RegiestBindPhoneVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/10/12.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class RegiestBindPhoneVC: BaseViewController {
    var response: [String: Any] = [:]
    var authLoginType =  1 //  1.微信 2.支付宝
    var bindPhoneBlock: ((_ phone: String, _ password: String) -> Void)?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private let phoneTextField = UITextField()
    private let codeTextField = UITextField()
    private let getCodeBtn = UIButton().text("获取验证码").textColor(UIColor.hexColor("#F68235")).font(12)
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let nickName = Utils.getReadString(dir: response as NSDictionary, field: "nickname")
//        let sex = Utils.getReadString(dir: response as NSDictionary, field: "sex")
//        let headimgurl = Utils.getReadString(dir: response as NSDictionary, field: "headimgurl")
//        let uid = Utils.getReadString(dir: response as NSDictionary, field: "uid")
//        let openid = Utils.getReadString(dir: response as NSDictionary, field: "openid")
        
        statusStyle = .lightContent
        let topBG = UIImageView().image(#imageLiteral(resourceName: "login_bind_phone_top_bg"))
        view.sv(topBG)
        view.layout(
            0,
            |topBG.height(327.5)|,
            >=0
        )
        let backBtn = UIButton().image(#imageLiteral(resourceName: "scanCode_back"))
        let titleLabel = UILabel().text("绑定手机号").textColor(.white).fontBold(18)
        let helpBtn = UIButton().text("帮助").textColor(.white).font(16)
        let tipLabel = UILabel().text("请输入你要绑定的手机号码，并验证").textColor(.white).font(14)
        let centerBG = UIImageView().image(#imageLiteral(resourceName: "login_bind_phone_center_bg"))
        centerBG.isUserInteractionEnabled = true
        view.sv(backBtn, titleLabel, helpBtn, tipLabel, centerBG)
        view.layout(
            PublicSize.kStatusBarHeight,
            |-0-backBtn.size(44)-(>=0)-titleLabel.centerHorizontally()-(>=0)-helpBtn.width(50).height(44)-0-|,
            20,
            |-14-tipLabel.height(20),
            0,
            |-0-centerBG.height(393)-0-|,
            >=0
        )
        helpBtn.isHidden = true
        let phoneTextFieldBG = UIView().borderColor(.k27A27D).borderWidth(0.5).cornerRadius(29.5)
        let codeTextFieldBG = UIView().borderColor(.k27A27D).borderWidth(0.5).cornerRadius(29.5)
        let bindBtn = UIButton().text("立即绑定").textColor(.white).font(16).backgroundColor(.k27A27D).cornerRadius(29.5)
        centerBG.sv(phoneTextFieldBG, codeTextFieldBG, bindBtn)
        centerBG.layout(
            69.5,
            phoneTextFieldBG.width(280).height(59).centerHorizontally(),
            30,
            codeTextFieldBG.width(280).height(59).centerHorizontally(),
            40,
            bindBtn.width(280).height(59).centerHorizontally(),
            >=0
        )
        
        let phoneIcon = UIImageView().image(#imageLiteral(resourceName: "login_bind_phone_phone"))
        
        
        phoneTextField.clearButtonMode = .whileEditing
        phoneTextField.placeholder("请输入手机号")
        phoneTextField.placeholderColor = .k27A27D
        phoneTextField.font = .systemFont(ofSize: 14)
        phoneTextField.keyboardType = .phonePad
        phoneTextFieldBG.sv(phoneIcon, phoneTextField)
        phoneTextFieldBG.layout(
            19.5,
            |-20-phoneIcon.size(20)-6-phoneTextField.height(59)-20-|,
            19.5
        )
        
        let codeIcon = UIImageView().image(#imageLiteral(resourceName: "login_bind_phone_code"))
        
        let codeLine = UIView().backgroundColor(.k27A27D)
        
        
        codeTextField.clearButtonMode = .whileEditing
        codeTextField.placeholder("请输入验证码")
        codeTextField.placeholderColor = .k27A27D
        codeTextField.font = .systemFont(ofSize: 14)
        codeTextField.keyboardType = .phonePad
        codeTextFieldBG.sv(codeIcon, codeTextField, codeLine, getCodeBtn)
        codeTextFieldBG.layout(
            19.5,
            |-20-codeIcon.size(20)-6-codeTextField.height(59)-5-codeLine.width(0.5).height(59)-0-getCodeBtn.width(100).height(59)-0-|,
            19.5
        )
        backBtn.tapped { [weak self] (btn) in
            self?.navigationController?.popViewController(animated: true)
        }
        
        getCodeBtn.tapped { [weak self] (btn) in
            if self?.phoneTextField.text == "" {
                self?.noticeOnlyText("请输入手机号")
                return
            }
            //验证码置空
            self?.codeTextField.text = ""
            
            if Utils_objectC.isMobileNumber2(self?.phoneTextField.text) {
                
                self?.codeTextField.becomeFirstResponder()
                self?.getCodeBtn.isEnabled = false
                self?.sendSMSCode()
            }
            else{
                self?.noticeOnlyText("手机号码有误,请检查您输入的手机号是否正确!")
            }
        }
        
        bindBtn.tapped { [weak self] (btn) in
            self?.checkMobile()
        }
    }
    
    func checkMobile() {
        var parameters = Parameters()
        parameters["mobile"] = phoneTextField.text
        parameters["code"] = codeTextField.text
        parameters["type"] = authLoginType
        if authLoginType == 1 {
            parameters["openId"] = Utils.getReadString(dir: response as NSDictionary, field: "openid")
        } else {
            parameters["openId"] = Utils.getReadString(dir: response as NSDictionary, field: "alipay_open_id")
        }
        YZBSign.shared.request(APIURL.checkMobile, method: .get, parameters: parameters, success: { (res) in
            let code = Utils.getReadString(dir: res as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: res as AnyObject)
                let userInfoModel = Mapper<YZBUserInfoModel>().map(JSON: dataDic as! [String : Any])
                let userName = userInfoModel?.userName ?? ""
                let password = userInfoModel?.password ?? ""
                self.bindPhoneBlock?(userName, password)
                self.navigationController?.popViewController(animated: false)
            } else if code == "3" {
                let vc = ServiceRegiestSelectVC()
                vc.title = "会员注册"
                vc.phone = self.phoneTextField.text ?? ""
                if self.authLoginType == 1 {
                   vc.openId = Utils.getReadString(dir: self.response as NSDictionary, field: "openid")
                } else {
                    vc.openId = Utils.getReadString(dir: self.response as NSDictionary, field: "alipay_open_id")
                }
                vc.authLoginType = self.authLoginType
                self.navigationController?.pushViewController(vc)
            }
        }) { (error) in
        
        }
    }
    private var codeKey = ""
    private var timerCount: NSInteger!              //倒计时
    private var verificationTimer: Timer!           //验证码定时器
    //发送短信验证码
    func sendSMSCode() {
        let parameters: Parameters = ["mobile": phoneTextField.text!]
        let urlStr = APIURL.getSMS + phoneTextField.text!
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let data = Utils.getReadDic(data: response as NSDictionary, field: "data")
                let codeKey = Utils.getReadString(dir: data, field: "codeKey")
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
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self.noticeOnlyText(msg)
                self.getCodeBtn.isEnabled = true
                self.getCodeBtn.setTitle("获取验证码", for: .normal)
                if let timer = self.verificationTimer {
                    if timer.isValid {
                        self.verificationTimer.invalidate()
                    }
                }
            }
            
        }) { (error) in
            
            self.getCodeBtn.isEnabled = true
            self.getCodeBtn.setTitle("获取验证码", for: .normal)
            if let timer = self.verificationTimer {
                if timer.isValid {
                    self.verificationTimer.invalidate()
                }
            }
        }
    }
    
    //MARK: - 定时器
    @objc func verificationWait() {
        var str: String
        if timerCount <= 0 {
            str = "获取验证码"
            getCodeBtn.isEnabled = true
            if let timer = verificationTimer {
                if timer.isValid {
                    verificationTimer.invalidate()
                }
            }
        }else {
            timerCount = timerCount-1
            str = "获取验证码(\(String(timerCount)))"
        }
        getCodeBtn.setTitle(str, for: .normal)
    }
}
