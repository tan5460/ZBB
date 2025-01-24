//
//  PaymentInstrumentController.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/21.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import Kingfisher
import ObjectMapper

class PaymentInstrumentController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var workerModel: WorkerModel?
    var purchaseOrderId: String? // 订单号
    var id: String? //修改id
    var isPerson = false
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var instrumentView: UIImageView!
    
    var imageUrl = ""
    
    var addLicenseBtn: UIButton!
    var addLicenseHint: UILabel!
    
    var cameraPicker: UIImagePickerController!
    var photoPicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "聚材道"
        
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        
        submitBtn.setBackgroundImage(backgroundImg, for: .normal)
        submitBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        
        
        //相机
        cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        if Utils.isSimulator == false {
            cameraPicker.sourceType = .camera
        }
        
        //相册
        photoPicker =  UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        
        
        //添加支付凭证按钮
        let addLicenseWidth: CGFloat = 50
        let addBtnColor = UIColor.init(red: 241.0/255, green: 90.0/255, blue: 90.0/255, alpha: 1)
        addLicenseBtn = UIButton(type: .custom)
        addLicenseBtn.layer.cornerRadius = addLicenseWidth/2
        addLicenseBtn.layer.masksToBounds = true
        addLicenseBtn.layer.borderWidth = 1
        addLicenseBtn.layer.borderColor = addBtnColor.cgColor
        addLicenseBtn.setImage(UIImage.init(named: "addLicense"), for: .normal)
        addLicenseBtn.addTarget(self, action: #selector(addLicenseAction), for: .touchUpInside)
        instrumentView.addSubview(addLicenseBtn)
        
        addLicenseBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-15)
            make.width.height.equalTo(addLicenseWidth)
        }
        
        //添加支付凭证
        addLicenseHint = UILabel()
        addLicenseHint.text = "请添加支付凭证"
        addLicenseHint.textColor = PublicColor.minorTextColor
        addLicenseHint.font = UIFont.systemFont(ofSize: 14)
        instrumentView.addSubview(addLicenseHint)
        
        addLicenseHint.snp.makeConstraints { (make) in
            make.top.equalTo(addLicenseBtn.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        instrumentView.isUserInteractionEnabled = true
        instrumentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addLicenseAction)))
    }
    @objc func addLicenseAction() {
        
//        optionType = 1
        presentAddPhoto()
    }
    @IBAction func submitAction(_ sender: UIButton) {
        
        if imageUrl == "" {
            self.noticeOnlyText("请上传支付凭证")
            return
        }
        var storeID = ""
        if let valueStr = (workerModel ?? UserData.shared.workerModel!).store?.id {
            storeID = valueStr
        }else {
            storeID = (workerModel ?? UserData.shared.workerModel!).id ?? ""
        }
        
        var parameters: Parameters = ["img": imageUrl, "storeId": storeID, "id": ""]
        if let vid = (workerModel ?? UserData.shared.workerModel!).voucher?.id {
            
            parameters["id"] = vid
        }
        if let purchaseOrderId = purchaseOrderId {
            parameters["orderNo"] = purchaseOrderId
        }
        if let id = id {
            parameters["id"] = id
        }
        
        self.clearAllNotice()
        self.pleaseWait()
        let urlStr = isPerson ? APIURL.uploadPayVoucher : APIURL.uploadOrderVoucher
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                let popup = PopupDialog(title: "提示", message: "提交成功", tapGestureDismissal: false, panGestureDismissal: false)
                let sureBtn = AlertButton(title: "确定") {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
                
            }
            
        }) { (error) in
          
        }
        
    }
    
    //添加照片弹窗
    func presentAddPhoto() {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            
            DispatchQueue.main.async {
                if granted {
                    
                    let sourceActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let cameraOption = UIAlertAction.init(title: "相机", style: .default) { [weak self] _ in
                        
                        self?.present(self!.cameraPicker, animated: true, completion: nil)
                    }
                    let photoOption = UIAlertAction.init(title: "相册", style: .default) { [weak self] _ in
                        
                        self?.present(self!.photoPicker, animated: true, completion: nil)
                    }
                    
                    let cancelOption = UIAlertAction(title: "取消", style: .cancel, handler:nil)
                    
                    sourceActionSheet.addAction(cameraOption)
                    sourceActionSheet.addAction(photoOption)
                   
                    sourceActionSheet.addAction(cancelOption)
                    
                    if IS_iPad {
                        
                        let popPresenter = sourceActionSheet.popoverPresentationController
                        
                        
                            popPresenter?.sourceView = self.addLicenseBtn
                            popPresenter?.sourceRect = self.addLicenseBtn.bounds
                        
                    }
                    
                    self.present(sourceActionSheet, animated: true, completion: nil)
                }
                else {
                    let modifyAlert = UIAlertController.init(title: "请在iPhone的“设置-隐私-相机”选项中，允许App访问你的相机", message: nil, preferredStyle: .alert)
                    
                    let sure = UIAlertAction.init(title: "去设置", style: .default, handler: { (sureAction) in
                        
                        let settingUrl = URL(string: UIApplication.openSettingsURLString)!
                        if UIApplication.shared.canOpenURL(settingUrl) {
                            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                        }
                    })
                    
                    let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (sureAction) in
                    })
                    
                    modifyAlert.addAction(sure)
                    modifyAlert.addAction(cancel)
                    self.present(modifyAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - 获得照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        AppLog("照片原尺寸: \(image.size)")
        image = image.resizeImage(valueMax: 800) ?? UIImage()
        AppLog("照片压缩后尺寸: \(image.size)")
        
       
            let type = "register/company"
            
            YZBSign.shared.upLoadImageRequest(oldUrl: self.imageUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                
                self.imageUrl = headStr
                self.addLicenseBtn.isHidden = true
                self.addLicenseHint.isHidden = true
                self.instrumentView.image = image
                
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
            
        
    }

}
