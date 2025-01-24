//
//  WithdrawalsRecordController.swift
//  YZB_Company
//
//  Created by yzb_ios on 24.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import MJRefresh

class WithdrawalsRecordController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var rowsData: Array<WithdrawalsRecordModel> = []
    var curPage = 1                             //页码
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "提现记录"
        
        prepareTableView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 64
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WithdrawalsRecordCell.self, forCellReuseIdentifier: WithdrawalsRecordCell.self.description())
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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
        AppLog("下拉刷新")
        curPage = 1
        
        loadData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        if rowsData.count > 0 {
            curPage += 1
        }else {
            curPage = 1
        }
        
        loadData()
    }
    
    
    //MARK: - 网络请求
    
    //提现记录
    func loadData() {
                
        let pageSize = 20
        let parameters: Parameters = ["size": "\(pageSize)", "current": "\(curPage)"]
        
        let urlStr = APIURL.getWithdrawList
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            self.clearAllNotice()
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<WithdrawalsRecordModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
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
            }
            
            self.tableView.reloadData()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
        }) { (error) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WithdrawalsRecordCell.self.description(), for: indexPath) as! WithdrawalsRecordCell
        
        if indexPath.row == 0 {
            cell.topLineVie.isHidden = false
        }else {
            cell.topLineVie.isHidden = true
        }
        
        let detailModel = rowsData[indexPath.row]
        cell.recordModel = detailModel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
}
