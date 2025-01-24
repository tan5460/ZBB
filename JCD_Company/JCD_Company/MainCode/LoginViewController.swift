//
//  LoginViewController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/25.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PopupDialog
import IQKeyboardManagerSwift
import SwiftyJSON
import Stevia

enum LoginType: Int {
    
    case jzgs = 1            //会员
    case gys  = 2            //品牌商
    case yys  = 3            //城市分站
    case cgy  = 4            //采购员
    case fws  = 5            //服务商
}

class LoginViewController: BaseViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var topBgView: UIImageView!             //背景图片图片
    var backBtn: UIButton!                  //返回按钮
    var logoView: UIImageView!              //logo图片
    
    var passwordLoginBtn = UIButton()
    var codeLoginBtn = UIButton()
    var registerBtn: UIButton!              //注册
    var forgetPwBtn: UIButton!              //忘记密码
    var normalLoginView: UIView!            //普通登录界面
    var otherLoginView: UIView!             //验证码登录界面
    var accountField: UITextField!          //账号输入框
    var accounHistoryBtn: UIButton!         //历史账号按钮u
    var passwordField: UITextField!         //密码输入框
    var loginNormalBtn: UIButton!           //登录按钮
    var phoneField: UITextField!            //手机号输入框
    var phoneHistoryBtn: UIButton!          //历史手机按钮
    var vCodeBtn: UIButton!                 //获取验证码
    var verificationField: UITextField!     //验证码输入框
    var historyView: UIView!                //历史账号弹窗
    var tableView: UITableView!             //历史列表
    var rowsData: Array<String> = []        //历史数据
    var historyUser: Array<String> = []     //历史数据
    var historyTel: Array<String> = []      //历史数据
    let identifier = "historyCell"
    
    var verificationTimer: Timer!           //验证码定时器
    var timerCount: NSInteger!              //倒计时
    var codeKey = ""                        //验证码key
    var historyUserKey = ""                 //用户名缓存key
    var historyTelKey = ""                  //电话缓存key
    var isPaySuccess = false
    
    var isRememberPassword = true           //记住密码
    var rememberBtn: UIButton!
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>> 登录界面释放 <<<<<<<<<<<<<<<<<<")
    }
    
    var viewModel: LoginViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        switch UserData.shared.userType {
//        case .jzgs: self.title = "会员"
//        case .gys:  self.title = "品牌商"
//        case .yys:  self.title = "城市分站"
//        default: fatalError("error LoginType")
//        }
        
        prepareSubView()
        
        viewModel = LoginViewModel()
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.statusStyle = .lightContent
        UserDefaults.standard.removeObject(forKey: "VersionHintTime") // 进入登录页面再验证版本更新
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false // 控制点击背景是否收起键盘(影响historyView的点击事件)
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 150 //输入框距离键盘的距离
        
        if isPaySuccess == true {
            isPaySuccess = false
            let popup = PopupDialog(title: "提示", message: "支付结果查询可能会延迟，如支付成功但是仍无法登录，请稍等片刻后再尝试。", tapGestureDismissal: false, panGestureDismissal: false)
            let sureBtn = AlertButton(title: "确定") {
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.statusStyle = .default
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.isTranslucent = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true // 控制点击背景是否收起键盘
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 50 //输入框距离键盘的距离
    }
    
    
    private let containerView = UIView().backgroundColor(.white).cornerRadius(20).masksToBounds()
    func prepareSubView() {
        
        topBgView = UIImageView()
        topBgView.image = UIImage.init(named: "login_top_bg")
        topBgView.isUserInteractionEnabled = true
        view.addSubview(topBgView)
        topBgView.contentMode = .scaleAspectFill
        topBgView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            if PublicSize.isX {
                make.height.equalTo(549)
            }
            else {
                make.height.equalTo(423)
            }
        }
        
        //Logo
        logoView = UIImageView()
        logoView.image = UIImage.init(named: "yzb_logo")
        logoView.contentMode = .scaleAspectFit
        view.addSubview(logoView)
        
        logoView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            if PublicSize.isX {
                make.top.equalTo(50+PublicSize.kStatusBarHeight)
                make.width.height.equalTo(72)
            } else {
                make.top.equalTo(67)
                make.width.height.equalTo(60)
            }
            
        }
        
        
        view.sv(containerView)
        if PublicSize.isX {
            view.layout(
                151+PublicSize.kStatusBarHeight,
                |-20-containerView.height(460)-20-|,
                >=0
            )
        } else {
            view.layout(
                147,
                |-20-containerView.height(410)-20-|,
                >=0
            )
        }
        
        containerView.addShadowColor()
            
        let titles = ["密码登录", "验证码登录"]
        let w: CGFloat = (PublicSize.screenWidth - 40)/2
        
        var h: CGFloat = 102.5
        if !PublicSize.isX {
            h = 73
        }
        for (i,title) in titles.enumerated() {
            let btn = UIButton()
            btn.setTitle(title, for: .normal)
            btn.tag = 100 + i
            btn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x999999), for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.addTarget(self, action: #selector(switchAction(_:)), for: .touchUpInside)
            btn.frame = CGRect(x: (w)*CGFloat(i), y: 0, width: w, height: h)
            containerView.addSubview(btn)
            if i == 0 {
                btn.textColor(.k27A27D)
            }
            if UserData.shared.userType == .yys {
                btn.isHidden = true
            }
            if i == 0 {
                passwordLoginBtn = btn
            } else if i == 1 {
                codeLoginBtn = btn
            }
        }
        
        //普通登录、验证码登录、历史记录
        prepareNormalView()
        prepareOtherView()
        
        
        //登录
        loginNormalBtn = UIButton.init(type: .custom).backgroundColor(.k27A27D)
        loginNormalBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loginNormalBtn.layer.cornerRadius = 29.5
        loginNormalBtn.layer.masksToBounds = true
        loginNormalBtn.setTitle("登  录", for: .normal)
        loginNormalBtn.setTitleColor(.white, for: .normal)
        loginNormalBtn.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        containerView.addSubview(loginNormalBtn)
        
        loginNormalBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(-80.5)
            make.left.equalTo(27.5)
            make.right.equalTo(-27.5)
            make.height.equalTo(59)
        }
        
        
        //注册协议，隐私政策
        let agreeBtn = UIButton.init {  btn in
            print("点击了同意按钮")
            btn.isSelected = !btn.isSelected
        }
        agreeBtn.setImage(UIImage.init(named: "login_uncheck"), for: .normal)
        agreeBtn.setImage(UIImage.init(named: "login_check"), for: .selected)
        containerView.addSubview(agreeBtn)
        agreeBtn.snp.makeConstraints { make in
            make.bottom.equalTo(-20)
            make.left.equalTo(27.5)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        let agreeLab = UILabel.init(text: "我已阅读并同意").font(14)
        containerView.addSubview(agreeLab)
        agreeLab.snp.makeConstraints { make in
            make.left.equalTo(agreeBtn.snp_right).offset(0)
            make.centerY.equalTo(agreeBtn)
        }
        // 注册协议
        let zcxyBtn = UIButton.init(action: { btn in
            print("点击了注册协议")
        }).text("《注册协议》、").textColor(.k27A27D).font(14)
        containerView.addSubview(zcxyBtn)
        zcxyBtn.snp.makeConstraints { make in
            make.left.equalTo(agreeLab.snp_right).offset(5)
            make.centerY.equalTo(agreeLab)
        }
        // 隐私政策
        let yxzcBtn = UIButton.init(action: { btn in
            print("点击了隐私政策")
        }).text("《隐私政策》").textColor(.k27A27D).font(14)
        containerView.addSubview(yxzcBtn)
        yxzcBtn.snp.makeConstraints { make in
            make.left.equalTo(zcxyBtn.snp_right).offset(0)
            make.centerY.equalTo(agreeLab)
        }
        
        
        
        let loginBottomIV = UIImageView().image(#imageLiteral(resourceName: "login_bottom_bg"))
        view.sv(loginBottomIV)
        view.layout(
            >=0,
            |loginBottomIV.height(129)|,
            0
        )
        
        if (UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy) && UserData1.shared.isNew {
           let otherLoginLabel = UILabel().text("其他登录方式").textColor(.kColor99).font(12)
            let otherLoginLine1 = UIView().backgroundColor(UIColor.hexColor("#DEDEDE"))
            let otherLoginLine2 = UIView().backgroundColor(UIColor.hexColor("#DEDEDE"))
            let wechatBtn = UIButton().image(#imageLiteral(resourceName: "login_wechat"))
            let zfbBtn = UIButton().image(#imageLiteral(resourceName: "login_zfb"))
            registerBtn = UIButton(type: .custom)
            registerBtn.isHidden = true
            registerBtn.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
            view.sv(otherLoginLine1, otherLoginLabel, otherLoginLine2, wechatBtn, zfbBtn, registerBtn)
            var spaceH: CGFloat = 643.5-40+PublicSize.kStatusBarHeight
            if !PublicSize.isX {
                spaceH = 545.5
            }
            view.layout(
                spaceH,
                |-31.51-otherLoginLine1.height(0.5)-20-otherLoginLabel.width(74).height(16.5)-20-otherLoginLine2-31.51-|,
                23,
                |-((view.width-130)/2)-wechatBtn.size(40)-50-zfbBtn.size(40),
                15,
                registerBtn.height(30).centerHorizontally(),
                >=0
            )
            equal(sizes: otherLoginLine1, otherLoginLine2)
            wechatBtn.tapped { [weak self] (btn) in
                LDWechatShare.login({ (response) in
                    debugPrint(response)
                    self?.checkOpenId(response: response, type: 1)
                }) { (errorStr) in
                    self?.noticeOnlyText(errorStr)
                }
            }
            zfbBtn.tapped { [weak self] (btn) in
                
                self?.doAPAuth()
            }
        } else {
            registerBtn = UIButton(type: .custom)
            registerBtn.isHidden = true
            registerBtn.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
            view.sv(registerBtn)
            if !PublicSize.isX {
                view.layout(
                    663.5-80+PublicSize.kStatusBarHeight,
                    registerBtn.height(30).centerHorizontally(),
                    >=0
                )
            } else {
                view.layout(
                    663.5-50+PublicSize.kStatusBarHeight,
                    registerBtn.height(30).centerHorizontally(),
                    >=0
                )
            }
            
        }
        
        //注册
        let attributStr = NSMutableAttributedString.init()
        attributStr.append(NSAttributedString.init(string: "没有账号？", attributes: [NSAttributedString.Key.foregroundColor : UIColor.kColor99, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributStr.append(NSAttributedString.init(string: "立即注册", attributes: [NSAttributedString.Key.foregroundColor : UIColor.k27A27D, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        let regiestLab = UILabel().textAligment(.center)
        regiestLab.attributedText = attributStr
        registerBtn.sv(regiestLab)
        regiestLab.followEdges(registerBtn)
        
        if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy || UserData.shared.userType == .fws ||
        UserData.shared.userType == .gys {
            registerBtn.isHidden = false
        }
        //历史记录
        prepareHistoryView()
    }
    
    func checkOpenId(response: [String: Any], type: Int) {
        var parameters = Parameters()
        if type == 1 {
            parameters["openId"] = Utils.getReadString(dir: response as NSDictionary, field: "openid")
        } else {
            parameters["openId"] = Utils.getReadString(dir: response as NSDictionary, field: "alipay_open_id")
        }
        
        parameters["type"] = type
        YZBSign.shared.request(APIURL.checkOpenId, method: .get, parameters: parameters, success: { (res) in
            let code = Utils.getReadString(dir: res as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: res as AnyObject)
                let userInfoModel = Mapper<YZBUserInfoModel>().map(JSON: dataDic as! [String : Any])
                self.LoginFun(account: userInfoModel?.userName ?? "", password: userInfoModel?.password ?? "", type: 3)
            } else if code == "1" {
                let vc = RegiestBindPhoneVC()
                vc.bindPhoneBlock = { [weak self] (phone, password) in
                    self?.LoginFun(account: phone, password: password, type: 3)
                }
                vc.response = response
                vc.authLoginType = type
                self.navigationController?.pushViewController(vc)
            }
        }) { (error) in
            
        }
        
    }
    
    //MARK: - 点击支付宝授权登录
    func doAPAuth() {
        // 重要说明
        // 这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
        // 真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
        // 防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
        /*============================================================================*/
        /*=======================需要填写商户app申请的===================================*/
        /*============================================================================*/
        let pid = "2088531043674722"
        let appID = "2021002100637061"
        // 如下私钥，rsa2PrivateKey 或者 rsaPrivateKey 只需要填入一个
        // 如果商户两个都设置了，优先使用 rsa2PrivateKey
        // rsa2PrivateKey 可以保证商户交易在更加安全的环境下进行，建议使用 rsa2PrivateKey
        // 获取 rsa2PrivateKey，建议使用支付宝提供的公私钥生成工具生成，
        // 工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
        let rsaPrivateKey = "MIIEpQIBAAKCAQEA7EiqnhjjW33atw9N3N/ayX4YBpSkmNi7ROYexV6awbLqDy/vXKwfaIjDsGysIMKPgjgpPPZ+dAygBhe7s/QuzQqA7Sv79Is2urLz47u1eWXO8hxtILTjWkNq/noSgWzKBIAiiXoZghnfpKLC+v1XtbCZTDWlZZBh0U1Qyk7ANfcBYzq39jg9oPhHBa2qow+mWlCavM1zshLwCTMdfi4IUDYTv38XcJ9yJxHA4VJA+qfMwncAImKlGW6uor2xqkqd+9DTU5hu+S4ZJOWQ1E+2A3pby6EYtklD2p7ALAoTLL6Niy/glmKaGYg4UAqG+2ad4hn3sL1WAvFVCmkbFOONtQIDAQABAoIBAQC1vfsGWexfDkHx9mKUltapj0SZozGro2D/0OUwOOFeRejEv8EkDfymojOq+xu2oxBRQDNwAcUoLCHWLeEhvJtW+VJLmz5UTdRN7KGttE8UzltMXNMPijMp1Ztxm6GqTWxh49Es327JZG9iKhNBjSYuyWRQex76LQEgRZDz23j6x8WbQgRLXYQ4SQXcMtM5Z6cOOCk/RWXoBQ4uT2jA6gDge+ErTQqDfQ+5NlueDBBRN8pkGqOxjtdOtvsE0LpwzTZgfscacc4b0rRlg3xpWTTK7xonOf+MMQRmTaH73pG3n9WnE/T2XKlShQVBEhurlojHASktHnf1p3k4OS+o10mBAoGBAPysfgfbhMgVcSmyDV3kZICa9GwuYNnnqp5/fhVegTt24/MsomH3GBY6VT9F9xo7xkDsAG2Y8C9ojdDAZvLsPJ/Mn+c0QWOxU7k+WLioHUJ3c+OZU3X+hFRkWxJWT1Sw42TAkcYzbVjiCtqM8/WeR3MrT66Lh4kqgj/h4IHoDb3hAoGBAO9k8LQo+PHZ+Td0RvUYMoLsMQ2gG/WBZ6Rdn4Yt+NsyunITsky0FJhSS4GhVHdcEaV0OvuZWu6SFhM5Zm+sVnJE68lId0EAo4Vky9FT5bcTE8ZOfOmBaWNbGC47IiDbjoylAi3Qq3yWjTefVDI8UaZjESjmms9wni0DbaXGT8JVAoGBAKbm4dEa5disoTVjkYTFysVQlcen0v3dE0zi9kvzQvYekHAeuZxwdY6pNYo4EwNXHJvhyF6cuXr3W0Xa8aXg+iKsLauxTsglaCJi1oQTOFChSwG6U/ELECoWqDmynXBZ77qroR8E9WPS3EyE8tj5lkSzBU1MiVjHpYXBFGV6/SjBAoGADJZsKaz12hGyDv5oNL7++O9ebO78SV5yiqv5lV6ZdT0nnJP4jhvx8Uhye/B1toj6zI5eA5i+tUitLHmaL0kKipuhIkZTLvHPp1XzeaBFteik44qA+u45EmZZ0SR+2OdyiWarxKjyO2zXJBOWo8WULYGMB3CIt1uelZNWkp7o1rkCgYEA558QtbY9bLxRp9NxP8poc2TbAgVaACIUeY1Dtnpl1gVcl0YIi+PCB+6zgzua3Vq2BL+uk2xPd3HFOVEnoZB58BGjhpzO4e0nGfY565QCRF7T894ilmMnV9SbL/QmEv8Oww5S3G0YoS3RC6KdsR3nEXsVC1JnPhl7zTkQKbmHQGU="
        let authInfo = APAuthInfo()
        authInfo.pid = pid
        authInfo.appID = appID
        let authType = UserDefaults.standard.object(forKey: "authType")
        if (authType != nil) {
            authInfo.authType = authType as? String
        }
        var authInfoStr = authInfo.description
         // 获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
        var signedString: String?
        let signer = APRSASigner.init(privateKey: rsaPrivateKey)
        signedString = signer?.sign(authInfoStr, withRSA2: false)
        if signedString != nil {
            authInfoStr = "\(authInfoStr)&sign=\(signedString ?? "")&sign_type=RSA"
            debugPrint("authInfoStr =" + authInfoStr)
            
//            AlipaySDK.defaultService()?.auth_V2(withInfo: authInfoStr, fromScheme: "aliauth", callback: { (resp) in
//
//            })
            AliPayUtils.login(signStr: authInfoStr, aliAuthBack: self)
        } else {
            self.noticeOnlyText("支付宝签名失败")
        }
        
    }
    
    func prepareNormalView() {
        
        //普通登录
        normalLoginView = UIView()
        containerView.addSubview(normalLoginView)
        
        normalLoginView.snp.makeConstraints { (make) in
            if PublicSize.isX {
                make.top.equalTo(102.5)
            } else {
                make.top.equalTo(73)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(168)
        }
        
        let accountFieldBg = UIView().cornerRadius(29.5).masksToBounds().borderWidth(0.5).borderColor(.kColor99)
        let passwordFieldBg = UIView().cornerRadius(29.5).masksToBounds().borderWidth(0.5).borderColor(.kColor99)
        normalLoginView.sv(accountFieldBg, passwordFieldBg)
        if PublicSize.isX {
            normalLoginView.layout(
                10,
                |-27.5-accountFieldBg.height(59)-27.5-|,
                30,
                |-27.5-passwordFieldBg.height(59)-27.5-|,
                >=0
            )
        } else {
            normalLoginView.layout(
                10,
                |-27.5-accountFieldBg.height(59)-27.5-|,
                20,
                |-27.5-passwordFieldBg.height(59)-27.5-|,
                >=0
            )
        }
        
        //账号输入框
        accountField = UITextField()
        accountField.returnKeyType = .done
        accountField.delegate = self
        accountField.tag = 2001
        accountField.clearButtonMode = .whileEditing
        accountField.placeholder = "请输入账号/手机号"
        accountField.placeholderColor = .kColor99
        accountField.font = UIFont.systemFont(ofSize: 14)
        accountField.keyboardType = .numbersAndPunctuation
        accountField.addTarget(self, action: #selector(accountFieldDidChanged(_:)), for: .editingChanged)
        accountFieldBg.addSubview(accountField)
        
        accountField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(46)
            make.right.equalTo(-40)
            make.height.equalTo(59)
        }
        
        //修改清除按钮
        let clearBtn = accountField.value(forKey: "_clearButton") as! UIButton
        clearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框左侧视图
        let imgView = UIImageView()
        imgView.image = UIImage(named: "login_account")
        accountFieldBg.sv(imgView)
        accountFieldBg.layout(
            19.5,
            |-20-imgView.size(20),
            19.5
        )
        
        //输入框右侧按钮
        accounHistoryBtn = UIButton(type: .custom)
        accounHistoryBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        accounHistoryBtn.tag = 301
        accounHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        accounHistoryBtn.addTarget(self, action: #selector(showHistoryAction), for: .touchUpInside)
        accountFieldBg.addSubview(accounHistoryBtn)
        
        accounHistoryBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(accountField)
            make.right.equalTo(0)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        
        //密码输入框
        passwordField = UITextField()
        passwordField.returnKeyType = .done
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
        passwordField.clearButtonMode = .whileEditing
        passwordField.placeholder = "请输入密码"
        passwordField.font = UIFont.systemFont(ofSize: 14)
        passwordField.placeholderColor = .kColor99
        passwordField.keyboardType = .default
        passwordFieldBg.addSubview(passwordField)
        
        passwordField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(46)
            make.right.equalTo(-40)
            make.height.equalTo(59)
        }
        
        //修改清除按钮
        let pclearBtn = passwordField.value(forKey: "_clearButton") as! UIButton
        pclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框左侧视图
        let pimgView = UIImageView()
        pimgView.image = UIImage(named: "login_password")
        passwordFieldBg.sv(pimgView)
        passwordFieldBg.layout(
            19.5,
            |-20-pimgView.size(20),
            19.5
        )
        
        //输入框右侧按钮
        let showpwBtn = UIButton(type: .custom)
        showpwBtn.setImage(UIImage.init(named: "login_hidepw"), for: .normal)
        showpwBtn.setImage(UIImage.init(named: "login_showpw"), for: .selected)
        showpwBtn.addTarget(self, action: #selector(showPwAction(_:)), for: .touchUpInside)
        passwordFieldBg.addSubview(showpwBtn)
        
        showpwBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(passwordField)
            make.right.equalTo(0)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        
        
        //记住密码
        rememberBtn = UIButton(type: .custom)
        rememberBtn.setImage(UIImage.init(named: "login_uncheck"), for: .normal)
        rememberBtn.setImage(UIImage.init(named: "login_check"), for: .selected)
        rememberBtn.isSelected = true
        rememberBtn.setTitle(" 记住密码", for: .normal)
        rememberBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        rememberBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        rememberBtn.addTarget(self, action: #selector(rememberAction(_:)), for: .touchUpInside)
        normalLoginView.addSubview(rememberBtn)
        
        rememberBtn.snp.makeConstraints { (make) in
            make.top.equalTo(passwordField.snp.bottom).offset(10)
            make.left.equalTo(48.5)
        }
    }
    
    @objc func rememberAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        isRememberPassword = sender.isSelected
    }
    
    func prepareOtherView() {
        
        //验证码登录
        otherLoginView = UIView()
        otherLoginView.isHidden = true
        view.addSubview(otherLoginView)
        
        otherLoginView.snp.makeConstraints { (make) in
            make.edges.equalTo(normalLoginView)
        }
        
        let phoneFieldBg = UIView().cornerRadius(29.5).masksToBounds().borderWidth(0.5).borderColor(.kColor99)
        let verificationFieldBg = UIView().cornerRadius(29.5).masksToBounds().borderWidth(0.5).borderColor(.kColor99)
        otherLoginView.sv(phoneFieldBg, verificationFieldBg)
        otherLoginView.layout(
            10,
            |-27.5-phoneFieldBg.height(59)-27.5-|,
            30,
            |-27.5-verificationFieldBg.height(59)-27.5-|,
            >=0
        )
        
        //手机输入框
        phoneField = UITextField()
        phoneField.delegate = self
        phoneField.returnKeyType = .done
        phoneField.tag = 1001
        phoneField.layer.masksToBounds = true
        phoneField.clearButtonMode = .whileEditing
        phoneField.placeholder = "请输入手机号"
        phoneField.placeholderColor = .kColor99
        phoneField.font = UIFont.systemFont(ofSize: 14)
        phoneField.keyboardType = .phonePad
        phoneFieldBg.addSubview(phoneField)
        
        phoneField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(46)
            make.right.equalTo(-40)
            make.height.equalTo(59)
        }
        
        //修改清除按钮
        let clearBtn = phoneField.value(forKey: "_clearButton") as! UIButton
        clearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框左侧视图
        let imgView = UIImageView()
        imgView.image = UIImage(named: "login_phone_icon")
        phoneFieldBg.sv(imgView)
        phoneFieldBg.layout(
            19.5,
            |-20-imgView.size(20),
            19.5
        )
        
        //输入框右侧按钮
        phoneHistoryBtn = UIButton(type: .custom)
        phoneHistoryBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        phoneHistoryBtn.tag = 302
        phoneHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        phoneHistoryBtn.addTarget(self, action: #selector(showHistoryAction), for: .touchUpInside)
        phoneFieldBg.addSubview(phoneHistoryBtn)
        phoneHistoryBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(phoneField)
            make.right.equalTo(0)
            make.width.equalTo(40)
            make.height.equalTo(30)
        }
        
        
        //验证码输入框
        verificationField = UITextField()
        verificationField.delegate = self
        verificationField.returnKeyType = .done
        verificationField.tag = 1003
        verificationField.keyboardType = .numberPad
        verificationField.clearButtonMode = .whileEditing
        verificationField.placeholder = "请输入验证码"
        verificationField.font = phoneField.font
        verificationField.placeholderColor = .kColor99
        if #available(iOS 12.0, *) {
            verificationField.textContentType = .oneTimeCode
        }
        verificationFieldBg.addSubview(verificationField)
        
        verificationField.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(46)
            make.right.equalTo(-100)
            make.height.equalTo(59)
        }
        
        //修改清除按钮
        let vclearBtn = verificationField.value(forKey: "_clearButton") as! UIButton
        vclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框左侧视图
        let vimgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        vimgView.image = UIImage(named: "login_code_icon")
        verificationFieldBg.sv(vimgView)
        verificationFieldBg.layout(
            19.5,
            |-20-vimgView.size(20),
            19.5
        )
        
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = .kColor99
        verificationFieldBg.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(verificationField.snp.right)
            make.centerY.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(59)
        }
        
        //获取验证码
        vCodeBtn = UIButton.init(type: .custom)
        vCodeBtn.setTitle("获取验证码", for: .normal)
        vCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        vCodeBtn.setTitleColor(.k27A27D, for: .normal)
        vCodeBtn.setTitleColor(.kColor99, for: .highlighted)
        vCodeBtn.setTitleColor(.kColor99, for: .disabled)
        vCodeBtn.addTarget(self, action: #selector(getVCodeAction(_:)), for: .touchUpInside)
        verificationFieldBg.addSubview(vCodeBtn)
        
        vCodeBtn.snp.makeConstraints { (make) in
            make.top.height.right.equalToSuperview()
            make.left.equalTo(lineView.snp.right)
        }
    }
    
    func prepareHistoryView() {
        
        historyView = UIView()
        historyView.isHidden = true
        historyView.backgroundColor = .white
        historyView.layer.cornerRadius = 4
        historyView.layer.borderWidth = 1
        historyView.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xFFB89C).cgColor
        historyView.layerShadow(color: UIColor.colorFromRGB(rgbValue: 0xDC4D42), opacity: 0.6, radius: 5)
        view.addSubview(historyView)
        
        historyView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(134)
            make.top.equalTo(accountField.snp.bottom).offset(5)
        }
        
        //读取历史记录数据
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            historyUserKey = "jzgsLoginHistoryUser"
            historyTelKey = "jzgsLoginHistoryTel"
            
        case .gys:
            historyUserKey = "gysLoginHistoryUser"
            historyTelKey = "gysLoginHistoryTel"
            
        case .yys:
            historyUserKey = "yysLoginHistoryUser"
            historyTelKey = "yysLoginHistoryTel"
        case .fws:
            historyUserKey = "fwsLoginHistoryUser"
            historyTelKey = "fwsLoginHistoryTel"
        }
        
        if let userArray = UserDefaults.standard.object(forKey: historyUserKey) as? Array<String> {
            historyUser = userArray
        }
        
        if let telArray = UserDefaults.standard.object(forKey: historyTelKey) as? Array<String> {
            historyTel = telArray
        }
        
        
        
        if historyUser.count > 0 {
            accounHistoryBtn.isHidden = false
        }else {
            accounHistoryBtn.isHidden = true
        }
        if historyTel.count > 0 {
            phoneHistoryBtn.isHidden = false
        }else {
            phoneHistoryBtn.isHidden = true
        }
        
        //tableview
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 44
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.register(LoginHistoryCell.self, forCellReuseIdentifier: identifier)
        historyView.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(1)
            make.bottom.equalTo(-1)
            make.left.right.equalToSuperview()
        }
    }
    
    
    //MARK: - 按钮点击事件
    
    //账号输入框
    @objc func accountFieldDidChanged(_ textField: UITextField) {
        viewModel.accountFieldDidChange(text: textField.text)
    }
    
    //返回
    @objc func backAction(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    //注册
    @objc func registerAction() {
        let vc = RegisterViewController()
        vc.title = "注册"
        navigationController?.pushViewController(vc, animated: true)
//        if UserData.shared.userType == .fws {
//            let vc = ServiceRegiestSelectVC()
//            vc.title = "服务商注册"
//            navigationController?.pushViewController(vc, animated: true)
//        } else if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
//            let vc = ServiceRegiestSelectVC()
//            vc.title = "会员注册"
//            navigationController?.pushViewController(vc, animated: true)
//        } else if UserData.shared.userType == .gys {
//            let vc = PPSRegiestVC()
//            vc.title = "品牌商注册"
//            navigationController?.pushViewController(vc)
//        }
    }
    
    
    //密码是否可见
    @objc func showPwAction(_ sender:UIButton) {
        passwordField.isSecureTextEntry = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    //切换登录方式
    @objc func switchAction(_ sender:UIButton) {
        if sender.tag == passwordLoginBtn.tag {
            
            passwordLoginBtn.textColor(.k27A27D)
            codeLoginBtn.textColor(.kColor99)
        } else {
            passwordLoginBtn.textColor(.kColor99)
            codeLoginBtn.textColor(.k27A27D)
        }
        viewModel.switchAction(sender: sender)
    }
    
    //登录
    @objc func loginAction(_ sender: UIButton) {
        
        viewModel.login()
        
        if normalLoginView.isHidden {
            // 验证码登录
            if phoneField.text == "" {
                self.noticeOnlyText("请输入手机号")
                return
            }
            
            if !Utils_objectC.isMobileNumber2(phoneField.text) {
                
                self.noticeOnlyText("手机号码有误,请检查您输入的手机号是否正确!")
                return
            }
            
            if verificationField.text?.count != 6 {
                self.noticeOnlyText("请输入6位验证码")
                return
            }
            
            LoginFun(account: phoneField.text!, password: verificationField.text!, type: 2)
        }
        else {
            // 密码登录
            if accountField.text == "" {
                noticeOnlyText("请输入账号或手机号")
                return
            }
            if passwordField.text == "" {
                noticeOnlyText("请输入密码")
                return
            }
            LoginFun(account: accountField.text!, password: passwordField.text!, type: 1)
        }
    }
    
    //获取验证码
    @objc func getVCodeAction(_ sender: UIButton) {
        
        if phoneField.text == "" {
            self.noticeOnlyText("请输入手机号")
            return
        }
        
        //验证码置空
        verificationField.text = ""
        
        if Utils_objectC.isMobileNumber2(phoneField.text) {
            
            verificationField.becomeFirstResponder()
            vCodeBtn.isEnabled = false
            sendSMSCode()
        }
        else{
            self.noticeOnlyText("手机号码有误,请检查您输入的手机号是否正确!")
        }
    }
    
    //显示历史账号
    @objc func showHistoryAction(_ sender: UIButton) {
        
        var isShow = true
        if !historyView.isHidden {
            isShow = false
        }
        
        if sender.tag == 301 {
            accountField.becomeFirstResponder()
        }else {
            phoneField.becomeFirstResponder()
        }
        
        if isShow {
            historyView.isHidden = false
            accounHistoryBtn.setImage(UIImage.init(named: "login_up"), for: .normal)
            phoneHistoryBtn.setImage(UIImage.init(named: "login_up"), for: .normal)
            
            if normalLoginView.isHidden {
                rowsData = historyTel
            }else {
                rowsData = historyUser
            }
            tableView.reloadData()
        }
        else {
            historyView.isHidden = true
            accounHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
            phoneHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        }
    }
    
    //查询历史记录
    func showQueryHistory(queryStr: String) {
        
        var historyArray: Array<String> = []
        
        if normalLoginView.isHidden {
            historyArray = historyTel
        }else {
            historyArray = historyUser
        }
        
        rowsData.removeAll()
        for tel in historyArray {
            if tel.range(of: queryStr) != nil {
                rowsData.append(tel)
            }
        }
        
        if rowsData.count > 0 {
            tableView.reloadData()
            historyView.isHidden = false
            accounHistoryBtn.setImage(UIImage.init(named: "login_up"), for: .normal)
            phoneHistoryBtn.setImage(UIImage.init(named: "login_up"), for: .normal)
        }else {
            historyView.isHidden = true
            accounHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
            phoneHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        }
    }
    
    /// 更新本地缓存
    func updateHistory(_ account: String) {
        
        //缓存手机号到历史记录
        if Utils_objectC.isMobileNumber2(account) {
            
            if let index = historyTel.firstIndex(of: account) {
                historyTel.remove(at: index)
            }
            
            if historyTel.count >= 10 {
                historyTel.remove(at: 9)
            }
            historyTel.insert(account, at: 0)
            UserDefaults.standard.set(historyTel, forKey: historyTelKey)
            
        }
        
        if let index = historyUser.firstIndex(of: account) {
            historyUser.remove(at: index)
        }
        
        if historyUser.count >= 10 {
            historyUser.remove(at: 9)
        }
        historyUser.insert(account, at: 0)
        UserDefaults.standard.set(historyUser, forKey: historyUserKey)
        
        
        if historyUser.count > 0 {
            accounHistoryBtn.isHidden = false
        }else {
            accounHistoryBtn.isHidden = true
        }
        if historyTel.count > 0 {
            phoneHistoryBtn.isHidden = false
        }else {
            phoneHistoryBtn.isHidden = true
        }
        
    }
    /// 删除记录
    func deleteHistory(_ account: String) {
        
        if let index = historyUser.firstIndex(of: account) {
            historyUser.remove(at: index)
        }
        UserDefaults.standard.set(historyUser, forKey: historyUserKey)
        
        if Utils_objectC.isMobileNumber2(account) {
            
            if let index = historyTel.firstIndex(of: account) {
                historyTel.remove(at: index)
            }
            
            UserDefaults.standard.set(historyTel, forKey: historyTelKey)
        }
        if historyUser.count > 0 {
            accounHistoryBtn.isHidden = false
        }else {
            accounHistoryBtn.isHidden = true
        }
        if historyTel.count > 0 {
            phoneHistoryBtn.isHidden = false
        }else {
            phoneHistoryBtn.isHidden = true
        }
        
        if let index = rowsData.firstIndex(of: account) {
            rowsData.remove(at: index)
        }
        
        if rowsData.count > 0 {
            tableView.reloadData()
            historyView.isHidden = false
            accounHistoryBtn.setImage(UIImage.init(named: "login_up"), for: .normal)
            phoneHistoryBtn.setImage(UIImage.init(named: "login_up"), for: .normal)
        }else {
            tableView.reloadData()
            historyView.isHidden = true
            accounHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
            phoneHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        }
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
        
        let parameters: Parameters = ["mobile": phoneField.text!]
        let urlStr = APIURL.getSMS + phoneField.text!
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
    
    //登录
    func LoginFun(account: String, password: String="", type: Int=1) {  // 1 密码登录， 2 验证码登录 3: 绑定手机后回调
            
        
        
        let deviceName: String = String.init(format: "%@", UIDevice.current.model)
        var parameters: Parameters = ["deviceType": "1", "deviceId": UserData.shared.registrationId, "deviceSystem": UIDevice.current.systemVersion, "deviceName": deviceName, "appVersion": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String]
        if type == 1 {
            parameters["username"] = account
            parameters["password"] = YZBSign.shared.passwordMd5(password: password)
        }
        else if type == 2 {
            parameters["mobile"] = account
            parameters["randCode"] = password
        } else if type == 3 {
            parameters["username"] = account
            parameters["password"] = password
        }
        parameters["fromType"] = "APP"
        
        self.pleaseWait()
        
        let urlStr = APIURL.login
        if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            parameters["type"] = 5
        }
        if UserData.shared.userType == .gys {
            parameters["type"] = 4
        }
        if UserData.shared.userType == .yys {
            parameters["type"] = 1
        }
        if UserData.shared.userType == .fws {
            parameters["type"] = 6
        }
        
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                if type != 3 {
                    self.updateHistory(account)
                    if self.isRememberPassword {
                        if var passDic = UserDefaults.standard.object(forKey: "RememberPassword") as? [String:String]{
                            passDic[account] = password
                            UserDefaults.standard.set(passDic, forKey: "RememberPassword")
                        }else {
                            let passDic = [account:password]
                            UserDefaults.standard.set(passDic, forKey: "RememberPassword")
                        }
                    }
                }
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let tokenModel = Mapper<TokenModel1>().map(JSON: dataDic as! [String: Any])
                UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel)
                UserData1.shared.tokenModel = tokenModel
                self.getUserInfoRequest()
            } else if errorCode == "401" {
                self.notice("您的账号已在另一台设备中登录，如非本人操作，则密码可能已经泄露，建议立即修改密码。", autoClear: true, autoClearTime: 3)
            }
            else if errorCode == "23" {
                if UserData.shared.userType == .fws {
                    let dataDic = Utils.getReqDir(data: response as AnyObject)
                    let regiestModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String: Any])
                    if regiestModel?.serviceType == 5 {
                        let vc = ServiceRegiestWorkerVC()
                        vc.regiestId = regiestModel?.id
                        self.navigationController?.pushViewController(vc)
                    } else if regiestModel?.serviceType == 6 {
                        let vc = ServiceRegiestDesignVC()
                        vc.regiestId = regiestModel?.id
                        self.navigationController?.pushViewController(vc)
                    } else if regiestModel?.serviceType == 7 {
                        let vc = ServiceRegiestForemanVC()
                        vc.regiestId = regiestModel?.id
                        self.navigationController?.pushViewController(vc)
                    }
                } else if  UserData.shared.userType == .gys {
                    let dataDic = Utils.getReqDir(data: response as AnyObject)
                    
                    let regiestBaseModel = RegisterBaseModel()
                    let regiestModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String: Any])
                    regiestBaseModel.registerRData = regiestModel
                    let vc = PPSRegiestSecondVC()
                    vc.regiestBaseModel = regiestBaseModel
                    self.navigationController?.pushViewController(vc, animated: true)
                } else if  UserData.shared.userType == .yys {
                    let alert = UIAlertController.init(title: "提示", message: "您的资料不全，请使用电脑访问网站补全资料信息", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (aciton) in
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
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

            }
            else if errorCode == "008" {
                self.noticeOnlyText("当前账号未注册！")
            }
            else if errorCode == "30" {
                UIApplication.shared.keyWindow?.endEditing(true)
                self.updateHistory(account)
                self.clearAllNotice()
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let tokenModel = Mapper<TokenModel1>().map(JSON: dataDic as! [String: Any])
                UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel)
                UserData1.shared.tokenModel = tokenModel
                let userId = tokenModel?.userId ?? ""
                let substationId = tokenModel?.substationId ?? ""
                let popup = PopupDialog(title: "提示", message: "您的公司会员已过期，是否续费会员", buttonAlignment: .horizontal, tapGestureDismissal: false, panGestureDismissal: false)
                
                let sureBtn = AlertButton(title: "续费") {
                    let vc = MembershipLevelsVC()
                    vc.substationId = substationId
                    vc.userId = userId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                let cancel = CancelButton(title: "确定") {
                }
                popup.addButtons([cancel,sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            else if errorCode == "31" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let tokenModel = Mapper<TokenModel1>().map(JSON: dataDic as! [String: Any])
                UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel)
                UserData1.shared.tokenModel = tokenModel
                UIApplication.shared.keyWindow?.endEditing(true)
                self.updateHistory(account)
                self.clearAllNotice()
                let substationId = dataDic["substationId"] as! String
                let userId = dataDic["userId"] as! String
                let popup = PopupDialog(title: "提示", message: "是否现在申请开通会员", buttonAlignment: .horizontal, tapGestureDismissal: false, panGestureDismissal: false)
                
                let sureBtn = AlertButton(title: "开通会员") {
                    UserData.shared.userInfoModel?.yzbVip = nil
                    let vc = MembershipLevelsVC()
                    vc.openMembershipSusccess = { [weak self] in
                        self?.LoginFun(account: account, password: password, type: type)
                    }
                    vc.substationId = substationId
                    vc.userId = userId
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                let cancel = CancelButton(title: "取消") {
                }
                popup.addButtons([cancel, sureBtn])
                self.present(popup, animated: true, completion: nil)
            }else if errorCode == "020" {
                
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
                
                if UserData.shared.userType == .fws {
                    let regiestModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String: Any])
                    let vc = ServiceRegiestFailVC()
                    vc.regiestModel = regiestModel
                    vc.reason = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else if UserData.shared.userType == .gys {
                    let regiestModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String: Any])
                    let vc = ServiceRegiestFailVC()
                    vc.regiestModel = regiestModel
                    vc.reason = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else if  UserData.shared.userType == .yys {
                    let alert = UIAlertController.init(title: "提示", message: "您的审核未通过，请使用电脑访问网站进行修改", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "好的", style: .default, handler: { (aciton) in
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let regiestDic = Utils.getReadDic(data: dataDic, field: "registerRData")
                    let regiestModel = Mapper<RegisterModel>().map(JSON: regiestDic as! [String: Any])
                    let vc = ServiceRegiestFailVC()
                    vc.regiestModel = regiestModel
                    vc.reason = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
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
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! LoginHistoryCell
        
        if indexPath.row < rowsData.count {
            
            cell.titleLabel?.text = rowsData[indexPath.row]
            
            cell.deleteBlock = { [weak self] (rowText) in
                self?.deleteHistory(rowText)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if normalLoginView.isHidden {
            phoneField.text = rowsData[indexPath.row]
            verificationField.becomeFirstResponder()
        }else {
            accountField.text = rowsData[indexPath.row]
            if let passDic = UserDefaults.standard.object(forKey: "RememberPassword") as? [String:String]{
                passwordField.text = passDic[accountField.text ?? ""]
            }else {
                
                passwordField.becomeFirstResponder()
            }
        }
        
        historyView.isHidden = true
        accounHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        phoneHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
    }
    
    
    //MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if  textField.tag == 1001 {
            //手机号只允许输入数字
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if newString.count > 11 {
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
            else {
                showQueryHistory(queryStr: newString)
                return true
            }
        }
        else if textField.tag == 2001 {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            showQueryHistory(queryStr: newString)
        }else if textField.tag == 1003 {
            
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if newString.count > 6{
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.tag == 2001 || textField.tag == 1001 {
            if textField.text != "" {
                showQueryHistory(queryStr: textField.text!)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        historyView.isHidden = true
        accounHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        phoneHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
    }
    
}
// MARK - LoginViewModelDelegate
extension LoginViewController: LoginViewModelDelegate {
    
    func reloadViews() {
        
    }
    
    func moveToHomeScreen() {
        
    }
    
    func reloadSwitchViews(sender: UIButton) {
        
        UIApplication.shared.keyWindow?.endEditing(true)
        
        historyView.isHidden = true
        accounHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        phoneHistoryBtn.setImage(UIImage.init(named: "login_down"), for: .normal)
        
        normalLoginView.isHidden = !viewModel.normalViewEnable
        otherLoginView.isHidden  = !viewModel.otherViewEnable
    }
}

extension LoginViewController: AliPayBack {
    func finish(_ result: String?) {
        let resultArr = result?.components(separatedBy: "&")
        resultArr?.forEach({ (str) in
            if str.length > 15 && str.hasPrefix("alipay_open_id=") {
                var parameters = Parameters()
                parameters["alipay_open_id"] = str.subString(from: 15)
                checkOpenId(response: parameters, type: 2)
            }
        })
        
        
    }
    
    func failed() {
        
    }
    
    
}




