//
//  RegisterViewController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/2/27.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Alamofire
import ObjectMapper

class RegisterViewController: BaseViewController, UITextFieldDelegate, THPickerDelegate, CompanyTypePickerDelegate {
    
    
    private var scrollView: UIScrollView = UIScrollView()
    
    var topView:UIView!
    var selectBtoView: UIView!
    var type: String = "1"
    
    var userNameField: UITextField!         //用户名输入框
    var passwordField: UITextField!         //密码输入框
    var surePasswordField: UITextField!     //新密码输入框
    var selectAreaView: UIView!
    var selectAreaField: UITextField!       //选择地区输入框
    var  selectCompanyTypeView = UIView()
    var selectOperatorView = UIView()
    var selectOperatorField: UITextField!   //选择运营商输入框
    var selectCompanyTypeField: UITextField!//选择公司类型输入框
    var phoneField: UITextField!            //手机输入框
    var rePhoneField: UITextField!          //推荐人手机输入框
    var validationView: UIView!             //验证码背景
    var verificationField: UITextField!     //验证码输入框
    var getValidationBtn: UIButton!         //获取验证码
    var registerBtn: UIButton!              //注册按钮
    var agreeBtn: UIButton!                 //同意按钮
    var pickerView: THAreaPicker!           //地址选择器
    var operatorPickerView: THAreaPicker!   //运营商选择器
    var companyTypePickerView: CompanyTypePicker!   //公司类型选择器
    var companyTypes = ["家装公司", "工装公司", "家装公司/工装公司"]
    var companyTypeNum = 1
    var provModel: CityModel?               //省
    var cityModel: CityModel?               //市
    var distModel: CityModel?               //区
    
    var verificationTimer: Timer!           //验证码定时器
    var timerCount: NSInteger!              //倒计时
    var codeKey = ""                        //验证码key
    var cityList: Array<CityModel> = []
    var operatorList: Array<CityModel> = []
    var operatorModel: CityModel?           //运营商
    
