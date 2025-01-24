//
//  ZBBLoginViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/9.
//

import UIKit
import JXSegmentedView
import ObjectMapper

class ZBBLoginViewController: BaseViewController {
    
    private var gradientBackLayer: CAGradientLayer!
    private var logo: UIImageView!
    private var slogon: UIImageView!
    
    private var containerView: UIView!
    
    private var typeBackIcon: UIImageView!
    private var typeFrontIcon: UIImageView!
    private var segmentDataSource: JXSegmentedTitleDataSource!
    private var segmentView: JXSegmentedView!
    
    private var phoneTextField: UITextField!
    private var secretTextField: UITextField!
    
    private var codeView: UIView!
    private var codeTextField: UITextField!
    private var getCodeBtn: UIButton!
    
    private var loginBtn: UIButton!
    
    private var registerBtn: UIButton!
    
    private var protocolLabel: UILabel!
    private var agreeBtn: UIButton!
    private var registerProtocolBtn: UIButton!
    private var privateProtocolBtn: UIButton!
    
    private var isHideNavigationBar = true
    private var codeTime = 60
    private var timer: Timer?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        isHideNavigationBar = navigationController?.isNavigationBarHidden ?? true
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLoginBtnState), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isHideNavigationBar {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isHideNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    private func createViews() {
        
        gradientBackLayer = CAGradientLayer()
        gradientBackLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        gradientBackLayer.colors = [UIColor.hexColor("#E7F5F5").cgColor, UIColor.hexColor("#E4F8EA").cgColor]
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
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-15-PublicSize.kBottomOffset)
        }
        
        typeBackIcon = UIImageView(image: UIImage(named: "zbbt_login_right_unselect"))
        containerView.addSubview(typeBackIcon)
        typeBackIcon.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(50);
        }
        
        typeFrontIcon = UIImageView(image: UIImage(named: "zbbt_login_left_select"))
        containerView.addSubview(typeFrontIcon)
        typeFrontIcon.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(50);
        }
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 3
        indicator.indicatorCornerRadius = 1.5
        indicator.verticalOffset = 6
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 1.5
        gradientLayer.masksToBounds = true
        gradientLayer.frame = CGRectMake(0, 0, 20, 3)
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 0)
        gradientLayer.colors = [UIColor.hexColor("#47DC94").cgColor, UIColor.hexColor("#007E41").cgColor]
        indicator.layer.addSublayer(gradientLayer)
        
        segmentDataSource = JXSegmentedTitleDataSource()
        segmentDataSource.titles = ["密码登录", "验证码登录"]
        segmentDataSource.titleNormalFont = .systemFont(ofSize: 16)
        segmentDataSource.titleNormalColor = .hexColor("#666666")
        segmentDataSource.titleSelectedFont = .systemFont(ofSize: 16, weight: .medium)
        segmentDataSource.titleSelectedColor = .hexColor("#131313")
        segmentDataSource.isTitleColorGradientEnabled = true
        
        segmentView = JXSegmentedView()
        segmentView.backgroundColor = .clear
        segmentView.delegate = self
        segmentView.dataSource = segmentDataSource
        segmentView.indicators = [indicator]
        containerView.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(-15)
            make.right.equalTo(15)
            make.height.equalTo(50)
        }
        
        phoneTextField = UITextField()
        phoneTextField.layer.cornerRadius = 25
        phoneTextField.layer.masksToBounds = true
        phoneTextField.backgroundColor = .hexColor("#F3F9F6")
        phoneTextField.font = .systemFont(ofSize: 15, weight: .medium)
        phoneTextField.textColor = .hexColor("#131313")
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "请输入手机号",
                                                                  attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium),
                                                                               .foregroundColor : UIColor.hexColor("#90AB9F")])
        phoneTextField.leftView = UIView(frame: CGRectMake(0, 0, 20, 50))
        phoneTextField.leftViewMode = .always
        phoneTextField.clearButtonMode = .whileEditing
        phoneTextField.keyboardType = .numberPad
        containerView.addSubview(phoneTextField)
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(typeBackIcon.snp.bottom).offset(30)
            make.height.equalTo(50)
            make.left.equalTo(25)
            make.right.equalTo(-25)
        }
        
        secretTextField = UITextField()
        secretTextField.layer.cornerRadius = 25
        secretTextField.layer.masksToBounds = true
        secretTextField.backgroundColor = .hexColor("#F3F9F6")
        secretTextField.font = .systemFont(ofSize: 15, weight: .medium)
        secretTextField.textColor = .hexColor("#131313")
        secretTextField.attributedPlaceholder = NSAttributedString(string: "请输入密码",
                                                                   attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium),
                                                                                .foregroundColor : UIColor.hexColor("#90AB9F")])
        secretTextField.leftView = UIView(frame: CGRectMake(0, 0, 20, 50))
        secretTextField.leftViewMode = .always
        secretTextField.clearButtonMode = .whileEditing
        secretTextField.isSecureTextEntry = true
        containerView.addSubview(secretTextField)
        secretTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(15)
            make.height.equalTo(50)
            make.left.equalTo(25)
            make.right.equalTo(-25)
        }
        
        codeView = UIView()
        codeView.isHidden = true
        codeView.layer.cornerRadius = 25
        codeView.layer.masksToBounds = true
        codeView.backgroundColor = .hexColor("#F3F9F6")
        containerView.addSubview(codeView)
        codeView.snp.makeConstraints { make in
            make.edges.equalTo(secretTextField)
        }
        
        codeTextField = UITextField()
        codeTextField.font = .systemFont(ofSize: 15, weight: .medium)
        codeTextField.textColor = .hexColor("#131313")
        codeTextField.attributedPlaceholder = NSAttributedString(string: "请输入验证码",
                                                                 attributes: [.font : UIFont.systemFont(ofSize: 15, weight: .medium),
                                                                              .foregroundColor : UIColor.hexColor("#90AB9F")])
        codeTextField.leftView = UIView(frame: CGRectMake(0, 0, 20, 50))
        codeTextField.leftViewMode = .always
        codeTextField.clearButtonMode = .whileEditing
        codeTextField.keyboardType = .numberPad
        codeView.addSubview(codeTextField)
        codeTextField.snp.makeConstraints { make in
            make.top.left.bottom.equalTo(0)
            make.right.equalTo(-140)
        }
        
        getCodeBtn = UIButton(type: .custom)
        getCodeBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        getCodeBtn.setTitle("获取验证码", for: .normal)
        getCodeBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        getCodeBtn.setTitle("获取验证码(60)", for: .disabled)
        getCodeBtn.setTitleColor(.hexColor("#CCCCCC"), for: .disabled)
        getCodeBtn.addTarget(self, action: #selector(getCodeBtnAction(_:)), for: .touchUpInside)
        codeView.addSubview(getCodeBtn)
        getCodeBtn.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(0)
            make.left.equalTo(codeTextField.snp.right)
        }
        
        
        loginBtn = UIButton(type: .custom)
        loginBtn.isEnabled = false
        loginBtn.layer.cornerRadius = 25
        loginBtn.layer.masksToBounds = true
        loginBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        loginBtn.setTitle("登录", for: .normal)
        loginBtn.setTitleColor(.white, for: .normal)
        loginBtn.setBackgroundImage(UIImage(color: .hexColor("#7FBE9F"), size: CGSizeMake(1, 1)), for: .disabled)
        loginBtn.setBackgroundImage(UIImage(color: .hexColor("#007E41"), size: CGSizeMake(1, 1)), for: .normal)
        loginBtn.addTarget(self, action: #selector(loginBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { make in
            make.top.equalTo(secretTextField.snp.bottom).offset(15)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(50)
        }
        
        let attrText = NSMutableAttributedString(string: "没有账号？点击注册")
        attrText.addAttribute(.foregroundColor, value: UIColor.hexColor("#6F7A75"), range: NSMakeRange(0, 5))
        attrText.addAttribute(.foregroundColor, value: UIColor.hexColor("#007E41"), range: NSMakeRange(attrText.length - 4, 4))
        registerBtn = UIButton(type: .custom)
        registerBtn.titleLabel?.font = .systemFont(ofSize: 15)
        registerBtn.setAttributedTitle(attrText, for: .normal)
        registerBtn.addTarget(self, action: #selector(registerBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(registerBtn)
        registerBtn.snp.makeConstraints { make in
            make.top.equalTo(loginBtn.snp.bottom).offset(30)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
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
            make.bottom.equalTo(-15)
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

extension ZBBLoginViewController {
    
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
    
    @objc private func refreshLoginBtnState() {
        if segmentView.selectedIndex == 0 {
            loginBtn.isEnabled = (phoneTextField.text?.count ?? 0) > 0 && (secretTextField.text?.count ?? 0) > 0
        } else {
            loginBtn.isEnabled = (phoneTextField.text?.count ?? 0) > 0 && (codeTextField.text?.count ?? 0) > 0
        }
    }
    
    @objc private func loginBtnAction(_ sender: UIButton) {
        if !agreeBtn.isSelected {
            noticeOnlyText("请阅读并同意协议")
            return
        }
        if segmentView.selectedIndex == 0 {
            //密码登录
            requestLogin(phone: phoneTextField.text!, secret: secretTextField.text!)
        } else {
            //验证码登录
            if Utils_objectC.isMobileNumber2(phoneTextField.text) {
                //手机号验证通过
                requestLogin(phone: phoneTextField.text!, code: codeTextField.text!)
            } else {
                noticeOnlyText("手机号码有误")
            }
        }
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
        let vc = ZBBRegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
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


extension ZBBLoginViewController : JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        segmentedView.selectedIndex != index
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if index == 0 {
            typeBackIcon.image = UIImage(named: "zbbt_login_right_unselect")
            typeFrontIcon.image = UIImage(named: "zbbt_login_left_select")
            secretTextField.isHidden = false
            codeView.isHidden = true
        } else {
            typeBackIcon.image = UIImage(named: "zbbt_login_left_unselect")
            typeFrontIcon.image = UIImage(named: "zbbt_login_right_select")
            secretTextField.isHidden = true
            codeView.isHidden = false
        }
        refreshLoginBtnState()
    }
    
}

extension ZBBLoginViewController {
    
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
    
    ///登录
    private func requestLogin(phone: String, secret: String? = nil, code: String? = nil) {
        var param: Parameters = ["deviceType": "1",
                                 "fromType" : "APP",
                                 "deviceId": UserData.shared.registrationId,
                                 "deviceSystem": UIDevice.current.systemVersion,
                                 "deviceName": UIDevice.current.model,
                                 "appVersion": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String]
        param["type"] = 5
        if let secret = secret {
            param["username"] = phone
            param["password"] = YZBSign.shared.passwordMd5(password: secret)
        } else if let code = code {
            param["mobile"] = phone
            param["randCode"] = code
        }
        YZBSign.shared.request(APIURL.login, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            switch code {
                case 0:
                    let dataDic = Utils.getReqDir(data: response as AnyObject)
                    UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel)
                    UserData1.shared.tokenModel = Mapper<TokenModel1>().map(JSON: dataDic as! [String: Any])
                    
                    self?.requestUserInfo()
                default:
                    let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self?.noticeOnlyText(msg)
                    break
            }
        } failure: { error in
            
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
                self?.navigationController?.popViewController(animated: true)
            }
        } failure: { error in
            
        }
    }
}
