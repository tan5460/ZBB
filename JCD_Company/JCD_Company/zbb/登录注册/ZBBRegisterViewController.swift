//
//  ZBBRegisterViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/9.
//

import UIKit
import ObjectMapper

class ZBBRegisterViewController: BaseViewController {

    private var gradientBackLayer: CAGradientLayer!
    private var logo: UIImageView!
    private var slogon: UIImageView!
    
    private var containerView: UIView!
    
    private var titleLabel: UILabel!
    private var loginBtn: UIButton!
    
    private var phoneLabel: UILabel!
    private var phoneTextField: UITextField!
    
    private var codeLabel: UILabel!
    private var codeTextField: UITextField!
    private var getCodeBtn: UIButton!
    
    private var secretLabel: UILabel!
    private var secretTextField: UITextField!
    
    private var sureSecretLabel: UILabel!
    private var sureSecretTextField: UITextField!
    
    private var registerBtn: UIButton!
    
    private var protocolLabel: UILabel!
    private var agreeBtn: UIButton!
    private var registerProtocolBtn: UIButton!
    private var privateProtocolBtn: UIButton!
    
    private var codeTime = 60
    private var timer: Timer?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRegisterBtnState), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func createViews() {
        view.backgroundColor = .white
        
        let topSpace = PublicSize.kNavBarHeight + 15 + 60 + 15 + 17 + 40
        
        gradientBackLayer = CAGradientLayer()
        gradientBackLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, topSpace + 20)
        gradientBackLayer.colors = [UIColor.hexColor("#E0F2F2").cgColor, UIColor.hexColor("#E1F2F0").cgColor, UIColor.hexColor("#E4F2E8").cgColor]
        gradientBackLayer.startPoint = .zero
        gradientBackLayer.endPoint = CGPointMake(0, 1)
        view.layer.addSublayer(gradientBackLayer)
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back_nav"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalTo(PublicSize.kStatusBarHeight)
            make.left.equalTo(0)
            make.width.height.equalTo(44)
        }
        
        logo = UIImageView(image: UIImage(named: "zbbt_logo"))
        view.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.top.equalTo(PublicSize.kNavBarHeight + 15)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        slogon = UIImageView(image: UIImage(named: "zbbt_slogon"))
        view.addSubview(slogon)
        slogon.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(192)
            make.height.equalTo(17)
        }
        
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(slogon.snp.bottom).offset(40)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        titleLabel = UILabel()
        titleLabel.text = "用户注册"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .hexColor("#007E41")
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.left.equalTo(25)
            make.height.equalTo(25)
        }
        
        let attrText = NSMutableAttributedString(string: "已有账号？去登录")
        attrText.addAttribute(.foregroundColor, value: UIColor.hexColor("#6F7A75"), range: NSMakeRange(0, 5))
        attrText.addAttribute(.foregroundColor, value: UIColor.hexColor("#007E41"), range: NSMakeRange(5, 3))
        loginBtn = UIButton(type: .custom)
        loginBtn.titleLabel?.font = .systemFont(ofSize: 15)
        loginBtn.setAttributedTitle(attrText, for: .normal)
        loginBtn.addTarget(self, action: #selector(loginBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-25)
            make.height.equalTo(30)
        }
        

        phoneLabel = UILabel()
        phoneLabel.text = "手机号"
        phoneLabel.font = .systemFont(ofSize: 14)
        phoneLabel.textColor = .hexColor("131313")
        containerView.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.left.equalTo(25)
            make.height.equalTo(20)
        }

        phoneTextField = UITextField()
        phoneTextField.font = .systemFont(ofSize: 14, weight: .medium)
        phoneTextField.textColor = .hexColor("#131313")
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "请输入手机号",
                                                                  attributes: [.font : UIFont.systemFont(ofSize: 14),
                                                                               .foregroundColor : UIColor.hexColor("#90AB9F")])
        phoneTextField.clearButtonMode = .whileEditing
        phoneTextField.keyboardType = .numberPad
        containerView.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { make in
            make.centerY.equalTo(phoneLabel)
            make.height.equalTo(50)
            make.left.equalTo(96)
            make.right.equalTo(-25)
        }
        
        let phoneLine = UIView()
        phoneLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(phoneLine)
        phoneLine.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(0.5)
        }

        codeLabel = UILabel()
        codeLabel.text = "验证码"
        codeLabel.font = .systemFont(ofSize: 14)
        codeLabel.textColor = .hexColor("131313")
        containerView.addSubview(codeLabel)
        codeLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneLine.snp.bottom).offset(15)
            make.left.equalTo(25)
            make.height.equalTo(20)
        }
        
        codeTextField = UITextField()
        codeTextField.font = .systemFont(ofSize: 14, weight: .medium)
        codeTextField.textColor = .hexColor("#131313")
        codeTextField.attributedPlaceholder = NSAttributedString(string: "请输入验证码",
                                                                  attributes: [.font : UIFont.systemFont(ofSize: 14),
                                                                               .foregroundColor : UIColor.hexColor("#90AB9F")])
        codeTextField.clearButtonMode = .whileEditing
        containerView.addSubview(codeTextField)
        codeTextField.snp.makeConstraints { make in
            make.centerY.equalTo(codeLabel)
            make.height.equalTo(50)
            make.left.equalTo(96)
            make.right.equalTo(-125)
        }
        
        getCodeBtn = UIButton(type: .custom)
        getCodeBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        getCodeBtn.setTitle("获取验证码", for: .normal)
        getCodeBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        getCodeBtn.setTitle("获取验证码(60)", for: .disabled)
        getCodeBtn.setTitleColor(.hexColor("#CCCCCC"), for: .disabled)
        getCodeBtn.addTarget(self, action: #selector(getCodeBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(getCodeBtn)
        getCodeBtn.snp.makeConstraints { make in
            make.centerY.equalTo(codeLabel)
            make.height.equalTo(50)
            make.width.equalTo(110)
            make.right.equalTo(-25)
        }
        
        let getCodeLine = UIView()
        getCodeLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(getCodeLine)
        getCodeLine.snp.makeConstraints { make in
            make.centerY.equalTo(codeLabel)
            make.height.equalTo(15)
            make.width.equalTo(0.5)
            make.right.equalTo(getCodeBtn.snp.left)
        }
        
        let codeLine = UIView()
        codeLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(codeLine)
        codeLine.snp.makeConstraints { make in
            make.top.equalTo(codeTextField.snp.bottom)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(0.5)
        }

        secretLabel = UILabel()
        secretLabel.text = "登录密码"
        secretLabel.font = .systemFont(ofSize: 14)
        secretLabel.textColor = .hexColor("131313")
        containerView.addSubview(secretLabel)
        secretLabel.snp.makeConstraints { make in
            make.top.equalTo(codeLine.snp.bottom).offset(15)
            make.left.equalTo(25)
            make.height.equalTo(20)
        }
        
        secretTextField = UITextField()
        secretTextField.font = .systemFont(ofSize: 14, weight: .medium)
        secretTextField.textColor = .hexColor("#131313")
        secretTextField.attributedPlaceholder = NSAttributedString(string: "8~16位数字、字母、符号中至少两种组成",
                                                                 attributes: [.font : UIFont.systemFont(ofSize: 14),
                                                                              .foregroundColor : UIColor.hexColor("#90AB9F")])
        secretTextField.clearButtonMode = .whileEditing
        secretTextField.isSecureTextEntry = true
        containerView.addSubview(secretTextField)
        secretTextField.snp.makeConstraints { make in
            make.centerY.equalTo(secretLabel)
            make.height.equalTo(50)
            make.left.equalTo(96)
            make.right.equalTo(-25)
        }
        
        let secretLine = UIView()
        secretLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(secretLine)
        secretLine.snp.makeConstraints { make in
            make.top.equalTo(secretTextField.snp.bottom)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(0.5)
        }

        sureSecretLabel = UILabel()
        sureSecretLabel.text = "确认密码"
        sureSecretLabel.font = .systemFont(ofSize: 14)
        sureSecretLabel.textColor = .hexColor("131313")
        containerView.addSubview(sureSecretLabel)
        sureSecretLabel.snp.makeConstraints { make in
            make.top.equalTo(secretLine.snp.bottom).offset(15)
            make.left.equalTo(25)
            make.height.equalTo(20)
        }
        
        sureSecretTextField = UITextField()
        sureSecretTextField.font = .systemFont(ofSize: 14, weight: .medium)
        sureSecretTextField.textColor = .hexColor("#131313")
        sureSecretTextField.attributedPlaceholder = NSAttributedString(string: "请确认密码",
                                                                   attributes: [.font : UIFont.systemFont(ofSize: 14),
                                                                                .foregroundColor : UIColor.hexColor("#90AB9F")])
        sureSecretTextField.clearButtonMode = .whileEditing
        sureSecretTextField.isSecureTextEntry = true
        containerView.addSubview(sureSecretTextField)
        sureSecretTextField.snp.makeConstraints { make in
            make.centerY.equalTo(sureSecretLabel)
            make.height.equalTo(50)
            make.left.equalTo(96)
            make.right.equalTo(-25)
        }
        
        let sureSecretLine = UIView()
        sureSecretLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(sureSecretLine)
        sureSecretLine.snp.makeConstraints { make in
            make.top.equalTo(sureSecretTextField.snp.bottom)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(0.5)
        }
        
        registerBtn = UIButton(type: .custom)
        registerBtn.isEnabled = false
        registerBtn.layer.cornerRadius = 25
        registerBtn.layer.masksToBounds = true
        registerBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        registerBtn.setTitle("注册", for: .normal)
        registerBtn.setTitleColor(.white, for: .normal)
        registerBtn.setBackgroundImage(UIImage(color: .hexColor("#7FBE9F"), size: CGSizeMake(1, 1)), for: .disabled)
        registerBtn.setBackgroundImage(UIImage(color: .hexColor("#007E41"), size: CGSizeMake(1, 1)), for: .normal)
        registerBtn.addTarget(self, action: #selector(registerBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(registerBtn)
        registerBtn.snp.makeConstraints { make in
            make.top.equalTo(sureSecretLine.snp.bottom).offset(30)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(50)
        }
        
        
        let attrProText = NSMutableAttributedString(string: "我已阅读并同意《注册协议》和《隐私政策》")
        attrProText.addAttribute(.foregroundColor, value: UIColor.hexColor("#999999"), range: NSMakeRange(0, attrProText.length))
        attrProText.addAttribute(.foregroundColor, value: UIColor.hexColor("#007E41"), range: NSMakeRange(7, 6))
        attrProText.addAttribute(.foregroundColor, value: UIColor.hexColor("#007E41"), range: NSMakeRange(attrProText.length - 6, 6))
        protocolLabel = UILabel()
        protocolLabel.attributedText = attrProText
        protocolLabel.font = .systemFont(ofSize: 12)
        containerView.addSubview(protocolLabel)
        protocolLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(15)
            make.bottom.equalTo(-15-PublicSize.kBottomOffset)
        }
        
        agreeBtn = UIButton(type: .custom)
        agreeBtn.setImage(UIImage(named: "zbbt_unselect"), for: .normal)
        agreeBtn.setImage(UIImage(named: "zbbt_select"), for: .selected)
        agreeBtn.addTarget(self, action: #selector(agreeBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(agreeBtn)
        agreeBtn.snp.makeConstraints { make in
            make.centerY.equalTo(protocolLabel)
            make.right.equalTo(protocolLabel.snp.left)
            make.width.height.equalTo(30)
        }
        
        registerProtocolBtn = UIButton(type: .custom)
        registerProtocolBtn.backgroundColor = .clear
        containerView.addSubview(registerProtocolBtn)
        registerProtocolBtn.addTarget(self, action: #selector(registerProtocolBtnAction(_:)), for: .touchUpInside)
        registerProtocolBtn.snp.makeConstraints { make in
            make.centerY.equalTo(protocolLabel)
            make.centerX.equalTo(protocolLabel).offset(4)
            make.height.equalTo(30)
            make.width.equalTo(65)
        }
        
        privateProtocolBtn = UIButton(type: .custom)
        privateProtocolBtn.backgroundColor = .clear
        privateProtocolBtn.addTarget(self, action: #selector(privateProtocolBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(privateProtocolBtn)
        privateProtocolBtn.snp.makeConstraints { make in
            make.centerY.equalTo(protocolLabel)
            make.right.equalTo(protocolLabel)
            make.height.equalTo(30)
            make.width.equalTo(65)
        }
    }

    //MARK: - Action
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
}


//MARK: - 

extension ZBBRegisterViewController {
    
    private func startCodeTimer() {
        codeTime = 60
        timer = Timer(timeInterval: 1, repeats: true) {[weak self] timer in
            self?.codeTime -= 1
            if (self?.codeTime ?? 0) <= 0 {
                self?.getCodeBtn.isEnabled = true
                self?.timer?.invalidate()
                self?.timer = nil
            } else {
                self?.getCodeBtn.setTitle("获取验证码(\(self?.codeTime ?? 0))", for: .disabled)
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
        timer?.fire()
    }
    
    @objc private func refreshRegisterBtnState() {
        if let phone = phoneTextField.text, phone.count > 0,
           let code = codeTextField.text, code.count > 0,
           let secret = secretTextField.text, secret.count > 0,
           let sureSecret = sureSecretTextField.text, sureSecret.count > 0 {
            registerBtn.isEnabled = true
        } else {
            registerBtn.isEnabled = true
        }
    }
    
    @objc private func loginBtnAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func getCodeBtnAction(_ sender: UIButton) {
        if Utils_objectC.isMobileNumber2(phoneTextField.text) {
            //手机号验证通过
            getCodeBtn.isUserInteractionEnabled = false
            requestGetSMSCode(phone: phoneTextField.text ?? "") {[weak self] isSuccess in
                self?.getCodeBtn.isUserInteractionEnabled = true
                if isSuccess {
                    self?.getCodeBtn.isEnabled = false
                    self?.startCodeTimer()
                }
            }
        } else {
            noticeOnlyText("手机号码有误")
        }
    }
    
    @objc private func registerBtnAction(_ sender: UIButton) {
        if !agreeBtn.isSelected {
            noticeOnlyText("请阅读并同意协议")
            return
        }
        if let phone = phoneTextField.text, let code = codeTextField.text, let secret = secretTextField.text, let sureSecret = sureSecretTextField.text {
            if secret.count < 8 || secret.count > 16 {
                noticeOnlyText("密码长度错误")
                return
            }
            if secret != sureSecret {
                noticeOnlyText("两次密码不一致")
                return
            }
            let predicate = NSPredicate(format: "SELF MATCHES %@", "^((?=.*[0-9])(?=.*[a-zA-Z])|(?=.*[0-9])(?=.*[^a-zA-Z0-9])|(?=.*[a-zA-Z])(?=.*[^a-zA-Z0-9])).+$")
            if !predicate.evaluate(with: secret) {
                noticeOnlyText("密码应由数字、字母、符号中至少两种组成")
                return
            }
            
            requestRegister(phone: phone, code: code, password: secret)
        }
    }
    
    @objc private func agreeBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func registerProtocolBtnAction(_ sender: UIButton) {
        let rootVC = AgreementViewController()
        let vc = BaseNavigationController.init(rootViewController: rootVC)
        rootVC.type = .protocl
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc private func privateProtocolBtnAction(_ sender: UIButton) {
        let rootVC = AgreementViewController()
        let vc = BaseNavigationController.init(rootViewController: rootVC)
        rootVC.type = .protocl1
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
}

extension ZBBRegisterViewController {
    
    ///获取验证码
    private func requestGetSMSCode(phone: String, completeClosure: ((_ isSuccess: Bool) -> Void)?) {
        YZBSign.shared.request(APIURL.getSMS + phone, method: .get, parameters: ["mobile" : phone]) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
            self?.noticeOnlyText(msg)
            completeClosure?(code == 0)
        } failure: { error in
            
        }
    }
    
    private func requestRegister(phone: String, code: String, password: String) {
        var parameters = Parameters()
        parameters["mobile"] = phone
        parameters["validateCode"] = code
        parameters["password"] = YZBSign.shared.passwordMd5(password: password)
        YZBSign.shared.request(APIURL.zbbRegister, method: .post, parameters: parameters) {[weak self] (response) in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let tokenModel = Mapper<TokenModel1>().map(JSON: dataDic as! [String: Any])
                UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel)
                UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel1)
                UserData1.shared.tokenModel = tokenModel
                let popDialog = PopupDialog(viewController: ZBBRegisterNoticeViewController(), transitionStyle: .zoomIn) {
                    self?.requestUserInfo()
                }
                self?.present(popDialog, animated: true)
            }
        } failure: { (error) in
            
        }
    }
    
    //获取用户信息
    private func requestUserInfo() {
        YZBSign.shared.request(APIURL.getUserInfo, method: .get) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                UserData.shared.userInfoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
                if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                    if UserData.shared.workerModel?.jobType == 4 || UserData.shared.workerModel?.jobType == 999 {
                        AppUtils.setUserType(type: .cgy)
                    } else {
                        AppUtils.setUserType(type: .jzgs)
                    }
                }
                self?.navigationController?.popToRootViewController(animated: true)
            }
        } failure: { error in
            
        }
    }
}
