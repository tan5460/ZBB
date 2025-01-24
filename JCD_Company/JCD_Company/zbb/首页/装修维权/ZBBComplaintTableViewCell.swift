//
//  ZBBComplaintTableViewCell.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/4.
//

import UIKit

class ZBBComplaintTableViewCell: UITableViewCell {
    
    var model: ZBBComplaintListModel? {
        didSet {
            refreshViews()
        }
    }

    private var containerView: UIView!
    private var typeLabel: UILabel!
    private var timeLabel: UILabel!
    private var serviceLabel: UILabel!
    private var descLabel: UILabel!
    
    private var imgsView: ZBBComplaintImgsView!
    
    private var resultView: UIView!
    private var resultTimeLabel: UILabel!
    private var resultDescLabel: UILabel!
    private var resultImgsView: ZBBComplaintImgsView!
    
    
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
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(0)
        }
        

        typeLabel = UILabel()
        typeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        typeLabel.textColor = .hexColor("#131313")
        containerView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }

        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .hexColor("#666666")
        containerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(typeLabel)
            make.right.equalTo(-15)
        }

        serviceLabel = UILabel()
        serviceLabel.font = .systemFont(ofSize: 12, weight: .medium)
        serviceLabel.textColor = .hexColor("#007E41")
        serviceLabel.numberOfLines = 0
        containerView.addSubview(serviceLabel)
        serviceLabel.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }

        descLabel = UILabel()
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .hexColor("#131313")
        descLabel.numberOfLines = 0
        containerView.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(serviceLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }

        imgsView = ZBBComplaintImgsView()
        containerView.addSubview(imgsView)
        imgsView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }

        resultView = UIView()
        resultView.layer.cornerRadius = 5
        resultView.layer.masksToBounds = true
        resultView.backgroundColor = .hexColor("#F7F7F7")
        containerView.addSubview(resultView)
        resultView.snp.makeConstraints { make in
            make.top.equalTo(imgsView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-15)
        }

        resultTimeLabel = UILabel()
        resultTimeLabel.font = .systemFont(ofSize: 12)
        resultTimeLabel.textColor = .hexColor("#666666")
        resultView.addSubview(resultTimeLabel)
        resultTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.height.equalTo(20)
        }

        resultDescLabel = UILabel()
        resultDescLabel.font = .systemFont(ofSize: 12, weight: .medium)
        resultDescLabel.textColor = .hexColor("#131313")
        resultDescLabel.numberOfLines = 0
        resultView.addSubview(resultDescLabel)
        resultDescLabel.snp.makeConstraints { make in
            make.top.equalTo(resultTimeLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }

        resultImgsView = ZBBComplaintImgsView()
        resultView.addSubview(resultImgsView)
        resultImgsView.snp.makeConstraints { make in
            make.top.equalTo(resultDescLabel.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }
    
    private func refreshViews() {
        //
        let problemType = model?.problemType ?? 1
        if problemType == 1 {
            typeLabel.text = "质量问题"
        } else if problemType == 2 {
            typeLabel.text = "费用问题"
        } else {
            typeLabel.text = "其他问题"
        }
        
        //
        timeLabel.text = model?.createDate
        //
        serviceLabel.text = "被投诉方：" + (model?.complaintObject ?? "")
        //
        descLabel.text = model?.problemDescription
        //
        imgsView.refreshViews(urls: model?.problemPicUrl?.components(separatedBy: ",") ?? [], totalWidth: SCREEN_WIDTH - 50)
        
        
        //
        resultView.isHidden = (model?.dealState ?? 0) != 2
        imgsView.snp.remakeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            if resultView.isHidden {
                make.bottom.equalTo(-15)
            }
        }
        resultView.snp.remakeConstraints { make in
            make.top.equalTo(imgsView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            if !resultView.isHidden {
                make.bottom.equalTo(-15)
            }
        }
        //
        resultTimeLabel.text = model?.updateDate
        //
        resultDescLabel.text = model?.dealResult
        //
        resultImgsView.refreshViews(urls: model?.dealPicUrl?.components(separatedBy: ",") ?? [], totalWidth: SCREEN_WIDTH - 70)
    }
}
