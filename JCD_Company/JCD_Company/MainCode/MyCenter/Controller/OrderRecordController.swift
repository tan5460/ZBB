//
//  OrderRecordController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/12.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper

class OrderRecordController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var rowsData: Array<OrderRecordModel> = []
    let identifier = "OrderRecordCell"
    let sectionHeaderId = "sectionHeaderView"
    
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>> 交易记录界面释放 <<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "交易记录"
        
        prepareTableView()
        //开始刷新
        tableView.mj_header?.beginRefreshing()
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 55
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OrderRecordCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let noMoreLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 44))
        noMoreLabel.text = "客户端只能查看最近三个月记录呦~"
        noMoreLabel.textAlignment = .center
        noMoreLabel.textColor = PublicColor.placeholderTextColor
        noMoreLabel.font = UIFont.boldSystemFont(ofSize: 13)
        tableView.tableFooterView = noMoreLabel
        
        //--注册组头
        tableView.register(OrderRecordHeaderView.self, forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(loadData))
        tableView.mj_header = header
    }

    
    //MARK: - 网络请求
    
    @objc func loadData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        
        let parameters: Parameters = ["workerId": userId, "month": "3"]
        let urlStr = APIURL.getOrderCount
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let array = Utils.getReadArr(data: (response as AnyObject) as! NSDictionary, field: "data")
                let modelArray = Mapper<OrderRecordModel>().mapArray(JSONArray: array as! [[String : Any]])
                self.rowsData = modelArray
                if self.rowsData.count > 0 {
                    if let model = self.rowsData.first {
                        model.isShow = true
                    }
                }
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionModel = rowsData[section]
        
        if let count = sectionModel.orderList?.count {
            return sectionModel.isShow ? count : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //主材
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OrderRecordCell
        
        if indexPath.row == 0 {
            cell.lineView.isHidden = true
        }else {
            cell.lineView.isHidden = false
        }
        
        let sectionModel = rowsData[indexPath.section]
        if let orderArray = sectionModel.orderList {
            
            let cellModel = orderArray[indexPath.row]
            cell.nameLabel.text = "自由组合"
            
            if let valueStr = cellModel.createDate {
                cell.timeLabel.text = valueStr
            }
            cell.moneyLabel.text = "+¥\(cellModel.payMoney ?? 0)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId) as! OrderRecordHeaderView
        
        header.titleLabel.text = ""
        header.detailLabel.text = ""
        
        let sectionModel = rowsData[section]
        header.upOrDownBtn.isSelected = sectionModel.isShow
        header.lineView.isHidden = !sectionModel.isShow
        header.upOrDownBlock = {() in
            sectionModel.isShow = !sectionModel.isShow
            
            tableView.reloadSections([section], with: .fade)
        }
        if let valueStr = sectionModel.month?.intValue {
            
            header.titleLabel.text = "\(valueStr)月成交额:"
            
            let calendar: Calendar = Calendar(identifier: .gregorian)
            var comps: DateComponents = DateComponents()
            comps = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: Date())
            
            if valueStr == comps.month {
                header.titleLabel.text = "本月成交额:"
            }
        }
        
        if let valueStr = sectionModel.payCount {
            
            //初始化NumberFormatter
            let format = NumberFormatter()
            //设置numberStyle(有多种格式)
            format.numberStyle = .currency
            //转换后的string
            var newValue = format.string(from: valueStr)!
            
            let index = newValue.index(newValue.endIndex, offsetBy: -1)
            newValue = String(newValue.prefix(upTo: index))
            header.detailLabel.text = newValue
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 54
    }
    
}
