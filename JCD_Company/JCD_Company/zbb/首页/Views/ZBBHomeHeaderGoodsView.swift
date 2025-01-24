//
//  ZBBHomeHeaderGoodsView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/20.
//

import UIKit

class ZBBHomeHeaderGoodsView: UIView {

    var coverImageView: UIImageView!
    var typeIcon: UIImageView!
    var titleLabel: UILabel!
    var descLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = .white

        coverImageView = UIImageView()
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.backgroundColor = .hexColor("#F6F6F6")
        addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(coverImageView.snp.width)
        }

        typeIcon = UIImageView()
        addSubview(typeIcon)
        typeIcon.snp.makeConstraints { make in
            make.top.right.equalTo(0)
            make.width.equalTo(34)
            make.height.equalTo(17)
        }

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(6)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.equalTo(16.5)
        }

        descLabel = UILabel()
        descLabel.font = .systemFont(ofSize: 10, weight: .medium)
        descLabel.textColor = .hexColor("#FF3C2F")
        descLabel.textAlignment = .center
        addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.equalTo(14)
        }
    }

}
