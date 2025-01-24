//
//  MessageNotiVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2020/11/16.
//

import UIKit
import Stevia

class MessageNotiVC: BaseViewController {
    private let backBtn = UIButton().image(#imageLiteral(resourceName: "detail_back"))
    private let titleLabel = UILabel().text("消息通知").textColor(.kColor33).fontBold(18)
    private let titleScrollView =  UIScrollView().backgroundColor(.clear)
    private let pageScrollView = UIScrollView().backgroundColor(.clear)
    private var titles = ["待办", "聊天", "通知"]
    private var titleBtns = [UIButton]()
    private var vcs = [BaseViewController]()
    private var waitDoUnReadLabel = UILabel().textColor(.white).font(10).textAligment(.center).cornerRadius(7).masksToBounds().backgroundColor(.kDF2F2F)
    private var chatUnReadLabel = UILabel().textColor(.white).font(10).textAligment(.center).cornerRadius(7).masksToBounds().backgroundColor(.kDF2F2F)
    private var msgUnReadLabel = UILabel().textColor(.white).font(10).textAligment(.center).cornerRadius(7).masksToBounds().backgroundColor(.kDF2F2F)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        statusStyle = .default
        let line = UIView().backgroundColor(.kColorEE)
        view.sv(backBtn, titleLabel, line, titleScrollView ,pageScrollView)
        view.layout(
            PublicSize.kStatusBarHeight,
            |-5-backBtn.size(44)-(>=0)-titleLabel.centerHorizontally(),
            0,
            |line.height(0.5)|,
            0,
            |titleScrollView.height(37)|,
            0,
            |pageScrollView|,
            0
        )
        pageScrollView.layoutIfNeeded()
        pageScrollView.isPagingEnabled = true
        pageScrollView.isScrollEnabled = false
        pageScrollView.bounces = true
        pageScrollView.delegate = self
        titleScrollView.showsHorizontalScrollIndicator = false
        backBtn.addTarget(self , action: #selector(backBtnClick(btn:)))
        refresh()
        loadData()
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
    
    func loadData() {
        YZBSign.shared.request(APIURL.msgCount, method: .get, parameters: Parameters()) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let noticeCount = dataDic["noticeCount"] as? Int
                let dealtWithCount = dataDic["dealtWithCount"] as? Int
               // let msgCount = dataDic["msgCount"] as? String
                if noticeCount ?? 0 > 0 {
                    self.msgUnReadLabel.isHidden = false
                    self.msgUnReadLabel.text("\(noticeCount ?? 0)")
                } else {
                    self.msgUnReadLabel.isHidden = true
                    self.msgUnReadLabel.text("\(noticeCount ?? 0)")
                }
                if dealtWithCount ?? 0 > 0 {
                    self.waitDoUnReadLabel.isHidden = false
                    self.waitDoUnReadLabel.text("\(dealtWithCount ?? 0)")
                } else {
                    self.waitDoUnReadLabel.isHidden = true
                    self.waitDoUnReadLabel.text("\(dealtWithCount ?? 0)")
                }
            }
        } failure: { (error) in
            
        }

    }
    //MARK: - 刷新聊天未读数量
    func refreshChatUnreadCount(conversations: [JMSGConversation]) {
        let unreadCount = conversations.unreadCount
        if unreadCount > 0 {
            self.chatUnReadLabel.isHidden = false
            self.chatUnReadLabel.text("\(unreadCount )")
        } else {
            self.chatUnReadLabel.isHidden = true
            self.chatUnReadLabel.text("\(unreadCount )")
        }
    }
    
