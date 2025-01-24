//
//  MyDJQListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/7.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import Stevia

class MyDJQListVC: BaseViewController {
    
    public var index = 0
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
        tableView.register(cellWithClass: MyDJQListCell.self)
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        prepareNoDateView("暂无代金券～")
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
        } else if index == 3 {
            parameters["useStatus"] = "4" // 未激活
        }
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

extension MyDJQListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MyDJQListCell().backgroundColor(.clear)
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

class MyDJQListCell: UITableViewCell {
    var index = 0
    var model: CouponModel? {
        didSet {
            configCell()
        }
    }
    var refreshList: (() -> Void)?
    private var bgIV = UIImageView().image(#imageLiteral(resourceName: "purchase_djq_bg_1_1")).backgroundColor(.white)
    private var leftBg = UIImageView().image(#imageLiteral(resourceName: "purchase_djq_bg_1"))
    private var rightBg = UIView().backgroundColor(UIColor.hexColor("#61D9B9"))
    private var priceDes = UILabel().text("¥").textColor(.white).font(18)
    private var price = UILabel().text("500").textColor(.white).fontBold(28)
    private var useBtn = UIButton().text("立即使用").textColor(.k2AC99E).font(10).backgroundColor(.white).cornerRadius(10).masksToBounds()
    private var status = UILabel().text("全网券").textColor(.white).font(10)
    private var titleDes = UIView().backgroundColor(#colorLiteral(red: 0.1137254902, green: 0.7725490196, blue: 0.5921568627, alpha: 1)).cornerRadius(3).masksToBounds()
    private var title = UILabel().text("仅限购买厨房卫浴-厨电品类的产品").textColor(.kColor33).fontBold(12)
    private var time = UILabel().text("有效期至2020.08.18").textColor(.kColor66).font(10)
    private var time1 = UILabel().text("2020.08.18").textColor(.kColor66).font(10)
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
        
        bgIV.sv(leftBg, rightBg)
        bgIV.layout(
            0,
            |leftBg.width(105),
            0
        )
        
        bgIV.layout(
            0,
            rightBg.width(60).height(20)-0-|,
            >=0
        )
        
        bgIV.sv(priceDes, price, useBtn, status, titleDes, title, time, time1, statusIV)
        
        bgIV.layout(
            >=0,
            statusIV.size(55)-6-|,
            6
        )
        bgIV.layout(
            3,
            status.height(14)-15-|,
            >=0
        )
        bgIV.layout(
            35.5,
            |-125-titleDes.size(6),
            >=0,
            |-125-time.height(14),
            1,
            |-166-time1.height(14),
            7
        )
        bgIV.layout(
            30,
            |-135-title-24.5-|,
            >=0
        )
        rightBg.corner(byRoundingCorners: [.bottomLeft, .topRight], radii: 4)
        statusIV.isHidden = true
        time.numberOfLines(0).lineSpace(2)
    }
    
    func configCell() {
        price.text("\(model?.denomination ?? 0)")
        switch model?.type {
        case "1":
            status.text("全网券")
        case "2":
            status.text("天网券")
        case "3":
            status.text("地网券")
        default:
            break
        }
        switch model?.usableRange {
        case "1":
            title.text("全场通用")
        case "2":
            title.text("仅限购买\(model?.name ?? "")-\(model?.objName ?? "")品类的产品")
        case "3":
            title.text("仅限购买\(model?.objName ?? "")品牌商的产品")
        default:
            break
        }
        time.text("有效期：\(model?.createDate ?? "")")
        time1.text("\(model?.invalidDate ?? "")")
        switch index {
        case 0:
            if model?.isTakeEffect == 0 {
                statusIV.isHidden = false
                switch model?.type {
                case "1":
                    bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_1_1"))
                    leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_1"))
                    rightBg.backgroundColor(UIColor.hexColor("#1DC597"))
                    statusIV.image(#imageLiteral(resourceName: "purchase_djq_no_1"))
                case "2":
                    bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_2_1"))
                    leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_2"))
                    statusIV.image(#imageLiteral(resourceName: "purchase_djq_no_2"))
                    rightBg.backgroundColor(UIColor.hexColor("#3564F6"))
                case "3":
                    bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_3_1"))
                    leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_3"))
                    statusIV.image(#imageLiteral(resourceName: "purchase_djq_no_3"))
                    rightBg.backgroundColor(UIColor.hexColor("#F68235"))
                default:
                    break
                }
            } else {
                statusIV.isHidden = true
            }
            useBtn.isHidden = true
            bgIV.layout(
                41,
                |-21-priceDes.height(25)-2-price,
                >=0
            )
        case 1:
            bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_4_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_4"))
            rightBg.backgroundColor(UIColor.hexColor("#C2C2C2"))
            statusIV.isHidden = false
            statusIV.image(#imageLiteral(resourceName: "purchase_use_icon"))
            useBtn.isHidden = true
            titleDes.backgroundColor(.kColorC2)
            bgIV.layout(
                41,
                |-21-priceDes.height(25)-2-price,
                >=0
            )
        case 2:
            bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_4_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_4"))
            rightBg.backgroundColor(UIColor.hexColor("#C2C2C2"))
            statusIV.isHidden = false
            statusIV.image(#imageLiteral(resourceName: "purchase_djq_invalid"))
            useBtn.isHidden = true
            titleDes.backgroundColor(.kColorC2)
            bgIV.layout(
                41,
                |-21-priceDes.height(25)-2-price,
                >=0
            )
        case 3:
            bgIV.image(#imageLiteral(resourceName: "purchase_djq_bg_4_1"))
            leftBg.image(#imageLiteral(resourceName: "purchase_djq_bg_4"))
            rightBg.backgroundColor(UIColor.hexColor("#C2C2C2"))
            statusIV.isHidden = false
            statusIV.image(#imageLiteral(resourceName: "purchase_djq_no_4"))
            useBtn.isHidden = true
            titleDes.backgroundColor(.kColorC2)
            bgIV.layout(
                41,
                |-21-priceDes.height(25)-2-price,
                >=0
            )
        default:
            break
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
