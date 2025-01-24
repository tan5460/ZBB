//
//  ZBBCreditAuthNoticeViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/31.
//

import UIKit

class ZBBCreditAuthNoticeViewController: BaseViewController {

    var msgText: String?
    
    private var icon: UIImageView!
    private var msgLabel: UILabel!
    private var sureBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
    }
    
    private func createViews() {
        let contentView = UIView()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(0)
            make.width.equalTo(280.0/375.0*SCREEN_WIDTH)
        }
        
        icon = UIImageView(image: UIImage(named: "zbbt_tx"))
        contentView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 22
        style.maximumLineHeight = 22
        msgLabel = UILabel()
        msgLabel.attributedText = NSAttributedString(string: msgText ?? "", attributes: [.paragraphStyle : style])
        msgLabel.font = .systemFont(ofSize: 16, weight: .medium)
        msgLabel.textColor = .hexColor("#131313")
        msgLabel.numberOfLines = 0
        contentView.addSubview(msgLabel)
        msgLabel.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(15)
            make.height.greaterThanOrEqualTo(44)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(30)
            make.right.lessThanOrEqualTo(-30)
        }
        
        sureBtn = UIButton(type: .custom)
        sureBtn.layer.cornerRadius = 20
        sureBtn.layer.masksToBounds = true
        sureBtn.backgroundColor = .hexColor("#007E41")
        sureBtn.titleLabel?.font = .systemFont(ofSize: 14)
        sureBtn.setTitle("我知道了", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnAction(_:)), for: .touchUpInside)
        contentView.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { make in
            make.top.equalTo(msgLabel.snp.bottom).offset(30)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(40)
            make.bottom.equalTo(-20)
        }
        
    }

    @objc private func sureBtnAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
