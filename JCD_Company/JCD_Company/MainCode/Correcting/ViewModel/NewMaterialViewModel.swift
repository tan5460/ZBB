//
//  NewMaterialViewModel.swift
//  YZB_Company
//
//  Created by Mac on 18.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

@objc protocol NewMaterialViewModelDelegate {
    
    func clearNotice()
    func showWait()
    func endRefreshing()
    
    func updateLeftSelectView()
    func updateTopSelectView()
    func alertSuccess(_ text: String, autoClear: Bool, autoClearTime: Float)
    
    // 刷新搜索栏
    func updateSearchBar()
    
    // 隐藏
    func hiddenFiltrate()
    
    // 更新顶部标签栏
    func updateTopViewUI()
    func updateTopViewUINotNeedIndex()

    // 显示更多数据
    func showNormoreData()
    
    // 更新主材
    func reloadUI()
    
    func updateBrandUI()
    
    func alert(_ text: String)
    
    func noneMoreData()
}

private protocol NewMaterialViewModelInterface {
    var delegate: NewMaterialViewModelDelegate! {get}
    
    var leftData: [BrandHouseModel]!  { get }
    var leftItems: [String]! { get }
    var topItems: [String]! { get }
    var itemsData: [MaterialsModel]! { get }
    var searchName: String {get}
    var category: BrandHouseModel! {get}// 左视图 - 当前选中model

    func headerRefresh()
    func footerRefresh()
    
    /// 搜索回调
    var searchBlock: ((_ searchString: String)->())? {set get}
    
    /// 左边列表选中回调
    var leftSelectedBlock: ((_ indexPath: IndexPath)->())? {get set}

    /// 顶部列表选中回调
    var topSelectedBlock: ((_ indexPath: IndexPath)->())? {set get}
    
    /// 列表筛选
    var filtrateSelectedBlock: ((_ merchantModel: BrandListItem?)->())? { set get}

    
    /// //是否添加主材
    var isAddMaterial: Bool { set get }
    
    // 是否显示normore视图
    var isHiddenNoMoreData: Bool { get }
    
    // 显示更多数据
    var showMoreData: Bool { get }
}

class NewMaterialViewModel: NSObject {
    
    var showMoreData: Bool {
        get {
            return pShowMoreData
        }
    }
    
    var searchName: String {
        get {
            return pSearchName
        }
    }
    
    var secondItems: [BrandListItem]! {
        get {
            return filtrateDatas
        }
    }
    
    var category: BrandHouseModel! {
        get {
            return pCategory
        }
    }// 左视图 - 当前选中model

    var isHiddenNoMoreData: Bool {
        get {
            return pIsHiddenNoMoreData
        }
    }
    
    weak var delegate: NewMaterialViewModelDelegate!
    var itemsData: [MaterialsModel]!
    var searchBlock: ((_ searchString: String)->())?
    var leftSelectedBlock: ((_ indexPath: IndexPath)->())?
    var topSelectedBlock: ((_ indexPath: IndexPath)->())?
    var filtrateSelectedBlock: ((_ merchantModel: BrandListItem?)->())?
    var isAddMaterial: Bool = false

    private var pShowMoreData = false
    private var pIsHiddenNoMoreData = false
    private var topItemData: [NewMaterialRightTopModel]!
    private var pLeftData: [BrandHouseModel]!
    private var curPage = 1
    var brandName = ""                  //品牌名
    private var beginPriceCustom: Float?        //价格筛选低
    private var endPriceCustom: Float?          //价格筛选高
    private var pSearchName: String = ""         //搜索类容
    private var pCategory: BrandHouseModel! // 左视图 - 当前选中model
    private var sortType: NSNumber = 4          //排序类型 1. 销量降序， 2. 价格降序， 3. 价格升序， 4. 时间降序
    private var materialsType: NSNumber = 1     //主材类型 1. 全部主材  2. 系统主材  3. 自建主材
    private var isOneSell: NSNumber = 0
    private var requestTask: DataRequest?       //请求任务
    private var rightTopModel: NewMaterialRightTopModel!// 右视图 - 默认全部
    private var isFirstLoad = true         // 第一次加载
    private var filtrateDatas: [BrandListItem]? // 品牌数据
    private var allCategoryId: String!
    
