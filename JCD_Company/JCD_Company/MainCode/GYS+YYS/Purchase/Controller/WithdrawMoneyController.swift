//
//  WithdrawMoneyController.swift
//  YZB_Company
//
//  Created by yzb_ios on 22.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PopupDialog
import SwiftyJSON

class WithdrawMoneyController: BaseViewController, UITextFieldDelegate {
    
    var bankLabel = UILabel()
    var moneyField: UITextField!            //积分输入框
    var moneyLabel: UILabel!                //提现金额
    var integrationLabel = UILabel()          //可提现金额
    var codeField: UITextField!             //验证码输入框
    var vCodeBtn: UIButton!                 //获取验证码
    
    var verificationTimer: Timer!           //验证码定时器
    var timerCount: NSInteger!              //倒计时
    var codeKey = ""                        //验证码key
    
    var userCustId = ""
    var moneyValue: Double = 0
    var currentMoneyValue: Double = 0
    var xfLabel = UILabel()
    var openAccountModel = OpenAccountInfoModel()
    
    var mobileStr: String {
        get {
            var mobile = ""
            switch UserData.shared.userType {
            case .cgy, .jzgs:
                mobile = UserData.shared.workerModel?.mobile ?? ""
            case .gys:
                mobile = UserData.shared.merchantModel?.mobile ?? ""
            case .yys:
                mobile = UserData.shared.substationModel?.mobile ?? ""
            case .fws:
                mobile = UserData.shared.merchantModel?.mobile ?? ""
            }
            return mobile
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "提现"
        prepareSubView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    let sureBtn = UIButton(type: .custom)
    func prepareSubView() {
        
        //提现记录
        let recordBtn = UIButton(type: .custom)
        recordBtn.frame = CGRect.init(x: 0, y: 0, width: 60, height: 30)
        recordBtn.setTitle("提现记录", for: .normal)
        recordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        recordBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
        recordBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        recordBtn.addTarget(self, action: #selector(recordAction), for: .touchUpInside)
        
        let editItem = UIBarButtonItem.init(customView: recordBtn)
        navigationItem.rightBarButtonItem = editItem
        
        //请选择银行卡
        let selCardView = UIView()
        selCardView.backgroundColor = .white
        view.addSubview(selCardView)
        
        selCardView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        //银行卡显示
        bankLabel.font = UIFont.systemFont(ofSize: 15)
        bankLabel.text = "请选择银行卡"
        bankLabel.textColor = PublicColor.commonTextColor
        selCardView.addSubview(bankLabel)
        
        bankLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
        }
        
        //箭头
        let arrowView = UIImageView()
        arrowView.image = UIImage.init(named: "arrow_right")
        arrowView.contentMode = .scaleAspectFit
        selCardView.addSubview(arrowView)
        
        arrowView.snp.makeConstraints { (make) in
            make.width.equalTo(7)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        
        //点击区域
        let bankBtn = UIButton()
        let bankBackImg = UIColor.init(white: 0.7, alpha: 0.2).image()
        bankBtn.setBackgroundImage(bankBackImg, for: .highlighted)
        bankBtn.addTarget(self, action: #selector(bankAction), for: .touchUpInside)
        selCardView.addSubview(bankBtn)
        
        bankBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //积分背景
        let moneyView = UIView()
        moneyView.backgroundColor = .white
        view.addSubview(moneyView)
        
        moneyView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(288)
            make.top.equalTo(selCardView.snp.bottom).offset(10)
        }
        
        //积分提现标题
        let moneyTitleLabel = UILabel()
        moneyTitleLabel.text = "提现金额"
        moneyTitleLabel.textColor = PublicColor.commonTextColor
        moneyTitleLabel.font = UIFont.systemFont(ofSize: 15)
        moneyView.addSubview(moneyTitleLabel)
        
        moneyTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(15)
        }
        
        //人民币符号
        let ￥Label = UILabel()
        ￥Label.text = "￥"
        ￥Label.font = UIFont.systemFont(ofSize: 35)
        moneyView.addSubview(￥Label)
        
        ￥Label.snp.makeConstraints { (make) in
            make.left.equalTo(moneyTitleLabel)
            make.top.equalTo(moneyTitleLabel.snp.bottom).offset(25)
            make.width.equalTo(36)
        }
        
        //金额输入框
        moneyField = UITextField()
        moneyField.returnKeyType = .done
//        moneyField.delegate = self
        moneyField.tag = 101
        moneyField.keyboardType = .decimalPad
        moneyField.textColor = .black
        moneyField.font = UIFont.systemFont(ofSize: 35)
        moneyField.addTarget(self, action: #selector(valueChanged(_ :)), for: .editingChanged)
        moneyView.addSubview(moneyField)
        
        moneyField.snp.makeConstraints { (make) in
            make.left.equalTo(￥Label.snp.right).offset(15)
            make.right.equalTo(-15)
            make.centerY.equalTo(￥Label)
            make.height.equalTo(40)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.placeholderTextColor
        moneyView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.bottom.left.right.equalTo(moneyField)
        }
        
        //可提现金额
        integrationLabel.text = "可提现金额: ￥0.00"
        integrationLabel.textColor = PublicColor.minorTextColor
        integrationLabel.font = UIFont.systemFont(ofSize: 14)
        moneyView.addSubview(integrationLabel)
        
        integrationLabel.snp.makeConstraints { (make) in
            make.left.equalTo(moneyTitleLabel)
            make.top.equalTo(moneyField.snp.bottom).offset(15)
        }
        
        //全部提现按钮
        let withdrawBtn = UIButton(type: .custom)
        withdrawBtn.setTitle("全部提现", for: .normal)
        withdrawBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
        withdrawBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        withdrawBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        withdrawBtn.addTarget(self, action: #selector(withdrawAction), for: .touchUpInside)
        moneyView.addSubview(withdrawBtn)
        
        withdrawBtn.snp.makeConstraints { (make) in
            make.right.equalTo(moneyField)
            make.centerY.equalTo(integrationLabel)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        //手续费
        xfLabel.text = "手续费：单笔提现10元/笔"
        xfLabel.textColor = PublicColor.minorTextColor
        xfLabel.font = UIFont.systemFont(ofSize: 14)
        moneyView.addSubview(xfLabel)
        
        xfLabel.snp.makeConstraints { (make) in
            make.left.equalTo(integrationLabel)
            make.top.equalTo(integrationLabel.snp.bottom).offset(22)
        }
        
        //提现说明
        let smLabel = UILabel()
        smLabel.text = "提现说明："
        smLabel.textColor = PublicColor.minorTextColor
        smLabel.font = UIFont.systemFont(ofSize: 14)
        moneyView.addSubview(smLabel)
        
        smLabel.snp.makeConstraints { (make) in
            make.left.equalTo(xfLabel)
            make.top.equalTo(xfLabel.snp.bottom).offset(22)
        }
        
        //提现说明1
        let smLabel1 = UILabel()
        smLabel1.text = "1.每日可提现5笔，单笔最低提现100，最高20W限额"
        smLabel1.textColor = PublicColor.minorTextColor
        smLabel1.numberOfLines = 0
        smLabel1.font = UIFont.systemFont(ofSize: 14)
        moneyView.addSubview(smLabel1)
        
        smLabel1.snp.makeConstraints { (make) in
            make.left.equalTo(xfLabel)
            make.right.equalTo(withdrawBtn)
            make.top.equalTo(smLabel.snp.bottom)
        }
        
        //提现说明2
        let smLabel2 = UILabel()
        smLabel2.text = "2.提现申请提交后，资金实时到账，请后续留意银行卡入账情况"
        smLabel2.textColor = PublicColor.minorTextColor
        smLabel2.font = UIFont.systemFont(ofSize: 14)
        smLabel2.numberOfLines = 0
        moneyView.addSubview(smLabel2)
        
        smLabel2.snp.makeConstraints { (make) in
            make.left.equalTo(xfLabel)
            make.right.equalTo(withdrawBtn)
            make.top.equalTo(smLabel1.snp.bottom)
        }
        
        //确认提现
        let bgImg = PublicColor.gradualColorImage
        let bgHighImg = PublicColor.gradualHightColorImage
        
        sureBtn.layer.cornerRadius = 4
        sureBtn.layer.masksToBounds = true
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sureBtn.setTitle("确认提现", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.setBackgroundImage(bgImg, for: .normal)
        sureBtn.setBackgroundImage(bgHighImg, for: .highlighted)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        view.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.top.equalTo(moneyView.snp.bottom).offset(50)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
    }
    
    @objc func valueChanged(_ textField: UITextField) {
        
        if textField.text?.contains(",") ?? false {
            let text = textField.text!.replacingOccurrences(of: ",", with: "")
            currentMoneyValue = (text as NSString).doubleValue
        }
        else {
            currentMoneyValue = ((textField.text ?? "") as NSString).doubleValue
        }
        
        if currentMoneyValue >= moneyValue {
            currentMoneyValue = moneyValue
        }
        textField.text = currentMoneyValue.notRoundingString(afterPoint: 2)
    }
    
    //MARK: - 按钮事件
    //获取验证码
    @objc func getVCodeAction() {
        
        codeField.becomeFirstResponder()
        vCodeBtn.isEnabled = false
        sendSMSCode()
    }
    
    //提现记录
    @objc func recordAction() {
        let vc = WithdrawalsRecordController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //选择银行卡
    @objc func bankAction() {
        if openAccountModel.settleAccountId == nil {
            noticeOnlyText("请您添加银行卡")
            return
        }
    }
    
    //全部提取
    @objc func withdrawAction() {
        
        if moneyValue >= 200000 {
            currentMoneyValue = 200000
        }
        else {
            currentMoneyValue = moneyValue
        }
        let balanceStr = currentMoneyValue.notRoundingString(afterPoint: 2)
        moneyField.text = balanceStr
    }
    
    //确认提现
    @objc func sureAction() {
      
        if openAccountModel.settleAccountId == nil {
            self.noticeOnlyText("请选择银行卡~")
            return
        }
     
        if currentMoneyValue == 0 {
            self.noticeOnlyText("请输入提现金额~")
            return
        }
        
        if currentMoneyValue < 100 {
            self.noticeOnlyText("提现金额必须大于100")
            return
        }
        
        if currentMoneyValue > moneyValue {
            self.noticeOnlyText("已超过可提现金额~")
            return
        }
        self.withdrawMoney()
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
        
        let parameters: Parameters = ["mobile": mobileStr, "type": "g"]
        let urlStr = APIURL.getSMS + mobileStr
        self.clearAllNotice()
        
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
    
    //查询开户信息
    func loadData() {
        
        let urlStr = APIURL.lessMoney
        self.pleaseWait()
        
        var parameters: Parameters = [:]
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            parameters["userId"] = UserData.shared.merchantModel?.id
        }else if UserData.shared.userType == .yys {
            parameters["userId"] = UserData.shared.substationModel?.id
        }
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")

            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let accountModel = Mapper<OpenAccountInfoModel>().map(JSON: dataDic as! [String : Any])
                self.openAccountModel = accountModel ?? OpenAccountInfoModel()
                let balance = accountModel?.withdrawBalance?.doubleValue ?? 0
                let balanceStr = balance.notRoundingString(afterPoint: 2)
                self.moneyValue = balance
                self.integrationLabel.text = "可提现金额: ￥\(balanceStr)"
                
                if let type = accountModel?.type {
                    if type == "business" {
                        self.xfLabel.text = "手续费：单笔提现10元/笔"
                    }
                    else {
                        self.xfLabel.text = "手续费：单笔提现1元/笔"
                    }
                }

                
                self.bankLabel.attributedText = ToolsFunc.getMixtureAttributString([MixtureAttr(string: accountModel?.settleAccountId ?? "", color: PublicColor.commonTextColor, font: UIFont.systemFont(ofSize: 15)), MixtureAttr(string: "    \(accountModel?.openBank ?? "")", color: PublicColor.placeholderTextColor, font: UIFont.systemFont(ofSize: 15))])
            }
            else if errorCode == "008" {
                let popup = PopupDialog(title: "提示", message: "您尚未开通支付账户，请先前往后台开通！", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    self.navigationController?.popViewController()
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
    }
    
    //验证验证码
    func checkVCode() {
        
        var parameters: Parameters = [:]
        parameters["mobile"] = mobileStr
        parameters["code"] = codeField.text!
        parameters["codeKey"] = codeKey
        
        let urlStr = APIURL.checkCode
        self.pleaseWait()
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                self.getWithdrawalJurisdiction()
            }
            
        }) { (error) in
            
        }
    }
    
    //是否可提现
    func getWithdrawalJurisdiction() {
        
        let urlStr = APIURL.withdrawCheck
        self.pleaseWait()
        
        var parameters: Parameters = [:]
        parameters["userCustId"] = userCustId
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            parameters["userId"] = UserData.shared.merchantModel?.id
        }else if UserData.shared.userType == .yys {
            parameters["userId"] = UserData.shared.substationModel?.id
        }
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                self.withdrawMoney()
            }
            else if errorCode == "022" {
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "今日已提现，每日限制提现五次！", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
    }
    
    //提现
    func withdrawMoney() {
        
        let urlStr = APIURL.withdrawMoney
        self.pleaseWait()
        sureBtn.isUserInteractionEnabled = false
        
        var parameters: Parameters = [:]
        parameters["amount"] = currentMoneyValue * 100
        parameters["description"] = "提现"

        if let valueStr = openAccountModel.settleAccountId {
            parameters["settleAccountId"] = valueStr
        }
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            parameters["userId"] = UserData.shared.merchantModel?.id
        }else if UserData.shared.userType == .yys {
            parameters["userId"] = UserData.shared.substationModel?.id
        } else if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            parameters["userFeeFlag"] = 1
        }
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { [weak self] (response) in
            self?.sureBtn.isUserInteractionEnabled = true
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "006" {
                let dataStr: String = Utils.getReadString(dir: response as NSDictionary, field: "data")
                let dataDic = String.getDictionaryFromJSONString(jsonString: dataStr )
                let errorMsg = dataDic["errorMsg"] as? String
                var popup: PopupDialog!
                var btn: AlertButton!
                popup = PopupDialog(title: "提示", message: errorMsg, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                btn = AlertButton(title: "确定") {
                    
                }
                popup.addButtons([btn])
                self?.present(popup, animated: true, completion: nil)
                return
            }
            else if errorCode == "0" {
                var popup: PopupDialog!
                var btn: AlertButton!
                self?.moneyField.text = ""
                let msgStr = "提现已受理，等待银行处理中，若提现成功，预计T+1日到账；若提现失败，则余额不变，需重新提现!"
                popup = PopupDialog(title: "提示", message: msgStr, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                btn = AlertButton(title: "确定") {
                    self?.recordAction()
                }
                popup.addButtons([btn])
                self?.present(popup, animated: true, completion: nil)
                return
            }
            
        }) { (error) in
            self.sureBtn.isUserInteractionEnabled = true
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //只允许输入数字
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString == "" {
            return true
        }
        
        var expression = "^[0-9]+([.][0-9]{0,2})?$"
        
        if textField.tag == 101 {
            expression = "^[0-9]*$,"
            return true
        }
        
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        
        if numberOfMatches == 0 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //收起键盘
        textField.resignFirstResponder()
        return true;
    }
}
