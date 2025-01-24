//
//  ZBBCreditAuthBrandsLeftView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit

class ZBBCreditAuthBrandsLeftView: UIView {

    var titles: [String] = [] {
        didSet {
            refreshViews()
        }
    }
    
    var selectedIndex: Int {
        set {
            if targetIndex >= 0, newValue != targetIndex {
                return
            }
            targetIndex = -1
            selected(index: newValue, toTop: true)
        }
        get {
            return index
        }
    }
    
    var selectedClosure: ((Int) -> Void)?
    
    private var index = 0
    private var targetIndex = -1
    
    private var scrollView: UIScrollView!
    
    private var selectedView: UIView!
    private var selectedBackView: UIView!
    private var selectedLeftLine: UIView!
    private var selectedTopIcon: UIImageView!
    private var selectedBottomIcon: UIImageView!
    
    private var contentView: UIView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }

        selectedView = UIView()
        scrollView.addSubview(selectedView)
        selectedView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.right.equalTo(0)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(73)
        }
        
        selectedBackView = UIView()
        selectedBackView.backgroundColor = .white
        selectedView.addSubview(selectedBackView)
        selectedBackView.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.right.equalTo(0)
            make.bottom.equalTo(-8)
        }
        
        selectedLeftLine = UIView()
        selectedLeftLine.backgroundColor = .hexColor("#007E41")
        selectedView.addSubview(selectedLeftLine)
        selectedLeftLine.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(13)
        }

        selectedTopIcon = UIImageView(image: UIImage(named: "zbbt_top"))
        selectedView.addSubview(selectedTopIcon)
        selectedTopIcon.snp.makeConstraints { make in
            make.top.right.equalTo(0)
            make.width.height.equalTo(8)
        }

        selectedBottomIcon = UIImageView(image: UIImage(named: "zbbt_down"))
        selectedView.addSubview(selectedBottomIcon)
        selectedBottomIcon.snp.makeConstraints { make in
            make.bottom.right.equalTo(0)
            make.width.height.equalTo(8)
        }

        contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedBackView.setNeedsLayout()
        selectedBackView.layoutIfNeeded()
        selectedBackView.corner(byRoundingCorners: [.topLeft, .bottomLeft], radii: 8)
    }
    
    private func refreshViews() {
        contentView.removeSubviews()
        
        var lastButton: UIButton? = nil;
        titles.forEach { title in
            let button = UIButton(type: .custom)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.titleLabel?.numberOfLines = 2
            button.contentHorizontalAlignment = .left
            button.setTitle(title, for: .normal)
            button.setTitleColor(.hexColor("#131313"), for: .normal)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            button.snp.makeConstraints { make in
                if let lastButton = lastButton {
                    make.top.equalTo(lastButton.snp.bottom)
                } else {
                    make.top.equalTo(15)
                }
                make.left.equalTo(18)
                make.right.equalTo(-5)
                make.height.equalTo(selectedView)
                if title == titles.last {
                    make.bottom.equalTo(-15)
                }
            }
            lastButton = button
        }
    }
    
    private func selected(index: Int, toTop: Bool) {
        
        guard index >= 0, index < titles.count else {
            self.index = 0
            selectedView.snp.remakeConstraints { make in
                make.top.equalTo(15)
                make.left.right.equalTo(0)
                make.width.equalTo(self.snp.width)
                make.height.equalTo(73)
            }
            return
        }
        
        let button = contentView.subviews[index]
        selectedView.snp.remakeConstraints { make in
            make.centerY.equalTo(button)
            make.left.right.equalTo(0)
            make.width.equalTo(self.snp.width)
            make.height.equalTo(73)
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.scrollView.setNeedsLayout()
            self.scrollView.layoutIfNeeded()
        }
        
        
        if toTop {
            var willOffsetY = button.frame.minY - 15
            let shortHeight = scrollView.contentSize.height - scrollView.frame.height - willOffsetY
            if shortHeight < 0 {
                willOffsetY = willOffsetY + shortHeight
            }
            scrollView.setContentOffset(CGPointMake(0, willOffsetY), animated: true)
        }
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        if let index = contentView.subviews.firstIndex(of: sender) {
            selectedClosure?(index)
            selected(index: index, toTop: true)
            targetIndex = index
        }
    }
}
