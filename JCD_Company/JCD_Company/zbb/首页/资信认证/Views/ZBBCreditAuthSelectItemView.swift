//
//  ZBBCreditAuthSelectItemView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit
import IQKeyboardManagerSwift

class ZBBCreditAuthSelectItemView: UIView {

    ///是否必填
    var isRequried: Bool {
        set {
            requiredLabel.isHidden = !newValue
        }
        get {
            !requiredLabel.isHidden
        }
    }
    
    ///标题
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            titleLabel.text
        }
    }
    
    ///内容
    var contentText: String = "" {
        didSet {
            refreshContentLabel()
        }
    }
    
    ///提示语
    var placeText: String = "" {
        didSet {
            refreshContentLabel()
        }
    }
    
    ///是否可编辑
    var isEditable: Bool {
        set {
            contentBtn.isEnabled = newValue
            moreIcon.isHidden = !newValue
        }
        get {
            contentBtn.isEnabled
        }
    }
    
    var hideSeparatorLine: Bool {
        set {
            separatorLine.isHidden = newValue
        }
        get {
            separatorLine.isHidden
        }
    }
    
    var selectedClosure: (() -> Void)?
    
    private var requiredLabel: UILabel!
    private var titleLabel: UILabel!
    private var contentLabel: UILabel!
    private var contentBtn: UIButton!
    private var moreIcon: UIImageView!
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
        
        requiredLabel = UILabel()
        requiredLabel.isHidden = true
        requiredLabel.text = "*"
        requiredLabel.font = .systemFont(ofSize: 14)
        requiredLabel.textColor = .hexColor("#FF3C2F")
        addSubview(requiredLabel)
        requiredLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(8)
            make.height.equalTo(20)
        }
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .hexColor("#131313")
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.greaterThanOrEqualTo(20)
        }
        
        contentLabel = UILabel()
        contentLabel.font = .systemFont(ofSize: 14, weight: .medium)
        contentLabel.textColor = .hexColor("#131313")
        contentLabel.numberOfLines = 0
        addSubview(contentLabel);
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(100)
            make.right.equalTo(-25)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.equalTo(-15)
        }

        contentBtn = UIButton(type: .custom)
        contentBtn.addTarget(self, action: #selector(contentBtnAction(_:)), for: .touchUpInside)
        addSubview(contentBtn)
        contentBtn.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(0)
            make.left.equalTo(contentLabel);
        }

        moreIcon = UIImageView(image: UIImage(named: "purchase_arrow"))
        addSubview(moreIcon)
        moreIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
        
        separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
        
    }
    
    private func refreshContentLabel() {
        if contentText.count > 0 {
            contentLabel.text = contentText
            contentLabel.font = .systemFont(ofSize: 14, weight: .medium)
            contentLabel.textColor = .hexColor("#131313")
        } else {
            contentLabel.text = placeText
            contentLabel.font = .systemFont(ofSize: 14)
            contentLabel.textColor = .hexColor("#CDCDCD")
        }
    }
    
    @objc private func contentBtnAction(_ sender: UIButton) {
        IQKeyboardManager.shared.resignFirstResponder()
        selectedClosure?()
    }

}
