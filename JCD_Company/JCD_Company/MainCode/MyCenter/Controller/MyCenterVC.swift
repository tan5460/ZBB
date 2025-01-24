//
//  MyCenterVC.swift
//  YZB_Company
//
//  Created by Cloud on 2020/3/9.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Then
import Alamofire
import PopupDialog
import Kingfisher
import ObjectMapper

class MyCenterVC: BaseViewController {

    private var modeTitle: String {
        get {
            return UserData.shared.userType == .jzgs ? "采购下单" : "客户下单"
        }
    }
    private var tableView: UITableView!
    private let tableViewHeaderView =  UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.statusStyle = .lightContent
        getUserInfoRequest()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.statusStyle = .default
    }
    
    func getUserInfoRequest() {
        YZBSign.shared.request(APIURL.getUserInfo, method: .get, parameters: Parameters(), success: { (response) in
            let dataDic = Utils.getReqDir(data: response as AnyObject)
            let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
            UserData.shared.userInfoModel = infoModel
            self.configHeaderViewData()
            self.tableView.reloadData()
        }) { (error) in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topIV = UIImageView().image(#imageLiteral(resourceName: "myCenter_top_bg"))
        view.sv(topIV)
        view.layout(
            0,
            |topIV.height(385)|,
            >=0
        )
        
        tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height), style: .grouped)
        tableView.backgroundColor(.clear)
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = true
        }
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.tableHeaderView = tableHeaderView()
    }
    
    
    func tableHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: 304+PublicSize.kStatusBarHeight)).backgroundColor(.clear)
        let bottomView = UIView().backgroundColor(.white)
        headerView.sv(bottomView)
        headerView.layout(
            >=0,
            |bottomView.height(76)|,
            0
        )
        bottomView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 40)
        bottomView.addShadowColor()
        
        configHeaderView(headerView)
        return headerView
    }
    
    private let avatar = UIImageView().cornerRadius(40).masksToBounds()
    private let company = UILabel().text("点石装饰公司").textColor(.white).font(16, weight: .bold)
    private let name = UILabel().text("谭谭谭    销售员").textColor(.white).font(14)
    private let topBtnBgView = UIView().backgroundColor(.white).cornerRadius(40).masksToBounds()
    
    /// 供需市场
    private let managerBtn = UIButton().text("供需市场").textColor(PublicColor.c333).font(14).image(#imageLiteral(resourceName: "my_manager_icon"))
    /// 我的工地
    private let siteBtn = UIButton().text("我的工地").textColor(PublicColor.c333).font(14).image(#imageLiteral(resourceName: "my_site_icon"))
    /// 资料中心
    private let dataBtn = UIButton().text("资料中心").textColor(PublicColor.c333).font(14).image(#imageLiteral(resourceName: "my_data_icon"))
    
    private func configHeaderView(_ v: UIView) {
        v.sv(avatar, company, name, topBtnBgView)
        v.layout(
            21+PublicSize.kStatusBarHeight,
            avatar.size(80).centerHorizontally(),
            10,
            company.height(22.5).centerHorizontally(),
            5,
            name.height(20).centerHorizontally(),
            33,
            |-27.5-topBtnBgView.height(80)-27.5-|,
            >=0
        )
        topBtnBgView.addShadowColor()
        
        let btnW = (PublicSize.screenWidth-55)/3
        topBtnBgView.sv(managerBtn, siteBtn, dataBtn)
        topBtnBgView.layout(
            0,
            |managerBtn.width(btnW)-0-siteBtn.width(btnW)-0-dataBtn.width(btnW)|,
            0
        )
        avatar.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(avatarTap)))
        managerBtn.set(image: #imageLiteral(resourceName: "my_manager_icon"), title: "供需市场", imagePosition: .top, additionalSpacing: 6, state: .normal)
        siteBtn.set(image: #imageLiteral(resourceName: "my_site_icon"), title: "我的工地", imagePosition: .top, additionalSpacing: 6, state: .normal)
        dataBtn.set(image: #imageLiteral(resourceName: "my_data_icon"), title: "资料中心", imagePosition: .top, additionalSpacing: 6, state: .normal)
        managerBtn.addTarget(self, action: #selector(managerBtnClick))
        siteBtn.addTarget(self, action: #selector(siteBtnClick))
        dataBtn.addTarget(self, action: #selector(dataBtnClick))
        configHeaderViewData()
    }
    
    private var job = "管理员"
    private func configHeaderViewData() {
        if let urlStr = UserData.shared.workerModel?.headUrl, !urlStr.isEmpty, let url = URL.init(string: APIURL.ossPicUrl + urlStr) {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = #imageLiteral(resourceName: "img_buyer")
        }
        company.text = UserData.shared.storeModel?.name
        if let valueStr = UserData.shared.workerModel?.jobType {
            if valueStr == 999 {
                job = "管理员"
            } else if valueStr == 1 {
                job = "工长"
            } else if valueStr == 2 {
                job = "客户经理"
            } else if valueStr == 3 {
                job = "设计师"
            } else if valueStr == 4 {
                job = "采购员"
            }
        }
        name.text = "\(UserData.shared.workerModel?.realName ?? "")    \(job)"
    }
}
// MARK: - button Click methods
extension MyCenterVC {
    /// 点击头像
    @objc func avatarTap() {
        let vc = UserInfoController()
        vc.userModel = UserData.shared.workerModel
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 进入供需市场
    @objc func managerBtnClick() {
        let vc = GXGLVC()
        navigationController?.pushViewController(vc)
    }
    /// 进入我的工地
    @objc func siteBtnClick() {
        let vc = HouseViewController()
        vc.title = "我的工地"
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 进入资料中心
    @objc func dataBtnClick() {
        let vc = MyDataCenterVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView delegate datasource
extension MyCenterVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserData.shared.sjsEnter || job == "管理员" || job == "采购员" {
            return 5
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
        if UserData.shared.sjsEnter || job == "管理员" || job == "采购员" {
            switch indexPath.row {
            case 0:
                cell.imageView?.image(#imageLiteral(resourceName: "myCenter_order"))
                cell.textLabel?.text = "客户订单"
            case 1:
                if UserData.shared.sjsEnter {
                    cell.imageView?.image(#imageLiteral(resourceName: "myCenter_mall"))
                    cell.textLabel?.text = "产品商城"
                } else {
                    cell.imageView?.image(#imageLiteral(resourceName: "myCenter_switch"))
                    cell.textLabel?.text = "切换模式"
                    cell.detailTextLabel?.text = "“客户下单”模式"
                }
            case 2:
                cell.imageView?.image(#imageLiteral(resourceName: "myCenter_message"))
                cell.textLabel?.text = "消息"
            case 3:
                cell.imageView?.image(#imageLiteral(resourceName: "myCenter_contact"))
                cell.textLabel?.text = "联系客服"
            default:
                cell.imageView?.image(#imageLiteral(resourceName: "myCenter_set"))
                cell.textLabel?.text = "设置"
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.imageView?.image(#imageLiteral(resourceName: "myCenter_order"))
                cell.textLabel?.text = "客户订单"
            case 1:
                cell.imageView?.image(#imageLiteral(resourceName: "myCenter_message"))
                cell.textLabel?.text = "消息"
            case 2:
                cell.imageView?.image(#imageLiteral(resourceName: "myCenter_contact"))
                cell.textLabel?.text = "联系客服"
            default:
                cell.imageView?.image(#imageLiteral(resourceName: "myCenter_set"))
                cell.textLabel?.text = "设置"
                break
            }
        }
        _ = cell.textLabel?.font(14).textColor(PublicColor.c333)
        _ = cell.detailTextLabel?.font(14).textColor(PublicColor.c999)
        if cell.textLabel?.text == "联系客服" {
            let icon = UIImageView()
            icon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            icon.image = #imageLiteral(resourceName: "service_phone")
            cell.accessoryView = icon
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if UserData.shared.sjsEnter || job == "管理员" || job == "采购员"  {
            switch indexPath.row {
            case 0:
                enterOrdersVC()
            case 1:
                if UserData.shared.sjsEnter {
                    enterMallVC()
                } else {
                    enterSwitchModeVC()
                }
            case 2:
                enterMessageVC()
            case 3:
                contactSubstation()
            default:
                enterSetVC()
            }
        } else {
            switch indexPath.row {
            case 0:
                enterOrdersVC()
            case 1:
                enterMessageVC()
            case 2:
                contactSubstation()
            default:
                enterSetVC()
            }
        }
        
    }
    /// 进入客户订单
    private func enterOrdersVC() {
        let vc = AllOrdersViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 进入产品商城
    private func enterMallVC() {
        let maVC = StoreViewController()
        maVC.sjsFlag = true
        self.navigationController?.pushViewController(maVC, animated: true)
    }
    /// 进入切换模式
    private func enterSwitchModeVC() {
        let tip = "是否切换为\"\(modeTitle)\"模式"
        let popup = PopupDialog(title: "切换模式", message: tip, buttonAlignment: .horizontal)
        let sureBtn = AlertButton(title: "确认") {
            if let window = UIApplication.shared.keyWindow {
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    let oldState: Bool = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(false)
                    if UserData.shared.userType == .jzgs {
                        AppUtils.setUserType(type: .cgy)
                    }else {
                        AppUtils.setUserType(type: .jzgs)
                    }
                    //更新极光用户信息
                    YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                    })
                    
                    window.rootViewController = MainViewController()
                    UIView.setAnimationsEnabled(oldState)
                })
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    /// 进入消息页面
    private func enterMessageVC() {
        let vc = ChatVC()
        vc.title = "消息"
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 进入联系客服页面
    func contactSubstation() {
        let substation = UserData.shared.substationModel
        
        houseListCallTel(name: substation?.groupName ?? "", phone: substation?.mobile ?? "")
        
        return
        
        var userId = ""
        var userName = ""
        var storeName = ""
        var headUrl = ""
        var nickname = ""
        var tel1 = ""
        let tel2 = ""
        let storeType = "3"
        
        if let valueStr = substation?.id {
            userId = valueStr
        }
        if let valueStr = substation?.userName {
            userName = valueStr
        }
        if let valueStr = substation?.fzName {
            storeName = valueStr
        }
        if let valueStr = substation?.headUrl {
            headUrl = valueStr
        }
        if let valueStr = substation?.realName {
            nickname = valueStr
        }
        if let valueStr = substation?.mobile {
            tel1 = valueStr
        }
        
        let ex: NSDictionary = ["detailTitle": storeName, "headUrl":headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
        
        let user = JMSGUserInfo()
        user.nickname = nickname
        user.extras = ex as! [AnyHashable : Any]
        updConsultNumRequest(id: userId)
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
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                
            }else {
                if error!._code == 898002 {
                    
                    YZBChatRequest.shared.register(with: userName, pwd: YZBSign.shared.passwordMd5(password: userName), userInfo: user, errorBlock: { (error) in
                        if error == nil {
                            self.contactSubstation()
                        }
                    })
                }
            }
        }
    }
    /// 进入设置页面
    private func enterSetVC() {
        let vc = MoreViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}

