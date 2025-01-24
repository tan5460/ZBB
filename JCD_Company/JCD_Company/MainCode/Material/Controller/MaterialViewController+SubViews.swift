//
//  RetailViewController+SubViews.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/25.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import Foundation
import MJRefresh

extension MaterialViewController {
    
    //MARK: - 自定义导航栏
    func prepareNavigationItem() {
        
        //施工
        workBtn = UIButton(type: .custom)
        workBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        workBtn.addTarget(self, action: #selector(workAction), for: UIControl.Event.touchUpInside)
        workBtn.titleLabel?.font = UIFont.systemFont(ofSize: 9)
        workBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: workBtn)
    
        workBtn.set(image: UIImage.init(named: "road_work"), title: "施工", imagePosition: .top, additionalSpacing: 2, state: .normal)
        
        if isAddMaterial {
            //扫一扫
            let scanBtn = UIButton(type: .custom)
            scanBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
            scanBtn.setImage(UIImage(named: "nav_scancode"), for: .normal)
            
            scanBtn.addTarget(self, action: #selector(scancodeAction), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: scanBtn)
            //完成
            completeBtn = UIButton(type: .custom)
            completeBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
            completeBtn.setTitle("完成", for: .normal)
            completeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            completeBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            completeBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
            completeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: completeBtn)
            
        }
  
        //搜索栏
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = "请输入产品名称"
        navigationItem.titleView = searchBar
        
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
        
        searchBar.backgroundImage = UIColor.white.image()
        searchBar.backgroundColor = .white
        let textfield = searchBar.textField
        textfield?.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF0F0F0)
        textfield?.layer.cornerRadius = 18
        textfield?.layer.masksToBounds = true
        textfield?.clearButtonMode = .never
        textfield?.font = UIFont.systemFont(ofSize: 13)
        textfield?.textColor = PublicColor.commonTextColor
        
        //让UISearchBar 支持空搜索
        textfield?.enablesReturnKeyAutomatically = false
        
    }
    
    
    //MARK: - 工具栏
    func prepareToolView() {
        
        toolView = UIView()
        toolView.backgroundColor = UIColor.white
        toolView.layerShadow()
        view.addSubview(toolView)
        
        toolView.snp.makeConstraints { (make) in
            
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(64)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
 
        
        //系统品牌
        systemBrandBtn = UIButton(type: .custom)
        systemBrandBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        systemBrandBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
        systemBrandBtn.setImage(UIImage.init(named: "up_arrows"), for: .selected)
        systemBrandBtn.addTarget(self, action: #selector(systemBrandAction(_:)), for: .touchUpInside)
        toolView.addSubview(systemBrandBtn)
        
        systemBrandBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            if IS_iPad {
                make.left.equalTo(20)
                make.height.equalTo(30)
            } else {
                
                make.left.equalTo(10)
                make.height.equalTo(30)
            }
            make.width.equalTo(100)
        }
        systemBrandBtn.set(image: UIImage.init(named: "down_arrows"), title: "系统品牌", imagePosition: .right, additionalSpacing: 5, state: .normal)
 
        //单品
        singleBtn = UIButton(type: .custom)
        singleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        singleBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        singleBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
        singleBtn.setImage(UIImage.init(named: "single_item_select"), for: .selected)
        singleBtn.addTarget(self, action: #selector(singleAction(_:)), for: .touchUpInside)
        toolView.addSubview(singleBtn)
        
        singleBtn.snp.makeConstraints { (make) in
            make.height.centerY.equalTo(systemBrandBtn)
            if IS_iPad {
                make.right.equalTo(-20)
            }else {
                make.right.equalTo(-10)
            }
            make.width.equalTo(80)
        }
        
        singleBtn.set(image: UIImage.init(named: "single_item"), title: "单品", imagePosition: .right, additionalSpacing: 5, state: .normal)

        //自建品牌
        buildBrandBtn = UIButton(type: .custom)
        buildBrandBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        buildBrandBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        buildBrandBtn.setImage(UIImage.init(named: "up_arrows"), for: .selected)
        buildBrandBtn.addTarget(self, action: #selector(buildBrandAction(_:)), for: .touchUpInside)
        toolView.addSubview(buildBrandBtn)
        
        buildBrandBtn.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(systemBrandBtn)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
        }
        buildBrandBtn.set(image: UIImage.init(named: "down_arrows"), title: "自建品牌", imagePosition: .right, additionalSpacing: 5, state: .normal)
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = UIColor.init(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
        toolView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    //MARK: - 创建collectionView
    func prepareCollectionView() {
        
        let cellWidth = IS_iPad ? (PublicSize.screenWidth-40)/3 : (PublicSize.screenWidth-30)/2
        var cellHeight = cellWidth*(245.0/173)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(MaterialCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.insertSubview(collectionView, aboveSubview: toolView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(toolView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        collectionView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        collectionView.mj_footer = footer
        collectionView.mj_footer?.isHidden = true
    }
    
    //MARK: - 菜单栏
    func prepareMenuView() {
        //系统品牌
        filtrateView = FiltrateView()
        let cate = CategoryModel()
        cate.name = "全部"
        cate.id = ""
//        filtrateView?.tableView2.normalSelectCategory = cate
        view?.addSubview(filtrateView!)
        filtrateView?.hiddeBlock = {[weak self] in
            self?.systemBrandBtn.isSelected = false
        }
        filtrateView?.snp.makeConstraints({ (make) in
         
            make.top.equalTo(toolView.snp.bottom)
            make.right.left.bottom.equalToSuperview()
        })
        
        //自建品牌
        buildFiltrateView = FiltrateView()
        buildFiltrateView?.isSelfMercant = true
        view?.addSubview(buildFiltrateView!)
        buildFiltrateView?.hiddeBlock = {[weak self] in
            self?.buildBrandBtn.isSelected = false
        }
        buildFiltrateView?.snp.makeConstraints({ (make) in
            
            make.top.equalTo(toolView.snp.bottom)
            make.right.left.bottom.equalToSuperview()
        })

    }
}


