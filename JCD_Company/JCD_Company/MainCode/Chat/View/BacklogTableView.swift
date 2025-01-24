//
//  BacklogTableView.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import ObjectMapper

class BacklogTableView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var data:[BacklogModel] = []
    private var removeIndexPath: IndexPath! // 移除标识
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.estimatedRowHeight = 142
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        // 注册cell
        tableView.register(BacklogCell.self, forCellReuseIdentifier: BacklogCell.self.description())
        
        return tableView
    }()
    
    var noneDataView: UIView!
    
    func refreshRemoveItem() {
        if let indexPath = removeIndexPath {
            if data.count > 0 {
                data.remove(at: indexPath.row)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        noneDataView = UIView()
        prepareNoDate(view: noneDataView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        noneDataView?.isHidden = data.count > 0
        tableView.mj_footer?.isHidden = !(data.count > 0)
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BacklogCell.self.description(), for: indexPath) as! BacklogCell
        cell.model = data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        removeIndexPath = indexPath
        let model = data[indexPath.row]

        if model.isRead?.boolValue == true {
            
            model.isRead = false
            tableView.reloadData()
            
            var parameters: Parameters = ["id": model.id ?? ""]
            parameters["isRead"] = 0
            parameters["isDealwith"] = 1
            let urlStr = APIURL.updateMessage
            
            YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
                
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                if errorCode == "0"{
                    
                }
                
            }) { (error) in }
        }
        
        guard let orderId = model.orderId else {
            return
        }
        
        if model.orderType == 1 {
            let orderModel: OrderModel = OrderModel()
            orderModel.id = orderId
            let vc = OrderDetailCartController()
            vc.orderModel = orderModel
            self.viewController()?.navigationController?.pushViewController(vc, animated: true)
        } else {
            if model.purchaseOrderType == "2" {
                let vc = ServiceOrderDetailVC()
                vc.orderId = orderId
                vc.removeId = model.id!
                self.viewController()?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = PurchaseDetailController()
                vc.orderId = orderId
                vc.removeId = model.id!
                self.viewController()?.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "删除"
    }
    
    //左滑删除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let cellModel = data[indexPath.row]
        
        let popup = PopupDialog(title: "提示", message: "是否删除此条待办信息？",buttonAlignment: .horizontal)
        let sureBtn = DestructiveButton(title: "删除") {
            
            let parameters: Parameters = ["id": cellModel.id!]
            
            self.pleaseWait()
            let urlStr =  APIURL.deleteSysMessage
            
            YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
                
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
                if errorCode == "000" {
                    
                    self.data.remove(at: indexPath.row)
                    self.tableView.reloadData()
                    self.noticeSuccess("删除成功")
                }
                
            }) { (error) in
                
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.viewController()?.present(popup, animated: true, completion: nil)
    }
}
