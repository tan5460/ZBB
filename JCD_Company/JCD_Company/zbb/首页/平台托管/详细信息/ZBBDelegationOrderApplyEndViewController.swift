//
//  ZBBDelegationOrderApplyEndViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/30.
//

import UIKit

class ZBBDelegationOrderApplyEndViewController: UIViewController {

    var completeClosure: ((String) -> Void)?
    
    private var titleLabel: UILabel!
    private var textView: UITextView!
    private var cancelBtn: UIButton!
    private var sureBtn: UIButton!
    
    deinit {
        print(#function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
    }
    
    private func createViews() {
        let contentView = UIView()
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(0)
            make.height.equalTo(295)
        }
        
        titleLabel = UILabel()
        titleLabel.text = "结束托管"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalTo(contentView)
            make.height.equalTo(22.5)
        }
        
        textView = UITextView()
        textView.layer.cornerRadius = 2
        textView.layer.masksToBounds = true
        textView.backgroundColor = .hexColor("#F7F7F7")
        textView.font = .systemFont(ofSize: 13)
        textView.placeHolderEx = "请填写申诉原因"
        textView.placeholdFont = .systemFont(ofSize: 13)
        textView.placeholdColor = .hexColor("#6F7A75")
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-70)
        }
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.layer.cornerRadius = 20
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.hexColor("#CCCCCC").cgColor
        cancelBtn.layer.masksToBounds = true
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.hexColor("#131313"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction(_:)), for: .touchUpInside)
        contentView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(contentView.snp.centerX).offset(-7.5)
            make.height.equalTo(40)
        }
        
        sureBtn = UIButton(type: .custom)
        sureBtn.layer.cornerRadius = 20
        sureBtn.layer.masksToBounds = true
        sureBtn.backgroundColor = .hexColor("#007E41")
        sureBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        sureBtn.setTitle("提交申请", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnAction(_:)), for: .touchUpInside)
        contentView.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(10)
            make.right.equalTo(-15)
            make.left.equalTo(contentView.snp.centerX).offset(7.5)
            make.height.equalTo(40)
        }
    }
    

    @objc private func cancelBtnAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func sureBtnAction(_ sender: UIButton) {
        let text = textView.text.replacingOccurrences(of: " ", with: "")
        if text.count <= 0 {
            view.noticeOnlyText("请填写申诉原因")
            return
        }
        completeClosure?(textView.text)
        dismiss(animated: true)
    }
}
