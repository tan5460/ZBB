//
//  SelectRoomCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 7.11.2018.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class SelectRoomCell: UITableViewCell {

    var nameLabel: UILabel!             //标题
    var countLabel: UILabel!            //数量
    var minusBtn: UIButton!             //减按钮
    var addBtn: UIButton!               //加按钮
    
    var selRoomModel: SelRoomModel? {
        didSet {
            
            minusBtn.isEnabled = true
            addBtn.isEnabled = true
            if let roomCount = selRoomModel?.roomCount {
                if roomCount <= 0 {
                    minusBtn.isEnabled = false
                }
                if roomCount >= 10 {
                    addBtn.isEnabled = false
                }
                countLabel.text = "\(roomCount)"
            }
            
            if let valueStr = selRoomModel?.roomName {
                nameLabel.text = valueStr
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
        
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubView() {
        
        //标题
        nameLabel = UILabel()
        nameLabel.text = "房间名"
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = PublicColor.commonTextColor
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        //加按钮
        addBtn = UIButton.init(type: .custom)
        addBtn.setImage(UIImage.init(named: "room_add"), for: .normal)
        addBtn.addTarget(self, action: #selector(addBtnAction), for: .touchUpInside)
        contentView.addSubview(addBtn)
        
        addBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(-10)
            make.width.height.equalTo(40)
        }
        
        //减按钮
        minusBtn = UIButton.init(type: .custom)
        minusBtn.setImage(UIImage.init(named: "room_reduce"), for: .normal)
        minusBtn.setImage(UIImage.init(named: "room_disreduce"), for: .disabled)
        minusBtn.addTarget(self, action: #selector(minusBtnAction), for: .touchUpInside)
        contentView.addSubview(minusBtn)
        
        minusBtn.snp.makeConstraints { (make) in
            make.right.equalTo(addBtn.snp.left).offset(-20)
            make.centerY.width.height.equalTo(addBtn)
        }
        
        //数量
        countLabel = UILabel()
        countLabel.text = "0"
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 15)
        countLabel.textColor = PublicColor.minorTextColor
        contentView.addSubview(countLabel)
        
        countLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(minusBtn.snp.right)
            make.right.equalTo(addBtn.snp.left)
        }
    }
    
    //加号按钮点击
    @objc func addBtnAction() {
        
        selRoomModel?.roomCount += 1
        minusBtn.isEnabled = true
        if let roomCount = selRoomModel?.roomCount {
            if roomCount >= 10 {
                addBtn.isEnabled = false
            }
            countLabel.text = "\(roomCount)"
        }
    }
    
    //减号按钮点击
    @objc func minusBtnAction() {
        
        selRoomModel?.roomCount -= 1
        addBtn.isEnabled = true
        if let roomCount = selRoomModel?.roomCount {
            if roomCount <= 0 {
                minusBtn.isEnabled = false
            }
            countLabel.text = "\(roomCount)"
        }
    }
}
