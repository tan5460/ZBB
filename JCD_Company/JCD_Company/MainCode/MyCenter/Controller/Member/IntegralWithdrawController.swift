//
//  IntegralWithdrawController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/22.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PopupDialog

class IntegralWithdrawController: BaseViewController, UITextFieldDelegate {

    var accountField: UITextField!          //账号输入框
    var scoreField: UITextField!            //积分输入框
    var moneyLabel: UILabel!                //提现金额
    
    var userModel: WorkerModel?
    var isCanWithdraw = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "积分提现"
        
        prepareSubView()
    }

    func prepareSubView() {
        
        //账号背景
        let accountView = UIView()
        accountView.backgroundColor = .white
        view.addSubview(accountView)
        
        accountView.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.top.left.right.equalToSuperview()
        }
        
        //转出到
        let accountTitleLabel = UILabel()
        accountTitleLabel.text = "转出到"
        accountTitleLabel.textColor = PublicColor.minorTextColor
        accountTitleLabel.font = UIFont.systemFont(ofSize: 15)
        accountView.addSubview(accountTitleLabel)
        
        accountTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        //账号
        accountField = UITextField()
        accountField.returnKeyType = .done
        accountField.delegate = self
        accountField.tag = 1001
        accountField.clearButtonMode = .whileEditing
        accountField.textColor = UIColor.colorFromRGB(rgbValue: 0x4B66C0)
        accountField.placeholder = "请填写支付宝账号（手机号）"
        accountField.font = UIFont.systemFont(ofSize: 15)
        accountView.addSubview(accountField)
        
        accountField.snp.makeConstraints { (make) in
            make.left.equalTo(90)
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
            make.height.equalTo(30)
        }
        
        //积分背景
        let scoreView = UIView()
        scoreView.backgroundColor = .white
        view.addSubview(scoreView)
        
        scoreView.snp.makeConstraints { (make) in
            make.left.right.equalTo(accountView)
            make.height.equalTo(140)
            make.top.equalTo(accountView.snp.bottom).offset(5)
        }
        
        //积分提现标题
        let scoreTitleLabel = UILabel()
        scoreTitleLabel.text = "提现积分（\(AppData.yzbIntegral)积分=1人民币）"
        scoreTitleLabel.textColor = PublicColor.placeholderTextColor
        scoreTitleLabel.font = UIFont.systemFont(ofSize: 15)
        scoreView.addSubview(scoreTitleLabel)
        
        scoreTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(15)
        }
        
        //全部提现按钮
        let withdrawBtn = UIButton(type: .custom)
        withdrawBtn.setTitle("全部提现", for: .normal)
        withdrawBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x4B66C0), for: .normal)
        withdrawBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        withdrawBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        withdrawBtn.addTarget(self, action: #selector(withdrawAction), for: .touchUpInside)
        scoreView.addSubview(withdrawBtn)
        
        withdrawBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.top.equalTo(60)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        //积分输入框
        scoreField = UITextField()
        scoreField.returnKeyType = .done
        scoreField.delegate = self
        scoreField.tag = 1003
        scoreField.keyboardType = .numbersAndPunctuation
        scoreField.clearButtonMode = .whileEditing
        scoreField.textColor = .black
        scoreField.placeholder = "0"
        scoreField.font = UIFont.systemFont(ofSize: 30)
        scoreView.addSubview(scoreField)
        
        scoreField.snp.makeConstraints { (make) in
            make.left.equalTo(scoreTitleLabel).offset(5)
            make.right.equalTo(withdrawBtn.snp.left).offset(-5)
            make.bottom.equalTo(withdrawBtn)
            make.height.equalTo(36)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xD9D9D9)
        scoreView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.equalTo(scoreTitleLabel)
            make.right.equalTo(scoreField)
            make.top.equalTo(scoreField.snp.bottom).offset(2)
        }
        
        //转换金额
        moneyLabel = UILabel()
        moneyLabel.textColor = PublicColor.placeholderTextColor
        moneyLabel.text = "提现金额: 0.00元"
        moneyLabel.font = UIFont.systemFont(ofSize: 13)
        scoreView.addSubview(moneyLabel)
        
        moneyLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(15)
            make.left.equalTo(lineView)
        }
        
        if !isCanWithdraw {
            moneyLabel.text = "本月已提现"
            moneyLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xDE5D4B)
        }
        
        //可用积分
        let integrationLabel = UILabel()
        integrationLabel.text = "可用积分: 0"
        integrationLabel.textColor = PublicColor.placeholderTextColor
        integrationLabel.font = UIFont.systemFont(ofSize: 13)
        scoreView.addSubview(integrationLabel)
        
        integrationLabel.snp.makeConstraints { (make) in
            make.right.equalTo(withdrawBtn)
            make.centerY.equalTo(moneyLabel)
        }
        
        if let valueStr = userModel?.integration?.stringValue {
            integrationLabel.text = "可用积分: \(valueStr)"
            scoreField.placeholder = valueStr
        }
        
        //确认提现
        let sureBackImg = UIColor.colorFromRGB(rgbValue: 0xDE5D4B).image()
        let sureBackImgHig = UIColor.colorFromRGB(rgbValue: 0xC24E3E).image()
        let sureBtn = UIButton(type: .custom)
        sureBtn.layer.cornerRadius = 4
        sureBtn.layer.masksToBounds = true
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sureBtn.setTitle("下一步", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.setBackgroundImage(sureBackImg, for: .normal)
        sureBtn.setBackgroundImage(sureBackImgHig, for: .highlighted)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        view.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.top.equalTo(scoreView.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
    }
    
    //全部提现
    @objc func withdrawAction() {
        
        scoreField.text = "0"
        
        if let valueStr = userModel?.integration?.stringValue {
            scoreField.text = valueStr
        }
        
        getMoneyValue(scoreField.text!)
    }
    
    //确认提现
    @objc func sureAction() {
        
        UIApplication.shared.keyWindow?.endEditing(true)
        
        if !isCanWithdraw {
            self.noticeOnlyText("本月已提现")
            return
        }
        
        //验证账号
        let accountStr = accountField.text!
        
        if accountStr == "" {
            self.noticeOnlyText("请填写支付宝手机号")
            return
        }
        
        let regStr = "^1[3-9]\\d{9}$"
        let regex = try! NSRegularExpression(pattern: regStr, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: accountStr, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (accountStr as NSString).length))
        
        if numberOfMatches == 0 {
            self.noticeOnlyText("手机号格式有误")
            return
        }
        
        //积分
        let scoreStr = scoreField.text!
        
        if scoreStr == "" {
            self.noticeOnlyText("请填写提现积分")
            return
        }
        
        //判断积分是否越界
        if let valueStr = Int(scoreStr), let integration = userModel?.integration?.intValue {
            
            if valueStr > integration {
                self.noticeOnlyText("提现积分超出可用积分")
                return
            }
            
            if valueStr < 100 {
                self.noticeOnlyText("提现积分不能低于100")
                return
            }
        }
        
        //下一步
        let vc = WithdrawCodeController()
        vc.scoreValue = scoreStr
        vc.telValue = accountStr
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //获取提现金额
    func getMoneyValue(_ scoreStr: String) {
        
        if let valueStr = Int(scoreStr), let integration = userModel?.integration?.intValue, isCanWithdraw {
            
            if valueStr > integration {
                moneyLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xDE5D4B)
                moneyLabel.text = "提现积分超出可用积分"
            }else {
                let moneyValue = Double(valueStr)/Double(Int(AppData.yzbIntegral)!)
                moneyLabel.textColor = PublicColor.placeholderTextColor
                let moneyValueStr = moneyValue.notRoundingString( afterPoint: 2)
                moneyLabel.text = "提现金额: \(moneyValueStr)"
            }
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if  textField.tag == 1003 {
            
            //积分只允许输入数字
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if newString.count > 10 {
                return false
            }
            let expression = "^[0-9]*$"
            let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
            let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
            
            if numberOfMatches == 0 {
                return false
            }
            
            getMoneyValue(newString)
        }
        else if textField.tag == 1001 {
            
            //手机号
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if newString.count > 20 {
                return false
            }
            let expression = "^[0-9]*$"
            let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
            let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
            
            if numberOfMatches == 0 {
                return false
            }
        }
        else if textField.tag == 1002 {
            
            //验证姓名
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if newString.count > 16 {
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        //收起键盘
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 1003 {
            
            if let valueStr = Int(textField.text!) {
                textField.text = "\(valueStr)"
            }
        }
    }
}
