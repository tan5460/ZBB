//
//  ZBBCreditAuthBrandsTableViewCell.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit

class ZBBCreditAuthBrandsTableViewCell: UITableViewCell {
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var items: [ZBBAuthBrandModel] = [] {
        didSet {
            refreshViews()
        }
    }
    
    private var titleLabel: UILabel!
    private var containerView: UIView!
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }

    private func createViews() {
        selectionStyle = .none
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.equalTo(21)
        }
        
        containerView = UIView()
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
        }
    }
    
    private func refreshViews() {
        containerView.removeSubviews()
        
        if containerView.width <= 1 {
            containerView.setNeedsLayout()
            containerView.layoutIfNeeded()
        }
        
        let itemWidth = (280.0/375.0*SCREEN_WIDTH - 30.0 - 30.0)/3.0
        let itemHeight = itemWidth + 28.5
        
        for (i, item) in items.enumerated() {
            let lineIndex = i/3
            let columnIndex = i%3
            
            let itemView = ZBBCreditAuthBrandsCellItem(type: .custom)
            itemView.icon.kf.setImage(with: URL(string: APIURL.ossPicUrl + (item.brandImg ?? "")), placeholder: UIImage(named: "loading"))
            itemView.textLabel.text = item.brandName
            containerView.addSubview(itemView)
            itemView.snp.makeConstraints { make in
                make.top.equalTo(CGFloat(lineIndex)*(itemHeight + 15))
                make.width.equalTo(itemWidth)
                make.height.equalTo(itemHeight)
                if (columnIndex == 0) {
                    make.left.equalTo(0)
                } else if (columnIndex == 1) {
                    make.centerX.equalToSuperview()
                } else {
                    make.right.equalTo(0)
                }
                if i == items.count - 1 {
                    make.bottom.equalTo(0)
                }
             }
        }
    }
}


//MARK: -

fileprivate class ZBBCreditAuthBrandsCellItem: UIButton {
    
    var icon: UIImageView!
    var textLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        icon = UIImageView()
        icon.layer.cornerRadius = 5
        icon.layer.borderWidth = 0.5
        icon.layer.borderColor = UIColor.hexColor("#F0F0F0").cgColor
        icon.layer.masksToBounds = true
        icon.contentMode = .scaleAspectFit
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(icon.snp.width)
        }
        
        textLabel = UILabel()
        textLabel.font = .systemFont(ofSize: 13)
        textLabel.textColor = .hexColor("#666666")
        textLabel.textAlignment = .center
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom).offset(10)
            make.height.equalTo(18.5)
            make.left.bottom.right.equalTo(0)
        }
    }
    
    
    
}
