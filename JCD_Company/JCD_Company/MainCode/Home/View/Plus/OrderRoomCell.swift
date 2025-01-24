//
//  OrderRoomCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/5/18.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

class OrderRoomCell: UITableViewCell {

    var roomTitleLabel: UILabel!                //房间名
    var signView: UIView!                       //选中标记
    var selectedBtn: UIButton!                  //选择按钮
    
    var selecteBlock: ((_ isCheck: Bool)->())?  //点击选择
    
    var isEdit: Bool = false {
        
        didSet {
            
            if isEdit {
                selectedBtn.isHidden = false
                
                roomTitleLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(16)
                    make.right.equalTo(-4)
                }
            }else {
                selectedBtn.isHidden = true
                
                roomTitleLabel.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.left.equalTo(10)
                    make.right.equalTo(-10)
                }
            }
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
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //选中按钮
        selectedBtn = UIButton.init(type: .custom)
        selectedBtn.isHidden = true
        selectedBtn.setImage(UIImage.init(named: "order_unchecked_room"), for: .normal)
        selectedBtn.setImage(UIImage.init(named: "order_checked_room"), for: .selected)
        selectedBtn.addTarget(self, action: #selector(selectedAction), for: .touchUpInside)
        contentView.addSubview(selectedBtn)
        
        selectedBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(22)
            make.height.equalTo(50)
        }
        
        //房间标题
        roomTitleLabel = UILabel()
        roomTitleLabel.text = "房间名"
        roomTitleLabel.numberOfLines = 2
        roomTitleLabel.textAlignment = .center
        roomTitleLabel.textColor = PublicColor.commonTextColor
        roomTitleLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(roomTitleLabel)
        
        roomTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        //选中标记
        signView = UIView()
        signView.backgroundColor = PublicColor.emphasizeTextColor
        contentView.addSubview(signView)
        
        signView.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.width.equalTo(2)
            make.height.equalTo(34)
        }
        
    }
    
    //选中
    @objc func selectedAction() {
        
        selectedBtn.isSelected = !selectedBtn.isSelected
        
        if let block = selecteBlock {
            block(selectedBtn.isSelected)
        }
    }

}
