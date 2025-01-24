//
//  ZBBCreditAuthBrandsApplyViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit

class ZBBCreditAuthBrandsApplyViewController: BaseViewController {

    enum ViewType {
        case new
        case edit
        case check
    }
    
    var type: ViewType = .new
    
    
    private var bottomView: UIView!
    private var applyBtn: UIButton!
    private var scrollView: UIScrollView!
    
    private var companyNameView: ZBBCreditAuthInputItemView!
    private var addressView: ZBBCreditAuthInputItemView!
    private var companyDescView: ZBBCreditAuthInputItemView!
    private var busiNoView: ZBBCreditAuthInputItemView!
    
    private var busiView: ZBBCreditAuthPhotoItemView!
    private var brandAuthView: ZBBCreditAuthPhotoItemView!
    private var creditView: ZBBCreditAuthPhotoItemView!
    
    private var invoiceView: ZBBCreditAuthSwitchItemView!
    private var bankAccountView: ZBBCreditAuthInputItemView!
    
    private var houseView: ZBBCreditAuthPhotoItemView!
    private var balanceView: ZBBCreditAuthPhotoItemView!
    private var taxView: ZBBCreditAuthPhotoItemView!
    
    private var breakView: ZBBCreditAuthSwitchItemView!
    private var passView: ZBBCreditAuthPhotoItemView!
    private var greenView: ZBBCreditAuthPhotoItemView!
    
