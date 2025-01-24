//
//  LoginCodeVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/18.
//

import UIKit
import ObjectMapper

class LoginCodeVC: BaseViewController {
    var mobile: String = ""
    private var verificationTimer: Timer?           //验证码定时器
    private var timerCount: Int?              //倒计时
    private var validCode: String?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private let codeView = TDWVerifyCodeView.init(inputTextNum: 6)
    private let lab3 = UIButton().text("60s后重新获取验证码").textColor(.kColor66).font(14)
    private let lab4 = UILabel().text("该手机号未注册，输入验证码后自动注册").textColor(.kColor99).font(12)
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
        let lab1 = UILabel().text("请输入验证码").textColor(.kColor33).fontBold(24)
        let lab2 = UILabel().text("验证码已发至+86 \(mobile)").textColor(.kColor33).font(16)
        
        let sureBtn = UIButton().text("确定").textColor(.white).font(16)
        
        
        view.sv(backBtn, lab1, lab2, lab3, codeView, lab4, sureBtn)
        view.layout(
            PublicSize.kStatusBarHeight,
            |backBtn.size(44),
            30.5,
            |-30-lab1.height(33.5),
            20,
            |-30-lab2.height(22.5),
            30,
            |-30-lab3.height(20),
            20,
            |codeView.height(40)|,
            10,
            |-30-lab4.height(16.5),
            30,
            |-30-sureBtn.height(50)-30-|,
            >=0
        )
        
        configCodeView()
        sureBtn.corner(radii: 4).fillGreenColorLF()
        
        backBtn.tapped { [weak self] (tapBtn) in
            self?.navigationController?.popViewController()
        }
        lab3.tapped { [weak self] (tapBtn) in
            self?.sendSMSCode()
        }
        sureBtn.tapped { [weak self] (tapBtn) in
            if self?.isRegiest ?? false {
                self?.login()
            } else {
                self?.checkValidCodeRequest()
            }
             
        }
        validMobile()
    }
    
    
    func checkValidCodeRequest() {
        guard let code = validCode, code.count == 6  else {
            noticeOnlyText("请输入正确验证码")
            return
        }
        var parameters = Parameters()
        parameters["mobile"] = mobile
        parameters["validateCode"] = code
        YZBSign.shared.request(APIURL.checkValidateCode, method: .post, parameters: parameters, success: { (res) in
            let code = Utils.getReadString(dir: res as NSDictionary, field: "code")
            if code == "0" {
                self.enterBaseInfoVC()
            }
        }) { (error) in
        }
    }
    
    func enterBaseInfoVC() {
        let vc = RegiestBaseInfoVC()
        vc.phone = mobile
        vc.validCode = validCode
        navigationController?.pushViewController(vc)
    }
    
    //MARK: - 定时器
    @objc func verificationWait() {
        var str: String
        if timerCount ?? 0 <= 0 {
            str = "获取验证码"
            lab3.isUserInteractionEnabled = true
            if let timer = verificationTimer {
                if timer.isValid {
                    verificationTimer?.invalidate()
                }
            }
            lab3.textColor(.k1DC597)
        }else {
            lab3.isUserInteractionEnabled = false
            timerCount = (timerCount ?? 0) - 1
            str = "\(String(timerCount ?? 0))s后重新获取验证码"
            lab3.textColor(.kColor66)
        }
        lab3.text(str)
    }
    private var isRegiest: Bool? = false
    //MARK: - 验证手机号
    func validMobile() {
        var parameters = Parameters()
        parameters["mobile"] = mobile
        parameters["type"] = "5"
        YZBSign.shared.request(APIURL.checkMobileV2, method: .get, parameters: parameters, success: { (res) in
            let code = Utils.getReadString(dir: res as NSDictionary, field: "code")
            if code == "0" {
                self.isRegiest = res["data"] as? Bool
                if self.isRegiest ?? false {
                    self.lab4.isHidden = true
                } else {
                    self.lab4.isHidden = false
                }
            }
            self.sendSMSCode()
        }) { (error) in
            self.sendSMSCode()
        }
    }
    
    
    //MARK: - 发送短信验证码
    func sendSMSCode() {
        let parameters: Parameters = ["mobile": mobile]
        let urlStr = APIURL.getSMS + mobile
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self.noticeOnlyText(msg)
                self.timerCount = 60
                if let timer = self.verificationTimer {
                    if timer.isValid {
                        timer.invalidate()
                    }
                }
                self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.verificationWait), userInfo: nil, repeats: true)
            } else{
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self.noticeOnlyText(msg)
                self.lab3.isUserInteractionEnabled = true
                self.lab3.text("\(String(self.timerCount ?? 0))s后重新获取验证码")
                self.lab3.setTitle("获取验证码", for: .normal)
                if let timer = self.verificationTimer {
                    if timer.isValid {
                        self.verificationTimer?.invalidate()
                    }
                }
            }
            
        }) { (error) in
            self.lab3.isUserInteractionEnabled = true
            self.lab3.text("获取验证码").textColor(.k1DC597)
            if let timer = self.verificationTimer {
                if timer.isValid {
                    self.verificationTimer?.invalidate()
                }
            }
        }
    }
    
    //MARK: - 手机验证码登录
    func login() {
        guard let code = validCode, code.count == 6  else {
            noticeOnlyText("请输入正确验证码")
            return
        }
        pleaseWait()
        let deviceName: String = String.init(format: "%@", UIDevice.current.model)
        var parameters: Parameters = ["deviceType": "1", "deviceId": UserData.shared.registrationId, "deviceSystem": UIDevice.current.systemVersion, "deviceName": deviceName, "appVersion": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String]
        parameters["mobile"] = mobile
        parameters["randCode"] = code
        parameters["type"] = 5
        parameters["fromType"] = "APP"
        parameters["flag"] = "2"
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
    func configCodeView() {
        
        codeView.textFiled.becomeFirstResponder()
        
        // 监听验证码输入的过程
        codeView.textValueChange = { [weak self] str in
            // 要做的事情
            self?.validCode = str
        }
//        // 监听验证码输入完成
//        codeView.inputFinish = { [weak self] str in
//            // 要做的事情
//        }
    }
    
    deinit {
        self.verificationTimer?.invalidate()
    }

}
