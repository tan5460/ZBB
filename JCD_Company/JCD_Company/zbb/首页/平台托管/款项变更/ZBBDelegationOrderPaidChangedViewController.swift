//
//  ZBBDelegationOrderPaidChangedViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit
import MJRefresh
import ObjectMapper

class ZBBDelegationOrderPaidChangedViewController: BaseViewController {
    
    var id: String?
    
    private var tableView: UITableView!
    private var dataList = [ZBBOrderWaitPayNodeModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单动态"
        createViews()
        refreshData()
    }
    
    private func createViews() {
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .hexColor("#F7F7F7")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(ZBBDelegationOrderPaidChangedTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.bottom.equalTo(0)
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.loadMoreData()
        })
    }


}

extension ZBBDelegationOrderPaidChangedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBDelegationOrderPaidChangedTableViewCell
        cell.model = dataList[indexPath.row]
        return cell
    }
}

extension ZBBDelegationOrderPaidChangedViewController {
    
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
    
    private func requestDataList(with page: Int, complete: (([ZBBOrderWaitPayNodeModel]?) -> Void)?) {
        var param = Parameters()
        param["orderId"] = id
        param["current"] = page
        param["size"] = 20
        YZBSign.shared.request(APIURL.zbbOrderWaitPayNode, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBOrderWaitPayNodeModel>().mapArray(JSONArray: records ?? [])
                complete?(list)
            } else {
                complete?(nil)
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            complete?(nil)
        }

    }
}

class ZBBOrderWaitPayNodeModel: NSObject, Mappable {
    //ID
    var id: String?
    //节点id
    var nodeId: String?
    //增项费用
    var additionalAmount: Int?
    //增项备注
    var additionalRemarks: String?
    //节点金额
    var nodeAmount: Int?
    //节点名称
    var nodeName: String?
    //付款比例（%）
    var nodeRatio: Int?
    //节点状态 2.待支付
    var nodeStatus: String?
    //订单id
    var orderId: String?
    //已付金额
    var paidAmount: Int?
    //节点小计
    var totalAmount: Int?
    //待付金额
    var waitPayAmount: Int?
    
    override init() {
        super.init()
    }
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        nodeId <- map["nodeId"]
        additionalAmount <- map["additionalAmount"]
        additionalRemarks <- map["additionalRemarks"]
        nodeAmount <- map["nodeAmount"]
        nodeName <- map["nodeName"]
        nodeRatio <- map["nodeRatio"]
        nodeStatus <- map["nodeStatus"]
        orderId <- map["orderId"]
        paidAmount <- map["paidAmount"]
        totalAmount <- map["totalAmount"]
        waitPayAmount <- map["waitPayAmount"]
    }
}

