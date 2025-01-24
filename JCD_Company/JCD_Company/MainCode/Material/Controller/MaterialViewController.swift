//
//  RetailViewController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/22.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import MJRefresh

class MaterialViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    var searchBar: UISearchBar!         //搜索
    var workBtn: UIButton!
    var completeBtn: UIButton!
    var toolView: UIView!               //工具条
    var systemBrandBtn: UIButton!       //系统品牌
    var buildBrandBtn: UIButton!        //自建品牌
    var singleBtn: UIButton!            //单品
    var collectionView: UICollectionView!
    var filtrateView: FiltrateView?
    var buildFiltrateView: FiltrateView?
    
    var itemsData: Array<MaterialsModel> = []
    var curPage = 1                     //页码
    var searchName: String = ""         //搜索类容
    var merchantId = ""                 //材料商id
    var brandId = ""                    //品牌id
    var brandName = ""                  //品牌名
    var beginPriceCustom: Float?        //价格筛选低
    var endPriceCustom: Float?          //价格筛选高
    
    var sortType: NSNumber = 4          //排序类型 1. 销量降序， 2. 价格降序， 3. 价格升序， 4. 时间降序
    var materialsType: NSNumber = 2     //主材类型 1. 全部主材  2. 系统主材  3. 自建主材
    var isOneSell: NSNumber = 0         //是否单卖 0. 非单品   1. 单品
    
    let cellIdentifier = "MaterialCell"
    
    var isAddMaterial: Bool = false     //是否添加主材
    var addMaterialBlock: ((_ materialModel: MaterialsModel)->())?
    var requestTask: DataRequest?       //请求任务
    
    var supCategory: CategoryModel!     //父分类
    var category: CategoryModel!        //分类
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 商城界面释放 <<<<<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        prepareNavigationItem()
        prepareNoDateView("暂无产品")
        prepareToolView()
        prepareCollectionView()
        
        prepareMenuView()
        
        category = CategoryModel()
        category.id = ""
        category.type = 0
        category.name = "全部分类"
        
        supCategory = CategoryModel()
        supCategory.id = "0"
        supCategory.type = 0
        supCategory.name = "全部分类"
        
        
        if itemsData.count <= 0 && !(collectionView.mj_header?.isRefreshing ?? false) {
            collectionView.mj_header?.beginRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if filtrateView?.isHidden == false {
            filtrateView?.hiddenMenu()
        }
        
        if buildFiltrateView?.isHidden == false {
            buildFiltrateView?.hiddenMenu()
        }
        
    
    }
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        
        curPage = 1
        collectionView.mj_footer?.endRefreshingWithNoMoreData()
        loadData()
        filtrateView?.loadMerchantData()
        buildFiltrateView?.loadSelfMerchantData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        
        if itemsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    
    //MARK: - 网络请求
    
    func loadData() {
        
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
        
        parameters["pageNo"] = "\(self.curPage)"
        parameters["pageSize"] = "\(pageSize)"
        parameters["name"] = searchName
//        parameters["merchant.id"] = merchantId
//        parameters["brand.id"] = brandId
        parameters["brand.brandName"] = brandName
        parameters["city.id"] = cityID
        parameters["sortType"] = sortType
        parameters["store.id"] = storeID
       // parameters["materialsType"] = materialsType
        parameters["isOneSell"] = ""
        parameters["substationId"] = substationId
        
        if isOneSell == 1 {
            parameters["isOneSell"] = isOneSell
        }
        
        if category.id == "0" {
            parameters["category"] = ""
        }else {
            parameters["category"] = category.id
        }
        
        if beginPriceCustom != nil {
            parameters["beginPriceShow"] = NSNumber(value: beginPriceCustom!)
        }
        
        if endPriceCustom != nil {
            parameters["endPriceShow"] = NSNumber(value: endPriceCustom!)
        }
        
        AppLog(">>>>>>>>>>>>> 分类筛选: \(parameters)")
        
        let urlStr = APIURL.getMaterials
        
        requestTask = YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            //结束刷新
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            self.collectionView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" || errorCode == "015" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage > 1 {
                    self.itemsData += modelArray
                }
                else {
                    self.itemsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.collectionView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.itemsData.removeAll()
            }
            
            self.collectionView.reloadData()
            
            if self.itemsData.count <= 0 {
                self.collectionView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
            
        }) { (error) in
            
            //结束刷新
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            
            if self.itemsData.count <= 0 {
                self.collectionView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.collectionView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
        }
    }
    
    //MARK: - 按钮事件
    
    @objc func cancelAction() {
        
        navigationController?.dismiss(animated: true, completion: nil)
    }

    
    @objc func scancodeAction() {
        
        let vc = ScanCodeController()
        vc.title = "产品二维码"
        vc.hidesBottomBarWhenPushed = true
        
        if isAddMaterial {
            vc.isScanAddShop = true
        }
        
        vc.selectBlock = { [weak self] materialsModel in
            
            if let block = self?.addMaterialBlock {
                block(materialsModel)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func workAction() {
        
        let vc = ServiceViewController()
        vc.title = "施工商城"
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //系统品牌
    @objc func systemBrandAction(_ sender: UIButton) {
        
        if buildFiltrateView?.isHidden == false {
            buildFiltrateView?.isHidden = true
            buildBrandBtn.isSelected = false
            buildFiltrateView!.menuView.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: -130)
                .scaledBy(x: 1, y: 0.01)
            buildFiltrateView!.opacityView.alpha = 0
        }
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected  {
            filtrateView?.showMenu()
            filtrateView?.selectedBlock = {[weak self] (merchantModel ,categoryModel) in
                
                if let mid = merchantModel?.id {
                    self?.merchantId = mid
                }
                if let valueStr = merchantModel?.brandName {
                    self?.brandName = valueStr
                }
//                self?.category = categoryModel
                
                sender.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
                var brandName = "系统品牌"
                if let brand = merchantModel?.brandName {
                    if brand != "全部品牌" {
                       brandName = brand
                    }
                }
                sender.set(image: UIImage.init(named: "down_arrows"), title: brandName, imagePosition: .right, additionalSpacing: 5, state: .normal)
                
                self?.buildFiltrateView?.emptyNormalSelcetData()
                self?.buildBrandBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
                self?.buildBrandBtn.set(image: UIImage.init(named: "down_arrows"), title: "自建品牌", imagePosition: .right, additionalSpacing: 5, state: .normal)
                
                self?.materialsType = 2
                self?.mjReloadData()
            }
        }else {
            filtrateView?.hiddenMenu()
        }
        

    }
    
    //自建品牌
    @objc func buildBrandAction(_ sender: UIButton) {
        
        if filtrateView?.isHidden == false {
            filtrateView?.isHidden = true
            systemBrandBtn.isSelected = false
            filtrateView!.menuView.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: -130)
                .scaledBy(x: 1, y: 0.01)
            filtrateView!.opacityView.alpha = 0
        }
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected  {
            buildFiltrateView?.showMenu()
            buildFiltrateView?.selectedBlock = {[weak self] (merchantModel ,categoryModel) in
                
                if let mid = merchantModel?.id {
                    self?.merchantId = mid
                }
                if let mid = merchantModel?.brandId {
                    self?.brandId = mid
                }
//                self?.category = categoryModel
                
                sender.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
                var brandName = "自建品牌"
                if let brand = merchantModel?.brandName {
                    if brand != "全部品牌" {
                        brandName = brand
                    }
                }
                sender.set(image: UIImage.init(named: "down_arrows"), title: brandName, imagePosition: .right, additionalSpacing: 5, state: .normal)
                
                self?.materialsType = 3
                
                self?.filtrateView?.emptyNormalSelcetData()
                
                self?.systemBrandBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
                self?.systemBrandBtn.set(image: UIImage.init(named: "down_arrows"), title: "系统品牌", imagePosition: .right, additionalSpacing: 5, state: .normal)
                
                self?.mjReloadData()
            }
        }else {
            buildFiltrateView?.hiddenMenu()
        }
    }
    
    //单品
    @objc func singleAction(_ sender: UIButton) {
        if filtrateView?.isHidden == false {
            filtrateView?.hiddenMenu()
        }
        if buildFiltrateView?.isHidden == false {
            buildFiltrateView?.hiddenMenu()
        }
        
        sender.isSelected = !sender.isSelected
        isOneSell = 0
        if sender.isSelected {
            isOneSell = 1
        }
        mjReloadData()
        itemsData.removeAll()
        collectionView.reloadData()
    }
    
    //刷新列表
    @objc func mjReloadData() {
        
        if collectionView.mj_header?.isRefreshing ?? false {
            collectionView.mj_header?.endRefreshing()
        }
        
        self.pleaseWait()
        headerRefresh()
    }
    
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MaterialCell
        cell.model = itemsData[indexPath.item]
        cell.isAddMaterial = isAddMaterial
        
        cell.addMaterialBlock = { [weak self] in
            let model = self?.itemsData[indexPath.row]
            
            if let block = self?.addMaterialBlock {
                block(model!)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = MaterialDetailController()
        if !isAddMaterial {
            vc.detailType = .addCart
        }
        else {
            vc.detailType = .addShop
            vc.selectBlock = { [weak self] materialsModel in
                
                if let block = self?.addMaterialBlock {
                    block(materialsModel)
                }
            }
        }
        vc.hidesBottomBarWhenPushed = true
        vc.materialsModel = itemsData[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: - SearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if filtrateView?.isHidden == false {
            filtrateView?.hiddenMenu()
        }
        if buildFiltrateView?.isHidden == false {
            buildFiltrateView?.hiddenMenu()
        }
        let vc = CurrencySearchController()
        vc.searchString = searchBar.text
        vc.isAddMaterial = isAddMaterial
        vc.merchantId = merchantId
        vc.brandId = brandId
        vc.addMaterialBlock = addMaterialBlock
        vc.searchBlock = {[weak self] (searchString) in
            
            self?.searchBar.text = searchString
            self?.searchName = searchString
            self?.mjReloadData()
        }
        self.navigationController?.pushViewController(vc, animated: false)
        return false
    }
}


