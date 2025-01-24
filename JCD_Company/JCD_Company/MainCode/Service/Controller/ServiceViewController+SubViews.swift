//
//  ServiceViewController+SubViews.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/10/30.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh

extension ServiceViewController {
    
    //MARK: - 自定义导航栏
    func prepareNavigationItem() {
        
        //筛选
        let screenBtn = UIButton(type: .custom)
        screenBtn.frame = CGRect.init(x: 0, y: 0, width: 28, height: 30)
        screenBtn.setImage(UIImage(named: "shop_filter"), for: .normal)
        screenBtn.addTarget(self, action: #selector(screenAction), for: .touchUpInside)
        if addServiceType != .service {
            //完成
            let cancelBtn = UIButton(type: .custom)
            cancelBtn.frame = CGRect.init(x: 0, y: 0, width: 35, height: 30)
            cancelBtn.setTitle("完成", for: .normal)
            cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            cancelBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            cancelBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
            cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: cancelBtn),UIBarButtonItem.init(customView: screenBtn)]
        }else {
          
            //购物车
            let cartBtn = UIButton(type: .custom)
            cartBtn.frame = CGRect.init(x: 0, y: 0, width: 28, height: 30)
            cartBtn.setImage(UIImage(named: "icon_shop_black"), for: .normal)
            cartBtn.addTarget(self, action: #selector(goCartAction), for: .touchUpInside)
            
            navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: screenBtn),UIBarButtonItem.init(customView: cartBtn)]
        }
        
        //搜索栏
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = "请输入施工名称"
        navigationItem.titleView = searchBar
        
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
        
        searchBar.backgroundImage = UIColor.white.image()
        searchBar.backgroundColor = .white
        let textfield = searchBar.textField
        textfield?.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF0F0F0)
        textfield?.layer.cornerRadius = 18
        textfield?.layer.masksToBounds = true
        textfield?.font = UIFont.systemFont(ofSize: 13)
        textfield?.textColor = PublicColor.commonTextColor
        
        // Add spinner to search bar
        spinner.stopAnimating()
        
        if let textField = searchBar.subviews.first?.subviews.last {
            textField.addSubview(spinner)
            
            spinner.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(5)
                make.width.height.equalTo(20)
            }
        }
    }
     
    //MARK: - 创建TableView
    func prepareTableView() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        //列表
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 96
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(ServiceCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(0)
            }
            make.left.right.bottom.equalToSuperview()
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer = footer
        tableView.mj_footer?.isHidden = true
    }
    
    //MARK: - 搜索时按钮
    func prepareMaskBtn() {
        //搜索时蒙版遮罩
        maskBtn = UIButton(type: .custom)
        maskBtn.isHidden = true
        maskBtn.backgroundColor = UIColor.init(white: 0.1, alpha: 0.1)
        maskBtn.addTarget(self, action: #selector(cancelSearchAction), for: .touchUpInside)
        self.view.addSubview(maskBtn)
        
        maskBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - 菜单栏
    func prepareMenuView() {

        //筛选
        rightMenuView = ServiceFilterView()
        view?.addSubview(rightMenuView!)
       
        rightMenuView?.snp.makeConstraints({ (make) in
 
            make.top.right.left.bottom.equalToSuperview()
        })
    }
    
}