    func refresh() {
        let btnW: CGFloat = (view.width-28)/3
        titles.enumerated().forEach { (item) in
            // 标题栏
            let index = item.offset
            let title = item.element
            let offsetX: CGFloat = 14 + btnW * CGFloat(index)
            let titleBtn = UIButton().text(title).textColor(.k2FD4A7).font(12)
            titleScrollView.sv(titleBtn)
            titleScrollView.layout(
                0,
                |-offsetX-titleBtn.width(btnW).height(37),
                0
            )
            titleBtn.tag = index
            titleBtn.addTarget(self, action: #selector(titleBtnClick(btn:)))
            titleBtns.append(titleBtn)
            
            let line = UIView().backgroundColor(.k2FD4A7).cornerRadius(1)
            line.tag = 10001
            titleBtn.sv(line)
            titleBtn.layout(
                >=0,
                line.width(24).height(2).centerHorizontally(),
                2
            )
            if index > 0 {
                line.isHidden = true
                titleBtn.textColor(.kColor33)
            }
            if index == 0 {
                titleBtn.sv(waitDoUnReadLabel)
                titleBtn.layout(
                    5,
                    waitDoUnReadLabel.size(14).centerHorizontally(20),
                    >=0
                )
                waitDoUnReadLabel.isHidden = true
            }
            
            if index == 1 {
                titleBtn.sv(chatUnReadLabel)
                titleBtn.layout(
                    5,
                    chatUnReadLabel.size(14).centerHorizontally(20),
                    >=0
                )
                chatUnReadLabel.isHidden = true
            }
            
            if index == 2 {
                titleBtn.sv(msgUnReadLabel)
                titleBtn.layout(
                    5,
                    msgUnReadLabel.size(14).centerHorizontally(20),
                    >=0
                )
                msgUnReadLabel.isHidden = true
            }
            
            // 页面栏
            let pageOffsetX: CGFloat = view.width*CGFloat(index)
            if index == 0 {
                let vc = WaitDoVC()
                vc.refreshMsgCount = { [weak self] in
                    self?.loadData()
                }
                addChild(vc)
                pageScrollView.sv(vc.view)
                pageScrollView.layout(
                    0,
                    |-pageOffsetX-vc.view-(>=0)-|,
                    0
                )
                vc.view.width(pageScrollView.width).height(pageScrollView.height)
            } else if index == 1 {
                let vc = ChatVC()
                vc.refreshChatConversationCount = { [weak self] (conversations) in
                    self?.refreshChatUnreadCount(conversations: conversations)
                }
                addChild(vc)
                pageScrollView.sv(vc.view)
                pageScrollView.layout(
                    0,
                    |-pageOffsetX-vc.view-(>=0)-|,
                    0
                )
                vc.view.width(pageScrollView.width).height(pageScrollView.height)
            } else if index == 2 {
                let vc = SystemNotiVC()
                vc.refreshMsgCount = { [weak self] in
                    self?.loadData()
                }
                addChild(vc)
                pageScrollView.sv(vc.view)
                pageScrollView.layout(
                    0,
                    |-pageOffsetX-vc.view-(>=0)-|,
                    0
                )
                vc.view.width(pageScrollView.width).height(pageScrollView.height)
            }
            
            
        }
    }
    
    @objc func titleBtnClick(btn: UIButton) {
        switchBtn(index: btn.tag)
        let offsetX: CGFloat = CGFloat(btn.tag)*PublicSize.kScreenWidth
        pageScrollView.contentOffset = CGPoint(x: offsetX, y: 0)
    }
    
    private func switchBtn(index: Int) {
        titleBtns.forEach { (titleBtn) in
            let line = titleBtn.viewWithTag(10001)
            if titleBtn.tag == index {
                line?.isHidden = false
                titleBtn.textColor(.k2FD4A7)
            } else {
                line?.isHidden = true
                titleBtn.textColor(.kColor33)
            }
        }
       // vc.index = index
        
//        if vc.rowsData.count == 0 {
//            vc.current = 1
//            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
//                vc.loadTGData()
//            } else {
//                if index == 3 {
//                    vc.loaXPXHData()
//                } else {
//                    vc.loadData()
//                }
//            }
//        }
    }
}

extension MessageNotiVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / PublicSize.kScreenWidth)
        switchBtn(index: index)
    }
}
