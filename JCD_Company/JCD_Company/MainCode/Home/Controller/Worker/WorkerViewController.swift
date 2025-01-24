//
//  WorkerViewController.swift
//  YZB_Company
//
//  Created by yzb_ios on 5.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import ObjectMapper
import PopupDialog

class WorkerViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource ,UISearchBarDelegate{
    
    var tableView: UITableView!
    var rowsData: Array<WorkerModel> = []
    var curPage = 1
    let identifier = "workerCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNoDateView("数据异常")
        prepareTableViewView()
        
        //开始刷新
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func prepareTableViewView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 76
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.register(WorkerCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview()
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
    
    //MARK: - 触发事件
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        if rowsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    //MARK: - 加载数据
    func loadData() {
        
        var storeId = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeId = valueStr
        }
        
        let pageSize = 20
        let parameters: Parameters = ["pageSize": "\(pageSize)", "pageNo": "\(self.curPage)", "store.id": storeId]
        
        let urlStr =  APIURL.getWorkerList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" || errorCode == "015" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<WorkerModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage > 1 {
                    self.rowsData += modelArray
                }
                else {
                    self.rowsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.rowsData.removeAll()
            }
            
            self.tableView.reloadData()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
            
        }) { (error) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.tableView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
        }
    }
    
    //MARK: - uitableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WorkerCell
        
        let cellModel = rowsData[indexPath.row]
        cell.workerModel = cellModel
        
        return cell
    }
    
}
