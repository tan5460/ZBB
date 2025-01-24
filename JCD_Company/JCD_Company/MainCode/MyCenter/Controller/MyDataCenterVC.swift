//
//  MyDataCenterVC.swift
//  YZB_Company
//
//  Created by Cloud on 2020/3/10.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Then
import Alamofire
import MJRefresh
import ObjectMapper

class MyDataCenterVC: BaseViewController {

    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    private var pageNum = 1
    private var pageSize = 15
    private var dataSource = [DataCenterModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "资料中心"
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = true
        }
        tableView.delegate = self
        tableView.dataSource = self
        // 下拉刷新
        tableView.refreshHeader { [weak self] in
            self?.headerRefresh()
        }
        tableView.refreshFooter { [weak self] in
            self?.footerRefresh()
        }
        loadData()
        prepareNoDateView("暂无数据")
        noDataView.isHidden = false
    }
    
    @objc private func headerRefresh() {
        pageNum = 1
        loadData()
    }
    
    @objc private func footerRefresh() {
        pageNum += 1
        loadData()
    }
    
    private func loadData() {
        var parameters = Parameters()
        parameters["size"] = pageSize
        parameters["current"] = pageNum
        YZBSign.shared.request(APIURL.getDownloadData, method: .get, parameters: parameters, success: { (response) in
            self.tableView.endHeaderRefresh()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<DataCenterModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.pageNum == 1 {
                    self.dataSource = modelArray
                } else {
                    self.dataSource.append(contentsOf: modelArray)
                }
                if modelArray.count == self.pageSize {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
                if self.dataSource.count > 0 {
                    self.noDataView.isHidden = true
                } else {
                    self.noDataView.isHidden = false
                }
                self.tableView.reloadData()
            }
        }) { (error) in
            self.noDataView.isHidden = false
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
}

extension MyDataCenterVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.createDate
        _ = cell.textLabel?.textColor(PublicColor.c333).font(14, weight: .bold)
        _ = cell.detailTextLabel?.textColor(PublicColor.c999).font(12)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = MyDataCenterDetailVC()
        vc.fileUrls = dataSource[indexPath.row].fileUrls
        vc.dateStr = dataSource[indexPath.row].createDate
        navigationController?.pushViewController(vc, animated: true)
    }
}



class DataCenterModel: NSObject, Mappable {
    var createDate: String?       //员工id
    var fileUrls: String?          //资料下载列表
    var content: String?  // 文本
    var title: String? // 标题
    var id: String? //
    var createBy : AnyObject?
    var files : AnyObject?
    var sizeStr : AnyObject?
    var type : String?
    var updateBy : String?
    var updateDate : String?
    var urls : AnyObject?

    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }

    func mapping(map: Map) {
        createDate <- map["createDate"]
        fileUrls <- map["fileUrls"]
        content <- map["content"]
        title <- map["title"]
        id <- map["id"]
        
        createBy <- map["createBy"]
        files <- map["files"]
        sizeStr <- map["sizeStr"]
        type <- map["type"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        urls <- map["urls"]
    }
}