    override init() {
        super.init()
        
        searchBlock = {[weak self] (searchString) in
            self?.pSearchName = searchString
            self?.delegate?.updateSearchBar()
            self?.loadData()
        }
        
        leftSelectedBlock = {[weak self] indexPath in
            self?.delegate?.hiddenFiltrate()
            if let model = self?.pLeftData?[indexPath.item] {
                self?.pCategory = model
                self?.allCategoryId = model.categoryId
                self?.rightTopModel = nil
                self?.delegate?.updateTopViewUI()
                self?.loadRightTopViewData(model)
                self?.brandName = ""
                self?.curPage = 1
                self?.loadData()
            }
        }
        topSelectedBlock = {[weak self] indexPath in
            self?.delegate?.hiddenFiltrate()
            if let model = self?.topItemData[indexPath.item] {
                self?.curPage = 1
                if indexPath.item == 0 {
                    self?.rightTopModel = nil
                }
                else {
                    self?.rightTopModel = model
                }
                
                self?.requestSecondCategoryData()
                self?.delegate?.updateTopViewUINotNeedIndex()
                self?.brandName = ""
                self?.loadData()
            }
        }
        
        filtrateSelectedBlock = {[weak self] (merchantModel) in
            
            if let valueStr = merchantModel?.brandName, valueStr != "全部品牌" {
                self?.brandName = valueStr
            }else {
                self?.brandName = ""
            }
            self?.curPage = 1
            self?.delegate.updateBrandUI()
            self?.loadData()
        }
    }
    
    //MARK: - 网络请求
    ///获取二级分类
    private func requestSecondCategoryData() {
        
        var categoryId = allCategoryId ?? ""
        if let cateId = self.rightTopModel?.id {
            categoryId = cateId
        }
        let parameters: Parameters = [
            "categoryId": categoryId,
            "substationId": UserData.shared.workerModel?.store?.citySubstation ?? ""
        ]
        
        delegate?.clearNotice()
        delegate?.showWait()
        let urlStr = APIURL.secondCategoryList
        AppLog(parameters)
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
        
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<BrandListItem>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.filtrateDatas = modelArray
                self.delegate?.updateTopViewUINotNeedIndex()
            }
            else if errorCode == "008" {
                
                self.filtrateDatas = []
                self.delegate?.updateTopViewUINotNeedIndex()
            }
            
        }) { (error) in }

    }
    
    
    ///获取左边视图所有分类
    private func requestFindListByCategoryData() {
        
        var substationId = ""
        if let valueStr = UserData.shared.workerModel?.substation?.id {
            substationId = valueStr
        }
        
        let parameters: Parameters = ["substationId": substationId]
        
        delegate?.clearNotice()
        delegate?.showWait()
        let urlStr = APIURL.findListByCategory
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<BrandHouseModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                self.pLeftData = modelArray
                self.delegate?.updateLeftSelectView()
                self.leftSelectedBlock?(NSIndexPath.init(item: 0, section: 0) as IndexPath)
            }
           
        }) { (error) in
        }
        
    }
    
    /// 获取主材
    private func loadData() {
        requestTask?.cancel()
        
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        var cityID = ""
        if let valueStr = UserData.shared.workerModel?.store?.city?.id {
            cityID = valueStr
        }
        
        var substationId = ""
        if let valueStr = UserData.shared.workerModel?.substation?.id {
            substationId = valueStr
            
        }
        
        let pageSize = IS_iPad ? 21 : 20
        
        var parameters: Parameters = [:]
        
        var brandNames = ""
        var brandList: [BrandListItem] = []
        brandList = category?.brandList ?? []
        
        for brandModel in brandList {
            if let name = brandModel.brandName, name != "" {
                if brandNames == "" {
                    brandNames = name
                }else {
                    brandNames += ",\(name)"
                }
            }
        }
        
        var categoryId = category?.categoryId ?? ""
        if rightTopModel != nil {
            categoryId = rightTopModel.id ?? ""
        }
        
        parameters["pageNo"] = "\(self.curPage)"
        parameters["pageSize"] = "\(pageSize)"
        parameters["name"] = searchName
        parameters["brand.brandName"] = brandName
        parameters["city.id"] = cityID
        parameters["sortType"] = sortType
        parameters["store.id"] = storeID
        //parameters["materialsType"] = materialsType
        parameters["isOneSell"] = ""
        parameters["substationId"] = substationId
        parameters["category"] = categoryId
        
        if isOneSell == 1 {
            parameters["isOneSell"] = isOneSell
        }
        
        if beginPriceCustom != nil {
            parameters["beginPriceShow"] = NSNumber(value: beginPriceCustom!)
        }
        
        if endPriceCustom != nil {
            parameters["endPriceShow"] = NSNumber(value: endPriceCustom!)
        }
        
        AppLog(">>>>>>>>>>>>> 分类筛选: \(parameters)")
        
        let urlStr = APIURL.getMaterials
        
        requestTask = YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { [unowned self](response) in
            
            //结束刷新
            self.delegate?.endRefreshing()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage > 1 {
                    self.itemsData += modelArray
                }
                else {
                    self.itemsData = modelArray
                }
                
                self.pShowMoreData = modelArray.count >= pageSize
                
            }else if errorCode == "008" {
                self.itemsData?.removeAll()
            }
            else if errorCode == "015" { // 超出记录
                self.pShowMoreData = false
            }
            
            self.pIsHiddenNoMoreData = self.itemsData?.count ?? 0 > 0
            self.delegate?.reloadUI()

        }) { (error) in
            
            //结束刷新
            self.pIsHiddenNoMoreData = self.itemsData?.count ?? 0 > 0
            self.delegate?.endRefreshing()
            self.delegate?.reloadUI()
        }
    }
    
    /// 加载右视图顶部视图数据
    private func loadRightTopViewData(_ withLeftModel: BrandHouseModel) {
        
//        let parameters: Parameters = [
//            "parent.id": withLeftModel.categoryId ?? "0",
//            "pageSize": "500"]
//        
//        delegate?.clearNotice()
//        delegate?.showWait()
//        let urlStr = APIURL.getMaterialsCategory
//        
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" {
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                let modelArray = Mapper<NewMaterialRightTopModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                self.topItemData = modelArray
//                self.topItemData.insert(NewMaterialRightTopModel(), at: 0)
//                self.delegate?.updateTopSelectView()
//            }
//           
//        }){ (error) in
//        }
    }
}

