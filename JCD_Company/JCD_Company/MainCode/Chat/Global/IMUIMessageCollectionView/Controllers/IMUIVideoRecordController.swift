//
//  IMUIVideoRecordController.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/16.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class IMUIVideoRecordController: BaseViewController, AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate {
    
    var endRecordVideoURL: ((_ url: URL)->())?
    
    var endRecordImage: ((_ image: UIImage)->())?
    
    //  MARK: - Properties ，
    //  视频捕获会话，他是 input 和 output 之间的桥梁，它协调着 input 和 output 之间的数据传输
    let captureSession = AVCaptureSession()
    
    //  视频输入设备，前后摄像头
    var camera: AVCaptureDevice?
    var captureDeviceInput:AVCaptureDeviceInput?
    
    //  展示界面
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    //  视频播放
    var player: AVPlayer?
    var avlayer: AVPlayerLayer?
    
    //  音频输入设备
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    
    let photoOutput = AVCapturePhotoOutput()
    //  将捕获到的视频输出到文件
    let fileOut = AVCaptureMovieFileOutput()
   
    var videoURL: URL?
    var imagefile: UIImage?
    
    //  前后摄像头转换
    lazy var cameraSideButton:UIButton = {
        let cameraBtn = UIButton()
        cameraBtn.setImage(UIImage.imuiImage(with: "switch_camera_btn"), for: .normal)
        cameraBtn.addTarget(self, action: #selector(changeCamera), for: .touchUpInside)
        return cameraBtn
    }()
    
    //  取消
    lazy var cancelBtn:UIButton = {
        let cancelB = UIButton()
        cancelB.isHidden = true
        cancelB.backgroundColor = .clear
        cancelB.setImage(UIImage.imuiImage(with: "record_cancel"), for: .normal)
        cancelB.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return cancelB
    }()
    
    //  返回
    lazy var backBtn:UIButton = {
        let backB = UIButton()
        backB.setImage(UIImage.imuiImage(with: "record_back"), for: .normal)
        backB.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return backB
    }()
    
    //  确定
    lazy var sureBtn:UIButton = {

        let sureB = UIButton()
        sureB.isHidden = true
        sureB.backgroundColor = .clear
        sureB.setImage(UIImage.imuiImage(with: "record_sure"), for: .normal)
        sureB.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        return sureB
    }()
    
    //  进度按钮
    lazy var pressBtn: CirclePressButton = {
        let press = CirclePressButton.init(frame: CGRect.init(x: (PublicSize.screenWidth-100)/2, y: PublicSize.screenHeight-150, width: 100, height: 100))
        return press
    }()
   
    //  录制时间Timer
    var timer: Timer?
    var secondCount = 0
    
    //  表示当时是否在录像中
    var isRecording = false
    
    // 缩放倍数
    var deviceZoom: CGFloat = 1
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //  MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  UI 布局
        setupView()
       
        let videoAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let audioAuthStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        if videoAuthStatus == .authorized &&
            audioAuthStatus == .authorized {
            //  录制视频基本设置
            setupAVFoundationSettings()
        }else  if videoAuthStatus == .notDetermined || audioAuthStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted) in
                        DispatchQueue.main.async {
                            
                            if granted {
                                //  录制视频基本设置
                                self.setupAVFoundationSettings()
                            }else {
                                self.goToIphoneSettings()
                            }
                        }
                    })
                }else {
                    DispatchQueue.main.async {
                        
                        self.goToIphoneSettings()
                    }
                }
            }
        }else {
            self.perform(#selector(goToIphoneSettings), with: self, afterDelay: 1)
        }
        

    }
    
    @objc func goToIphoneSettings() {
        
        let modifyAlert = UIAlertController.init(title: "请在iPhone的“设置-隐私”选项中，允许优装宝访问你的相机和麦克风", message: nil, preferredStyle: .alert)
        
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
    //  MARK: - Private Methods
    func setupAVFoundationSettings() {
       
        //获得输入设备
        camera = cameraWithPosition(position: AVCaptureDevice.Position.back)
        
        if camera == nil {
            return
        }
        
        //  设置视频清晰度，这里有很多选择
        captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
    
        //  添加视频、音频输入设备
        if let videoInput = try? AVCaptureDeviceInput(device: self.camera!) {
            captureDeviceInput = videoInput
            if captureSession.canAddInput(videoInput) {
                
                self.captureSession.addInput(videoInput)
            }
        }
        if let audioInput = try? AVCaptureDeviceInput(device: self.audioDevice!) {
            if captureSession.canAddInput(audioInput) {
                
                self.captureSession.addInput(audioInput)
            }
    
        }
        
        let setDic = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        let photoSettings = AVCapturePhotoSettings(format: setDic)
        
        photoOutput.photoSettingsForSceneMonitoring = photoSettings
        
        //添加图片输入设备
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        //  添加视频捕获输出
        self.captureSession.addOutput(fileOut)
        
        //  使用 AVCaptureVideoPreviewLayer 可以将摄像头拍到的实时画面显示在 ViewController 上
        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoLayer.frame = view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.insertSublayer(videoLayer, at: 0)
        previewLayer = videoLayer
        
        //缩放手势
//        let pinchGestureRecoginzer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
//        view.addGestureRecognizer(pinchGestureRecoginzer)
        
        //  启动 Session 回话
        self.captureSession.startRunning()
    }
    
    //  选择摄像头
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let devicesIOS10 = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position)
        return devicesIOS10
    }
    
    /*
    /// 缩放手势
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        
        let zoomScale = recognizer.scale
//        AppLog("缩放倍数：\(zoomScale)")
        
        var zoomSize: CGFloat = 1
        zoomSize = deviceZoom*zoomScale
        
        if zoomSize < 1 {
            zoomSize = 1
        }else if zoomSize > 3 {
            zoomSize = 3
        }
        
        if recognizer.state == .ended {
            AppLog(">>>>>>>>>>>>>>>>>>>>> 手指抬起 <<<<<<<<<<<<<<<<<<<")
            deviceZoom = zoomSize
        }
        
        var frame = view.frame
        frame.origin.x = -frame.size.width*(zoomSize-1)/2
        frame.origin.y = -frame.size.height*(zoomSize-1)/2
        frame.size.width = frame.size.width*zoomSize
        frame.size.height = frame.size.height*zoomSize
        previewLayer.frame = frame
        
//        if let output = captureSession.outputs.first {
//            let videoConnection = output.connection(with: .video)
//            if let maxScale = videoConnection?.videoMaxScaleAndCropFactor {
//
//                if deviceZoom < maxScale {
////                    videoConnection?.videoScaleAndCropFactor = deviceZoom
//                    previewLayer.transform = CATransform3DMakeScale(deviceZoom, deviceZoom, 1)
//                }
//            }
//        }
    }
 */

    
    //  MARK: - UI Settings
    func setupView() {
       
        view.backgroundColor = .black
        
        view.addSubview(cameraSideButton)
        cameraSideButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            } else {
                make.top.equalTo(30)
            }
            make.right.equalTo(-10)
        }
       
        view.addSubview(pressBtn)
        pressBtn.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            } else {
                make.bottom.equalTo(-50)
            }
            make.centerX.equalToSuperview()
            make.height.width.equalTo(100)
        }
        
        pressBtn.actionWithClosure { [weak self] (state) in
            
            switch state {
                
            case .Begin:
                self?.startRecord()
                AppLog("begin")
            case .Moving:
                AppLog("moving")
            case .WillCancel:
                AppLog("willCancel")
            case .DidCancel:
                self?.endRecord()
                AppLog("didCancel")
            case .End:
                self?.endRecord()
                AppLog("end")
            case .Click:
                AppLog("click")
                self?.takePhoto()
            }
        }
        
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalTo(pressBtn.right).offset(40)
            make.centerY.equalTo(pressBtn)
            make.height.width.equalTo(80)
        }
        
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.center.height.width.equalTo(backBtn)
        }
        
        view.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalTo(pressBtn.left).offset(-40)
            make.centerY.equalTo(pressBtn)
            make.height.width.equalTo(80)
        }
        
    }
    
    //  MARK: Actions
    //  开始录制视频
    @objc func startRecord() {
        
        self.pressBtn.isHidden = false
        self.cameraSideButton.isHidden = true
        self.cancelBtn.isHidden = true
        self.backBtn.isHidden = true
        self.sureBtn.isHidden = true
        
        if !isRecording {
            //  记录状态： 录像中 ...
            isRecording = true
            
            captureSession.startRunning()
  
            //  设置录像保存地址，在 Documents 目录下，名为 当前时间.mp4
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentDirectory = path[0] as String
            let filePath: String? = "\(documentDirectory)/\(NSDate()).mp4"
            let fileUrl: NSURL? = NSURL(fileURLWithPath: filePath!)
            //  启动视频编码输出
            fileOut.startRecording(to: fileUrl! as URL, recordingDelegate: self)
        }
    }
    
    // 停止了录像
    @objc func endRecord() {
        
        self.cameraSideButton.isHidden = true
        self.cancelBtn.isHidden = false
        self.backBtn.isHidden = true
        self.sureBtn.isHidden = false
        self.pressBtn.isHidden = true
        
        if isRecording {
            //  停止视频编码输出
            captureSession.stopRunning()
            
            //  记录状态： 录像结束 ...
            isRecording = false
        }
    }
    
    @objc func takePhoto() {
        
        
        let setDic = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        let photoSettings = AVCapturePhotoSettings(format: setDic)
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        //  停止视频编码输出
        captureSession.stopRunning()
    }
    
    //  返回上一页
    @objc func backAction() {
        
//        previewLayer.removeFromSuperlayer()
//        self.navigationController?.popViewController(animated: true)
        player?.pause()
        self.dismiss(animated: true, completion: nil)
    }
    
    //取消
    @objc func cancelAction(){
        
        player?.pause()
        avlayer?.removeFromSuperlayer()
        view.layer.insertSublayer(previewLayer, at: 0)
        captureSession.startRunning()
        
        self.cameraSideButton.isHidden = false
        self.cancelBtn.isHidden = true
        self.backBtn.isHidden = false
        self.sureBtn.isHidden = true
        self.pressBtn.isHidden = false
    }
    
    //确认
    @objc func sureAction(){
        if videoURL != nil {
            
            endRecordVideoURL?(videoURL!)
        }
        
        if imagefile != nil {
            
            endRecordImage?(imagefile!)
        }
        backAction()
    }
    
    //  调整摄像头
    @objc func changeCamera(cameraSideButton: UIButton) {
        cameraSideButton.isSelected = !cameraSideButton.isSelected

        //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
        self.captureSession.beginConfiguration()
        
        self.captureSession.removeInput(captureDeviceInput!)
        
        
        if cameraSideButton.isSelected {
            camera = cameraWithPosition(position: .front)
            if let input = try? AVCaptureDeviceInput(device: camera!) {
                captureDeviceInput = input
                captureSession.addInput(input)
            }
     
        } else {
            camera = cameraWithPosition(position: .back)
            if let input = try? AVCaptureDeviceInput(device: camera!) {
                captureDeviceInput = input
                captureSession.addInput(input)
            }
        }
        self.captureSession.commitConfiguration()
    }
    
    
  
    //  MARK: - 录像代理方法
    // 开始
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    //  结束
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
       
        videoURL = outputFileURL
        
        NotificationCenter.default.removeObserver(self)
        
        previewLayer.removeFromSuperlayer()
        let playerItem = AVPlayerItem.init(url: outputFileURL)
        player = AVPlayer.init(playerItem: playerItem)
        avlayer = AVPlayerLayer.init(player: player)
        avlayer?.frame = view.frame
        view.layer.insertSublayer(avlayer!, at: 0)
        player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc func moviePlayDidEnd(_ noti: Notification) {
        
        if let item = noti.object as? AVPlayerItem {
            item.seek(to: CMTime.zero)
            player?.play()
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingRawPhoto rawSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if error != nil {
            
            captureSession.startRunning()
            
            return
        }
        if rawSampleBuffer != nil && previewPhotoSampleBuffer != nil {
            
            guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: rawSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer!) else {
                return
            }
            imagefile = UIImage(data: imageData, scale: 0.8)
            self.cameraSideButton.isHidden = true
            self.cancelBtn.isHidden = false
            self.backBtn.isHidden = true
            self.sureBtn.isHidden = false
            self.pressBtn.isHidden = true
        }
    }
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error == nil {
            guard let imageData = photo.fileDataRepresentation() else {
                return
            }
            imagefile = UIImage(data: imageData, scale: 0.8)
            
            self.cameraSideButton.isHidden = true
            self.cancelBtn.isHidden = false
            self.backBtn.isHidden = true
            self.sureBtn.isHidden = false
            self.pressBtn.isHidden = true
        }else {
            
            captureSession.startRunning()
            
        }
    }
    
}