    var maxY: CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "注册"
        scrollView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height-PublicSize.kNavBarHeight)
        view.addSubview(scrollView)
        getCityList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func prepareSubView() {
        //创建上部视图
        topView = UIView()
        topView.backgroundColor = UIColor.clear
        scrollView.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.right.left.equalToSuperview()
            make.height.equalTo(40)
            
        }
        
        let titles = ["公司","个人"]
        let w = (PublicSize.screenWidth - CGFloat(titles.count-1))/CGFloat(titles.count)
        for (i,title) in titles.enumerated() {
            
            let btn = UIButton()
            btn.setTitle(title, for: .normal)
            btn.tag = 100 + i
            btn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            btn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            btn.frame = CGRect(x: (w+1)*CGFloat(i), y: 0, width: w, height: 44)
            topView.addSubview(btn)
            
            if i == 0 {
                btn.isSelected = true
                
                
                selectBtoView = UIView()
                selectBtoView.frame = CGRect(x: (btn.width-63)/2, y: btn.bottom - 8, width: 63, height: 1)
                selectBtoView.backgroundColor = PublicColor.emphasizeTextColor
                topView.addSubview(selectBtoView)
            }
            
        }
        //账号图标
        let userNameLogo = UIView(frame: CGRect.init(x: 0, y: 0, width: 43, height: 44))
        let userNameLogoImg = UIImageView()
        userNameLogoImg.contentMode = .center
        userNameLogoImg.frame = CGRect.init(x: 10, y: 0, width: 33, height: 44)
        userNameLogoImg.image = UIImage.init(named: "login_username")
        userNameLogo.addSubview(userNameLogoImg)
        
        //用户名输入框
        userNameField = UITextField()
        userNameField.delegate = self
        userNameField.tag = 2001
        userNameField.returnKeyType = .done
        userNameField.backgroundColor = .white
        userNameField.clearButtonMode = .whileEditing
        userNameField.placeholder = "请输入用户名"
        userNameField.font = UIFont.systemFont(ofSize: 15)
        userNameField.leftView = userNameLogo
        userNameField.leftViewMode = .always
        userNameField.keyboardType = .default
        scrollView.addSubview(userNameField)
        
        //修改清除按钮
        let uclearBtn = userNameField.value(forKey: "_clearButton") as! UIButton
        uclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        userNameField.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(44)
            make.top.equalTo(topView.snp.bottom).offset(10)
        }
        
        let userNameHint = UILabel()
        userNameHint.text = "6-20位,字母开头,可使用字母、数字、下划线组合"
        userNameHint.font = UIFont.systemFont(ofSize: 12)
        userNameHint.textColor = PublicColor.placeholderTextColor
        scrollView.addSubview(userNameHint)
        
        userNameHint.snp.makeConstraints { (make) in
            make.left.equalTo(43)
            make.right.equalTo(-10)
            make.top.equalTo(userNameField.snp.bottom).offset(10)
        }
        
        //密码图标
        let passwordLogo = UIView(frame: userNameLogo.frame)
        let passwordLogoImg = UIImageView()
        passwordLogoImg.contentMode = userNameLogoImg.contentMode
        passwordLogoImg.frame = userNameLogoImg.frame
        passwordLogoImg.image = UIImage.init(named: "login_oldpw")
        passwordLogo.addSubview(passwordLogoImg)
        
        //密码输入框
        passwordField = UITextField()
        passwordField.delegate = self
        passwordField.tag = 2002
        passwordField.returnKeyType = .done
        passwordField.backgroundColor = .white
        passwordField.isSecureTextEntry = true
        passwordField.clearButtonMode = .whileEditing
        passwordField.placeholder = "请输入密码"
        passwordField.font = userNameField.font
        passwordField.leftView = passwordLogo
        passwordField.leftViewMode = .always
        passwordField.keyboardType = .default
        scrollView.addSubview(passwordField)
        
        passwordField.snp.makeConstraints { (make) in
            make.left.height.width.equalTo(userNameField)
            make.top.equalTo(userNameHint.snp.bottom).offset(10)
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
        scrollView.addSubview(pshowpwBtn)
        
        pshowpwBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(passwordField)
            make.right.equalTo(passwordField)
            make.width.equalTo(40)
            make.height.equalTo(44)
        }
        
        let passwordHint = UILabel()
        passwordHint.text = "6-20位,可使用字母、数字、英文字符组合"
        passwordHint.font = UIFont.systemFont(ofSize: 12)
        passwordHint.textColor = PublicColor.placeholderTextColor
        scrollView.addSubview(passwordHint)
        
        passwordHint.snp.makeConstraints { (make) in
            make.left.equalTo(userNameHint)
            make.right.equalTo(-10)
            make.top.equalTo(passwordField.snp.bottom).offset(10)
        }
        
        //确认密码图标
        let surePasswordLogo = UIView(frame: userNameLogo.frame)
        let surePasswordLogoImg = UIImageView()
        surePasswordLogoImg.contentMode = userNameLogoImg.contentMode
        surePasswordLogoImg.frame = userNameLogoImg.frame
        surePasswordLogoImg.image = UIImage.init(named: "login_pwagain")
        surePasswordLogo.addSubview(surePasswordLogoImg)
        
        //确认密码输入框
        surePasswordField = UITextField()
        surePasswordField.delegate = self
        surePasswordField.tag = 2003
        surePasswordField.returnKeyType = .done
        surePasswordField.backgroundColor = .white
        surePasswordField.isSecureTextEntry = true
        surePasswordField.clearButtonMode = .whileEditing
        surePasswordField.placeholder = "确认密码"
        surePasswordField.font = userNameField.font
        surePasswordField.leftView = surePasswordLogo
        surePasswordField.leftViewMode = .always
        surePasswordField.keyboardType = .default
        scrollView.addSubview(surePasswordField)
        
        surePasswordField.snp.makeConstraints { (make) in
            make.left.width.height.equalTo(userNameField)
            make.top.equalTo(passwordHint.snp.bottom).offset(10)
        }
        
        //修改清除按钮
        let sclearBtn = surePasswordField.value(forKey: "_clearButton") as! UIButton
        sclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //输入框右侧按钮
        let showpwBtn = UIButton(type: .custom)
        showpwBtn.tag = 101
        showpwBtn.backgroundColor = .white
        showpwBtn.setImage(UIImage.init(named: "login_hidepw"), for: .normal)
        showpwBtn.setImage(UIImage.init(named: "login_showpw"), for: .selected)
        showpwBtn.addTarget(self, action: #selector(showPwAction(_:)), for: .touchUpInside)
        scrollView.addSubview(showpwBtn)
        
        showpwBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(surePasswordField)
            make.right.equalTo(surePasswordField)
            make.width.equalTo(40)
            make.height.equalTo(44)
        }
        
        
        //选择地区
        let selectAreaLogo = UIView(frame: userNameLogo.frame)
        let selectAreaLogoImg = UIImageView()
        selectAreaLogoImg.contentMode = userNameLogoImg.contentMode
        selectAreaLogoImg.frame = userNameLogoImg.frame
        selectAreaLogoImg.image = UIImage.init(named: "login_address")
        selectAreaLogo.addSubview(selectAreaLogoImg)
        
        //选择地区输入框
        selectAreaField = UITextField()
        selectAreaField.delegate = self
        selectAreaField.tag = 1004
        selectAreaField.backgroundColor = .white
        selectAreaField.placeholder = "请选择地区"
        selectAreaField.font = userNameField.font
        selectAreaField.leftView = selectAreaLogo
        selectAreaField.leftViewMode = .always
        
        selectAreaView = UIView()
        scrollView.addSubview(selectAreaView)
        selectAreaView.addSubview(selectAreaField)
        
        selectAreaView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(userNameField)
            make.top.equalTo(surePasswordField.snp.bottom).offset(10)
        }
        selectAreaField.snp.makeConstraints { (make) in
            make.top.width.height.centerX.equalToSuperview()
            
        }
        
        //选择运营商地区
        let selectOperatorLogo = UIView(frame: userNameLogo.frame)
        let selectOperatorLogoImg = UIImageView()
        selectOperatorLogoImg.contentMode = userNameLogoImg.contentMode
        selectOperatorLogoImg.frame = userNameLogoImg.frame
        selectOperatorLogoImg.image = UIImage.init(named: "login_operator")
        selectOperatorLogo.addSubview(selectOperatorLogoImg)
        
        //选择运营商输入框
        selectOperatorField = UITextField()
        selectOperatorField.delegate = self
        selectOperatorField.tag = 1005
        selectOperatorField.backgroundColor = .white
        selectOperatorField.placeholder = "请选择区域"
        selectOperatorField.font = userNameField.font
        selectOperatorField.leftView = selectOperatorLogo
        selectOperatorField.leftViewMode = .always
        
        selectOperatorView = UIView()
        scrollView.addSubview(selectOperatorView)
        selectOperatorView.addSubview(selectOperatorField)
        
        selectOperatorView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(userNameField)
            make.top.equalTo(selectAreaView.snp.bottom).offset(10)
        }
        selectOperatorField.snp.makeConstraints { (make) in
            make.top.width.height.centerX.equalToSuperview()
            
        }
        
        //选择公司类型
        let selectCompanyTypeLogo = UIView(frame: userNameLogo.frame)
        let selectCompanyTypeLogoImg = UIImageView()
        selectCompanyTypeLogoImg.contentMode = userNameLogoImg.contentMode
        selectCompanyTypeLogoImg.frame = userNameLogoImg.frame
        selectCompanyTypeLogoImg.image = UIImage.init(named: "login_companyType")
        selectCompanyTypeLogo.addSubview(selectCompanyTypeLogoImg)
        
        //选择公司类型输入框
        selectCompanyTypeField = UITextField()
        selectCompanyTypeField.delegate = self
        selectCompanyTypeField.tag = 1006
        selectCompanyTypeField.backgroundColor = .white
        selectCompanyTypeField.placeholder = "请选择公司类型"
        selectCompanyTypeField.font = userNameField.font
        selectCompanyTypeField.text = companyTypes.first
        selectCompanyTypeField.leftView = selectCompanyTypeLogo
        selectCompanyTypeField.leftViewMode = .always
        
        selectCompanyTypeView = UIView()
        scrollView.addSubview(selectCompanyTypeView)
        selectCompanyTypeView.addSubview(selectCompanyTypeField)
        
        selectCompanyTypeView.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(userNameField)
            make.top.equalTo(selectOperatorView.snp.bottom).offset(10)
        }
        selectCompanyTypeField.snp.makeConstraints { (make) in
            make.top.width.height.centerX.equalToSuperview()
            
        }
        
        //手机号码图标
        let phoneLogo = UIView(frame: userNameLogo.frame)
        let phoneLogoImg = UIImageView()
        phoneLogoImg.contentMode = userNameLogoImg.contentMode
        phoneLogoImg.frame = userNameLogoImg.frame
        phoneLogoImg.image = UIImage.init(named: "login_phone")
        phoneLogo.addSubview(phoneLogoImg)
        
        //手机号输入框
        phoneField = UITextField()
        phoneField.delegate = self
        phoneField.returnKeyType = .done
        phoneField.tag = 1002
        phoneField.backgroundColor = .white
        phoneField.clearButtonMode = .whileEditing
        phoneField.placeholder = "请输入手机号"
        phoneField.font = userNameField.font
        phoneField.leftView = phoneLogo
        phoneField.leftViewMode = .always
        phoneField.keyboardType = .phonePad
        scrollView.addSubview(phoneField)
        
        phoneField.snp.makeConstraints { (make) in
            make.left.right.height.equalTo(userNameField)
            make.top.equalTo(selectCompanyTypeView.snp.bottom).offset(10)
        }
        
        //        //推荐手机号码图标
        //        let rePhoneLogo = UIView(frame: userNameLogo.frame)
        //        let rePhoneLogoImg = UIImageView()
        //        rePhoneLogoImg.contentMode = userNameLogoImg.contentMode
        //        rePhoneLogoImg.frame = userNameLogoImg.frame
        //        rePhoneLogoImg.image = UIImage.init(named: "login_phone")
        //        rePhoneLogo.addSubview(rePhoneLogoImg)
        //
        //        //手机号输入框
        //        rePhoneField = UITextField()
        //        rePhoneField.delegate = self
        //        rePhoneField.returnKeyType = .done
        //        rePhoneField.tag = 3000
        //        rePhoneField.backgroundColor = .white
        //        rePhoneField.clearButtonMode = .whileEditing
        //        rePhoneField.placeholder = "请输入推荐人手机号（非必填）"
        //        rePhoneField.font = userNameField.font
        //        rePhoneField.leftView = rePhoneLogo
        //        rePhoneField.leftViewMode = .always
        //        rePhoneField.keyboardType = .phonePad
        //        view.addSubview(rePhoneField)
        //
        //        rePhoneField.snp.makeConstraints { (make) in
        //            make.left.right.height.equalTo(userNameField)
        //            make.top.equalTo(phoneField.snp.bottom).offset(10)
        //        }
        //修改清除按钮
        let phclearBtn = phoneField.value(forKey: "_clearButton") as! UIButton
        phclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
        //验证码背景
        validationView = UIView()
        validationView.backgroundColor = .white
        scrollView.addSubview(validationView)
        
        validationView.snp.makeConstraints { (make) in
            make.top.equalTo(phoneField.snp.bottom).offset(10)
            make.left.right.height.equalTo(userNameField)
        }
        
        //验证码图标
        let verificationCodeLogo = UIView(frame: userNameLogo.frame)
        let verificationCodeLogoImg = UIImageView()
        verificationCodeLogoImg.contentMode = userNameLogoImg.contentMode
        verificationCodeLogoImg.frame = userNameLogoImg.frame
        verificationCodeLogoImg.image = UIImage.init(named: "login_pin")
        verificationCodeLogo.addSubview(verificationCodeLogoImg)
        
        //验证码输入框
        verificationField = UITextField()
        verificationField.delegate = self
        verificationField.returnKeyType = .done
        verificationField.keyboardType = .numberPad
        verificationField.tag = 1003
        verificationField.clearButtonMode = .whileEditing
        verificationField.placeholder = "验证码"
        verificationField.font = userNameField.font
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
        
        //修改清除按钮
        let vclearBtn = verificationField.value(forKey: "_clearButton") as! UIButton
        vclearBtn.setImage(UIImage(named: "login_delete"), for: .normal)
        
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
        getValidationBtn.setTitleColor(PublicColor.emphasizeColor, for: .normal)
        getValidationBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        getValidationBtn.setTitleColor(PublicColor.placeholderTextColor, for: .disabled)
        getValidationBtn.addTarget(self, action: #selector(getValidationAction), for: .touchUpInside)
        validationView.addSubview(getValidationBtn)
        
        getValidationBtn.snp.makeConstraints { (make) in
            make.top.height.right.equalToSuperview()
            make.left.equalTo(lineView.snp.right)
        }
        
        //同意
        agreeBtn = UIButton.init(type: .custom)
        agreeBtn.setImage(UIImage.init(named: "car_unchecked"), for: .normal)
        agreeBtn.addTarget(self, action: #selector(agreeAction), for: .touchUpInside)
        scrollView.addSubview(agreeBtn)
        
        agreeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(19)
            make.top.equalTo(validationView.snp.bottom).offset(12)
            make.width.height.equalTo(30)
        }
        
        //我已同意
        let agreeLabel = UILabel()
        agreeLabel.text = "我已阅读并同意"
        agreeLabel.textColor = PublicColor.minorTextColor
        agreeLabel.font = UIFont.systemFont(ofSize: 10)
        scrollView.addSubview(agreeLabel)
        
        agreeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(agreeBtn.snp.right).offset(-2)
            make.centerY.equalTo(agreeBtn)
        }
        
        //协议
        let agreementBtn = UIButton.init(type: .custom)
        agreementBtn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        agreementBtn.setTitle("《服务协议》", for: .normal)
        agreementBtn.setTitleColor(PublicColor.emphasizeColor, for: .normal)
        agreementBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        agreementBtn.addTarget(self, action: #selector(agreementAction), for: .touchUpInside)
        scrollView.addSubview(agreementBtn)
        
        agreementBtn.snp.makeConstraints { (make) in
            make.left.equalTo(agreeLabel.snp.right)
            make.centerY.equalTo(agreeBtn)
        }
        
        //协议
        let agreementBtn1 = UIButton.init(type: .custom)
        agreementBtn1.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        agreementBtn1.setTitle("《入驻协议》", for: .normal)
        agreementBtn1.setTitleColor(PublicColor.emphasizeColor, for: .normal)
        agreementBtn1.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        agreementBtn1.addTarget(self, action: #selector(agreementAction1), for: .touchUpInside)
        scrollView.addSubview(agreementBtn1)
        
        agreementBtn1.snp.makeConstraints { (make) in
            make.left.equalTo(agreementBtn.snp.right)
            make.centerY.equalTo(agreeBtn)
        }
        
        //注册
        let bgImg = PublicColor.gradualColorImage
        let bgHighImg = PublicColor.gradualHightColorImage
        registerBtn = UIButton.init(type: .custom)
        registerBtn.layer.cornerRadius = 4
        registerBtn.layer.masksToBounds = true
        registerBtn.setTitle("下一步", for: .normal)
        registerBtn.setTitleColor(.white, for: .normal)
        registerBtn.setBackgroundImage(bgImg, for: .normal)
        registerBtn.setBackgroundImage(bgHighImg, for: .highlighted)
        registerBtn.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
        registerBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        scrollView.addSubview(registerBtn)
        
        registerBtn.snp.makeConstraints { (make) in
            make.left.width.height.equalTo(userNameField)
            make.top.equalTo(agreeBtn.snp.bottom).offset(35)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        //选择器
        pickerView = THAreaPicker()
        pickerView.tag = 3000
        pickerView.areaDelegate = self
        pickerView.cityArray = cityList
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        
        operatorPickerView = THAreaPicker()
        operatorPickerView.areaDelegate = self
        operatorPickerView.tag = 3001
        
        view.addSubview(operatorPickerView)
        
        operatorPickerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        companyTypePickerView = CompanyTypePicker()
        companyTypePickerView.delegate = self
        view.addSubview(companyTypePickerView)
        
        companyTypePickerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    
    //MARK: - 按钮事件
    //
    @objc func buttonAction(_ sender:UIButton) {
        selectBtoView.centerX = sender.centerX
        sender.isSelected = true
        if sender.tag == 100 {
            type = "1"
            if let btn = topView.viewWithTag(101) as? UIButton {
                btn.isSelected = false
            }
            selectCompanyTypeView.isHidden = false
            phoneField.snp.remakeConstraints { (make) in
                make.left.right.height.equalTo(userNameField)
                make.top.equalTo(selectCompanyTypeView.snp.bottom).offset(10)
            }
        }else {
            type = "2"
            if let btn = topView.viewWithTag(100) as? UIButton {
                btn.isSelected = false
            }
            selectCompanyTypeView.isHidden = true
            
            phoneField.snp.remakeConstraints { (make) in
                make.left.right.height.equalTo(userNameField)
                make.top.equalTo(selectOperatorView.snp.bottom).offset(10)
            }
        }
    }
    //密码是否可见
    @objc func showPwAction(_ sender:UIButton) {
        if sender.tag == 100 {
            passwordField.isSecureTextEntry = sender.isSelected
        }else {
            surePasswordField.isSecureTextEntry = sender.isSelected
        }
        sender.isSelected = !sender.isSelected
    }
    //同意
    @objc func agreeAction() {
        
        agreeBtn.isSelected = !agreeBtn.isSelected
        
        if agreeBtn.isSelected {
            agreeBtn.setImage(UIImage.init(named: "car_checked"), for: .normal)
        }
        else {
            agreeBtn.setImage(UIImage.init(named: "car_unchecked"), for: .normal)
        }
    }
    
    //服务协议
    @objc func agreementAction() {
        
        let rootVC = AgreementViewController()
        let vc = BaseNavigationController.init(rootViewController: rootVC)
        rootVC.type = .protocl
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    //入驻协议
    @objc func agreementAction1() {
        
        let rootVC = AgreementViewController()
        let vc = BaseNavigationController.init(rootViewController: rootVC)
        rootVC.type = .protocl
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    //获取验证码
    @objc func getValidationAction() {
        
        if phoneField.text == "" {
            self.noticeOnlyText("请输入手机号")
            return
        }
        
        verificationField.text = ""
        
        if Utils_objectC.isMobileNumber2(phoneField.text) {
            
            getValidationBtn.isEnabled = false
            sendSMSCode()
            
            verificationField.becomeFirstResponder()
            
        }else{
            let popup = PopupDialog(title: phoneField.text, message: "手机号码有误,请检查您输入的手机号是否正确!", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
            
            let sureBtn = AlertButton(title: "确定") {
                
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    @objc func registerAction() {
        
        if userNameField.text == "" {
            self.noticeOnlyText("请输入用户名")
            return
        }
        
        if let userNameStr = userNameField.text {
            
            if userNameStr.count < 6 || userNameStr.count > 20  {
                
                self.noticeOnlyText("用户名格式不对")
                return
            }
            
            //是否包含字母
            let index = userNameStr.index(userNameStr.startIndex, offsetBy: 1)
            let firstStr = String(userNameStr.prefix(upTo: index))
            let firstChar = firstStr.utf8.first
            if (firstChar! > 64 && firstChar! < 91) || (firstChar! > 96 && firstChar! < 123) {
                AppLog("首字符为字母")
            }
            else {
                
                self.noticeOnlyText("用户名格式不对")
                return
            }
            
            let expression = "^[0-9a-zA-Z_]{1,}$"
            let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
            let numberOfMatches = regex.numberOfMatches(in: userNameStr, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (userNameStr as NSString).length))
            
            if numberOfMatches == 0 {
                
                self.noticeOnlyText("用户名格式不对")
                return
            }
        }
        
        if passwordField.text!.count < 6 || passwordField.text!.count > 20 {
            self.noticeOnlyText("请输入6-20位密码")
            return
        }
        
        if surePasswordField.text == "" {
            self.noticeOnlyText("请确认密码")
            return
        }
        
        if passwordField.text != surePasswordField.text {
            self.noticeOnlyText("两次输入密码不一致")
            return
        }
        
        if cityModel == nil {
            self.noticeOnlyText("请选择地区")
            return
        }
        if operatorModel == nil {
            self.noticeOnlyText("请选择运营商")
            return
        }
        if type == "1" && selectCompanyTypeField.text == "" {
            self.noticeOnlyText("请选择公司类型")
            return
        }
        
        if phoneField.text == "" {
            self.noticeOnlyText("请输入手机号")
            return
        }
        
        if !Utils_objectC.isMobileNumber2(phoneField.text) {
            
            self.noticeOnlyText("手机号有误")
            return
        }
        
        if verificationField.text?.count != 6 {
            self.noticeOnlyText("请输入6位数验证码")
            return
        }
        
        if !agreeBtn.isSelected {
            self.noticeOnlyText("请同意并勾选聚材道服务协议")
            return
        }
        
        registerRequest()
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
    
    //获取城市信息
    func getCityList() {
        
        self.pleaseWait()
        var parameters: Parameters = [:]
        let urlStr = APIURL.findCityList
        parameters["mobile"] = UserData.shared.substationModel?.mobile
        parameters["realName"] = UserData.shared.substationModel?.realName
        parameters["cityId"] = UserData.shared.substationModel?.cityId
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CityModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.cityList = modelArray
                
                self.prepareSubView()
            }else {
                let popup = PopupDialog(title: "获取城市信息失败！", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    self.navigationController?.popViewController(animated: true)
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            let popup = PopupDialog(title: "获取城市信息失败！", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
            
            let sureBtn = AlertButton(title: "确定") {
                self.navigationController?.popViewController(animated: true)
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
    }
    //获取运营商信息
    func getOperatorList() {
        self.pleaseWait()
        let parameters: Parameters = ["cityId":  cityModel?.id ?? ""]
        let urlStr = APIURL.findOperatorList
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<SubstationModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                self.operatorList.removeAll()
                for model in modelArray {
                    let ctmodel = CityModel()
                    ctmodel.id = model.id
                    ctmodel.name = model.groupName
                    self.operatorList.append(ctmodel)
                }
                
                if self.selectOperatorField.text == "" {
                    if self.operatorList.count > 0 {
                        
                        self.selectOperatorField.text = self.operatorList[0].name
                        self.operatorModel = self.operatorList.first
                    }
                    
                }
                
                self.operatorPickerView.cityArray = self.operatorList
                self.operatorPickerView.picker.reloadAllComponents()
                self.operatorPickerView.showPicker()
                
            }else {
                let popup = PopupDialog(title: "获取城市运营商失败！", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
            let popup = PopupDialog(title: "获取城市运营商失败！", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
            
            let sureBtn = AlertButton(title: "确定") {
                
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    //发送短信验证码
    func sendSMSCode(){
        
        let parameters: Parameters = ["mobile": phoneField.text!, "type": "3"]
        
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
            }
            
        }) { (error) in
            
            self.getValidationBtn.isEnabled = true
        }
    }
    
    //注册
    func registerRequest() {
        var parameters: Parameters = [:]
        parameters["userName"] = userNameField.text
        parameters["mobile"] = phoneField.text
        parameters["password"] = YZBSign.shared.passwordMd5(password: passwordField.text)
        parameters["validateCode"] = verificationField.text
        parameters["codeKey"] = codeKey
        parameters["provinceId"] = ""
        parameters["cityId"] = cityModel?.id
        parameters["districtId"] = ""
        parameters["citySubstation"] = operatorModel?.id
        parameters["isCheck"] = "4"
        parameters["type"] = type
        if type == "1" {
            parameters["storeType"] = companyTypeNum
        }
        //parameters["refereePhone"] = "待定"
        self.pleaseWait()
        let urlStr = APIURL.companyRegister
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let registerModel = Mapper<RegisterModel>().map(JSON: dataDic as! [String : Any])
                let workerModel = WorkerModel()
                workerModel.yzbRegister = registerModel
                
                let vc = UploadIDCardController()
                vc.type = self.type
                vc.workerModel = workerModel
                self.navigationController?.pushViewController(vc, animated: true)

//                let paySb = UIStoryboard.init(name: "PayStoryboard", bundle: nil)
//
//                let vc = paySb.instantiateViewController(withIdentifier: "PayTableViewController") as? PayTableViewController
//                vc?.isRegister = true
//                vc?.registerID = registerModel?.id
//                vc?.citySubstationID = registerModel?.citySubstation
//                self.navigationController?.pushViewController(vc!, animated: true)
        
            }
            else if errorCode == "009" {
                
                self.getValidationBtn.isEnabled = true
                self.getValidationBtn.setTitle("获取验证码", for: .normal)
                
                if let timer = self.verificationTimer {
                    if timer.isValid {
                        self.verificationTimer.invalidate()
                    }
                }
                
                self.clearAllNotice()
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                let popup = PopupDialog(title: msg, message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
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
    
    
    //MARK: - THPickerDelegate
    
    func pickerViewSelectArea(pickerView:THAreaPicker, selectModel: CityModel, component: Int) {
        if pickerView.tag == 3000 {
            
            cityModel = selectModel
            selectAreaField.text = cityModel?.name
            
            operatorModel = nil
            selectOperatorField.text = ""
            
        }else if pickerView.tag == 3001 {
            operatorModel = selectModel
            selectOperatorField.text = operatorModel?.name
        }
    }
    
    func pickerViewSelectCompanyType(pickerView: CompanyTypePicker, selectIndex: Int, component: Int) {
        selectCompanyTypeField.text = companyTypes[selectIndex]
        companyTypeNum = selectIndex + 1
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString == "" {
            return true
        }
        textField.text?.isPhoneNumber()
        if textField.tag == 2001 || textField.tag == 2002 || textField.tag == 2003 {
            
            //账号密码不能超过20位
            if newString.count > 20 {
                return false
            }
        }
        
        if  textField.tag == 1002 || textField.tag == 1003 {
            
            //手机号、验证码只允许输入数字
            if newString.count > 11 && textField.tag == 1002 {
                return false
            }
            
            if newString.count > 6 && textField.tag == 1003 {
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        userNameField.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6).cgColor
        passwordField.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6).cgColor
        surePasswordField.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6).cgColor
        selectAreaField.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6).cgColor
        phoneField.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6).cgColor
        validationView.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6).cgColor
        
        if textField.tag == 1003 {
            validationView.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xff8565).cgColor
        }else {
            textField.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xff8565).cgColor
        }
        
        let rect = textField.convert(CGPoint.zero, to: view)
        maxY = rect.y + textField.frame.size.height
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 1003 {
            validationView.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6).cgColor
        }else {
            textField.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6).cgColor
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1004 {
            UIApplication.shared.keyWindow?.endEditing(true)
            
            if textField.text == "" {
                if cityList.count > 0 {
                    
                    textField.text = cityList[0].name
                    cityModel = cityList.first
                }
                
            }
            pickerView.showPicker()
            return false
        }else if textField.tag == 1005 {
            if cityModel == nil {
                self.noticeOnlyText("请先选择地区")
                return false
            }
            getOperatorList()
            return false
        } else if textField.tag == 1006 {
            self.companyTypePickerView.companyTypes = companyTypes
            self.companyTypePickerView.picker.reloadAllComponents()
            self.companyTypePickerView.showPicker()
            return false
        }
        return true
    }
    
}
