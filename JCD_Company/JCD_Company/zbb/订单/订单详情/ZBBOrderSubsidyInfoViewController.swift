//
//  ZBBOrderSubsidyInfoViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/15.
//

import UIKit

class ZBBOrderSubsidyInfoViewController: BaseViewController {

    private var scrollView: UIScrollView!
    
    private var statusView: ZBBCreditAuthInputItemView!
    private var priceView: ZBBCreditAuthInputItemView!
    private var nameView: ZBBCreditAuthInputItemView!
    private var idCardView: ZBBCreditAuthInputItemView!
    private var phoneView: ZBBCreditAuthInputItemView!
    private var addressView: ZBBCreditAuthInputItemView!
    
    private var areaView: ZBBCreditAuthPhotoItemView!
    private var unitView: ZBBCreditAuthPhotoItemView!
    private var houseView: ZBBCreditAuthPhotoItemView!
    
    private var invoiceView: ZBBCreditAuthInputItemView!
    private var invoiceDownBtn: UIButton!
    private var invoiceShareBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "补贴详情"
        createView()
    }
    
    private func createView() {
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        statusView = ZBBCreditAuthInputItemView()
        statusView.title = "补贴状态"
        statusView.isEditable = false
        scrollView.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        priceView = ZBBCreditAuthInputItemView()
        priceView.title = "补贴金额"
        priceView.isEditable = false
        scrollView.addSubview(priceView)
        priceView.snp.makeConstraints { make in
            make.top.equalTo(statusView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        nameView = ZBBCreditAuthInputItemView()
        nameView.title = "姓名"
        nameView.isEditable = false
        scrollView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.equalTo(priceView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        idCardView = ZBBCreditAuthInputItemView()
        idCardView.title = "身份证"
        idCardView.isEditable = false
        scrollView.addSubview(idCardView)
        idCardView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        phoneView = ZBBCreditAuthInputItemView()
        phoneView.title = "联系电话"
        phoneView.isEditable = false
        scrollView.addSubview(phoneView)
        phoneView.snp.makeConstraints { make in
            make.top.equalTo(idCardView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        addressView = ZBBCreditAuthInputItemView()
        addressView.title = "房屋地址"
        addressView.isEditable = false
        scrollView.addSubview(addressView)
        addressView.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        areaView = ZBBCreditAuthPhotoItemView()
        areaView.title = "小区照片"
        areaView.isEditable = false
        scrollView.addSubview(areaView)
        areaView.snp.makeConstraints { make in
            make.top.equalTo(addressView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        unitView = ZBBCreditAuthPhotoItemView()
        unitView.title = "单元照片"
        unitView.isEditable = false
        scrollView.addSubview(unitView)
        unitView.snp.makeConstraints { make in
            make.top.equalTo(areaView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        houseView = ZBBCreditAuthPhotoItemView()
        houseView.title = "室内照片"
        houseView.isEditable = false
        scrollView.addSubview(houseView)
        houseView.snp.makeConstraints { make in
            make.top.equalTo(unitView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        invoiceView = ZBBCreditAuthInputItemView()
        invoiceView.title = "订单发票"
        invoiceView.isEditable = false
        invoiceView.hideSeparatorLine = true
        scrollView.addSubview(invoiceView)
        invoiceView.snp.makeConstraints { make in
            make.top.equalTo(houseView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(-5)
        }
        
        invoiceDownBtn = UIButton(type: .custom)
        invoiceDownBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        invoiceDownBtn.setTitle("下载", for: .normal)
        invoiceDownBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        invoiceDownBtn.addTarget(self, action: #selector(invoiceDownBtnAction(_:)), for: .touchUpInside)
        invoiceView.addSubview(invoiceDownBtn)
        invoiceDownBtn.snp.makeConstraints { make in
            make.right.equalTo(-58)
            make.top.bottom.equalTo(0)
            make.centerY.equalToSuperview()
        }
        
        invoiceShareBtn = UIButton(type: .custom)
        invoiceShareBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        invoiceShareBtn.setTitle("下载", for: .normal)
        invoiceShareBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        invoiceShareBtn.addTarget(self, action: #selector(invoiceShareBtnAction(_:)), for: .touchUpInside)
        invoiceView.addSubview(invoiceShareBtn)
        invoiceShareBtn.snp.makeConstraints { make in
            make.right.equalTo(0)
            make.top.bottom.equalTo(0)
            make.centerY.equalToSuperview()
        }
    }

    //MARK: - Action
    
    @objc private func invoiceDownBtnAction(_ sender: UIButton) {
        
    }
    
    @objc private func invoiceShareBtnAction(_ sender: UIButton) {
        
    }

}
