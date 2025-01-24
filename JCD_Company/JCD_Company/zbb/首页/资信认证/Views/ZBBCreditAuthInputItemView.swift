//
//  ZBBCreditAuthInputItemView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit

class ZBBCreditAuthInputItemView: UIView, UITextViewDelegate {
    
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
    var contentText: String {
        set {
            textView.text = newValue
            textViewDidChange(textView)
        }
        get {
            return textView.text
        }
    }
    
    ///提示语
    var placeText: String? {
        set {
            textView.placeHolderEx = newValue
        }
        get {
            textView.placeHolderEx
        }
    }
    
    ///字数限制
    var maxLength = 100
    
    ///是否可编辑
    var isEditable: Bool {
        set {
            textView.isEditable = newValue
        }
        get {
            textView.isEditable
        }
    }
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textView.keyboardType = keyboardType
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
    
    
    private var requiredLabel: UILabel!
    private var titleLabel: UILabel!
    private var textView: UITextView!
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
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.lessThanOrEqualTo(-15)
        }
        
        textView = UITextView()
        textView.delegate = self
        textView.font = .systemFont(ofSize: 14, weight: .medium)
        textView.textColor = .hexColor("#131313")
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 2, bottom: 8, right: 0)
        textView.placeholdFont = .systemFont(ofSize: 14)
        textView.placeholdColor = .hexColor("#CDCDCD")
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(93)
            make.right.equalTo(-15)
            make.height.greaterThanOrEqualTo(34)
            make.bottom.equalTo(-8)
        }
        
        separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let nstext = textView.text as NSString
        var string = nstext.replacingCharacters(in: range, with: text)
        if let markedTextRange = textView.markedTextRange, !markedTextRange.isEmpty {
            if let markedText = textView.text(in: markedTextRange), string.contains(markedText) {
                string = string.replacingOccurrences(of: markedText, with: "")
            }
        }

        if maxLength > 0, string.count > maxLength {
            textView.text = string.subString(to: maxLength)
            noticeOnlyText("最多\(maxLength)个字")
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.placeHolderExLabel?.isHidden = !textView.text.isEmpty
        let size = textView.sizeThatFits(CGSizeMake(SCREEN_WIDTH - 115, CGFLOAT_MAX))
        textView.snp.remakeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(93)
            make.right.equalTo(-15)
            make.height.greaterThanOrEqualTo(max(34, size.height))
            make.bottom.equalTo(-8)
        }
    }
    
}
