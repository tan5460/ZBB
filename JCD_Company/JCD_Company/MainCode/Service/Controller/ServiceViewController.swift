//
//  ServiceViewController.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/10/30.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import MJRefresh

enum AddServiceType {
    
    case service            //施工商城
    case AddRoutine         //添加常规施工
    case AddCheapen         //添加套餐内升级项施工
}


class ServiceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var addServiceType: AddServiceType = .service                   //施工商城样式
    var addServiceBlock: ((_ serviceModel: ServiceModel)->())?      //添加施工block
    var serviceType: NSNumber = 2                                   //查询施工类型
    
    var searchBar: UISearchBar!                 //搜索
    var maskBtn: UIButton!                      //搜索时遮罩按钮
    let spinner = UIActivityIndicatorView(style: .gray)        //活动指示器
    var rightMenuView: ServiceFilterView!       //筛选菜单
    
    var tableView: UITableView!
    var rowsData: Array<ServiceModel> = []
    var curPage = 1                             //页码
    var searchName: String = ""                 //搜索类容
    var category: String = ""                   //施工分类
    var beginCusPrice: Float?                   //价格筛选低
    var endCusPrice: Float?                     //价格筛选高
    
    var sortType: NSNumber = 3                  //排序类型 1. 名字升序， 2. 名字降序， 3. 分类升序， 4. 分类降序， 5. 价格升序， 6. 价格降序
    var requestTask: DataRequest?                //请求任务
    
    let cellIdentifier = "ServiceCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if addServiceType == .AddCheapen {
            serviceType = 3
        }
        
        prepareNavigationItem()
        prepareNoDateView("暂无施工")
        prepareTableView()
        prepareMenuView()
        prepareMaskBtn()
        
        if rowsData.count <= 0 && !(tableView.mj_header?.isRefreshing ?? false ) {
            tableView.mj_header?.beginRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if rightMenuView.isHidden == false {
            rightMenuView.hiddenMenu()
        }
    }
    
    //MARK: - 按钮事件
    
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
    
    @objc func cancelAction() {
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelSearchAction() {
        
        AppLog("点击了取消搜索")
        maskBtn.isHidden = true
        searchBar.resignFirstResponder()
    }
    //跳转购物车
    @objc func goCartAction() {
        
        let viewController = ShopCartViewController()
        viewController.isRootVC = false
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    @objc func screenAction(_ btn:UIButton) {
        AppLog("点击了筛选")
        
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
        
        if rightMenuView.isHidden == true {
           
            rightMenuView.showMenu()
            rightMenuView.selectedBlock = { [weak self] (categoryType) in
                
                self?.category = ""
                if let typeValue = categoryType {
                    self?.category = typeValue
                }
                if self?.category == "" {
                    btn.setImage(UIImage(named: "shop_filter"), for: .normal)
                }else {
                    btn.setImage(UIImage(named: "shop_filter_red"), for: .normal)
                }
                self?.mjReloadData()
            }
            

        }else {
            rightMenuView.hiddenMenu()
        }
        
    }
    
    //刷新列表
    func mjReloadData() {
        
        if tableView.mj_header?.isRefreshing ?? false {
            tableView.mj_header?.endRefreshing()
        }
        self.pleaseWait()
        headerRefresh()
    }
    
    //MARK: - 网络加载
    
    func loadData() {
        requestTask?.cancel()
        
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        let pageSize = 40
        
        var parameters: Parameters = ["store.id": storeID, "name": searchName, "category": category, "sortType": sortType, "type": serviceType, "pageSize": "\(pageSize)", "pageNo": "\(self.curPage)"]
        
        if beginCusPrice != nil {
            parameters["beginCusPrice"] = NSNumber(value: beginCusPrice!)
        }
        
        if endCusPrice != nil {
            parameters["endCusPrice"] = NSNumber(value: endCusPrice!)
        }
        
        let urlStr = APIURL.getComService
        
        requestTask = YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            self.spinnerStop()
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" || errorCode == "015" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<ServiceModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
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
            
            self.spinnerStop()
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.tableView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ServiceCell
        cell.serviceModel = rowsData[indexPath.row]
        cell.addServiceType = addServiceType
        
        cell.addServiceBlock = { [weak self] in
            let serviceModel = self?.rowsData[indexPath.row]
            
            if let block = self?.addServiceBlock {
                if self?.addServiceType == .AddRoutine {
                    serviceModel?.serviceType = 2
                }
                else {
                    serviceModel?.serviceType = 3
                }
                
                block(serviceModel!)
            }
        }
        
        return cell
    }
    
    
    //MARK: - SearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        AppLog("searchBar: \(searchText)")
        performSearch(with: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        maskBtn.isHidden = false
        if rightMenuView.isHidden == false {
            rightMenuView.hiddenMenu()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        maskBtn.isHidden = true
    }
    
    // 搜索触发事件，点击虚拟键盘上的search按钮时触发此方法
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        performSearch(with: searchBar.text!)
    }
    
    // 取消按钮触发事件
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 搜索内容置空
        spinnerStop()
        searchName = ""
        searchBar.text = ""
        headerRefresh()
        searchBar.resignFirstResponder()
    }
    
    //搜索框输入文字的时候自动搜索
    let intervalGuard = ActionIntervalGuard()
    
    func performSearch(with searchText: String) {
        
        if searchText.count >= 0 {
            
            searchName = searchText
            intervalGuard.perform(interval: 0.6) {[weak self] in
                guard let this = self else { return }
                this.spinnerStart()
                this.headerRefresh()
            }
            
        }else{
            spinnerStop()
        }
    }
    
    //活动指示器动画
    func spinnerStart() {
        spinner.startAnimating()
        searchBar.setImage(UIImage(), for: .search, state: .normal)
    }
    
    func spinnerStop() {
        spinner.stopAnimating()
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
    }
}
