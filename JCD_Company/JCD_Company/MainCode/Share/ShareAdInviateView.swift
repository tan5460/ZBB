//
//  ShareAdInviateView.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/15.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

class ShareAdInviateView: UIView {
    var cancelBtnAction: (() -> Void)?
    var sureBtnAction: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let adIcon = UIImageView().image(#imageLiteral(resourceName: "share_ad"))
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "share_close"))
        let sureBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "share_sure")).text("立即邀请").textColor(UIColor.hexColor("#E02634")).font(21)
        sv(adIcon)
        adIcon.isUserInteractionEnabled = true
        adIcon.width(301.5).height(330).centerInContainer()
        adIcon.sv(closeBtn, sureBtn)
        adIcon.layout(
            9,
            |-28-closeBtn.size(30),
            >=0,
            sureBtn.width(206).height(43.5).centerHorizontally(),
            26
        )
        closeBtn.tapped { [weak self] (btn) in
            self?.cancelBtnAction?()
        }
        sureBtn.tapped { [weak self] (btn) in
            self?.sureBtnAction?()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
