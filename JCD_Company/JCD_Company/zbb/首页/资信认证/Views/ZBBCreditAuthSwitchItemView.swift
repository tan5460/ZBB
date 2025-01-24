//
//  ZBBCreditAuthSwitchItemView.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/3.
//

import UIKit

class ZBBCreditAuthSwitchItemView: UIView {

    ///标题
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            titleLabel.text
        }
    }
    
    ///
    var on: Bool {
        set {
            rightSwitch.isOn = newValue
        }
        get {
            rightSwitch.isOn
        }
    }
    
    ///是否可编辑
    var isEditable: Bool {
        set {
            rightSwitch.isEnabled = newValue
        }
        get {
            rightSwitch.isEnabled
        }
    }

    
    private var titleLabel: UILabel!
    private var rightSwitch: UISwitch!
    private var separatorLine: UIView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .hexColor("#131313")
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.equalTo(-15)
        }
        
        rightSwitch = UISwitch()
        addSubview(rightSwitch)
        rightSwitch.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.centerY.equalToSuperview()
        }
        
        separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
}
