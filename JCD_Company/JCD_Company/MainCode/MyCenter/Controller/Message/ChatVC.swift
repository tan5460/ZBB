//
//  ChatVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2020/11/16.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import PopupDialog
import MJRefresh

class ChatVC: BaseViewController {
    var refreshChatConversationCount: (([JMSGConversation]) -> Void)?
    var conversations:[JMSGConversation] = []   //会话
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    private let noDataBtn = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        tableView.register(ChatSessionCell.self, forCellReuseIdentifier: ChatSessionCell.self.description())
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        tableView.refreshHeader { [weak self] in
            self?.msgRefresh()
        }
        //监听会话消息
        JMessage.add(self, with: nil)
        msgRefresh()
        
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无聊天消息～").textColor(.kColor66).font(14)
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
    }
    
    ///消息列表下拉刷新
    @objc func msgRefresh() {
        //加载聊天会话
        reloadConversationList()
    }
  
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        JMessage.remove(self, with: nil)
    }
    
    ///加载聊天会话
    @objc func reloadConversationList() {
        AppLog(">>>>>>>>>>>>>>>>>>>>> 收到聊天消息 <<<<<<<<<<<<<<<<<<<<")
        YZBChatRequest.shared.getAllConversationList(errorBlock:{(convers,error) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            if error == nil {
                self.conversations = convers
                self.refreshChatConversationCount?(self.conversations)
                self.tableView.reloadData()
                self.noDataBtn.isHidden = self.conversations.count > 0
                self.updateUnreadSign()
            }
        })
    }
    
    ///更新未读标记
    func updateUnreadSign() {
        //聊天未读数
        let unreadCount = conversations.unreadCount
        //本地缓存用户数据
        UserDefaults.standard.set(unreadCount, forKey: "unreadCount")
        if unreadCount <= 0 {
          //  changeTitleView.showOrhiddenUnReadView(index: 0, isHidden: true)
        }else {
          //  changeTitleView.showOrhiddenUnReadView(index: 0, isHidden: false)
        }
        
        //总标记
//        if unreadCount > 0 || backlogModel?.isNewLog == true {
//            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
//                tabBarController?.tabBar.showBadgeOnItem(index: 0, btnCount: 5)
//            }else {
//                tabBarController?.tabBar.showBadgeOnItem(index: 0, btnCount: 4)
//            }
//        }else {
//            tabBarController?.tabBar.hideBadgeOnItem(index: 0)
//        }
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatSessionCell.self.description(), for: indexPath) as! ChatSessionCell
        cell.msgView.isHidden = true
        cell.conversation = conversations[indexPath.row]
        if indexPath.row == conversations.count - 1 {
            cell.lineView.isHidden = true
        }else {
            cell.lineView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        //清空未读
        conversation.clearUnreadCount()
        refreshChatConversationCount?(conversations)
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatSessionCell else {
            return
        }
        cell.conversation = conversation
        
        if let userInfo = conversation.target as? JMSGUser {
            
            let userName = userInfo.username
            self.pleaseWait()
            
            YZBChatRequest.shared.getUserInfo(with: userName) { (user, error) in
                
                self.clearAllNotice()
                if error == nil {
                    let vc = ChatMessageController(conversation: conversation)
                    vc.convenUser = user
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .destructive, title: "删除") { (action, indexPath) in
            self.delete(indexPath)
        }
        return [action1]
    }
    
    func delete(_ indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        let tager = conversation.target
        JCDraft.update(text: nil, conversation: conversation)
        if conversation.ex.isGroup {
            guard let group = tager as? JMSGGroup else {
                return
            }
            JMSGConversation.deleteGroupConversation(withGroupId: group.gid)
        } else {
            guard let user = tager as? JMSGUser else {
                return
            }
            JMSGConversation.deleteSingleConversation(withUsername: user.username)
        }
        conversations.remove(at: indexPath.row)
       
        self.tableView.reloadData()
    }
}


//MAKE: JMessageDelegate
extension ChatVC: JMessageDelegate {
   
    //收到消息和会话后刷新界面
    //接收消息(服务器端下发的)回调
    func onReceive(_ message: JMSGMessage!, error: Error!) {
        reloadConversationList()
    }
    
    //发送消息结果返回回调
    func onSendMessageResponse(_ message: JMSGMessage!, error: Error!) {
        reloadConversationList()
    }
    
    //会话信息变更通知
    func onConversationChanged(_ conversation: JMSGConversation!) {
//        reloadConversationList()
    }
    
    //群组信息 (GroupInfo) 信息通知
    func onGroupInfoChanged(_ group: JMSGGroup!) {
        reloadConversationList()
    }
    
    //同步漫游消息通知
    func onSyncRoamingMessageConversation(_ conversation: JMSGConversation!) {
        reloadConversationList()
    }
    
    //同步离线消息、离线事件通知
    func onSyncOfflineMessageConversation(_ conversation: JMSGConversation!, offlineMessages: [JMSGMessage]!) {
        reloadConversationList()
    }
    
    //监听消息撤回事件
    func onReceive(_ retractEvent: JMSGMessageRetractEvent!) {
        reloadConversationList()
    }
    
    //监听消息回执状态变更事件
    func onReceive(_ receiptEvent: JMSGMessageReceiptStatusChangeEvent!) {
        reloadConversationList()
    }
    
    //监听当前用户登录状态变更事件
    func onReceive(_ event: JMSGUserLoginStatusChangeEvent!) {
        
        if event.eventType.rawValue == JMSGLoginStatusChangeEventType.eventNotificationLoginKicked.rawValue ||
           event.eventType.rawValue == JMSGLoginStatusChangeEventType.eventNotificationServerAlterPassword.rawValue ||
            event.eventType.rawValue == JMSGLoginStatusChangeEventType.eventNotificationUserLoginStatusUnexpected.rawValue ||
            event.eventType.rawValue == JMSGLoginStatusChangeEventType.eventNotificationCurrentUserDeleted.rawValue ||
            event.eventType.rawValue == JMSGLoginStatusChangeEventType.eventNotificationCurrentUserDisabled.rawValue {
            let window = UIApplication.shared.windows.first
            window?.clearAllNotice()
            let vc = window?.rootViewController
            let popup = PopupDialog(title: "下线提示", message: "您的账号已在另一台设备中登录，如非本人操作，则密码可能已经泄露，建议立即修改密码！", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
            
            let sureBtn = AlertButton(title: "确认") {
                ToolsFunc.showLoginVC()
            }
            popup.addButtons([sureBtn])
            vc?.present(popup, animated: true, completion: nil)
        }
    }
   
}
