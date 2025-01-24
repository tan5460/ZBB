//
//  ZBBCreditAuthServiceApplyViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit

class ZBBCreditAuthServiceApplyViewController: BaseViewController {
    
    enum ViewType {
        case new
        case edit
        case check
    }
    
    var type: ViewType = .new
    private var id: String?
    
    private var bottomView: UIView!
    private var applyBtn: UIButton!
    private var scrollView: UIScrollView!
    
    private var identityTypeView: ZBBCreditAuthSelectItemView!
    private var companyNameView: ZBBCreditAuthInputItemView!
    private var workTypeView: ZBBCreditAuthSelectItemView!
    private var nameView: ZBBCreditAuthInputItemView!
    private var phoneView: ZBBCreditAuthInputItemView!
    private var IDCardFrontView: ZBBCreditAuthPhotoItemView!
    private var IDCardBackView: ZBBCreditAuthPhotoItemView!
    private var workTimeView: ZBBCreditAuthInputItemView!
    private var honorView: ZBBCreditAuthPhotoItemView!
    
    private var identityType = 0 {
        didSet {
            companyNameView.isHidden = identityType != 1
            workTypeView.isHidden = identityType != 4
            
            nameView.snp.remakeConstraints { make in
                if !companyNameView.isHidden {
                    make.top.equalTo(companyNameView.snp.bottom)
                } else if !workTypeView.isHidden {
                    make.top.equalTo(workTypeView.snp.bottom)
                } else {
                    make.top.equalTo(identityTypeView.snp.bottom)
                }
                make.left.right.equalTo(0)
            }
        }
    }
    
