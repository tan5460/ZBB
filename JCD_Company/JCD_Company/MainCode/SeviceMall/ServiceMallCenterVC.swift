//
//  ServiceMallCenterVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/15.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import MJRefresh
import Alamofire
import ObjectMapper
import PopupDialog

class ServiceMallCenterVC: BaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        headerRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func headerRefresh() {
        refreshUserData()
       // self.loadData()
    }
    
    //查询开户信息
    func loadData() {
        let urlStr = APIURL.lessMoney
        self.pleaseWait()
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            
            
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let accountModel = Mapper<OpenAccountInfoModel>().map(JSON: dataDic as! [String : Any])
                
                let balance = accountModel?.withdrawBalance
                if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
                    UserData.shared.merchantModel?.money = balance
                }
                else if UserData.shared.userType == .yys {
                    UserData.shared.userInfoModel?.substation?.balance = balance
                }
            }
            else if errorCode == "008" {
                
                if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
                    UserData.shared.merchantModel?.money = 0
                }
                else if UserData.shared.userType == .yys {
                    UserData.shared.substationModel?.balance = 0
                }
            }
            self.tableView.reloadData()
        }) { (error) in
            
        }
    }
    
    /// 获取用户数据
    @objc func refreshUserData() {
        
        let parameters: Parameters = [:]
        var urlStr = ""
        urlStr = APIURL.getUserInfo
        
        AppLog(parameters)
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                //储存用户数据
                AppUtils.setUserData(response: response)
                
                var userName = ""
                switch UserData.shared.userType {
                case .jzgs, .cgy:
                    if let valueStr = UserData.shared.userInfoModel?.userName {
                        userName = valueStr
                    }
                case .gys, .fws:
                    if let valueStr = UserData.shared.userInfoModel?.merchant?.userName {
                        userName = valueStr
                    } else if let valueStr = UserData.shared.userInfoModel?.userInfo?.yzbUser?.loginName {
                        userName = valueStr
                    }
                case .yys:
                    if let valueStr = UserData.shared.userInfoModel?.userInfo?.yzbUser?.loginName {
                        userName = valueStr
                    }
                }
                
                if userName == "" {
                    self.noticeOnlyText("用户信息异常~")
                    return
                }
                self.tableView.reloadData()
                
                //更新极光信息
                YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                    
                })
            }
            else if errorCode == "018" {
                
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "您的公司会员已过期，续费后才能恢复使用，请联系管理员前往后台续费！", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确认") {
                    ToolsFunc.showLoginVC()
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            else if errorCode == "019" {
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let workerModel = Mapper<WorkerModel>().map(JSON: dataDic as! [String : Any])
                
                var cityMobile = ""
                if let valueStr = workerModel?.cityMobile {
                    cityMobile = valueStr
                }
                
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "您的公司暂未开通会员，请前往后台交费后使用，详情请咨询当地运营商（电话：\(cityMobile)）", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    ToolsFunc.showLoginVC()
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        configTableView()
    }
    
    func configTableView() {
        tableView.backgroundColor(.white)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
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
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
    }
    
    ///设置
    @objc func settingAction() {
        let vc = MoreViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    private var userHeadImg = ""
    @objc func headerImageAction() {
        let alertAction = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        if userHeadImg != "" {
            alertAction.addAction(UIAlertAction.init(title: "查看大图", style: .default, handler: { (alertCamera) in
                if let headUrl = URL.init(string: APIURL.ossPicUrl + self.userHeadImg) {
                    let phoneVC = IMUIImageBrowserController()
                    phoneVC.imageArr = [headUrl]
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
        self.present(alertAction, animated: true, completion: nil)
    }
    
    //MARK: ImagePicker Delegate 选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let chosenImage =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            picker.dismiss(animated: true) {
            }
            //处理传入后台
            var image = chosenImage
            AppLog("照片原尺寸: \(image.size)")
            image = image.resizeImage() ?? UIImage()
            AppLog("照片压缩后尺寸: \(image.size)")
            
            var imageType = ""
            
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                
                imageType = "company/worker/header"
                
            }else if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
                
                imageType = "merchant/header"
                
            }else if UserData.shared.userType == .yys {
                
                imageType = "substation/header"
            }
            
            YZBSign.shared.upLoadImageRequest(oldUrl: self.userHeadImg, imageType: imageType, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.userHeadImg = headStr
                self.noticeSuccess("上传头像成功", autoClear: true, autoClearTime: 1)
                self.saveUserHeader()
                
            }, failture: { (error) in
                
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                
            })
        }
    }
}



