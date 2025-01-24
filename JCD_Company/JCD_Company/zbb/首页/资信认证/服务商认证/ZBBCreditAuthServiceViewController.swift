//
//  ZBBCreditAuthServiceViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit
import JXSegmentedView
import MJRefresh
import ObjectMapper

class ZBBCreditAuthServiceViewController: BaseViewController {
    
    ///0.待审核 1.审核通过 2.审核拒绝
    var authStatus: String?
    ///4:品牌商 6服务商 22:消费者
    var authType: String?
    ///拒绝原因
    var rejectReason: String?


    private var bottomView: UIView!
    private var applyBtn: UIButton!
    
    private var segmentDataSource: JXSegmentedTitleDataSource!
    private var segmentView: JXSegmentedView!
    private var tableView: UITableView!
    
    private var dataList = [ZBBCreditAuthServiceListModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "已认证服务商"
        createViews()
        refreshData()
    }
    
    private func createViews() {
        view.backgroundColor = .hexColor("#F7F7F7")
        
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(54+PublicSize.kBottomOffset)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = .hexColor("#EFEFEF")
        bottomView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        applyBtn = UIButton(type: .custom)
        applyBtn.layer.cornerRadius = 22
        applyBtn.layer.masksToBounds = true
        applyBtn.backgroundColor = .hexColor("#007E41")
        applyBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        applyBtn.setTitle("申请成为服务商", for: .normal)
        applyBtn.setTitleColor(.white, for: .normal)
        applyBtn.addTarget(self, action: #selector(applyBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(applyBtn)
        applyBtn.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
        
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
        segmentDataSource.titles = ["装修公司", "项目经理", "经纪人", "工匠", "设计师"]
        segmentDataSource.titleNormalFont = .systemFont(ofSize: 14)
        segmentDataSource.titleNormalColor = .hexColor("#999999")
        segmentDataSource.titleSelectedFont = .systemFont(ofSize: 14, weight: .bold)
        segmentDataSource.titleSelectedColor = .hexColor("#131313")
        segmentDataSource.isTitleColorGradientEnabled = true
        
        segmentView = JXSegmentedView()
        segmentView.backgroundColor = .white
        segmentView.delegate = self
        segmentView.dataSource = segmentDataSource
        segmentView.contentEdgeInsetLeft = 15
        segmentView.contentEdgeInsetRight = 15
        segmentView.indicators = [indicator]
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        segmentView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(ZBBCreditAuthServiceTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomView.snp.top)
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.loadMoreData()
        })
    }
    
    @objc private func applyBtnAction(_ sender: UIButton) {
        if let authType = authType, let authStatus = authStatus  {
            if authType == "4", (authStatus == "0" || authStatus == "1") {
                let vc = ZBBCreditAuthNoticeViewController()
                vc.msgText = "您已认证成为材料商，不可再申请成为服务商！"
                let popDialog = PopupDialog(viewController: vc, transitionStyle: .zoomIn)
                present(popDialog, animated: true)
                return
            } else if authType == "22", (authStatus == "0" || authStatus == "1") {
                let vc = ZBBCreditAuthNoticeViewController()
                vc.msgText = "您已认证成为消费者，不可再申请成为服务商！"
                let popDialog = PopupDialog(viewController: vc, transitionStyle: .zoomIn)
                present(popDialog, animated: true)
                return
            } else if authType == "6" {
                let vc = ZBBCreditAuthApplyResultViewController(authType: .service, result: .init(rawValue: authStatus) ?? .wait)
                vc.rejectReason = rejectReason
                navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        let vc = ZBBCreditAuthServiceApplyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ZBBCreditAuthServiceViewController : JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        segmentedView.selectedIndex != index
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        tableView.mj_header?.beginRefreshing()
    }
    
}

extension ZBBCreditAuthServiceViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBCreditAuthServiceTableViewCell
        let model = dataList[indexPath.row]
        cell.nameText = segmentView.selectedIndex == 0 ? model.companyName : model.fullName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ZBBCreditAuthServiceViewController {
    
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
    
    private func requestDataList(with page: Int, complete: (([ZBBCreditAuthServiceListModel]?) -> Void)?) {
        var param = Parameters()
        param["identityType"] = segmentView.selectedIndex + 1
        param["checkStatus"] = 1
        param["current"] = page
        param["size"] = 20
        YZBSign.shared.request(APIURL.zbbAuthServices, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBCreditAuthServiceListModel>().mapArray(JSONArray: records ?? [])
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

class ZBBCreditAuthServiceListModel: NSObject, Mappable {
    
    var id: String?
    var checkStatus: Int?
    var citySubstationId: String?
    var companyName: String?
    var createDate: String?
    var delFlag: Int?
    var fullName: String?
    var idCardB: String?
    var idCardF: String?
    var identityType: Int?
    var password: String?
    var phoneNumber: Int?
    var qualificationCertificateUrl: String?
    var refuseReason: String?
    var retentionMoney: String?
    var updateDate: String?
    var userId: String?
    var workType: Int?
    var workYears: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        checkStatus <- map["checkStatus"]
        citySubstationId <- map["citySubstationId"]
        companyName <- map["companyName"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        fullName <- map["fullName"]
        idCardB <- map["idCardB"]
        idCardF <- map["idCardF"]
        identityType <- map["identityType"]
        password <- map["password"]
        phoneNumber <- map["phoneNumber"]
        qualificationCertificateUrl <- map["qualificationCertificateUrl"]
        refuseReason <- map["refuseReason"]
        retentionMoney <- map["retentionMoney"]
        updateDate <- map["updateDate"]
        userId <- map["userId"]
        workType <- map["workType"]
        workYears <- map["workYears"]
    }
}
