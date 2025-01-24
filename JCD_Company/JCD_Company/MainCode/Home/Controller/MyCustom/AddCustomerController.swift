//
//  AddCustomerController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/7.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import PopupDialog
import Photos
import AVFoundation

class AddCustomerController: BaseViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var tableView : UITableView!
    let identifier1 = "HeadPortraitCell"
    let identifier2 = "AddCustomCell"
    
    var userModel: CustomModel?             //用户Model
    
    var textView: UITextView!
    
    var headPicUrl: String?
    var sexString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userModel == nil {
            userModel = CustomModel()
        }
        
        prepareTableView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
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
        
        
        tableView = UITableView()
        tableView.backgroundColor = PublicColor.backgroundViewColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = createTableFooterView()
        
        tableView.register(HeadPortraitCell.self, forCellReuseIdentifier: identifier1)
        tableView.register(AddCustomCell.self, forCellReuseIdentifier: identifier2)
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(saveBtn.snp.top)
        }
        
    }
    
    func createTableFooterView() -> UIView {
        let footView = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: 75))
        footView.backgroundColor = .white
        
        textView = UITextView()
        textView.textColor = PublicColor.commonTextColor
        textView.font = UIFont.systemFont(ofSize: 15)
        footView.addSubview(textView)
        
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
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        textView.setValue(placeholderLabel, forKey: "_placeholderLabel")
        
        if let intro = userModel?.intro {
            if intro.count > 0 {
                
                textView.text = intro
                placeholderLabel.isHidden = true
            }
        }
        
        return footView
    }
    
    //MARK: - UITableViewDelegate && UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier1) as! HeadPortraitCell
            if let imageStr = userModel?.headUrl {
                if let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
                    cell.iconImgView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "imageRow_camera"))
                }
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier2) as! AddCustomCell
        
        if indexPath.row == 1 {
            cell.leftLabel?.text = "姓名"
            cell.rightTextField.isUserInteractionEnabled = true
            cell.rightTextField?.placeholder = "请输入姓名"
            cell.rightTextField.keyboardType = .default
            if let str = userModel?.realName {
                cell.rightTextField?.text = str
                cell.rightTextField.isUserInteractionEnabled = false
                cell.rightTextField.textColor = PublicColor.placeholderTextColor
            }
            
        }else if indexPath.row == 2 {
            cell.leftLabel?.text = "手机"
            cell.rightTextField.isUserInteractionEnabled = true
            cell.rightTextField?.placeholder = "请输入手机号"
            cell.rightTextField.keyboardType = .phonePad
            if let str = userModel?.tel {
                cell.rightTextField?.text = str
                cell.rightTextField.isUserInteractionEnabled = false
                cell.rightTextField.textColor = PublicColor.placeholderTextColor
            }
        }else if indexPath.row == 3 {
            cell.leftLabel?.text = "性别"
            cell.rightTextField.isUserInteractionEnabled = false
            cell.rightTextField?.text = "男"
            if(AppData.sexList.count>0){
                cell.rightTextField?.text = Utils.getReadString(dir: AppData.sexList[0], field: "label")
                if let index = userModel?.sex?.intValue {
                    if index > 0 && index <= AppData.sexList.count {
                        cell.rightTextField?.text = Utils.getReadString(dir: AppData.sexList[index-1], field: "label")
                    }
                }
            }
            self.sexString = cell.rightTextField?.text
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {// 头像
            self.addIcon()
        }else if indexPath.row == 1 {
            
        }else if indexPath.row == 2 {
            
        }else if indexPath.row == 3 {
            DispatchQueue.main.async {
                self.selectSex()
            }
        }else if indexPath.row == 4 {
            
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
                //                self.iconImage.image = chosenImage
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
        let nameCell = tableView.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! AddCustomCell
        let realName = nameCell.rightTextField.text
        if realName?.count == 0 {
            self.noticeOnlyText("姓名不能为空")
            return
        }else {
            self.userModel?.realName = realName
        }
        
        let mobileCell = tableView.cellForRow(at: IndexPath.init(row: 2, section: 0)) as! AddCustomCell
        
        let mobile = mobileCell.rightTextField.text
        if mobile?.count == 0 {
            self.noticeOnlyText("手机号不能为空")
            return
        }else {
            if !Utils_objectC.isMobileNumber2(mobile) {
                self.noticeOnlyText("请输入正确的手机号!")
                return
            }
            self.userModel?.tel = mobile
        }
        
        if textView.text.count > 0 {
            self.userModel?.intro = textView.text
        }
        
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        
        var storeID = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeID = valueStr
        }
        
        var parameters: Parameters = [:]
        var urlStr = APIURL.companyCustomSave
        var method: HTTPMethod = .put
        if let customId = self.userModel?.id {
            parameters["id"] = customId
        }else {
            urlStr = APIURL.addCustom
            method = .post
            parameters["store"] = storeID
            parameters["worker"] = userId
        }
        
        if let headUrl = self.headPicUrl {
            if headUrl != "" {
                parameters["headUrl"] = headUrl
            }
        }
        
        if let realName = self.userModel?.realName {
            parameters["realName"] = realName
        }
        if let mobile = self.userModel?.tel {
            parameters["mobile"]  = mobile
        }
        
        let sexStr = self.sexString ?? ""
        let sexArray = Utils.getFieldArrInDirArr(arr: AppData.sexList, field: "label")
        var sexIndex = self.userModel?.sex?.intValue
        if let si = sexArray.firstIndex(of: sexStr){
            sexIndex = si
        }
        parameters["sex"] = NSNumber(value: sexIndex!+1)
        
        if let intro = self.userModel?.intro {
            parameters["intro"]  = intro
        }
        
        AppLog(parameters)
        
        self.pleaseWait()
        
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                
                var msg = "添加成功"
                if (self.userModel?.id) != nil {
                    msg = "修改成功"
                }
                let popup = PopupDialog(title: msg, message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    self.navigationController?.popViewController(animated: true)
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
            
        }) { (error) in
            
            
        }
    }
    
}
