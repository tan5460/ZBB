//
//  GXMZTHListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper

class GXMZTHListVC: BaseViewController {
    
    public var index = 0
    public var brandName: String?
    public var categoryaId: String?
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    var materials: [MaterialsModel] = []
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
        
        view.backgroundColor(.clear)
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
        tableView.register(cellWithClass: GXMZTHListCell.self)
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        prepareNoDateView("暂无数据")
        if index == 0 {
            loadData()
        }
    }
    private var size = 10
    var current = 1
    
    func loadData() {
        var parameters = Parameters()
        parameters["size"] = size
        parameters["current"] = current
        parameters["brandName"] = brandName
        parameters["categoryaId"] = categoryaId
        YZBSign.shared.request(APIURL.getPromotionalMaterials, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let total = Utils.getReadString(dir: dataDic, field: "total")
                let models = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current == 1 {
                    self.materials = models
                } else {
                    self.materials.append(contentsOf: models)
                }
                self.tableView.reloadData()
                self.noDataView.isHidden = self.materials.count > 0
                self.tableView.endHeaderRefresh()
                if total.toInt ?? 0 > self.materials.count {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
    
    
    private func endRefreshHandle(_ haveNextPage: Bool?) {
        self.tableView.endHeaderRefresh()
        if haveNextPage ?? true {
            self.tableView.endFooterRefresh()
        } else {
            self.tableView.endFooterRefreshNoMoreData()
        }
    }
}

extension GXMZTHListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materials.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GXMZTHListCell().backgroundColor(.clear)
        cell.model = materials[indexPath.row]
        return cell
    }
    
    func refreshTableViewList(indexPath: IndexPath, cell: UITableViewCell) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = materials[indexPath.row]
        let vc = MaterialsDetailVC()
        vc.detailType = .th
        let material = MaterialsModel()
        material.id = model.materialsId
        vc.activityId = model.activityId
        vc.materialsModel = material
        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 120))
        let bannerBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "gx_th_banner"))
        v.sv(bannerBtn)
        v.layout(
            0,
            |-14-bannerBtn-14-|,
            10
        )
        bannerBtn.imageView?.contentMode = .scaleAspectFit
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.clear)
    }
    
}

class GXMZTHListCell: UITableViewCell {
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
    private let title = UILabel().text("贝朗卫浴节水静音坐便器家用").textColor(.kColor33).fontBold(16)
    private let num = UILabel().text("已售112件").textColor(.kDF2F2F).font(12)
    private let bgIV = UIImageView().image(#imageLiteral(resourceName: "gx_th_item_bg"))
    private let leftLab = UILabel().text("超值速抢").textColor(.kDF2F2F).fontBold(10)
    private let rightLab1 = UILabel().text("￥198").textColor(.white).fontBold(14)
    private let rightLab2 = UILabel().text("￥298.99").textColor(.white).font(10)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let v = UIView().backgroundColor(.white)
        sv(v)
        layout(
            5,
            |-14-v.height(148)-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        v.sv(icon, title, num, bgIV)
        title.numberOfLines(0).lineSpace(2)
        v.layout(
            14,
            |-14-icon.size(120),
            14
        )
        v.layout(
            14,
            |-148-title-14-|,
            >=6,
            |-148-num.height(16.5),
            22.5,
            |-148-bgIV.height(30)-14-|,
            14
        )
        bgIV.sv(leftLab, rightLab1, rightLab2)
        |-9-leftLab.centerVertically()
        |-79.5-rightLab1.centerVertically()
        bgIV.layout(
            10,
            rightLab2.height(14)-6-|,
            6
        )
        icon.contentMode = .scaleAspectFit
        icon.cornerRadius(3).masksToBounds()
        rightLab2.setLabelUnderline()
    }
    
    func configCell() {
        if !icon.addImage(model?.imageUrl) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        title.text(model?.materialsName ?? "")
        num.text("已售\(model?.sellNum ?? 0)件")
        rightLab1.text("￥\(model?.promotionPrice ?? 0)")
        rightLab2.text("￥\(model?.priceSupply1 ?? 0)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

