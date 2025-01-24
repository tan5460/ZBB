//
//  ScanCodeController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/1/26.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import AVFoundation
import TLTransitions
import ObjectMapper

class ScanCodeController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var barcodeView: UIImageView!
    var scanLineView: UIImageView!
    var timer: Timer!
    var captureSession: AVCaptureSession!
    var audioPlayer: AVPlayer!
    
    var isScanAddShop = false
    var packageModel: PackageModel?         //主材包模型
    var addPlusMaterialBlock: (()->())?     //选择套餐主材block
    var selectBlock: ((_ materialsModel: MaterialsModel)->())?      //选择主材
    var queryPlusMaterialBlock: ((_ materialsId: String)->(MaterialsModel?))?       //查询是否是套餐主推
    var pop: TLTransition?
    var isPresent = false  //是否模态过来
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>> 扫码界面释放 <<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        createSubView()
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            DispatchQueue.main.async {
                if granted {
                    self.loadScanView()
                }
                else {
                    let modifyAlert = UIAlertController.init(title: "请在iPhone的“设置-隐私-相机”选项中，允许App访问你的相机", message: nil, preferredStyle: .alert)
                    let sure = UIAlertAction.init(title: "去设置", style: .default, handler: { (sureAction) in
                        let settingUrl = URL(string: UIApplication.openSettingsURLString)!
                        if UIApplication.shared.canOpenURL(settingUrl) {
                            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                        }
                        self.backAction()
                    })
                    let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (sureAction) in
                        self.backAction()
                    })
                    modifyAlert.addAction(sure)
                    modifyAlert.addAction(cancel)
                    self.present(modifyAlert, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.statusStyle = .lightContent
        scannerStart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.statusStyle = .default
        scannerStop()
    }
    
    func createSubView() {
        
        //扫码部分
        let barcodeWidth = PublicSize.screenWidth * 0.7
        let barcodeTop = (PublicSize.screenHeight-barcodeWidth)/2
        let barcodeLeft = (PublicSize.screenWidth-barcodeWidth)/2
        let maskColor = UIColor.init(white: 0, alpha: 0.4)
        
        //左蒙版
        let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: barcodeLeft, height: PublicSize.screenHeight))
        leftView.backgroundColor = maskColor
        view.addSubview(leftView)
        
        //右蒙版
        let rightView = UIView.init(frame: CGRect.init(x: PublicSize.screenWidth-barcodeLeft, y: 0, width: barcodeLeft, height: PublicSize.screenHeight))
        rightView.backgroundColor = maskColor
        view.addSubview(rightView)
        
        //上蒙版
        let topView = UIView.init(frame: CGRect.init(x: barcodeLeft, y: 0, width: barcodeWidth, height: barcodeTop-30))
        topView.backgroundColor = maskColor
        view.addSubview(topView)
        
        //下蒙版
        let bottomView = UIView.init(frame: CGRect.init(x: barcodeLeft, y: PublicSize.screenHeight-barcodeTop-30, width: barcodeWidth, height: barcodeTop+30))
        bottomView.backgroundColor = maskColor
        view.addSubview(bottomView)
        
        //扫描框
        barcodeView = UIImageView.init(frame: CGRect.init(x: Int(barcodeLeft), y: Int(barcodeTop-30), width: Int(barcodeWidth+1), height: Int(barcodeWidth+1)))
        view.addSubview(barcodeView)
        
        //图片拉伸
        let barcodeImage = UIImage(named: "scanCode_barcode")
        var imageWidth = (barcodeImage?.size.width)! * 0.5
        var imageHeight = (barcodeImage?.size.height)! * 0.5
        barcodeView.image = barcodeImage?.resizableImage(withCapInsets: UIEdgeInsets(top: imageHeight, left: imageWidth, bottom: imageHeight, right: imageWidth))
        
        //设置扫描线
        scanLineView = UIImageView()
        scanLineView.frame = CGRect(x: 0, y: 5, width: barcodeWidth, height: 5)
        barcodeView.addSubview(scanLineView)
        
        let scanImage = UIImage(named: "scanCode_line")
        imageWidth = (scanImage?.size.width)! * 0.5
        imageHeight = (scanImage?.size.height)! * 0.5
        scanLineView.image = scanImage?.resizableImage(withCapInsets: UIEdgeInsets(top: imageHeight, left: imageWidth, bottom: imageHeight, right: imageWidth))
        
        //扫码提示
        let hintLabel = UILabel.init(frame: CGRect.init(x: 20, y: barcodeView.bottom+20, width: PublicSize.screenWidth-40, height: 20))
        hintLabel.text = "将二维码放入框内，即可自动扫描"
        hintLabel.textColor = .white
        hintLabel.font = UIFont.systemFont(ofSize: 14)
        hintLabel.textAlignment = .center
        view.addSubview(hintLabel)
        
        //返回按钮
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage.init(named: "scanCode_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(backBtn)
        
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(44)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(20)
            }
        }
        
        //标题
        let titleLabel = UILabel.init()
        titleLabel.text = "产品二维码"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(44)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(20)
            }
        }
        //相册
        let albumBtn = UIButton(type: .custom).image(#imageLiteral(resourceName: "scan_photo_icon"))
        albumBtn.addTarget(self, action: #selector(albumAction), for: .touchUpInside)
        view.addSubview(albumBtn)
        
        albumBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-66-PublicSize.kBottomOffset)
            make.size.equalTo(50)
        }
    }
    
    func loadScanView() {
        
        //初始化捕捉设备（AVCaptureDevice），类型AVMdeiaTypeVideo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        //捕捉异常
        do {
            //初始化链接对象
            captureSession = AVCaptureSession()
            
            guard let device = captureDevice else {
                return
            }
            //创建输入流
            let input = try AVCaptureDeviceInput(device: device)
            
            //创建媒体数据输出流
            let output = AVCaptureMetadataOutput()
            
            //把输入流添加到会话
            captureSession.addInput(input)
            
            //把输出流添加到会话
            captureSession.addOutput(output)
            
            //设置输出流的代理 在主线程回调
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //设置输出媒体的数据类型
            output.metadataObjectTypes = NSArray(array: [AVMetadataObject.ObjectType.qr]) as? [AVMetadataObject.ObjectType]
            
            //创建预览图层
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            //设置预览图层的填充方式
            videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            //设置预览图层的frame
            videoPreviewLayer.frame = view.bounds
            
            //将预览图层添加到预览视图上
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
            
            //开始扫描
            scannerStart()
        }
        catch {
            self.noticeOnlyText("摄像头不可用")
        }
        
    }
    
    /// 开始扫描
    func scannerStart() {
        pop = nil
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(moveScannerLayer(_:)), userInfo: nil, repeats: true)
            timer.fire()
        }
        
        if captureSession != nil {
            DispatchQueue.global().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    /// 停止扫描
    func scannerStop() {
        
        //停止扫描动画
        scanLineView.layer.removeAllAnimations()
        
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        
        if captureSession != nil {
            captureSession.stopRunning()
        }
    }
    
    //MARK: - 触发事件
    
    @objc func backAction() {
        if isPresent {
            self.dismiss(animated: true, completion: nil)
        }else {
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func albumAction() {
        AppLog("点击了相册")
        
        let picture = UIImagePickerController()
        picture.sourceType = UIImagePickerController.SourceType.photoLibrary
        picture.delegate = self
        self.present(picture, animated: true, completion: nil)
    }
    
    /// 让扫描线滚动
    @objc func moveScannerLayer(_ timer : Timer) {
        
        let Y = scanLineView.frame.origin.y
        UIView.animate(withDuration: timer.timeInterval) {
            var frame = self.scanLineView.frame
            if Y <= 5 {
                frame.origin.y = self.barcodeView.frame.size.height - self.scanLineView.frame.size.height - 5
            }
            else {
                frame.origin.y = 5
            }
            self.scanLineView.frame = frame
        } completion: { (flag) in
            
        }
    }
    
    
    //MARK: - 扫描代理方法 AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        AppLog("___________________________识别完成")
        
        if metadataObjects.count > 0 {
            let metaData : AVMetadataMachineReadableCodeObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            
            if let urlStr = metaData.stringValue {
                
                AppLog(urlStr)
                self.scanCodeSuccess(urlStr)
            }else {
                self.alertInvalidScanView()
            }
        }else {
            self.noticeOnlyText("未发现二维码")
        }
    }
    
    //选择相册中的图片完成，进行获取二维码信息
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        self.pleaseWait()
        
        DispatchQueue.global().async {
            
            let image = info[UIImagePickerController.InfoKey.originalImage]
            
            let imageData = (image as! UIImage).pngData()
            
            let ciImage = CIImage(data: imageData!)
            
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
            
            let array = detector?.features(in: ciImage!)
            
            DispatchQueue.main.async {
                
                self.clearAllNotice()
                
                if let result : CIQRCodeFeature = array!.first as? CIQRCodeFeature {
                    
                    if let urlStr = result.messageString {
                        
                        AppLog(urlStr)
                        self.scanCodeSuccess(urlStr)
                        
                    }else {
                        self.alertInvalidScanView()
                    }
                }else {
                    self.noticeOnlyText("未发现二维码")
                }
            }
        }
    }
    
    func alertInvalidScanView() {
        scannerStop()
        let bgV = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height)).backgroundColor(.clear)
        let v = UIView().backgroundColor(.white)
        bgV.sv(v)
        v.width(272).height(115).centerInContainer()
        let titleLabel = UILabel().text("暂不支持查看该类型二维码").textColor(.kColor33).fontBold(14)
        let lineView = UIView().backgroundColor(.kColor220)
        let sureBtn = UIButton().text("知道了").textColor(UIColor.hexColor("#2FD4A7")).font(16)
        v.sv(titleLabel, lineView, sureBtn)
        v.layout(
            22.5,
            titleLabel.height(20).centerHorizontally(),
            22.5,
            |lineView.height(0.5)|,
            0,
            |sureBtn|,
            0
        )
        pop = TLTransition.show(bgV, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
        
        bgV.isUserInteractionEnabled = true
        bgV.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(sureBtnClick)))
        
        sureBtn.tapped { [weak self] (btn) in
            self?.sureBtnClick()
        }
    }
    
    @objc func sureBtnClick() {
        self.pop?.dismiss(completion: {
            self.scannerStart()
        })
    }
    
    
    func scanCodeSuccess(_ urlStr: String) {
        
        if (urlStr.range(of: "jcdcbm.com")?.upperBound) != nil {
            
            self.scannerStop()
            self.audioPlayer = AVPlayer.init(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "scan_audio", ofType: "m4a")!))
            self.audioPlayer.play()
            
            let arrs = urlStr.components(separatedBy: "id=")
            guard arrs.count > 1, let id = arrs.last else {
                self.alertInvalidScanView()
                return
            }
            let materialModel = MaterialsModel()
            materialModel.id = id.subString(to: 32)
            self.getMaterialsRequest(model: materialModel)
        }else {
            self.alertInvalidScanView()
        }
    }
    
    // MARK: - 接口请求
    func getMaterialsRequest(model: MaterialsModel) {
        var parameters = Parameters()
        parameters["materialsId"] = model.id
        self.pleaseWait()
        let urlStr = APIURL.getMaterialsDetailsById
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { response in
            self.clearAllNotice()
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
            if code == "0" {
                let vc = MaterialsDetailVC()
                vc.materialsModel = model
                self.navigationController?.pushViewController(vc)
            } else {
                self.notice(msg, autoClear: true, autoClearTime: 2)
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.scannerStart()
                }
            }
        }) { (error) in
            self.alertInvalidScanView()
        }
    }
    
}
