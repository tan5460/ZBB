//
//  ZBBDecorationSubsidyRecordViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/7.
//

import UIKit
import JXSegmentedView
import MJRefresh
import ObjectMapper

class ZBBDecorationSubsidyRecordViewController: BaseViewController {

    
    private var segmentDataSource: JXSegmentedTitleDataSource!
    private var segmentView: JXSegmentedView!
    private var tableView: UITableView!
    
    private var dataList = [ZBBSubsidyOrderListModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "申领记录"
        createViews()
        refreshData()
    }
    
    private func createViews() {
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 3
        indicator.indicatorCornerRadius = 1.5
        indicator.verticalOffset = 6
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 1.5
        gradientLayer.masksToBounds = true
        gradientLayer.frame = CGRectMake(0, 0, 20, 3)
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 0)
        gradientLayer.colors = [UIColor.hexColor("#47DC94").cgColor, UIColor.hexColor("#007E41").cgColor]
        indicator.layer.addSublayer(gradientLayer)
        
        segmentDataSource = JXSegmentedTitleDataSource()
        segmentDataSource.titles = ["待初审", "待复审", "待银联打款", "待发放", "已补贴"]
        segmentDataSource.titleNormalFont = .systemFont(ofSize: 14)
        segmentDataSource.titleNormalColor = .hexColor("#999999")
        segmentDataSource.titleSelectedFont = .systemFont(ofSize: 14, weight: .bold)
        segmentDataSource.titleSelectedColor = .hexColor("#131313")
        segmentDataSource.isTitleColorGradientEnabled = true
        
        segmentView = JXSegmentedView()
        segmentView.backgroundColor = .white
        segmentView.delegate = self
        segmentView.dataSource = segmentDataSource
        segmentView.indicators = [indicator]
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .hexColor("#F7F7F7")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(ZBBDecorationSubsidyRecordTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
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

extension ZBBDecorationSubsidyRecordViewController : JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        segmentedView.selectedIndex != index
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        tableView.mj_header?.beginRefreshing()
    }
    
}

extension ZBBDecorationSubsidyRecordViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBDecorationSubsidyRecordTableViewCell
        cell.model = dataList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ZBBOrderDetailViewController()
        vc.orderId = dataList[indexPath.row].orderId
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ZBBDecorationSubsidyRecordViewController {
    
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
    
    private func requestDataList(with page: Int, complete: (([ZBBSubsidyOrderListModel]?) -> Void)?) {
        var param = Parameters()
        switch segmentView.selectedIndex {
        case 0:
            param["status"] = 2
        case 1:
            param["status"] = 4
        case 2:
            param["status"] = 6
        case 3:
            param["status"] = 7
        case 4:
            param["status"] = 8
        default:
            break
        }
        param["current"] = page
        param["size"] = 20
        YZBSign.shared.request(APIURL.zbbSubsidyOrderList, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBSubsidyOrderListModel>().mapArray(JSONArray: records ?? [])
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
