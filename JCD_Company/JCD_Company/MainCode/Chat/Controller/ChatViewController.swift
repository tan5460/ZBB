//
//  ChatViewController.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/3.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import PopupDialog
import MJRefresh
import TLTransitions

class ChatViewController: BaseViewController {

    var conversations:[JMSGConversation] = []   //会话
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
    
    ///待办
    var backlogModel: BacklogModel? {
        get {
            var model: BacklogModel? = nil
            if let response = UserDefaults.standard.object(forKey: "backlog") as? [String : AnyObject] {
                
                let localModel = Mapper<BacklogModel>().map(JSON: response)
                model = localModel
            }
            return model
        }
        set {
            
            if newValue != nil {
                if let dic = newValue?.toJSON() {
                    let localDic = DeleteEmpty.deleteEmpty(dic)!
                    UserDefaults.standard.set(localDic, forKey: "backlog")
                }else {
                    UserDefaults.standard.set("", forKey: "backlog")
                }
            }else {
                UserDefaults.standard.set("", forKey: "backlog")
            }
        }
    }

    
    lazy var changeTitleView: ChangeTitleView = {
        let ctView = ChangeTitleView()
        
        return ctView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.estimatedRowHeight = 65
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        // 注册cell
        tableView.register(ChatSessionCell.self, forCellReuseIdentifier: ChatSessionCell.self.description())
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(msgRefresh))
        tableView.mj_header = header
        tableView.isHidden = true
        return tableView
    }()
    
    lazy var backlogView: BacklogTableView = {
        
        let bview = BacklogTableView()
        bview.isHidden = false
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        bview.tableView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        bview.tableView.mj_footer = footer
        bview.tableView.mj_footer?.isHidden = true
        
        return bview
    }()
    
    var curPage = 1     //页码
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>> 聊天界面释放 <<<<<<<<<<<<<<")
        GlobalNotificationer.remove(observer: self, notification: .yysSureOrderRefresh)
        GlobalNotificationer.remove(observer: self, notification: .purchaseRefresh)
        NotificationCenter.default.removeObserver(self)
        JMessage.remove(self, with: nil)
    }
    
    
    //MARK: - 杉德支付系统弹窗
    private var pop: TLTransition?
    @objc private func showPayTipPopView() {
        let v = UIView().backgroundColor(.white)
        v.frame = CGRect(x: 0, y: 0, width: 313, height: 475)
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        
        
        var role = ""
        
        switch UserData.shared.userType  {
        case .gys:
            role = "品牌商"
        case .fws:
            role = "服务商"
        case .yys:
            role = "城市分站"
        default:
            break
        }
        
        let title = UILabel().text("亲爱的\(role)：您好！").textColor(.kColor33).font(14)
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "unallow_icon"))
        let sv = UIScrollView()
        let okBtn = UIButton().text("申请入网").textColor(.white).font(14).cornerRadius(15).masksToBounds()
        
        
        
        v.sv(title, closeBtn, sv, okBtn)
        v.layout(
            15,
            |-20-title.height(22.5),
            20,
            |-0-sv-0-|,
            17.5,
            okBtn.width(130).height(30).centerHorizontally(),
            25
        )
        v.layout(
            5,
            closeBtn.size(30)-5-|,
            >=0
        )
        
        closeBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss()
        }
        let content = UILabel().textColor(.kColor66).font(14)
        
        switch UserData.shared.userType {
        case .gys:
            content.text("        为配合国家相关法规，从2020年12月20日开始，平台支付系统将变更为杉德支付，商家须在杉德支付系统进行开户。否则，商家在平台的部分功能将会受限。\n\n受限功能包括：\na.产品在会员端的展示\nb.商家的正常收款\n为保证线上产品的正常交易，请尽快进行开户。\n\n开户步骤：\n1.提交入网申请\n2.进行在线签约\n3.激活账号并设置密码\n\n商家开户可联系聚材道在线客服，或拨打400-698-7066。")
        case .fws:
            content.text("        为配合国家相关法规，从2020年12月20日开始，平台支付系统将变更为杉德支付，商家须在杉德支付系统进行开户。否则，商家在平台的部分功能将会受限。\n\n受限功能包括：\n\na.商家的正常收款\n\n为保证线上服务产品的正常交易，请尽快进行开户。\n\n开户步骤：\n1.提交入网申请\n2.进行在线签约\n3.激活账号并设置密码\n\n个体户提交收款信息即可，商家开户可联系聚材道在线客服，或拨打400-698-7066。")
        case .yys:
            content.text("        为配合国家相关法规，从2020年12月20日开始，平台支付系统将变更为杉德支付，商家须在杉德支付系统进行开户。否则，商家在平台的部分功能将会受限。\n\n受限功能包括：\na.商家的正常分账收款\n为保证商家正常分账收款，请尽快进行开户。\n\n开户步骤：\n1.提交入网申请\n2.进行在线签约\n3.激活账号并设置密码\n\n商家开户可联系聚材道在线客服，或拨打400-698-7066。")
        default:
            break
        }
        content.numberOfLines(0).lineSpace(2)
        sv.sv(content)
        sv.layout(
            10,
            content.width(273).centerHorizontally(),
            10
        )
        okBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.11, green: 0.77, blue: 0.59, alpha: 1).cgColor, UIColor(red: 0.38, green: 0.85, blue: 0.73, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = okBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        okBtn.layer.insertSublayer(bgGradient, at: 0)
        
        if UserData.shared.userType == .fws {
            if UserData.shared.merchantModel?.isComFlag == "1" {
                okBtn.text("申请入网")
                okBtn.addTarget(self, action: #selector(okBtnClick(btn:)))
            } else if UserData.shared.merchantModel?.isComFlag == "2" {
                okBtn.text("结算信息")
                okBtn.addTarget(self, action: #selector(okBtnClick1(btn:)))
            }
        } else {
            okBtn.addTarget(self, action: #selector(okBtnClick(btn:)))
        }
    }
    
    @objc private func okBtnClick(btn: UIButton) {
        pop?.dismiss(completion: {
            let vc = RWSQZLPutVC()
            self.navigationController?.pushViewController(vc)
        })
        
    }
    
    @objc private func okBtnClick1(btn: UIButton) {
        pop?.dismiss(completion: {
            let vc = RWSQStepTwoVC()
            self.navigationController?.pushViewController(vc)
        })
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let centerBtn = UIButton().image(#imageLiteral(resourceName: "system_icon"))
//        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: centerBtn)
//        centerBtn.tapped { [weak self] (btn) in
//            let vc = SystemNotiVC()
//            self?.navigationController?.pushViewController(vc)
//        }
        
        //获取用户本地信息
        AppUtils.getLocalUserData()
        
        //监听推送通知
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFirstMsg), name: Notification.Name.init("ReceiveNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(msgRefresh), name: Notification.Name.init("RefreshUnread"), object: nil)
        GlobalNotificationer.add(observer: self, selector: #selector(headerRefresh), notification: .purchaseRefresh)
        GlobalNotificationer.add(observer: self, selector: #selector(removeRefresh), notification: .yysSureOrderRefresh)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(backlogView)
        backlogView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.prepareNoDateView("暂无消息")
        
        if UserData.shared.userType != .jzgs {
            self.navigationItem.titleView = changeTitleView
        }
        
        changeTitleView.selectItemIndex = {[weak self] (index) in
            
            self?.tableView.isHidden = index == 1 ? false:true
            self?.backlogView.isHidden = index == 0 ? false:true
            
            if index == 0 {
                let model = self?.backlogModel
                model?.isNewLog = false
                self?.backlogModel = model
            }
            if let count = self?.backlogView.data.count, count <= 0 {
                self?.headerRefresh()
            }
            self?.updateUnreadSign()
        }
        //监听会话消息
        JMessage.add(self, with: nil)
        msgRefresh()

    }
    
    @objc func removeRefresh() {
        backlogView.refreshRemoveItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfoRequest()
    }
    
    func getUserInfoRequest() {
        let userId = UserData1.shared.tokenModel?.userId
        if userId == "977497a7672ed50e903de5f4fecc38d9" || userId == "4616ad3063925358c7c3712efa890b0e" || userId == "d3b20c22f06e4b2ab16497dd57ba0f67" {
            return
        }
        YZBSign.shared.request(APIURL.getUserInfo, method: .get, parameters: Parameters(), success: { (response) in
            
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let openAcctStatus = dataDic["openAcctStatus"] as? String
                if openAcctStatus != "1" {
                    self.showPayTipPopView()
                }
            }
        }) { (error) in
            
        }
    }
    
    //待办下拉刷新
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        
        loadBacklogData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        if self.backlogView.data.count > 0 {
            curPage += 1
        }else {
            curPage = 1
        }
        loadBacklogData()
    }
    
    ///消息列表下拉刷新
    @objc func msgRefresh() {
        
        //加载聊天会话
        reloadConversationList()
        
        //获取收条系统消息、待办
        getSystemMsg()
        loadBacklogData()
    }
  
    //获取首条消息
    @objc func refreshFirstMsg(nofi : Notification){
        
        if let msgType = nofi.userInfo!["msgType"] as? String{
            
            if msgType == "待办" {
                headerRefresh()
            }else if msgType == "通知" {
                getSystemMsg()
            }
        }
    }
    
    ///更新未读标记
    func updateUnreadSign() {
        
        //聊天未读数
        let unreadCount = conversations.unreadCount
        
        //本地缓存用户数据
        UserDefaults.standard.set(unreadCount, forKey: "unreadCount")
        
        if unreadCount <= 0 {
            changeTitleView.showOrhiddenUnReadView(index: 0, isHidden: true)
        }else {
            changeTitleView.showOrhiddenUnReadView(index: 0, isHidden: false)
        }
        
        //待办标记
        if backlogModel?.isNewLog == true {
            changeTitleView.showOrhiddenUnReadView(index: 1, isHidden: false)
        }else {
            changeTitleView.showOrhiddenUnReadView(index: 1, isHidden: true)
        }
        
        //总标记
        if unreadCount > 0 || backlogModel?.isNewLog == true {
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                tabBarController?.tabBar.showBadgeOnItem(index: 0, btnCount: 5)
            }else {
                tabBarController?.tabBar.showBadgeOnItem(index: 0, btnCount: 4)
            }
        }else {
            tabBarController?.tabBar.hideBadgeOnItem(index: 0)
        }
    }
    
    
    //MARK: - 网络请求
    
    ///获取第一条系统消息
    func getSystemMsg() {
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
                }
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            
        }
    }
    
    ///加载聊天会话
    @objc func reloadConversationList() {
        
        AppLog(">>>>>>>>>>>>>>>>>>>>> 收到聊天消息 <<<<<<<<<<<<<<<<<<<<")
        YZBChatRequest.shared.getAllConversationList(errorBlock:{(convers,error) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            if error == nil {
                
                self.conversations = convers
//                if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
//                    if self.conversations.count == 0 {
//                        self.noDataView.isHidden = false
//                    } else {
//                        self.noDataView.isHidden = true
//                    }
//                }
                self.tableView.reloadData()
                self.updateUnreadSign()
            }
        })
    }
    
    ///请求接口
//    private var url: String {
//        get {   // getMsgList      getList
//            return (UserData.shared.workerModel?.jobType == 4 || UserData.shared.workerModel?.jobType == 999) ? APIURL.getMessageList : APIURL.getMsgList
//        }
//    }
    
    ///获取待办
    @objc func loadBacklogData() {
        
        var urlStr = ""
        if UserData.shared.userType == .cgy {
            urlStr = APIURL.pageStoreMessage
        } else if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            urlStr = APIURL.pageMerchantMessage
        } else if UserData.shared.userType == .yys {
            urlStr = APIURL.pageMerchantMessage
        }
        let pageSize = 20
        var parameters = Parameters()
        parameters["messageType"] = 2
        parameters["current"] = "\(curPage)"
        parameters["size"] = 10
        
        if UserData.shared.userType == .gys {
            
        }else if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            

        } else if UserData.shared.userType == .yys {
//            var userId = ""
//            if let valueStr = UserData.shared.substationModel?.id {
//                userId = valueStr
//            }
//            parameters["substationId"] = userId
//            parameters["type"] = "2"
//            parameters["orderStatus"] = "9"
        }
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.backlogView.tableView.mj_header?.endRefreshing()
            self.backlogView.tableView.mj_footer?.endRefreshing()
            self.backlogView.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<BacklogModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.curPage == 1 {
                    if modelArray.count <= 0 {
                        let logModel = self.backlogModel
                        logModel?.isNewLog = false
                        self.backlogModel = logModel
                    }
                    
                    if let firstModel = modelArray.first {
                        
                        if let backlogId = self.backlogModel?.id, backlogId != firstModel.id {
                            firstModel.isNewLog = true
                            self.backlogModel = firstModel
                        }
                        
                        if self.backlogModel == nil {
                            self.backlogModel = firstModel
                        }
                    }
                    
                    if self.changeTitleView.segmentView.selectedSegmentIndex == 1 && self.tabBarController?.selectedIndex == 0 {
                        
                        let substitute = self.backlogModel
                        substitute?.isNewLog = false
                        self.backlogModel = substitute
                    }
                    
                    //更新未读标记
                    self.updateUnreadSign()
                }
                
                if self.curPage > 1 {
                    self.backlogView.data += modelArray
                }
                else {
                    self.backlogView.data = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.backlogView.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.backlogView.tableView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.backlogView.data.removeAll()
            }
            
            self.backlogView.tableView.reloadData()
            
            if self.backlogView.data.count <= 0 {
                self.backlogView.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
        }) { (error) in
            
            // 结束刷新
            self.backlogView.tableView.mj_header?.endRefreshing()
            self.backlogView.tableView.mj_footer?.endRefreshing()
            self.backlogView.tableView.mj_footer?.isHidden = false
        }
    }
}
