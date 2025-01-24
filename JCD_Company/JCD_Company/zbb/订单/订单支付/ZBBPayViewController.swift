//
//  ZBBPayViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/15.
//

import UIKit

class ZBBPayViewController: BaseViewController {
    
    private var infoView: UIView!
    private var priceLabel: UILabel!
    private var descLabel: UILabel!
    private var orderTitleLabel: UILabel!
    private var orderLabel: UILabel!
    private var timeTitleLabel: UILabel!
    private var timeLabel: UILabel!
    
    private var payView: UIView!
    private var wechatIcon: UIImageView!
    private var wechatLabel: UILabel!
    private var wechatBtn: UIButton!
    private var balanceIcon: UIImageView!
    private var balanceLabel: UILabel!
    private var balanceBtn: UIButton!
    
    private var sureBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单支付"
        createViews()
    }
    
    private func createViews() {

        infoView = UIView()
        infoView.layer.cornerRadius = 10
        infoView.layer.masksToBounds = true
        infoView.backgroundColor = .white
        view.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }

        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 24, weight: .medium)
        priceLabel.textColor = .hexColor("#FF3C2F")
        infoView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(33.5)
        }
        
        descLabel = UILabel()
        descLabel.text = "订单支付"
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .hexColor("666666")
        infoView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }

        let infoSeparatorLine = UIView()
        infoSeparatorLine.backgroundColor = .hexColor("#F0F0F0")
        infoView.addSubview(infoSeparatorLine)
        infoSeparatorLine.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(30)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }
        
        orderTitleLabel = UILabel()
        orderTitleLabel.text = "订单编号："
        orderTitleLabel.font = .systemFont(ofSize: 14)
        orderTitleLabel.textColor = .hexColor("#131313")
        infoView.addSubview(orderTitleLabel)
        orderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(infoSeparatorLine.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }

        orderLabel = UILabel()
        orderLabel.font = .systemFont(ofSize: 14, weight: .medium)
        orderLabel.textColor = .hexColor("#131313")
        infoView.addSubview(orderLabel)
        orderLabel.snp.makeConstraints { make in
            make.centerY.equalTo(orderTitleLabel)
            make.right.equalTo(-15)
        }

        timeTitleLabel = UILabel()
        timeTitleLabel.text = "下单时间："
        timeTitleLabel.font = .systemFont(ofSize: 14)
        timeTitleLabel.textColor = .hexColor("#131313")
        infoView.addSubview(timeTitleLabel)
        timeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(orderTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
            make.bottom.equalTo(-15)
        }

        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = .hexColor("#131313")
        infoView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(timeTitleLabel)
            make.right.equalTo(-15)
        }

        
        
        payView = UIView()
        payView.layer.cornerRadius = 10
        payView.layer.masksToBounds = true
        payView.backgroundColor = .white
        view.addSubview(payView)
        payView.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }

        wechatIcon = UIImageView(image: UIImage(named: "zbbt_pay_wechat"))
        payView.addSubview(wechatIcon)
        wechatIcon.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(15)
            make.width.height.equalTo(20)
        }

        wechatLabel = UILabel()
        wechatLabel.text = "微信支付"
        wechatLabel.font = .systemFont(ofSize: 16, weight: .medium)
        wechatLabel.textColor = .hexColor("#333333")
        payView.addSubview(wechatLabel)
        wechatLabel.snp.makeConstraints { make in
            make.centerY.equalTo(wechatIcon)
            make.left.equalTo(wechatIcon.snp.right).offset(5)
        }

        wechatBtn = UIButton(type: .custom)
        wechatBtn.setImage(UIImage(named: "zbbt_pay_unselect"), for: .normal)
        wechatBtn.setImage(UIImage(named: "zbbt_pay_select"), for: .selected)
        wechatBtn.addTarget(self, action: #selector(wechatBtnAction(_:)), for: .touchUpInside)
        payView.addSubview(wechatBtn)
        wechatBtn.snp.makeConstraints { make in
            make.centerY.equalTo(wechatIcon)
            make.width.height.equalTo(40)
            make.right.equalTo(-5)
        }
        
        let paySeparatorLine = UIView()
        paySeparatorLine.backgroundColor = .hexColor("#F0F0F0")
        payView.addSubview(paySeparatorLine)
        paySeparatorLine.snp.makeConstraints { make in
            make.top.equalTo(wechatIcon.snp.bottom).offset(16)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }
        
        balanceIcon = UIImageView(image: UIImage(named: "zbbt_pay_balance"))
        payView.addSubview(balanceIcon)
        balanceIcon.snp.makeConstraints { make in
            make.top.equalTo(paySeparatorLine.snp.bottom).offset(16)
            make.left.equalTo(15)
            make.width.height.equalTo(20)
        }
        
        balanceLabel = UILabel()
        balanceLabel.text = "余额支付"
        balanceLabel.font = .systemFont(ofSize: 16, weight: .medium)
        balanceLabel.textColor = .hexColor("#333333")
        payView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(balanceIcon)
            make.left.equalTo(balanceIcon.snp.right).offset(5)
        }
        
        balanceBtn = UIButton(type: .custom)
        balanceBtn.setImage(UIImage(named: "zbbt_pay_unselect"), for: .normal)
        balanceBtn.setImage(UIImage(named: "zbbt_pay_select"), for: .selected)
        balanceBtn.addTarget(self, action: #selector(balanceBtnAction(_:)), for: .touchUpInside)
        payView.addSubview(balanceBtn)
        balanceBtn.snp.makeConstraints { make in
            make.centerY.equalTo(balanceIcon)
            make.width.height.equalTo(40)
            make.right.equalTo(-5)
        }
        
        

        sureBtn = UIButton(type: .custom)
        sureBtn.layer.cornerRadius = 22
        sureBtn.layer.masksToBounds = true
        sureBtn.backgroundColor = .hexColor("#007E41")
        sureBtn.titleLabel?.font = .systemFont(ofSize: 16)
        sureBtn.setTitle("确认支付", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnAction(_:)), for: .touchUpInside)
        view.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { make in
            make.top.equalTo(payView.snp.bottom).offset(50)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
            
        }
    }
    
    
    //MARK: - Action
    
    @objc private func wechatBtnAction(_ sender: UIButton) {
        wechatBtn.isSelected = true
        balanceBtn.isSelected = false
    }
    
    @objc private func balanceBtnAction(_ sender: UIButton) {
        wechatBtn.isSelected = false
        balanceBtn.isSelected = true
    }
    
    @objc private func sureBtnAction(_ sender: UIButton) {
        if !wechatBtn.isSelected && !balanceBtn.isSelected {
            noticeOnlyText("请选择支付方式")
            return
        }
    }

}
