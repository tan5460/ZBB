//
//  ZFTitleBar.swift
//  ZFMultiTabPage
//
//  此bar对外提供了做渐隐渐现动效的接口，用户可以自行设置maxScrollY属性的值，来控制主页面在上下滑动的时候bar的透明度
//
//  Created by yuzhengfei on 2020/5/9.
//  Copyright © 2020 mflywork. All rights reserved.
//

import Foundation
import Stevia

class ZFTitleBar: UIView {
    
    //最大上滑距离
    var maxScrollY: CGFloat = 0.0
    
    // 此view主要用来做渐隐渐现的动效
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.alpha = 0.0
        contentView.backgroundColor = .white
        return contentView
    }()
    
    public lazy var mainBackButton: UIButton = {
        let btn = UIButton()
        let image = #imageLiteral(resourceName: "detail_back").imageChangeColor(color: .white)
        btn.image(image)
        return btn
    }()
    
    public lazy var backButton: UIButton = {
        let btn = UIButton()
        let image = #imageLiteral(resourceName: "detail_back").imageChangeColor(color: .black)
        btn.image(image)
        return btn
    }()
    
    public lazy var mainTitleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = self.titleLabel.font
        return titleLabel
    }()
    
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "ZFMultiTabPage"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configViews() {
        sv(mainBackButton, mainTitleLabel, contentView)
        contentView.sv(backButton, titleLabel)
        layout(
            PublicSize.kStatusBarHeight,
            |mainBackButton.size(44)-(>=0)-mainTitleLabel.centerHorizontally(),
            >=0
        )
        contentView.followEdges(self)
        layout(
            PublicSize.kStatusBarHeight,
            |backButton.size(44)-(>=0)-titleLabel.centerHorizontally(),
            >=0
        )
        backButton.addTarget(self, action: #selector(backBtnClick(btn:)))
        mainBackButton.addTarget(self, action: #selector(backBtnClick(btn:)))
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        parentController?.navigationController?.popViewController()
    }
    
}

// MARK: - Public Methods 对外
extension ZFTitleBar {
    func setTransparent(_ offsetY: CGFloat) {
        var alpha = 0.0
        let vc = parentController as? BaseViewController
        if offsetY > 0, offsetY < maxScrollY {
            alpha = Double(offsetY / maxScrollY)
            if alpha < 0.5 {
                vc?.statusStyle = .lightContent
            } else {
                vc?.statusStyle = .default
            }
        } else if offsetY >= maxScrollY {
            alpha = 1.0
            vc?.statusStyle = .default
        }
        contentView.alpha = CGFloat(alpha)
    }
}
