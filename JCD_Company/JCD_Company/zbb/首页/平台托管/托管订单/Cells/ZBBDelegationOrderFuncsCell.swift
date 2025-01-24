//
//  ZBBDelegationOrderFuncsCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/28.
//

import UIKit
import SnapKitExtend

class ZBBDelegationOrderFuncsCell: UITableViewCell {

    var selectedFuncClosure: ((Int) -> Void)?

    
    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var button_1: ZBBFuncsButton!
    private var button_2: ZBBFuncsButton!
    private var button_3: ZBBFuncsButton!
    private var button_4: ZBBFuncsButton!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }
    
    private func createViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(0)
        }
        
        titleLabel = UILabel()
        titleLabel.text = "常用功能"
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.lessThanOrEqualTo(-10)
            make.height.equalTo(22)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(0.5)
        }
        
        button_1 = ZBBFuncsButton(type: .custom)
        button_1.icon.image = .init(named: "zbbt_fymx")
        button_1.label.text = "费用明细"
        button_1.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        containerView.addSubview(button_1)
        button_1.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.height.equalTo(57)
            make.bottom.equalTo(-10)
        }

        button_2 = ZBBFuncsButton(type: .custom)
        button_2.icon.image = .init(named: "zbbt_zfjl")
        button_2.label.text = "支付记录"
        button_2.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        containerView.addSubview(button_2)
        button_2.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.height.equalTo(57)
        }
        
        button_3 = ZBBFuncsButton(type: .custom)
        button_3.icon.image = .init(named: "zbbt_dddt")
        button_3.label.text = "订单动态"
        button_3.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        containerView.addSubview(button_3)
        button_3.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.height.equalTo(57)
        }
        
        button_4 = ZBBFuncsButton(type: .custom)
        button_4.icon.image = .init(named: "zbbt_kxbg")
        button_4.label.text = "款项变更"
        button_4.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        containerView.addSubview(button_4)
        button_4.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.height.equalTo(57)
        }
        
        [button_1, button_2, button_3, button_4].snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        switch sender {
        case button_1:
            selectedFuncClosure?(0)
        case button_2:
            selectedFuncClosure?(1)
        case button_3:
            selectedFuncClosure?(2)
        case button_4:
            selectedFuncClosure?(3)
        default:
            break
        }
    }
}


fileprivate class ZBBFuncsButton: UIButton {
    
    var icon: UIImageView!
    var label: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        icon = UIImageView()
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalTo(self)
            make.width.height.equalTo(35)
        }
        
        label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .hexColor("#131313")
        label.textAlignment = .center
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(17)
        }
    }
    
   
}
