//
//  WaitDoVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2020/11/16.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import PopupDialog
import MJRefresh

class WaitDoVC: BaseViewController {
    var refreshMsgCount: (() -> Void)?
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>> 聊天界面释放 <<<<<<<<<<<<<<")
        GlobalNotificationer.remove(observer: self, notification: .purchaseRefresh)
        NotificationCenter.default.removeObserver(self)
    }
    var noDataBtn = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        //获取用户本地信息
        AppUtils.getLocalUserData()
        GlobalNotificationer.add(observer: self, selector: #selector(headerRefresh), notification: .purchaseRefresh)
        
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
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        loadData()
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无待办消息～").textColor(.kColor66).font(14)
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
    }
    
    //待办下拉刷新
    @objc func headerRefresh() {
        self.tableView.beginHeaderRefresh()
    }
    
    private var dataSoure: [BacklogModel] = []
    private var current = 1
    private var size = 10
    func loadData() {
        var urlStr = ""
        if UserData.shared.userType == .cgy {
            urlStr = APIURL.pageStoreMessage
        } else if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
            urlStr = APIURL.pageMerchantMessage
        } else if UserData.shared.userType == .yys {
            urlStr = APIURL.pageMerchantMessage
        }
        var parameters = Parameters()
        parameters["messageType"] = 2
        parameters["current"] = "\(current)"
        parameters["size"] = size
        
        if UserData.shared.userType == .gys {
            
        }else if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            

        } else if UserData.shared.userType == .yys {

        }
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<BacklogModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current == 1 {
                    self.dataSoure = modelArray
                } else {
                    self.dataSoure += modelArray
                }
                if modelArray.count < self.size {
                    self.tableView.endFooterRefreshNoMoreData()
                }
                self.tableView.reloadData()
            }
            self.noDataBtn.isHidden = self.dataSoure.count > 0
        }) { (error) in
            self.noDataBtn.isHidden = self.dataSoure.count > 0
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
    
}

extension WaitDoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSoure.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.white)
        let model = self.dataSoure[indexPath.section]
        let orderNo = UILabel().text("订单号：\(model.orderNo ?? "")").textColor(.kColor33).font(12)
        let redPoint = UIView().backgroundColor(.kDF2F2F).cornerRadius(5).masksToBounds()
        redPoint.isHidden = model.isRead == 0
        let line1 = UIView().backgroundColor(.kColor220)
        let gysLabel = UILabel().text("供应商：\(model.merchantName ?? "")").textColor(.kColor33).font(12)
        let msgLabel = UILabel().text("\(model.message ?? "")").textColor(.kColor33).font(12)
        msgLabel.numberOfLines(0).lineSpace(2)
        let line2 = UIView().backgroundColor(.kColor220)
        let dateLabel = UILabel().text("\(model.createTime ?? "")").textColor(.kColor66).font(12)
        cell.sv(orderNo, redPoint, line1, gysLabel, msgLabel, line2
        , dateLabel)
        cell.layout(
            15,
            |-14-orderNo.height(16.5)-(>=0)-redPoint.size(10)-14-|,
            10.5,
            |-14.5-line1.height(0.5)-13.5-|,
            9.5,
            |-14-gysLabel.height(16.5),
            10,
            |-14-msgLabel-14-|,
            10.5,
            |-14.5-line2.height(0.5)-13.5-|,
            9.5,
            |-14-dateLabel.height(16.5),
            20
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSoure[indexPath.section]
        if model.isRead ?? 0 == 1 {
            model.isRead = 0
            tableView.reloadData()
            self.msgRead(model: model)
        }
        guard let orderId = model.orderId else {
            return
        }
        
        if model.orderType == 1 {
            let orderModel: OrderModel = OrderModel()
            orderModel.id = orderId
            let vc = OrderDetailCartController()
            vc.orderModel = orderModel
            self.navigationController?.pushViewController(vc)
        } else {
            if model.purchaseOrderType == "2" {
                let vc = ServiceOrderDetailVC()
                vc.orderId = orderId
                vc.removeId = model.id!
                self.navigationController?.pushViewController(vc)
            } else {
                let vc = PurchaseDetailController()
                vc.orderId = orderId
                vc.removeId = model.id!
                self.navigationController?.pushViewController(vc)
            }
            
        }
    }
    
    
    func msgRead(model: BacklogModel) {
        var parameters: Parameters = ["id": model.id ?? ""]
        parameters["isRead"] = 0
        parameters["isDealwith"] = 1
        let urlStr = APIURL.updateMessage
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0"{
                self.refreshMsgCount?()
            }
        }) { (error) in }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    //左滑删除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let cellModel = dataSoure[indexPath.section]
        
        let popup = PopupDialog(title: "提示", message: "是否删除此条待办信息？",buttonAlignment: .horizontal)
        let sureBtn = DestructiveButton(title: "删除") {
            
            let parameters: Parameters = ["id": cellModel.id!]
            
            self.pleaseWait()
            let urlStr =  APIURL.deleteSysMessage
            
            YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                if errorCode == "0" {
                    self.msgRead(model: cellModel)
                    self.dataSoure.remove(at: indexPath.section)
                    self.tableView.reloadData()
                    self.noticeSuccess("删除成功")
                }
            }) { (error) in
                
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.kBackgroundColor)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.kBackgroundColor)
    }
}
