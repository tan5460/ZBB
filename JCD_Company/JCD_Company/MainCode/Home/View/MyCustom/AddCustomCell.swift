//
//  AddCustomCell.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/7.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class AddCustomCell: UITableViewCell {
    
    var leftLabel : UILabel!
    var rightTextField : UITextField!
    var line: UIView!
    var textFieldChangeBlock: ((_ textStr: String)->())?
    var isTelNumber = false
    
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
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func createSubView() {
        
        //左边label
        leftLabel = UILabel()
        leftLabel.text = ""
        leftLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x1E1E1E)
        leftLabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView.addSubview(leftLabel)
        
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
        }
        
        //右边label
        rightTextField = UITextField()
        rightTextField.text = ""
        rightTextField.textAlignment = .right
        rightTextField.textColor = PublicColor.commonTextColor
        rightTextField.font = UIFont.systemFont(ofSize: 14)
        rightTextField.addTarget(self, action: #selector(changeValue), for: .editingChanged)
        self.contentView.addSubview(rightTextField)
        
        rightTextField.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(28)
            make.left.equalTo(leftLabel.snp.right).offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        line = UIView()
        line.backgroundColor = PublicColor.partingLineColor
        self.contentView.addSubview(line)
        
        line.snp.makeConstraints { (make) in
            make.right.equalTo(rightTextField.snp.right)
            make.height.equalTo(1)
            make.left.equalTo(leftLabel.snp.left)
            make.bottom.equalToSuperview().offset(-1)
        }
    }
    
    
    @objc func changeValue(_ textField: UITextField) {
        if isTelNumber {
            if ((textField.text ?? "").length >= 11) {
                textField.text = textField.text?.subString(to: 11)
            }
        }
        
        textFieldChangeBlock?(textField.text ?? "")
    }
}
