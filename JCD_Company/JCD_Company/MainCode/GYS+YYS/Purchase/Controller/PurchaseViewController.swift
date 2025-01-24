//
//  PurchaseViewController.swift
//  YZB_Company
//
//  Created by yzb_ios on 9.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import ObjectMapper

class PurchaseViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    enum OrderDetailType {
        case cg
        case fw
    }
    var orderDetailType: OrderDetailType = .cg
    var tableView: UITableView!
    var searchBar: UISearchBar!                 //搜索
    var topView: UIView!                        //顶部栏
    var topBarView: UIView!                     //顶部选中条
    var topSelectBtnTag = 0                     //选择按钮Tag(0,1,2,3)
    var curPage = 1                             //页码
    var searchStr = ""                          //搜索字段
    var storeId = ""                            //店铺id
    var storeUserName = ""                      //店铺用户名
    var merchantId = ""                         //供应商id
    var merchantUserName = ""                   //供应商用户名
    var isSecondSearch = false                  //是否第二次搜索
    var requestTask: DataRequest?               //请求任务
    var isFirstLoad = true                      //第一次请求
    var isSendOrder = false                     //是否发送订单
    var sendOrderBlock: ((_ model:PurchaseOrderModel)->())?             // 发送订单block
    
    var btnArray = ["全部", "进行中", "已完成", "已失效"]
    
    var remoteType: LoginType!
    
    var rowsData: Array<PurchaseOrderModel> = []        //订单数据
    let identifier = "PurchaseCell"
    
    var isChatIn = false // 是否从聊天进入
    
    var sjsEnter: Bool {
        get {
            return UserData.shared.workerModel?.jobType != 999 && UserData.shared.workerModel?.jobType != 4 && UserData.shared.workerModel?.costMoneyLookFlag == "1"
        }
    }
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>> 采购订单界面释放 <<<<<<<<<<<<<<")
        GlobalNotificationer.remove(observer: self, notification: .purchaseRefresh)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if orderDetailType == .cg {
            self.title = "采购订单"
        } else if orderDetailType == .fw {
            self.title = "服务订单"
        }
        
        
        prepareNavigationItem()
        prepareTopView()
        prepareTableView()
        
        if isSecondSearch {
            topView.isHidden = true
            
            tableView.snp.remakeConstraints { (make) in
                make.top.left.right.bottom.equalToSuperview()
            }
        }
        GlobalNotificationer.add(observer: self, selector: #selector(mjReloadData), notification: .purchaseRefresh)
        
        prepareNoDateView("暂无数据")
        noDataView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mjReloadData()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func prepareNavigationItem() {
        
        if isSecondSearch {
            
            self.automaticallyAdjustsScrollViewInsets = false
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
            
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
            
        }else {
            //搜索
            let searchBtn = UIButton(type: .custom)
            searchBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            searchBtn.setImage(UIImage.init(named: "item_search"), for: .normal)
            searchBtn.addTarget(self, action: #selector(searchAction), for: UIControl.Event.touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: searchBtn)
        }
    }
    
    func prepareTopView() {
        
        topView = UIView()
        topView.backgroundColor = .white
        view.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(0)
            }
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
        
        if let sender = topView.viewWithTag(100+topSelectBtnTag) as? UIButton {
            
            let btnTitle = sender.titleLabel?.text
    
            let textWidth = btnTitle!.getLabWidth(font: (sender.titleLabel?.font)!)
            
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
        tableView.rowHeight = 190
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.register(UINib.init(nibName: "PurchaseCell", bundle: nil), forCellReuseIdentifier: identifier)
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
    
    //刷新列表
    @objc func mjReloadData() {
        
        if tableView.mj_header?.isRefreshing ?? false {
            tableView.mj_header?.endRefreshing()
        }
        
        rowsData.removeAll()
        tableView.reloadData()
        
        self.clearAllNotice()
        self.pleaseWait()
        self.tableView.mj_header?.beginRefreshing()
    }
    
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        
        if isChatIn {
            fetchData()
        }
        else {
            loadData()
        }
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        if rowsData.count > 0 {
            curPage += 1
        }else {
            curPage = 1
        }
        
        if isChatIn {
            fetchData()
        }
        else {
            loadData()
        }
    }
    
    //MARK: - 按钮事件
    @objc func backAction() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func searchAction() {
        
        let vc = CurrencySearchController()
        vc.isSecondSearch = false
        
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            vc.searchType = .jzPurchase
        case .gys:
            vc.searchType = .gysPurchase
        case .yys:
            vc.searchType = .yysPurchase
        case .fws:
            vc.searchType = .gysPurchase
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func topSwitchAction(_ sender: UIButton) {
        AppLog("点击了切换按钮")
        if sender.tag == 100+topSelectBtnTag {
            return
        }
        
        let btn = topView.viewWithTag(100+topSelectBtnTag) as! UIButton
        btn.isSelected = false
        sender.isSelected = true
        
        let btnTitle = sender.titleLabel?.text

        let textWidth = btnTitle!.getLabWidth(font: (sender.titleLabel?.font)!)

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
        topSelectBtnTag = tagValue
        
        tableView.mj_footer?.isHidden = true
        mjReloadData()
    }
    
    
    //MARK: - 加载数据
    ///从聊天窗口进入
    @objc private func fetchData() {
        requestTask?.cancel()
        let pageSize = 20
        var parameters: Parameters = ["keyWord": searchStr, "size": "\(pageSize)", "orderStatuss": ""]
        parameters["current"] = "\(self.curPage)"
        
        if UserData.shared.userType == .yys {
            if remoteType == .gys {
                parameters["merchantId"] = storeId
                parameters["workerId"] = ""
            }
            else {
                parameters["merchant.id"] = ""
                parameters["worker.id"] = storeId
            }
            parameters["substationId"] = UserData.shared.substationModel?.id ?? ""
        }
        else if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            parameters["merchantId"] = UserData.shared.merchantModel?.id ?? ""
            //parameters["substationId"] = UserData.shared.substationModel?.id ?? "" // 品牌商和服务商不需要传这个东西
            parameters["workerId"] = storeId
            if remoteType == .yys {
                parameters["workerId"] = ""
            }
        }
        else if UserData.shared.userType == .cgy {
            if  let worker = UserData.shared.workerModel, let valueStr = UserData.shared.storeModel?.id {
                parameters["storeId"] = valueStr
                if UserData.shared.workerModel?.jobType != 999 {
                    parameters["workerId"] = worker.id
                }
                else if UserData.shared.workerModel?.jobType == 999 {
                    parameters["workerId"] = ""
                }
            }
            if let valueStr = UserData.shared.substationModel?.id {
                parameters["substationId"] = valueStr
            }
            parameters["merchantId"] = storeId
            if remoteType == .yys {
                parameters["storeId"] = ""
                parameters["merchantId"] = ""
            }
            if orderDetailType == .cg {
                parameters["orderType"] = 1
            } else if orderDetailType == .fw {
                parameters["orderType"] = 2
            }
            
        }
        
        let urlStr = APIURL.getYYSPurchaseOrder
        
        requestTask = YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataDic1 = Utils.getReadDic(data: dataDic as AnyObject, field: "orderPage")
                let dataArray = Utils.getReadArr(data: dataDic1, field: "records")
                let modelArray = Mapper<PurchaseOrderModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
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
                self.noDataView.isHidden = self.rowsData.count > 0
                self.tableView.mj_footer?.isHidden = self.rowsData.count == 0
            }else if errorCode == "008" {
                self.rowsData.removeAll()
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
    
    //获取订单
    func loadData() {
        
        requestTask?.cancel()
        
        var orderStatus = ""
        switch topSelectBtnTag {
        case 1:
            orderStatus = "1,2,3,4,5,9,10"
        case 2:
            orderStatus = "6,7"
        case 3:
            orderStatus = "11"
        default:
            orderStatus = ""
        }
        
        let pageSize = 20
        var parameters: Parameters = ["keyWord": searchStr, "size": "\(pageSize)"]
        parameters["orderStatuss"] = orderStatus
        parameters["current"] = "\(self.curPage)"
        
        if UserData.shared.userType == .yys {
            parameters["merchantId"] = UserData.shared.merchantModel?.id
            parameters["storeId"] = UserData.shared.storeModel?.id
            parameters["substationId"] = UserData.shared.substationModel?.id
        }
        else if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            parameters["merchantId"] = UserData.shared.merchantModel?.id
            parameters["substationId"] = UserData.shared.substationModel?.id
            parameters["storeId"] = storeId
        }
        else if UserData.shared.userType == .cgy {
            if UserData.shared.workerModel?.jobType == 999 {
                parameters["workerId"] = UserData.shared.workerModel?.id
            }
            parameters["storeId"] = UserData.shared.storeModel?.id
           // parameters["substationId"] = UserData.shared.substationModel?.id
           // parameters["merchantId"] = merchantId
            if remoteType == .yys {
                parameters["storeId"] = ""
                parameters["merchantId"] = ""
            }
            
            if orderDetailType == .cg {
                parameters["orderType"] = 1
            } else if orderDetailType == .fw {
                parameters["orderType"] = 2
            }
        }
        
        let urlStr = APIURL.getYYSPurchaseOrder
        
        requestTask = YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataDic1 = Utils.getReadDic(data: dataDic as AnyObject, field: "orderPage")
                let dataArray = Utils.getReadArr(data: dataDic1, field: "records")
                let modelArray = Mapper<PurchaseOrderModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
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
                self.noDataView.isHidden = self.rowsData.count > 0
                self.tableView.mj_footer?.isHidden = self.rowsData.count == 0
            }else if errorCode == "008" {
                self.rowsData.removeAll()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PurchaseCell
        
        let orderModel = rowsData[indexPath.row]
        cell.puechaseOrderModel = orderModel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if sjsEnter { return }
        
        let orderModel = rowsData[indexPath.row]
        
        if isSendOrder {
            navigationController?.popViewController(animated: true)
            sendOrderBlock?(orderModel)
        }else {
            if orderDetailType == .cg {
                let vc = PurchaseDetailController()
                if let valueStr = orderModel.id {
                    vc.orderId = valueStr
                }
                vc.goBackBlock = { [weak self] model in
                    if let purchaseModel = model {
                        if self?.rowsData.count ?? 0 > 0 {
                            self?.rowsData.remove(at: indexPath.row)
                            self?.rowsData.append(purchaseModel)
                            self?.tableView.reloadData()
                        }
                    } else {
                        if self?.rowsData.count ?? 0 > 0 {
                            self?.rowsData.remove(at: indexPath.row)
                            self?.tableView.reloadData()
                        }
                    }
                }
                navigationController?.pushViewController(vc, animated: true)
            } else if orderDetailType == .fw {
                let vc = ServiceOrderDetailVC()
                if let valueStr = orderModel.id {
                    vc.orderId = valueStr
                }
                vc.goBackBlock = { [weak self] model in
                    if let purchaseModel = model {
                        if self?.rowsData.count ?? 0 > 0 {
                            self?.rowsData.remove(at: indexPath.row)
                            self?.rowsData.append(purchaseModel)
                            self?.tableView.reloadData()
                        }
                    } else {
                        if self?.rowsData.count ?? 0 > 0 {
                            self?.rowsData.remove(at: indexPath.row)
                            self?.tableView.reloadData()
                        }
                    }
                }
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    
    //MARK: - SearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let vc = CurrencySearchController()
        vc.searchString = searchBar.text
        vc.isSecondSearch = true
        vc.isSendOrder = isSendOrder
        
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            vc.searchType = .jzPurchase
        case .gys:
            vc.searchType = .gysPurchase
        case .yys:
            vc.searchType = .yysPurchase
        case .fws:
            vc.searchType = .gysPurchase
        }
        
        vc.searchBlock = {[weak self] (searchString) in
            self?.searchBar.text = searchString
            self?.searchStr = searchString
            self?.mjReloadData()
        }
        self.navigationController?.pushViewController(vc, animated: false)
        return false
    }
    

}
