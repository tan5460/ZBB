//
//  CancelOrderReasonView.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

class CancelOrderReasonView: UIView {
    private var btns: [UIButton] = []
    var cancelBtnBlock: (() -> Void)?
    var sureBtnBlock: ((String) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let titleLabel = UILabel().text("取消订单").textColor(.kColor33).fontBold(14)
        let messageLabel = UILabel().text("请选择取消订单的原因（必选）：").textColor(.kColor33).font(14)
        let cancelBtn = UIButton().text("关闭").textColor(.kColor33).font(14).borderColor(.kColor220).borderWidth(0.5)
        let sureBtn = UIButton().text("确定").textColor(.k1DC597).font(14).borderColor(.kColor220).borderWidth(0.5)
        let reasons = ["商品无货", "配送时间问题", "不想要了", "商品信息填写错误", "地址信息填写错误", "商品降价", "商品错选/多选", "重新下单", "其他"]
        sv(titleLabel, messageLabel, cancelBtn, sureBtn)
        layout(
            25,
            titleLabel.height(20).centerHorizontally(),
            15,
            messageLabel.height(20).centerHorizontally(),
            >=0,
            |cancelBtn.height(48.5)-0-sureBtn|,
            0
        )
        equal(sizes: cancelBtn, sureBtn)
        
        reasons.enumerated().forEach { (item) in
            let index = item.offset
            let reason = item.element
            let btn = UIButton()
            btn.setImage(#imageLiteral(resourceName: "login_check"), for: .selected)
            btn.setImage(#imageLiteral(resourceName: "login_uncheck"), for: .normal)
            let label = UILabel().text(reason).textColor(.kColor33).font(14)
            let offsetY: CGFloat = CGFloat(85 + 30*index)
            sv(btn, label)
            layout(
                offsetY,
                |-19-btn.size(30)-0-label,
                >=0
            )
            btn.tag = index
            btns.append(btn)
            btn.tapped { [weak self] (button) in
                self?.btns.forEach({ (itemBtn) in
                    if itemBtn.tag == button.tag {
                        itemBtn.isSelected = true
                    } else {
                        itemBtn.isSelected = false
                    }
                })
            }
        }
        
        cancelBtn.tapped { [weak self] (btn) in
            self?.cancelBtnBlock?()
        }
        
        sureBtn.tapped { [weak self] (btn) in
            var currentIndex = -1
            self?.btns.forEach { (itemBtn) in
                if itemBtn.isSelected {
                    currentIndex = itemBtn.tag
                }
            }
            if currentIndex < 0 {
                self?.noticeOnlyText("请选择取消订单原因")
            } else {
                self?.sureBtnBlock?(reasons[currentIndex])
            }
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