extension ServiceMallCenterVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.white)
        let iv = UIImageView()
        let title = UILabel().textColor(.kColor33).font(14)
        let arrow = UIImageView().image(#imageLiteral(resourceName: "purchase_arrow"))
        let detailTitle = UILabel().text(UserData.shared.merchantModel?.servicephone ?? "").textColor(.kColor99).font(14)
            
        cell.sv(iv, title, arrow, detailTitle)
        |-14-iv.size(20).centerVertically()-5-title.centerVertically()-(>=0)-detailTitle.centerVertically()-5-arrow.width(6).height(11).centerVertically()-14-|
        detailTitle.isHidden = true
        switch indexPath.row {
//        case 0:
//            iv.image(#imageLiteral(resourceName: "service_mall_center_tx"))
//            title.text("提现")
        case 0:
            iv.image(#imageLiteral(resourceName: "service_mall_center_xgmm"))
            title.text("修改密码")
        case 1:
            detailTitle.isHidden = false
            detailTitle.text(UserData.shared.merchantModel?.mobile ?? "")
            iv.image(#imageLiteral(resourceName: "service_mall_center_sjh"))
            title.text("手机号")
        case 2:
            detailTitle.isHidden = false
            detailTitle.text(UserData.shared.merchantModel?.servicephone ?? "")
            iv.image(#imageLiteral(resourceName: "service_mall_center_kf"))
            title.text("客服电话")
        case 3:
            iv.image(#imageLiteral(resourceName: "icon_zlzx_fws"))
            title.text("资料中心")
        case 4:
            iv.image(#imageLiteral(resourceName: "icon_scxt"))
            title.text("商城系统")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
//        case 0: // 提现
//            let vc = WithdrawMoneyController()
//            navigationController?.pushViewController(vc, animated: true)
        case 0: // 修改密码
            let vc = PasswordModifyController()
            navigationController?.pushViewController(vc, animated: true)
        case 1: // 手机号
            if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
                let cphoneVC = ChangePhoneController()
                self.navigationController?.pushViewController(cphoneVC, animated: true)
            }
            else if UserData.shared.userType == .yys {
                houseListCallTel(name: UserData.shared.userInfoModel?.substation?.groupName ?? "" , phone: UserData.shared.userInfoModel?.substation?.mobile ?? "")
               // modifyMobile()
            }
        case 2:
            modifyMobile()
        case 3:
            let cphoneVC = MyDataCenterVC()
            self.navigationController?.pushViewController(cphoneVC, animated: true)
        case 4:
            ToolsFunc.clearData()
            let tokenModel = UserDefaults.standard.object(forKey: UserDefaultStr.tokenModel1)
            UserDefaults.standard.set(tokenModel, forKey: UserDefaultStr.tokenModel)
            UserData1.shared.tokenModel = Mapper<TokenModel1>().map(JSON: tokenModel as! [String: Any])
            getUserInfoRequest1()
        default: // 客服电话
            break
        }
    }
    
    //MARK: - 主要为了切换供应商
    func getUserInfoRequest1() {
        pleaseWait()
        YZBSign.shared.request(APIURL.getUserInfo, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
                UserData.shared.userInfoModel = infoModel
                AppUtils.setUserType(type: .cgy)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
        let iv = UIImageView().image(#imageLiteral(resourceName: "service_mall_center_top_bg"))
        v.sv(iv)
        iv.followEdges(v)
        iv.contentMode = .scaleAspectFill
        
        userHeadImg = ""
        let avatar = UIImageView().image(#imageLiteral(resourceName: "headerImage_man")).cornerRadius(30).masksToBounds()
        
        let name = UILabel().text("谭某某").textColor(.white).font(16)
        let desLabel = UILabel().text("").textColor(.white).font(14)
//        let price = UILabel().text("5100.00元").textColor(.white).fontBold(14)
//        let priceDes = UILabel().text("（可提现余额）").textColor(.white).fontBold(14)
        let setBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_center_sz"))
        v.sv(avatar, name, setBtn, desLabel)
        v.layout(
            60,
            |-14-avatar.size(60),
            >=0
        )
        v.layout(
            46,
            setBtn.size(45)|,
            >=0
        )
        v.layout(
            64,
            |-89-name.height(22.5),
            10,
            |-89-desLabel.height(20),
            >=0
        )
        avatar.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(headerImageAction)))
        setBtn.addTarget(self, action: #selector(settingAction))
        
        var money: Double = 0
        var moneyStr = "0"
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            break
        case .gys, .fws:
            if let headUrl = UserData.shared.merchantModel?.headUrl, headUrl != "" {
                userHeadImg = headUrl
            }
            if let valueStr = UserData.shared.merchantModel?.name {
                name.text = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.serviceType {
                AppData.serviceTypes.forEach({ (dic) in
                    let value = Utils.getReadString(dir: dic, field: "value")
                    if Int(value) == valueStr {
                        desLabel.text = Utils.getReadString(dir: dic, field: "label")
                    }
                })
                
            }
            if let valueStr = UserData.shared.merchantModel?.money?.doubleValue {
                money = valueStr
                moneyStr = money.notRoundingString(afterPoint: 2, qian: false)
            }
        case .yys:
            if let headUrl = UserData.shared.substationModel?.headUrl, headUrl != "" {
                userHeadImg = headUrl
            }
            if let valueStr = UserData.shared.userInfoModel?.substation?.groupName {
                name.text = valueStr
            }
            if let valueStr = UserData.shared.userInfoModel?.substation?.balance?.doubleValue {
                money = valueStr
                moneyStr = money.notRoundingString(afterPoint: 2, qian: false)
            }
        }
        avatar.contentMode = .scaleAspectFill
        avatar.addImage(userHeadImg)
        
        let formatter = NumberFormatter.init()
        let number = formatter.number(from: moneyStr)
        if money >= 1000 {
            formatter.positiveFormat = "0,000.00"
        }else if money >= 1000000 {
            formatter.positiveFormat = "0,000,000.00"
        }else if money >= 1000000000 {
            formatter.positiveFormat = "0,000,000,000.00"
        }else {
            formatter.positiveFormat = "0.00"
        }
        formatter.numberStyle = .decimal
       // let str = formatter.string(from: number ?? 0.00)
       // price.text = "\(str ?? "")元"
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - 按钮点击方法
extension ServiceMallCenterVC {
    ///修改客服电话
    func modifyMobile() {
        var servicephone = ""
        
        if UserData.shared.userType == .gys  || UserData.shared.userType == .fws {
            servicephone = UserData.shared.merchantModel?.servicephone ?? ""
        }
        else if UserData.shared.userType == .yys {
            servicephone = UserData.shared.userInfoModel?.substation?.mobile ?? ""
        }
        
        let remarkVC = RemarksViewController(title: "客服电话", remark: servicephone)
        remarkVC.remarksType = .tel
        remarkVC.doneBlock = { (remarks, re2) in
            if remarks != nil && remarks != ""  {
                
                var urlStr = ""
                
                var parameters: Parameters = [:]
                
                if UserData.shared.userType == .gys  || UserData.shared.userType == .fws {
                    urlStr = APIURL.editServiceTel
                    parameters["servicephone"] = remarks!
                    
                    if let valueStr = UserData.shared.merchantModel?.id {
                        parameters["id"] = valueStr
                    }
                }
                else if UserData.shared.userType == .yys {
                    urlStr = APIURL.editServiceTel
                    parameters["servicephone"] = remarks!
                    
                    if let valueStr = UserData.shared.userInfoModel?.substation?.id {
                        parameters["id"] = valueStr
                    }
                }
                
                self.pleaseWait()
                
                YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
                    
                    let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                    if errorCode == "0" {
                        self.noticeSuccess("修改成功")
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            self.pleaseWait()
                            self.refreshUserData()
                        }
                    }
                    
                }) { (error) in
                    
                }
            }
        }
        self.present(remarkVC, animated: true, completion:nil)
    }
    
    //修改头像
    func saveUserHeader() {
        
        let urlStr = APIURL.editServiceTel
        var parameters: Parameters = [:]
        parameters["headUrl"] = userHeadImg
        
        var userId = ""
        if let valueStr = UserData.shared.merchantModel?.id {
            userId = valueStr
        }
        if let valueStr = UserData.shared.substationModel?.id {
            userId = valueStr
        }
        parameters["id"] = userId
        
        self.pleaseWait()
        
        YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                
                if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
                    UserData.shared.merchantModel?.headUrl = self.userHeadImg
                }else if UserData.shared.userType == .yys {
                    UserData.shared.substationModel?.headUrl = self.userHeadImg
                }
                //修改聊天头像
                YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                })
                self.noticeSuccess("修改图片成功", autoClear: true, autoClearTime: 1)
                self.tableView.reloadData()
            }
            
        }) { (error) in
            
            
        }
    }
}
