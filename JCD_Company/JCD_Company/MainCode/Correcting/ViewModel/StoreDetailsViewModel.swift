//
//  StoreDetailsViewModel.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/7.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

@objc protocol StoreDetailsViewModelDelegate {
    func toSearchVC()
    
    func updateUI()
    func updateUpsUI()
    func reloadMainUI()
    
    func showLoading()
    func hiddenLoading()
    
    func didClick(_ item: MaterialsModel!)
    
    func refresh() // 刷新
    func endRefresh()
    func endRefreshWithNoneMore()
    
    func clearNotice()
    func showWait()
    func alert(_ text: String)
    func alertSuccess(_ text: String, autoClear: Bool, autoClearTime: Float)
}

class StoreDetailsViewModel: NSObject {
    
    weak var delegate: StoreDetailsViewModelDelegate?
    
    var line1Show = true
    var line2Show = false
    var line3Show = false
    var priceIsNormal = true // 设置price 票房

    var sectionModel: HoStoreModel!
    var selectedModel: HoStoreModel!
    var selectedBrand: HoBrandModel!
    var selectedSpesub: HoSpecSubModel!
    
    var searchName: String?
    
    var itemsData = [MaterialsModel]()
    var brands: [HoBrandModel]! // 品牌数据
    var spes: [HoSpecModel]! // 规格数据
    // 默认选中
    var index = 10 {
        didSet {
            selectedModel?.isSelected = false
            selectedBrand?.isSelected = false
            selectedSpesub?.isSelected = false
        }
    }
    // 关闭 / 重置 标题
    var upsCloseTitle: String {
        get {
            return index == 10 ? "关闭" : "重置"
        }
    }
    var sjsFlag = false
    
    private var curPage = 1
    private var sortType = "1"
    
    private struct Constant {
        private static let screenW = UIScreen.main.bounds.size.width
        private static let screenH = UIScreen.main.bounds.size.height
        private static let itemWidth = screenW * 517 / 1125
        
        static let upsItemSize: CGSize = CGSize(width: screenW * 315 / 1125, height: screenH * 90 / 2436)
        static let itemSize: CGSize = CGSize(width: itemWidth, height: itemWidth + 63)
        
        static let upsTag = 10
        static let nTag = 20
    }
    
    func new() {
        line2Show = true
        line1Show = false
        sortType = "7"
        priceIsNormal = true
        delegate?.updateUI()
        delegate?.refresh()
    }
    
    func defaultA() {
        priceIsNormal = true
        line1Show = true
        line2Show = false
        sortType = "1"
        delegate?.updateUI()
        delegate?.refresh()
    }
    
    func sureUps() {
        delegate?.updateUI()
        headerRefresh()
    }
    
    func brandClick() {
        
        if brands == nil {
            delegate?.showLoading()
            requestBrandData()
        }
    }
    
    func headerRefresh() {
        self.curPage = 1
        loadData()
    }
       
    func footerRefresh() {
        self.curPage += 1
        loadData()
    }
    
    // 降序
    func down() {
        sortType = "3"
        line1Show = false
        line2Show = false
        delegate?.updateUI()
        delegate?.refresh()
    }
    
    // 升序
    func up() {
        sortType = "4"
        line1Show = false
        line2Show = false
        delegate?.updateUI()
        delegate?.refresh()
    }
    
    //MARK: - 网络请求
    /// 获取主材
    func loadData() {
        
        var cityID = ""
        if let valueStr = UserData.shared.storeModel?.cityId {
            cityID = valueStr
        }
        
        var substationId = ""
        if let valueStr = UserData.shared.substationModel?.id {
            substationId = valueStr
        }
        
        let pageSize = IS_iPad ? 21 : 20
        
        var parameters = ["current": "\(self.curPage)"]
        parameters["size"] = "\(pageSize)"
        parameters["name"] = searchName ?? ""
        parameters["brandName"] = selectedBrand?.brandName ?? ""
        parameters["cityId"] = cityID
        parameters["sortType"] = sortType
        //parameters["materialsType"] = "1"
        parameters["isOneSell"] = ""
        parameters["substationld"] = substationId
        parameters["categorycId"] = selectedModel?.id ?? ""
        if selectedSpesub?.id == "2" {
            parameters["customizeFlag"] = selectedSpesub?.id ?? ""
        } else {
            parameters["yzbSpecification.id"] = selectedSpesub?.id ?? ""
        }
        let urlStr = APIURL.getMaterials
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { [unowned self](response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if modelArray.count < pageSize {
                    self.delegate?.endRefreshWithNoneMore()
                }
                else {
                    self.delegate?.endRefresh()
                }
                
                if self.curPage > 1 {
                    self.itemsData += modelArray
                }
                else {
                    self.itemsData = modelArray
                }
                
                self.delegate?.reloadMainUI()
                
            }else if errorCode == "008" {
                // 无数据
                self.itemsData = []
                self.delegate?.reloadMainUI()
            }
            else if errorCode == "015" { // 超出记录
                self.delegate?.endRefresh()
            }
            else {
                self.delegate?.endRefresh()
            }

        }) { (error) in
            
            
        }
    }
    
    ///获取二级分类
    private func requestBrandData() {
        
//        let parameters = [
//            "categoryId": sectionModel?.id ?? "",
//            "substationId": UserData.shared.workerModel?.store?.citySubstation ?? ""
//        ]
        guard let categoryId = sectionModel.id else {
            UIApplication.shared.windows.first?.noticeOnlyText("分类数据异常，无法查询品牌")
            return
        }
        
        let urlStr = APIURL.secondCategoryBrandList + categoryId
        
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            
            self.delegate?.hiddenLoading()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<HoBrandModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.brands = modelArray
                let specArray = Mapper<HoSpecModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.spes = specArray
                self.delegate?.updateUpsUI()
            }
            else if errorCode == "008" {
                // 清空
                self.brands = []
                self.spes = []
                self.delegate?.updateUpsUI()
            }
            
        }) { (error) in }
        
    }
    
    // 获取选中三级分类品牌
    private var selectedBrands: [HoBrandModel] {
        get {
            var bras = [HoBrandModel]()
            
            brands?.forEach {
                if $0.brandType?.contains(selectedModel?.parent ?? "") ?? false {
                    bras.append($0)
                }
            }
            return bras
        }
    }
    
    // 获取选中三级分类规格
    private var selectedSpes: [HoSpecSubModel] {
        get {
            var bras = [HoSpecSubModel]()
            spes?.forEach {
                AppLog("ALL: \($0.category ?? "") selected: \(selectedModel.id ?? "")")
                
                if $0.category == selectedModel.id {
                    bras.append(contentsOf: $0.specificationDatas ?? [])
                }
            }
            return bras
        }
    }
}
// 父类ids
private extension HoStoreModel {
    
