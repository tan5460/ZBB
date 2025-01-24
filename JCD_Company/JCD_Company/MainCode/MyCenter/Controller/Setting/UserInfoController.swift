//
//  UserInfoController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/9/30.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import PopupDialog
import Photos
import AVFoundation
import ObjectMapper

class UserInfoController: BaseViewController,UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var tableView : UITableView!
    let identifier1 = "HeadPortraitCell"
    let identifier2 = "NewUserInfoCell"
    
    var userModel: WorkerModel? {
        set {
        }
        get {
            return UserData.shared.workerModel
        }
    }
    
    var headPicUrl: String?
    var sexString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "员工信息"
        prepareTableView()
        tableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    

    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = PublicColor.backgroundViewColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        tableView.register(HeadPortraitCell.self, forCellReuseIdentifier: identifier1)
        tableView.register(NewUserInfoCell.self, forCellReuseIdentifier: identifier2)

        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }

    //MARK: - UITableViewDelegate && UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
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
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier2) as! NewUserInfoCell

        if indexPath.row == 1 {
            cell.arrowImgView.isHidden = true
            cell.leftLabel?.text = "用户名"
            cell.rightLabel?.text = UserData.shared.userInfoModel?.userName
        }else if indexPath.row == 2 {
            cell.arrowImgView.isHidden = true
            cell.leftLabel?.text = "姓名"
            cell.rightLabel?.text = userModel?.realName
        }else if indexPath.row == 3 {
            cell.arrowImgView.isHidden = false
            cell.leftLabel?.text = "手机"
            cell.rightLabel?.text = userModel?.mobile
        }else if indexPath.row == 4 {
            cell.arrowImgView.isHidden = false
            cell.leftLabel?.text = "性别"
            cell.rightLabel?.text = "未设置"
            if(AppData.sexList.count>0){
                cell.rightLabel?.text = Utils.getReadString(dir: AppData.sexList[0], field: "label")
                if let index = userModel?.sex?.intValue {
                    if index > 0 && index <= AppData.sexList.count {
                         cell.rightLabel?.text = Utils.getReadString(dir: AppData.sexList[index-1], field: "label")
                    }
                }
            }
        }else if indexPath.row == 5 {
            cell.arrowImgView.isHidden = false
            cell.leftLabel?.text = "简介"
            cell.rightLabel?.text = "介绍下你自己吧"
            if let intro = userModel?.intro {
                if intro.count > 0 {
                    cell.rightLabel?.text = intro
                }
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {// 头像
            DispatchQueue.main.async {
                self.addIcon()
            }
        }else if indexPath.row == 1 {
          
        }else if indexPath.row == 2 {
            
        }else if indexPath.row == 3 {
            let cphoneVC = ChangePhoneController()
            self.navigationController?.pushViewController(cphoneVC, animated: true)
            
        }else if indexPath.row == 4 {
            DispatchQueue.main.async {
                self.selectSex()
            }
        }else if indexPath.row == 5 {
            
            //模型转字典
            let dic = userModel?.toJSON()
            //字典转模型
            let customModel = Mapper<CustomModel>().map(JSON: dic!)
            
            let vc = ChangeUserInfoController()
            vc.userModel = customModel
            vc.modifyUserModel = {[weak self](model) in
                self?.userModel?.intro = model?.intro
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    //MARK: 相机，相册
    func addIcon()  {
        
        picker.delegate = self
        
        let alertAction = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let headUrl = userModel?.headUrl, headUrl != "" {
            
            alertAction.addAction(UIAlertAction.init(title: "查看大图", style: .default, handler: { (alertCamera) in
                
                if let imageUrl = URL.init(string: APIURL.ossPicUrl + headUrl) {
                    
                    let phoneVC = IMUIImageBrowserController()
                    phoneVC.imageArr = [imageUrl]
                    phoneVC.imgCurrentIndex = 0
                    phoneVC.modalPresentationStyle = .overFullScreen
                    self.present(phoneVC, animated: true, completion: nil)
                }
            }))
        }
        
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
            
            let type = "company/worker/header"
            
            YZBSign.shared.upLoadImageRequest(oldUrl: self.userModel?.headUrl, imageType: type, image: image, success: { (response) in
                
                if self.userModel == nil {
                    self.userModel = WorkerModel()
                }
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.headPicUrl = headStr
                self.noticeSuccess("上传头像成功", autoClear: true, autoClearTime: 1)
                self.saveUserData(type: 1)
                
                GlobalNotificationer.post(notification: .user, object: nil, userInfo: nil)

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
                        self.saveUserData(type: 2)
                    }))
                }
            }
           
            alertAction.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (alertCancel) in
                
            }))
            if IS_iPad {
                let cell = tableView.cellForRow(at: IndexPath.init(row: 4, section: 0)) as! NewUserInfoCell
                alertAction.popoverPresentationController!.sourceView = cell.rightLabel
                alertAction.popoverPresentationController!.sourceRect = cell.rightLabel.bounds
            }
            self.present(alertAction, animated: true, completion: nil)
        }
    }
    // MARK: 保存数据
    // type:1:修改图片，2:修改性别
    func saveUserData(type:Int) {
        var parameters: Parameters = [:]
        parameters["id"] = self.userModel?.id
        if let headUrl = self.headPicUrl {
            if headUrl != "" {
                parameters["headUrl"] = headUrl
            }
        }
        let sexStr = self.sexString ?? ""
        let sexArray = Utils.getFieldArrInDirArr(arr: AppData.sexList, field: "label")
        var sexIndex = self.userModel?.sex?.intValue
        if let si = sexArray.firstIndex(of: sexStr){
            sexIndex = si
        }
        if sexIndex != nil {
            parameters["sex"] = NSNumber(value: sexIndex!+1)
        }
        var urlStr = ""
        urlStr = APIURL.addUpdateCustomInfo
        parameters["operType"] = "update"
        AppLog(parameters)
        self.pleaseWait()
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                if type == 1 {
                    self.userModel?.headUrl = self.headPicUrl
                    self.noticeSuccess("修改图片成功", autoClear: true, autoClearTime: 1)
                    //更新聊天头像
                    UserData.shared.workerModel?.headUrl = self.headPicUrl
                    YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                    })
                } else if type == 2 {
                    self.userModel?.sex = NSNumber(value: sexIndex!+1)
                    self.noticeSuccess("修改性别成功", autoClear: true, autoClearTime: 1)
                }
                self.tableView.reloadData()
            }
        }) { (error) in
            
           
        }
    }

}
