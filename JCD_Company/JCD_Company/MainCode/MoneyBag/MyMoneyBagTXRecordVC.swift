//
//  MyMoneyBagTXRecordVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/20.
//

import UIKit
import ObjectMapper

class MyMoneyBagTXRecordVC: BaseViewController {

    private var noDataBtn = UIButton()
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.white)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "提现记录"
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
        
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        loadData()
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无数据～").textColor(.kColor66).font(14)
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
    }
    
    private var size = 15
    private var current = 1
    private var dataSource: [TXRecordModel] = []
    func loadData() {
        var parameters = Parameters()
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.jcdWithdrawRecord, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let pageModel = Mapper<PagesModel>().map(JSON: dataDic as! [String : Any])
                let models = Mapper<TXRecordModel>().mapArray(JSONObject: pageModel?.records) ?? [TXRecordModel]()
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
                self.tableView.reloadData()
                self.noDataBtn.isHidden = self.dataSource.count > 0
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
}


extension MyMoneyBagTXRecordVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let model = dataSource[indexPath.row]
        var channel = "支付宝"
        if model.channel == "1" {
           channel = "微信"
        }
        var status = "提现成功"
        var statusColor = UIColor.hexColor("#1DC597")
        if model.status == "2" {
            status = "提现失败"
            statusColor = UIColor.hexColor("#FD9C3B")
        }
        let lab1 = UILabel().text("提现到：\(channel)").textColor(.kColor33).font(14)
        let lab2 = UILabel().text("-\(model.withdrawAmount?.doubleValue ?? 0.00)").textColor(.kColor33).fontBold(14)
        let lab3 = UILabel().text("\(model.updateTime ?? "")").textColor(.kColor99).font(12)
        let lab4 = UILabel().text("\(status)").textColor(statusColor).font(12)
        
        cell.sv(lab1, lab2, lab3, lab4)
        cell.layout(
            9.5,
            |-13.5-lab1.height(20)-(>=0)-lab2-14-|,
            6,
            |-13.5-lab3.height(16.5)-(>=0)-lab4-14-|,
            10.5
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PublicSize.kBottomOffset
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.white)
    }
}


class TXRecordModel : NSObject, Mappable{

    var channel : String?
    var createTime : String?
    var id : String?
    var remarks : String?
    var responseDesc : String?
    var status : String?
    var updateTime : String?
    var userId : String?
    var withdrawAccount : String?
    var withdrawAmount : NSNumber?

    required init?(map: Map){}
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        channel <- map["channel"]
        createTime <- map["createTime"]
        id <- map["id"]
        remarks <- map["remarks"]
        responseDesc <- map["responseDesc"]
        status <- map["status"]
        updateTime <- map["updateTime"]
        userId <- map["userId"]
        withdrawAccount <- map["withdrawAccount"]
        withdrawAmount <- map["withdrawAmount"]
        
    }

}
