//
//  RegiestBaseInfoVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/18.
//

import UIKit
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

class RegiestBaseInfoVC: BaseViewController, UITextFieldDelegate, THPickerDelegate, CompanyTypePickerDelegate {
    var phone: String = ""
    var validCode: String?
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

    private var provModel: CityModel?               //省
    private var cityModel: CityModel?               //市
    private var distModel: CityModel?               //区
    private var provPickerView: THAreaPicker!
    private var pickerView: THAreaPicker!           //地址选择器
    private var operatorPickerView: THAreaPicker!   //运营商选择器
    private var provList: [CityModel] = []
    private var cityList: [CityModel] = []
    private var operatorList: [CityModel] = []
    private var operatorModel: CityModel?           //运营商
    private let provLabel = UILabel().text("请选择省份").textColor(.kColor99).font(14)
    private let addressLabel = UILabel().text("请选择地区").textColor(.kColor99).font(14)
    private let distLabel = UILabel().text("请选择区域").textColor(.kColor99).font(14)
    private let companyTypeLabel = UILabel().text("请选择性别").textColor(.kColor99).font(14)
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
    private var companyTypeText = ""
    
    var verificationTimer: Timer!           //验证码定时器
    var timerCount: NSInteger!              //倒计时
    var codeKey = ""                        //验证码key
    
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "基础信息"
        [userNameTF, passwordTF, surePasswordTF].forEach({
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
        getCityList1()
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
        if UserData.shared.userType != .fws {
            pickerView.cityArray = cityList
        }
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case userNameTF:
            userNameText = userNameTF.text ?? ""
        case passwordTF:
            passwordText = passwordTF.text ?? ""
        case surePasswordTF:
            surePasswordText = surePasswordTF.text ?? ""
        default:
            break
        }
    }
    
    //MARK: - THPickerDelegate
    
    func pickerViewSelectArea(pickerView:THAreaPicker, selectModel: CityModel, component: Int) {
        if UserData.shared.userType == .fws {
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
        } else {
            if pickerView == self.pickerView {
                cityModel = selectModel
                operatorModel = nil
                addressLabel.text(cityModel?.name ?? "").textColor(.kColor33)
                distLabel.text("请选择区域").textColor(.kColor99)
            }else if pickerView == self.operatorPickerView {
                operatorModel = selectModel
                distLabel.text(operatorModel?.name ?? "").textColor(.kColor33)
            }
        }
        
    }
    
    func pickerViewSelectCompanyType(pickerView: CompanyTypePicker, selectIndex: Int, component: Int) {
    }
}


