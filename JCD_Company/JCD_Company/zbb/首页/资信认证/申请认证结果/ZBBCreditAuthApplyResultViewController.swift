//
//  ZBBCreditAuthApplyResultViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/3.
//

import UIKit

class ZBBCreditAuthApplyResultViewController: BaseViewController {

    enum AuthType {
        case brands
        case service
        case customer
        case designPaper(id: String?)
    }
    
    enum AuthResult: String {
        case wait = "0"
        case success = "1"
        case fail = "2"
    }
    
    ///品牌商、服务商 后台地址
    var webURL: String?
    ///失败原因
    var rejectReason: String?
    
    private var authType: AuthType
    private var result: AuthResult
    init(authType: AuthType, result: AuthResult) {
        self.authType = authType
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private var statusIcon: UIImageView!
    private var statusLabel: UILabel!
    private var descLabel: UILabel!
    
    private var copyBtn: UIButton!
    private var actionBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        refreshViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.view
    }
    
    private func createViews() {
        view.backgroundColor = .white
        
        statusIcon = UIImageView()
        view.addSubview(statusIcon)
        statusIcon.snp.makeConstraints { make in
            make.top.equalTo(75)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(160)
        }

        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 16, weight: .medium)
        statusLabel.textColor = .hexColor("#131313")
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(statusIcon.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }

        descLabel = UILabel()
        descLabel.font = .systemFont(ofSize: 13, weight: .medium)
        descLabel.textColor = .hexColor("#666666")
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        view.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }

        copyBtn = UIButton(type: .custom)
        copyBtn.layer.cornerRadius = 22
        copyBtn.layer.borderWidth = 1
        copyBtn.layer.borderColor = UIColor.hexColor("#007E41").cgColor
        copyBtn.layer.masksToBounds = true
        copyBtn.titleLabel?.font = .systemFont(ofSize: 16)
        copyBtn.setTitle("复制网址", for: .normal)
        copyBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        copyBtn.addTarget(self, action: #selector(copyBtnAction(_:)), for: .touchUpInside)
        view.addSubview(copyBtn)
        copyBtn.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(30)
            make.left.equalTo(30)
            make.right.equalTo(view.snp.centerX).offset(-7.5)
            make.height.equalTo(44)
        }

        actionBtn = UIButton(type: .custom)
        actionBtn.layer.cornerRadius = 22
        actionBtn.layer.masksToBounds = true
        actionBtn.backgroundColor = .hexColor("#007E41")
        actionBtn.titleLabel?.font = .systemFont(ofSize: 16)
        actionBtn.setTitleColor(.white, for: .normal)
        actionBtn.addTarget(self, action: #selector(actionBtnAction(_:)), for: .touchUpInside)
        view.addSubview(actionBtn)
        actionBtn.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(30)
            make.right.equalTo(-30)
            make.left.equalTo(view.snp.centerX).offset(7.5)
            make.height.equalTo(44)
        }
    }
    
    private func refreshViews() {
        switch authType {
            case .brands:
                title = "材料商认证"
            case .service:
                title = "服务商认证"
            case .customer:
                title = "消费者认证"
            case .designPaper:
                title = "设计图认证"
        }
        
        copyBtn.isHidden = true
        switch result {
            case .wait:
                statusIcon.image = UIImage(named: "zbbt_authResult_wait")
                statusLabel.text = "您的资料已提交正在等待\n审核，请耐心等待"
                descLabel.text = nil
                actionBtn.setTitle("修改认证资料", for: .normal)
            case .success:
                statusIcon.image = UIImage(named: "zbbt_authResult_success")
                actionBtn.setTitle("查看认证资料", for: .normal)
                switch authType {
                    case .brands:
                        statusLabel.text = "您已认证成为材料商"
                        descLabel.text = "请用电脑打开以下网址进行使用：\n\(webURL ?? "")"
                        copyBtn.isHidden = false
                    case .service:
                        statusLabel.text = "您已认证成为服务商"
                        descLabel.text = "请用电脑打开以下网址进行使用：\n\(webURL ?? "")"
                        copyBtn.isHidden = false
                    case .customer:
                        statusLabel.text = "您已认证成为消费者"
                        descLabel.text = "可参与政府补贴活动！"
                        copyBtn.isHidden = true
                    case .designPaper:
                        statusLabel.text = "已认证图纸"
                        descLabel.text = ""
                        copyBtn.isHidden = true
                }
            case .fail:
                statusIcon.image = UIImage(named: "zbbt_authResult_fail")
                statusLabel.text = "审核拒绝"
                descLabel.text = rejectReason ?? "原因：资料不符合要求，请重新准备"
                actionBtn.setTitle("修改认证资料", for: .normal)
        }
        
        actionBtn.snp.remakeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(30)
            make.height.equalTo(44)
            if copyBtn.isHidden {
                make.width.equalTo(150)
                make.centerX.equalToSuperview()
            } else {
                make.left.equalTo(view.snp.centerX).offset(7.5)
                make.right.equalTo(-30)
            }
        }
        
    }
    
    @objc private func copyBtnAction(_ sender: UIButton) {
        if let webURL = webURL, webURL.count > 0 {
            UIPasteboard.general.string = webURL
            noticeOnlyText("复制成功")
        }
    }
    
    @objc private func actionBtnAction(_ sender: UIButton) {
        switch authType {
            case .brands:
                let vc = ZBBCreditAuthBrandsApplyViewController()
                vc.type = result == .success ? .check : .edit
                navigationController?.pushViewController(vc, animated: true)
            case .service:
                let vc = ZBBCreditAuthServiceApplyViewController()
                vc.type = result == .success ? .check : .edit
                navigationController?.pushViewController(vc, animated: true)
            case .customer:
                let vc = ZBBCreditAuthCustomerApplyViewController()
                vc.type = result == .success ? .check : .edit
                navigationController?.pushViewController(vc, animated: true)
            case .designPaper(let id):
                let vc = ZBBCreditAuthDesignPaperApplyViewController()
                vc.type = result == .success ? .check : .edit
                vc.id = id
                navigationController?.pushViewController(vc, animated: true)
        }
    }
    

}