    var parent: String {
        get {
            if parentIds != nil && parentIds!.length > 0 {
                let pas = parentIds!.components(separatedBy: ",")
                return pas[1]
            }
            return ""
        }
    }
}

extension StoreDetailsViewModel: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        delegate?.toSearchVC()
        return false
    }
}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension StoreDetailsViewModel: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == Constant.upsTag {
            
            if index == 10 {
                return sectionModel?.categoryList?.count ?? 0
            }
            else if index == 20 {
                
                return selectedBrands.count
            }
            else if index == 30 {
                return selectedSpes.count
            }
            
        }
        else if collectionView.tag == Constant.nTag {
            return itemsData.count
        }
        fatalError("collectionView Not Set")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == Constant.upsTag {
            
            let cell = collectionView.hw_dequeueReusableCell(indexPath: indexPath) as StoreDetailsUpsCollectionViewCell
            if index == 10 {
                cell.model = sectionModel?.categoryList?[indexPath.item]
            }
            else if index == 20 {
                cell.brand = selectedBrands[indexPath.item]
            }
            else if index == 30 {
                cell.spe = selectedSpes[indexPath.item]
            }
            return cell
        }
        else if collectionView.tag == Constant.nTag {
            
            
            if UserData.shared.userType == .cgy {
               let cell = collectionView.hw_dequeueReusableCell(indexPath: indexPath) as CGYCollectionViewCell
                cell.model = itemsData[indexPath.item]
                cell.delegate = self
                return cell
            }
            else if UserData.shared.sjsEnter && sjsFlag {
                
                let cell = collectionView.hw_dequeueReusableCell(indexPath: indexPath) as CGYCollectionViewCell
                cell.sjsFlag = sjsFlag
                cell.model = itemsData[indexPath.item]
                return cell
                
            }
            
            let cell = collectionView.hw_dequeueReusableCell(indexPath: indexPath) as StoreDetailsItemCollectionViewCell
            cell.model = itemsData[indexPath.item]
            
            return cell
        }
        fatalError("collectionView Not Set")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == Constant.upsTag {
            
            if index == 10 {
                selectedModel?.isSelected = false
                let item = sectionModel?.categoryList?[indexPath.item]
                selectedModel = item
                selectedModel?.isSelected = true
                
                selectedBrand?.isSelected = false
                selectedBrand = nil
                selectedSpesub?.isSelected = false
                selectedSpesub = nil
            }
            else if index == 20 {
                selectedBrand?.isSelected = false
                let item = selectedBrands[indexPath.item]
                selectedBrand = item
                selectedBrand?.isSelected = true
                
                selectedSpesub?.isSelected = false
                selectedSpesub = nil
            }
            else if index == 30 {
                selectedSpesub?.isSelected = false
                let item = selectedSpes[indexPath.item]
                selectedSpesub = item
                selectedSpesub?.isSelected = true
            }
            delegate?.updateUpsUI()
        }
        else if collectionView.tag == Constant.nTag {
            
            delegate?.didClick(itemsData[indexPath.item])
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == Constant.upsTag {
            return Constant.upsItemSize
        }
        else if collectionView.tag == Constant.nTag {
            
            if UserData.shared.userType == .cgy  || sjsFlag {
                let cellWidth = PublicSize.screenWidth - 20
                let cellHeight = cellWidth*(500.0/369) / 4
                let itemSize = CGSize(width: cellWidth, height: cellHeight)
                return itemSize
            }
            
            return Constant.itemSize
        }
        fatalError("collectionView Not Set")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == Constant.nTag {
            return 10
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == Constant.nTag {
            return 3
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.tag == Constant.upsTag {
            return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        }
        else if collectionView.tag == Constant.nTag {
            return UIEdgeInsets(top: 11, left: 0, bottom:0, right: 0)
        }
        fatalError("collectionView Not Set")
    }
    
    
}
// MARK: - CGYCollectionViewCellDelegate
extension StoreDetailsViewModel: CGYCollectionViewCellDelegate {
    
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
