//
//  GXGroupInviteDetailVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/10/28.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
 
class GXGroupInviteDetailVC: UIBaseWebViewController {
    var id: String?
    var isMe = false
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "团购邀请"
        let membersBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 44)).text("查看成员").textColor(.kColor33).font(14)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: membersBtn)
        membersBtn.tapped { [weak self] (btn) in
            let vc = GXTGMembersVC()
            vc.id = self?.id
            self?.navigationController?.pushViewController(vc)
        }
        if UserData.shared.userType == .gys {
            membersBtn.isHidden = false
        } else {
            membersBtn.isHidden = !isMe
        }
    }
}
