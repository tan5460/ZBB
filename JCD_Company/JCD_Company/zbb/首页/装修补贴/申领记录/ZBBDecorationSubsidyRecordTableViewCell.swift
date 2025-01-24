//
//  ZBBDecorationSubsidyRecordTableViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/7.
//

import UIKit

class ZBBDecorationSubsidyRecordTableViewCell: UITableViewCell {

    
    var model: ZBBSubsidyOrderListModel? {
        didSet {
            nameLabel.text = model?.merchantName ?? ""
            timeLabel.text = model?.updateDate ?? model?.createDate ?? ""
            coverImageView.kf.setImage(with: URL(string: APIURL.ossPicUrl + (model?.orderDataList?.first?.materialsImageUrl ?? "")), placeholder: UIImage(named: "loading"))
            titleLabel.text = model?.orderDataList?.first?.materialsName ?? ""
            typeLabel.text = "分类：" + (model?.orderDataList?.first?.categoryName ?? "")
            countLabel.text = "x" + (model?.orderDataList?.first?.materialsCount ?? "")
            priceLabel.text = String(format: "订单总额：¥%.2f", model?.orderAmount ?? 0)
            
            let attrText = NSMutableAttributedString(string: String(format: "政府补贴：¥%.2f", model?.subsidyAmount ?? 0))
            attrText.addAttribute(.foregroundColor, value: UIColor.hexColor(""), range: NSMakeRange(6, attrText.length - 6))
            subsidyLabel.attributedText = attrText
        }
    }
    
    private var containerView: UIView!
    
    private var icon: UIImageView!
    private var nameLabel: UILabel!
    private var timeLabel: UILabel!
    
    private var coverImageView: UIImageView!
    private var titleLabel: UILabel!
    private var typeLabel: UILabel!
    private var countLabel: UILabel!
    
    private var priceLabel: UILabel!
    private var subsidyLabel: UILabel!

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
        
        
        icon = UIImageView(image: UIImage(named: "zbb_bt_record_icon"))
        containerView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.width.height.equalTo(18)
        }
        
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        nameLabel.textColor = .hexColor("#131313")
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.left.equalTo(icon.snp.right).offset(2)
        }
        
        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .hexColor("#666666")
        containerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.right.equalTo(-15)
        }
        
        coverImageView = UIImageView()
        coverImageView.layer.cornerRadius = 5
        coverImageView.layer.masksToBounds = true
        coverImageView.backgroundColor = .hexColor("#F7F7F7")
        coverImageView.contentMode = .scaleAspectFill
        containerView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(12)
            make.left.equalTo(15)
            make.width.height.equalTo(65)
        }
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        titleLabel.numberOfLines = 2
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView)
            make.left.equalTo(coverImageView.snp.right).offset(10)
            make.right.equalTo(-15)
            make.height.greaterThanOrEqualTo(20)
        }
        
        typeLabel = UILabel()
        typeLabel.font = .systemFont(ofSize: 12)
        typeLabel.textColor = .hexColor("#131313")
        containerView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.left.equalTo(coverImageView.snp.right).offset(10)
            make.height.equalTo(17)
            make.bottom.equalTo(coverImageView)
        }
        
        countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = .hexColor("#131313")
        containerView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(typeLabel)
            make.right.equalTo(-15)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }
        
        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 12, weight: .medium)
        priceLabel.textColor = .hexColor("#131313")
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(16)
            make.left.equalTo(15)
            make.height.equalTo(16.5)
            make.bottom.equalTo(-21)
        }
        
        subsidyLabel = UILabel()
        subsidyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subsidyLabel.textColor = .hexColor("#131313")
        containerView.addSubview(subsidyLabel)
        subsidyLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(16)
            make.left.equalTo(priceLabel.snp.right).offset(10)
            make.height.equalTo(16.5)
            make.bottom.equalTo(-21)
        }
        
    }
}