//MARK:定义圆按钮
//按钮状态
enum CircleProgressButtonState {
    case Begin
    case Moving
    case WillCancel
    case DidCancel
    case End
    case Click
}

typealias actionState = (_ state: CircleProgressButtonState) -> Void

class CirclePressButton: UIView {
    
    /// 计时时长
    var interval: Float = 10.0
 
    private var buttonAction: actionState?
    
    //中心圆
    private lazy var centerLayer: CAShapeLayer = {
        
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.fillColor = UIColor.white.cgColor
        return layer
    }()
    
    //外圈圆
    private lazy var ringLayer: CAShapeLayer = {
        
        let layer = CAShapeLayer()
        layer.frame = self.bounds
        layer.fillColor = UIColor.init(displayP3Red: 152/255.0, green: 150/255.0, blue: 153/255.0, alpha: 1).cgColor
        return layer
    }()
    
    //进度条
    private lazy var progressLayer: CAShapeLayer = {
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.init(displayP3Red: 31/255.0, green: 185/255.0, blue: 34/255.0, alpha: 1.0).cgColor
        layer.lineWidth = 4
        layer.lineCap = CAShapeLayerLineCap.round
        return layer
    }()
    
    private lazy var link: CADisplayLink = {
        let link = CADisplayLink.init(target: self, selector: #selector(linkRun))
        link.preferredFramesPerSecond = 60
        link.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        link.isPaused = true
        return link
    }()
    
    private var tempInterval: Float = 0.0
    private var progress: Float = 0.0
    private var isTimeOut: Bool = false
    private var isPressed: Bool = false
    private var isClick: Bool = false
    private var isCancel: Bool = false
    private var ringFrame: CGRect = .zero
    
    
    deinit {
        print("deinit LZPressButton")
        self.link.invalidate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.addSublayer(ringLayer)
        self.layer.addSublayer(centerLayer)
        
        self.backgroundColor = UIColor.clear
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressGesture))
        self.addGestureRecognizer(longPress)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture))
        self.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func actionWithClosure(_ closure: @escaping actionState) {
        
        self.buttonAction = closure
    }
    
    @objc private func tapGesture() {
       
        self.link.isPaused = false
        self.isPressed = true
        self.isClick = true
        if let closure = self.buttonAction {
            closure(.Click)
        }
        self.perform(#selector(stop), with: self, afterDelay: 0.4)
        
    }
    
    @objc private func longPressGesture(_ gesture: UILongPressGestureRecognizer) {
        
        self.isClick = false
        switch gesture.state {
        case .began:
            
            self.link.isPaused = false
            self.isPressed = true
            self.layer.addSublayer(self.progressLayer)
            if let closure = self.buttonAction {
                closure(.Begin)
            }
        case .changed:
            let point = gesture.location(in: self)
            if self.ringFrame.contains(point) {
                self.isCancel = false
                if let closure = self.buttonAction {
                    closure(.Moving)
                }
            } else {
                self.isCancel = true
                if let closure = self.buttonAction {
                    closure(.WillCancel)
                }
            }
        case .ended:
            self.stop()
            if self.isCancel {
                if let closure = self.buttonAction {
                    closure(.DidCancel)
                }
            } else if self.isTimeOut == false {
                if let closure = self.buttonAction {
                    closure(.End)
                }
            }
            
            self.isTimeOut = false
        default:
            self.stop()
            self.isCancel = true
            if let closure = self.buttonAction {
                closure(.DidCancel)
            }
        }
        
        self.setNeedsDisplay()
    }
    
    @objc private func linkRun() {
        
        tempInterval += 1/60.0
        progress = tempInterval/interval
        
        if tempInterval >= interval {
            
            self.stop()
            isTimeOut = true
            if let closure = self.buttonAction {
                closure(.End)
            }
        }
        
        self.setNeedsDisplay()
    }
    
    @objc func stop() {
        
        isPressed = false
        tempInterval = 0.0
        progress = 0.0
        
        self.progressLayer.strokeEnd = 0;
        self.progressLayer.removeFromSuperlayer()
        self.link.isPaused = true
        self.setNeedsDisplay()
        
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let width = self.bounds.width
        
        var mainWidth = width/2.0
        
        var mainFrame = CGRect(x: mainWidth/2.0, y: mainWidth/2.0, width: mainWidth, height: mainWidth)
        
        var ringFrame = mainFrame.insetBy(dx: -0.7*mainWidth/2.0, dy: -0.7*mainWidth/2.0);
        self.ringFrame = ringFrame
        if self.isPressed && !self.isClick {
            ringFrame = mainFrame.insetBy(dx: -mainWidth/2.0, dy: -mainWidth/2.0)
        }
        
        let ringPath = UIBezierPath.init(roundedRect: ringFrame, cornerRadius: ringFrame.width/2.0)
        self.ringLayer.path = ringPath.cgPath
        
        if self.isPressed {
            mainWidth *= 0.7
            mainFrame = CGRect.init(x: (width - mainWidth)/2.0, y: (width - mainWidth)/2.0, width: mainWidth, height: mainWidth)
        }
        
        let mainPath = UIBezierPath.init(roundedRect: mainFrame, cornerRadius: mainWidth/2.0)
        self.centerLayer.path = mainPath.cgPath
        
        if self.isPressed {
            
            let progressFrame = ringFrame.insetBy(dx: 2.0, dy: 2.0)
            let progressPath = UIBezierPath.init(roundedRect: progressFrame, cornerRadius: progressFrame.width/2.0)
            self.progressLayer.path = progressPath.cgPath
            self.progressLayer.strokeEnd = CGFloat(self.progress)
        }
    }
}