    private var authInfo: [String : Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "材料商认证"
        createViews()
        //
        requestBrandAuthInfo {[weak self] dict in
            self?.authInfo = dict
            //公司名称
            self?.companyNameView.contentText = dict["companyName"] as? String ?? ""
            //公司地址
            self?.addressView.contentText = dict["companyAddress"] as? String ?? ""
            //企业介绍
            self?.companyDescView.contentText = dict["companyIntroduce"] as? String ?? ""
            //营业执照号
            self?.busiNoView.contentText = dict["licenseNo"] as? String ?? ""
            //营业执照
            if let url = dict["licenseUrl"] as? String, url.count > 0 {
                self?.busiView.imageURLs = [url]
            }
            //品牌授权书
            if let url = dict["brandAuthLetterUrl"] as? String, url.count > 0 {
                self?.brandAuthView.imageURLs = [url]
            }
            //资质证明
            if let url = dict["qualificationCertificateUrl"] as? String, url.count > 0 {
                self?.creditView.imageURLs = [url]
            }
            //可提供发票(0:否 1:是)
            if let num = dict["provideInvoice"] as? Int {
                self?.invoiceView.on = num == 1
            }
            //银行对公账户
            self?.bankAccountView.contentText = dict["bankCorporateAccount"] as? String ?? ""
            //房产证明/租赁合同
            if let url = dict["proveUrl"] as? String, url.count > 0 {
                self?.houseView.imageURLs = [url]
            }
            //负债资产表
            if let url = dict["balanceSheetUrl"] as? String, url.count > 0 {
                self?.balanceView.imageURLs = [url]
            }
            //库存量和俩年纳税情况
            if let url = dict["taxSituationUrl"] as? String, url.count > 0 {
                self?.taxView.imageURLs = [url]
            }
            //是否列入失信名单(0:否 1:是)
            if let num = dict["dishonest"] as? Int {
                self?.breakView.on = num == 1
            }
            //合格证
            if let url = dict["conformityCertificateUrl"] as? String, url.count > 0 {
                self?.passView.imageURLs = [url]
            }
            //绿色检测证书
            if let url = dict["greenTestCertificateUrl"] as? String, url.count > 0 {
                self?.greenView.imageURLs = [url]
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
        

        companyNameView = ZBBCreditAuthInputItemView()
        companyNameView.title = "公司名称"
        companyNameView.placeText = "请输入公司名称"
        companyNameView.isEditable = type != .check
        scrollView.addSubview(companyNameView)
        companyNameView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH)
        }

        addressView = ZBBCreditAuthInputItemView()
        addressView.title = "地址"
        addressView.placeText = "请输入公司地址"
        addressView.isEditable = type != .check
        scrollView.addSubview(addressView)
        addressView.snp.makeConstraints { make in
            make.top.equalTo(companyNameView.snp.bottom)
            make.left.right.equalTo(0)
        }

        companyDescView = ZBBCreditAuthInputItemView()
        companyDescView.title = "企业介绍"
        companyDescView.placeText = "请输入企业介绍"
        companyDescView.isEditable = type != .check
        companyDescView.maxLength = 300
        scrollView.addSubview(companyDescView)
        companyDescView.snp.makeConstraints { make in
            make.top.equalTo(addressView.snp.bottom)
            make.left.right.equalTo(0)
        }

        busiNoView = ZBBCreditAuthInputItemView()
        busiNoView.title = "营业执照号"
        busiNoView.placeText = "请输入营业执照号"
        busiNoView.isEditable = type != .check
        scrollView.addSubview(busiNoView)
        busiNoView.snp.makeConstraints { make in
            make.top.equalTo(companyDescView.snp.bottom)
            make.left.right.equalTo(0)
        }

        busiView = ZBBCreditAuthPhotoItemView()
        busiView.title = "营业执照"
        busiView.isEditable = type != .check
        scrollView.addSubview(busiView)
        busiView.snp.makeConstraints { make in
            make.top.equalTo(busiNoView.snp.bottom)
            make.left.right.equalTo(0)
        }

        brandAuthView = ZBBCreditAuthPhotoItemView()
        brandAuthView.title = "品牌授权书"
        brandAuthView.isEditable = type != .check
        scrollView.addSubview(brandAuthView)
        brandAuthView.snp.makeConstraints { make in
            make.top.equalTo(busiView.snp.bottom)
            make.left.right.equalTo(0)
        }

        creditView = ZBBCreditAuthPhotoItemView()
        creditView.title = "资质证明"
        creditView.isEditable = type != .check
        scrollView.addSubview(creditView)
        creditView.snp.makeConstraints { make in
            make.top.equalTo(brandAuthView.snp.bottom)
            make.left.right.equalTo(0)
        }

        invoiceView = ZBBCreditAuthSwitchItemView()
        invoiceView.title = "可提供发票"
        invoiceView.isEditable = type != .check
        scrollView.addSubview(invoiceView)
        invoiceView.snp.makeConstraints { make in
            make.top.equalTo(creditView.snp.bottom)
            make.left.right.equalTo(0)
        }

        bankAccountView = ZBBCreditAuthInputItemView()
        bankAccountView.title = "银行对公账\n户"
        bankAccountView.placeText = "请输入银行对公账户"
        bankAccountView.isEditable = type != .check
        bankAccountView.keyboardType = .numberPad
        scrollView.addSubview(bankAccountView)
        bankAccountView.snp.makeConstraints { make in
            make.top.equalTo(invoiceView.snp.bottom)
            make.left.right.equalTo(0)
        }

        houseView = ZBBCreditAuthPhotoItemView()
        houseView.title = "房产证明/\n租赁合同"
        houseView.isEditable = type != .check
        scrollView.addSubview(houseView)
        houseView.snp.makeConstraints { make in
            make.top.equalTo(bankAccountView.snp.bottom)
            make.left.right.equalTo(0)
        }

        balanceView = ZBBCreditAuthPhotoItemView()
        balanceView.title = "负债资产表"
        balanceView.isEditable = type != .check
        scrollView.addSubview(balanceView)
        balanceView.snp.makeConstraints { make in
            make.top.equalTo(houseView.snp.bottom)
            make.left.right.equalTo(0)
        }

        taxView = ZBBCreditAuthPhotoItemView()
        taxView.title = "库存量和两\n年纳税情况"
        taxView.isEditable = type != .check
        scrollView.addSubview(taxView)
        taxView.snp.makeConstraints { make in
            make.top.equalTo(balanceView.snp.bottom)
            make.left.right.equalTo(0)
        }

        breakView = ZBBCreditAuthSwitchItemView()
        breakView.title = "是否列入失\n信名单"
        breakView.isEditable = type != .check
        scrollView.addSubview(breakView)
        breakView.snp.makeConstraints { make in
            make.top.equalTo(taxView.snp.bottom)
            make.left.right.equalTo(0)
        }

        passView = ZBBCreditAuthPhotoItemView()
        passView.title = "合格证"
        passView.isEditable = type != .check
        scrollView.addSubview(passView)
        passView.snp.makeConstraints { make in
            make.top.equalTo(breakView.snp.bottom)
            make.left.right.equalTo(0)
        }

        greenView = ZBBCreditAuthPhotoItemView()
        greenView.title = "绿色检测证\n书"
        greenView.isEditable = type != .check
        greenView.hideSeparatorLine = true
        scrollView.addSubview(greenView)
        greenView.snp.makeConstraints { make in
            make.top.equalTo(passView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(-5)
        }
    }


    @objc private func applyBtnAction(_ sender: UIButton) {
        var param = [String : Any]()
        
        //公司名称
        param["companyName"] = companyNameView.contentText
        //公司地址
        param["companyAddress"] = addressView.contentText
        //企业介绍
        param["companyIntroduce"] = companyDescView.contentText
        //营业执照号
        param["licenseNo"] = busiNoView.contentText
        //营业执照
        param["licenseUrl"] = busiView.imageURLs.first
        //品牌授权书
        param["brandAuthLetterUrl"] = brandAuthView.imageURLs.first
        //资质证明
        param["qualificationCertificateUrl"] = creditView.imageURLs.first
        //可提供发票(0:否 1:是)
        param["provideInvoice"] = invoiceView.on ? 1 : 0
        //银行对公账户
        param["bankCorporateAccount"] = bankAccountView.contentText
        //房产证明/租赁合同
        param["proveUrl"] = houseView.imageURLs.first
        //负债资产表
        param["balanceSheetUrl"] = balanceView.imageURLs.first
        //库存量和俩年纳税情况
        param["taxSituationUrl"] = taxView.imageURLs.first
        //是否列入失信名单(0:否 1:是)
        param["dishonest"] = breakView.on ? 1 : 0
        //合格证
        param["conformityCertificateUrl"] = passView.imageURLs.first
        //绿色检测证书
        param["greenTestCertificateUrl"] = greenView.imageURLs.first
        
        if type == .new {
            requestApplyAuth(param) {[weak self] in
                let vc = ZBBCreditAuthApplyResultViewController(authType: .brands, result: .wait)
                self?.navigationController?.pushViewController(vc, animated: true)
                //
                if var vcs = self?.navigationController?.viewControllers {
                    vcs.removeAll { $0 == self || $0.isKind(of: ZBBCreditAuthBrandsViewController.self)}
                    self?.navigationController?.viewControllers = vcs
                }
            }
        } else if type == .edit {
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

extension ZBBCreditAuthBrandsApplyViewController {
    
    private func requestBrandAuthInfo(complete: (([String : Any]) -> Void)?) {
        if let userId = UserData1.shared.tokenModel?.userId {
            YZBSign.shared.request(APIURL.zbbApplyBrandInfo, method: .get, parameters: ["userId" : userId]) {[weak self] response in
                let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
                if code == 0 {
                    let dict = Utils.getReqDir(data: response as AnyObject) as! [String : Any]
                    complete?(dict)
                } else {
                    let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self?.noticeOnlyText(msg)
                }
            } failure: { error in
                
            }
        }
    }
    
    private func requestApplyAuth(_ param: [String: Any], success: (() -> Void)?) {
        YZBSign.shared.request(APIURL.zbbApplyBrand, method: .post, parameters: param) {[weak self] response in
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
        YZBSign.shared.request(APIURL.zbbApplyBrandEdit, method: .put, parameters: param) {[weak self] response in
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
