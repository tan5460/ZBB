//
//  ZBBPayResultViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/15.
//

import UIKit

class ZBBPayResultViewController: BaseViewController {

    private var statusIcon: UIImageView!
    private var statusLabel: UILabel!
    private var descLabel: UILabel!
    private var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
    }

    private func createViews() {
        statusIcon = UIImageView()
        view.addSubview(statusIcon)
        statusIcon.snp.makeConstraints { make in
            make.top.equalTo(75)
            make.centerX.equalToSuperview()
            make.height.equalTo(61)
            make.width.equalTo(61)
        }
        
        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 18, weight: .medium)
        statusLabel.textColor = .hexColor("#131313")
        view.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(statusIcon.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(25)
        }
        
        descLabel = UILabel()
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .hexColor("#666666")
        view.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        button = UIButton(type: .custom)
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.backgroundColor = .hexColor("#007E41")
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(250)
        }
    }


    //MARK: - Action
    
    @objc private func buttonAction(_ sender: UIButton) {
        
    }
}
