//
//  ZBBDelegationOrderProgressViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit
import MJRefresh
import ObjectMapper

class ZBBDelegationOrderProgressViewController: BaseViewController {

    var id: String?
    
    private var tableView: UITableView!
    private var dataList = [ZBBOrderLogModel]()
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
        tableView.register(ZBBDelegationOrderProgressTableViewCell.self, forCellReuseIdentifier: "Cell")
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

extension ZBBDelegationOrderProgressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBDelegationOrderProgressTableViewCell
        let model = dataList[indexPath.row]
        cell.config(isFirst: indexPath.row == 0,
                    isLast: indexPath.row == dataList.count - 1,
                    timeText: model.updateDate ?? model.createDate ?? "",
                    contentText: model.detail ?? "")
        return cell
    }
}

extension ZBBDelegationOrderProgressViewController {
    
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
    
    private func requestDataList(with page: Int, complete: (([ZBBOrderLogModel]?) -> Void)?) {
        var param = Parameters()
        param["orderId"] = id
        param["current"] = page
        param["size"] = 20
        YZBSign.shared.request(APIURL.zbbOrderLog, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBOrderLogModel>().mapArray(JSONArray: records ?? [])
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

class ZBBOrderLogModel: NSObject, Mappable {
    //
    var id: String?
    //创建者
    var createBy: String?
    //创建时间
    var createDate: String?
    //删除标记
    var delFlag: String?
    //动态信息
    var detail: String?
    //订单id
    var orderId: String?
    //更新者
    var updateBy: String?
    //更新时间
    var updateDate: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        id <- map["id"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        detail <- map["detail"]
        orderId <- map["orderId"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
    }
}

