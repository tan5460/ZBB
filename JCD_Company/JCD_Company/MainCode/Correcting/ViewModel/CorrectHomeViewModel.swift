//
//  CorrectHomeViewModel.swift
//  YZB_Company
//
//  Created by Mac on 16.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

@objc protocol CorrectHomeViewModelDelegate {
    
    // 提醒消息
    func alertInfo(text: String)
    
    // 客户管理
    func toMyCustom()
    
    // 员工管理
    func toWorker()
    
    // 采购管理
    func toOrder()
    
    // 品牌馆
    func toBrandHouse()
    
    // 客户案例
    func toWholeHouse()
    
    // VR
    func toVR()
    
    // 结束刷新
    func endRefresh()
    
    // tableView刷新
    func tableViewUpdate()
    
    // 头部轮播刷新
    func refreshHeader()
}

private protocol CorrectHomeInterface {
    
    var delegate: CorrectHomeViewModelDelegate! { set get }
    
    func clickAction(sender: UIButton)
    
    func headerRefresh()
        
    var data: MaterialsCorrcetModel? { get }
    var secondData: MaterialsCorrcetModel? { get }
    var imagePaths: Array<String>! { get }
}

class CorrectHomeViewModel: NSObject, CorrectHomeInterface {
    
    var data: MaterialsCorrcetModel? {
        get {
            return exchangeData
        }
    }
    
    var secondData: MaterialsCorrcetModel? {
        get {
            return exchangeSecondData
        }
    }
    
    var imagePaths: Array<String>! {
        get {
            return exchangeImagePaths
        }
    }
    var downLoadURL: String?
    var downLoadURL2: String?
    var downLoadURL3: String?
    var haveBackImage = false
    
    @objc var delegate: CorrectHomeViewModelDelegate!
    
    private var exchangeData: MaterialsCorrcetModel?
    private var exchangeSecondData: MaterialsCorrcetModel?
    private var exchangeImagePaths:Array<String> = []
    
    func clickAction(sender: UIButton) {
        switch sender.tag {
        case 1000: delegate?.toMyCustom()
//        case 1001://员工管理
//            if UserData.shared.workerModel?.jobType != 999 {
//                delegate?.alertInfo(text: "‘员工管理’仅管理员可使用")
//            }
//            else {
//                delegate?.toWorker()
//            }
        case 1001:
            if UserData.shared.workerModel?.jobType == 999 || UserData.shared.workerModel?.jobType == 4  {
                
                
                delegate?.toOrder()
            }
            else {
                delegate?.alertInfo(text: "‘订单管理’仅管理员和采购员可使用")
            }
        case 1002: delegate?.toBrandHouse()
        case 1003: delegate?.toWholeHouse()
        case 1004: delegate?.toVR()
        default: fatalError("\(sender.tag) Tag is undefine")
        }
    }
    
    func headerRefresh() {
        AppLog("下拉刷新")
        
        loadData()
        loadCarouselData()
    }
   
    
}
// MARK: - Private
private extension CorrectHomeViewModel {
    
    ///网络请求
    func loadData() {
      //  requestSecondData()
        
        let urlStr = APIURL.getMaterialsList
        
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            
            // 结束刷新
            self.delegate?.endRefresh()

            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.exchangeData = Mapper<MaterialsCorrcetModel>().map(JSON: dataDic as! [String : Any])
            }
            self.delegate?.tableViewUpdate()
            
        }) { (error) in
            
            // 结束刷新
            self.delegate?.endRefresh()
        }
    }
    
    func loadCarouselData() {
        let urlStr = APIURL.backImgInfo
        
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            var arr:Array<String> = []
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let imgInfo = Mapper<BackImgInfoModel>().map(JSON: dataDic as! [String : Any])
                if let imgUrl = imgInfo?.backImg, !imgUrl.isEmpty {
                    let imgUrls = imgUrl.components(separatedBy: ",")
                    
                    arr.append(APIURL.ossPicUrl + imgUrls[0])
                    if imgUrls.count > 1 {
                        self.haveBackImage = true
                        self.downLoadURL = imgUrls[1]
                    }
                }
                if let imgUrl = imgInfo?.cityBackImg, !imgUrl.isEmpty {
                    let imgUrls = imgUrl.components(separatedBy: ",")
                    arr.append(APIURL.ossPicUrl + imgUrls[0])
                    if imgUrls.count > 1 {
                        self.downLoadURL2 = imgUrls[1]
                    }
                }
                if let imgUrl = imgInfo?.storeBackImg, !imgUrl.isEmpty {
                    let imgUrls = imgUrl.components(separatedBy: ",")
                    arr.append(APIURL.ossPicUrl + imgUrls[0])
                    if imgUrls.count > 1 {
                        self.downLoadURL3 = imgUrls[1]
                    }
                }
                self.exchangeImagePaths = arr
            }
            self.delegate?.refreshHeader()
            
        }) { (error) in
            
        }
    }
    
    func requestSecondData() {
        
        var storeId = ""
        
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeId = valueStr
        }else {
            delegate?.endRefresh()
            return
        }
        
        AppLog("店铺id: "+storeId)
        
        let parameters: Parameters = ["storeId": storeId]
        
        let urlStr = APIURL.getSecondList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.delegate?.endRefresh()

            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" || errorCode == "015" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.exchangeSecondData = Mapper<MaterialsCorrcetModel>().map(JSON: dataDic as! [String : Any])
            }
            
            self.delegate?.tableViewUpdate()
            
        }) { (error) in
            
            // 结束刷新
            self.delegate?.endRefresh()

        }
    }
}

