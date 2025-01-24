//
//  PasswordLoginVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/18.
//

import UIKit
import ObjectMapper

class PasswordLoginVC: BaseViewController, UITextFieldDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    private let phoneTF = UITextField().placeholder("请输入您的账号")
    private let passwordTF = UITextField().placeholder("请输入您的密码")
    override func viewDidLoad() {
        super.viewDidLoad()
        let bottomIV = UIImageView().image(#imageLiteral(resourceName: "login_bottom_bg"))
        view.sv(bottomIV)
        view.layout(
            >=0,
            |bottomIV.height(194)|,
            0
        )
        
        let backBtn = UIButton().image(#imageLiteral(resourceName: "back_nav"))
        backBtn.isHidden = true
        let lab1 = UILabel().text("欢迎登录聚材道").textColor(.kColor33).fontBold(24)
        let lab2 = UILabel().text("账号密码登录").textColor(.kColor33).font(16)
        let phoneTFBG = UIView().cornerRadius(4).borderColor(UIColor.hexColor("#61D9B9")).borderWidth(0.5)
        let phoneIcon = UIImageView().image(#imageLiteral(resourceName: "login_icon_phone"))
        
        let passwordTFBG = UIView().cornerRadius(4).borderColor(UIColor.hexColor("#61D9B9")).borderWidth(0.5)
        let passwordIcon = UIImageView().image(#imageLiteral(resourceName: "login_icon_password"))
        
        let loginBtn = UIButton().text("登录").textColor(.white).font(16)
        let codeLoginBtn = UIButton()
        let codeLoginLab = UILabel().text("验证码登录").textColor(.k1DC597).font(12)
        let codeLoginIV = UIImageView().image(#imageLiteral(resourceName: "login_icon_in"))
        view.sv(backBtn, lab1, lab2, phoneTFBG, passwordTFBG, loginBtn, codeLoginBtn)
        view.layout(
            PublicSize.kStatusBarHeight+61,
            |-30-lab1.height(33.5),
            20,
            |-30-lab2.height(22.5),
            30,
            |-30-phoneTFBG.height(50)-30-|,
            20,
            |-30-passwordTFBG.height(50)-30-|,
            30,
            |-30-loginBtn.height(50)-30-|,
            10,
            |-30-codeLoginBtn.width(100).height(16.5),
            >=0
        )
        
        phoneTF.placeholderColor = .kColor99
        phoneTF.font(14)
        phoneTF.keyboardType = .namePhonePad
        phoneTF.delegate = self
        phoneTF.clearButtonMode = .whileEditing
        phoneTFBG.sv(phoneIcon, phoneTF)
        phoneTFBG.layout(
            15,
            |-15-phoneIcon.size(20)-10-phoneTF.height(50)-10-|,
            15
        )
        
        passwordTF.placeholderColor = .kColor99
        passwordTF.font(14)
        passwordTF.keyboardType = .namePhonePad
        passwordTF.isSecureTextEntry = true
        passwordTF.delegate = self
        passwordTF.clearButtonMode = .whileEditing
        
        let showBtn = UIButton()
        showBtn.setImage(#imageLiteral(resourceName: "password_unshow"), for: .normal)
        showBtn.setImage(#imageLiteral(resourceName: "password_show"), for: .selected)
        
        passwordTFBG.sv(passwordIcon, passwordTF, showBtn)
        passwordTFBG.layout(
            15,
            |-15-passwordIcon.size(20)-10-passwordTF.height(50)-0-showBtn.width(47).height(50)-0-|,
            15
        )
        
        loginBtn.corner(radii: 4).fillGreenColorLF()
        
        codeLoginBtn.sv(codeLoginLab, codeLoginIV)
        codeLoginBtn.layout(
            0,
            |codeLoginLab.height(16.5)-2-codeLoginIV.size(16),
            0
        )
        
        backBtn.tapped { [weak self] (tapBtn) in
            self?.navigationController?.popViewController()
        }
        codeLoginBtn.tapped { [weak self] (tapBtn) in
            self?.navigationController?.popViewController()
        }
        loginBtn.tapped { [weak self] (tapBtn) in
            self?.login()
        }
        showBtn.tapped { [weak self] (tapBtn) in
            showBtn.isSelected = !showBtn.isSelected
            self?.passwordTF.isSecureTextEntry = !showBtn.isSelected
        }
    }
    
    func enterCodeLoginVC() {
        navigationController?.popViewController()
    }

    //MARK: - 账号密码登录
    func login() {
        
        guard let account = phoneTF.text, !account.isEmpty else {
            noticeOnlyText("\(phoneTF.placeholder ?? "")")
            return
        }
        guard let password = passwordTF.text, !password.isEmpty else {
            noticeOnlyText("\(passwordTF.placeholder ?? "")")
            return
        }
        pleaseWait()
        let deviceName: String = String.init(format: "%@", UIDevice.current.model)
        var parameters: Parameters = ["deviceType": "1", "deviceId": UserData.shared.registrationId, "deviceSystem": UIDevice.current.systemVersion, "deviceName": deviceName, "appVersion": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String]
        parameters["username"] = account
        parameters["password"] = YZBSign.shared.passwordMd5(password: password)
        parameters["type"] = 5
        parameters["fromType"] = "APP"
        let urlStr = APIURL.login
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let tokenModel = Mapper<TokenModel1>().map(JSON: dataDic as! [String: Any])
                UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel)
                UserData1.shared.tokenModel = tokenModel
                self.getUserInfoRequest()
            } else if errorCode == "401" {
                self.notice("您的账号已在另一台设备中登录，如非本人操作，则密码可能已经泄露，建议立即修改密码。", autoClear: true, autoClearTime: 3)
            }
            else if errorCode == "23" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let regiestBaseModel = Mapper<RegisterBaseModel>().map(JSON: dataDic as! [String: Any])
                if regiestBaseModel?.registerRData?.type == 1 {
                    let vc = UploadIDCardController()
                    vc.type = "1"
                    if (regiestBaseModel?.registerRData?.openId) != nil  {
                        vc.isThirdLogin = true
                    } else {
                        vc.isThirdLogin = false
                    }
                    vc.regiestBaseModel = regiestBaseModel
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = UploadIDCardController()
                    vc.type = "2"
                    if (regiestBaseModel?.registerRData?.openId) != nil  {
                        vc.isThirdLogin = true
                    } else {
                        vc.isThirdLogin = false
                    }
                    vc.regiestBaseModel = regiestBaseModel
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else if errorCode == "008" {
                self.noticeOnlyText("当前账号未注册！")
            }
            else if errorCode == "020" {
                
                let popup = PopupDialog(title: "提示", message: "已支付，请耐心等待审核!", tapGestureDismissal: false, panGestureDismissal: false)
                let sureBtn = AlertButton(title: "确定") {
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            else if errorCode == "21" {
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "资料已上传，请耐心等待审核！", tapGestureDismissal: false, panGestureDismissal: false)
                let sureBtn = AlertButton(title: "确定") {
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            } else if errorCode == "001" {
                self.noticeOnlyText("用户名或密码错误")
            } else if errorCode == "22" {
                self.clearAllNotice()
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                    let regiestDic = Utils.getReadDic(data: dataDic, field: "registerRData")
                    let regiestModel = Mapper<RegisterModel>().map(JSON: regiestDic as! [String: Any])
                    let vc = ServiceRegiestFailVC()
                    vc.regiestModel = regiestModel
                    vc.reason = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self.navigationController?.pushViewController(vc, animated: true)
            }
        }) { (error) in
            
        }
    }
    
    func getUserInfoRequest() {
        pleaseWait()
        YZBSign.shared.request(APIURL.getUserInfo, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
                UserData.shared.userInfoModel = infoModel
                if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                    if UserData.shared.workerModel?.jobType == 4 || UserData.shared.workerModel?.jobType == 999 {
                        AppUtils.setUserType(type: .cgy)
                    } else {
                        AppUtils.setUserType(type: .jzgs)
                    }
                }
                self.enterMainController()
            }
        }) { (error) in
            
        }
    }
    
    func enterMainController() {
        if let window = UIApplication.shared.keyWindow {
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = MainViewController()
                UIView.setAnimationsEnabled(oldState)
            })
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTF {
            if string.isNumber() || string.isLetter() || string.isEmpty {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
