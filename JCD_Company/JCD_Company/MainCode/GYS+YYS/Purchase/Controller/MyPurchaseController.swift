//
//  MyPurchaseController.swift
//  YZB_Company
//
//  Created by yzb_ios on 9.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Alamofire
import ObjectMapper
import Kingfisher
import SwiftyJSON

class MyPurchaseController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var moretableView: UITableView!
    let identifier = "MoreCell"
    
    var headerImageBtn: UIButton!
    var titleLabel:UILabel!
    var nameLabel: UILabel!
    var priceAlertLabel:UILabel!
    var priceLabel:UILabel!
    
    var userHeadImg = ""
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>>> 我的界面释放 <<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
        //设置
        let settingBtn = UIButton(type: .custom)
        settingBtn.setImage(UIImage.init(named: "settings_icon"), for: .normal)
        settingBtn.addTarget(self, action: #selector(settingAction), for: .touchUpInside)
        view.addSubview(settingBtn)
        
        settingBtn.snp.makeConstraints { (make) in
            
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(22)
            }
            
            make.right.equalTo(-5)
            make.width.height.equalTo(40)
        }
        // self.headerRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.statusStyle = .lightContent
        navigationController?.setNavigationBarHidden(true, animated: false)
        headerRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    func prepareTableView() {
        
        moretableView = UITableView()
        moretableView.delegate = self
        moretableView.dataSource = self
        moretableView.rowHeight = 50
        moretableView.separatorStyle = .none
        moretableView.showsVerticalScrollIndicator = false
        moretableView.tableHeaderView = createTableHeadview()
        moretableView.tableFooterView = UIView()
        moretableView.backgroundColor = .clear
        moretableView.register(MoreCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(moretableView)
        
        moretableView.snp.makeConstraints { (make) in
            make.top.right.left.bottom.equalToSuperview()
        }
        
        if #available(iOS 11.0, *) {
            moretableView.contentInsetAdjustmentBehavior = .never
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        moretableView.mj_header = header
    }
    
    @objc func headerRefresh() {
        self.refreshUserData()
       // self.loadData()
    }
    
    //MARK:上背景
    func createTableHeadview() -> UIView {
        
        let headImageView = UIImageView.init(image: #imageLiteral(resourceName: "service_mall_center_top_bg"))
        headImageView.isUserInteractionEnabled = true
        headImageView.frame = CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 200)
        
        //头像按钮
        headerImageBtn = UIButton()
        headerImageBtn.backgroundColor = .clear
        headerImageBtn.imageView?.contentMode = .scaleAspectFit
        headerImageBtn.layer.cornerRadius = 57/2
        headerImageBtn.layer.masksToBounds = true
        headerImageBtn.layer.borderColor = UIColor.init(white: 1, alpha: 0.6).cgColor
        headerImageBtn.layer.borderWidth = 1
        headerImageBtn.setImage(UIImage.init(named: "headerImage_man"), for: .normal)
        headerImageBtn.addTarget(self, action: #selector(headerImageAction), for: .touchUpInside)
        headImageView.addSubview(headerImageBtn)
        
        headerImageBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(5)
            make.left.equalTo(30)
            make.width.height.equalTo(57)
        }
        
        //用户名
        titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        headImageView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerImageBtn).offset(5)
            make.left.equalTo(headerImageBtn.snp.right).offset(15)
            make.right.equalTo(-30)
        }
        
        nameLabel = UILabel()
        nameLabel.text = ""
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        headImageView.addSubview(nameLabel)

        nameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(headerImageBtn).offset(-5)
            make.left.equalTo(titleLabel)
        }
        
