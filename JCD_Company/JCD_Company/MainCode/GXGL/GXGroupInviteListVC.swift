//
//  GXGroupInviteListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/10/27.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper

class GXGroupInviteListVC: BaseViewController {
    
    public var index = 0
    public var brandId: String?
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
        tableView.register(cellWithClass: GXGroupInviteListCell.self)
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
        parameters["brandIds"] = brandId
        parameters["categoryaId"] = categoryaId
        YZBSign.shared.request(APIURL.groupPurchaseInvitePage, method: .get, parameters: parameters, success: { (response) in
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

extension GXGroupInviteListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materials.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = materials[indexPath.row]
        let cell = GXGroupInviteListCell().backgroundColor(.clear)
        cell.model = model
        cell.groupBtnBlock = { [weak self] in
            let id = model.id ?? ""
            let userId = UserData1.shared.tokenModel?.userId ?? ""
            let vc = GXGroupInviteDetailVC()
            vc.materialId = model.materialsId ?? ""
            if model.isMe == 0 {
                vc.isMe = true
            } else {
                vc.isMe = false
            }
            vc.isShare = false
            vc.id = id
            if UserData.shared.userType == .gys {
                vc.urlStr = "\(APIURL.webUrl)/other/jcd-active-h5/#/invitation?id=\(id)&userId=\(userId)&isgys=1"
            } else {
            //    vc.urlStr = "http://192.168.1.16:8080/#/invitation?id=\(id)&userId=\(userId)"
                vc.urlStr = "\(APIURL.webUrl)/other/jcd-active-h5/#/invitation?id=\(id)&userId=\(userId)"
            }
            self?.navigationController?.pushViewController(vc)
        }
        return cell
    }
    
    func refreshTableViewList(indexPath: IndexPath, cell: UITableViewCell) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let model = materials[indexPath.row]
//        let vc = MaterialsDetailVC()
//        vc.detailType = .th
//        let material = MaterialsModel()
//        material.id = model.materialsId
//        vc.activityId = model.activityId
//        vc.materialsModel = material
//        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 120))
        let bannerBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "gx_tgyq_banner"))
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

class GXGroupInviteListCell: UITableViewCell {
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    var groupBtnBlock: (() -> Void)?
    private let smallIcon = UIImageView().image(#imageLiteral(resourceName: "gx_group_small"))
    private let groupTitle = UILabel().text("     与诺贝尔瓷砖工程已谈好批发价，组团购买优惠价89/元一片，组团购买请报名联系...").textColor(.kColor66).font(12)
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
    private let rightBg = UIView()
    private let iconBg = UIView().backgroundColor(UIColor.hexColor("#DF2F2F", alpha: 0.5))
    private let iconLabel = UILabel().text("1000件成团").textColor(.white).font(10)
    private let title = UILabel().text("诺贝尔的的品牌的瓷砖瓷砖瓷砖800*400").textColor(.kColor33).fontBold(14)
    private let redLine = UIView().backgroundColor(UIColor.hexColor("#D93024")).cornerRadius(3.5)
    private let grayLine = UIView().backgroundColor(UIColor.hexColor("#B7B7B7")).cornerRadius(3.5)
    private let num = UILabel().text("已报名600件").textColor(.kColor99).font(12)
    private let ruleLabel = UILabel().text("800*400").textColor(.kColor66).font(12)
    private let leftLab = UILabel().text("超值速抢").textColor(.kDF2F2F).fontBold(10)
    private let rightLab1 = UILabel().text("￥198").textColor(UIColor.hexColor("#DF2F2F")).fontBold(14)
    private let rightLab2 = UILabel().text("￥398").textColor(.kColor99).font(10)
    private let groupBtn = UIButton().text("参团详情").textColor(.white).font(14).backgroundColor(UIColor.hexColor("#DF2F2F")).cornerRadius(15)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let v = UIView().backgroundColor(.white)
        sv(v)
        layout(
            5,
            |-14-v-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        
        v.sv(smallIcon, groupTitle, icon, rightBg)
        v.layout(
            15,
            |-14-smallIcon.size(15),
            >=0
        )
        groupTitle.numberOfLines(0).lineSpace(2)
        v.layout(
            16,
            |-14-groupTitle-14-|,
            10,
            |-14-icon.size(120)-14-rightBg.height(120)-14-|,
            14
        )
        icon.sv(iconBg)
        icon.layout(
            >=0,
            |-0-iconBg.height(25)-0-|,
            0
        )
        iconBg.sv(iconLabel)
        iconLabel.centerInContainer()
        
        title.numberOfLines(2).lineSpace(2)
        rightBg.sv(title, grayLine, num, ruleLabel, rightLab1, rightLab2, groupBtn)
        rightBg.layout(
            0,
            |-0-title-0-|,
            11.5,
            |-0-grayLine.width(94).height(7)-10-num,
            12,
            |-0-ruleLabel.height(16.5),
            13,
            |-0-rightLab1.height(20),
            0
        )
        
        rightLab2.Left == rightLab1.Right + 4
        rightLab2.Bottom == rightLab1.Bottom
        
        rightBg.layout(
            >=0,
            groupBtn.width(84).height(30)-0-|,
            0
        )
                
        
        icon.backgroundColor(.kBackgroundColor)
        icon.contentMode = .scaleAspectFit
        icon.cornerRadius(3).masksToBounds()
        rightLab2.setLabelUnderline()
        
        groupBtn.tapped { [weak self] (btn) in
            self?.groupBtnBlock?()
        }
    }
    
    func configCell() {
        groupTitle.text("      \(model?.title ?? "")")
        let imageUrl = model?.materials?.imageUrl
        let imageUrls = imageUrl?.components(separatedBy: ",")
        if !icon.addImage(imageUrls?.first) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        title.text(model?.materials?.name ?? "")
        
        let alreadyGroupNum: Int = model?.alreadyGroupNum ?? 0
        let groupNum: Int = model?.groupNum ?? 0
        if groupNum > 0 {
            var percent: Float = Float(alreadyGroupNum) / Float(groupNum)
            if percent > 1 {
                percent = 1
            }
            let width: CGFloat = CGFloat(94 * percent)
            grayLine.sv(redLine)
            grayLine.layout(
                0,
                |-0-redLine.width(width),
                0
            )
        }
        
        
        ruleLabel.text(model?.skuAttr1 ?? "未知")
        iconLabel.text("\(groupNum)件成团")
        num.text("已报名\(alreadyGroupNum)件")
        rightLab1.text("￥\(model?.groupPrice ?? 0)")
        rightLab2.text("￥\(model?.priceSupply1 ?? 0)")
        
        if groupNum <= alreadyGroupNum && (groupNum != 0) {
            groupBtn.text("组团成功").backgroundColor(UIColor.hexColor("#1DC597"))
        } else {
            groupBtn.text("参团详情").backgroundColor(UIColor.hexColor("#DF2F2F"))
        }
        rightLab2.setLabelUnderline()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
