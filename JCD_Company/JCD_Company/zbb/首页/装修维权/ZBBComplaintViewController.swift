//
//  ZBBComplaintViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/4.
//

import UIKit
import MJRefresh
import JXSegmentedView
import ObjectMapper

class ZBBComplaintViewController: BaseViewController {

    private var segmentDataSource: JXSegmentedTitleDataSource!
    private var segmentView: JXSegmentedView!
    private var tableView: UITableView!
    private var applyBtn: UIButton!
    
    private var dataList = [ZBBComplaintListModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "装修维权"
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
        segmentDataSource.titles = ["待受理", "已受理", "处理结果"]
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
        tableView.register(ZBBComplaintTableViewCell.self, forCellReuseIdentifier: "Cell")
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
        
        
        applyBtn = UIButton(type: .custom)
        applyBtn.setImage(UIImage(named: "zbbt_wyts"), for: .normal)
        applyBtn.addTarget(self, action: #selector(applyBtnAction(_:)), for: .touchUpInside)
        view.addSubview(applyBtn)
        applyBtn.snp.makeConstraints { make in
            make.width.height.equalTo(54)
            make.right.equalTo(-10)
            make.bottom.equalTo(-110-PublicSize.kBottomOffset)
        }
    }
    
    @objc private func applyBtnAction(_ sender: UIButton) {
        let vc = ZBBComplaintApplyViewController()
        vc.applySuccess = {[weak self] in
            if let index = self?.segmentView.selectedIndex, index == 0 {
                self?.tableView.mj_header?.beginRefreshing()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ZBBComplaintViewController : JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        segmentedView.selectedIndex != index
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        tableView.mj_header?.beginRefreshing()
    }
    
}

extension ZBBComplaintViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBComplaintTableViewCell
        cell.model = dataList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

extension ZBBComplaintViewController {
    
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
    
    private func requestDataList(with page: Int, complete: (([ZBBComplaintListModel]?) -> Void)?) {
        var param = Parameters()
        param["current"] = page
        param["size"] = 20
        param["userId"] = UserData1.shared.tokenModel?.userId
        param["dealState"] = segmentView.selectedIndex
        YZBSign.shared.request(APIURL.zbbDecorationList, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBComplaintListModel>().mapArray(JSONArray: records ?? [])
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

class ZBBComplaintListModel: NSObject, Mappable {
    
    var updateDate: String?
    var delFlag: String?
    var citySubstationId: String?
    
    var id: String?
    var userId: String?
    var createDate: String?
    
    var problemType: Int?
    var complaintObject: String?
    var problemDescription: String?
    var problemPicUrl: String?
    
    
    var phoneNumber: String?
    
    var rightsDefenderName: String?
    
    var dealState: Int?
    var dealPicUrl: String?
    var dealResult: String?
    
    
    
    override init() {
        super.init()
    }
    
    required init?(map: ObjectMapper.Map) {
    
    }
    
    func mapping(map: ObjectMapper.Map) {
        updateDate <- map["updateDate"]
        delFlag <- map["delFlag"]
        citySubstationId <- map["citySubstationId"]
        
        id <- map["id"]
        userId <- map["userId"]
        createDate <- map["createDate"]
        
        problemType <- map["problemType"]
        complaintObject <- map["complaintObject"]
        problemDescription <- map["problemDescription"]
        problemPicUrl <- map["problemPicUrl"]
        
        phoneNumber <- map["phoneNumber"]
        
        rightsDefenderName <- map["rightsDefenderName"]
        
        dealState <- map["dealState"]
        dealPicUrl <- map["dealPicUrl"]
        dealResult <- map["dealResult"]
    }
    
    
    
    
}

