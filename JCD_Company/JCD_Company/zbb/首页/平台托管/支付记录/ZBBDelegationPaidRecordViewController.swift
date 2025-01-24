//
//  ZBBDelegationPaidRecordViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit
import MJRefresh
import ObjectMapper

class ZBBDelegationPaidRecordViewController: BaseViewController {

    var id: String?
    
    private var tableView: UITableView!
    private var dataList = [ZBBOrderPayRecordModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "支付记录"
        createViews()
        refreshData()
    }
    
    private func createViews() {
        view.backgroundColor = .hexColor("#F7F7F7")
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ZBBDelegationPaidRecordTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.loadMoreData()
        })

    }
    
}

extension ZBBDelegationPaidRecordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBDelegationPaidRecordTableViewCell
        cell.model = dataList[indexPath.row]
        return cell
    }
}

extension ZBBDelegationPaidRecordViewController {
    
    private func refreshData() {
        requestDataList(with: 1) {[weak self] list in
            self?.tableView.mj_header?.endRefreshing()
            if let list = list {
                self?.page = 1
                self?.dataList.removeAll()
                self?.dataList.append(contentsOf: list)
                self?.tableView.reloadData()
                if list.count == 0 {
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    self?.tableView.mj_footer?.resetNoMoreData()
                }
            }
        }
    }
    
    private func loadMoreData() {
        let page = page + 1
        requestDataList(with: page) {[weak self] list in
            self?.tableView.mj_footer?.endRefreshing()
            if let list = list {
                self?.page = page
                self?.dataList.append(contentsOf: list)
                self?.tableView.reloadData()
                if list.count == 0 {
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
    private func requestDataList(with page: Int, complete: (([ZBBOrderPayRecordModel]?) -> Void)?) {
        var param = Parameters()
        param["orderId"] = id
        param["current"] = page
        param["size"] = 20
        YZBSign.shared.request(APIURL.zbbOrderPayRecord, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBOrderPayRecordModel>().mapArray(JSONArray: records ?? [])
                complete?(list)
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
                complete?(nil)
            }
        } failure: { error in
            complete?(nil)
        }
    }
}

class ZBBOrderPayRecordModel: NSObject, Mappable {
    //
    var nodeId: Int?
    //节点名称
    var nodeName: String?
    //结算状态 0.待结算 1.已结算 2.已退款
    var settlementStatus: String?
    //交易金额
    var transactionAmount: Int?
    //交易号，流水号
    var transactionId: String?
    //交易时间
    var transactionTime: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        nodeId <- map["nodeId"]
        nodeName <- map["nodeName"]
        settlementStatus <- map["settlementStatus"]
        transactionAmount <- map["transactionAmount"]
        transactionId <- map["transactionId"]
        transactionTime <- map["transactionTime"]
    }
}
