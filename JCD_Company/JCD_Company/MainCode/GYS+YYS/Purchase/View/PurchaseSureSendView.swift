//
//  PurchaseSureSendView.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/16.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import TLTransitions

class PurchaseSureSendView: UIView {
    var titleLabel = UILabel().text("确认发货").textColor(.kColor33).fontBold(14)
    // 物流公司
    private var companyLabel = UILabel()
    private var companyBgView = UIView().borderColor(.kColor99).borderWidth(0.5).cornerRadius(2).masksToBounds()
    var companyTextField = UITextField().placeholder("请输入物流公司")
    // 物流单号
    private var numLabel = UILabel()
    private var numBgView = UIView().borderColor(.kColor99).borderWidth(0.5).cornerRadius(2).masksToBounds()
    var numTextField = UITextField().placeholder("请输入物流单号")
    // 备注
    private var remarkLabel = UILabel().text("备注").textColor(.kColor66).font(12)
    private var remarkBgView = UIView().borderColor(.kColor99).borderWidth(0.5).cornerRadius(2).masksToBounds()
    var remarkTextView = UITextView()
    // 取消
    private var cancelBtn = UIButton().text("取消").textColor(.kColor33).font(14).borderColor(.kColor220).borderWidth(0.5)
    // 确认
    private var sureBtn = UIButton().text("确认").textColor(.k1DC597).font(14).borderColor(.kColor220).borderWidth(0.5)
    private var pop: TLTransition?
    public var sureBtnBlock: ((String, String, String) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(.white)
        sv(titleLabel, companyLabel, companyBgView, numLabel, numBgView, remarkLabel, remarkBgView, cancelBtn, sureBtn)
        layout(
            25,
            titleLabel.height(20).centerHorizontally(),
            15,
            |-20-companyLabel.height(16.5),
            5,
            |-20-companyBgView.height(30)-20-|,
            10,
            |-20-numLabel.height(16.5),
            5,
            |-20-numBgView.height(30)-20-|,
            10,
            |-20-remarkLabel.height(16.5),
            5,
            |-20-remarkBgView.height(47)-20-|,
            14.5,
            |-0-cancelBtn.height(48.5)-0-sureBtn.height(48.5)-0-|,
            0
        )
        equal(widths: cancelBtn, sureBtn)
        configCompanyTextField()
        configNumTextField()
        configRemarkTextView()
        companyLabel.attributedText = String.attributedString(strs: ["*", "物流公司："], colors: [.kDF2F2F, .kColor66], fonts: [.systemFont(ofSize: 12), .systemFont(ofSize: 12)])
        numLabel.attributedText = String.attributedString(strs: ["*", "物流单号："], colors: [.kDF2F2F, .kColor66], fonts: [.systemFont(ofSize: 12), .systemFont(ofSize: 12)])
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(btn:)))
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        pop = TLTransition.show(self, popType: TLPopTypeAlert)
    }
    
    func configCompanyTextField() {
        companyTextField.font(12)
        companyTextField.setPlaceHolderTextColor(.kColor99)
        companyBgView.sv(companyTextField)
        companyBgView.layout(
            0,
            |-5-companyTextField-5-|,
            0
        )
    }
    
    func configNumTextField() {
        numTextField.font(12)
        numTextField.setPlaceHolderTextColor(.kColor99)
        numBgView.sv(numTextField)
        numBgView.layout(
            0,
            |-5-numTextField-5-|,
            0
        )
    }
    
    func configRemarkTextView() {
        remarkBgView.sv(remarkTextView)
        remarkBgView.layout(
            0,
            |remarkTextView|,
            0
        )
        remarkTextView.layoutIfNeeded()
        remarkTextView.placeholdFont = .systemFont(ofSize: 12)
        remarkTextView.placeHolderEx = "请在此备注告知买家如何查询物流信息"
        remarkTextView.placeholdColor = .kColor99
    }
    
    @objc private func cancelBtnClick(btn: UIButton) {
        pop?.dismiss()
    }
    
    @objc private func sureBtnClick(btn: UIButton) {
        if companyTextField.text?.isEmpty ?? false {
            noticeOnlyText("请输入物流公司")
            return
        }
        if numTextField.text?.isEmpty ?? false {
            noticeOnlyText("请输入物流单号")
            return
        }
        pop?.dismiss()
        sureBtnBlock?(companyTextField.text ?? "", numTextField.text ?? "", remarkTextView.text ?? "无")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
