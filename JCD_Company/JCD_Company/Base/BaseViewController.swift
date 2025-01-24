//
//  BaseViewController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/22.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import Stevia
import TLTransitions

class BaseViewController: UIViewController {
    
    //使用时调用prepareNoDateView()
    var noDataView : UIView!            //没有数据时的视图
    private var sharePop: TLTransition?
    public var isPortrait: Bool = true     //是否竖屏 默认竖屏
    lazy public var picker: UIImagePickerController = UIImagePickerController()
    
    //显示隐藏状态栏
    var isStatusHidden = false {
        
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        
        return self.isStatusHidden
    }
    /* 状态栏样式：字体颜色白，黑
     * 注意：如果`UIViewController`存在`UINavigationController`，又想要通过`rootViewController`来控制`UIStatusBarStyle`，
     * 则需要在自定义`NavigationController`重写`childViewControllerForStatusBarStyle`方法
     * override var childViewControllerForStatusBarStyle: UIViewController?{
     *   return self.topViewController
     * }
     */
    var statusStyle : UIStatusBarStyle = .default {
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    //修改状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return self.statusStyle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()    
        let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = item
        
        //控制器背景颜色
        view.backgroundColor = .kBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("进入: \(type(of: self).className)")
        navigationController?.navigationBar.isTranslucent = false
        
        var shadowHeaght: CGFloat = 1
        let screenScale = UIScreen.main.scale
        
        if screenScale == 2 {
            shadowHeaght = shadowHeaght/2
        }else if screenScale == 3 {
            shadowHeaght = shadowHeaght/3
        }
        
        //设置导航栏分割线
        let shadImage = PublicColor.navigationLineColor.image(size: CGSize(width: PublicSize.screenWidth, height: shadowHeaght))
        navigationController?.navigationBar.shadowImage = shadImage
        
        if !AppData.isBaseDataLoaded {
            //获取基础数据
            YZBSign.shared.getBaseInfo()
        }
    }
    
    deinit {
        debugPrint("退出\(type(of: self).className) 并释放")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.windows.first?.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        AppLog(">>>>>>>>>>>>>>>> 内存警告 <<<<<<<<<<<<<<<<")
    }
    
    
    
    //创建没有数据时的视图
    func prepareNoDateView(_ title:String, image: UIImage? = #imageLiteral(resourceName: "icon_empty")) {
        noDataView = UIView()
        noDataView.isHidden = true
        self.view.addSubview(noDataView)
        
        noDataView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        let imgView : UIImageView = UIImageView()
        imgView.tag = 1000
        imgView.image = image
        imgView.contentMode = .scaleAspectFit
        noDataView.addSubview(imgView)
        
        imgView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.width.height.equalTo(158)
        }
        
        let noDataLabel = UILabel()
        noDataLabel.tag = 1001
        noDataLabel.font = UIFont.systemFont(ofSize: 15)
        noDataLabel.textColor = UIColor.darkGray
        noDataLabel.text = "暂无数据"
        noDataView.addSubview(noDataLabel)
        
        if title.count > 0 {
            noDataLabel.text = title
        }
        
        noDataLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imgView.snp.bottom).offset(20)
        }
        
    }
    
    //MARK: - 相机相册权限
    //判断权限打开相机
    func judgeCameraAuthorization() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (ist) in
                
                let status:AVAuthorizationStatus=AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                
                if status==AVAuthorizationStatus.authorized {//获得权限
                    
                    //                    let picker:UIImagePickerController = UIImagePickerController()
                    //                    picker.delegate = self
                    DispatchQueue.main.async {
                        if Utils.isSimulator == false {
                            self.picker.sourceType = .camera
                        }
                        self.picker.allowsEditing = true
                        
                        self.present(self.picker, animated: true, completion: { () -> Void in
                            
                        })
                    }
                }else{
                    self.authorizationPopupDialog(alert: "相机")
                }
                
            })
            
        }else {
            self.authorizationPopupDialog(alert: "相机")
        }
        
    }
    //判断权限打开相册
    func judgePhotoLibraryAuthorization() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            PHPhotoLibrary.requestAuthorization({ (status) in
                
                if status == .authorized {
                    //                    let picker:UIImagePickerController = UIImagePickerController()
                    //                    picker.delegate = self
                    DispatchQueue.main.async {
                        self.picker.sourceType = .photoLibrary
                        self.picker.allowsEditing = true
                        self.present(self.picker, animated: true, completion: {
                            () -> Void in
                        })
                    }
                }else {
                    self.authorizationPopupDialog(alert: "相册")
                }
                
            })
        }else {
            self.authorizationPopupDialog(alert: "相册")
        }
    }
    
    func authorizationPopupDialog(alert:String){
        let popup = PopupDialog(title: "未获得权限访问您的" + alert, message: "请在设置选项中允许优装宝访问您的" + alert, image: nil, buttonAlignment: .horizontal, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        let sureBtn1 = AlertButton(title: "确定") {
            
        }
        let sureBtn2 = AlertButton(title: "去设置") {
            let url=URL.init(string: UIApplication.openSettingsURLString)
            
            if UIApplication.shared.canOpenURL(url!){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: { (ist)in
                    })
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }
        }
        popup.addButtons([sureBtn1,sureBtn2])
        self.present(popup, animated: true, completion: nil)
    }
    
    //MARK: - 解决右滑返回与scroll滑动的冲突
    func screenEdgePanGestureRecognizerRequireFailToScrollView(_ scrollView:UIScrollView){
        let gestureArray = self.navigationController!.view.gestureRecognizers!
        // 当是侧滑手势的时候设置scrollview需要此手势失效即可
        for gesture in gestureArray {
            if gesture.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
                scrollView.panGestureRecognizer.require(toFail: gesture)
                break
            }
        }
        
    }
    
    //MARK: - 横竖屏
    override var shouldAutorotate: Bool {
        return false
    }
    
    //支持方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if isPortrait {
            return .portrait
        }else {
            return .landscapeRight
        }
    }
    
    //初始方向
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if isPortrait {
            return .portrait
        }else {
            return .landscapeRight
        }
    }
}

