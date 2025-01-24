//
//  PurchaseRemarkCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 17.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class PurchaseRemarkCell: UITableViewCell, UITextViewDelegate {

    var titleLabel: UILabel!
    var textView: UITextView!
    var placeholderLabel: UILabel!
    
    var textViewChangeBlock: ((_ textStr: String)->())?
    var textViewEndEditBlock: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //标题
        titleLabel = UILabel()
        titleLabel.text = "备注:"
        titleLabel.textColor = PublicColor.minorTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.height.equalTo(16)
            make.width.lessThanOrEqualTo(80)
        }
        
        //备注输入框
        textView = UITextView()
        textView.delegate = self
        textView.textColor = PublicColor.commonTextColor
        textView.font = titleLabel.font
        contentView.addSubview(textView)
        
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(titleLabel)
            make.right.equalTo(-15)
            make.bottom.equalTo(-5)
        }
        
        //提示
        placeholderLabel = UILabel()
        placeholderLabel.text = "非必填                             "
        placeholderLabel.textColor = PublicColor.placeholderTextColor
        placeholderLabel.font = titleLabel.font
        placeholderLabel.textAlignment = .left
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        textView.setValue(placeholderLabel, forKey: "_placeholderLabel")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if let block = textViewChangeBlock {
            block(textView.text)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isScrollEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isScrollEnabled = false
        
        if let block = textViewEndEditBlock {
            block()
        }
    }
}
