//
//  BindMerchantSysVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/19.
//

import UIKit
//MARK: - 绑定商户系统已有账户
class BindMerchantSysVC: BaseViewController, UITextFieldDelegate {
    var merchantType: String?
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.kBackgroundColor)
    var isSelectType = 1 // 1: 选择品牌商 2: 选中服务商
    private var verificationTimer: Timer!           //验证码定时器
    private var timerCount: NSInteger!              //倒计时
    private var codeKey = ""                        //验证码key
    private let phoneTF = UITextField().placeholder("请输入已有账户手机号").font(14).then {
         $0.setPlaceHolderTextColor(.kColor99)
         $0.maxTextNumber = 11
         $0.addChangeTextTarget()
         $0.keyboardType = .phonePad
     }
    
     
    private let codeTF = UITextField().placeholder("请输入验证码").font(14).then {
         $0.setPlaceHolderTextColor(.kColor99)
         $0.maxTextNumber = 6
         $0.addChangeTextTarget()
         $0.keyboardType = .phonePad
     }
    private let getCodeBtn = UIButton().text("获取验证码").textColor(.white).font(12).backgroundColor(.k2FD4A7)
    private var phoneText = ""
    private var codeText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "绑定已有账户"
        if merchantType == "1" {
            isSelectType = 1
        } else if merchantType == "2" {
            isSelectType = 2
        }
        
        [phoneTF, codeTF].forEach({
            $0.delegate = self
            $0.clearButtonMode = .whileEditing
            $0.addTarget(self, action: #selector(valueChange(textField:)), for: .editingChanged)
        })
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case phoneTF:
            phoneText = phoneTF.text ?? ""
        case codeTF:
            codeText = codeTF.text ?? ""
        default:
            break
        }
    }

}


