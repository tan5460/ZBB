//
//  IntegralDetailController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/20.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class IntegralDetailController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var topView: UIView!
    var tableView: UITableView!
    var rowsData: Array<IntegralDetailModel> = []
    let identifier = "IntegralDetailCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "积分明细"
        
        prepareTopView()
        prepareTableView()
        getChangeDetailData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    func prepareTopView() {
        
        //顶部栏
        topView = UIView()
        topView.backgroundColor = .white
        view.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(34)
        }
        
        //时间
        let timeLabel = UILabel()
        timeLabel.text = "时间"
        timeLabel.textColor = .black
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        topView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.0/3)
        }
        
        //明细
        let detailLabel = UILabel()
        detailLabel.text = "明细"
        detailLabel.textColor = .black
        detailLabel.font = UIFont.systemFont(ofSize: 14)
        topView.addSubview(detailLabel)
        
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        //积分变化
        let changeLabel = UILabel()
        changeLabel.text = "积分变化"
        changeLabel.textColor = .black
        changeLabel.font = UIFont.systemFont(ofSize: 14)
        topView.addSubview(changeLabel)
        
        changeLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(5.0/3)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        topView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 48
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(IntegralDetailCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
    }
    
    
    //MARK: - 网络请求
    
    //获取积分明细
    func getChangeDetailData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        
        self.pleaseWait()
        let parameters: Parameters = ["worker.id": userId, "type": "2"]
        let urlStr = APIURL.getChangeDetail
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<IntegralDetailModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.rowsData = modelArray
                self.tableView.reloadData()
            }
            
        }) { (error) in
            
        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! IntegralDetailCell
        
        if indexPath.row == 0 {
            cell.topLineVie.isHidden = false
        }else {
            cell.topLineVie.isHidden = true
        }
        
        let detailModel = rowsData[indexPath.row]
        cell.detailModel = detailModel
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
}
