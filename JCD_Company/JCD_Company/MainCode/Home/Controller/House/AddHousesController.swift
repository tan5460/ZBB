//
//  AddHousesController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/8.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import PopupDialog
import Photos
import AVFoundation
import ObjectMapper

class AddHousesController: BaseViewController,UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, THPickerDelegate {
    
    
    var selectedHouseBlock: ((_ houseModel: HouseModel?)->())?      //选择工地block
    var tableView : UITableView!
    let identifier1 = "HeadPortraitCell"
    let identifier2 = "AddCustomCell"
    let identifier3 = "NewUserInfoCell"
    
    var acitivityType = 1
    var houseModel: HouseModel?
    var introTextView: UITextView?          //简介
    var addressTextView: UITextView?        //工地地址
    var expressAddTextView: UITextView?     //收货地址
    var userModel: CustomModel?             //用户Model
    
    var headPicUrl: String?
    var sexString: String?
    private var provModel: CityModel?               //省
    private var cityModel: CityModel?               //市
    private var distModel: CityModel?               //区
    private var provPickerView: THAreaPicker?
    private var cityPickerView: THAreaPicker?
    private var distPickerView: THAreaPicker?
    private var provList: [CityModel] = []
    private var cityList: [CityModel] = []
    private var distList: [CityModel] = []
    var modifyHouseBlock: ((_ houseModel: HouseModel)->())?       //编辑工地block
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if houseModel == nil {
            houseModel = HouseModel()
        }else {
            self.title = (houseModel?.customName ?? "未知") + "的工地"
        }
        if userModel == nil {
            userModel = CustomModel()
        }
        prepareTableView()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        
        loadProvList()
    }
    //获取省份列表
    private func loadProvList() {
        
        self.pleaseWait()
        let parameters: Parameters = [:]
        let urlStr = APIURL.getAllProvList
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CityModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.provList = modelArray
                self.configPickerViews()
            }
        }) { (error) in
        }
    }
    
    //获取城市列表
    private func loadCityList() {
        self.pleaseWait()
        let parameters: Parameters = [:]
        let urlStr = APIURL.getAllCityList + "\(provModel?.id ?? "")"
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CityModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.cityList = modelArray
                self.cityPickerView?.cityArray = modelArray
                self.cityPickerView?.picker.reloadAllComponents()
                self.cityPickerView?.showPicker()
            }
        }) { (error) in
        }
    }
    
    //获取地区列表
    private func loadDistList() {
        self.pleaseWait()
        let parameters: Parameters = [:]
        let urlStr = APIURL.getAllDistList + "\(cityModel?.id ?? "")"
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CityModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.distList = modelArray
                self.distPickerView?.cityArray = modelArray
                self.distPickerView?.picker.reloadAllComponents()
                self.distPickerView?.showPicker()
            }
        }) { (error) in
        }
    }
    
    func configPickerViews() {
        //选择器
        provPickerView = THAreaPicker()
        provPickerView?.areaDelegate = self
        provPickerView?.cityArray = provList
        view.addSubview(provPickerView!)
        
        provPickerView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        //选择器
        cityPickerView = THAreaPicker()
        cityPickerView?.areaDelegate = self
        view.addSubview(cityPickerView!)
        
        cityPickerView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        distPickerView = THAreaPicker()
        distPickerView?.areaDelegate = self
        view.addSubview(distPickerView!)
        
        distPickerView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    func pickerViewSelectArea(pickerView: THAreaPicker, selectModel: CityModel, component: Int) {
        if pickerView == provPickerView {
            provModel = selectModel
            self.houseModel?.provinceId = selectModel.id
            self.houseModel?.provinceName = selectModel.areaName
            cityModel = nil
            distModel = nil
            self.houseModel?.cityId = nil
            self.houseModel?.cityName = nil
            self.houseModel?.areaName = nil
            self.houseModel?.areaId = nil
            tableView.reloadData()
            loadCityList()
        } else if pickerView == cityPickerView {
            cityModel = selectModel
            self.houseModel?.cityId = selectModel.id
            self.houseModel?.cityName = selectModel.areaName
            distModel = nil
            self.houseModel?.areaName = nil
            self.houseModel?.areaId = nil
            tableView.reloadData()
            loadDistList()
        } else if pickerView == distPickerView {
            distModel = selectModel
            self.houseModel?.areaId = selectModel.id
            self.houseModel?.areaName = selectModel.areaName
            tableView.reloadData()
        }
    }
    
    @objc func backAction() {
        let popup = PopupDialog(title: "提示", message: "当前信息未保存，是否返回上一页？",buttonAlignment: .horizontal)
        
        let sureBtn = DestructiveButton(title: "返回") {
            
            self.navigationController?.popViewController(animated: true)
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    func prepareTableView() {
        
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        let saveBtn = UIButton()
        saveBtn.setBackgroundImage(backgroundImg, for: .normal)
        saveBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        saveBtn.setTitle("保存", for: .normal)
        saveBtn.setTitleColor(UIColor.white, for: .normal)
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        view.addSubview(saveBtn)
        
        saveBtn.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(0)
            }
            make.right.left.equalTo(0)
            make.height.equalTo(44)
        }
        
        
        tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = PublicColor.backgroundViewColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        
        tableView.separatorStyle = .none
        
        tableView.register(HeadPortraitCell.self, forCellReuseIdentifier: identifier1)
        tableView.register(AddCustomCell.self, forCellReuseIdentifier: identifier2)
        tableView.register(NewUserInfoCell.self, forCellReuseIdentifier: identifier3)
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(saveBtn.snp.top)
        }
        
    }
    
    //MARK: - UITableViewDelegate && UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.userModel!.id != nil {
                return 0
            }
            return 4
        }else if section == 1 {
            return 1
        }else if section == 2 {
            if self.houseModel?.lat == nil || self.houseModel?.lon == nil {
                return 0
            }
        }else if section == 3 {
            if UserData.shared.userType == .cgy || acitivityType == 2 || acitivityType == 3 {
                return 4
            }else {
                return 0
            }
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier1) as! HeadPortraitCell
                if let imageStr = houseModel?.headUrl {
                    if let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
                        cell.iconImgView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "imageRow_camera"))
                    }
                }
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier2) as! AddCustomCell
            cell.line.isHidden = false
            if indexPath.row == 1 {
                cell.leftLabel?.text = "姓名"
                cell.rightTextField.isUserInteractionEnabled = true
                cell.rightTextField?.placeholder = "请输入姓名"
                cell.rightTextField.keyboardType = .default
                if let str = houseModel?.customName {
                    cell.rightTextField?.text = str
                    cell.rightTextField.isUserInteractionEnabled = false
                }
                
                cell.textFieldChangeBlock = {(text) in
                    self.userModel?.realName = text
                }
                
            }else if indexPath.row == 2 {
                cell.leftLabel?.text = "手机"
                cell.rightTextField.isUserInteractionEnabled = true
                cell.rightTextField?.placeholder = "请输入手机号"
                cell.rightTextField.keyboardType = .phonePad
                if let str = houseModel?.customMobile {
                    cell.rightTextField?.text = str
                }
                cell.textFieldChangeBlock = {(text) in
                    self.userModel?.tel = text
                }
                
            }else if indexPath.row == 3 {
                cell.leftLabel?.text = "性别"
                cell.rightTextField.isUserInteractionEnabled = false
                cell.rightTextField?.text = "男"
                if(AppData.sexList.count>0){
                    cell.rightTextField?.text = Utils.getReadString(dir: AppData.sexList[0], field: "label")
                    if let index = Int(houseModel?.customSex ?? "") {
                        if index > 0 && index <= AppData.sexList.count {
                            cell.rightTextField?.text = Utils.getReadString(dir: AppData.sexList[index-1], field: "label")
                        }
                    }
                }
                self.sexString = cell.rightTextField?.text
            }
            
            return cell
            
        }else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier3) as! NewUserInfoCell
            
            cell.leftLabel.text = "工地位置"
            cell.rightLabel.text = "请在地图上选择"
            cell.line.isHidden = true
            
            if self.houseModel?.lat != nil && self.houseModel?.lon != nil {
                cell.line.isHidden = false
                var lat = "" , lon = ""
                if let latStr = self.houseModel?.lat {
                    lat = latStr
                }
                if let lonStr = self.houseModel?.lon {
                    lon = lonStr
                }
                cell.rightLabel.text = lat + "," + lon
            }
            
            return cell
        } else if indexPath.section == 3 {
            if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier3) as! NewUserInfoCell
                cell.leftLabel.text = "请选择省市区"
                if let provinceName = self.houseModel?.provinceName {
                   // cell.rightLabel.text = "\(provModel?.areaName ?? "") \(cityModel?.areaName ?? "") \(distModel?.areaName ?? "")"
                    cell.rightLabel.text = "\(provinceName) \(self.houseModel?.cityName ?? "") \(self.houseModel?.areaName ?? "")"
                }
                if !(cell.rightLabel.text?.isEmpty ?? false) {
                    cell.rightLabel.textColor(.kColor33)
                }
                cell.line.isHidden = false
                return cell
            }
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier2) as! AddCustomCell
        if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                cell.leftLabel?.text = "小区名"
                cell.rightTextField.isUserInteractionEnabled = true
                cell.rightTextField?.placeholder = "请填写小区名"
                cell.line.isHidden = false
                cell.rightTextField.keyboardType = .default
                if let name = self.houseModel?.plotName {
                    cell.rightTextField.text = name
                }
                
                cell.textFieldChangeBlock = {(text) in
                    self.houseModel?.plotName = text
                }
                
            }else if indexPath.row == 1 {
                cell.leftLabel?.text = "楼房栋号"
                cell.rightTextField.isUserInteractionEnabled = true
                cell.rightTextField?.placeholder = "XX栋XX单元XX号"
                cell.rightTextField.keyboardType = .default
                cell.line.isHidden = false
                if let roomNo = self.houseModel?.roomNo {
                    cell.rightTextField.text = roomNo
                }
                
                cell.textFieldChangeBlock = {(text) in
                    self.houseModel?.roomNo = text
                }
                
            }else if indexPath.row == 2 {
                cell.leftLabel?.text = "面积(平米)"
                cell.rightTextField.isUserInteractionEnabled = true
                cell.rightTextField?.placeholder = "请填写面积"
                cell.rightTextField.keyboardType = .decimalPad
                if let space = self.houseModel?.space {
                    cell.rightTextField.text = String(format: "%.2f", Float(truncating: space))
                    
                }
                cell.line.isHidden = true
                
                cell.textFieldChangeBlock = {(text) in
                    if let valueStr = Double.init(text) {
                        self.houseModel?.space = NSNumber(value: valueStr)
                    }
                }
            }
        }else {
            if indexPath.row == 0 {
                cell.leftLabel?.text = "收货人"
                cell.rightTextField.isUserInteractionEnabled = true
                cell.rightTextField?.placeholder = "请输入收货人姓名"
                cell.line.isHidden = false
                cell.rightTextField.keyboardType = .default
                if let name = self.houseModel?.expressName{
                    cell.rightTextField.text = name
                }
                cell.textFieldChangeBlock = {(text) in
                    self.houseModel?.expressName = text
                }
                
            } else if indexPath.row == 1 {
                cell.leftLabel?.text = "收货人手机号"
                cell.rightTextField.isUserInteractionEnabled = true
                cell.rightTextField?.placeholder = "请输入收货人手机号"
                cell.rightTextField.keyboardType = .phonePad
                cell.isTelNumber = true
                if let expressTel = self.houseModel?.expressTel {
                    cell.rightTextField.text = expressTel
                }
                cell.textFieldChangeBlock = {(text) in
                    self.houseModel?.expressTel = text
                }
            }else if indexPath.row == 2 {
                cell.leftLabel?.text = "收货人座机"
                cell.rightTextField.isUserInteractionEnabled = true
                cell.rightTextField?.placeholder = "非必填"
                cell.rightTextField.keyboardType = .phonePad
                cell.line.isHidden = false
                //TODO:座机
                if let expressTel = self.houseModel?.expressPhone {
                    cell.rightTextField.text = expressTel
                }
                cell.textFieldChangeBlock = {(text) in
                    self.houseModel?.expressPhone = text
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            if self.userModel!.id != nil {
                return 10
            }
            return 85
        }else if section == 1 {
            if self.houseModel?.plotId == nil {
                return 0
            }
            return 85
        }else if section == 3 {
            if UserData.shared.userType == .cgy  || acitivityType == 2 || acitivityType == 3  {
                return 85
            }
            return 0
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footView = UIView()
        
        if section == 2 {
            return footView
        }else if section == 0 {
            if self.userModel!.id != nil {
                return footView
            }
        }else if section == 1 {
            if self.houseModel?.plotId == nil {
                return footView
            }
        }
        
        let footBgView = UIView()
        footBgView.backgroundColor = .white
        footView.addSubview(footBgView)
        footBgView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(-10)
            
        }
        
        let textView = UITextView()
        textView.textColor = PublicColor.commonTextColor
        textView.font = UIFont.systemFont(ofSize: 15)
        footBgView.addSubview(textView)
        
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.left.equalTo(12)
            make.right.bottom.equalTo(-11)
            
        }
        
        //提示
        let placeholderLabel = UILabel()
        placeholderLabel.text = "简介"
        placeholderLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xB2B2B2)
        placeholderLabel.font = textView.font
        
        
        if section == 0 {
            
            placeholderLabel.text = "简介"
            
            if let intro = userModel?.intro {
                if intro.count > 0 {
                    textView.text = intro
                    placeholderLabel.isHidden = true
                }
            } else if let intro = houseModel?.intro {
                if intro.count > 0 {
                    textView.text = intro
                    placeholderLabel.isHidden = true
                }
            }
            introTextView = textView
            
        }else if section == 1 {
            
            placeholderLabel.text = "请填写详细地址"
            
            if let adr = self.houseModel?.address {
                textView.text = adr
            }
            addressTextView = textView
            
        }else if section == 3 {
            placeholderLabel.text = "请填写详细地址：如街道，小区，门牌号等"
            
            if let adr = self.houseModel?.expressAdd {
                textView.text = adr
            }
            expressAddTextView = textView
        }
        textView.placeHolderEx = placeholderLabel.text
        
        return footView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {// 头像
                DispatchQueue.main.async {
                    self.addIcon()
                }
            }else if indexPath.row == 1 {
                
            }else if indexPath.row == 2 {
                
            }else if indexPath.row == 3 {
                DispatchQueue.main.async {
                    self.selectSex()
                }
            }
        }else if indexPath.section == 1 {
            let vc = SelectMapPlaceController()
            vc.selectPlaceModel = houseModel?.plot
            vc.isSearchBiotope = true
            vc.onDismissback = {[weak self] (plot) in
                self?.houseModel?.plot = plot
                self?.houseModel?.lat = plot?.lat
                self?.houseModel?.lon = plot?.lon
                self?.houseModel?.plotName = plot?.name
                self?.houseModel?.plotId = plot?.id

                //获取城市
                var getAreaName = ""
                var getCityName = ""
                var getDistrictName = ""
                //省
                if let areaName = self?.houseModel?.plot?.prov?.name {
                    getAreaName = areaName
                }
                
                //市
                if let cityName = self?.houseModel?.plot?.city?.name {
                    getCityName = cityName
                }
                //区
                if let districtName = self?.houseModel?.plot?.dist?.name {
                    getDistrictName = districtName
                }
                
                var address = getAreaName + getCityName + getDistrictName
                
                if let adr = self?.houseModel?.plot?.address {
                    address = address + adr
                }
                self?.houseModel?.address = address
                
                self?.tableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 3 {
            if indexPath.row == 3 {
                if provModel == nil {
                    provPickerView?.showPicker()
                } else if cityModel == nil {
                    cityPickerView?.showPicker()
                } else if distModel == nil {
                    distPickerView?.showPicker()
                } else {
                    provPickerView?.showPicker()
                }
            }
        }
    }
    
    //MARK: 相机，相册
    func addIcon()  {
        
        picker.delegate = self
        
        let alertAction = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alertAction.addAction(UIAlertAction.init(title: "选择相机", style: .default, handler: { (alertCamera) in
            self.judgeCameraAuthorization()
        }))
        
        alertAction.addAction(UIAlertAction.init(title: "选择相册", style:.default, handler: { (alertPhpto) in
            
            self.judgePhotoLibraryAuthorization()
        }))
        
        alertAction.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (alertCancel) in
            
        }))
        if IS_iPad {
            let cell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! HeadPortraitCell
            alertAction.popoverPresentationController!.sourceView = cell.iconImgView
            alertAction.popoverPresentationController!.sourceRect = cell.iconImgView.bounds
        }
        
        self.present(alertAction, animated: true, completion: nil)
    }
    
    
    // MARK: ImagePicker Delegate 选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let chosenImage =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            picker.dismiss(animated: true) {
                
            }
            //处理传入后台
            var image = chosenImage
            AppLog("照片原尺寸: \(image.size)")
            image = image.resizeImage() ?? image
            AppLog("照片压缩后尺寸: \(image.size)")
            
            let type = "company/customer/header"
            
            YZBSign.shared.upLoadImageRequest(oldUrl: self.userModel?.headUrl, imageType: type, image: image, success: { (response) in
                
                if self.userModel == nil {
                    self.userModel = CustomModel()
                }
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.headPicUrl = headStr
                self.noticeSuccess("上传头像成功", autoClear: true, autoClearTime: 1)
                
                let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! HeadPortraitCell
                if let imageUrl = URL(string: APIURL.ossPicUrl + headStr) {
                    cell.iconImgView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "imageRow_camera"))
                }
                
            }, failture: { (error) in
                
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                
            })
        }
    }
    
    
    // MARK: 选择性别
    func selectSex() {
        
        if(AppData.sexList.count>0){
            var sexLabel = ""
            if let index = userModel?.sex?.intValue {
                if index > 0 && index <= AppData.sexList.count {
                    sexLabel = Utils.getReadString(dir: AppData.sexList[index-1], field: "label")
                }
            }
            let alertAction = UIAlertController.init(title: "选择性别", message: nil, preferredStyle: .actionSheet)
            for sex in AppData.sexList {
                let sexStr = Utils.getReadString(dir: sex, field: "label")
                
                if sexStr == sexLabel {
                    alertAction.addAction(UIAlertAction.init(title: sexStr, style: .destructive, handler: { (alertCamera) in
                        
                    }))
                }else {
                    alertAction.addAction(UIAlertAction.init(title: sexStr, style: .default, handler: { (alertCamera) in
                        self.sexString = alertCamera.title
                        let cell = self.tableView.cellForRow(at: IndexPath.init(row: 3, section: 0)) as! AddCustomCell
                        cell.rightTextField.text = self.sexString
                        
                    }))
                }
                
            }
            
            alertAction.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (alertCancel) in
                
            }))
            if IS_iPad {
                let cell = tableView.cellForRow(at: IndexPath.init(row: 3, section: 0)) as! AddCustomCell
                alertAction.popoverPresentationController!.sourceView = cell.rightTextField
                alertAction.popoverPresentationController!.sourceRect = cell.rightTextField.bounds
            }
            self.present(alertAction, animated: true, completion: nil)
        }
    }
    // MARK: 保存数据
    @objc func saveAction() {
        
        if introTextView != nil {
            if introTextView!.text.count > 0 {
                self.userModel?.intro = introTextView!.text
            }
        }
        
        if houseModel?.customId == nil {
            if let nameCell = tableView.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? AddCustomCell {
                let realName = nameCell.rightTextField.text
                userModel?.realName = realName
            }
            
            if let mobileCell = tableView.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? AddCustomCell {
                let mobile = mobileCell.rightTextField.text
                userModel?.tel = mobile
            }
            
            let sexStr = self.sexString ?? ""
            let sexArray = Utils.getFieldArrInDirArr(arr: AppData.sexList, field: "label")
            if let si = sexArray.firstIndex(of: sexStr){
                userModel?.sex = NSNumber(value: si)
            }
        }
        
        if let plotNameCell = tableView.cellForRow(at: IndexPath.init(row: 0, section: 2)) as? AddCustomCell {
            let plotName = plotNameCell.rightTextField.text
            houseModel?.plotName = plotName
        }
        
        if let roomNoCell = tableView.cellForRow(at: IndexPath.init(row: 1, section: 2)) as? AddCustomCell {
            let roomNo = roomNoCell.rightTextField.text
            houseModel?.roomNo = roomNo
        }
        
        var space: String?
        if let spaceCell = tableView.cellForRow(at: IndexPath.init(row: 2, section: 2)) as? AddCustomCell {
            space = spaceCell.rightTextField.text
            if let valueStr = Double.init(space!) {
                houseModel?.space = NSNumber(value: valueStr)
            }
        }
        
        houseModel?.expressAdd = expressAddTextView?.text
        
        if houseModel?.customId == nil {
            
            if userModel?.realName == nil || userModel?.realName == "" {
                self.noticeOnlyText("姓名不能为空")
                return
            }
            
            if userModel?.tel == nil || userModel?.tel == "" {
                self.noticeOnlyText("手机号不能为空")
                return
            }else {
                if !Utils_objectC.isMobileNumber2(userModel?.tel) {
                    self.noticeOnlyText("请输入正确的手机号!")
                    return
                }
                
            }
            
            if userModel?.sex == nil {
                self.noticeOnlyText("请选择性别")
                return
            }
        }
        
        if self.houseModel?.lat == nil || self.houseModel?.lon == nil {
            self.noticeOnlyText("请选择位置")
            return
        }
        
        if houseModel?.address == nil || houseModel?.address == "" {
            self.noticeOnlyText("请填写详细地址")
            return
        }
        
        if houseModel?.plotName == nil || houseModel?.plotName == "" {
            self.noticeOnlyText("请填写小区名")
            return
        }
        
        if houseModel?.roomNo == nil || houseModel?.roomNo == "" {
            self.noticeOnlyText("请填写楼栋房号")
            return
        }
        
        if space == "" {
            self.noticeOnlyText("请填写面积")
            return
        }else if Double.init(space!) == nil {
            self.noticeOnlyText("面积格式错误")
            return
        }
        
        if UserData.shared.userType == .cgy  || acitivityType == 2 || acitivityType == 3  {
            
            if houseModel?.expressName == nil || houseModel?.expressName == "" {
                self.noticeOnlyText("请填写收货人姓名")
                return
            }
            
            if houseModel?.expressTel == nil || houseModel?.expressTel == "" {
                self.noticeOnlyText("请填写收货人手机号")
                return
            }
            else if houseModel?.expressTel?.isPhoneNumber() == false {
                self.noticeOnlyText("收货人手机号格式错误")
                return
            }
            if houseModel?.provinceId == nil {
                noticeOnlyText("请选择收货人省份")
                return
            }
            if houseModel?.cityId == nil {
                noticeOnlyText("请选择收货人城市")
                return
            }
            if houseModel?.areaId == nil {
                noticeOnlyText("请选择收货人地区")
                return
            }
            
            if houseModel?.expressAdd == nil || houseModel?.expressAdd == "" {
                self.noticeOnlyText("请填写收货人详细地址")
                return
            }
        }
        if userModel?.id == nil {
            if houseModel?.customId == nil {
                saveCusAndHouseData()
            }else {
                saveHouseData()
            }
        } else {
            saveHouseWithCustomId()
        }
        
        
    }
    
    func saveCusAndHouseData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        
        var storeID = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeID = valueStr
        }
        
        var parameters: Parameters = [:]
        parameters["workerId"] = userId
        parameters["storeId"] = storeID
        
        if let valueStr = self.headPicUrl {
            parameters["headUrl"] = valueStr
        }
        
        if let valueStr = userModel?.realName {
            parameters["realName"] = valueStr
        }
        if let valueStr = userModel?.qq {
            parameters["qq"] = valueStr
        }
        if let valueStr = userModel?.tel {
            parameters["mobile"] = valueStr
        }
        
        if let valueStr = userModel?.sex?.intValue {
            if valueStr == 0 {
                parameters["sex"] = 1
            } else {
                parameters["sex"] = valueStr
            }
        }
        if let valueStr = userModel?.intro {
            parameters["intro"]  = valueStr
        }
        
        parameters["house.space"] = houseModel?.space
        parameters["house.roomNo"] = houseModel?.roomNo
        parameters["house.houseType"] = houseModel?.houseType
        parameters["house.layout"] = houseModel?.layout
        parameters["house.styleType"] = houseModel?.styleType
        parameters["house.plotName"] = houseModel?.plotName
        parameters["house.address"] = houseModel?.address
        parameters["house.lon"] = houseModel?.lon
        parameters["house.lat"] = houseModel?.lat
        parameters["plot.provId"] = houseModel?.plot?.prov?.id
        parameters["plot.cityId"] = houseModel?.plot?.city?.id
        parameters["plot.distId"] = houseModel?.plot?.dist?.id
        
        if UserData.shared.userType == .cgy  || acitivityType == 2 || acitivityType == 3  {
            
            if let valueStr = houseModel?.expressName {
                parameters["house.expressName"] = valueStr
            }
            
            if let valueStr = houseModel?.expressTel {
                parameters["house.expressTel"] = valueStr
            }
            
            if let valueStr = houseModel?.expressAdd {
                parameters["house.expressAdd"] = valueStr
            }
            
            if let valueStr = houseModel?.expressPhone {
                parameters["house.expressPhone"] = valueStr
            }
            parameters["house.provinceId"] = houseModel?.provinceId
            parameters["house.cityId"] = houseModel?.cityId
            parameters["house.areaId"] = houseModel?.areaId
            
        }
        
        self.pleaseWait()
        let urlStr = APIURL.companyCusAndHouseSave
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let houseDic = Utils.getReadDic(data: dataDic, field: "house")
                let model = Mapper<HouseModel>().map(JSON: houseDic as! [String : Any])
                model?.customName = dataDic["realName"] as? String
                model?.customMobile = dataDic["mobile"] as? String
                model?.headUrl = dataDic["headUrl"] as? String
                let msg = "添加成功"
                let popup = PopupDialog(title: msg, message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    if let block = self.modifyHouseBlock {
                        block(model!)
                    }
                    if let vcs = self.navigationController?.viewControllers {
                        for vc in vcs {
                            if vc.isKind(of: PlaceOrderController.classForCoder()) {
                                self.selectedHouseBlock?(model)
                                self.navigationController?.popToViewController(vc, animated: true)
                            } else if vc.isKind(of: WantPurchaseController.classForCoder()) {
                                self.selectedHouseBlock?(model)
                                self.navigationController?.popToViewController(vc, animated: true)
                            } else if vc.isKind(of: HouseViewController.classForCoder()) {
                                self.selectedHouseBlock?(model)
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
            
        }
    }
    
    
    func saveHouseWithCustomId() {
        var parameters: Parameters = [:]
        parameters["storeId"] = UserData.shared.storeModel?.id
        parameters["workerId"] = UserData.shared.workerModel?.id
        parameters["space"] = houseModel?.space
        parameters["plotName"] = houseModel?.plotName
        parameters["roomNo"] = houseModel?.roomNo
        parameters["customId"] = userModel?.id
        parameters["customName"] = userModel?.realName
        parameters["customSex"] = userModel?.sex
        parameters["customMobile"] = userModel?.mobile
        parameters["lat"] = houseModel?.lat
        parameters["lon"] = houseModel?.lon
        parameters["address"] = houseModel?.address
        if houseModel?.id != nil {
            parameters["id"] = houseModel?.id
        }
        if let valueStr = houseModel?.expressName {
            parameters["expressName"] = valueStr
        }
        if let valueStr = houseModel?.expressTel {
            parameters["expressTel"] = valueStr
        }
        if let valueStr = houseModel?.expressAdd {
            parameters["expressAdd"] = valueStr
        }
        
        if let valueStr = houseModel?.expressPhone {
            parameters["expressPhone"] = valueStr
        }
        parameters["provinceId"] = houseModel?.provinceId
        parameters["cityId"] = houseModel?.cityId
        parameters["areaId"] = houseModel?.areaId
        self.pleaseWait()
        let urlStr =  APIURL.addHouseWithCustomId
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model = Mapper<HouseModel>().map(JSON: dataDic as! [String : Any])
                model?.customName = self.userModel?.realName
                model?.customMobile = self.userModel?.mobile
                var msg: String?
                if self.houseModel?.customId == nil {
                    msg = "添加成功"
                }else {
                    msg = "保存成功"
                }
                
                let popup = PopupDialog(title: msg, message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    
                    if let block = self.modifyHouseBlock {
                        block(model!)
                    }
                    if  let vcs = self.navigationController?.viewControllers {
                        for vc in vcs {
                            if vc.isKind(of: PlaceOrderController.classForCoder()) {
                                self.selectedHouseBlock?(model)
                                self.navigationController?.popToViewController(vc, animated: true)
                            } else if vc.isKind(of: WantPurchaseController.classForCoder()) {
                                self.selectedHouseBlock?(model)
                                self.navigationController?.popToViewController(vc, animated: true)
                            } else if vc.isKind(of: HouseViewController.classForCoder()) {
                                self.selectedHouseBlock?(model)
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }else {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
    }
    
    func saveHouseData() {
        var parameters: Parameters = [:]
        parameters["id"] = houseModel?.id
        parameters["spec"] = houseModel?.space
        parameters["roomNo"] = houseModel?.roomNo
        parameters["address"] = houseModel?.address
        parameters["plotName"] = houseModel?.plotName
        parameters["lat"] = houseModel?.lat
        parameters["lon"] = houseModel?.lon
        if let valueStr = houseModel?.expressName {
            parameters["expressName"] = valueStr
        }
        
        if let valueStr = houseModel?.expressTel {
            parameters["expressTel"] = valueStr
        }
        
        if let valueStr = houseModel?.expressAdd {
            parameters["expressAdd"] = valueStr
        }
        
        if let valueStr = houseModel?.expressPhone {
            parameters["expressPhone"] = valueStr
        }
        parameters["provinceId"] = houseModel?.provinceId
        parameters["cityId"] = houseModel?.cityId
        parameters["areaId"] = houseModel?.areaId
        self.pleaseWait()
        let urlStr =  APIURL.saveHouse
        
        YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model = Mapper<HouseModel>().map(JSON: dataDic as! [String : Any])
                
                var msg: String?
                if self.houseModel?.customId == nil {
                    msg = "添加成功"
                }else {
                    msg = "保存成功"
                }
                
                let popup = PopupDialog(title: msg, message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    
                    if let block = self.modifyHouseBlock {
                        block(model!)
                    }
                    if  let vcs = self.navigationController?.viewControllers {
                        for vc in vcs {
                            if vc.isKind(of: HouseViewController.classForCoder()) {
                                self.selectedHouseBlock?(model)
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }else {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
    }
}
