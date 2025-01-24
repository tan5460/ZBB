//
//  MyCenterController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/5.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import ObjectMapper
import Kingfisher

class MyCenterController: BaseViewController, UIScrollViewDelegate {

    var refreshView : UIView!                   //刷新控件底部视图
    var activityView: UIActivityIndicatorView!  //下拉加载时显示的菊花
    var refreshImage: UIImageView!              //下拉加载时的箭头
    var refreshLabel: UILabel!                  //下拉加载的提示语
    var changeViewBg: UIView!
    
    var scrollerView: UIScrollView!     //滚动视图
    var headImageView: UIImageView!     //上背景图
    var headerImageBtn: UIButton!       //头像
    var nameLabel: UILabel!             //姓名
    var displayJob: UILabel!            //职位
    var storeLabel: UILabel!            //店铺
//    var gradeLabel: UILabel!            //会员等级
//    var scoreLabel: UILabel!            //会员积分
//    var rankLabel: UILabel!             //本市排名
    var customerBtn: UIButton!            //我的客户
    var workBtn: UIButton!              //我的工地
    var selfBuildBtn: UIButton!         //自建品牌
    var recordView: UIView!             //交易背景
    var recordCountLabel: UILabel!      //交易量
    var recordMoneyLabel: UILabel!      //本月成交额
    var orderView: UIView!              //订单背景
    var cgOrderView: UIView!              //采购订单背景
    var unconfirmedCount: UILabel!      //待确认的订单数
    var unreadView: UIView!             //系统通知未读标记
    var chatBtn: UIButton!              //聊天
    var unreadMsgView: UIView!          //未读消息标记
    var unreadCount = 0
    var redView: UIView!                //小红点
  
    var headerHeight: CGFloat = 135*(IS_iPad ? PublicSize.PadRateHeight:PublicSize.RateHeight)
    var isRefresh = false
    
    var newOrderModel: OrderModel?
    
    ///系统消息
    var msgModel: SystemMsgModel? {
        get {
            var model: SystemMsgModel? = nil
            if let response = UserDefaults.standard.object(forKey: "SystemMsg") as? [String : AnyObject] {
                
                let localModel = Mapper<SystemMsgModel>().map(JSON: response)
                model = localModel
            }
            return model
        }
        set {
            
            if newValue != nil {
                if let dic = newValue?.toJSON() {
                    let localDic = DeleteEmpty.deleteEmpty(dic)!
                    UserDefaults.standard.set(localDic, forKey: "SystemMsg")
                }else {
                    UserDefaults.standard.set("", forKey: "SystemMsg")
                }
            }else {
                UserDefaults.standard.set("", forKey: "SystemMsg")
            }
        }
    }
    
