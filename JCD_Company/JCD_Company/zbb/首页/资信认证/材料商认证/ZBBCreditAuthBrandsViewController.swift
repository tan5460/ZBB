//
//  ZBBCreditAuthBrandsViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit
import ObjectMapper

class ZBBCreditAuthBrandsViewController: BaseViewController {
    
    ///0.待审核 1.审核通过 2.审核拒绝
    var authStatus: String?
    ///4:品牌商 6服务商 22:消费者
    var authType: String?
    ///拒绝原因
    var rejectReason: String?

    private var bottomView: UIView!
    private var applyBtn: UIButton!
    
    private var leftView: ZBBCreditAuthBrandsLeftView!
    private var rightBackView: UIView!
    private var rightTableView: UITableView!
    
    private var list: [ZBBAuthBrandListModel]?
    private var authInfo: [String : Any]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "已认证品牌"
        createViews()
        requestAuthBrandList()
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
        applyBtn.setTitle("申请成为材料商", for: .normal)
        applyBtn.setTitleColor(.white, for: .normal)
        applyBtn.addTarget(self, action: #selector(applyBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(applyBtn)
        applyBtn.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
        
        leftView = ZBBCreditAuthBrandsLeftView()
        leftView.selectedClosure = {[weak self] index in
            if index >= 0, index < (self?.rightTableView.numberOfRows(inSection: 0) ?? 0) - 1 {
                self?.rightTableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
            }
        }
        view.addSubview(leftView)
        leftView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.width.equalTo(95.0/375.0*SCREEN_WIDTH)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        rightBackView = UIView()
        rightBackView.backgroundColor = .white
        view.addSubview(rightBackView)
        rightBackView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(leftView.snp.right)
            make.right.equalTo(0)
            make.bottom.equalTo(leftView)
        }
        
        rightTableView = UITableView(frame: .zero, style: .plain)
        rightTableView.backgroundColor = .clear
        rightTableView.delegate = self
        rightTableView.dataSource = self
        rightTableView.tableFooterView = UIView()
        rightTableView.showsVerticalScrollIndicator = false
        rightTableView.separatorStyle = .none
        rightTableView.register(ZBBCreditAuthBrandsTableViewCell.self, forCellReuseIdentifier: "Cell")
        rightBackView.addSubview(rightTableView)
        rightTableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rightBackView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 10)
    }
    
    @objc private func applyBtnAction(_ sender: UIButton) {
        if let authType = authType, let authStatus = authStatus  {
            if authType == "22", (authStatus == "0" || authStatus == "1") {
                let vc = ZBBCreditAuthNoticeViewController()
                vc.msgText = "您已认证成为消费者，不可再申请成为材料商！"
                let popDialog = PopupDialog(viewController: vc, transitionStyle: .zoomIn)
                present(popDialog, animated: true)
                return
            } else if authType == "6", (authStatus == "0" || authStatus == "1") {
                let vc = ZBBCreditAuthNoticeViewController()
                vc.msgText = "您已认证成为服务商，不可再申请成为材料商！"
                let popDialog = PopupDialog(viewController: vc, transitionStyle: .zoomIn)
                present(popDialog, animated: true)
                return
            } else if authType == "4" {
                let vc = ZBBCreditAuthApplyResultViewController(authType: .brands, result: .init(rawValue: authStatus) ?? .wait)
                vc.rejectReason = rejectReason
                navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        let vc = ZBBCreditAuthBrandsApplyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ZBBCreditAuthBrandsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        leftView.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBCreditAuthBrandsTableViewCell
        cell.title = leftView.titles[indexPath.row]
        cell.items = list?[indexPath.row].brandList ?? []
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let firstIndexPath = tableView.indexPathsForVisibleRows?.first {
            leftView.selectedIndex = firstIndexPath.row
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let firstIndexPath = rightTableView.indexPathsForVisibleRows?.first, !decelerate {
            leftView.selectedIndex = firstIndexPath.row
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let firstIndexPath = rightTableView.indexPathsForVisibleRows?.first {
            leftView.selectedIndex = firstIndexPath.row
        }
    }
}

extension ZBBCreditAuthBrandsViewController {
    
    private func requestAuthBrandList() {
        YZBSign.shared.request(APIURL.zbbAuthBrands, method: .get) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqArr(data: response as AnyObject)
                self?.list = Mapper<ZBBAuthBrandListModel>().mapArray(JSONArray: data as! [[String : Any]])
                self?.leftView.titles = self?.list?.compactMap{ $0.name } ?? []
                self?.rightTableView.reloadData()
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
           
        }
    }
    
    
}

class ZBBAuthBrandListModel: NSObject, Mappable {
    
    var id: String?
    var name: String?
    var brandList: [ZBBAuthBrandModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        brandList <- map["brandList"]
    }
}

class ZBBAuthBrandModel: NSObject, Mappable {
    
    var id: String?
    var brandImg: String?
    var brandName: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        brandImg <- map["brandImg"]
        brandName <- map["brandName"]
    }
}