extension NewMaterialViewModel: NewMaterialViewModelInterface {
    
    
    var topItems: [String]! {
        get {
            return topItemData?.map{$0.name ?? ""} ?? []
        }
    }
    
    var leftItems: [String]! {
        get {
            return pLeftData?.map{$0.categoryName ?? ""} ?? []
        }
    }
    
    func headerRefresh() {
        AppLog("下拉刷新")
        
        if isFirstLoad {
            isFirstLoad = false
            // 1.加载左边分类
            requestFindListByCategoryData()
            // 2.请求成功后，加载右边主材数据
            return
        }
        
        curPage = 1
        loadData()
    }
    
    func footerRefresh() {
        AppLog("上拉加载")
        
        if itemsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    
    var leftData: [BrandHouseModel]! {
        get {
            return pLeftData
        }
    }
    
    
}
// MARK: - CGYCollectionViewCellDelegate
extension NewMaterialViewModel: CGYCollectionViewCellDelegate {
    
    ///查询是否已经加入预购
    func checkIsAdded(_ model: MaterialsModel!) {
        
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        guard let workerId = UserData.shared.workerModel?.id else{
            delegate?.alert("参数异常")
            return
        }
        
        let parameters: Parameters = ["storeId": storeID, "id": model!.id!, "workerId": workerId]
        
        delegate?.clearNotice()
        let urlStr = APIURL.isAddPurchase
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {

                let isExist = Utils.getReadString(dir: response["body"] as! NSDictionary, field: "isExist")
                if isExist == "1" { // 已加入
                    self.delegate?.alert("已加入预购清单")
                }
                else {
                }
                
            }
            
        }) { (error) in
            
        }
    }
    
    func addPurchase(_ model: MaterialsModel!) {
        
        checkIsAdded(model)
    }
    
  
}