    var userModel: WorkerModel? {
        
        didSet {
            
            nameLabel.text = "姓名缺失"
            storeLabel.text = ""
            
            if let valueStr = UserData.shared.storeModel?.name {
                storeLabel.text = valueStr
            }
            
            if let valueStr = userModel?.jobType {
                
                var vWidth = 44
                if valueStr == 999 {
                    displayJob.text = "管理员"
                    vWidth = 44
                }
                else if valueStr == 1 {
                    displayJob.text = "工长"
                    vWidth = 33
                }
                else if valueStr == 2 {
                    displayJob.text = "客户经理"
                    vWidth = 66
                }
                else if valueStr == 3 {
                    displayJob.text = "设计师"
                    vWidth = 44
                }
                else if valueStr == 4 {
                    displayJob.text = "采购员"
                    vWidth = 44
                }
                displayJob.snp.updateConstraints { (make) in
                    make.width.equalTo(vWidth)
                }
            }
            
            if let name = userModel?.realName {
                nameLabel.text = name
            }
            
            var headerImage = UIImage.init(named: "headerImage_man")
            
            if let valueType = userModel?.sex?.intValue {
                if valueType == 2 {
                    headerImage = UIImage.init(named: "headerImage_woman")
                }
            }
            
            headerImageBtn.setImage(headerImage, for: .normal)
            
            if let imagestr = userModel?.headUrl {
                
                if imagestr != "" {
                    
                    let imageUrl = URL(string: APIURL.ossPicUrl + imagestr)!
                    headerImageBtn.kf.setImage(with: imageUrl, for: .normal, placeholder: headerImage, options: nil, progressBlock: nil, completionHandler: nil)
                }
            }
            
            
            if  UserData.shared.workerModel?.jobType != 999 && UserData.shared.workerModel?.jobType != 4 {
                if UserData.shared.workerModel?.costMoneyLookFlag == "1" {
                    changeViewBg.snp.updateConstraints { (make) in
                        make.height.equalTo(44)
                    }
                }
                else {
                    changeViewBg.snp.updateConstraints { (make) in
                        make.height.equalTo(0)
                    }
                }
            }
           
            
        }
    }
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>> 我的界面释放 <<<<<<<<<<<<<<<<<")
        NotificationCenter.default.removeObserver(self)
        [GlobalNotificationer.HoNotification.order, .user, .record].forEach { GlobalNotificationer.remove(observer: self, notification: $0) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubView()
        createRefreshView()
        
        if UserData.shared.workerModel?.id != nil {
            userModel = UserData.shared.workerModel
        }
        
        //监听推送通知
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFirstMsg), name: Notification.Name.init("ReceiveNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUnreadData), name: Notification.Name.init("RefreshUnread"), object: nil)
        GlobalNotificationer.add(observer: self, selector: #selector(getNewUnconfirmedOrder), notification: .order)
        GlobalNotificationer.add(observer: self, selector: #selector(refreshUserData), notification: .user)
        GlobalNotificationer.add(observer: self, selector: #selector(getOrderCountData), notification: .record)

        self.pleaseWait()
        self.refreshAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.statusStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.statusStyle = .default
    }
    
    
    //MARK: - 触发事件
    
    /// 会员中心
    @objc func memberCenter() {
        let paySb = UIStoryboard.init(name: "PayStoryboard", bundle: nil)
        
        let vc = paySb.instantiateViewController(withIdentifier: "MemberCenterViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    ///刷新所有数据
    func refreshAllData() {
        getSystemMsg()
        refreshUserData()
        getOrderCountData()
        getNewUnconfirmedOrder()
        reloadConversationList()
    }
    
    ///更新未读标记
    func updateUnreadSign() {
        
        if chatBtn.isHidden {
            return
        }
        
        if unreadCount > 0 {
            unreadMsgView.isHidden = false
            tabBarController?.tabBar.showBadgeOnItem(index: 4, btnCount: 5)
            redView?.isHidden = false
        }else {
            unreadMsgView.isHidden = true
            redView?.isHidden = true
            tabBarController?.tabBar.hideBadgeOnItem(index: 4)
        }
    }
    
    ///进入前台
    @objc func refreshUnreadData() {
        reloadConversationList()
    }
    
    ///加载聊天会话
    @objc func reloadConversationList() {
        
        if chatBtn.isHidden {
            return
        }
        
        //聊天未读数
        let unreadCount = JMSGConversation.getAllUnreadCount().intValue
        UserDefaults.standard.set(unreadCount, forKey: "unreadCount")
        
        self.unreadCount = unreadCount
        self.updateUnreadSign()
    }
    
    ///设置
    @objc func settingAction() {
        
        let vc = MoreViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///点击头像
    @objc func headerImageAction() {
        let vc = UserInfoController()
        vc.userModel = userModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //开始刷新
    func startRefresh() {
        
        activityView.startAnimating()
        refreshImage.isHidden = true
        activityView.isHidden = false
        refreshLabel.text = "正在刷新..."
        
        refreshAllData()
    }
    
    ///停止刷新
    func stopRefresh() {
        
        activityView.stopAnimating()
        refreshView.isHidden = true
        isRefresh = false
    }
    
    private var modeTitle: String {
        get {
            return UserData.shared.userType == .jzgs ? "采购下单" : "客户下单"
        }
    }
    
    //主材商城
    @objc func toShop() {
        let maVC = StoreViewController()
        maVC.sjsFlag = true
        self.navigationController?.pushViewController(maVC, animated: true)
    }
    
    ///切换模式
    @objc func changeMode() {
        
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
    
    ///我的客户
    @objc func customerAction() {
        
        let vc = MyCustomController()
        vc.title = "我的客户"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///我的工地
    @objc func workSiteAction() {
        
        let vc = HouseViewController()
        vc.title = "我的工地"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///自建品牌
    @objc func selfBuildAction() {
        
        let vc = AddComMaterialController()
        vc.title = "自建产品"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///会员
    @objc func memberAction() {
        let vc = InvitationCodeController()
        navigationController?.pushViewController(vc, animated: true)
//        let vc = MemberViewController()
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///查看交易明细
    @objc func moreRecordAction() {
        
        let vc = OrderRecordController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///采购订单
    @objc func cgOrderAction() {
        let vc = PurchaseViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///查看更多订单
    @objc func moreOrderAction() {
        let vc = AllOrdersViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///订单按钮点击
    @objc func orderClickAction(_ sender:UIButton) {
        
        let vc = AllOrdersViewController()
        vc.topSelectBtnTag = sender.tag - 1000 + 1
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///消息
    @objc func msgListAction() {
        
        let vc = MessageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///我的邀请
    @objc func inviteAction() {
        
        let vc = MyInviteController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///运营商
    @objc func substationAction() {
        
        let subVC = SubstationController()
        subVC.substation = UserData.shared.workerModel?.substation
        self.navigationController?.pushViewController(subVC, animated: true)
    }
    
    ///聊天
    @objc func chatBtnClickAction() {
        
        let vc = ChatViewController()
        vc.title = "消息"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///系统通知
    @objc func msgAction() {
        
        let model = msgModel
        model?.isNewMsg = false
        msgModel = model
        unreadView.isHidden = true
        
        let vc = MessageViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func refreshFirstMsg(nofi : Notification) {
        
        if let msgType = nofi.userInfo!["msgType"] as? String{
            
            if msgType == "通知" {
                getSystemMsg()
            } else if msgType == "聊天" {
                reloadConversationList()
            }
        }
    }
    
    //MARK: - 网络请求
    
    ///获取第一条系统消息
    func getSystemMsg() {
        
        if chatBtn.isHidden {
            return
        }
        
        let parameters: Parameters = ["messageType": "1", "size": "1", "current": "1"]
        let urlStr = APIURL.getMsgPushList
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<SystemMsgModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if let firstModel = modelArray.first {
                    
                    if let msgId = self.msgModel?.id, msgId != firstModel.id {
                        firstModel.isNewMsg = true
                        self.msgModel = firstModel
                    }
                    
                    if self.msgModel == nil {
                        self.msgModel = firstModel
                    }
                    
                    if self.msgModel?.isNewMsg == true {
                        self.unreadView.isHidden = false
                    }else {
                        self.unreadView.isHidden = true
                    }
                }
            }
            
        }) { (error) in
            
        }
    }
    
    //获取用户信息
    @objc func refreshUserData() {
        isRefresh = true
        let urlStr = APIURL.getUserInfo
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            self.stopRefresh()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                //储存用户数据
                AppUtils.setUserData(response: response)
                self.userModel = UserData.shared.workerModel
                //更新极光信息
                YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                    
                })
            }
            else if errorCode == "018" {
                
                self.clearAllNotice()
                let popup = PopupDialog(title: "提示", message: "您的公司会员已过期，续费后才能恢复使用，请联系管理员前往后台续费！", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion:nil)

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
            
            self.stopRefresh()
        }
    }
    
    //获取交易记录
    @objc func getOrderCountData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        
        let parameters: Parameters = ["workerId": userId, "month": "1"]
        let urlStr = APIURL.getOrderCount
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<OrderRecordModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                self.recordCountLabel.text = "0"
                self.recordMoneyLabel.text = "0"
                if modelArray.count > 0 {
                    let recordModel = modelArray[0]
                    self.recordCountLabel.text = "\(recordModel.orderList?.count ?? 0)"
                    
                    if let valueStr = recordModel.totalAmount?.doubleValue {
                        self.recordMoneyLabel.text = valueStr.notRoundingString(afterPoint: 2)
                    }
                }
            }
            
        }) { (error) in
            
        }
    }
    
    //获取最新待确认订单数量
    @objc func getNewUnconfirmedOrder() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeID = valueStr
        }
        var jobType = ""
        if let valueStr = UserData.shared.workerModel?.jobType?.stringValue {
            jobType = valueStr
        }
        
        let parameters: Parameters = ["storeId": storeID, "workerId": userId, "jobType": jobType, "orderStatus": "1"]
        let urlStr = APIURL.getOrderNumber
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                var orderCount = Utils.getReadInt(dir: response as NSDictionary, field: "data")
                if orderCount > 0 {
                    if orderCount > 99 {
                        orderCount = 99
                    }
                    self.unconfirmedCount.text = "\(orderCount)"
                    self.unconfirmedCount.isHidden = false
                    
                    var labelWidth: CGFloat = 0
                    if orderCount < 10 {
                        labelWidth = 14
                    }else {
                        labelWidth = self.unconfirmedCount.text!.getLabWidth(font: self.unconfirmedCount.font) + 8
                    }
                    
                    self.unconfirmedCount.snp.updateConstraints { (make) in
                        make.width.equalTo(labelWidth)
                    }
                }else {
                    self.unconfirmedCount.text = "0"
                    self.unconfirmedCount.isHidden = true
                }
            }else {
                self.unconfirmedCount.text = "0"
                self.unconfirmedCount.isHidden = true
            }
            
        }) { (error) in
        }
    }
    
    
    //MARK: -  UIScrollViewDelegate
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView){

        AppLog("开始减速")

        if !isRefresh {
            
            if !refreshView.isHidden {
                AppLog("正在刷新")
                
                startRefresh()
            }
        }
    }
    
    //根据内容偏移量放大图片
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let refreshY: CGFloat = -50
        
        if !isRefresh {
            
            if scrollView.contentOffset.y < refreshY {
                refreshLabel.text = "松手即可刷新"
                refreshView.isHidden = false
                refreshImage.isHidden = false
                activityView.isHidden = true
            }
            else {
                refreshView.isHidden = true
            }
        }
        
        let point = scrollView.contentOffset
        let headerHeightNew = headerHeight - point.y
        
        if point.y < 0 {
            headImageView.frame = CGRect.init(x: 0, y: point.y, width: PublicSize.screenWidth, height: headerHeightNew)
        }else {
            headImageView.frame = CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: headerHeight)
        }
    }
}
