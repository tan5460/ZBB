//
//  StoreViewModel.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/6.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import SkeletonView
import ObjectMapper

@objc protocol StoreViewModelDelegate {
    
    // 搜索
    func toSearchVC()
    
    // 刷新
    func reloadData()
    
    // 刷新右边数据
    func reloadRightView(_ isFirstItem: Bool)
    
    // toDetails
    func toDetail(_ withModel: HoStoreModel?, sectionModel: HoStoreModel?)
}

private protocol StoreViewModelInterface {
    
    
}

class StoreViewModel: NSObject, StoreViewModelInterface {

    weak var vc: UIViewController?
    weak var delegate: StoreViewModelDelegate?
    
    private var tableHeight: CGFloat = 0
    private var collectionHeaderSize: CGSize = CGSize.zero
    
    private var datas: [HoStoreModel]? {
        didSet { delegate?.reloadData() }
    }
    private var selectedModel: HoStoreModel!
    
    /// 加载数据
    func loadData() {

        UIApplication.shared.windows.first?.pleaseWait()
        var parameters = [String: Any]()
        parameters["type"] = 1
        parameters["categoryType"] = "1"
        YZBSign.shared.request(APIURL.getNewCategory, method: .get, parameters: parameters, success: response(_:)) { (error) in
        }
    }
    
    private func response(_ res : [String : AnyObject]) {
        UIApplication.shared.windows.first?.clearAllNotice()
        let errorCode = Utils.getReadString(dir: res as NSDictionary, field: "code")
        if errorCode == "0" {
            let dataArray = Utils.getReqArr(data: res as AnyObject)
            let modelArray = Mapper<HoStoreModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
            selectedModel = modelArray.first
            selectedModel?.isSelected = true
            datas = modelArray
            self.getTwoCategoryData(true)
        }
    }
    
    private func getTwoCategoryData(_ isReload: Bool) {
        guard let model = selectedModel else { return  }
        UIApplication.shared.windows.first?.pleaseWait()
        var parameters = [String: Any]()
        
        parameters["parentId"] = model.id
        parameters["categoryType"] = "1"
        YZBSign.shared.request(APIURL.getNewCategory, method: .get, parameters: parameters, success: { (res) in
            let dataArray = Utils.getReqArr(data: res as AnyObject)
            let modelArray = Mapper<HoStoreModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
            self.selectedModel.categoryList = modelArray
            self.delegate?.reloadRightView(isReload)
        }) { (error) in
            
        }
    }
    
}
// MARK: - TableView占位图代理
extension StoreViewModel: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return StoreTableViewCell.identifier
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}

// MARK: - LeftView代理
extension StoreViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.hw_dequeueReusableCell(indexPath: indexPath) as StoreTableViewCell
        cell.model = datas?[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = datas?[indexPath.item]
        if item?.name == selectedModel.name {
            return
        }
        selectedModel.isSelected = false
        selectedModel = item
        selectedModel.isSelected = true
        self.getTwoCategoryData(false)
       // delegate?.reloadRightView(false)
    }
    
}
// MARK: - UICollectionView占位图代理
extension StoreViewModel: SkeletonCollectionViewDataSource {
    func numSections(in collectionSkeletonView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        
        return StoreCollectionViewCell.identifier
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, supplementaryViewIdentifierOfKind: String, at indexPath: IndexPath) -> ReusableCellIdentifier? {
        return StoreCollectionHeaderView.identifier
    }
    
    
}

// MARK: - RightView代理
extension StoreViewModel: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return selectedModel?.categoryList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = selectedModel?.categoryList?[section].categoryList?.count ?? 0
        
        if count > 9 {
            // 设置更多
            selectedModel?.categoryList?[section].categoryList?[8].isMoreItem = true
            if selectedModel?.categoryList?[section].categoryList?[8].isOpen ?? false == false {
                count = 9
            }
            
        }
        
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.hw_dequeueReusableCell(indexPath: indexPath) as StoreCollectionViewCell
        cell.model = selectedModel?.categoryList?[indexPath.section].categoryList?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionHeaderSize == .zero {
            collectionHeaderSize = CGSize(width: collectionView.frame.size.width, height: UIScreen.main.bounds.size.height * 180 / 2436)
        }
        return collectionHeaderSize
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.hw_dequeueCollectionHeaderView(indexPath: indexPath) as StoreCollectionHeaderView
        header.delegate = self
        header.section = indexPath.section
        header.model = selectedModel?.categoryList?[indexPath.section]
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var sectionItem = selectedModel?.categoryList?[indexPath.section]
        var item = sectionItem?.categoryList?[indexPath.row]
        item?.isSelected = true
        if item?.isMoreItem ?? false && item?.isOpen ?? false == false {
            // 设置更多
            item?.isOpen = true
            selectedModel?.categoryList?[indexPath.section].isOpen = true
            delegate?.reloadRightView(false)
        }
        else {
            sectionItem = sectionItem?.copy() as? HoStoreModel
            item = sectionItem?.categoryList?[indexPath.row]
            delegate?.toDetail(item, sectionModel: sectionItem)
        }
    }
    
}
// MARK: - 头视图收起代理
extension StoreViewModel: StoreCollectionHeaderViewDelegate {
    
    func reload(section: Int) {
        selectedModel?.categoryList?[section].isOpen = false
        if selectedModel?.categoryList?[section].categoryList?.count ?? 0 > 9 {
            selectedModel?.categoryList?[section].categoryList?[8].isOpen = false
        }
        
        delegate?.reloadRightView(false)
    }
}

// MARK: - UISearchBarDelegate
extension StoreViewModel: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        delegate?.toSearchVC()
        return false
    }
}


