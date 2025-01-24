//
//  ChatViewController+Delegate.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/4.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import PopupDialog

//MAKE: UITableViewDelegate, UITableViewDataSource
extension ChatViewController:UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
//        if UserData.shared.userType == .jzgs {
//            return 1
//        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if section == 0 && UserData.shared.userType != .jzgs {
//            return 1
//        }
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatSessionCell.self.description(), for: indexPath) as! ChatSessionCell
        cell.msgView.isHidden = true
        
//        if indexPath.section == 0 && UserData.shared.userType != .jzgs {
//
//            cell.avatarView.image = UIImage(named: "Chat_inform")
//            cell.nameLabel.text = "通知"
//            cell.detailNameLabel.text = "系统通知"
//            cell.detailLabel.text = ""
//            cell.timeLabel.text = ""
//            if conversations.count == 0 {
//                cell.lineView.isHidden = true
//            }else {
//                cell.lineView.isHidden = false
//            }
//
//            if let valueStr = msgModel?.messageTitle {
//                cell.detailLabel.text = valueStr
//            }
//
//            if let valueStr = msgModel?.pushTime?.doubleValue {
//
//                let date = Date(timeIntervalSince1970: valueStr/1000)
//                let dfmatter = DateFormatter()
//                dfmatter.dateFormat="MM-dd HH:mm"
//                let timeStr = dfmatter.string(from: date)
//                cell.timeLabel.text = timeStr
//            }
//
//            if msgModel?.isNewMsg == true {
//                cell.msgView.isHidden = false
//            }
//
//        } else {
//
//
//        }
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
        
//        if indexPath.section == 0 && UserData.shared.userType != .jzgs {
//            let model = msgModel
//            model?.isNewMsg = false
//            msgModel = model
//
//            let vc = MessageViewController()
//            navigationController?.pushViewController(vc, animated: true)
//            return
//        }
        
        let conversation = conversations[indexPath.row]
        
        //清空未读
        conversation.clearUnreadCount()
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if indexPath.section == 0 && UserData.shared.userType != .jzgs {
//            return false
//        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action1 = UITableViewRowAction(style: .destructive, title: "删除") { (action, indexPath) in
            self.delete(indexPath)
        }
//        let conversation = conversations[indexPath.row]
//        let action2 = UITableViewRowAction(style: .normal, title: "置顶") { (action, indexPath) in
//            conversation.ex.isSticky = !conversation.ex.isSticky
//            self.reloadConversationList()
//        }
//        if conversation.ex.isSticky {
//            action2.title = "取消置顶"
//        } else {
//            action2.title = "置顶"
//        }
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
extension ChatViewController: JMessageDelegate {
   
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
            let window = UIApplication.shared.keyWindow
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
