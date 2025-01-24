//
//  GXNewListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/10/23.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper

class GXNewListVC: BaseViewController {
    
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
        tableView.register(cellWithClass: GXNewListCell.self)
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
        if index > 0 {
            self.tableView.isHidden = true
            self.noDataView.isHidden = false
            return
        }
        
        var parameters = Parameters()
        parameters["size"] = size
        parameters["current"] = current
        parameters["isCheck"] = "1"
        parameters["upperFlag"] = 0
//        if UserData.shared.userType == .gys {
//            parameters["merchantName"] = UserData.shared.merchantModel?.name
//        }
        YZBSign.shared.request(APIURL.newProductsMaterials, method: .get, parameters: parameters, success: { (response) in
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

extension GXNewListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return materials.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GXNewListCell().backgroundColor(.clear)
        cell.model = materials[indexPath.section]
        return cell
    }
    
    func refreshTableViewList(indexPath: IndexPath, cell: UITableViewCell) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = materials[indexPath.section]
        let vc = MaterialsDetailVC()
        vc.detailType = .new
        let material = MaterialsModel()
        material.id = model.materialsId
        material.activityId = model.activityId
        vc.materialsModel = material
        vc.activityId = model.activityId
        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

class GXNewListCell: UITableViewCell {
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    private let icon = UIImageView().image(#imageLiteral(resourceName: "gx_new_default")).backgroundColor(.kBackgroundColor)
    private let title = UILabel().text("古六客厅北欧风格四件套沙发茶几").textColor(.kColor33).fontBold(14)
    private let price = UILabel().text("￥4080起").textColor(.kDF2F2F).fontBold(14)
    private let comIcon = UIImageView().image(#imageLiteral(resourceName: "companys_logo")).backgroundColor(.kBackgroundColor)
    private let comName = UILabel().text("林氏木业").textColor(.kColor66).font(10)
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let v = UIView().backgroundColor(.white)
        sv(v)
        layout(
            5,
            |-14-v.height(128)-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        v.sv(icon, title, price, comIcon, comName)
        title.numberOfLines(0).lineSpace(2)
        v.layout(
            14,
            |-14-icon.size(100),
            14
        )
        v.layout(
            14,
            |-128-title-14-|,
            >=11,
            |-128-price.height(20),
            15,
            |-128-comIcon.width(18).height(14)-5-comName-14-|,
            14
        )
        icon.contentMode = .scaleAspectFit
        icon.cornerRadius(3).masksToBounds()
        comName.contentMode = .scaleAspectFill
        comName.cornerRadius(1).masksToBounds()
    }
    
    func configCell() {
        let imageUrl = model?.materials?.imageUrl
        let imageUrls = imageUrl?.components(separatedBy: ",")
        if !icon.addImage(imageUrls?.first) {
            icon.image(#imageLiteral(resourceName: "gx_new_default"))
        }
        title.text(model?.materialsName ?? "")
        price.text("￥\(model?.materials?.priceSupplyMin1?.doubleValue ?? 0)起")
        comIcon.addImage(model?.brandImg)
        comName.text(model?.merchantName ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
