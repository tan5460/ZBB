//
//  ZBBDelegationOrderCompletePhotoTableViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit

class ZBBDelegationOrderCompletePhotoTableViewCell: UITableViewCell {

    var imgURLs: [String]? {
        didSet {
            refreshViews()
        }
    }
    
    var leftLabel: UILabel!
    
    private var containerView: UIView!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }
    
    private func createViews() {
        selectionStyle = .none
        backgroundColor = .white
        
        leftLabel = UILabel()
        leftLabel.font = .systemFont(ofSize: 14)
        leftLabel.textColor = .hexColor("#131313")
        contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }
     
        containerView = UIView()
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(100)
            make.right.equalTo(-20)
            make.bottom.equalTo(-15)
            make.height.greaterThanOrEqualTo(20)
        }
    }
        
    private func refreshViews() {
        //
        for view in containerView.subviews {
            view.removeFromSuperview()
        }
        
        //
        if let imgURLs = imgURLs {
            let imageWidth = floor((SCREEN_WIDTH - 115 - 20)/3)
            for url in imgURLs {
                let imageView = UIImageView()
                imageView.layer.cornerRadius = 4
                imageView.layer.masksToBounds = true
                imageView.contentMode = .scaleAspectFill
                imageView.backgroundColor = .hexColor("#F7F7F7")
                imageView.kf.setImage(with: URL(string: url), placeholder: UIImage(named: ""))
                containerView.addSubview(imageView)
            }
            
            if (containerView.subviews.count > 1) {
                containerView.subviews.snp.distributeSudokuViews(fixedItemWidth: imageWidth, fixedItemHeight: imageWidth, warpCount: 3, edgeInset: .zero)
            } else {
                let imageView = containerView.subviews.first
                imageView?.snp.makeConstraints { make in
                    make.top.left.equalTo(0)
                    make.width.height.equalTo(imageWidth)
                }
            }
            
            let lineCount = imgURLs.count/3 + 1
            let height = CGFloat(lineCount)*(imageWidth + 10.0) - 10.0
            containerView.snp.remakeConstraints { make in
                make.top.equalTo(15)
                make.left.equalTo(100)
                make.right.equalTo(-20)
                make.bottom.equalTo(-15)
                make.height.equalTo(height)
            }
        }
        
    }
}
