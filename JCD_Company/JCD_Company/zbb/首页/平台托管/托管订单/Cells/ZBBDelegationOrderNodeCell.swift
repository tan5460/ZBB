//
//  ZBBDelegationOrderNodeCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/28.
//

import UIKit

class ZBBDelegationOrderNodeCell: UITableViewCell {

    private var containerView: UIView!
    private var titleLabel: UILabel!
    private var statusLabel: UILabel!
    
    private var rateLabel: UILabel!
    private var paidLabel: UILabel!
    private var addFeeLabel: UILabel!
    private var waitPayLabel: UILabel!
    private var addFeeDescLabel: UILabel!
    
    private var bottomView: UIView!
    private var btnTopLine: UIView!
    private var btnCenterLine: UIView!
    private var leftBtn: UIButton!
    private var rightBtn: UIButton!
    
    var model: ZBBPlatformDelegationOrderNodeModel? {
        didSet {
            titleLabel.text = model?.nodeName ?? ""
            
            leftBtn.isHidden = true
            rightBtn.isHidden = true
            rightBtn.setTitle("立即验收", for: .normal)
            //1.待开始 2.待支付 3.待完工 4.待验收 5.待整改 6.已完成
            let status = model?.nodeStatus ?? "1"
            switch status {
            case "1":
                statusLabel.text = "待开始"
                leftBtn.isHidden = true
                rightBtn.isHidden = true
            case "2":
                statusLabel.text = "待支付"
                leftBtn.isHidden = true
                rightBtn.isHidden = false
                rightBtn.setTitle("立即支付", for: .normal)
            case "3":
                statusLabel.text = "待完工"
                leftBtn.isHidden = true
                rightBtn.isHidden = true
            case "4":
                statusLabel.text = "待验收"
                leftBtn.isHidden = false
                rightBtn.isHidden = false
            case "5":
                statusLabel.text = "待整改"
                leftBtn.isHidden = true
                rightBtn.isHidden = true
            case "6":
                statusLabel.text = "已完成"
                leftBtn.isHidden = false
                rightBtn.isHidden = true
            default:
                break
            }
            
            
            rateLabel.text = "付款比例：" + "\(model?.nodeRatio ?? 0)%"
            paidLabel.text = String(format: "付款金额：¥%.2f", CGFloat(model?.paidAmount ?? 0)/100.0)
            addFeeLabel.text = String(format: "增项费用：¥%.2f", CGFloat(model?.additionalAmount ?? 0)/100.0)
            waitPayLabel.text = String(format: "待付金额：¥%.2f", CGFloat((model?.nodeAmount ?? 0) - (model?.paidAmount ?? 0))/100.0)
            addFeeDescLabel.text = "增项备注：" + (model?.additionalRemarks ?? "")
            
            //
            bottomView.isHidden = leftBtn.isHidden && rightBtn.isHidden
            bottomView.snp.remakeConstraints { make in
                make.top.equalTo(addFeeDescLabel.snp.bottom).offset(10)
                make.left.right.bottom.equalTo(0)
                if bottomView.isHidden {
                    make.height.equalTo(0)
                } else {
                    make.height.equalTo(50)
                }
            }
            
            leftBtn.snp.remakeConstraints { make in
                make.top.equalTo(btnTopLine.snp.bottom)
                make.bottom.equalTo(0)
                make.left.equalTo(0)
                if rightBtn.isHidden {
                    make.right.equalTo(0)
                } else {
                    make.right.equalTo(btnCenterLine.snp.left)
                }
                
            }
            
            rightBtn.snp.remakeConstraints { make in
                make.top.equalTo(btnTopLine.snp.bottom)
                make.bottom.equalTo(0)
                make.right.equalTo(0)
                if leftBtn.isHidden {
                    make.left.equalTo(0)
                } else {
                    make.left.equalTo(btnCenterLine.snp.right)
                }
            }
            
        }
    }
    
    var leftBtnActionClosure: (() -> Void)?
    var rightBtnActionClosure: (() -> Void)?
    
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
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.lessThanOrEqualTo(-10)
            make.height.equalTo(22)
        }
        
        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 15, weight: .medium)
        containerView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-10)
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
        
        rateLabel = UILabel()
        rateLabel.font = .systemFont(ofSize: 13)
        rateLabel.textColor = .hexColor("#131313")
        containerView.addSubview(rateLabel)
        rateLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
            make.height.equalTo(18)
        }

        paidLabel = UILabel()
        paidLabel.font = .systemFont(ofSize: 13)
        paidLabel.textColor = .hexColor("#131313")
        containerView.addSubview(paidLabel)
        paidLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(10)
            make.left.equalTo(containerView.snp.centerX).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(18)
        }

        addFeeLabel = UILabel()
        addFeeLabel.font = .systemFont(ofSize: 13)
        addFeeLabel.textColor = .hexColor("#131313")
        containerView.addSubview(addFeeLabel)
        addFeeLabel.snp.makeConstraints { make in
            make.top.equalTo(rateLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
            make.height.equalTo(18)
        }

        waitPayLabel = UILabel()
        waitPayLabel.font = .systemFont(ofSize: 13)
        waitPayLabel.textColor = .hexColor("#131313")
        containerView.addSubview(waitPayLabel)
        waitPayLabel.snp.makeConstraints { make in
            make.top.equalTo(paidLabel.snp.bottom).offset(10)
            make.left.equalTo(containerView.snp.centerX).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(18)
        }

        addFeeDescLabel = UILabel()
        addFeeDescLabel.font = .systemFont(ofSize: 13)
        addFeeDescLabel.textColor = .hexColor("#131313")
        containerView.addSubview(addFeeDescLabel)
        addFeeDescLabel.snp.makeConstraints { make in
            make.top.equalTo(addFeeLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(18)
        }
        
        bottomView = UIView()
        bottomView.clipsToBounds = true
        containerView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.top.equalTo(addFeeDescLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50)
        }

        btnTopLine = UIView()
        btnTopLine.backgroundColor = .hexColor("#F0F0F0")
        bottomView.addSubview(btnTopLine)
        btnTopLine.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(0.5)
        }

        btnCenterLine = UIView()
        btnCenterLine.backgroundColor = .hexColor("#F0F0F0")
        bottomView.addSubview(btnCenterLine)
        btnCenterLine.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.centerX.equalTo(bottomView)
            make.height.equalTo(20)
            make.width.equalTo(0.5)
        }

        leftBtn = UIButton(type: .custom)
        leftBtn.backgroundColor = .white
        leftBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        leftBtn.setTitle("查看完工照片", for: .normal)
        leftBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        leftBtn.addTarget(self, action: #selector(leftBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(leftBtn)
        leftBtn.snp.makeConstraints { make in
            make.top.equalTo(btnTopLine.snp.bottom)
            make.bottom.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(btnCenterLine.snp.left)
        }

        rightBtn = UIButton(type: .custom)
        rightBtn.backgroundColor = .white
        rightBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        rightBtn.setTitle("立即验收", for: .normal)
        rightBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        rightBtn.addTarget(self, action: #selector(rightBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { make in
            make.top.equalTo(btnTopLine.snp.bottom)
            make.bottom.equalTo(0)
            make.left.equalTo(btnCenterLine.snp.right)
            make.right.equalTo(0)
        }
    }
    
    @objc private func leftBtnAction(_ sender: UIButton) {
        leftBtnActionClosure?()
    }
    
    @objc private func rightBtnAction(_ sender: UIButton) {
        rightBtnActionClosure?()
    }
}
