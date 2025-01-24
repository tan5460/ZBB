//
//  ServiceOrderListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/9.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh
import ObjectMapper

class ServiceOrderListVC: BaseViewController {

    var index: Int = 0
    var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.kBackgroundColor)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer = footer
        tableView.mj_footer?.isHidden = true
        
        prepareNoDateView("暂无数据")
        noDataView.isHidden = true
        
        loadData()
    }
    var curPage = 1                             //页码
    var rowsData: Array<PurchaseOrderModel> = []        //订单数据
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        if rowsData.count > 0 {
            curPage += 1
        }else {
            curPage = 1
        }
        
        loadData()
    }
    
    //获取订单
    func loadData() {
        var orderStatus = ""
        
        switch index {
        case 1:
            orderStatus = "2"
        case 2:
            orderStatus = "3"
        case 3:
            orderStatus = "4"
        case 4:
            orderStatus = "12"
        case 5:
            orderStatus = "13"
        default:
            orderStatus = ""
        }
        
        let pageSize = 20
        var parameters: Parameters = ["size": "\(pageSize)"]
        parameters["orderStatuss"] = orderStatus
        parameters["current"] = "\(self.curPage)"
        
        if UserData.shared.workerModel?.jobType == 999 {
             parameters["workerId"] = UserData.shared.workerModel?.id
         }
         parameters["storeId"] = UserData.shared.storeModel?.id
         parameters["orderType"] = 2
        
        let urlStr = APIURL.getYYSPurchaseOrder
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataDic1 = Utils.getReadDic(data: dataDic as AnyObject, field: "orderPage")
                let dataArray = Utils.getReadArr(data: dataDic1, field: "records")
                let modelArray = Mapper<PurchaseOrderModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.curPage > 1 {
                    self.rowsData += modelArray
                }
                else {
                    self.rowsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.rowsData.removeAll()
            }
            
            self.tableView.reloadData()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self.noDataView.isHidden = self.rowsData.count > 0
            
        }) { (error) in
            self.noDataView.isHidden = self.rowsData.count > 0
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }

}


extension ServiceOrderListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = rowsData[indexPath.row]
        let cell = UITableViewCell()
        cell.backgroundColor(.kBackgroundColor)
        let content = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
        cell.sv(content)
        cell.layout(
            0,
            |-14-content-14-| ~ 159,
            10
        )
        
        let orderNO = UILabel().text("订单号：\(model.orderNo ?? "")").textColor(.kColor33).font(12)
        let status = UILabel().text("待确认").textColor(.kDF2F2F).font(14)
        AppData.serviceStatusTypes.forEach { (dic) in
            if model.orderStatus?.intValue == Int(Utils.getReadString(dir: dic, field: "value")) {
                status.text(Utils.getReadString(dir: dic, field: "label"))
            }
        }
        let line = UIView().backgroundColor(.kColor220)
        let service = UILabel().text("服务商：\(model.merchantName ?? "")").textColor(.kColor33).font(12)
        let address = UILabel().text("地址：\(model.address ?? "")").textColor(.kColor33).font(12)
        let line1 = UIView().backgroundColor(.kColor220)
        var orderTime = model.orderTime ?? ""
        orderTime = orderTime.replacingOccurrences(of: "T", with: " ")
        let time = UILabel().text(orderTime).textColor(.kColor66).font(12)
        let orderMoney = UILabel().text("订单金额：").textColor(.kColor33).font(12)
        let money = UILabel().text("¥\(model.payMoney ?? 0)").textColor(#colorLiteral(red: 1, green: 0.6705882353, blue: 0.2392156863, alpha: 1)).font(12)
        content.sv(orderNO, status, line, line1, service, address, time, orderMoney, money)
        content.layout(
            17,
            |-15-orderNO.height(16.5)-(>=0)-status.height(20)-15-|,
            11,
            |-15-line.height(0.5)-15-|,
            15,
            |-15-service.height(16.5),
            10,
            |-15-address.height(16.5)-15-|,
            15,
            |-15-line1.height(0.5)-15-|,
            10,
            |-15-time.height(16.5)-(>=0)-orderMoney-1-money-15-|,
            >=0
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orderModel = rowsData[indexPath.row]
        let vc = ServiceOrderDetailVC()
        if let valueStr = orderModel.id {
            vc.orderId = valueStr
        }
        vc.goBackBlock = { [weak self] model in
            if let purchaseModel = model {
                if self?.rowsData.count ?? 0 > 0 {
                    self?.rowsData.remove(at: indexPath.row)
                    self?.rowsData.insert(purchaseModel, at: indexPath.row)
                    self?.tableView.reloadData()
                }
            } else {
                if self?.rowsData.count ?? 0 > 0 {
                    self?.rowsData.remove(at: indexPath.row)
                    self?.tableView.reloadData()
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 169
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

