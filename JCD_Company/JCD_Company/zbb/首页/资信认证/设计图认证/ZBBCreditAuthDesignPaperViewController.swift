//
//  ZBBCreditAuthDesignPaperViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit
import JXSegmentedView
import MJRefresh
import ObjectMapper

class ZBBCreditAuthDesignPaperViewController: BaseViewController {

    private var bottomView: UIView!
    private var applyBtn: UIButton!
    
    private var segmentDataSource: JXSegmentedTitleDataSource!
    private var segmentView: JXSegmentedView!
    private var tableView: UITableView!
    
    private var dataList = [ZBBCreditAuthDesignPaperModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设计图认证"
        createViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        applyBtn.setTitle("申请图纸认证", for: .normal)
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
        segmentDataSource.titles = ["待审核", "已审核", "审核失败"]
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
        tableView.backgroundColor = .hexColor("#F7F7F7")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(ZBBCreditAuthDesignPaperTableViewCell.self, forCellReuseIdentifier: "Cell")
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
        let vc = ZBBCreditAuthDesignPaperApplyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension ZBBCreditAuthDesignPaperViewController : JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        segmentedView.selectedIndex != index
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        tableView.mj_header?.beginRefreshing()
    }
    
}

extension ZBBCreditAuthDesignPaperViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBCreditAuthDesignPaperTableViewCell
        cell.model = dataList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataList[indexPath.row]
        let vc = ZBBCreditAuthApplyResultViewController(authType: .designPaper(id: model.id), result: .init(rawValue: model.checkStatus ?? "0") ?? .wait)
        vc.rejectReason = model.refuseReason
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ZBBCreditAuthDesignPaperViewController {
    
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
    
    private func requestDataList(with page: Int, complete: (([ZBBCreditAuthDesignPaperModel]?) -> Void)?) {
        var param = Parameters()
        param["checkStatus"] = segmentView.selectedIndex
        param["current"] = page
        param["size"] = 20
        YZBSign.shared.request(APIURL.zbbDesignDrawList, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBCreditAuthDesignPaperModel>().mapArray(JSONArray: records ?? [])
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

class ZBBCreditAuthDesignPaperModel: NSObject, Mappable {
    
    var id: String?
    //认证状态：0.待审核 1.审核通过 2.审核拒绝
    var checkStatus: String?
    //分站id
    var citySubstationId: String?
    //创建人
    var createBy: String?
    //创建时间
    var createDate: String?
    //删除标记 0.正常 1.删除
    var delFlag: String?
    //图纸名称
    var fileName: String?
    //图纸文件url,多个用逗号隔开
    var fileUrl: String?
    //上传人身份 4.材料商 6.服务商 22.消费者
    var identityType: String?
    //手机号
    var phoneNumber: String?
    //拒绝原因
    var refuseReason: String?
    //更新人
    var updateBy: String?
    //更新时间
    var updateDate: String?
    //上传人
    var uploadUser: String?
    //用户id
    var userId: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        checkStatus <- map["checkStatus"]
        citySubstationId <- map["citySubstationId"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        fileName <- map["fileName"]
        fileUrl <- map["fileUrl"]
        identityType <- map["identityType"]
        phoneNumber <- map["phoneNumber"]
        refuseReason <- map["refuseReason"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        uploadUser <- map["uploadUser"]
        userId <- map["userId"]
    }
}

    

