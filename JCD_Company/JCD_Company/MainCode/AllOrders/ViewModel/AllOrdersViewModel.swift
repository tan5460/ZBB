//
//  AllOrdersViewModel.swift
//  YZB_Company
//
//  Created by Mac on 12.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

@objc public protocol AllOrdersViewModelDelegate {
    
    func endRefresh()
    func endRefreshingWithNoMoreData()
    func resetNoMoreData()
    func reloadUI()
    func updateUI()
    func pushOrderDetailCart()
    func pushOrderDetail()
}

public class AllOrdersViewModel: NSObject {
    
    weak var delegate: AllOrdersViewModelDelegate?
    
    private var topSelectBtnTag = 0                    //选择按钮Tag(0,1,2,3)
    
    //状态
    private var orderStatus: NSNumber {
        get { return NSNumber.init(value: topSelectBtnTag) }
    }
    
    //数据数量
    var rowsDataCount: Int {
        get { return exchangeRowsData.count }
    }
    
    //订单数据
    var rowsData: Array<OrderModel> {
        get { return exchangeRowsData }
    }
    
    //选中model
    var model: OrderModel {
        get { return exchangeModel }
    }
    
    //无数据是否隐藏标识
    var noneDataIsHidden: Bool {
        get { return noneDataEnable}
    }
    
    //尾部视图隐藏标识
    var footerIsHidden: Bool {
        get { return footerEnable }
    }
    
    private var footerEnable = false
    private var noneDataEnable = false
    private var curPage = 1
    private var exchangeRowsData: Array<OrderModel> = []        //交换订单数据
    private var exchangeModel: OrderModel!
    
    /// 头部刷新
    func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        
        loadData()
    }
    
    /// 尾部刷新
    func footerRefresh() {
        AppLog("上拉加载")
        if exchangeRowsData.count > 0 {
            curPage += 1
        }else {
            curPage = 1
        }
        
        loadData()
    }
    
    /// 状态点击
    func topClick(index: Int) {
        topSelectBtnTag = index
        AppLog("订单状态: \(orderStatus)")
    }
    
    /// 选中
    func didSelectRowAt(indexPath: IndexPath) {
        
        exchangeModel = self.exchangeRowsData[indexPath.row]
        if exchangeModel.orderType == 1 || exchangeModel.orderType == 3 {
            delegate?.pushOrderDetailCart()
        }else {
            delegate?.pushOrderDetail()
        }
    }
    
    //获取订单
    private func loadData() {
        
        guard let jobType = UserData.shared.workerModel?.jobType?.stringValue else {
            return
        }
        let pageSize = 20
        var parameters = Parameters()
        parameters["size"] = "\(pageSize)"
        parameters["current"] = "\(self.curPage)"
        if orderStatus != 0 {
            parameters["orderStatus"] = orderStatus
        }
        parameters["jobType"] = jobType == "4" || jobType == "999" ? "999" : jobType
        
        
        AppLog(parameters)
        let urlStr = APIURL.getCompanyOrder
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { [unowned self](response) in
            
            // 结束刷新
            self.delegate?.endRefresh()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<OrderModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage > 1 {
                    self.exchangeRowsData += modelArray
                }
                else {
                    self.exchangeRowsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.delegate?.endRefreshingWithNoMoreData()
                }else {
                    self.delegate?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.exchangeRowsData.removeAll()
            }
            
            self.delegate?.reloadUI()
            
            if self.rowsData.count <= 0 {
                self.delegate?.endRefreshingWithNoMoreData()
            }
            if self.rowsData.count <= 0 {
                self.footerEnable = true
                self.noneDataEnable = false
            }else {
                self.noneDataEnable = true
            }
            
            self.delegate?.updateUI()
            
        }) { (error) in
            
            // 结束刷新
            self.delegate?.endRefresh()
            
            if self.rowsData.count <= 0 {
                self.delegate?.endRefreshingWithNoMoreData()
            }
            if self.rowsData.count <= 0 {
                self.footerEnable = true
                self.noneDataEnable = false
            }else {
                self.footerEnable = false
                self.noneDataEnable = true
            }
            self.delegate?.updateUI()
        }
    }
}
