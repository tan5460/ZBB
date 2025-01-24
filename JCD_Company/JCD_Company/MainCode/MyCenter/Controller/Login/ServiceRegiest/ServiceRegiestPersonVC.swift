//
//  ServiceRegiestPersonVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper

class ServiceRegiestPersonVC: BaseViewController, UITextFieldDelegate, THPickerDelegate, CompanyTypePickerDelegate {
    var phone: String = ""
    var openId: String = ""
    var authLoginType: Int = 0
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
    private let phoneTF = UITextField().placeholder("请输入手机号").font(14).then {
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
    
    private let nickNameTF = UITextField().placeholder("请输入姓名").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
    }
    
    private var provModel: CityModel?               //省
    private var cityModel: CityModel?               //市
    private var distModel: CityModel?               //区
    private var provPickerView: THAreaPicker!
    private var pickerView: THAreaPicker!           //地址选择器
    private var operatorPickerView: THAreaPicker!   //运营商选择器
    private var companyTypePickerView: CompanyTypePicker!   //服务类型选择器
    private var companyTypes = ["工人",  "设计师", "工长"]
    private var companyTypePickerView1: CompanyTypePicker!   //公司类型选择器
    private var companyTypes1 = ["家装公司",  "工装公司", "家装/工装公司"]
    private var companyTypeNum = 5
    private var companyTypeNum1 = 1
    private var provList: [CityModel] = []
    private var cityList: [CityModel] = []
    private var operatorList: [CityModel] = []
    private var operatorModel: CityModel?           //运营商
    private let provLabel = UILabel().text("请选择省份").textColor(.kColor99).font(14)
    private let addressLabel = UILabel().text("请选择地区").textColor(.kColor99).font(14)
    private let distLabel = UILabel().text("请选择区域").textColor(.kColor99).font(14)
    private let typeLabel = UILabel().text("请选择服务类别").textColor(.kColor99).font(14)
    private let companyTypeLabel = UILabel().text("请选择公司类型").textColor(.kColor99).font(14)
    private let getCodeBtn = UIButton().text("获取验证码").textColor(.white).font(12).backgroundColor(.k2FD4A7)
    private let checkBtn = UIButton().then {
        $0.setImage(#imageLiteral(resourceName: "login_check"), for: .selected)
        $0.setImage(#imageLiteral(resourceName: "login_uncheck"), for: .normal)
    }
    private let nextBtn = UIButton().text("下一步").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_next_btn"))
    private var userNameText = ""
    private var passwordText = ""
    private var surePasswordText = ""
    private var phoneText = ""
    private var codeText = ""
    private var provText = ""
    private var addressText = ""
    private var distText = ""
    private var typeText = ""
    private var companyTypeText = ""
    private var nickNameText = ""
    
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
        
        [userNameTF, passwordTF, surePasswordTF, phoneTF, codeTF].forEach({
            $0.delegate = self
            $0.clearButtonMode = .whileEditing
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
        
        getProvList()
    }
    
    func configPickerViews() {
        
        //加一个全国的
        let countyModel = CityModel()
        countyModel.shortName = "全国"
        provList.insert(countyModel, at: 0)
        
        
        //选择器
        provPickerView = THAreaPicker()
        provPickerView.areaDelegate = self
        provPickerView.cityArray = provList
        
        view.addSubview(provPickerView)
        
        provPickerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        //选择器
        pickerView = THAreaPicker()
        pickerView.areaDelegate = self
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
        
        companyTypePickerView1 = CompanyTypePicker()
        companyTypePickerView1.delegate = self
        view.addSubview(companyTypePickerView1)
        
        companyTypePickerView1.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
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
        case nickNameTF:
            nickNameText = nickNameTF.text ?? ""
        default:
            break
        }
    }
    
    //MARK: - THPickerDelegate
    
    func pickerViewSelectArea(pickerView:THAreaPicker, selectModel: CityModel, component: Int) {
        if pickerView == provPickerView {
            provModel = selectModel
            provText = provModel?.shortName ?? ""
            provLabel.text(provText).textColor(.kColor33)
            cityModel = nil
            operatorModel = nil
            addressText = ""
            distText = ""
            if provText == "全国" {
                addressLabel.text(provText).textColor(.kColor99)
                distLabel.text(provText).textColor(.kColor99)
            } else {
                addressLabel.text("请选择地区").textColor(.kColor99)
                distLabel.text("请选择区域").textColor(.kColor99)
            }
        } else if pickerView == self.pickerView{
            cityModel = selectModel
            addressText = cityModel?.shortName ?? ""
            addressLabel.text(addressText).textColor(.kColor33)
            operatorModel = nil
            distText = ""
            if addressText == "全国" {
                distLabel.text(addressText).textColor(.kColor99)
            } else {
                distLabel.text("请选择区域").textColor(.kColor99)
            }
        }else if pickerView == operatorPickerView {
            operatorModel = selectModel
            distText = operatorModel?.shortName ?? ""
            distLabel.text(distText).textColor(.kColor33)
        }
        
    }
    
    func pickerViewSelectCompanyType(pickerView: CompanyTypePicker, selectIndex: Int, component: Int) {
        if pickerView == companyTypePickerView {
            typeText = companyTypes[selectIndex]
            typeLabel.text(typeText).textColor(.kColor33)
            companyTypeNum = selectIndex + 5
        } else {
            companyTypeText = companyTypes1[selectIndex]
            companyTypeLabel.text(companyTypeText).textColor(.kColor33)
            companyTypeNum1 = selectIndex + 1
        }
    }
}


extension ServiceRegiestPersonVC: UITableViewDelegate, UITableViewDataSource {
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
            let icon = UIImageView().image(#imageLiteral(resourceName: "fws_register_icon_1"))
            let titleLabel = UILabel().text("个人").textColor(UIColor.hexColor("#D6D6D6")).font(14)
            let arrow = UIImageView().image(#imageLiteral(resourceName: "fws_register_arrow_down"))
            cell.sv(icon, titleLabel, arrow)
            |-21-icon.size(17).centerVertically()-8-titleLabel.height(44)-(>=0)-arrow.width(11).height(6).centerVertically()-17-|
            
        case 1:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "login_companyType"))
            let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
            arrow.isUserInteractionEnabled = false
            cell.sv(star, icon, typeLabel, arrow)
            if !typeText.isEmpty {
                typeLabel.text(typeText).textColor(.kColor33)
            } else {
                typeLabel.textColor(.kColor99)
            }
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-typeLabel.height(44)-0.5-arrow.size(44)-0.5-|

        case 2:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_username_icon"))
            cell.sv(star, icon, userNameTF)
            userNameTF.text(userNameText)
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-userNameTF.height(44)-45-|
        case 3:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_password"))
            let showBtn = UIButton().then {
                $0.setImage(#imageLiteral(resourceName: "regiest_unshow"), for: .normal)
                $0.setImage(#imageLiteral(resourceName: "regiest_show"), for: .selected)
            }
            cell.sv(star, icon, passwordTF, showBtn)
            passwordTF.text(passwordText)
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-passwordTF.height(44)-0.5-showBtn.size(44)-0.5-|
            showBtn.addTarget(self, action: #selector(passwordShowBtnClick(btn:)))
        case 4:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_surepassword"))
            let showBtn = UIButton().then {
                $0.setImage(#imageLiteral(resourceName: "regiest_unshow"), for: .normal)
                $0.setImage(#imageLiteral(resourceName: "regiest_show"), for: .selected)
            }
            cell.sv(star, icon, surePasswordTF, showBtn)
            surePasswordTF.text(surePasswordText)
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-surePasswordTF.height(44)-0.5-showBtn.size(44)-0.5-|
            showBtn.addTarget(self, action: #selector(surePasswordShowBtnClick(btn:)))
        case 5:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_select_address"))
            let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
            arrow.isUserInteractionEnabled = false
            cell.sv(star, icon, provLabel, arrow)
            if !provText.isEmpty {
                provLabel.text(provText).textColor(.kColor33)
            } else {
                provLabel.textColor(.kColor99)
            }
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-provLabel.height(44)-0.5-arrow.size(44)-0.5-|
        case 6:
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
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-addressLabel.height(44)-0.5-arrow.size(44)-0.5-|
        case 7:
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
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-distLabel.height(44)-0.5-arrow.size(44)-0.5-|
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.section == 5 { // 选择省份
                if provText.isEmpty {
                    if provList.count > 0 {
                        provText = provList[0].shortName ?? ""
                        provLabel.text(provList[0].shortName ?? "").textColor(.kColor33)
                        provModel = provList.first
                    }
                }
                provPickerView.showPicker()
            }
            if indexPath.section == 6 { // 选择城市
                if provText == "全国" {
                    return
                }
                if provModel == nil {
                    self.noticeOnlyText("请先选择省份")
                    return
                }
                getCityList()
            }
            if indexPath.section == 7 { // 选择运营商
                if provText == "全国" {
                    return
                }
                if provModel == nil {
                    self.noticeOnlyText("请先选择省份")
                    return
                }
                if cityModel == nil {
                    self.noticeOnlyText("请先选择地区")
                    return
                }
                getOperatorList()
            }
            if indexPath.section == 1 { // 选择服务商
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
        if section == 2 || section == 3 {
            return 36.5
        } else if section == 7 {
            return 269
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 2 || section == 3 {
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
        if section == 3 {
            tip.text("6-20位字母开头或数字")
        }
        v.sv(tip)
        |-39-tip.centerVertically()
    }
    
    func configCheck(v: UIView, section: Int) {
        let label = UILabel().text("我已阅读并同意").textColor(.kColor99).font(10)
        let protocolBtn = UIButton().text("《入驻协议》").textColor(.k2FD4A7).font(10)
        v.sv(checkBtn, label, protocolBtn, nextBtn)
        nextBtn.text("下一步")
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
extension ServiceRegiestPersonVC {
    //获取省份信息
    func getProvList() {
        self.pleaseWait()
        let parameters: Parameters = [:]
        let urlStr = APIURL.getProvList
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CityModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.provList = modelArray
                self.configPickerViews()
            }else {
                self.getCityInfoFail()
            }
            
        }) { (error) in
            self.getCityInfoFail()
        }
    }
    
    
    //获取城市信息
    func getCityList() {
        self.pleaseWait()
        let parameters: Parameters = [:]
        let urlStr = APIURL.getCityListByProvId + (provModel?.id ?? "")
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CityModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.cityList = modelArray
                self.pickerView.cityArray = self.cityList
                self.pickerView.picker.reloadAllComponents()
                self.pickerView.showPicker()
            }else {
                self.getCityInfoFail()
            }
            
        }) { (error) in
            self.getCityInfoFail()
        }
    }
    
    private func getCityInfoFail() {
        let popup = PopupDialog(title: "获取信息失败！", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        let sureBtn = AlertButton(title: "确定") {
            self.navigationController?.popViewController(animated: true)
        }
        popup.addButtons([sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    //获取运营商信息
    func getOperatorList() {
        let parameters: Parameters = [:]
        let urlStr = APIURL.getSubstationListByCityId + (cityModel?.id ?? "")
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<SubstationModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                self.operatorList.removeAll()
                for model in modelArray {
                    let ctmodel = CityModel()
                    ctmodel.id = model.id
                    ctmodel.shortName = model.groupName
                    self.operatorList.append(ctmodel)
                }
                
                if self.distText.isEmpty {
                    if self.operatorList.count > 0 {
                        self.distText = self.operatorList[0].shortName ?? ""
                        self.distLabel.text(self.distText).textColor(.kColor33)
                        self.operatorModel = self.operatorList.first
                    }
                }
                self.operatorPickerView.cityArray = self.operatorList
                self.operatorPickerView.picker.reloadAllComponents()
                self.operatorPickerView.showPicker()
                
            }else {
                self.getOperatorFail()
            }
        }) { (error) in
            self.getOperatorFail()
        }
    }
    
    func getOperatorFail() {
        let popup = PopupDialog(title: "获取城市运营商失败！", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        let sureBtn = AlertButton(title: "确定") {
            
        }
        popup.addButtons([sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    //注册
    func registerRequest() {
        var parameters: Parameters = [:]
        parameters["userName"] = userNameTF.text
        parameters["password"] = YZBSign.shared.passwordMd5(password: passwordTF.text ?? "")
        parameters["merchantType"] = "2" // 供应商类型 1品牌商 2服务商
        parameters["isComFlag"] = "2"
        parameters["serviceType"] = "\(companyTypeNum)"
        if provModel?.id != nil {
            parameters["provId"] = provModel?.id
            parameters["cityId"] = cityModel?.id
            parameters["substationId"] = operatorModel?.id
        }
        self.pleaseWait()
        let urlStr = APIURL.serviceRegisterStepOneV2
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let regiestId = Utils.getReadString(dir: dataDic, field: "id")
                switch self.companyTypeNum {
                case 5:
                    let vc = ServiceRegiestWorkerVC()
                    vc.regiestId = regiestId
                    self.navigationController?.pushViewController(vc)
                case 6:
                    let vc = ServiceRegiestDesignVC()
                    vc.regiestId = regiestId
                    self.navigationController?.pushViewController(vc)
                case 7:
                    let vc = ServiceRegiestForemanVC()
                    vc.regiestId = regiestId
                    self.navigationController?.pushViewController(vc)
                default:
                    break
                }
            }
            
        }) { (error) in
        }
    }
}

extension ServiceRegiestPersonVC {
    //获取城市信息
    func getCityList1() {
        
        self.pleaseWait()
        let parameters: Parameters = [:]
        let urlStr = APIURL.findCityList
        //        parameters["mobile"] = UserData.shared.substationModel?.mobile
        //        parameters["realName"] = UserData.shared.substationModel?.realName
        //        parameters["cityId"] = UserData.shared.substationModel?.cityId
        
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
extension ServiceRegiestPersonVC {
    @objc private func passwordShowBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        passwordTF.isSecureTextEntry = !btn.isSelected
    }
    
    @objc private func surePasswordShowBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        surePasswordTF.isSecureTextEntry = !btn.isSelected
    }
    
    @objc private func nextBtnClick(btn: UIButton) {
        view.endEditing(true)
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
        if provModel == nil {
            self.noticeOnlyText("请选择省份")
            return
        }
        if cityModel == nil &&  provText != "全国"  {
            self.noticeOnlyText("请选择地区")
            return
        }
        if operatorModel == nil && provText != "全国" {
            self.noticeOnlyText("请选择区域")
            return
        }
        if typeText == "" {
            self.noticeOnlyText("请选择服务类别")
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
