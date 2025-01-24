//
//  ZBBCreditAuthDesignPaperTableViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/2.
//

import UIKit

class ZBBCreditAuthDesignPaperTableViewCell: UITableViewCell {

    var model: ZBBCreditAuthDesignPaperModel? {
        didSet {
            timeLabel.text = model?.createDate
            nameLabel.text = model?.fileName
        }
    }
    
    private var containerView: UIView!
    private var timeLabel: UILabel!
    private var icon: UIImageView!
    private var nameLabel: UILabel!
    private var downBtn: UIButton!
    private var shareBtn: UIButton!

    
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
        
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
        }

        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .hexColor("#666666")
        containerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(15)
            make.height.equalTo(16)
        }
        
        let line = UIView()
        line.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }

        icon = UIImageView(image: UIImage(named: "zbbt_wj"))
        containerView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.bottom.equalTo(-15)
            make.width.height.equalTo(20)
        }

        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = .hexColor("#131313")
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.left.equalTo(icon.snp.right).offset(2)
            make.right.lessThanOrEqualTo(-100)
        }

        downBtn = UIButton(type: .custom)
        downBtn.setImage(UIImage(named: "zbbt_xz"), for: .normal)
        downBtn.addTarget(self, action: #selector(downBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(downBtn)
        downBtn.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.right.equalTo(-50)
            make.width.height.equalTo(50)
        }

        shareBtn = UIButton(type: .custom)
        shareBtn.setImage(UIImage(named: "zbbt_fx"), for: .normal)
        shareBtn.addTarget(self, action: #selector(shareBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(shareBtn)
        shareBtn.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.right.equalTo(0)
            make.width.height.equalTo(50)
        }
        
        let btnLine = UIView()
        btnLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(btnLine)
        btnLine.snp.makeConstraints { make in
            make.centerY.equalTo(downBtn)
            make.left.equalTo(shareBtn)
            make.width.equalTo(0.5)
            make.height.equalTo(16)
        }
    }
    
    @objc private func downBtnAction(_ sender: UIButton) {
        
    }
    
    @objc private func shareBtnAction(_ sender: UIButton) {
        
    }
}
