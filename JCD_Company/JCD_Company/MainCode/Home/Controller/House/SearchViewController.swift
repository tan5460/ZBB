//
//  SearchViewController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2017/12/20.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import MJRefresh
import ObjectMapper

class DicResult: Equatable {
    
    let title: String
    let id: String
    let subTitle: String
    let subTitle2: String
    
    init(title: String,id: String, subTitle: String, subTitle2: String) {
        self.title = title
        self.id = id
        self.subTitle = subTitle
        self.subTitle2 = subTitle2
    }
    
    static func == (lhs: DicResult, rhs: DicResult) -> Bool {
        return lhs.id == rhs.id
    }
}


/// A Selector row, where user can pik address with autocomplete field
final class SearchRow: OptionsRow<PushSelectorCell<DicResult>>, PresenterRowType, RowType {
    
    typealias PresenterRow = SearchViewController
    
    /// Defines how the view controller will be presented, pushed, etc.
    var presentationMode: PresentationMode<PresenterRow>?
    
    /// Will be called before the presentation occurs.
    var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        cellStyle = .subtitle
        
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return SearchViewController.init(tag: tag!, callback: { vc in })
            
            },
            onDismiss: { vc in let _ = vc.navigationController?.popViewController(animated: true) }
        )
    }
    
    override func updateCell() {
        super.updateCell()
        
        cell.textLabel?.text = title //value?.title ?? title
        
        if value == nil {
            cell.detailTextLabel?.text = nil
        } else {
            cell.detailTextLabel?.text = value?.title//value?.subTitle
        }
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresenterRow else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}


class SearchViewController: BaseViewController, TypedRowControllerType, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate {

    var row: RowOf<DicResult>!
    var onDismissCallback: ((UIViewController) -> ())?
    
    var tagStr = ""
    let spinner = UIActivityIndicatorView(style: .gray)
    var resultSearchController: UISearchController!
    
    var tableView: UITableView!
    var customArray: Array<CustomModel> = []
    var merchantArray: Array<MerchantModel> = []
    var curPage = 1                                 //页码
    let identifier = "customerCell"
    var searchName = ""
    let intervalGuard = ActionIntervalGuard()       //延时调用类
    
