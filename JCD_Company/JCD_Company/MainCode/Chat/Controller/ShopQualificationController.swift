//
//  ShopQualificationController.swift
//  YZB_Company
//
//  Created by yzb_ios on 29.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class ShopQualificationController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var comId = ""
    var merchant : MerchantModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "公司资质"
        
        prepareTableView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 60
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.separatorColor = PublicColor.partingLineColor
        tableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 10))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 120))
        let footerLabel = UILabel()
        footerLabel.numberOfLines = 0
        footerLabel.font = UIFont.systemFont(ofSize: 11)
        footerLabel.text = "注：以上营业执照信息来源于供应商自行申报或工商系统数据，具体以工商部门登记为准。经营者需确保信息真实有效，平台也将定期核查。如与实际不符，为避免违规，请联系当地工商部门或平台客服更新"
        footerLabel.textColor = PublicColor.minorTextColor
        footerView.addSubview(footerLabel)
        
        footerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        
        footerLabel.attributedText = footerLabel.text?.changeLineSpaceForLabel(lineSpacing: 5)
        tableView.tableFooterView = footerView
    }
    
    
    //MARK: - 网络请求
    
    //提现记录
    func loadData() {
        
        self.pleaseWait()
        
        let parameters: Parameters = ["id": comId]
        let urlStr = APIURL.getMerchantInfo + comId
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model = Mapper<MerchantModel>().map(JSON: dataDic as! [String : Any])
                self.merchant = model
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            
        }
    }
    

    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "comInfo")
        
        cell.selectionStyle = .none
        cell.detailTextLabel?.text = "未知"
        cell.textLabel?.textColor = PublicColor.minorTextColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.detailTextLabel?.textColor = PublicColor.commonTextColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.numberOfLines = 0
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "统一社会信用代码/营业执照注册号:"
            
            if let valueStr = merchant?.certCode {
                cell.detailTextLabel?.text = valueStr
            }
        }else if indexPath.row == 1 {
            cell.textLabel?.text = "公司名称:"
            
            if let valueStr = merchant?.name {
                cell.detailTextLabel?.text = valueStr
            }
        }else if indexPath.row == 2 {
            cell.textLabel?.text = "注册地址:"
            
            if let valueStr = merchant?.address {
                cell.detailTextLabel?.text = valueStr
            }
        }else if indexPath.row == 3 {
            cell.textLabel?.text = "法定代表人:"
            
            if let valueStr = merchant?.legalRepresentative {
                cell.detailTextLabel?.text = valueStr
            }
        }else if indexPath.row == 4 {
            cell.textLabel?.text = "注册资本:"
            
            if let valueStr = merchant?.registeredCapital {
                cell.detailTextLabel?.text = valueStr
            }
        }else if indexPath.row == 5 {
            cell.textLabel?.text = "营业期限:"
            
            var timeStart = "0000-00-00"
            var timeEnd = "0000-00-00"
            if let valueStr = merchant?.businessTermStart {
                timeStart = valueStr
            }
            if let valueStr = merchant?.businessTermEnd {
                timeEnd = valueStr
            }
            
            cell.detailTextLabel?.text = timeStart + " 至 " + timeEnd
        }else if indexPath.row == 6 {
            cell.textLabel?.text = "企业经营范围:"
            
            if let valueStr = merchant?.businessScope {
                cell.detailTextLabel?.text = valueStr
            }
        }
        
        cell.detailTextLabel?.attributedText =     (cell.detailTextLabel?.text)?.changeLineSpaceForLabel()

        
        return cell
    }
}
