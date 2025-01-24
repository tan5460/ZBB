//
//  ZBBDelegationOrderProgressTableViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit

class ZBBDelegationOrderProgressTableViewCell: UITableViewCell {
    
    private var dotView: UIView!
    private var upLine: UIView!
    private var downLine: UIView!
    
    private var timeLabel: UILabel!
    private var containerView: UIView!
    private var contentLabel: UILabel!

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
        

        dotView = UIView()
        dotView.layer.cornerRadius = 5
        dotView.layer.masksToBounds = true
        dotView.backgroundColor = .hexColor("#007E41")
        contentView.addSubview(dotView)
        dotView.snp.makeConstraints { make in
            make.top.equalTo(18.5)
            make.left.equalTo(15)
            make.width.height.equalTo(10)
        }

        upLine = UIView()
        upLine.backgroundColor = .hexColor("#007E41", alpha: 0.2)
        contentView.addSubview(upLine)
        upLine.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.width.equalTo(1)
            make.centerX.equalTo(dotView)
            make.bottom.equalTo(dotView.snp.centerY)
        }
        
        downLine = UIView()
        downLine.backgroundColor = .hexColor("#007E41", alpha: 0.2)
        contentView.addSubview(downLine)
        downLine.snp.makeConstraints { make in
            make.top.equalTo(dotView.snp.centerY)
            make.width.equalTo(1)
            make.centerX.equalTo(dotView)
            make.bottom.equalTo(0)
        }

        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .hexColor("#666666")
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dotView)
            make.left.equalTo(dotView.snp.right).offset(10)
            make.height.equalTo(16)
        }

        containerView = UIView()
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .hexColor("#007E41", alpha: 0.1)
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.left.equalTo(timeLabel)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
        }

        contentLabel = UILabel()
        contentLabel.font = .systemFont(ofSize: 14, weight: .medium)
        contentLabel.textColor = .hexColor("#131313")
        contentLabel.numberOfLines = 0
        containerView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-15)
            make.height.greaterThanOrEqualTo(20)
        }
    }

    func config(isFirst: Bool, isLast: Bool, timeText: String, contentText: String) {
        upLine.isHidden = isFirst
        downLine.isHidden = isLast
        timeLabel.text = timeText
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 20
        style.maximumLineHeight = 20
        let attrText = NSMutableAttributedString(string: contentText)
        attrText.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, attrText.length))
        contentLabel.attributedText = attrText
    }
}
