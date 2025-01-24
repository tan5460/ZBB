//
//  ZBBDecorationSubsidyApplyViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/7.
//

import UIKit

class ZBBDecorationSubsidyApplyViewController: BaseViewController {
    
    var id: String?

    private var bottomView: UIView!
    private var applyBtn: UIButton!
    private var scrollView: UIScrollView!
    
    private var nameView: ZBBCreditAuthInputItemView!
    private var IDCardView: ZBBCreditAuthInputItemView!
    private var phoneView: ZBBCreditAuthInputItemView!
    private var houseView: ZBBCreditAuthInputItemView!
    
    private var areaView: ZBBCreditAuthPhotoItemView!
    private var unitView: ZBBCreditAuthPhotoItemView!
    private var homeView: ZBBCreditAuthPhotoItemView!
    private var invoiceView: ZBBCreditAuthPhotoItemView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "申领补贴"
        createViews()
        //
        requestSubsidyOrderInfo {[weak self] name, idNum, phone in
            self?.nameView.contentText = name ?? ""
            self?.IDCardView.contentText = idNum ?? ""
            self?.phoneView.contentText = phone ?? ""
        }
    }
    
    private func createViews() {
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(54+PublicSize.kBottomOffset)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = .hexColor("#EFEFEF")
        bottomView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        applyBtn = UIButton(type: .custom)
        applyBtn.layer.cornerRadius = 22
        applyBtn.layer.masksToBounds = true
        applyBtn.backgroundColor = .hexColor("#007E41")
        applyBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        applyBtn.setTitle("提交", for: .normal)
        applyBtn.setTitleColor(.white, for: .normal)
        applyBtn.addTarget(self, action: #selector(applyBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(applyBtn)
        applyBtn.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        
        nameView = ZBBCreditAuthInputItemView()
        nameView.title = "姓名"
        nameView.placeText = "请输入姓名"
        scrollView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        IDCardView = ZBBCreditAuthInputItemView()
        IDCardView.title = "身份证"
        IDCardView.placeText = "请输入身份证号码"
        scrollView.addSubview(IDCardView)
        IDCardView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom)
            make.left.right.equalTo(0)
        }

        phoneView = ZBBCreditAuthInputItemView()
        phoneView.title = "联系电话"
        phoneView.placeText = "请输入联系电话"
        phoneView.keyboardType = .numberPad
        scrollView.addSubview(phoneView)
        phoneView.snp.makeConstraints { make in
            make.top.equalTo(IDCardView.snp.bottom)
            make.left.right.equalTo(0)
        }

        houseView = ZBBCreditAuthInputItemView()
        houseView.title = "房屋地址"
        houseView.placeText = "请输入房屋地址"
        scrollView.addSubview(houseView)
        houseView.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        areaView = ZBBCreditAuthPhotoItemView()
        areaView.maxCount = 9
        areaView.title = "小区照片"
        scrollView.addSubview(areaView)
        areaView.snp.makeConstraints { make in
            make.top.equalTo(houseView.snp.bottom)
            make.left.right.equalTo(0)
        }

        unitView = ZBBCreditAuthPhotoItemView()
        unitView.maxCount = 9
        unitView.title = "单元照片"
        scrollView.addSubview(unitView)
        unitView.snp.makeConstraints { make in
            make.top.equalTo(areaView.snp.bottom)
            make.left.right.equalTo(0)
        }

        homeView = ZBBCreditAuthPhotoItemView()
        homeView.maxCount = 9
        homeView.title = "室内照片"
        scrollView.addSubview(homeView)
        homeView.snp.makeConstraints { make in
            make.top.equalTo(unitView.snp.bottom)
            make.left.right.equalTo(0)
        }
 
        invoiceView = ZBBCreditAuthPhotoItemView()
        invoiceView.title = "订单发票"
        invoiceView.hideSeparatorLine = true
        scrollView.addSubview(invoiceView)
        invoiceView.snp.makeConstraints { make in
            make.top.equalTo(homeView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(-5)
        }
    }
    
    @objc private func applyBtnAction(_ sender: UIButton) {
        var param = Parameters()
        param["id"] = id
        
        //
        if nameView.contentText.isEmpty {
            noticeOnlyText("请输入姓名")
            return
        }
        param["name"] = nameView.contentText
        
        //
        if IDCardView.contentText.isEmpty {
            noticeOnlyText("请输入身份证")
            return
        }
        param["idCard"] = IDCardView.contentText
        
        //
        if phoneView.contentText.isEmpty {
            noticeOnlyText("请输入身份证")
            return
        }
        param["mobile"] = phoneView.contentText
        
        //
        if houseView.contentText.isEmpty {
            noticeOnlyText("请输入房屋地址")
            return
        }
        param["address"] = houseView.contentText
        
        //
        if areaView.imageURLs.isEmpty {
            noticeOnlyText("请上传小区照片")
            return
        }
        param["areaUrl"] = areaView.imageURLs.joined(separator: ",")
        
        //
        if unitView.imageURLs.isEmpty {
            noticeOnlyText("请上传单元照片")
            return
        }
        param["unitUrl"] = unitView.imageURLs.joined(separator: ",")
        
        //
        if homeView.imageURLs.isEmpty {
            noticeOnlyText("请上传室内照片")
            return
        }
        param["indoorUrl"] = homeView.imageURLs.joined(separator: ",")
        
        //
        if invoiceView.imageURLs.isEmpty {
            noticeOnlyText("请上传订单发票")
            return
        }
        param["invoiceUrl"] = invoiceView.imageURLs.joined(separator: ",")
        //
        YZBSign.shared.request(APIURL.zbbSubsidyOrderApply, method: .put, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                self?.noticeOnlyText("提交成功")
                self?.navigationController?.popViewController(animated: true)
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }
    }
    
    private func requestSubsidyOrderInfo(complete: ((_ name: String?, _ idNum: String?, _ phone: String?) -> Void)?) {
        var param = Parameters()
        param["id"] = id
        YZBSign.shared.request(APIURL.zbbSubsidyOrderInfo, method: .get, parameters: param) { response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let name = data["name"] as? String
                let idNum = data["idCard"] as? String
                let phone = data["mobile"] as? String
                complete?(name, idNum, phone)
            }
        } failure: { error in
            
        }
    }
    
}
