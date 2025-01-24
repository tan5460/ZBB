//
//  ShareInviateVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/15.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

class ShareInviateVC: BaseViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "邀请好友"
        statusStyle = .lightContent
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
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        
        
        let backBtn = UIButton().image(#imageLiteral(resourceName: "scanCode_back"))
        view.sv(backBtn)
        view.layout(
            PublicSize.kBottomOffset,
            |-0-backBtn.size(44),
            >=0
        )
        backBtn.tapped { [weak self] (btn) in
            self?.navigationController?.popViewController()
        }
    }

}

extension ShareInviateVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let inviteBg = UIImageView().image(#imageLiteral(resourceName: "share_bg_1"))
        cell.sv(inviteBg)
        cell.layout(
            0,
            |inviteBg|,
            0
        )
        inviteBg.height(1255)
        
        let inviteBtn = UIButton().image(#imageLiteral(resourceName: "share_sure_1"))
        let memberIV = UIImageView().image(#imageLiteral(resourceName: "share_member"))
        let groupIV = UIImageView().image(#imageLiteral(resourceName: "share_group"))
        let shareBtn = UIButton().image(#imageLiteral(resourceName: "share_sure_2"))
        inviteBg.sv(inviteBtn, memberIV, groupIV, shareBtn)
        inviteBtn.layout(
            407,
            inviteBtn.width(210).height(57).centerHorizontally(),
            91.5,
            memberIV.width(333).height(336.5).centerHorizontally(),
            38.5,
            groupIV.width(333).height(143).centerHorizontally(),
            44,
            shareBtn.width(343).height(58).centerHorizontally(),
            >=0
        )
        
        let groupInfoBg = UIView().backgroundColor(UIColor.hexColor("#FFE9EC")).cornerRadius(15).masksToBounds()
        let avatar = UIImageView().image(#imageLiteral(resourceName: "sjs_avatar_default")).cornerRadius(15).masksToBounds()
        let infoLabel = UILabel().text("惠州****装饰  成功邀请1名好友").textColor(.kColor33).font(11)
        let timeLabel = UILabel().text("6分钟前").textColor(UIColor.hexColor("#EE697B")).font(10)
        groupIV.sv(groupInfoBg)
        groupIV.layout(
            72.5,
            groupInfoBg.width(274).height(30).centerHorizontally(),
            >=0
        )
        groupInfoBg.sv(avatar, infoLabel, timeLabel)
        groupInfoBg.layout(
            0,
            |avatar.size(30)-10-infoLabel-(>=10)-timeLabel-14.5-|,
            0
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
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
}

