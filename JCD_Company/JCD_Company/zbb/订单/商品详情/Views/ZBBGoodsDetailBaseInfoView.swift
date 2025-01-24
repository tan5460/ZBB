//
//  ZBBGoodsDetailBaseInfoView.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/16.
//

import UIKit

class ZBBGoodsDetailBaseInfoView: UIView {
    
    private var priceLabel: UILabel!
    private var oldPriceLabel: UILabel!
    
    private var subsidyView: UIView!
    private var subsidyIcon: UIImageView!
    private var subsidyLabel: UILabel!
    
    private var titleLabel: UILabel!
    private var typeLabel: UILabel!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 10)
    }

}
