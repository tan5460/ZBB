//
//  MessageViewModel.swift
//  YZB_Company
//
//  Created by Mac on 12.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

@objc protocol MessageViewModelDelegate {
    
    func updateUI()
    func endRefresh()
    func endRefreshingWithNoMoreData()
    func resetNoMoreData()
}

private protocol MessageInterface {
    
    var delegate: MessageViewModelDelegate? { set get }
    var rowsData: Array<SystemMsgModel> { get }
    var rowDataCount: Int {get}
    
    func footerRefresh()
    func headerRefresh()
}
class MessageViewModel: NSObject, MessageInterface {
    
    var rowDataCount: Int {
        get { return exchangeRowsData.count }
    }
    
    var delegate: MessageViewModelDelegate?
    
    var rowsData: Array<SystemMsgModel> {
        get { return exchangeRowsData }
    }
    
    private var exchangeRowsData: Array<SystemMsgModel> = []
    private var curPage = 1
    
    func footerRefresh() {
        AppLog("上拉加载")
        
        if exchangeRowsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    func headerRefresh(){
        AppLog("下拉刷新")
        curPage = 1
        loadData()
    }
    
    private func loadData() {
        let pageSize = 20
        
        let parameters: Parameters = ["messageType": "1", "size": "\(pageSize)", "current": "\(self.curPage)"]
        
        let urlStr = APIURL.getMsgPushList
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { [unowned self](response) in
            self.delegate?.endRefresh()
           
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<SystemMsgModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage > 1 {
                    self.exchangeRowsData += modelArray
                }
                else {
                    self.exchangeRowsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.delegate?.endRefreshingWithNoMoreData()
                } else {
                    self.delegate?.resetNoMoreData()
                }
            } else {
                self.exchangeRowsData.removeAll()
            }
            self.delegate?.updateUI()
            
            if self.rowsData.count <= 0 {
                self.delegate?.endRefreshingWithNoMoreData()
            }
            
        }) { (error) in
            // 结束刷新
            self.delegate?.endRefresh()
            
            if self.rowsData.count <= 0 {
                self.delegate?.endRefreshingWithNoMoreData()
            }
        }
    }
    
}
