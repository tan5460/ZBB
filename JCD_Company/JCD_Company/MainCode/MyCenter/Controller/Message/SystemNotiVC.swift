//
//  SystemNotiVC.swift
//  YZB_Company
//
//  Created by 巢云 on 2020/9/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class SystemNotiVC: BaseViewController {
    var refreshMsgCount: (() -> Void)?
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "系统通知"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
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
        pleaseWait()
        loadData()
        prepareNoDateView("暂无系统通知")
        noDataView.isHidden = true
        
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
    }
    private var current = 1
    private var size = 15
    private var dataSource: [MessageModel] = []
    func loadData() {
        var parameters = Parameters()
        parameters["messageType"] = 3
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.systremMessages, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let pageModel = Mapper<PagesModel>().map(JSON: dataDic as! [String : Any])
                let models = Mapper<MessageModel>().mapArray(JSONObject: pageModel?.records) ?? [MessageModel]()
                if self.current == 1 {
                    self.dataSource = models
                } else {
                    self.dataSource.append(contentsOf: models)
                }
                if pageModel?.hasNextPage ?? false {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
                self.tableView.endHeaderRefresh()
                self.noDataView.isHidden = self.dataSource.count > 0
                self.tableView.reloadData()
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
}


extension SystemNotiVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell().backgroundColor(UIColor.hexColor("#F6F6F6"))
        cell.selectionStyle = .none
        let timeLabel = UILabel().text("\(model.createTime ?? "")").textColor(.kColor99).font(12)
        let content = UIView().backgroundColor(.white).cornerRadius(5)
        let titleLabel = UILabel().text(model.message ?? "").textColor(.kColor33).font(14)
        let detailLabel = UILabel().text("\(model.subTitle ?? "")，GO>>>").textColor(.kColor99).font(12)
        let readView = UIView().backgroundColor(UIColor.hexColor("#DF2F2F")).cornerRadius(5)
        
        cell.sv(timeLabel, content)
        cell.layout(
            10,
            timeLabel.height(16.5).centerHorizontally(),
            9.5,
            |-14-content-14-|,
            0
        )
        content.sv(titleLabel, detailLabel, readView)
        content.layout(
            15,
            |-15-titleLabel.height(20)-(>=0)-readView.size(10)-15-|,
            8,
            |-15-detailLabel-15-|,
            15
        )
        detailLabel.numberOfLines(2).lineSpace(2)
        readView.isHidden = (model.isRead == 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataSource[indexPath.row]
        let vc = UIBaseWebViewController()
        let urlStr = APIURL.webUrl + "/other/jcd-active-h5/#/message-notification?id=\(model.orderId ?? "")"
        vc.urlStr = urlStr
        vc.isShare = true
        vc.title = model.message ?? ""
        navigationController?.pushViewController(vc)
        readMessageRequest(indexPath: indexPath)
//        let vc = MembershipInterestsVC()
//        navigationController?.pushViewController(vc)
    }
    
    func readMessageRequest(indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        var parameters = Parameters()
        parameters["isRead"] = 0
        parameters["isDealwith"] = 1
        parameters["id"] = model.id
        YZBSign.shared.request(APIURL.updateMessage, method: .post, parameters: parameters,  success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                model.isRead = 0
                self.refreshMsgCount?()
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }) { (error) in
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
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


class MessageModel : NSObject, Mappable{
    
    var comId : String?
    var contacts : AnyObject?
    var createTime : String?
    var id : String?
    var isDealwith : Int?
    var isRead : Int?
    var merchantName : AnyObject?
    var message : String?
    var messageType : Int?
    var orderId : String?
    var orderNo : AnyObject?
    var orderType : Int?
    var page : AnyObject?
    var purchaseOrderType : AnyObject?
    var storeName : String?
    var substationId : AnyObject?
    var type : Int?
    
    var belongName : String?
    var belongObj : String?
    var content : String?
    var pushFlag : Int?
    var pushObj : AnyObject?
    var sortNo : AnyObject?
    var subTitle : String?
    var title : String?
    var updateTime : String?
    
    required init?(map: Map){}
    private override init(){
        super.init()
    }
    
    func mapping(map: Map)
    {
        belongName <- map["belongName"]
        belongObj <- map["belongObj"]
        content <- map["content"]
        pushFlag <- map["pushFlag"]
        pushObj <- map["pushObj"]
        sortNo <- map["sortNo"]
        subTitle <- map["subTitle"]
        title <- map["title"]
        updateTime <- map["updateTime"]
        comId <- map["comId"]
        contacts <- map["contacts"]
        createTime <- map["createTime"]
        id <- map["id"]
        isDealwith <- map["isDealwith"]
        isRead <- map["isRead"]
        merchantName <- map["merchantName"]
        message <- map["message"]
        messageType <- map["messageType"]
        orderId <- map["orderId"]
        orderNo <- map["orderNo"]
        orderType <- map["orderType"]
        page <- map["page"]
        purchaseOrderType <- map["purchaseOrderType"]
        storeName <- map["storeName"]
        substationId <- map["substationId"]
        type <- map["type"]
        
    }
}
