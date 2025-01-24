//
//  ZBBSubsidyRegionSortView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/8.
//

import UIKit

class ZBBSubsidyRegionSortView: UIView {
    
    enum ZBBSubsidyRegionSortType {
        case normal
        case priceUp
        case priceDown
    }
    
    var sortTypeActionClosure: (() -> Void)?
    private(set) var sortType: ZBBSubsidyRegionSortType = .normal {
        didSet {
            switch sortType {
            case .normal:
                normalBtn.isSelected = true
                normalBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
                priceBtn.isSelected = false
                priceBtn.titleLabel?.font = .systemFont(ofSize: 14)
            case .priceUp:
                normalBtn.isSelected = false
                normalBtn.titleLabel?.font = .systemFont(ofSize: 14)
                priceBtn.isSelected = true
                priceBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
                priceBtn.setImage(UIImage(named: "zbbt_price_up"), for: .selected)
            case .priceDown:
                normalBtn.isSelected = false
                normalBtn.titleLabel?.font = .systemFont(ofSize: 14)
                priceBtn.isSelected = true
                priceBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
                priceBtn.setImage(UIImage(named: "zbbt_price_down"), for: .selected)
            }
        }
    }
    
    var categoryActionClosure: (() -> Void)?
    var isSelectedCategory: Bool = false {
        didSet {
            categoryBtn.isSelected = isSelectedCategory
            categoryBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: isSelectedCategory ? .medium : .regular)
            categoryBtn.setImage(UIImage(named: "zbbt_brand_unselect"), for: .normal)
        }
    }
    
    var filterActionClosure: (() -> Void)?
    var isSelectedFilter: Bool = false {
        didSet {
            filterBtn.isSelected = isSelectedCategory
            filterBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: isSelectedFilter ? .medium : .regular)
        }
    }
    
    //MARK: - 
    
    private var normalBtn: UIButton!
    private var priceBtn: UIButton!
    private var categoryBtn: UIButton!
    private var filterBtn: UIButton!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        normalBtn = UIButton(type: .custom)
        normalBtn.isSelected = true
        normalBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        normalBtn.setTitle("综合", for: .normal)
        normalBtn.setTitleColor(.hexColor("#666666"), for: .normal)
        normalBtn.setTitleColor(.hexColor("#131313"), for: .selected)
        normalBtn.addTarget(self, action: #selector(normalBtnAction(_:)), for: .touchUpInside)
        addSubview(normalBtn)
        normalBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
        }
        
        priceBtn = UIButton(type: .custom)
        priceBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        priceBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -55)
        priceBtn.titleLabel?.font = .systemFont(ofSize: 14)
        priceBtn.setTitle("价格", for: .normal)
        priceBtn.setTitleColor(.hexColor("#666666"), for: .normal)
        priceBtn.setTitleColor(.hexColor("#131313"), for: .selected)
        priceBtn.setImage(UIImage(named: "zbbt_price_normal"), for: .normal)
        priceBtn.addTarget(self, action: #selector(priceBtnAction(_:)), for: .touchUpInside)
        addSubview(priceBtn)
        priceBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
        }
        
        categoryBtn = UIButton(type: .custom)
        categoryBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        categoryBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -65)
        categoryBtn.titleLabel?.font = .systemFont(ofSize: 14)
        categoryBtn.setTitle("分类", for: .normal)
        categoryBtn.setTitleColor(.hexColor("#666666"), for: .normal)
        categoryBtn.setTitleColor(.hexColor("#131313"), for: .selected)
        categoryBtn.setTitleColor(.hexColor("#131313"), for: .highlighted)
        categoryBtn.setImage(UIImage(named: "zbbt_brand_unselect"), for: .normal)
        categoryBtn.setImage(UIImage(named: "zbbt_brand_select"), for: .selected)
        categoryBtn.addTarget(self, action: #selector(categoryBtnAction(_:)), for: .touchUpInside)
        addSubview(categoryBtn)
        categoryBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
        }
        
        filterBtn = UIButton(type: .custom)
        filterBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        filterBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -65)
        filterBtn.titleLabel?.font = .systemFont(ofSize: 14)
        filterBtn.setTitle("筛选", for: .normal)
        filterBtn.setTitleColor(.hexColor("#666666"), for: .normal)
        filterBtn.setTitleColor(.hexColor("#131313"), for: .selected)
        filterBtn.setImage(UIImage(named: "zbbt_filter_unselect"), for: .normal)
        filterBtn.setImage(UIImage(named: "zbbt_filter_select"), for: .selected)
        filterBtn.addTarget(self, action: #selector(filterBtnAction(_:)), for: .touchUpInside)
        addSubview(filterBtn)
        filterBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(0)
        }
        
        [normalBtn, priceBtn, categoryBtn, filterBtn].snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = .hexColor("#CCCCCC")
        addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
    
    //MARK: - Action
    
    @objc private func normalBtnAction(_ sender: UIButton) {
        if sortType == .normal {
            return
        }
        sortType = .normal
        sortTypeActionClosure?()
    }

    @objc private func priceBtnAction(_ sender: UIButton) {
        if sortType != .priceUp {
            sortType = .priceUp
        } else {
            sortType = .priceDown
        }
        sortTypeActionClosure?()
    }

    @objc private func categoryBtnAction(_ sender: UIButton) {
        categoryBtn.isSelected = false
        categoryBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        categoryBtn.setImage(UIImage(named: "zbbt_brand_highlight"), for: .normal)
        categoryActionClosure?()
    }

    @objc private func filterBtnAction(_ sender: UIButton) {
        filterActionClosure?()
    }

}
