//
//  MyYHQListVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/5.
//

import UIKit
import ObjectMapper
import Stevia

class MyYHQListVC: BaseViewController {
    
    public var index = 0
    public  weak var viewController: UIViewController?
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        tableView.backgroundColor(.clear)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(cellWithClass: MyYHQListCell.self)
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        prepareNoDateView("暂无优惠券～")
        noDataView.isHidden = true
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        if index == 0 {
            loadData()
        }
        // loadData(false)
    }
    private var pageSize = 10
    var current = 1
    var rowsData: [CouponModel] = []
    func loadData() {
        var parameters = Parameters()
        if index == 0 {
            parameters["useStatus"] = "1" // 未使用
        } else if index == 1 {
            parameters["useStatus"] = "2" // 已使用
        } else if index == 2 {
            parameters["useStatus"] = "3" // 已失效
        }
        parameters["cashCouponType"] = "2" // 代金券不传此参数 优惠券传2
        parameters["current"] = current
        parameters["size"] = pageSize
        YZBSign.shared.request(APIURL.getCouponList, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false

            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let pages = Utils.getReadDic(data: dataDic as AnyObject, field: "page")
                let dataArray = Utils.getReadArr(data: pages, field: "records")
                let modelArray = Mapper<CouponModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current > 1 {
                    self.rowsData += modelArray
                }
                else {
                    self.rowsData = modelArray
                }
                self.tableView.reloadData()
                if modelArray.count < self.pageSize {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }

            }else if errorCode == "008" {
                self.rowsData.removeAll()
            }

            self.tableView.reloadData()

            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self.noDataView.isHidden = self.rowsData.count > 0
        }) { (error) in
            self.noDataView.isHidden = self.rowsData.count > 0
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false

            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
        
    }
}

extension MyYHQListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MyYHQListCell().backgroundColor(.clear)
        cell.selectionStyle = .none
        cell.index = index
        cell.model = rowsData[indexPath.row]
        return cell
    }
    
    func refreshTableViewList(indexPath: IndexPath, cell: UITableViewCell) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if index == 3 {
            self.noticeOnlyText("邀请的用户成为中级及以上会员代金券可激活")
        }
        let vc = StoreViewController()
        viewController?.navigationController?.pushViewController(vc)
        
//        let model = rowsData[indexPath.row]
//        let vc = MaterialsDetailVC()
//        let material = MaterialsModel()
//        material.id = model.materialsId
//        vc.materialsModel = material
//        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.clear)
    }
    
}

