//
//  BrandHouseViewModel.swift
//  YZB_Company
//
//  Created by Mac on 18.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

@objc protocol BrandHouseViewModelDelegate {
    
    func clearNotice()
    func showWait()
    func endRefreshing()
    
    /// 刷新所有UI
    func updateUI()
    
    /// 仅刷新CollectionView
    func reloadCollectionView()
}


private protocol BrandHouseViewModelInterface {
    var item: BrandHouseModel? { get }
    var itemCount: Int { get }
    var delegate: BrandHouseViewModelDelegate! { set get }
    var leftDatas: [String]! { get }
    var leftSelectViewBlock: ((_ indexPath: IndexPath)->())? { set get }
    
    func headerRefresh()
}

extension BrandHouseViewModel: BrandHouseViewModelInterface {
    
    var leftDatas: [String]! {
        get {
            return pItems?.map{$0.categoryName ?? ""} ?? []
        }
    }
    
    var item: BrandHouseModel? {
        get {
            return pItems?[selectedIndex]
        }
    }

    var itemCount: Int {
        get {
            return pItems?[selectedIndex].brandList?.count ?? 0
        }
    }
    
    func headerRefresh() {
        AppLog("下拉刷新")
        loadData()
    }
    
}
class BrandHouseViewModel: NSObject {

    var delegate: BrandHouseViewModelDelegate!
    var leftSelectViewBlock: ((_ indexPath: IndexPath)->())?
    
    private var selectedIndex: Int = 0
    private var pItems: [BrandHouseModel]?
    private var pSelectedIndex: Int = 0
    
    override init() {
        super.init()
        leftSelectViewBlock = ({ [unowned self](indexPath) in
            self.selectedIndex = indexPath.item
            self.delegate?.reloadCollectionView()
        })
    }
    
    /// 请求数据
    private func loadData() {
        
        var cityID = ""
        if let valueStr = UserData.shared.workerModel?.store?.city?.id {
            cityID = valueStr
        }
        var substationId = ""
        if let valueStr = UserData.shared.workerModel?.substation?.id {
            substationId = valueStr
            
        }
        
        let parameters: Parameters = ["id": "", "category.id": "", "city.id": cityID,"substationId":substationId, "isshow": "", "pageSize": "500"]
        
        delegate?.clearNotice()
        delegate?.showWait()
        let urlStr = APIURL.getMerchant
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<BrandHouseModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.pItems = modelArray
                self.delegate?.endRefreshing()
                self.delegate?.updateUI()
            }
         
        }) { (error) in
            self.delegate?.endRefreshing()
        }
        
    }
}