//        priceLabel = UILabel()
//        priceLabel.text = "0.00元"
//        priceLabel.textColor = .white
//        priceLabel.font = UIFont.systemFont(ofSize: 18)
//        headImageView.addSubview(priceLabel)
//
//        priceLabel.snp.makeConstraints { (make) in
//            make.bottom.equalTo(headerImageBtn).offset(-5)
//            make.left.equalTo(titleLabel)
//        }
//
//        priceAlertLabel = UILabel()
//        priceAlertLabel.text = "(可提现余额)"
//        priceAlertLabel.textColor = .white
//        priceAlertLabel.textAlignment = .center
//        priceAlertLabel.font = UIFont.systemFont(ofSize: 13)
//        headImageView.addSubview(priceAlertLabel)
//
//        priceAlertLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(priceLabel.snp.right).offset(10)
//            make.bottom.equalTo(priceLabel)
//        }
        
        return headImageView
    }
    
    func updataData() {
        
        userHeadImg = ""
        var userName = ""
        var name = ""
        var moneyStr = "0"
        var money: Double = 0
        
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            break
        case .gys, .fws:
            if let headUrl = UserData.shared.merchantModel?.headUrl, headUrl != "" {
                userHeadImg = headUrl
            }
            if let valueStr = UserData.shared.merchantModel?.name {
                userName = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.legalRepresentative {
                name = valueStr
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
                userName = valueStr
            }
            if let valueStr = UserData.shared.userInfoModel?.substation?.realName {
                name = valueStr
            }
            if let valueStr = UserData.shared.userInfoModel?.substation?.balance?.doubleValue {
                money = valueStr
                moneyStr = money.notRoundingString(afterPoint: 2, qian: false)
            }
        }
        
        headerImageBtn.kf.setImage(with: URL(string: APIURL.ossPicUrl + userHeadImg)!, for: .normal, placeholder: UIImage.init(named: "headerImage_man"))
        self.titleLabel.text = userName
        self.nameLabel.text = name
//        let formatter = NumberFormatter.init()
//        let number = formatter.number(from: moneyStr)
//        if money >= 1000 {
//            formatter.positiveFormat = "0,000.00"
//        }else if money >= 1000000 {
//            formatter.positiveFormat = "0,000,000.00"
//        }else if money >= 1000000000 {
//            formatter.positiveFormat = "0,000,000,000.00"
//        }else {
//            formatter.positiveFormat = "0.00"
//        }
//        formatter.numberStyle = .decimal
//        let str = formatter.string(from: number ?? 0.00)
       // self.priceLabel.text = "\(str!)元"
        
        self.moretableView.reloadData()
    }
    
    //MARK: - 按钮事件
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
            
            self.updataData()
            
        }) { (error) in
            
        }
    }
    
    ///设置
    @objc func settingAction() {
        
        let vc = MoreViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func headerImageAction(_ sender: UIButton) {
        
        picker.delegate = self
        
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
        if IS_iPad {
            alertAction.popoverPresentationController!.sourceView = sender
            alertAction.popoverPresentationController!.sourceRect = sender.bounds
        }
        
        self.present(alertAction, animated: true, completion: nil)
    }
    
    
    //MARK: - 网络请求
    /// 获取用户数据
    @objc func refreshUserData() {
        
        let parameters: Parameters = [:]
        var urlStr = ""
        urlStr = APIURL.getUserInfo
        
        AppLog(parameters)
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            self.moretableView.mj_header?.endRefreshing()
            
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
                
                self.updataData()
                
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
            self.moretableView.mj_header?.endRefreshing()
        }
    }
    /// 进入资料中心
    func enterZLZX() {
        let vc = MyDataCenterVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    ///修改客服电话
    func modifyMobile() {
        
        var servicephone = ""
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
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
                
                if UserData.shared.userType == .gys  || UserData.shared.userType == .fws{
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
                self.updataData()
            }
            
            
        }) { (error) in
            
            
        }
    }
    
    
    //MARK: - UITableViewDelegate && UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            return 6
        }
        if UserData.shared.userType == .yys {
            return 2
        }
        return 4
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MoreCell
        cell.topLineView.isHidden = true
        cell.arrowView.isHidden = false
        cell.exitLabel.isHidden = true
        cell.downLineView.isHidden = false
        cell.contentLabel.text = ""
        
        cell.downLineView.snp.remakeConstraints { (make) in
            make.left.equalTo(18)
            make.right.equalTo(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
//        if indexPath.row == 0 {
//            cell.titleLabel.text = "提现"
//            cell.iconView.image = UIImage.init(named: "icon_withdraw")
//        }
        if indexPath.row == 0 {
            cell.titleLabel.text = "修改密码"
            cell.iconView.image = UIImage.init(named: "login_oldpw")
        }
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            if indexPath.row == 1 {
                cell.titleLabel.text = "手机号"
                cell.iconView.image = UIImage.init(named: "login_phone")
                cell.contentLabel.text = UserData.shared.merchantModel?.mobile ?? ""
            } else if indexPath.row == 2 {
                cell.titleLabel.text = "客服电话"
                cell.iconView.image = UIImage.init(named: "icon_service")
                cell.contentLabel.text = UserData.shared.merchantModel?.servicephone ?? ""
            } else if indexPath.row == 3 {
                cell.titleLabel.text = "供需市场"
                cell.downLineView.isHidden = true
                cell.iconView.image = #imageLiteral(resourceName: "gx_icon")
            } else if indexPath.row == 4 {
                cell.titleLabel.text = "资料中心"
                cell.downLineView.isHidden = true
                cell.iconView.image = #imageLiteral(resourceName: "icon_zlzx")
            } else if indexPath.row == 5 {
                cell.titleLabel.text = "商城系统"
                cell.downLineView.isHidden = true
                cell.iconView.image = #imageLiteral(resourceName: "icon_scxt")
            }
            
        } else {
            if indexPath.row == 1 {
                cell.titleLabel.text = "资料中心"
                cell.downLineView.isHidden = true
                cell.iconView.image = #imageLiteral(resourceName: "icon_zlzx")
            }
        }        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if UserData.shared.userType == .yys {
            return 200
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if UserData.shared.userType == .yys {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 200))
            let exitBtn = UIButton().text("退出登录").textColor(.white).font(16).backgroundImage(#imageLiteral(resourceName: "regiest_put_btn"))
            v.sv(exitBtn)
            v.layout(
                >=0,
                |-15-exitBtn.height(44)-15-|,
                >=10
            )
            exitBtn.tapped { [weak self] (btn) in
                self?.exitAction()
            }
            return v
        }
        return UIView()
    }
    
    private func exitAction() {
        let popup = PopupDialog(title: "退出登录", message: "是否确定退出当前登录账号?", buttonAlignment: .horizontal)
        let sureBtn = AlertButton(title: "确认") {
            
            ToolsFunc.showLoginVC()
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }

    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            switch indexPath.row {
//            case 0:
//                let vc = WithdrawMoneyController()
//                navigationController?.pushViewController(vc, animated: true)
            case 0:
                let vc = PasswordModifyController()
                navigationController?.pushViewController(vc, animated: true)
            case 1:
            let cphoneVC = ChangePhoneController()
            self.navigationController?.pushViewController(cphoneVC, animated: true)
            case 2:
                modifyMobile()
            case 3:
                let vc = GXGLVC()
                self.navigationController?.pushViewController(vc, animated: true)
            case 4:
                let vc = MyDataCenterVC()
                self.navigationController?.pushViewController(vc, animated: true)
            case 5:
                ToolsFunc.clearData()
                let tokenModel = UserDefaults.standard.object(forKey: UserDefaultStr.tokenModel1)
                UserDefaults.standard.set(tokenModel, forKey: UserDefaultStr.tokenModel)
                UserData1.shared.tokenModel = Mapper<TokenModel1>().map(JSON: tokenModel as! [String: Any])
                getUserInfoRequest1()
            default:
                break
            }
        } else if UserData.shared.userType == .yys {
            switch indexPath.row {
//            case 0:
//                let vc = WithdrawMoneyController()
//                navigationController?.pushViewController(vc, animated: true)
            case 0:
                let vc = PasswordModifyController()
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                enterZLZX()
               // modifyMobile()
            default:
                break
            }
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



class OpenAccountInfoModel: NSObject, Mappable {
    var availableBalance : NSNumber? // 可用余额
    var bankAccount : String?
    var code : Int?
    var mobile : String?
    var name : String?
    var openBank : String?
    var pendingBalance : NSNumber?
    var remarks : String?
    var settleAccountId : String?
    var status : String?
    var totalBalance : NSNumber? 
    var type : String?
    var withdrawBalance : NSNumber?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    
    func mapping(map: Map)
    {
        availableBalance <- map["availableBalance"]
        bankAccount <- map["bankAccount"]
        code <- map["code"]
        mobile <- map["mobile"]
        name <- map["name"]
        openBank <- map["openBank"]
        pendingBalance <- map["pendingBalance"]
        remarks <- map["remarks"]
        settleAccountId <- map["settleAccountId"]
        status <- map["status"]
        totalBalance <- map["totalBalance"]
        type <- map["type"]
        withdrawBalance <- map["withdrawBalance"]
        
    }
}
