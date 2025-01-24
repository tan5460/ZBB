//
//  PasswordModificationViewController.swift
//  YZB_Company
//
//  Created by 周化波 on 2017/12/19.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Alamofire


class PasswordModifyController: BaseViewController, UITextFieldDelegate {
    
    var passwordField: UITextField!         //密码输入框
    var newPasswordField: UITextField!      //新密码输入框
    var confirmPasswordField: UITextField!  //确认密码输入框
    var saveBtn: UIButton!                  //登录按钮
    var codeKey = ""                        //验证码key
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改密码"
        
        prepareNormalView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func prepareNormalView() {
        
        //旧密码图标
        let passwordLogo = UIView(frame: CGRect.init(x: 0, y: 0, width: 43, height: 44))
        let passwordLogoImg = UIImageView()
        passwordLogoImg.contentMode = .center
        passwordLogoImg.frame = CGRect.init(x: 10, y: 0, width: 33, height: 44)
        passwordLogoImg.image = UIImage.init(named: "login_oldpw")
        passwordLogo.addSubview(passwordLogoImg)
        
        //旧密码输入框
        passwordField = UITextField()
        passwordField.delegate = self
        passwordField.returnKeyType = .done
        passwordField.backgroundColor = .white
        passwordField.isSecureTextEntry = true
        passwordField.clearButtonMode = .whileEditing
        passwordField.placeholder = "旧密码"
        passwordField.font = UIFont.systemFont(ofSize: 15)
        passwordField.leftView = passwordLogo
        passwordField.leftViewMode = .always
        passwordField.keyboardType = .default
        view.addSubview(passwordField)
        
        passwordField.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(0)
            make.right.equalTo(-40)
            make.height.equalTo(44)
        }
        
        //修改清除按钮
        let pclearBtn = passwordField.value(forKey: "_clearButton") as! UIButton
        pclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框右侧按钮
        let pshowpwBtn = UIButton(type: .custom)
        pshowpwBtn.tag = 100
        pshowpwBtn.backgroundColor = .white
        pshowpwBtn.setImage(UIImage.init(named: "login_hidepw"), for: .normal)
        pshowpwBtn.setImage(UIImage.init(named: "login_showpw"), for: .selected)
        pshowpwBtn.addTarget(self, action: #selector(showPwAction(_:)), for: .touchUpInside)
        view.addSubview(pshowpwBtn)
        
        pshowpwBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(passwordField)
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
            make.top.equalTo(passwordField.snp.bottom).offset(10)
        }
        
        //新密码图标
        let newPasswordLogo = UIView(frame: passwordLogo.frame)
        let newPasswordLogoImg = UIImageView()
        newPasswordLogoImg.contentMode = passwordLogoImg.contentMode
        newPasswordLogoImg.frame = passwordLogoImg.frame
        newPasswordLogoImg.image = UIImage.init(named: "login_oldpw")
        newPasswordLogo.addSubview(newPasswordLogoImg)
        
        //新密码输入框
        newPasswordField = UITextField()
        newPasswordField.delegate = self
        newPasswordField.returnKeyType = .done
        newPasswordField.backgroundColor = .white
        newPasswordField.isSecureTextEntry = true
        newPasswordField.clearButtonMode = .whileEditing
        newPasswordField.placeholder = "新密码"
        newPasswordField.font = passwordField.font
        newPasswordField.leftView = newPasswordLogo
        newPasswordField.leftViewMode = .always
        newPasswordField.keyboardType = .default
        view.addSubview(newPasswordField)
        