class MyYHQListCell: UITableViewCell {
    var index = 0
    var model: CouponModel? {
        didSet {
            configCell()
        }
    }
    var refreshList: (() -> Void)?
    private var bgIV = UIImageView().image(#imageLiteral(resourceName: "purchase_yhq_bg_1_1")).backgroundColor(.white)
    private var leftBg = UIImageView().image(#imageLiteral(resourceName: "purchase_yhq_bg_1"))
    private var priceBg = UIView()
    private var priceDes = UILabel().text("¥").textColor(.white).font(18)
    private var price = UILabel().text("500").textColor(.white).fontBold(28)
    private var mkLabel = UILabel().text("无门槛").textColor(.white).font(12)
    private var useBtn = UIButton().text("立即使用").textColor(.white).font(10)
    private var title = UILabel().text("仅限购买厨房卫浴-厨电品类的产品").textColor(.kColor33).fontBold(12)
    private var time = UILabel().text("有效期至2020.08.18").textColor(.kColor66).font(10)
    private var xxLine = UIImageView().image(#imageLiteral(resourceName: "purchase_yhq_bg_2_2"))
    private var xzLabel = UILabel().text("全场通用").textColor(.kColor33).font(10)
    private var statusIV = UIImageView().image(#imageLiteral(resourceName: "purchase_use_icon"))
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bgIV.addShadowColor()
        sv(bgIV)
        
        layout(
            0,
            |-14-bgIV.height(100)-14-|,
            10
        )
        
        bgIV.sv(leftBg)
        bgIV.layout(
            0,
            |leftBg.width(105),
            0
        )
       // bgIV.isUserInteractionEnabled = true
        bgIV.sv(title, time, xxLine, xzLabel, statusIV, useBtn)
        
        
        
        
        leftBg.sv(priceBg, mkLabel)
        leftBg.layout(
            15,
            priceBg.height(39).centerHorizontally(),
            13.5,
            mkLabel.height(16.5).centerHorizontally(),
            19.5
        )
        priceBg.sv(priceDes, price)
        priceBg.layout(
            10.5,
            |-0-priceDes.height(25),
            >=0
        )
        priceBg.layout(
            0,
            |-13-price.height(39)-0-|,
            0
        )
        leftBg.layout(
            15,
            |-34-price.height(39),
            >=0
        )
        bgIV.layout(
            >=0,
            statusIV.size(55)-6-|,
            6
        )
        bgIV.layout(
            20,
            |-120-title.height(16.5)-20-|,
            7,
            |-120-time.height(14),
            10.25,
            |-120-xxLine.height(0.5)-97.5-|,
            8.25,
            |-120-xzLabel.height(14),
            10
        )
        statusIV.isHidden = true
        time.numberOfLines(0).lineSpace(2)
        
        useBtn.centerVertically()-15-|
        useBtn.width(60).height(20)
        useBtn.corner(radii: 10).fillRedColorLF()
        
        useBtn.isUserInteractionEnabled = true
        useBtn.tapped { (tapBtn) in
            let vc = StoreDetailVC()
            self.parentViewController?.navigationController?.pushViewController(vc)
        }
    }
    
    func configCell() {
        if index == 0 {
            xxLine.image(#imageLiteral(resourceName: "purchase_yhq_bg_2_3"))
        } else {
            xxLine.image(#imageLiteral(resourceName: "purchase_yhq_bg_2_2"))
        }
        title.text(model?.name ?? "")
        price.text("\(model?.denomination ?? 0)")
        if model?.useThreshold == "1" {
            mkLabel.text("无门槛")
        } else {
            mkLabel.text("满\(model?.withAmount?.doubleValue ?? 0)元可用")
        }
        
        switch model?.usableRange {
        case "1":
            xzLabel.text("全场通用")
        case "2":
            xzLabel.text("仅限购买\(model?.name ?? "")-\(model?.objName ?? "")品类的产品")
        case "3":
            xzLabel.text("仅限购买\(model?.objName ?? "")品牌商的产品")
        default:
            break
        }
        let invalidDate = model?.invalidDate ?? ""
        let invalidDate1 = invalidDate.components(separatedBy: " ").first ?? ""
        time.text("有效期：\(invalidDate1)")
        switch index {
        case 0:
            bgIV.image(#imageLiteral(resourceName: "purchase_yhq_bg_1_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_yhq_bg_1"))
            statusIV.image(#imageLiteral(resourceName: "purchase_djq_no_1"))
            statusIV.isHidden = true
            useBtn.isHidden = false
            bgIV.bringSubviewToFront(useBtn)
            useBtn.isUserInteractionEnabled = true
        case 1:
            bgIV.image(#imageLiteral(resourceName: "purchase_yhq_bg_2_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_yhq_bg_2"))
            statusIV.isHidden = false
            statusIV.image(#imageLiteral(resourceName: "purchase_use_icon"))
            useBtn.isHidden = true
        case 2:
            bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_4_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_4"))
            statusIV.isHidden = false
            statusIV.image(#imageLiteral(resourceName: "purchase_djq_invalid"))
            useBtn.isHidden = true
        case 3:
            bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_4_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_4"))
            statusIV.isHidden = false
            statusIV.image(#imageLiteral(resourceName: "purchase_djq_no_4"))
            useBtn.isHidden = true
        default:
            break
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

