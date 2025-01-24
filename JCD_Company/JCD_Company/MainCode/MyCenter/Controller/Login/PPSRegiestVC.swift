//
//  PPSRegiestVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/11/4.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper

class PPSRegiestVC: BaseViewController, UITextFieldDelegate, THPickerDelegate, CompanyTypePickerDelegate {
    var regiestModel: RegisterModel?
    private let userNameTF = UITextField().placeholder("请输入用户名").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
    }
    private let passwordTF = UITextField().placeholder("请输入密码").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
        $0.isSecureTextEntry = true
    }
    private let surePasswordTF = UITextField().placeholder("确认密码").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
        $0.isSecureTextEntry = true
    }
    
    private let comNameTF = UITextField().placeholder("请输入企业名称").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
    }
    
    private let kfPhoneTF = UITextField().placeholder("请输入客服电话").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
        $0.maxTextNumber = 11
        $0.addChangeTextTarget()
        $0.keyboardType = .phonePad
    }
    
    private let phoneTF = UITextField().placeholder("请输入手机号码").font(14).then {
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
    
    
    
    private var cityModel: CityModel?               //市
    private var distModel: CityModel?               //区
    private var provPickerView: THAreaPicker!
    private var pickerView: THAreaPicker!           //地址选择器
    private var operatorPickerView: THAreaPicker!   //运营商选择器
    private var companyTypePickerView: CompanyTypePicker!   //品牌商企业类型选择器
    private var companyTypes = ["生产厂家",  "地区总代理", "地区分销商"]
    private var companyTypeNum = 1
    private var provList: [CityModel] = []
    private var cityList: [CityModel] = []
    private var operatorList: [CityModel] = []
    private var operatorModel: CityModel?           //运营商
    private let provLabel = UILabel().text("请选择省份").textColor(.kColor99).font(14)
    private let addressLabel = UILabel().text("请选择地区").textColor(.kColor99).font(14)
    private let distLabel = UILabel().text("请选择区域").textColor(.kColor99).font(14)
    private let typeLabel = UILabel().text("请选择企业类型").textColor(.kColor99).font(14)
    private let getCodeBtn = UIButton().text("获取验证码").textColor(.white).font(12).backgroundColor(.k2FD4A7)
    private let checkBtn = UIButton().then {
        $0.setImage(#imageLiteral(resourceName: "login_check"), for: .selected)
        $0.setImage(#imageLiteral(resourceName: "login_uncheck"), for: .normal)
    }
    private let nextBtn = UIButton().text("下一步").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_next_btn"))
    private var userNameText = ""
    private var passwordText = ""
    private var surePasswordText = ""
    private var comNameText = ""
    private var kfPhoneText = ""
    private var phoneText = ""
    private var codeText = ""
    private var provText = ""
    private var addressText = ""
    private var distText = ""
    private var typeText = ""
    
    var verificationTimer: Timer!           //验证码定时器
    var timerCount: NSInteger!              //倒计时
    var codeKey = ""                        //验证码key
    
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bindBtn = UIButton().text("绑定已有账户").textColor(.k1DC597).font(14)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: bindBtn)
        bindBtn.tapped { [weak self] (tapBtn) in
            let vc = BindMerchantSysVC()
            self?.navigationController?.pushViewController(vc)
        }
        
        [userNameTF, passwordTF, surePasswordTF, phoneTF, codeTF, comNameTF, kfPhoneTF].forEach({
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
        
        getCityList1()
    }
    
    @objc func valueChange(textField: THTextField) {
        if textField.markedTextRange == nil {
            textField.text = textField.text?.replacingOccurrences(of: " ", with: "")
        }
    }
    
    func configPickerViews() {
        //加一个全国的
        let countyModel = CityModel()
        countyModel.name = "全国"
        cityList.insert(countyModel, at: 0)
        
        //选择器
        pickerView = THAreaPicker()
        pickerView.areaDelegate = self
        pickerView.cityArray = cityList
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        operatorPickerView = THAreaPicker()
        operatorPickerView.areaDelegate = self
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
    

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case userNameTF:
            userNameText = userNameTF.text ?? ""
        case passwordTF:
            passwordText = passwordTF.text ?? ""
        case surePasswordTF:
            surePasswordText = surePasswordTF.text ?? ""
        case phoneTF:
            phoneText = phoneTF.text ?? ""
        case codeTF:
            codeText = codeTF.text ?? ""
        case comNameTF:
            comNameText = comNameTF.text ?? ""
        case kfPhoneTF:
            kfPhoneText = kfPhoneTF.text ?? ""
        default:
            break
        }
    }
    
    //MARK: - THPickerDelegate
    
    func pickerViewSelectArea(pickerView:THAreaPicker, selectModel: CityModel, component: Int) {
        if pickerView == self.pickerView {
            cityModel = selectModel
            addressText = cityModel?.name ?? ""
            addressLabel.text(addressText).textColor(.kColor33)
            operatorModel = nil
            distText = ""
            if addressText == "全国" {
                distLabel.text(addressText).textColor(.kColor99)
            } else {
                distLabel.text("请选择地区").textColor(.kColor99)
            }
        }else if pickerView == self.operatorPickerView {
            operatorModel = selectModel
            distText = operatorModel?.name ?? ""
            distLabel.text(distText).textColor(.kColor33)
        }
    }
    
    func pickerViewSelectCompanyType(pickerView: CompanyTypePicker, selectIndex: Int, component: Int) {
        if pickerView == companyTypePickerView {
            typeText = companyTypes[selectIndex]
            typeLabel.text(typeText).textColor(.kColor33)
            companyTypeNum = selectIndex + 1
        }
    }
}


extension PPSRegiestVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_username_icon"))
            cell.sv(star, icon, userNameTF)
            userNameTF.text(userNameText)
            if let userName = regiestModel?.userName {
                userNameText = userName
                userNameTF.text(userNameText)
                userNameTF.isUserInteractionEnabled = false
            }
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-userNameTF.height(44)-45-|
        case 1:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_password"))
            let showBtn = UIButton()
            showBtn.setImage(#imageLiteral(resourceName: "regiest_show"), for: .normal)
            showBtn.setImage(#imageLiteral(resourceName: "regiest_unshow"), for: .selected)
            cell.sv(star, icon, passwordTF, showBtn)
            passwordTF.text(passwordText)
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-passwordTF.height(44)-0.5-showBtn.size(44)-0.5-|
            showBtn.addTarget(self, action: #selector(passwordShowBtnClick(btn:)))
        case 2:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_surepassword"))
            let showBtn = UIButton().then {
                $0.setImage(#imageLiteral(resourceName: "regiest_show"), for: .normal)
                $0.setImage(#imageLiteral(resourceName: "regiest_unshow"), for: .selected)
            }
            cell.sv(star, icon, surePasswordTF, showBtn)
            surePasswordTF.text(surePasswordText)
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-surePasswordTF.height(44)-0.5-showBtn.size(44)-0.5-|
            showBtn.addTarget(self, action: #selector(surePasswordShowBtnClick(btn:)))
        case 3:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_select_address"))
            let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
            arrow.isUserInteractionEnabled = false
            cell.sv(star, icon, addressLabel, arrow)
            if !addressText.isEmpty {
                addressLabel.text(addressText).textColor(.kColor33)
            } else {
                addressLabel.textColor(.kColor99)
            }
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-addressLabel.height(44)-0.5-arrow.size(44)-0.5-|
        case 4:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "login_operator"))
            let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
            arrow.isUserInteractionEnabled = false
            cell.sv(star, icon, distLabel, arrow)
            if !distText.isEmpty {
                distLabel.text(distText).textColor(.kColor33)
            } else {
                distLabel.textColor(.kColor99)
            }
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-distLabel.height(44)-0.5-arrow.size(44)-0.5-|
        case 5:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let icon = UIImageView().image(#imageLiteral(resourceName: "login_companyType"))
        let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
        arrow.isUserInteractionEnabled = false
        cell.sv(star, icon, typeLabel, arrow)
        if !typeText.isEmpty {
            typeLabel.text(distText).textColor(.kColor33)
        } else {
            typeLabel.textColor(.kColor99)
        }
        |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-typeLabel.height(44)-0.5-arrow.size(44)-0.5-|
        case 6:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_qyname_icon"))
            cell.sv(star, icon, comNameTF)
            comNameTF.text(comNameText)
            if let comName = regiestModel?.contacts {
                comNameText = comName
                comNameTF.text(comNameText)
            }
            comNameTF.text(comNameText)
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-comNameTF.height(44)-45-|
        case 7:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_kf_icon"))
            cell.sv(star, icon, kfPhoneTF)
            kfPhoneTF.text(kfPhoneText)
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-kfPhoneTF.height(44)-45-|
        case 8:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_phone"))
            cell.sv(star, icon, phoneTF)
            phoneTF.text(phoneText)
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-phoneTF.height(44)-45-|
        case 9:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_code"))
            cell.sv(star, icon, codeTF, getCodeBtn)
            codeTF.text(codeText)
            |-14-star.width(7).height(20).centerVertically()-1-icon.size(17).centerVertically()-8-codeTF.height(44)-5-getCodeBtn.width(127).height(44)-|
            getCodeBtn.addTarget(self, action: #selector(getCodeBtnClick(btn:)))
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 { // 选择城市
            if cityList.count > 0  && cityModel == nil {
                addressLabel.text = cityList[0].name
                cityModel = cityList.first
            }
            pickerView.showPicker()
        }
        if indexPath.section == 4 { // 选择地区
            if addressText == "全国" {
                return
            }
            if cityModel == nil {
                self.noticeOnlyText("请先选择地区")
                return
            }
            getOperatorList1()
        }
        if indexPath.section == 5 { // 选择城市
            self.companyTypePickerView.companyTypes = companyTypes
            self.companyTypePickerView.picker.reloadAllComponents()
            self.companyTypePickerView.showPicker()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 120.5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 120.5)).backgroundColor(.kBackgroundColor)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_anquan_icon"))
            let tipLabel = UILabel().text("为了确保交易安全，我们需要认证您的身份，此信息会完全保密并不对外提供，只用于身份认证").textColor(UIColor.hexColor("#3564F6")).font(12)
            tipLabel.numberOfLines(2).lineSpace(2)
            let stepIV = UIImageView().image(#imageLiteral(resourceName: "pps_register_step_1"))
            v.sv(icon, tipLabel, stepIV)
            v.layout(
                10,
                |-14-icon.size(14),
                >=0
            )
            v.layout(
                9.5,
                |-30-tipLabel-30-|,
                10,
                stepIV.height(58).centerHorizontally(),
                10
            )
            
            return v
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 36.5
        } else if section == 7 {
            return 269
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 36.5))
            configTip(v: v, section: section)
            return v
        } else if section == 7 {
            nextBtn.isEnabled = false
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 269))
            configCheck(v: v, section: section)
            return v
        }
        return UIView()
    }
    
    func configTip(v: UIView, section: Int) {
        let tip = UILabel().text("6-20位字母开头，可使用字母、数字、下划线组合").textColor(.kColor99).font(12)
        if section == 1 {
            tip.text("6-20位，可使用字母、数字、英文字符组合")
        }
        v.sv(tip)
        |-39-tip.centerVertically()
    }
    
    func configCheck(v: UIView, section: Int) {
        let label = UILabel().text("我已阅读并同意").textColor(.kColor99).font(10)
        let protocolBtn = UIButton().text("《入驻协议》").textColor(.k2FD4A7).font(10)
        v.sv(checkBtn, label, protocolBtn, nextBtn)
        if UserData.shared.userType != .fws {
            if title == "个人注册" {
                nextBtn.text("下一步")
            } else {
                nextBtn.text("下一步")
            }
        }
        v.layout(
            6.5,
            |-10-checkBtn.width(30).height(44)-0-label-0-protocolBtn.height(44),
            40,
            nextBtn.width(280).height(40).centerHorizontally(),
            >=0
        )
        checkBtn.addTarget(self, action: #selector(checkBtnClick(btn:)))
        protocolBtn.addTarget(self, action: #selector(protocolBtnClick(btn:)))
        nextBtn.addTarget(self, action: #selector(nextBtnClick(btn:)))
    }
}
// MARK: - 接口请求
extension PPSRegiestVC {
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
    
    
    /// 品牌商注册
    //注册
    func registerRequest() {
        var parameters: Parameters = [:]
        parameters["userName"] = userNameTF.text
        parameters["password"] = YZBSign.shared.passwordMd5(password: passwordTF.text ?? "")
        parameters["merchantType"] = "1" // 供应商类型 1品牌商 2服务商
        parameters["name"] = comNameTF.text
        parameters["cityId"] = cityModel?.id
        parameters["substationId"] = operatorModel?.id
        parameters["companyType"] = companyTypeNum
        parameters["servicephone"] = kfPhoneTF.text
        self.pleaseWait()
        let urlStr = APIURL.serviceRegisterStepOneV2
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let regiestId = Utils.getReadString(dir: dataDic, field: "id")
                
                let regiestBaseModel = RegisterBaseModel()
                let regiestModel = RegisterModel()
                regiestModel.id = regiestId
                regiestBaseModel.registerRData = regiestModel
                let vc = PPSRegiestSecondVC()
                vc.regiestBaseModel = regiestBaseModel
                self.navigationController?.pushViewController(vc)
            }
            else {
                self.getCodeBtn.isEnabled = true
                self.getCodeBtn.backgroundColor(.k2FD4A7)
                self.getCodeBtn.setTitle("获取验证码", for: .normal)
                
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
            self.getCodeBtn.isEnabled = true
            self.getCodeBtn.backgroundColor(.k2FD4A7)
            self.getCodeBtn.setTitle("获取验证码", for: .normal)
            if let timer = self.verificationTimer {
                if timer.isValid {
                    self.verificationTimer.invalidate()
                }
            }
        }
    }
}

extension PPSRegiestVC {
    //获取城市信息
    func getCityList1() {
        
        self.pleaseWait()
        let parameters: Parameters = [:]
        let urlStr = APIURL.findCityList

        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CityModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.cityList = modelArray
                self.configPickerViews()
                self.tableView.reloadData()
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
    func getOperatorList1() {
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
                
                if self.distLabel.text == "" {
                    if self.operatorList.count > 0 {
                        
                        self.distLabel.text = self.operatorList[0].name
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
}

// MARK: - 按钮点击方法
extension PPSRegiestVC {
    @objc private func passwordShowBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        passwordTF.isSecureTextEntry = !btn.isSelected
    }
    
    @objc private func surePasswordShowBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        surePasswordTF.isSecureTextEntry = !btn.isSelected
    }
    
    @objc private func getCodeBtnClick(btn: UIButton) {
        if phoneTF.text == "" {
            self.noticeOnlyText("请输入手机号码")
            return
        }
        
        codeTF.text = ""
        if Utils_objectC.isMobileNumber2(phoneTF.text) {
            getCodeBtn.isEnabled = false
            sendSMSCode()
            codeTF.becomeFirstResponder()
        } else{
            let popup = PopupDialog(title: phoneText, message: "手机号码有误,请检查您输入的手机号是否正确!", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
            let sureBtn = AlertButton(title: "确定") {
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    @objc private func nextBtnClick(btn: UIButton) {
        if userNameTF.text == "" {
            self.noticeOnlyText("请输入用户名")
            return
        }
        
        if userNameTF.text?.count ?? 0 < 6 || userNameTF.text?.count ?? 0 > 20  {
            self.noticeOnlyText("用户名格式不对")
            return
        }
        //是否包含字母
        let index = userNameText.index(userNameText.startIndex, offsetBy: 1)
        let firstStr = String(userNameText.prefix(upTo: index))
        let firstChar = firstStr.utf8.first
        if (firstChar! > 64 && firstChar! < 91) || (firstChar! > 96 && firstChar! < 123) {
            AppLog("首字符为字母")
        } else {
            self.noticeOnlyText("用户名格式不对")
            return
        }
        let expression = "^[0-9a-zA-Z_]{1,}$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: userNameText, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (userNameText as NSString).length))
        
        if numberOfMatches == 0 {
            
            self.noticeOnlyText("用户名格式不对")
            return
        }
        
        if passwordText.count < 6 || passwordText.count > 20 {
            self.noticeOnlyText("请输入6-20位密码")
            return
        }
        
        if surePasswordText == "" {
            self.noticeOnlyText("请输入确认密码")
            return
        }
        
        if passwordText != surePasswordText {
            self.noticeOnlyText("两次输入密码不一致")
            return
        }
        if cityModel == nil {
            self.noticeOnlyText("请选择地区")
            return
        }
        if operatorModel == nil && addressText != "全国" {
            self.noticeOnlyText("请选择区域")
            return
        }
        if typeText == "" {
            self.noticeOnlyText("请选择企业类型")
            return
        }
        
        if comNameText == "" {
            self.noticeOnlyText("请输入企业名称")
            return
        }
        
        if kfPhoneTF.text == "" {
            self.noticeOnlyText("请输入客服电话")
            return
        }
        
        if !checkBtn.isSelected {
            self.noticeOnlyText("请同意并勾选聚材道服务协议")
            return
        }
        registerRequest()
    }
    
    @objc private func checkBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        nextBtn.isEnabled = btn.isSelected
    }
    
    @objc private func protocolBtnClick(btn: UIButton) {
        let rootVC = AgreementViewController()
        let vc = BaseNavigationController.init(rootViewController: rootVC)
        rootVC.type = .protocl
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    @objc private func privacyBtnClick(btn: UIButton) {
        let rootVC = AgreementViewController()
        let vc = BaseNavigationController.init(rootViewController: rootVC)
        rootVC.type = .protocl1
        vc.modalPresentationStyle = .fullScreen
        navigationController?.present(vc, animated: true, completion: nil)
    }
}
