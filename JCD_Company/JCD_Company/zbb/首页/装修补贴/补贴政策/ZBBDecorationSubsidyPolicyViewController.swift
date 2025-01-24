//
//  ZBBDecorationSubsidyPolicyViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/7.
//

import UIKit
import MJRefresh
import ObjectMapper

class ZBBDecorationSubsidyPolicyViewController: BaseViewController {

    private var tableView: UITableView!
    private var dataList = [ZBBSubsidyPolicyModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "补贴政策"
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
        tableView.register(ZBBDecorationSubsidyPolicyTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.bottom.equalTo(0)
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
//        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
//            self?.loadMoreData()
//        })
    }

}

extension ZBBDecorationSubsidyPolicyViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBDecorationSubsidyPolicyTableViewCell
        cell.policyTitle = dataList[indexPath.row].label
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ZBBWebViewController()
        vc.url = dataList[indexPath.row].value
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ZBBDecorationSubsidyPolicyViewController {
    
    private func refreshData() {
        requestDataList(with: 1) {[weak self] list in
            self?.tableView.mj_header?.endRefreshing()
            self?.page = 1
            self?.dataList.removeAll()
            self?.dataList.append(contentsOf: list ?? [])
            self?.tableView.reloadData()
            if let list = list, list.count == 0 {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self?.tableView.mj_footer?.resetNoMoreData()
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
    
    private func requestDataList(with page: Int, complete: (([ZBBSubsidyPolicyModel]?) -> Void)?) {
        var param = Parameters()
//        param["current"] = page
//        param["size"] = 10
        YZBSign.shared.request(APIURL.zbbSubsidyPolicy) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqArr(data: response as AnyObject)
                let list = Mapper<ZBBSubsidyPolicyModel>().mapArray(JSONArray: data as? [[String : Any]] ?? [])
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

class ZBBSubsidyPolicyModel: NSObject, Mappable {
    //
    var id: Int? // 282,
    //
    var type: String? // : "subsidy_policy",
    //
    var value: String? // "https:\/\/zhubaobao.obs.cn-east-3.myhuaweicloud.com\/subsidyPolicy\/2.pdf",
    //
    var delFlag: String? //"0",
    //
    var remarks: String? // null,
    //
    var sort: Int? // 1,
    //
    var label: String? //"晋商消费〔2024〕136号（主、联）",
    //
    var createTime: String? //"2021-05-20 16:07:58",
    //
    var updateTime: String? //"2025-01-08 16:06:45"
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        value <- map["value"]
        delFlag <- map["delFlag"]
        remarks <- map["remarks"]
        sort <- map["sort"]
        label <- map["label"]
        createTime <- map["createTime"]
        updateTime <- map["updateTime"]
    }
}
