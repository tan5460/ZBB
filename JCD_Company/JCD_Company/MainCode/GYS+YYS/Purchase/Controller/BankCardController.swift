//
//  BankCardController.swift
//  YZB_Company
//
//  Created by yzb_ios on 23.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Alamofire
import ObjectMapper

class BankCardController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView : UITableView!
    var rowsData: Array<BankCardModel> = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    var selBankCardBlock: ((_ bankCardModel: BankCardModel)->())?
    
    //支付用
    var userCustId = ""
    var purchaseOrderId = ""
    var payMoney: Double = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "请选择银行卡"
        prepareTableView()
        tableView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        tableView.rowHeight = 110
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(BankCardCell.self, forCellReuseIdentifier: BankCardCell.self.description())
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    
    //MARK: - 网络请求
    
    func loadData() {
        
    }

    
    //MARK: - UITableViewDelegate && UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if rowsData.count > 3 {
            return 3
        }
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BankCardCell.self.description()) as! BankCardCell
        
        let cellModel = rowsData[indexPath.row]
        cell.bankCardModel = cellModel
        
        if indexPath.row == 0 {
            cell.backView.backgroundColor = PublicColor.bankYellowColor
        }else if indexPath.row == 1 {
            cell.backView.backgroundColor = PublicColor.bankBlueColor
        }else if indexPath.row == 2 {
            cell.backView.backgroundColor = PublicColor.bankPurpleColor
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellModel = rowsData[indexPath.row]
        
        if userCustId == "" {
            //提现选卡
            if let block = selBankCardBlock {
                block(cellModel)
                navigationController?.popViewController(animated: true)
            }
        }else {
            //支付选卡
            let vc = PayOrderController()
            vc.userCustId = userCustId
            vc.bankCardModel = cellModel
            vc.payMoney = payMoney
            vc.purchaseOrderId = purchaseOrderId
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
