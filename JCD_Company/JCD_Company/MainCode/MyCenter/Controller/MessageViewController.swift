//
//  MessageViewController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/13.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper

class MessageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    let identifier = "MessageCell"

    var viewModel: MessageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "系统通知"
        viewModel = MessageViewModel()
        viewModel.delegate = self
        
        prepareTableView()
        //开始刷新
        tableView.mj_header?.beginRefreshing()
    }

    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 288
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer = footer
        tableView.mj_footer?.isHidden = true
    }
    
    @objc func headerRefresh() {
        viewModel.headerRefresh()
    }
    
    @objc func footerRefresh() {
        viewModel.footerRefresh()
    }
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.rowDataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCell
        
        let msgModel = viewModel.rowsData[indexPath.row]
        cell.messageModel = msgModel
        cell.detailBlock = { [weak self] in
//            var detailUrl = ""
//            if let valueStr = msgModel.id {
//                detailUrl = APIURL.msgDetail + valueStr
//            }
//            let vc = BrandDetailController()
//            vc.title = "通知详情"
//            vc.detailUrl = detailUrl
//            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
}
extension MessageViewController: MessageViewModelDelegate {
    
    func updateUI() {
        tableView.reloadData()
    }
    
    func endRefresh() {
        // 结束刷新
        tableView.mj_header?.endRefreshing()
        tableView.mj_footer?.endRefreshing()
        tableView.mj_footer?.isHidden = false
    }
    
    func endRefreshingWithNoMoreData() {
        tableView.mj_footer?.endRefreshingWithNoMoreData()
    }
    
    func resetNoMoreData() {
        tableView.mj_footer?.resetNoMoreData()
    }

}