        newPasswordField.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(passwordField)
            make.top.equalTo(passwordHint.snp.bottom).offset(11)
        }
        
        //修改清除按钮
        let nclearBtn = passwordField.value(forKey: "_clearButton") as! UIButton
        nclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框右侧按钮
        let nshowpwBtn = UIButton(type: .custom)
        nshowpwBtn.tag = 101
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
        
        //确认密码图标
        let confirmPasswordLogo = UIView(frame: passwordLogo.frame)
        let confirmPasswordLogoImg = UIImageView()
        confirmPasswordLogoImg.contentMode = passwordLogoImg.contentMode
        confirmPasswordLogoImg.frame = passwordLogoImg.frame
        confirmPasswordLogoImg.image = UIImage.init(named: "login_pwagain")
        confirmPasswordLogo.addSubview(confirmPasswordLogoImg)
        
        //确认密码输入框
        confirmPasswordField = UITextField()
        confirmPasswordField.delegate = self
        confirmPasswordField.returnKeyType = .done
        confirmPasswordField.backgroundColor = .white
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.clearButtonMode = .whileEditing
        confirmPasswordField.placeholder = "确认新密码"
        confirmPasswordField.font = passwordField.font
        confirmPasswordField.leftView = confirmPasswordLogo
        confirmPasswordField.leftViewMode = .always
        confirmPasswordField.keyboardType = .default
        view.addSubview(confirmPasswordField)
        
        confirmPasswordField.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(passwordField)
            make.top.equalTo(newPasswordField.snp.bottom).offset(10)
        }
        
        //修改清除按钮
        let cclearBtn = passwordField.value(forKey: "_clearButton") as! UIButton
        cclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框右侧按钮
        let cshowpwBtn = UIButton(type: .custom)
        cshowpwBtn.tag = 102
        cshowpwBtn.backgroundColor = .white
        cshowpwBtn.setImage(UIImage.init(named: "login_hidepw"), for: .normal)
        cshowpwBtn.setImage(UIImage.init(named: "login_showpw"), for: .selected)
        cshowpwBtn.addTarget(self, action: #selector(showPwAction(_:)), for: .touchUpInside)
        view.addSubview(cshowpwBtn)
        
        cshowpwBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(confirmPasswordField)
            make.right.equalTo(0)
            make.width.equalTo(40)
            make.height.equalTo(44)
        }
        
        //保存
        let bgImg = PublicColor.gradualColorImage
        let bgHighImg = PublicColor.gradualHightColorImage
        saveBtn = UIButton.init(type: .custom)
        saveBtn.layer.cornerRadius = 4
        saveBtn.layer.masksToBounds = true
        saveBtn.setTitle("保存", for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.setBackgroundImage(bgImg, for: .normal)
        saveBtn.setBackgroundImage(bgHighImg, for: .highlighted)
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        view.addSubview(saveBtn)
        
        saveBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
            make.top.equalTo(confirmPasswordField.snp.bottom).offset(35)
        }
        
        if UserData.shared.userType != .yys {
            
            let resetBtn = UIButton(type: .custom)
            resetBtn.frame = CGRect.init(x: 0, y: 0, width: 60, height: 26)
            resetBtn.setTitle("忘记密码", for: .normal)
            resetBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            resetBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            resetBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
            resetBtn.addTarget(self, action: #selector(otherLoginAction), for: .touchUpInside)
            view.addSubview(resetBtn)
            
            resetBtn.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.height.equalTo(40)
                make.top.equalTo(saveBtn.snp.bottom).offset(12)
            }
        }
    }

    //MARK: - 按钮事件
    //密码是否可见
    @objc func showPwAction(_ sender:UIButton) {
        if sender.tag == 100 {
            passwordField.isSecureTextEntry = sender.isSelected
        }else if sender.tag == 101 {
            newPasswordField.isSecureTextEntry = sender.isSelected
        }else {
            confirmPasswordField.isSecureTextEntry = sender.isSelected
        }
        sender.isSelected = !sender.isSelected
    }

    //忘记密码
    @objc func otherLoginAction(_ sender: UIButton) {
        
        let vc = PasswordResetController()
        navigationController?.pushViewController(vc, animated: true)
    }

    //保存
    @objc func saveAction(_ sender: UIButton) {
        
        if (passwordField.text?.count)! <= 0 {
            noticeOnlyText("请输入旧密码")
            return
        }
        
        if (newPasswordField.text?.count)! < 6 || (newPasswordField.text?.count)! > 20 {
            noticeOnlyText("请输入6-20位新密码")
            return
        }
        
        if confirmPasswordField.text == "" {
            self.noticeOnlyText("请确认新密码")
            return
        }
       
        if passwordField.text == newPasswordField.text {
            noticeOnlyText("新密码与旧密码一样！")
            return
        }
    
        if confirmPasswordField.text != newPasswordField.text {
            noticeOnlyText("新密码不一致")
            return
        }
        
        updatePassword(newPassword: newPasswordField.text!, password: passwordField.text!)
    }

    //修改密码
    func updatePassword(newPassword: String="", password: String="") {
        
        var parameters: Parameters = [:]
        parameters["newPassword"] = YZBSign.shared.passwordMd5(password: newPassword)
        parameters["password"] = YZBSign.shared.passwordMd5(password: password)
        
        self.pleaseWait()
        let urlStr = APIURL.updatePassword
        parameters["id"] = UserData1.shared.tokenModel?.userId ?? ""
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            parameters["mobile"] = UserData.shared.workerModel?.mobile ?? ""
         //   urlStr = APIURL.updatePassword
        case .gys:
            parameters["mobile"] = UserData.shared.merchantModel?.mobile ?? ""
           // urlStr = APIURL.updateGYSPassword
        case .yys:
            parameters["mobile"] = UserData.shared.substationModel?.mobile ?? ""
          //  urlStr = APIURL.updateYYSPassword
        case .fws:
            parameters["mobile"] = UserData.shared.merchantModel?.mobile ?? ""
        }
        
        YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let popup = PopupDialog(title: "密码修改成功", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

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
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
       
    }

}