extension RegiestBaseInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_username_icon"))
            cell.sv(starLabel, icon, userNameTF)
            userNameTF.text(userNameText)
            |-14-starLabel.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-userNameTF.height(44)-45-|
        case 1:
            let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_password"))
            let showBtn = UIButton().then {
                $0.setImage(#imageLiteral(resourceName: "regiest_unshow"), for: .normal)
                $0.setImage(#imageLiteral(resourceName: "regiest_show"), for: .selected)
            }
            cell.sv(starLabel, icon, passwordTF, showBtn)
            passwordTF.text(passwordText)
            |-14-starLabel.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-passwordTF.height(44)-0.5-showBtn.size(44)-0.5-|
            showBtn.addTarget(self, action: #selector(passwordShowBtnClick(btn:)))
        case 2:
            let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_surepassword"))
            let showBtn = UIButton().then {
                $0.setImage(#imageLiteral(resourceName: "regiest_unshow"), for: .normal)
                $0.setImage(#imageLiteral(resourceName: "regiest_show"), for: .selected)
            }
            cell.sv(starLabel, icon, surePasswordTF, showBtn)
            surePasswordTF.text(surePasswordText)
            |-14-starLabel.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-surePasswordTF.height(44)-0.5-showBtn.size(44)-0.5-|
            showBtn.addTarget(self, action: #selector(surePasswordShowBtnClick(btn:)))
        case 3:
            let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_select_address"))
            let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
            arrow.isUserInteractionEnabled = false
            cell.sv(starLabel, icon, addressLabel, arrow)
            if !addressText.isEmpty {
                addressLabel.text(addressText).textColor(.kColor33)
            } else {
                addressLabel.textColor(.kColor99)
            }
            |-14-starLabel.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-addressLabel.height(44)-0.5-arrow.size(44)-0.5-|
        case 4:
            let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "login_operator"))
            let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
            arrow.isUserInteractionEnabled = false
            cell.sv(starLabel, icon, distLabel, arrow)
            if !distText.isEmpty {
                distLabel.text(distText).textColor(.kColor33)
            } else {
                distLabel.textColor(.kColor99)
            }
            |-14-starLabel.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-distLabel.height(44)-0.5-arrow.size(44)-0.5-|
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 { // 选择城市
            if cityList.count > 0 {
                addressLabel.text = cityList[0].name
                cityModel = cityList.first
            }
            pickerView.showPicker()
        }
        if indexPath.section == 4 { // 选择地区
            if cityModel == nil {
                self.noticeOnlyText("请先选择地区")
                return
            }
            getOperatorList1()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 36.5
        } else if section == 4 {
            return 269
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 36.5))
            configTip(v: v, section: section)
            return v
        } else if section == 4 {
            nextBtn.isEnabled = false
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 269))
            configCheck(v: v, section: section)
            return v
        }
        return UIView()
    }
    
    func configTip(v: UIView, section: Int) {
        let tip = UILabel().text("6-20位字母开头，可使用字母、数字、下划线组合").textColor(.kColor99).font(12)
        if section == 2 {
            tip.text("6-20位字母开头或数字")
        }
        v.sv(tip)
        |-39-tip.centerVertically()
    }
    
    func configCheck(v: UIView, section: Int) {
        let label = UILabel().text("我已阅读并同意").textColor(.kColor99).font(10)
        let protocolBtn = UIButton().text("《服务协议》").textColor(.k2FD4A7).font(10)
        let privacyBtn = UIButton().text("《隐私条款》").textColor(.k2FD4A7).font(10)
        protocolBtn.text("《入驻协议》")
        privacyBtn.text("《隐私条款》")
        v.sv(checkBtn, label, protocolBtn, privacyBtn, nextBtn)
        nextBtn.text("确定")
        v.layout(
            6.5,
            |-10-checkBtn.width(30).height(44)-0-label-0-protocolBtn.height(44)-0-privacyBtn.height(44),
            40,
            |-30-nextBtn.height(50)-30-|,
            >=0
        )
        
        //nextBtn.corner(radii: 4).fillGreenColorLF()
        checkBtn.addTarget(self, action: #selector(checkBtnClick(btn:)))
        protocolBtn.addTarget(self, action: #selector(protocolBtnClick(btn:)))
        privacyBtn.addTarget(self, action: #selector(privacyBtnClick(btn:)))
        nextBtn.addTarget(self, action: #selector(nextBtnClick(btn:)))
    }
}

extension RegiestBaseInfoVC {
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
extension RegiestBaseInfoVC {
    @objc private func passwordShowBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        passwordTF.isSecureTextEntry = !btn.isSelected
    }
    
    @objc private func surePasswordShowBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        surePasswordTF.isSecureTextEntry = !btn.isSelected
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
        if cityModel == nil   {
            self.noticeOnlyText("请选择地区")
            return
        }
        if operatorModel == nil {
            self.noticeOnlyText("请选择区域")
            return
        }
        
        if !checkBtn.isSelected {
            self.noticeOnlyText("请同意并勾选聚材道服务协议")
            return
        }
        regiestRequest()
    }
    
    func regiestRequest() {
        var parameters = Parameters()
        parameters["cityId"] = cityModel?.id
        parameters["citySubstation"] = operatorModel?.id
        parameters["userName"] = userNameText
        parameters["password"] = YZBSign.shared.passwordMd5(password: passwordText)
        parameters["sex"] = "1"
        parameters["mobile"] = phone
        parameters["validateCode"] = validCode
        YZBSign.shared.request(APIURL.regiestV2, method: .post, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let tokenModel = Mapper<TokenModel1>().map(JSON: dataDic as! [String: Any])
                UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel)
                UserDefaults.standard.set(dataDic, forKey: UserDefaultStr.tokenModel1)
                UserData1.shared.tokenModel = tokenModel
                self.getUserInfoRequest()
            }
        } failure: { (error) in
            
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

