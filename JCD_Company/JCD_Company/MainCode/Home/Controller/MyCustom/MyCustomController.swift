//
//  MyCustomController2.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/11/23.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import ObjectMapper
import PopupDialog

class MyCustomController: BaseViewController, UITableViewDelegate, UITableViewDataSource ,UISearchBarDelegate{
    var selectedHouseBlock: ((_ houseModel: HouseModel?)->())?      //选择工地block
    var searchBar: UISearchBar!                 //搜索
    var maskBtn: UIButton!                      //搜索时遮罩按钮
    let spinner = UIActivityIndicatorView(style: .gray)        //活动指示器
    var searchName: String = ""                 //搜索类容
    var collectionView: UICollectionView!
    var tableView: UITableView!
    var rowsData: Array<CustomModel> = []
    var curPage = 1
    let identifier = "CustomCell"
    
    var isSelectCustom : Bool = false           //是否是选择客户
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        prepareNavigationItem()
        prepareNoDateView("暂无客户")
        prepareTableViewView()
        
        //        if isSelectCustom == true {
        prepareSearchBarView()
        //        }
        
        //开始刷新
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        if isSelectCustom == true {
        navigationController?.navigationBar.shadowImage = UIImage()
        //        }
        if !(tableView.mj_header?.isRefreshing  ?? false ) {
            headerRefresh()
        }
    }
    
    func prepareNavigationItem() {
        
        //新增
        let addBtn = UIButton(type: .custom)
        addBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        addBtn.setTitle("添加", for: .normal)
        addBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        addBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        addBtn.addTarget(self, action: #selector(addNewAction), for: .touchUpInside)
        
        let addItem = UIBarButtonItem.init(customView: addBtn)
        navigationItem.rightBarButtonItems = [addItem]
    }
    
    func prepareSearchBarView() {
        
        let topView = UIView()
        topView.backgroundColor = .white
        view.addSubview(topView)
        
        topView.layerShadow()
        
        topView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(50)
        }
        
        //搜索栏
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "请输入客户姓名或手机号"
        topView.addSubview(searchBar)
        
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
        
        searchBar.backgroundImage = UIColor.white.image()
        searchBar.backgroundColor = .white
        
        let textfield = searchBar.textField
        textfield?.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF0F0F0)
        textfield?.layer.cornerRadius = 18
        textfield?.layer.masksToBounds = true
        textfield?.font = UIFont.systemFont(ofSize: 13)
        textfield?.textColor = PublicColor.commonTextColor
        
        searchBar.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }
        
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
        
        //搜索时蒙版遮罩
        maskBtn = UIButton(type: .custom)
        maskBtn.isHidden = true
        maskBtn.backgroundColor = UIColor.init(white: 0.1, alpha: 0.1)
        maskBtn.addTarget(self, action: #selector(cancelSearchAction), for: .touchUpInside)
        self.view.addSubview(maskBtn)
        
        maskBtn.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(50)
        }
    }
    
    func prepareTableViewView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 76
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.register(MyCustomCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        //        let h = isSelectCustom ? 50 : 0
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(50)
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
    //取消搜索
    @objc func cancelSearchAction() {
        
        AppLog("点击了取消搜索")
        maskBtn.isHidden = true
        searchBar.resignFirstResponder()
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
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    @objc func addNewAction() {
        if self.isSelectCustom == true {
            let vc = AddHousesController()
            vc.title = "添加客户工地"
            vc.selectedHouseBlock = { [weak self] (houseModel) in
                self?.selectedHouseBlock?(houseModel)
            }
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = AddCustomerController()
        vc.title = "添加客户"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - 加载数据
    func loadData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeID = valueStr
        }
        var jobType = ""
        if let valueStr = UserData.shared.workerModel?.jobType?.stringValue {
            jobType = valueStr
        }
        
        let pageSize = 20
        var parameters: Parameters = ["size": "\(pageSize)", "current": "\(self.curPage)", "storeId": storeID, "workerId": userId, "jobType": UserData.shared.userType]
        if UserData.shared.workerModel?.jobType == 4 || UserData.shared.workerModel?.jobType == 999 {
            parameters.removeValue(forKey: "worker")
        }
        
        //        if isSelectCustom == true {
        var realName = ""
        var mobile = ""
        let expression = "^[0-9]*$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: searchName, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (searchName as NSString).length))
        
        if numberOfMatches == 0 {
            realName = searchName
        }else {
            mobile = searchName
        }
        parameters["realName"] = realName
        parameters["mobile"] = mobile
        //        }
        
        let urlStr =  APIURL.getCompanyCustom
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            //            if self.isSelectCustom == true {
            self.spinnerStop()
            //            }
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<CustomModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
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
            //            if self.isSelectCustom == true {
            self.spinnerStop()
            //            }
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MyCustomCell
        
        let cellModel = rowsData[indexPath.row]
        cell.customModel = cellModel
        if isSelectCustom == false {
            cell.telBtn.isHidden = false
            //打电话
            cell.callPhoneBlock = { [weak self] in
                
                var name = "姓名未填"
                if let valueStr = cellModel.realName {
                    name = valueStr
                }
                
                var phone = ""
                if let valueStr = cellModel.tel {
                    phone = valueStr
                }
                self?.houseListCallTel(name: name, phone: phone)
            }
        }else {
            cell.telBtn.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelectCustom == false  {
            
            let vc = AddCustomerController()
            vc.title = "客户信息"
            vc.userModel = rowsData[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }else {
            
            let vc = AddHousesController()
            vc.title = "添加客户工地"
            vc.selectedHouseBlock = { (houseModel) in
                self.selectedHouseBlock?(houseModel)
            }
            vc.userModel = rowsData[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    //左滑删除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let cellModel = rowsData[indexPath.row]
        var name = ""
        if let valueStr = cellModel.realName {
            name = valueStr
        }
        
        let popup = PopupDialog(title: "提示", message: "是否删除客户'\(name)'？",buttonAlignment: .horizontal)
        let sureBtn = DestructiveButton(title: "删除") {
            let parameters: Parameters = ["ids": cellModel.id!]
            self.pleaseWait()
            let urlStr =  APIURL.customDel
            YZBSign.shared.request(urlStr, method: .delete, parameters: parameters, success: { (response) in
                
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                if errorCode == "0" {
                    self.rowsData.remove(at: indexPath.row)
                    self.tableView.reloadData()
                    self.noticeSuccess("删除成功")
                    if self.rowsData.count <= 0 {
                        self.tableView.mj_footer?.isHidden = true
                        self.noDataView.isHidden = false
                    }else {
                        self.tableView.mj_footer?.isHidden = false
                        self.noDataView.isHidden = true
                    }
                }
                
            }) { (error) in
                
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    
    //MARK: - SearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        AppLog("searchBar: \(searchText)")
        performSearch(with: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        maskBtn.isHidden = false
        
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
        if searchBar != nil {
            searchBar.setImage(UIImage(), for: .search, state: .normal)
        }
    }
    
    func spinnerStop() {
        spinner.stopAnimating()
        if searchBar != nil {
            searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
        }
    }
}
