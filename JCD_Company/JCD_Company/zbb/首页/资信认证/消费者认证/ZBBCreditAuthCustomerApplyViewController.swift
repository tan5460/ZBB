//
//  ZBBCreditAuthCustomerApplyViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit

class ZBBCreditAuthCustomerApplyViewController: BaseViewController {
    
    enum ViewType {
        case new
        case edit
        case check
    }
    
    var type: ViewType = .new
    
    private var bottomView: UIView!
    private var applyBtn: UIButton!
    private var scrollView: UIScrollView!
    private var nameView: ZBBCreditAuthInputItemView!
    private var phoneView: ZBBCreditAuthInputItemView!
    private var IDCardView: ZBBCreditAuthInputItemView!
    private var addressView: ZBBCreditAuthInputItemView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "消费者认证"
        createViews()
        //
        requestCustomerAuthInfo {[weak self] dict in
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
            //身份证
            self?.IDCardView.contentText = dict["idCardNumber"] as? String ?? ""
            //房屋地址
            self?.addressView.contentText = dict["houseAddress"] as? String ?? ""
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

        nameView = ZBBCreditAuthInputItemView()
        nameView.isRequried = true
        nameView.title = "姓名"
        nameView.placeText = "请输入姓名"
        nameView.isEditable = type != .check
        scrollView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH)
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

        IDCardView = ZBBCreditAuthInputItemView()
        IDCardView.isRequried = true
        IDCardView.title = "身份证"
        IDCardView.placeText = "请输入身份证号"
        IDCardView.isEditable = type != .check
        IDCardView.keyboardType = .asciiCapable
        scrollView.addSubview(IDCardView)
        IDCardView.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom)
            make.left.right.equalTo(0)
        }

        addressView = ZBBCreditAuthInputItemView()
        addressView.isRequried = true
        addressView.title = "房屋地址"
        addressView.placeText = "请输入房屋地址"
        addressView.isEditable = type != .check
        addressView.hideSeparatorLine = true
        scrollView.addSubview(addressView)
        addressView.snp.makeConstraints { make in
            make.top.equalTo(IDCardView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
    }
    
    @objc private func applyBtnAction(_ sender: UIButton) {
        var param = [String : Any]()
        //姓名
        param["fullName"] = nameView.contentText
        //手机号
        param["phoneNumber"] = phoneView.contentText
        //身份证
        param["idCardNumber"] = IDCardView.contentText
        //房屋地址
        param["houseAddress"] = addressView.contentText

        if type == .new {
            requestApplyAuth(param) {[weak self] in
                let vc = ZBBCreditAuthApplyResultViewController(authType: .customer, result: .wait)
                self?.navigationController?.pushViewController(vc, animated: true)
                if var vcs = self?.navigationController?.viewControllers {
                    vcs.removeAll { $0 == self }
                    self?.navigationController?.viewControllers = vcs
                }
            }
        } else if type == .edit {
            param["id"] = UserData1.shared.tokenModel?.userId
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

extension ZBBCreditAuthCustomerApplyViewController {
    
    private func requestCustomerAuthInfo(complete: (([String : Any]) -> Void)?) {
        if let userId = UserData1.shared.tokenModel?.userId {
            YZBSign.shared.request(APIURL.zbbCustomerAuthInfo + userId, method: .get) {[weak self] response in
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
        YZBSign.shared.request(APIURL.zbbCustomerAuthApply, method: .post, parameters: param) {[weak self] response in
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
        YZBSign.shared.request(APIURL.zbbCustomerAuthEdit, method: .post, parameters: param) {[weak self] response in
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
