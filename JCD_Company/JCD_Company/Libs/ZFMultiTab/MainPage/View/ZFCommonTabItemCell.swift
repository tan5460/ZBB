//
//  ZFCommonTabItemCell.swift
//  FortuneCatApp
//
//  Created by Flying on 2020/4/27.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation
import Stevia

class ZFCommonTabItemCell: UICollectionViewCell {
    
    func configView(view: UIView) {
        contentView.sv(view)
        view.followEdges(contentView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // cell在重用之前需要将原有的subview清掉，防止重复多次add
        for subView in contentView.subviews {
            subView.removeFromSuperview()
        }
    }
    
    private func initViews() {
        contentView.backgroundColor = .white
    }
}