// MARK: - 拨打电话 消息点击
extension BaseViewController {
    @objc func messageBtnClick(userId: String?, userName: String?, storeName: String?, headUrl: String?, nickname: String?, tel1: String?, tel2: String?) {
        let userId = userId ?? ""
        let userName = userName ?? ""
        let storeName = storeName ?? ""
        let headUrl =  APIURL.ossPicUrl + (headUrl ?? "")
        let nickname = nickname ?? ""
        let tel1 = tel1 ?? ""
        let tel2 = ""
        let storeType = "2"
        
        let ex: NSDictionary = ["detailTitle": storeName, "headUrl":headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
        
        let user = JMSGUserInfo()
        user.nickname = nickname
        user.extras = ex as! [AnyHashable : Any]
        
        
        YZBChatRequest.shared.createSingleMessageConversation(username: userName) { (conversation, error) in
            
            if error == nil {
                
                if let userInfo = conversation?.target as? JMSGUser {
                    
                    let userName = userInfo.username
                    self.pleaseWait()
                    
                    YZBChatRequest.shared.getUserInfo(with: userName) { (user, error) in
                        self.clearAllNotice()
                        if error == nil {
                            let vc = ChatMessageController(conversation: conversation!)
                            vc.convenUser = user
                            // vc.materialModel = self.materialsModel
                            self.navigationController?.pushViewController(vc)
                        }
                    }
                }
                
            }else {
                if error!._code == 898002 {
                    
                    YZBChatRequest.shared.register(with: userName, pwd: YZBSign.shared.passwordMd5(password: userName), userInfo: user, errorBlock: { (error) in
                        if error == nil {
                            self.messageBtnClick(userId: userId, userName: userName, storeName: storeName, headUrl: headUrl, nickname: nickname, tel1: tel1, tel2: tel2)
                        }
                    })
                }
            }
        }
    }
    
    
    func houseListCallTel(name: String, phone: String) {
        
        var mobileStr = phone
        
        if phone == "" {
            mobileStr = "电话未填"
        }
        
        //        if !phone.isTelNumber() {
        //            self.noticeOnlyText("手机号格式错误，请通过“联系买家”来沟通客户")
        //            return
        //        }
        
        let popup = PopupDialog(title: name, message: mobileStr, buttonAlignment: .vertical)
        
        if phone != "" {
            let buttonOne = AlertButton(title: "拨打电话") {
                let phoneStr = String.init(format: "tel:%@", phone).replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL.init(string: phoneStr)!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: phoneStr)!)
                }
            }
            let buttonTwo = AlertButton(title: "复制号码") {
                let pasteboard:UIPasteboard=UIPasteboard.general
                pasteboard.string = phone
                self.noticeSuccess("复制成功", autoClear: true, autoClearTime: 1)
            }
            let buttonThree = AlertButton(title: "保存到通讯录") {
                
                if AddressBookManage.shared.existPhone(phoneNum: phone) {
                    self.noticeInfo("手机号码已存在", autoClear: true, autoClearTime: 1)
                }else{
                    if AddressBookManage.shared.addContactName(name: name, phone: phone) {
                        self.noticeSuccess("已成功添加", autoClear: true, autoClearTime: 1)
                    }else {
                        let modifyAlert = UIAlertController.init(title: "请在设置中打开访问通信录权限", message: nil, preferredStyle: .alert)
                        
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
            popup.addButtons([buttonOne, buttonTwo,buttonThree])
        }
        self.present(popup, animated: true, completion: nil)
    }
    /// 修改咨询人数（人气)接口
    func updConsultNumRequest(id: String) {
        var parameters = Parameters()
        parameters["id"] = id
        YZBSign.shared.request(APIURL.updConsultNum, method: .post, parameters: parameters, success: { (response) in
            
        }) { (error) in
            
        }
    }
    
    func configShareSelectView(title: String?, des: String? = "", imageStr: String?, urlStr: String?, vc: UIViewController?) {
        let v = ShareSelectView(frame: CGRect(x: 0, y: 0, width: view.width, height: 176)).backgroundColor(.white)
        v.shareSelectStyleBlock = { [weak self] (style) in
            let manager = ShareManager.init(title: title, des: des, imageStr: imageStr, urlStr: urlStr, vc: self)
            manager.shareSelectStyle = style
            manager.share()
            self?.sharePop?.dismiss()
        }
        v.cancelBtnBlock = { [weak self] in
            self?.sharePop?.dismiss()
        }
        sharePop = TLTransition.show(v, popType: TLPopTypeActionSheet)
    }
}
