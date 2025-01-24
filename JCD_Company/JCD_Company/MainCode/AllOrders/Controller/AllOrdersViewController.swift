//
//  MyCenterViewController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/31.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import ObjectMapper

class AllOrdersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var topSelectBtnTag = 0
    
    var tableView: UITableView!
    var topView: UIView!                        //顶部栏
    var topBarView: UIView!                     //顶部选中条
    
    var btnArray = ["全部", "待确认", "已确认", "已完成"]
    
    let identifier = "orderCell"
    
    var viewModel: AllOrdersViewModel!
    
    var exchangeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "客户订单"
        viewModel = AllOrdersViewModel()
        viewModel.delegate = self
        
//        if AppData.plusOrderStatusTypeList.count > 0 {
//            let array = Utils.getFieldArrInDirArr(arr: AppData.plusOrderStatusTypeList, field: "label")
//            btnArray = ["全部"] + array
//        }
        prepareTopView()
        prepareNoDateView("暂无订单")
        prepareTableView()
        
        if viewModel.rowsData.count <= 0 && !(tableView.mj_header?.isRefreshing ?? false) {
            tableView.mj_header?.beginRefreshing()
        }else {
            self.pleaseWait()
            headerRefresh()
        }
        
        GlobalNotificationer.add(observer: self, selector: #selector(headerRefresh), notification: .order)
    }
    
    deinit {
        GlobalNotificationer.remove(observer: self, notification: .order)
    }
    
    func prepareTopView() {
        
        topView = UIView()
        topView.backgroundColor = .white
        view.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        for i in 0..<btnArray.count {
            let button = UIButton(type: .custom)
            button.tag = 100+i
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitle(btnArray[i], for: .normal)
            button.setTitleColor(PublicColor.commonTextColor, for: .normal)
            button.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
            button.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
            button.addTarget(self, action: #selector(topSwitchAction(_:)), for: .touchUpInside)
            topView.addSubview(button)
            
            let btnRight = Float(i+1)*(1.0/Float(btnArray.count))
            button.snp.makeConstraints({ (make) in
                make.top.bottom.equalToSuperview()
                make.right.equalToSuperview().multipliedBy(btnRight)
                make.width.equalToSuperview().multipliedBy(1.0/Float(btnArray.count))
            })
            
            if i == topSelectBtnTag {
                button.isSelected = true
                exchangeButton = button
                viewModel.topClick(index: i)
            }
        }
        
        let topLine = UIView()
        topLine.backgroundColor = PublicColor.partingLineColor
        topView.addSubview(topLine)

        topLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        topBarView = UIView()
        topBarView.backgroundColor = PublicColor.emphasizeTextColor
        topView.addSubview(topBarView)
        
        if let sender = exchangeButton {
            
            let textWidth = sender.titleWidth()
            
            topBarView.snp.makeConstraints { (make) in
                make.centerX.equalTo(sender)
                make.bottom.equalToSuperview()
                make.width.equalTo(textWidth+20)
                make.height.equalTo(2)
            }
        }
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 174
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        tableView.register(AllOrdersCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
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
    
    @objc func headerRefresh() {
        viewModel.headerRefresh()
    }
    
    @objc func footerRefresh() {
        viewModel.footerRefresh()
    }
    
    //MARK: - 按钮事件
    @objc func topSwitchAction(_ sender: UIButton) {
        AppLog("点击了切换按钮")
        
        exchangeButton.isSelected = false
        exchangeButton = sender
        exchangeButton.isSelected = true
        
        let textWidth = sender.titleWidth()
        
        topBarView.snp.remakeConstraints { (make) in
            make.centerX.equalTo(sender)
            make.bottom.equalToSuperview()
            make.width.equalTo(textWidth+20)
            make.height.equalTo(2)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.topView.layoutIfNeeded()
        }
        
        let tagValue = sender.tag-100
        viewModel.topClick(index: tagValue)
        
        tableView.mj_footer?.isHidden = true
        
        if tableView.mj_header?.isRefreshing  ?? false {
            tableView.mj_header?.endRefreshing()
        }
        self.pleaseWait()
        viewModel.headerRefresh()
    }
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.rowsDataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! AllOrdersCell
        
        let orderModel = viewModel.rowsData[indexPath.row]
        cell.orderModel = orderModel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectRowAt(indexPath: indexPath)
    }
    
}
// MARK: - AllOrdersViewModelDelegate
extension AllOrdersViewController: AllOrdersViewModelDelegate {
    
    func pushOrderDetailCart() {
        let vc = OrderDetailCartController()
        vc.orderModel = viewModel.model
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushOrderDetail() {
        let vc = OrderDetailController()
        vc.orderModel = viewModel.model
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func endRefresh() {
        self.tableView.mj_header?.endRefreshing()
        self.tableView.mj_footer?.endRefreshing()
        self.tableView.mj_footer?.isHidden = false
    }
    
    func endRefreshingWithNoMoreData() {
        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
    }
    
    func resetNoMoreData() {
        self.tableView.mj_footer?.resetNoMoreData()
    }
    
    func reloadUI() {
        self.tableView.reloadData()
    }
    
    func updateUI() {
        self.tableView.mj_footer?.isHidden = viewModel.footerIsHidden
        self.noDataView.isHidden = viewModel.noneDataIsHidden
    }
    
}