extension BindMerchantSysVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.section {
        case 0:
            configSection0(cell: cell)
        case 1:
            configSection1(cell: cell)
        case 2:
            configSection2(cell: cell)
        case 3:
            configSection3(cell: cell)
        default:
            break
        }
        return cell
    }
    
    func configSection0(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let ppsBtn = UIButton().backgroundColor(.white)
        let fwsBtn = UIButton().backgroundColor(.white)
        cell.sv(ppsBtn, fwsBtn)
        cell.layout(
            10,
            |-14-ppsBtn.height(80)-13-fwsBtn.height(80)-14-|,
            15
        )
        equal(widths: ppsBtn, fwsBtn)
        
        
        let ppsIcon = UIImageView().image(#imageLiteral(resourceName: "icon_pps"))
        let ppsLabel = UILabel().text("品牌商").textColor(.kColor33).fontBold(14)
        let ppsSelectIV = UIImageView().image("icon_select")
        
        ppsBtn.sv(ppsIcon, ppsLabel, ppsSelectIV)
        ppsBtn.layout(
            16,
            |-20-ppsIcon.size(48)-20-ppsLabel,
            16
        )
        
        ppsBtn.layout(
            >=0,
            ppsSelectIV.size(30)-0-|,
            0
        )
        
        let fwsIcon = UIImageView().image(#imageLiteral(resourceName: "icon_fws"))
        let fwsLabel = UILabel().text("服务商").textColor(.kColor33).fontBold(14)
        let fwsSelectIV = UIImageView().image("icon_select")
        
        fwsBtn.sv(fwsIcon, fwsLabel, fwsSelectIV)
        fwsBtn.layout(
            16,
            |-20-fwsIcon.size(48)-20-fwsLabel,
            16
        )
        fwsBtn.layout(
            >=0,
            fwsSelectIV.size(30)-0-|,
            0
        )
        
        if isSelectType == 1 {
            ppsBtn.cornerRadius(8).addShadowColor()
            fwsBtn.cornerRadius(8)
            ppsSelectIV.isHidden = false
            fwsSelectIV.isHidden = true
        } else {
            ppsBtn.cornerRadius(8)
            fwsBtn.cornerRadius(8).addShadowColor()
            ppsSelectIV.isHidden = true
            fwsSelectIV.isHidden = false
        }
        
        ppsBtn.tapped { [weak self] (button) in
            self?.isSelectType = 1
            self?.tableView.reloadData()
        }
        
        fwsBtn.tapped { [weak self] (button) in
            self?.isSelectType = 2
            self?.tableView.reloadData()
        }
    }
    //MARK: - 手机号码
    func configSection1(cell: UITableViewCell) {
        let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_phone"))
        cell.sv(icon, phoneTF)
        phoneTF.text(phoneText)
        cell.layout(
            13.5,
            |-14-icon.size(17).centerVertically()-8-phoneTF.height(44)-14-|,
            13.5
        )
    }
    //MARK: - 验证码
    func configSection2(cell: UITableViewCell) {
        let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_code"))
        cell.sv(icon, codeTF, getCodeBtn)
        codeTF.text(codeText)
        cell.layout(
            13.5,
            |-14-icon.size(17).centerVertically()-8-codeTF.height(44)-5-getCodeBtn.width(127).height(44)-0-|,
            13.5
        )
        getCodeBtn.addTarget(self, action: #selector(getCodeBtnClick(btn:)))
    }
    
    @objc private func getCodeBtnClick(btn: UIButton) {
        
        validMobile()
        
        
        
//        codeTF.text = ""
//        if Utils_objectC.isMobileNumber2(phoneTF.text) {
//
//        } else{
//            let popup = PopupDialog(title: phoneText, message: "手机号码有误,请检查您输入的手机号是否正确!", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
//            let sureBtn = AlertButton(title: "确定") {
//            }
//            popup.addButtons([sureBtn])
//            self.present(popup, animated: true, completion: nil)
//        }
    }
    
    //MARK: - 验证手机号
    func validMobile() {
    
        guard let mobile = phoneTF.text, !mobile.isEmpty else {
            self.noticeOnlyText("请输入手机号码")
            return
        }
        var parameters = Parameters()
        parameters["mobile"] = mobile
        parameters["type"] = "4"
        parameters["merchantType"] = "\(isSelectType)"
        YZBSign.shared.request(APIURL.checkMobileV2, method: .get, parameters: parameters, success: { (res) in
            let code = Utils.getReadString(dir: res as NSDictionary, field: "code")
            if code == "0" {
                let isRegiest = res["data"] as? Bool
                if isRegiest ?? false {
                    self.getCodeBtn.isEnabled = false
                    self.sendSMSCode()
                    self.codeTF.becomeFirstResponder()
                    self.codeTF.text("")
                } else {
                    if self.isSelectType == 1  {
                        self.noticeOnlyText("手机号未注册品牌商")
                    } else if self.isSelectType == 2 {
                        self.noticeOnlyText("手机号未注册服务商")
                    }
                }
            }
        }) { (error) in
        }
    }
    
    
    @objc func valueChange(textField: THTextField) {
        if textField.markedTextRange == nil {
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "")
        }
    }
    //MARK: - 确认绑定
    func configSection3(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let sureBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_put_btn")).text("确认绑定").textColor(.white).font(14)
        cell.sv(sureBtn)
        cell.layout(
            100,
            sureBtn.width(280).height(40).centerHorizontally(),
            100
        )
        sureBtn.tapped { [weak self] (button) in
            self?.bindMerchantRequest()
        }
    }
    
    //MARK: - 会员绑定品牌商供应商
    func bindMerchantRequest() {
        pleaseWait()
        var parameters = Parameters()
        parameters["merchantType"] = "\(isSelectType)"
        parameters["mobile"] = phoneTF.text
        parameters["validateCode"] = codeTF.text
        YZBSign.shared.request(APIURL.bindMerchant, method: .put, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                self.noticeSuccess("绑定成功", autoClear: true, autoClearTime: 1)
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } failure: { (error) in
            
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {  
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}



// MARK: - 接口请求
extension BindMerchantSysVC {
    //发送短信验证码
    func sendSMSCode() {
        let parameters: Parameters = ["mobile": phoneTF.text ?? "", "type": "3"]
        let urlStr = APIURL.getSMS + (phoneTF.text ?? "")
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.getCodeBtn.isEnabled = false
                self.getCodeBtn.backgroundColor(.kColor99)
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
                self.getCodeBtn.isEnabled = true
                self.getCodeBtn.backgroundColor(.k2FD4A7)
            }
            
        }) { (error) in
            self.getCodeBtn.isEnabled = true
            self.getCodeBtn.backgroundColor(.k2FD4A7)
        }
    }
    
    //MARK: - 定时器
    @objc func verificationWait() {
        var str: String
        if timerCount <= 0 {
            str = "获取验证码"
            getCodeBtn.isEnabled = true
            getCodeBtn.backgroundColor(.k2FD4A7)
            if let timer = verificationTimer {
                if timer.isValid {
                    verificationTimer.invalidate()
                }
            }
        }else {
            getCodeBtn.isEnabled = false
            getCodeBtn.backgroundColor(.kColor99)
            timerCount = timerCount-1
            str = "获取验证码(\(String(timerCount)))"
        }
        getCodeBtn.setTitle(str, for: .normal)
    }
}