    private var workType = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "服务商认证"
        createViews()
        //
        requestServiceAuthInfo {[weak self] dict in
            self?.id = dict["id"] as? String
            //身份
            if let identityType = dict["identityType"] as? String {
                self?.identityType = Int(identityType) ?? 0
                if let index = self?.identityType, index > 0 {
                    self?.identityTypeView.contentText = ["装修公司", "项目经理", "经纪人", "工匠", "设计师"][index - 1]
                }
            }

            //公司名称
            self?.companyNameView.contentText = dict["companyName"] as? String ?? ""
            
            //工种
            if let workType = dict["workType"] as? String {
                self?.workType = Int(workType) ?? 0
                if let index = self?.workType, index > 0 {
                    self?.workTypeView.contentText = ["水电工", "泥工", "木工", "油漆工", "安装工"][index - 1]
                }
            }
            
            //姓名
            self?.nameView.contentText = dict["fullName"] as? String ?? ""
            //手机号
            if let phoneNumber = dict["phoneNumber"] as? String, phoneNumber.count > 0 {
                self?.phoneView.contentText = phoneNumber
                self?.phoneView.isEditable = false
            } else {
                if let mobile = UserData.shared.workerModel?.mobile, mobile.count > 0 {
                    self?.phoneView.contentText = mobile
                    self?.phoneView.isEditable = false
                } else {
                    self?.phoneView.isEditable = true
                }
            }
            //身份证人面像
            if let url = dict["idCardF"] as? String, url.count > 0 {
                self?.IDCardFrontView.imageURLs = [url]
            }
            //身份证国徽像
            if let url = dict["idCardB"] as? String, url.count > 0 {
                self?.IDCardBackView.imageURLs = [url]
            }
            //从业年限
            self?.workTimeView.contentText = dict["workYears"] as? String ?? ""
            //资格证书
            if let url = dict["qualificationCertificateUrl"] as? String, url.count > 0 {
                self?.honorView.imageURLs = [url]
            }
        }
    }
    
    private func createViews() {
        bottomView = UIView()
        bottomView.isHidden = type == .check
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
            if type == .check {
                make.bottom.equalTo(0)
            } else {
                make.bottom.equalTo(bottomView.snp.top)
            }
        }

        
        identityTypeView = ZBBCreditAuthSelectItemView()
        identityTypeView.isRequried = true
        identityTypeView.title = "身份"
        identityTypeView.placeText = "请选择"
        identityTypeView.isEditable = type != .check
        identityTypeView.selectedClosure = {
            let titles = ["装修公司", "项目经理", "经纪人", "工匠", "设计师"]
            ZBBSelectPopView.show(titles: titles) {[weak self] index in
                self?.identityTypeView.contentText = titles[index]
                self?.identityType = index + 1
            }
        }
        scrollView.addSubview(identityTypeView)
        identityTypeView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH)
        }

        companyNameView = ZBBCreditAuthInputItemView()
        companyNameView.isHidden = true
        companyNameView.isRequried = true
        companyNameView.title = "公司名称"
        companyNameView.placeText = "请输入公司名称"
        companyNameView.isEditable = type != .check
        scrollView.addSubview(companyNameView)
        companyNameView.snp.makeConstraints { make in
            make.top.equalTo(identityTypeView.snp.bottom)
            make.left.right.equalTo(0)
        }

        workTypeView = ZBBCreditAuthSelectItemView()
        workTypeView.isHidden = true
        workTypeView.isRequried = true
        workTypeView.title = "工种"
        workTypeView.placeText = "请选择"
        workTypeView.isEditable = type != .check
        workTypeView.selectedClosure = {
            let titles = ["水电工", "泥工", "木工", "油漆工", "安装工"]
            ZBBSelectPopView.show(titles: titles) {[weak self] index in
                self?.workTypeView.contentText = titles[index]
                self?.workType = index + 1
            }
        }
        scrollView.addSubview(workTypeView)
        workTypeView.snp.makeConstraints { make in
            make.top.equalTo(identityTypeView.snp.bottom)
            make.left.right.equalTo(0)
        }

        nameView = ZBBCreditAuthInputItemView()
        nameView.isRequried = true
        nameView.title = "姓名"
        nameView.placeText = "请输入姓名"
        nameView.isEditable = type != .check
        scrollView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.equalTo(identityTypeView.snp.bottom)
            make.left.right.equalTo(0)
        }

        phoneView = ZBBCreditAuthInputItemView()
        phoneView.isRequried = true
        phoneView.title = "手机号"
        phoneView.placeText = "请输入手机号"
        phoneView.isEditable = type != .check
        phoneView.keyboardType = .numberPad
        phoneView.maxLength = 11
        scrollView.addSubview(phoneView)
        phoneView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom)
            make.left.right.equalTo(0)
        }

        IDCardFrontView = ZBBCreditAuthPhotoItemView()
        IDCardFrontView.isRequried = true
        IDCardFrontView.title = "身份证人\n像面"
        IDCardFrontView.isEditable = type != .check
        scrollView.addSubview(IDCardFrontView)
        IDCardFrontView.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom)
            make.left.right.equalTo(0)
        }

        IDCardBackView = ZBBCreditAuthPhotoItemView()
        IDCardBackView.isRequried = true
        IDCardBackView.title = "身份证国\n徽面"
        IDCardBackView.isEditable = type != .check
        scrollView.addSubview(IDCardBackView)
        IDCardBackView.snp.makeConstraints { make in
            make.top.equalTo(IDCardFrontView.snp.bottom)
            make.left.right.equalTo(0)
        }

        workTimeView = ZBBCreditAuthInputItemView()
        workTimeView.title = "从业年限"
        workTimeView.placeText = "请输入从业年限"
        workTimeView.isEditable = type != .check
        scrollView.addSubview(workTimeView)
        workTimeView.snp.makeConstraints { make in
            make.top.equalTo(IDCardBackView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        honorView = ZBBCreditAuthPhotoItemView()
        honorView.title = "资格证书/\n荣誉证书"
        honorView.hideSeparatorLine = true
        honorView.isEditable = type != .check
        scrollView.addSubview(honorView)
        honorView.snp.makeConstraints { make in
            make.top.equalTo(workTimeView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(-5)
        }
    }

    @objc private func applyBtnAction(_ sender: UIButton) {
        var param = [String : Any]()
        
        //身份
        if self.identityType <= 0 {
            noticeOnlyText("请选择身份类型")
            return
        }
        param["identityType"] = identityType
        
        //公司名称
        if !companyNameView.isHidden {
            param["companyName"] = companyNameView.contentText
        }
        
        //工种
        if !workTypeView.isHidden {
            if self.workType <= 0 {
                noticeOnlyText("请选择工种")
                return
            }
            param["workType"] = workType
        }
        
        
        //姓名
        param["fullName"] = nameView.contentText
        //手机号
        param["phoneNumber"] = phoneView.contentText
        //身份证人面像
        param["idCardF"] = IDCardFrontView.imageURLs.first
        //身份证国徽像
        param["idCardB"] = IDCardBackView.imageURLs.first
        //从业年限
        param["workYears"] = workTimeView.contentText
        //资格证书
        param["qualificationCertificateUrl"] = honorView.imageURLs.first

        
        if type == .new {
            requestApplyAuth(param) {[weak self] in
                let vc = ZBBCreditAuthApplyResultViewController(authType: .service, result: .wait)
                self?.navigationController?.pushViewController(vc, animated: true)
                //
                if var vcs = self?.navigationController?.viewControllers {
                    vcs.removeAll { $0 == self || $0.isKind(of: ZBBCreditAuthServiceViewController.self)}
                    self?.navigationController?.viewControllers = vcs
                }
            }
        } else if type == .edit {
            param["id"] = id
            requestEditAuth(param) {[weak self] in
                if var vcs = self?.navigationController?.viewControllers {
                    vcs.removeAll { vc in
                        vc.isKind(of: ZBBCreditAuthApplyResultViewController.self)
                    }
                    self?.navigationController?.viewControllers = vcs
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
    }
}


extension ZBBCreditAuthServiceApplyViewController {
    
    private func requestServiceAuthInfo(complete: (([String : Any]) -> Void)?) {
        if let userId = UserData1.shared.tokenModel?.userId {
            YZBSign.shared.request(APIURL.zbbServiceAuthInfo + userId, method: .get) {[weak self] response in
                let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
                if code == 0 {
                    let dict = Utils.getReqDir(data: response as AnyObject) as! [String : Any]
                    complete?(dict)
                } else {
                    let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self?.noticeOnlyText(msg)
                    complete?([String : Any]())
                }
            } failure: { error in
                complete?([String : Any]())
            }
        }
    }
    
    private func requestApplyAuth(_ param: [String: Any], success: (() -> Void)?) {
        YZBSign.shared.request(APIURL.zbbServiceAuthApply, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                success?()
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }
    }
    
    private func requestEditAuth(_ param: [String: Any], success: (() -> Void)?) {
        YZBSign.shared.request(APIURL.zbbServiceAuthEdit, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                success?()
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }
    }
    
}
