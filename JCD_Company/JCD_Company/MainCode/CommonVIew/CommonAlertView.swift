//
//  CommonAlertView.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import TLTransitions

class CommonAlertView: UIView {
    private var pop: TLTransition?
    private let titleLabel = UILabel().text("重新下单").textColor(.kColor33).fontBold(14)
    private let desLabel = UILabel().text("重新下单，自动将当前订单的产品加入到购物车，请问是否重新下单？").textColor(.kColor33).font(14)
    private let cancelBtn = UIButton().text("取消").textColor(.kColor33).font(14).borderColor(.kColor220).borderWidth(0.5)
    private let sureBtn = UIButton().text("确认").textColor(.k1DC597).font(14).borderColor(.kColor220).borderWidth(0.5)
    typealias SureBtnBlock = (() -> Void)
    var sureBtnBlock: SureBtnBlock?
    override init(frame: CGRect) {
        super.init(frame: frame)
        desLabel.numberOfLines(0).lineSpace(2)
        sv(titleLabel, desLabel, cancelBtn, sureBtn)
        layout(
            25,
            titleLabel.height(20).centerHorizontally(),
            15,
            |-20-desLabel-20-|,
            >=0,
            |cancelBtn.height(48.5)-0-sureBtn|,
            0
        )
        equal(sizes: cancelBtn, sureBtn)
        pop = TLTransition.show(self, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
        cancelBtn.tapped { [weak self] (btn) in
            self?.pop?.dismiss()
        }
        sureBtn.tapped { [weak self] (btn) in
            self?.pop?.dismiss()
            self?.sureBtnBlock?()
        }
    }
    
    func configPopView(title: String?, message: String?, action: SureBtnBlock?) {
        titleLabel.text(title ?? "")
        desLabel.text(message ?? "")
        sureBtnBlock = action
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
