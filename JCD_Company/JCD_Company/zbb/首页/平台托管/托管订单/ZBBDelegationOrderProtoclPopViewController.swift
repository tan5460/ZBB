//
//  ZBBDelegationOrderProtoclPopViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/30.
//

import UIKit
import WebKit

class ZBBDelegationOrderProtoclPopViewController: UIViewController {

    private var icon: UIImageView!
    private var titleLabel: UILabel!
    
    private var webView: WKWebView!
    
    private var agreeBtn: UIButton!
    private var protocolLabel: UILabel!
    private var protocolBtn: UIButton!
    
    private var sureBtn: UIButton!
    
    var protocolBtnAction: (() -> Void)?
    var sureBtnAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
    }
    
    private func createViews() {
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(0)
            make.height.equalTo(434)
        }
        
        icon = UIImageView(image: UIImage(named: "zbbt_xy"))
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalTo(contentView)
            make.width.height.equalTo(50)
        }

        titleLabel = UILabel()
        titleLabel.text = "住保保委托服务协议"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(15)
            make.centerX.equalTo(icon)
            make.height.equalTo(22.5)
        }

        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.layer.cornerRadius = 2
        webView.layer.masksToBounds = true
        webView.backgroundColor = .hexColor("#F7F7F7")
        contentView.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-97)
        }
        
        if let path = Bundle.main.path(forResource: "zbbContract", ofType: "html") {
            webView.load(URLRequest(url: URL(fileURLWithPath: path)))
        }

        agreeBtn = UIButton(type: .custom)
        agreeBtn.setImage(UIImage(named: "zbbt_unselect"), for: .normal)
        agreeBtn.setImage(UIImage(named: "zbbt_select"), for: .selected)
        agreeBtn.addTarget(self, action: #selector(agreeBtnAction(_:)), for: .touchUpInside)
        contentView.addSubview(agreeBtn)
        agreeBtn.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom)
            make.left.equalTo(10)
            make.width.height.equalTo(27)
        }

        protocolLabel = UILabel()
        protocolLabel.text = "已完全阅读并同意"
        protocolLabel.font = .systemFont(ofSize: 12)
        protocolLabel.textColor = .hexColor("#999999")
        contentView.addSubview(protocolLabel)
        protocolLabel.snp.makeConstraints { make in
            make.left.equalTo(agreeBtn.snp.right)
            make.centerY.equalTo(agreeBtn)
        }

        protocolBtn = UIButton(type: .custom)
        protocolBtn.titleLabel?.font = .systemFont(ofSize: 12)
        protocolBtn.setTitle("《住保保委托服务协议》", for: .normal)
        protocolBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        protocolBtn.addTarget(self, action: #selector(protocolBtnAction(_:)), for: .touchUpInside)
        contentView.addSubview(protocolBtn)
        protocolBtn.snp.makeConstraints { make in
            make.left.equalTo(protocolLabel.snp.right)
            make.centerY.equalTo(protocolLabel)
        }

        sureBtn = UIButton(type: .custom)
        sureBtn.layer.cornerRadius = 20
        sureBtn.layer.masksToBounds = true
        sureBtn.backgroundColor = .hexColor("#007E41")
        sureBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        sureBtn.setTitle("确认托管", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnAction(_:)), for: .touchUpInside)
        contentView.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
        }
    }
    
    @objc private func agreeBtnAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func protocolBtnAction(_ sender: UIButton) {
        dismiss(animated: true)
        protocolBtnAction?()
    }
    
    @objc private func sureBtnAction(_ sender : UIButton) {
        if !agreeBtn.isSelected {
            noticeOnlyText("请阅读并同意委托服务协议")
            return
        }
        dismiss(animated: true)
        sureBtnAction?()
    }

}
