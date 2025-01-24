//
//  BankCardCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 23.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class BankCardCell: UITableViewCell {

    var backView: UIView!               //背景
    var bankTitleLable: UILabel!        //银行标题
    var bankNoLabel: UILabel!           //银行卡号
    
    var bankCardModel: BankCardModel? {
        
        didSet {
            bankTitleLable.text = bankCardModel!.recipient?.open_bank
            bankNoLabel.text = bankCardModel!.recipient?.account
            
//            if let valueStr = bankCardModel?.bankCompanyName {
//                bankTitleLable.text = valueStr
//            }
//            if let valueStr = bankCardModel?.bankcardNo {
//                let index = valueStr.index(valueStr.endIndex, offsetBy: -4)
//                let suffixStr = String(valueStr.suffix(from: index))
//                bankNoLabel.text = "****  ****  ****  \(suffixStr)"
//            }
        }
    }
    
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
        self.backgroundColor = UIColor.clear
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //背景
        backView = UIView()
        backView.backgroundColor = PublicColor.bankYellowColor
        backView.layer.cornerRadius = 4
        contentView.addSubview(backView)
        
        backView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalToSuperview()
        }
        
        //银行标题
        bankTitleLable = UILabel()
        bankTitleLable.text = "银行名称"
        bankTitleLable.textColor = UIColor.white
        bankTitleLable.font = UIFont.systemFont(ofSize: 15)
        backView.addSubview(bankTitleLable)
        
        bankTitleLable.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(18)
        }
        
        //银行标题
        bankNoLabel = UILabel()
        bankNoLabel.text = "****  ****  ****  ****"
        bankNoLabel.textColor = UIColor.white
        bankNoLabel.font = UIFont.systemFont(ofSize: 20)
        backView.addSubview(bankNoLabel)
        
        bankNoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bankTitleLable)
            make.top.equalTo(bankTitleLable.snp.bottom).offset(15)
        }
    }
}
