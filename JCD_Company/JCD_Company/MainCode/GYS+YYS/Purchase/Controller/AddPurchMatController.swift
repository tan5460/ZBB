//
//  AddPurchMatController.swift
//  YZB_Company
//
//  Created by yzb_ios on 19.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import ObjectMapper

class AddPurchMatController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var tableView: UITableView!
    var searchBar: UISearchBar!                 //搜索
    var searchStr = ""                          //搜索字段
    var curPage = 1                             //页码
    var rowsData: Array<MaterialsModel> = []
    var requestTask: DataRequest?               //请求任务
    var isFirstLoad = true                      //第一次请求
    
    var doneHandler: (() -> Void)?
    
    var orderId = ""
    var storeId = ""
    var merchantId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNoDateView("暂无可添加产品～")
        prepareNavigationItem()
        prepareTableView()
        
        if isFirstLoad {
            isFirstLoad = false
            mjReloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func prepareNavigationItem() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        //搜索栏
        searchBar = UISearchBar(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth-50, height: 40))
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = "搜索"
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
        
        searchBar.text = searchStr
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 116
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = PublicColor.partingLineColor
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        tableView.tableFooterView = UIView()
        tableView.register(AddPurchMatCell.self, forCellReuseIdentifier: AddPurchMatCell.self.description())
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
    
    //刷新列表
    @objc func mjReloadData() {
        
        if tableView.mj_header?.isRefreshing ?? false {
            tableView.mj_header?.endRefreshing()
        }
        
        rowsData.removeAll()
        tableView.reloadData()
        
        self.clearAllNotice()
        self.pleaseWait()
        headerRefresh()
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
    
    func loadData() {
        
        requestTask?.cancel()
        let pageSize: Int = 20
        var parameters = Parameters()
        parameters["materialsName"] = searchStr
        parameters["merchantId"] = UserData.shared.merchantModel?.id
        
        let urlStr = APIURL.getSKUMaterials
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                var dataArray = [Any]()
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                if UserData.shared.userType == .yys {
                    let dataDic1 = Utils.getReadDic(data: dataDic, field: "page")
                    dataArray = Utils.getReadArr(data: dataDic1, field: "records") as! [Any]
                } else {
                    dataArray = Utils.getReadArr(data: dataDic, field: "records") as! [Any]
                }
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
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
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            
            if self.rowsData.count == 0 {
                self.noDataView.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.noDataView.isHidden = true
                self.tableView.isHidden = false
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: AddPurchMatCell.self.description(), for: indexPath) as! AddPurchMatCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        if indexPath.row == rowsData.count-1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: PublicSize.screenWidth, bottom: 0, right: 0)
        }
        let materialModel = rowsData[indexPath.row]
        cell.materialModel = materialModel
        
        cell.addBlock = { [weak self] in
            var parameters = Parameters()
            parameters["orderId"] = self?.orderId
            parameters["skuId"] = materialModel.id
            
            let urlStr = APIURL.addPurchaseMater
            self?.pleaseWait()
            
            YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
                
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                if errorCode == "0" {
                    self?.doneHandler?()
                    self?.noticeSuccess("添加成功")
                }
            }) { (error) in
                
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let materialModel = rowsData[indexPath.row]
        
//        let rootVC = MaterialDetailController()
//        rootVC.materialsModel = materialModel
//        let vc = BaseNavigationController.init(rootViewController: rootVC)
//        self.present(vc, animated: true, completion: nil)
        
        let rootVC = MaterialsDetailVC()
        rootVC.isDismiss = true
        
        let model = MaterialsModel()
        model.id = materialModel.materialsId
        rootVC.materialsModel = model
        let vc = BaseNavigationController.init(rootViewController: rootVC)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //MARK: - SearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let vc = CurrencySearchController()
        vc.searchString = searchBar.text
        vc.searchType = .purchMaterial
        
        vc.isSecondSearch = true
        vc.searchBlock = {[weak self] (searchString) in
            self?.searchBar.text = searchString
            self?.searchStr = searchString
            self?.isFirstLoad = true
            self?.loadData()
        }
        self.navigationController?.pushViewController(vc, animated: false)
        return false
    }
}
