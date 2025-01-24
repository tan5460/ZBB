//
//  MyInviteController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/29.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import PopupDialog

class MyInviteController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    let identifier = "MyInviteCell"
   
    var titleLB: UILabel!                       //自定义标题
    var ruleBtn: UIButton!                      //积分规则
    var totalLabel: UILabel!                    //累计积分
    var inviteCountLabel: UILabel!              //邀请数量
    
    var viewModel: MyInviteViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MyInviteViewModel()
        viewModel.delegate = self
        
        prepareNavigationItem()
        prepareTableView()
        
        viewModel.getMyInvite()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        
        let barBackground = navigationController?.navigationBar.subviews.first
        barBackground?.alpha = 0
        
        self.statusStyle = .lightContent
        navigationController?.navigationBar.tintColor = .white
        titleLB.textColor = UIColor.white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let barBackground = navigationController?.navigationBar.subviews.first
        barBackground?.alpha = 1
        
        self.statusStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.black
        titleLB.textColor = UIColor.black
        
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    func prepareNavigationItem() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        
        titleLB = UILabel()
        titleLB.textColor = UIColor.white
        titleLB.font = UIFont.systemFont(ofSize: 17)
        titleLB.text = "我的邀请"
        navigationItem.titleView = titleLB
        titleLB.sizeToFit()
        
        // 邀请规则
        ruleBtn = UIButton(type: .custom)
        ruleBtn.frame = CGRect.init(x: 0, y: 0, width: 60, height: 30)
        ruleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        ruleBtn.setTitle("邀请规则", for: .normal)
        ruleBtn.setTitleColor(.white, for: .normal)
        ruleBtn.setTitleColor(UIColor.init(white: 1, alpha: 0.4), for: .highlighted)
        ruleBtn.addTarget(self, action: #selector(ruleAction), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: ruleBtn)
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 63
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.register(MyInviteCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if #available(iOS 11.0, *) {
            
            tableView.contentInsetAdjustmentBehavior = .never
        }else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        //头视图
        let headerHeight: CGFloat = 180*(IS_iPad ? PublicSize.PadRateHeight:PublicSize.RateHeight)
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: headerHeight))
        let img = UIImageView(image: PublicColor.gradualColorImage)
        headerView.addSubview(img)
        img.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.tableHeaderView = headerView
        
        //累计获得积分标题
        let totalTitleLabel = UILabel()
        totalTitleLabel.text = "累计获得积分"
        totalTitleLabel.textColor = .white
        totalTitleLabel.font = UIFont.systemFont(ofSize: 13)
        headerView.addSubview(totalTitleLabel)
        
        let totalTitleTop: CGFloat = 80*(IS_iPad ? PublicSize.PadRateHeight:PublicSize.RateHeight)
        
        totalTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(totalTitleTop)
        }
        
        //累计获得积分
        totalLabel = UILabel()
        totalLabel.text = "0"
        totalLabel.textColor = .white
        totalLabel.font = UIFont.systemFont(ofSize: 24)
        headerView.addSubview(totalLabel)
        
        totalLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(totalTitleLabel.snp.bottom).offset(5)
        }
        
        //邀请数量
        inviteCountLabel = UILabel()
        inviteCountLabel.text = "您已成功辅导0位会员"
        inviteCountLabel.textColor = .white
        inviteCountLabel.font = UIFont.systemFont(ofSize: 13)
        headerView.addSubview(inviteCountLabel)
        
        inviteCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.bottom.equalTo(-10)
        }
        
    }
    
    
    
    //MARK: - 触发事件
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func ruleAction() {
        
        let popup = PopupDialog(title: "请咨询当地运营商", message: nil, buttonAlignment: .vertical)
        let sureBtn = AlertButton(title: "确认") {}
        popup.addButtons([sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.dataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MyInviteCell
        
        if let valueList = viewModel.inviteModel?.workerList {
            
            let workerModel = valueList[indexPath.row]
            cell.workerModel = workerModel
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if navigationController?.navigationBar.shadowImage != nil {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
        }
        
        let maxAlphaOffset: CGFloat = 10
        let offset: CGFloat = scrollView.contentOffset.y
        let alpha: CGFloat = offset/maxAlphaOffset
        
        let barBackground = navigationController?.navigationBar.subviews.first
        barBackground?.alpha = alpha
        
        if alpha == 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.05) {
                barBackground?.alpha = 0
            }
        }
        
        if offset >= maxAlphaOffset {
            
            if UIApplication.shared.statusBarStyle == .lightContent {
                self.statusStyle = .default
                navigationController?.navigationBar.tintColor = UIColor.black
                titleLB.textColor = UIColor.black
                ruleBtn.setTitleColor(.black, for: .normal)
            }
        }
        else {
            
            if UIApplication.shared.statusBarStyle == .default {
                self.statusStyle = .lightContent
                navigationController?.navigationBar.tintColor = .white
                titleLB.textColor = UIColor.white
                ruleBtn.setTitleColor(.white, for: .normal)
            }
        }
    }

}
// MARK: - MyInviteViewModelDelegate
extension MyInviteController: MyInviteViewModelDelegate {
    
    func alertInfo() {
    }
    
    func wait() {
        self.pleaseWait()
    }
    
    func updateUI() {
        
        self.tableView.reloadData()
        
        self.inviteCountLabel.text = viewModel.inviteCount
        
        self.totalLabel.text = viewModel.total
    }
}
