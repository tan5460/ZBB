//
//  ShareSelectView.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/14.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import TLTransitions

enum ShareSelectStyle {
    case friend // 微信好友
    case circle // 微信朋友圈
    case qq // qq好友
    case qz // qq空间
    case sina
}

class ShareSelectView: UIView {
    var shareSelectStyleBlock: ((ShareSelectStyle) -> Void)?
    var cancelBtnBlock: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let friendBtn = UIButton().image(#imageLiteral(resourceName: "share_friend")).text("微信好友").textColor(.kColor33).font(13)
        let circleBtn = UIButton().image(#imageLiteral(resourceName: "share_circle")).text("朋友圈").textColor(.kColor33).font(13)
        let sinaBtn = UIButton().image(#imageLiteral(resourceName: "share_wb")).text("微博").textColor(.kColor33).font(13)
        let cancelBtn = UIButton().text("取消").textColor(.kColor66).font(16)
        sv(friendBtn, circleBtn, sinaBtn, cancelBtn)
        [friendBtn, circleBtn, sinaBtn].forEach { (btn) in
            btn.backgroundColor(.white)
        }
        layout(
            0,
            |-0-friendBtn.height(132)-0-circleBtn-0-sinaBtn-0-|,
            0,
            |cancelBtn.height(44)|,
            0
        )
        friendBtn.layoutButton(imageTitleSpace: 10)
        circleBtn.layoutButton(imageTitleSpace: 10)
        sinaBtn.layoutButton(imageTitleSpace: 10)
        equal(sizes: friendBtn, circleBtn, sinaBtn)
        friendBtn.addTarget(self, action: #selector(friendBtnClick(btn:)))
        circleBtn.addTarget(self, action: #selector(circleBtnClick(btn:)))
        sinaBtn.addTarget(self, action: #selector(sinaBtnClick(btn:)))
        cancelBtn.tapped { [weak self] (btn) in
            self?.cancelBtnBlock?()
        }
    }
    
    @objc private func friendBtnClick(btn: UIButton) {
        shareSelectStyleBlock?(.friend)
    }
    
    @objc private func circleBtnClick(btn: UIButton) {
        shareSelectStyleBlock?(.circle)
    }
    
    @objc private func qqBtnClick(btn: UIButton) {
        shareSelectStyleBlock?(.qq)
    }
    
    @objc private func qzBtnClick(btn: UIButton) {
        shareSelectStyleBlock?(.qz)
    }
    
    @objc private func sinaBtnClick(btn: UIButton) {
        shareSelectStyleBlock?(.sina)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
