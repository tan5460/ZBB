//
//  ZBBCreditAuthViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/31.
//

import UIKit

class ZBBCreditAuthViewController: BaseViewController {
    
    private var titleLabel: UILabel!
    private var button_1: UIButton!
    private var button_2: UIButton!
    private var button_3: UIButton!
    private var button_4: UIButton!
    
    ///0.待审核 1.审核通过 2.审核拒绝
    private var authStatus: String?
    ///4:品牌商 6服务商 22:消费者
    private var authType: String?
    ///拒绝原因
    private var rejectReason: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "资信认证"
        createViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestAuthInfo {[weak self] authStatus, authType, rejectReason in
            self?.authStatus = authStatus
            self?.authType = authType
            self?.rejectReason = rejectReason
        }
    }
    
    private func createViews() {
        view.backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.text = "选择认证类型"
        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.height.equalTo(28)
            make.centerX.equalToSuperview()
        }
        
        button_1 = UIButton(type: .custom)
        button_1.setImage(UIImage(named: "zbbt_zxsh_1"), for: .normal)
        button_1.addTarget(self, action: #selector(button_1_action(_:)), for: .touchUpInside)
        view.addSubview(button_1)
        button_1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.right.equalTo(view.snp.centerX).offset(-12.5)
            make.width.equalTo(145)
            make.height.equalTo(180)
        }
        
        button_2 = UIButton(type: .custom)
        button_2.setImage(UIImage(named: "zbbt_zxsh_2"), for: .normal)
        button_2.addTarget(self, action: #selector(button_2_action(_:)), for: .touchUpInside)
        view.addSubview(button_2)
        button_2.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.left.equalTo(view.snp.centerX).offset(12.5)
            make.width.equalTo(145)
            make.height.equalTo(180)
        }
        
        button_3 = UIButton(type: .custom)
        button_3.setImage(UIImage(named: "zbbt_zxsh_3"), for: .normal)
        button_3.addTarget(self, action: #selector(button_3_action(_:)), for: .touchUpInside)
        view.addSubview(button_3)
        button_3.snp.makeConstraints { make in
            make.top.equalTo(button_1.snp.bottom).offset(25)
            make.right.equalTo(view.snp.centerX).offset(-12.5)
            make.width.equalTo(145)
            make.height.equalTo(180)
        }
        
        button_4 = UIButton(type: .custom)
        button_4.setImage(UIImage(named: "zbbt_zxsh_4"), for: .normal)
        button_4.addTarget(self, action: #selector(button_4_action(_:)), for: .touchUpInside)
        view.addSubview(button_4)
        button_4.snp.makeConstraints { make in
            make.top.equalTo(button_1.snp.bottom).offset(25)
            make.left.equalTo(view.snp.centerX).offset(12.5)
            make.width.equalTo(145)
            make.height.equalTo(180)
        }
    }
    
    //材料商认证
    @objc private func button_1_action(_ sender: UIButton) {
        if let authType = authType, authType == "4", let authStatus = authStatus  {
            let vc = ZBBCreditAuthApplyResultViewController(authType: .brands, result: .init(rawValue: authStatus) ?? .wait)
            vc.rejectReason = rejectReason
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = ZBBCreditAuthBrandsViewController()
        vc.authType = authType
        vc.authStatus = authStatus
        vc.rejectReason = rejectReason
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //服务商认证
    @objc private func button_2_action(_ sender: UIButton) {
        if let authType = authType, authType == "6", let authStatus = authStatus  {
            let vc = ZBBCreditAuthApplyResultViewController(authType: .service, result: .init(rawValue: authStatus) ?? .wait)
            vc.rejectReason = rejectReason
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = ZBBCreditAuthServiceViewController()
        vc.authType = authType
        vc.authStatus = authStatus
        vc.rejectReason = rejectReason
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///消费者认证
    @objc private func button_3_action(_ sender: UIButton) {
        if let authType = authType, let authStatus = authStatus  {
            if authType == "4", (authStatus == "0" || authStatus == "1") {
                let vc = ZBBCreditAuthNoticeViewController()
                vc.msgText = "您已认证成为材料商，不可再申请成为消费者！"
                let popDialog = PopupDialog(viewController: vc, transitionStyle: .zoomIn)
                present(popDialog, animated: true)
                return
            } else if authType == "6", (authStatus == "0" || authStatus == "1") {
                let vc = ZBBCreditAuthNoticeViewController()
                vc.msgText = "您已认证成为服务商，不可再申请成为消费者！"
                let popDialog = PopupDialog(viewController: vc, transitionStyle: .zoomIn)
                present(popDialog, animated: true)
                return
            } else if authType == "22" {
                let vc = ZBBCreditAuthApplyResultViewController(authType: .customer, result: .init(rawValue: authStatus) ?? .wait)
                vc.rejectReason = rejectReason
                navigationController?.pushViewController(vc, animated: true)
                return
            }
            
        }
        //申请
        let vc = ZBBCreditAuthCustomerApplyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///设计图认证
    @objc private func button_4_action(_ sender: UIButton) {
        if let authStatus = authStatus, authStatus == "1" {
            //已认证审核通过（品牌商or服务商or消费者)
            let vc = ZBBCreditAuthDesignPaperViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = ZBBCreditAuthNoticeViewController()
            vc.msgText = "请先认证材料商、服务商或消费者身份！"
            let popDialog = PopupDialog(viewController: vc, transitionStyle: .zoomIn, preferredWidth: 250.0/375.0*SCREEN_WIDTH)
            present(popDialog, animated: true)
        }
    }

}

extension ZBBCreditAuthViewController {
    
    private func requestAuthInfo(complete: ((_ authStatus: String?, _ authType: String?, _ rejectReason: String?) -> Void)?) {
        YZBSign.shared.request(APIURL.zbbAuthInfo, method: .get) { response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let authStatus = dataDic["authStatus"] as? String
                let authType = dataDic["authType"] as? String
                let rejectReason = dataDic["rejectReason"] as? String
                complete?(authStatus, authType, rejectReason)
            } else {
                complete?(nil, nil, nil)
            }
        } failure: { error in
            complete?(nil, nil, nil)
        }
    }
}
