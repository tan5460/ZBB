//
//  GXReleaseListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper

class GXReleaseListVC: BaseViewController {
    
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
        tableView.register(cellWithClass: GXReleaseListCell.self)
        tableView.register(cellWithClass: GXTGReleaseListCell.self)
        tableView.register(cellWithClass: GXXPXHReleaseListCell.self)
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                self?.loadTGData()
            } else {
                if self?.index == 3 {
                    self?.loaXPXHData()
                } else {
                    self?.loadData()
                }
            }
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                self?.loadTGData()
            } else {
                if self?.index == 3 {
                    self?.loaXPXHData()
                } else {
                    self?.loadData()
                }
            }
        }
        prepareNoDateView("暂无数据")
        noDataView.isHidden = true
        if index == 0 {
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                loadTGData()
            } else {
                loadData()
            }
        }
    }
    private var pageSize = 10
    var current = 1
    var rowsData: [MaterialsModel] = []
    func loadData() {
        var parameters = Parameters()
        parameters["entranceType"] = index + 1
        parameters["current"] = current
        parameters["size"] = pageSize
        if index > 1 {
            noDataView.isHidden = false
            return
        }
        YZBSign.shared.request(APIURL.myPublishMaterials, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
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
    
    func loadTGData() {
        var parameters = Parameters()
        parameters["size"] = pageSize
        parameters["current"] = current
        parameters["type"] = 0
        YZBSign.shared.request(APIURL.groupPurchaseInvitePage, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let total = Utils.getReadString(dir: dataDic, field: "total")
                let models = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current == 1 {
                    self.rowsData = models
                } else {
                    self.rowsData.append(contentsOf: models)
                }
                self.tableView.reloadData()
                self.noDataView.isHidden = self.rowsData.count > 0
                self.tableView.endHeaderRefresh()
                if total.toInt ?? 0 > self.rowsData.count {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
            }
        }) { (error) in
            self.noDataView.isHidden = self.rowsData.count > 0
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
    
    func loaXPXHData() {
        var parameters = Parameters()
        parameters["size"] = pageSize
        parameters["current"] = current
        YZBSign.shared.request(APIURL.newProductsMaterials, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let total = Utils.getReadString(dir: dataDic, field: "total")
                let models = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current == 1 {
                    self.rowsData = models
                } else {
                    self.rowsData.append(contentsOf: models)
                }
                self.tableView.reloadData()
                self.noDataView.isHidden = self.rowsData.count > 0
                self.tableView.endHeaderRefresh()
                if total.toInt ?? 0 > self.rowsData.count {
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
}

extension GXReleaseListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            let cell = GXTGReleaseListCell().backgroundColor(.clear)
            cell.model = rowsData[indexPath.row]
            cell.refreshList = { [weak self] in
                
                self?.refreshTableViewList(indexPath: indexPath, cell: cell)
            }
            return cell
        } else {
            if index == 3 {
                let cell = GXXPXHReleaseListCell().backgroundColor(.clear)
                cell.model = rowsData[indexPath.row]
                cell.refreshList = { [weak self] in
                    self?.refreshTableViewList(indexPath: indexPath, cell: cell)
                }
                return cell
            } else {
                let cell = GXReleaseListCell().backgroundColor(.clear)
                cell.model = rowsData[indexPath.row]
                cell.refreshList = { [weak self] in
                    self?.refreshTableViewList(indexPath: indexPath, cell: cell)
                }
                return cell
            }
        }
    }
    
    func refreshTableViewList(indexPath: IndexPath, cell: UITableViewCell) {
        self.rowsData.remove(at: indexPath.row)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = rowsData[indexPath.row]
        if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
            let id = model.id ?? ""
            let userId = UserData1.shared.tokenModel?.userId ?? ""
            let vc = GXGroupInviteDetailVC()
            vc.isShare = false
            vc.id = id
            vc.materialId = model.materialsId ?? ""
            if model.isMe == 0 {
                vc.isMe = true
            } else {
                vc.isMe = false
            }
            if UserData.shared.userType == .gys {
                vc.urlStr = "\(APIURL.webUrl)/other/jcd-active-h5/#/invitation?id=\(id)&userId=\(userId)&isgys=1"
            } else {
                vc.urlStr = "\(APIURL.webUrl)/other/jcd-active-h5/#/invitation?id=\(id)&userId=\(userId)"
            }
            self.navigationController?.pushViewController(vc)
        } else {
            if index != 3 {
                let vc = MaterialsDetailVC()
                let material = MaterialsModel()
                material.id = model.materialsId
                vc.materialsModel = material
                navigationController?.pushViewController(vc)
            } else {
                let vc = MaterialsDetailVC()
                let material = MaterialsModel()
                material.id = model.materialsId
                vc.materialsModel = material
                vc.detailType = .new
                navigationController?.pushViewController(vc)
            }
        }
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

class GXReleaseListCell: UITableViewCell {
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    var refreshList: (() -> Void)?
    private let activityTitle = UILabel().text("730特惠活动").textColor(.kColor33).font(14)
    private let activityStatus = UILabel().text("活动未开始").textColor(#colorLiteral(red: 1, green: 0.6705882353, blue: 0.2392156863, alpha: 1)).font(14)
    private let activityLine = UIView().backgroundColor(.kColorEE)
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
    private let title = UILabel().text("贝朗卫浴节水静音坐便器家用").textColor(.kColor33).fontBold(16)
    private let price = UILabel().text("￥1270.00").textColor(.kDF2F2F).font(12)
    private let line = UIView().backgroundColor(.kColorEE)
    /// 已发布 #1DC597 已拒绝 #DF2F2F
    private let status = UILabel().text("待审核").textColor(.kFFAB3D).font(14)
    private let deleteBtn = UIButton().text("删除").textColor(.kColor99).font(12).borderColor(.kColor99).borderWidth(0.5).cornerRadius(11).masksToBounds()
    
    func configCell() {
        let v = UIView().backgroundColor(.white)
        var cellH: CGFloat = 157
        if model?.activityId != nil {
            cellH = 202
        }
        sv(v)
        layout(
            5,
            |-14-v.height(cellH)-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        if model?.activityId != nil {
            v.sv(activityTitle, activityStatus, activityLine, icon, title, price, line, status, deleteBtn)
            title.numberOfLines(0).lineSpace(2)
            v.layout(
                15,
                |-15-activityTitle.height(20)-(>=0)-activityStatus-15-|,
                10,
                |-15-activityLine.height(0.5)-15-|,
                15,
                |-15-icon.size(80),
                10.75,
                |-15-line-15-|,
                11.25,
                |-15-status.height(20)-(>=0)-deleteBtn.width(55).height(22)-15-|,
                >=0
            )
            v.layout(
                60,
                |-105-title-15-|,
                >=20,
                |-105-price.height(20),
                62
            )
            if !icon.addImage(model?.imageUrl) {
                icon.image(#imageLiteral(resourceName: "loading"))
            }
            title.text(model?.materialsName ?? "")
            price.text("￥\(model?.promotionPrice ?? 0)")
            activityTitle.text(model?.activityTitle ?? "")
            switch model?.status {
            case 1:
                activityStatus.text("活动未开始").textColor(.kFFAB3D)
            case 2:
                activityStatus.text("活动进行中").textColor(.k2FD4A7)
            case 3:
                activityStatus.text("活动已结束").textColor(.kColor99)
            default:
                break
            }
        } else {
            v.sv(icon, title, price, line, status, deleteBtn)
            title.numberOfLines(0).lineSpace(2)
            v.layout(
                15,
                |-15-icon.size(80),
                10.75,
                |-15-line-15-|,
                11.25,
                |-15-status.height(20)-(>=0)-deleteBtn.width(55).height(22)-15-|,
                >=0
            )
            v.layout(
                15,
                |-105-title-15-|,
                >=20,
                |-105-price.height(20),
                62
            )
            let imageUrl = model?.materials?.imageUrl
            let imageUrls = imageUrl?.components(separatedBy: ",")
            if !icon.addImage(imageUrls?.first) {
                icon.image(#imageLiteral(resourceName: "loading"))
            }
            title.text(model?.materials?.name ?? "")
            price.text("￥\(model?.price ?? 0)")
        }
        deleteBtn.addTarget(self, action: #selector(deleteBtnClick(btn:)))
        
        switch model?.isCheck {
        case 0:
            status.text("未提交").textColor(.kColor66)
        case 1:
            status.text("已发布").textColor(.k2FD4A7)
        case 2:
            status.text("已拒绝").textColor(.kDF2F2F)
        case 3:
            status.text("待审核").textColor(.kFFAB3D)
        default:
            break
        }
       // status.text("")
        
    }
    
    @objc private func deleteBtnClick(btn: UIButton) {
        let alert = UIAlertController.init(title: "提示", message: "是否确认删除", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (aciton) in
            self.deleteRequest()
        }))
        parentController?.present(alert, animated: true, completion: nil)
        
    }
    
    func deleteRequest() {
        var parameters = Parameters()
        parameters["id"] = model?.id
        YZBSign.shared.request(APIURL.delMaterials, method: .delete, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("删除成功")
                self.refreshList?()
            }
        }) { (error) in
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class GXXPXHReleaseListCell: UITableViewCell {
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    var refreshList: (() -> Void)?
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
    private let title = UILabel().text("贝朗卫浴节水静音坐便器家用").textColor(.kColor33).fontBold(16)
    private let price = UILabel().text("￥1270.00").textColor(.kDF2F2F).font(12)
    private let line = UIView().backgroundColor(.kColorEE)
    /// 已发布 #1DC597 已拒绝 #DF2F2F
    private let status = UILabel().text("待审核").textColor(.kFFAB3D).font(14)
    private let deleteBtn = UIButton().text("删除").textColor(.kColor99).font(12).borderColor(.kColor99).borderWidth(0.5).cornerRadius(11).masksToBounds()
    
    func configCell() {
        let v = UIView().backgroundColor(.white)
        sv(v)
        layout(
            5,
            |-14-v-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        v.sv(icon, title, price, line, status, deleteBtn)
        title.numberOfLines(0).lineSpace(2)
        v.layout(
            15,
            |-15-icon.size(80),
            15,
            |-15-line.height(0.5)-15-|,
            11.25,
            |-15-status.height(20)-(>=0)-deleteBtn.width(55).height(22)-15-|,
            16
        )
        v.layout(
            15,
            |-105-title-15-|,
            20,
            |-105-price.height(20),
            62
        )
        let imageUrl = model?.materials?.imageUrl
        let imageUrls = imageUrl?.components(separatedBy: ",")
        if !icon.addImage(imageUrls?.first) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        title.text(model?.materials?.name ?? "")
        price.text("￥\(model?.materials?.priceSupplyMin1 ?? 0)")
        deleteBtn.addTarget(self, action: #selector(deleteBtnClick(btn:)))
       //新品现货 status 产品状态(0: 待提交 1:待审核 2：进行中 3：活动结束 4: 已拒绝)
        switch model?.status {
        case 0:
            status.text("待提交").textColor(.kColor66)
        case 1:
            status.text("待审核").textColor(UIColor.hexColor("#FD9C3B"))
        case 2:
            status.text("进行中").textColor(.k1DC597)
        case 3:
            status.text("活动结束").textColor(.kColor33)
        case 4:
            status.text("已拒绝").textColor(.kDF2F2F)
        
        default:
            break
        }
       // status.text("")
        
    }
    
    @objc private func deleteBtnClick(btn: UIButton) {
        let alert = UIAlertController.init(title: "提示", message: "是否确认删除", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (aciton) in
            self.deleteRequest()
        }))
        parentController?.present(alert, animated: true, completion: nil)
        
    }
    
    func deleteRequest() {
        var parameters = Parameters()
        parameters["id"] = model?.id
        let urlStr = APIURL.deleteNewProductsMaterials + "\(model?.id ?? "")"
        
        YZBSign.shared.request(urlStr, method: .delete, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("删除成功")
                self.refreshList?()
            }
        }) { (error) in
            
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class GXTGReleaseListCell: UITableViewCell {
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    var refreshList: (() -> Void)?
    
    private let isMeLabel = UILabel().text("我发起的").textColor(.kColor66).font(12)
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading")).backgroundColor(.kBackgroundColor)
    private let rightBg = UIView()
    private let title = UILabel().text("巴拉巴拉小魔仙乌卡拉卡边身 铁架子双人床").textColor(.kColor33).fontBold(14)
    private let ruleLabel = UILabel().text("800*800").textColor(.kColor66).font(12)
    private let groupDes = UILabel().text("团购价：").textColor(.kColor66).font(12)
    private let groupPrice = UILabel().text("￥1270.00").textColor(UIColor.hexColor("#DF2F2F")).font(12)
    private let numLabel = UILabel().text("数量：1").textColor(.kColor66).font(12)
    private let statusLabel = UILabel().text("进行中").textColor(UIColor.hexColor("#1DC597")).font(14)
    
    func configCell() {
        let v = UIView().backgroundColor(.white)
        sv(v)
        layout(
            5,
            |-14-v.height(197)-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        
        v.sv(isMeLabel, icon, rightBg, statusLabel)
        v.layout(
            15,
            |-15-isMeLabel.height(16.5),
            25.5,
            |-15-icon.size(80)-10-rightBg.height(80)-0-|,
            25,
            |-15-statusLabel.height(20),
            15
        )
        
        rightBg.sv(title, ruleLabel, groupDes, groupPrice, numLabel)
        rightBg.layout(
            0,
            |-0-title-15-|,
            4,
            |-0-ruleLabel.height(16.5),
            1.5,
            |-0-groupDes.height(16.5)-0-groupPrice-(>=0)-numLabel-15-|,
            0
        )
        title.numberOfLines(2).lineSpace(2)
        
        if model?.isMe == 0 {
            isMeLabel.text("我发起的")
        } else {
            isMeLabel.text("我参与的")
        }
        
        let imageUrl = model?.materials?.imageUrl
        let imageUrls = imageUrl?.components(separatedBy: ",")
        if !icon.addImage(imageUrls?.first) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        
        title.text(model?.materials?.name ?? "")
        ruleLabel.text(model?.skuAttr1 ?? "未知")
        groupPrice.text("￥\(model?.groupPrice ?? 0)")
        numLabel.text("数量：\(model?.groupNum ?? 0)")
        
        
        if model?.status?.doubleValue == 0 {
            statusLabel.text("进行中").textColor(UIColor.hexColor("#1DC597"))
        }  else if model?.status?.doubleValue == 1 {
            statusLabel.text("拼团成功").textColor(UIColor.hexColor("#FD9C3B"))
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
