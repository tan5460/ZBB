//
//  MyInviteViewModel.swift
//  YZB_Company
//
//  Created by Mac on 12.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

@objc protocol MyInviteViewModelDelegate {
    
    func wait()
    func alertInfo()
    func updateUI()
}

private protocol MyInviteInterface {
    
    var delegate: MyInviteViewModelDelegate? { get set }
    
    var dataCount: Int { get }
    var inviteModel: InviteModel? { get }
    var inviteCount: String? {get}
    var total: String? {get}
    
}

public class MyInviteViewModel: NSObject, MyInviteInterface {
    
    var inviteCount: String? {
        get { return exchangeInviteCount }
    }
    
    var total: String? {
        get { return exchangeTotal }
    }
    
    var inviteModel: InviteModel? {
        get { return exchangeInviteModel }
    }
    
    var delegate: MyInviteViewModelDelegate?

    private var exchangeInviteModel: InviteModel?
    private var exchangeInviteCount: String?
    private var exchangeTotal: String?
    
    var dataCount: Int {
        get { return inviteModel?.workerList?.count ?? 0 }
    }
    
    func getMyInvite() {
        
        guard let userId = UserData.shared.workerModel?.id else {
            fatalError("userId is null")
        }
        
        delegate?.wait()
        
        let parameters: Parameters = ["id": userId]
        let urlStr = APIURL.getMyInvite
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { [unowned self](response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model = Mapper<InviteModel>().map(JSON: dataDic as! [String : Any])
                
                self.exchangeInviteModel = model
                
                if let valueStr = model?.countWorker?.stringValue {
                    
                    self.exchangeInviteCount = "您已成功辅导\(valueStr)位会员"
                }
                
                if let valueStr = model?.sumIntegral {
                    
                    //初始化NumberFormatter
                    let format = NumberFormatter()
                    //设置numberStyle(有多种格式)
                    format.numberStyle = .decimal
                    //转换后的string
                    let newValue = format.string(from: valueStr)
                    self.exchangeTotal = newValue
                }
                
                self.delegate?.updateUI()
            }
            
        }) { (error) in
            
        }
    }
}