    convenience public init(tag: String, callback: ((UIViewController) -> ())?) {
        self.init()
        self.tagStr = tag
        self.onDismissCallback = callback
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //添加
        let addBtn = UIButton(type: .custom)
        addBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        addBtn.setTitle("添加", for: .normal)
        addBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        addBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        addBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        let addItem = UIBarButtonItem.init(customView: addBtn)
        navigationItem.rightBarButtonItems = [addItem]
        
        if tagStr == "custom" {
            prepareNoDateView("暂无客户")
        }else if tagStr == "brands" {
            prepareNoDateView("暂无品牌")
        }
        prepareTableView()
        prepareSearchController()
        tableView.mj_header?.beginRefreshing()
        
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 64
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchCustomCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(0)
            }
            make.left.right.bottom.equalToSuperview()
        }
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        self.tableView.mj_footer = footer
        tableView.mj_footer?.isHidden = true
    }
    
    func prepareSearchController() {
        
        self.definesPresentationContext  = true
        
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.delegate = self
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.hidesNavigationBarDuringPresentation = false
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = resultSearchController
            navigationItem.hidesSearchBarWhenScrolling = false
            spinner.backgroundColor = UIColor.init(red: 241.0/255, green: 241.0/255, blue: 242.0/255, alpha: 1)
        } else {
            tableView.tableHeaderView = resultSearchController.searchBar
            spinner.backgroundColor = UIColor.white
        }
        
        spinner.stopAnimating()
        
        if let textField = resultSearchController.searchBar.subviews.first?.subviews.last {
            textField.addSubview(spinner)
            
            spinner.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(5)
                make.width.height.equalTo(20)
            }
        }
    }
    
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        
        if tagStr == "custom" {
            loadCustomData()
        }else if tagStr == "brands" {
            loadMerchantData()
        }
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        
        if tagStr == "custom" {
            
            if customArray.count > 0 {
                curPage += 1
            }
            else {
                curPage = 1
            }
            loadCustomData()
        }
        else if tagStr == "brands" {
            
            if merchantArray.count > 0 {
                curPage += 1
            }
            else {
                curPage = 1
            }
            loadMerchantData()
        }
    }
    
    @objc func addAction() {
        print("点击了添加")
        
        if tagStr == "brands" {
            
            let vc = AddComMerchantController()
            vc.title = "新增品牌商"
            
            vc.addMerchantBlock = { [weak self] merchantModel in
                
                var title = ""
                var customId = ""
                var subTitle = ""
                var subTitle2 = ""
                
                if let valueStr = merchantModel!.brandName {
                    title = valueStr
                }
                if let valueStr = merchantModel!.id {
                    customId = valueStr
                }
                if let valueStr = merchantModel!.name {
                    subTitle = valueStr
                }
                if let valueStr = merchantModel?.category?.id {
                    subTitle2 = valueStr
                }
                
                let resultDic:DicResult=DicResult(title: title, id: customId, subTitle: subTitle, subTitle2: subTitle2)
                self?.row.value = resultDic
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
        else if tagStr == "custom" {
            let vc = AddCustomerController()
            vc.title = "添加客户"
           
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - 加载数据
    func loadCustomData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        var jobType = ""
        if let valueStr = UserData.shared.workerModel?.jobType?.stringValue {
            jobType = valueStr
        }
        
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
        
        let pageSize = 20
        let parameters: Parameters = ["realName": realName, "mobile": mobile, "pageSize": "\(pageSize)", "pageNo": "\(self.curPage)", "store": storeID, "worker": userId, "jobType": jobType]
        
        AppLog(parameters)
        
        let urlStr = APIURL.getCompanyCustom
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            self.spinnerStop()
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CustomModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage > 1 {
                    self.customArray += modelArray
                }
                else {
                    self.customArray = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }
                
                self.tableView.reloadData()
            }
            
            if self.customArray.count <= 0 {
                self.noDataView.isHidden = false
                self.tableView.mj_footer?.isHidden = true
            }else {
                self.noDataView.isHidden = true
            }
            
        }) { (error) in
            
            self.spinnerStop()
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            if self.customArray.count <= 0 {
                self.noDataView.isHidden = false
                self.tableView.mj_footer?.isHidden = true
            }else {
                self.noDataView.isHidden = true
                self.tableView.mj_footer?.isHidden = false
            }
        }
    }
    
    func loadMerchantData() {
        
//        var storeID = ""
//        if let valueStr = UserData.shared.workerModel?.store?.id {
//            storeID = valueStr
//        }
//        
//        let pageSize = 20
//        let parameters: Parameters = ["brandName": searchName, "store": storeID, "pageSize": "\(pageSize)", "pageNo": "\(self.curPage)"]
//        
//        AppLog(parameters)
//        
//        let urlStr = APIURL.getComMerchant
//        
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//            
//            self.spinnerStop()
//            
//            // 结束刷新
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
//            self.tableView.mj_footer?.isHidden = false
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" {
//                
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                let modelArray = Mapper<MerchantModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                
//                if self.curPage > 1 {
//                    self.merchantArray += modelArray
//                }
//                else {
//                    self.merchantArray = modelArray
//                }
//                
//                if modelArray.count < pageSize {
//                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//                }else {
//                    self.tableView.mj_footer?.resetNoMoreData()
//                }
//            }
//            else if errorCode == "008" {
//                self.merchantArray.removeAll()
//            }
//            
//            self.tableView.reloadData()
//            
//            if self.merchantArray.count <= 0 {
//                self.noDataView.isHidden = false
//                self.tableView.mj_footer?.isHidden = true
//            }else {
//                self.noDataView.isHidden = true
//            }
//            
//        }) { (error) in
//            
//            self.spinnerStop()
//            
//            // 结束刷新
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
//            self.tableView.mj_footer?.isHidden = false
//            
//            if self.merchantArray.count <= 0 {
//                self.noDataView.isHidden = false
//                self.tableView.mj_footer?.isHidden = true
//            }else {
//                self.noDataView.isHidden = true
//                self.tableView.mj_footer?.isHidden = false
//            }
//        }
    }
    
    // MARK: - UISearchResultsUpdating
    //搜索框输入文字的时候自动搜索
    func performSearch(with searchText: String?) {
        if((searchText?.count)! > -1){
            searchName=searchText!
            intervalGuard.perform(interval: 0.6) {[weak self] in
                guard let this = self else { return }
                this.spinnerStart()
                this.headerRefresh()
            }
        }else{
            spinnerStop()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        performSearch(with: searchController.searchBar.text)
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        AppLog("已经弹出搜索")

    }
    //活动指示器动画
    func spinnerStart() {
        spinner.startAnimating()
        resultSearchController.searchBar.setImage(UIImage(), for: .search, state: .normal)
    }
    
    func spinnerStop() {
        spinner.stopAnimating()
        resultSearchController.searchBar.setImage(nil, for: .search, state: .normal)
    }
    
    //MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tagStr == "custom" {
            return customArray.count
        }else if tagStr == "brands" {
            return merchantArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SearchCustomCell
        cell.nameLabel.textColor = PublicColor.commonTextColor
        
        if tagStr == "custom" {
            let model = customArray[indexPath.row]
            cell.customModel = model
            
            if let rowData = row.value {
                if model.id == rowData.id {
                    cell.nameLabel.textColor = PublicColor.emphasizeTextColor
                }
            }
            
        }else if tagStr == "brands" {
            let model = merchantArray[indexPath.row]
            cell.merchantModel = model
            
            if let rowData = row.value {
                if model.id == rowData.id {
                    cell.nameLabel.textColor = PublicColor.emphasizeTextColor
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        var title = ""
        var customId = ""
        var subTitle = ""
        var subTitle2 = ""
        
        if tagStr == "custom" {
            let model = customArray[indexPath.row]
            
            if let valueStr = model.realName {
                title = valueStr
            }
            if let valueStr = model.id {
                customId = valueStr
            }
            if let valueStr = model.tel {
                subTitle = valueStr
            }
            if let valueStr = model.sex?.intValue {
                if valueStr > 0 && valueStr <= AppData.sexList.count {
                    let array = Utils.getFieldArrInDirArr(arr: AppData.sexList, field: "label")
                    subTitle2 = array[valueStr-1]
                }
            }
            
        }else if tagStr == "brands" {
            
            let model = merchantArray[indexPath.row]
            if let valueStr = model.brandName {
                title = valueStr
            }
            if let valueStr = model.id {
                customId = valueStr
            }
            if let valueStr = model.name {
                subTitle = valueStr
            }
            if let valueStr = model.category?.id {
                subTitle2 = valueStr
            }
        }
        
        let resultDic:DicResult=DicResult(title: title, id: customId, subTitle: subTitle, subTitle2: subTitle2)
        
        row.value = resultDic
        onDismissCallback?(self)
    }

}
