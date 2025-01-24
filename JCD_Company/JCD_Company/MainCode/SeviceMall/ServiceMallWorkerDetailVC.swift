//
//  ServiceMallWorkerDetailVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/5.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import MJRefresh
import Alamofire

class ServiceMallWorkerDetailVC: BaseViewController {
    
    enum WorkerDetailType {
        case worker
        case design
    }
    var id: String?
    var detailType: WorkerDetailType = .worker
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        switch detailType {
        case .worker:
            title = "工人详情"
        case .design:
            title = "设计师详情"
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = tableHeaderView()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        loadData()
    }
    private var detailModel: WorkTeamDetailModel?
    private func loadData() {
        var parameter = Parameters()
        parameter["id"] = id
        switch detailType {
        case .worker:
            title = "工人详情"
        case .design:
            title = "设计师详情"
        }
        YZBSign.shared.request(APIURL.getPersonalDetails, method: .get, parameters: parameter, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.detailModel = WorkTeamDetailModel.deserialize(from: model?.data as? [String: Any]) ?? WorkTeamDetailModel()
                self.tableView.reloadData()
                self.configContentViewData()
            }
        }) { (error) in
            
        }
    }
    
    
    private let contentView = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
    func tableHeaderView() -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 278))
        v.sv(contentView)
        v.layout(
            15,
            |-14-contentView-14-| ~ 263,
            0
        )
        configContentView()
        return v
    }
    private let avatar = UIImageView().image(#imageLiteral(resourceName: "img_buyer")).cornerRadius(24.5).masksToBounds()
    private let name = UILabel().textColor(.kColor33).font(14)
    private let detail = UILabel().textColor(.kColor66).font(12)
    private let detail1 = UILabel().textColor(.kColor66).font(12)
    private let desLabel = UILabel().textColor(.kColor66).font(12).numberOfLines(2)
    private let desImage = UIImageView().image(#imageLiteral(resourceName: "loading_rectangle"))
    func configContentView() {
        
        let messageBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_wechat"))
        let phoneBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_phone"))
        let titleLabel = UILabel().text("个人简介").textColor(.kColor33).font(12)
        
        desLabel.lineSpace(2)
        contentView.sv(avatar, name, detail, detail1, messageBtn, phoneBtn, titleLabel, desLabel, desImage)
        contentView.layout(
            12,
            |-12-avatar.size(49)-(>=0)-messageBtn.size(30)-15-phoneBtn.size(30)-15-|,
            25,
            |-12-titleLabel.height(12),
            10,
            |-12-desLabel-20-|,
            10,
            |-12-desImage.width(140).height(95),
            15
        )
        contentView.layout(
            17,
            |-73-name.height(14),
            13,
            |-73-detail.height(12)-15-detail1.height(12),
            >=0
        )
        desImage.contentMode = .scaleAspectFit
        desImage.cornerRadius(5).masksToBounds()
        desImage.isUserInteractionEnabled = true
        desImage.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(desImageTap(tap:))))
        messageBtn.addTarget(self, action: #selector(messageBtnClick(btn:)))
        phoneBtn.addTarget(self, action: #selector(phoneBtnClick(btn:)))
    }
    
    @objc private func desImageTap(tap: UITapGestureRecognizer) {
        let infoModel = detailModel?.info
        let urlStr = APIURL.ossPicUrl + (infoModel?.relatedQualifications ?? "")
        if let imageUrl = URL.init(string: urlStr) {
            let phoneVC = IMUIImageBrowserController()
            phoneVC.imageArr = [imageUrl]
            phoneVC.imgCurrentIndex = 0
            
            phoneVC.modalPresentationStyle = .overFullScreen
            self.present(phoneVC, animated: true, completion: nil)
        }
    }
    
    @objc private func messageBtnClick(btn: UIButton) {
        let teamModel = detailModel?.info
        updConsultNumRequest(id: teamModel?.id ?? "")
        self.messageBtnClick(userId: teamModel?.id,
                             userName: teamModel?.userName,
                             storeName: teamModel?.name,
                             headUrl: teamModel?.headUrl,
                             nickname: teamModel?.userName,
                             tel1: teamModel?.mobile,
                             tel2: "")
        
    }
    
    @objc private func phoneBtnClick(btn: UIButton) {
        let teamModel = detailModel?.info
        self.houseListCallTel(name: teamModel?.name ?? "", phone: teamModel?.mobile ?? "")
    }
    
    func configContentViewData() {
        let infoModel = detailModel?.info
        avatar.addImage(infoModel?.headUrl)
        name.text(infoModel?.name ?? "")
        AppData.workTypes.forEach { (dic) in
            if infoModel?.workType ?? "" == Utils.getReadString(dir: dic, field: "value") {
                detail.text(Utils.getReadString(dir: dic, field: "label"))
            }
            
        }
        detail1.text("从业\(infoModel?.workingYears ?? 0)年")
        desLabel.text("本人从事\(detail.text ?? "")行业\(infoModel?.workingYears ?? 0)年，经验丰富，一直的服务理念是客户至上")
        if !desImage.addImage(infoModel?.relatedQualifications) {
            desImage.image(#imageLiteral(resourceName: "loading_rectangle"))
        }
        
    }
    
}


extension ServiceMallWorkerDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        switch indexPath.section {
        case 0:
            configSectionView0(cell: cell)
        case 1:
            configSectionView1(cell: cell)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140
        } else if indexPath.section == 1 {
            let count: Int = detailModel?.materials?.count ?? 0
            if count == 0 {
                return 213.5
            } else {
                return 203.5*CGFloat(((count+1)/2)) + 10
            }
        }
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 53
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 53))
        let image = UIImageView()
        let title = UILabel().textColor(.kColor33).font(12)
        v.sv(image, title)
        v.layout(
            25,
            |-14-image.size(13)-5-title.height(13),
            >=0
        )
        if section == 0 {
            image.image(#imageLiteral(resourceName: "service_mall_works"))
            title.text("作品(\(detailModel?.cases?.count ?? 0)）")
        } else if section == 1 {
            image.image(#imageLiteral(resourceName: "service_mall_services"))
            title.text("服务(\(detailModel?.materials?.count ?? 0)）")
        }
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func configSectionView0(cell: UITableViewCell) {
        let scrollView = UIScrollView().backgroundColor(.white)
        scrollView.showsHorizontalScrollIndicator = false
        cell.sv(scrollView)
        cell.layout(
            0,
            |scrollView|,
            0
        )
        let caseModels = detailModel?.cases
        caseModels?.enumerated().forEach { (item) in
            let index = item.offset
            let caseModel = item.element
            let btnW: CGFloat = 205
            let btnH: CGFloat = 140
            let offsetX: CGFloat = 14 + (btnW+13)*CGFloat(index)
            let btn = UIButton()
            let btnIV = UIImageView().image(#imageLiteral(resourceName: "service_mall_banner_bg")).backgroundColor(.kBackgroundColor)
            btnIV.contentMode = .scaleAspectFit
            btnIV.cornerRadius(5).masksToBounds()
            scrollView.sv(btn)
            scrollView.layout(
                0,
                |-offsetX-btn.width(btnW).height(btnH)-(>=14)-|,
                0
            )
            btn.sv(btnIV)
            btnIV.followEdges(btn)
            btnIV.addImage(caseModel.mainImgUrl)
            let styleTypeList = AppData.styleTypeList
            var styleType = ""
            styleTypeList.forEach { (dic) in
                let tmpStyleType = Utils.getReadString(dir: dic, field: "value")
                if tmpStyleType == caseModel.caseStyle {
                    styleType = Utils.getReadString(dir: dic, field: "label")
                }
            }
            
            let houseTypeList = AppData.houseTypesList
            var houseType = ""
            houseTypeList.forEach { (dic) in
                let tmpHouseType = Utils.getReadString(dir: dic, field: "value")
                if tmpHouseType == caseModel.houseType {
                    houseType = Utils.getReadString(dir: dic, field: "label")
                }
            }
            let label = UILabel().text("   \(houseType) | \(styleType) | \(caseModel.houseArea ?? "0")㎡  ").textColor(.white).font(12).backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
            btnIV.sv(label)
            btnIV.layout(
                >=0,
                |label| ~ 21,
                0
            )
            btn.tag = index
            btn.addTarget(self, action: #selector(caseBtnsClick(btn:)))
        }
        if caseModels?.count ?? 0 == 0 {
            let noDataBtn = UIButton().image(#imageLiteral(resourceName: "nodata_icon")).text("  暂无作品").textColor(.kColor66).font(14)
            cell.sv(noDataBtn)
            noDataBtn.width(200).height(100)
            noDataBtn.centerInContainer()
        }
    }
    
    func configSectionView1(cell: UITableViewCell) {
        let materials = detailModel?.materials
        materials?.enumerated().forEach { (item) in
            let index = item.offset
            let material = item.element
            let btnW: CGFloat = (view.width-28-13)/2
            let btnH: CGFloat = 193.5
            let offsetX: CGFloat = (btnW+13) * CGFloat(index%2) + 14
            let offsetY: CGFloat = (btnH+10) * CGFloat(index/2)
            let btn = UIButton().backgroundColor(.white)
            btn.contentMode = .scaleAspectFit
            btn.cornerRadius(5).masksToBounds()
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=0
            )
            let image = UIImageView().image(#imageLiteral(resourceName: "plus_backImage"))
            let label = UILabel().text(material.name ?? "未知").textColor(.kColor33).font(12).numberOfLines(2)
            label.lineSpace(5)
            image.addImage(material.imageUrl)
            let priceDesLabel = UILabel().text("报价").textColor(#colorLiteral(red: 1, green: 0.6705882353, blue: 0.2392156863, alpha: 1)).font(10).textAligment(.center).cornerRadius(2).masksToBounds().borderColor(#colorLiteral(red: 1, green: 0.6705882353, blue: 0.2392156863, alpha: 1)).borderWidth(0.5)
            let priceLabel = UILabel().text("¥\(material.priceSellMin ?? 0)/\(material.unitTypeName ?? "")").textColor(#colorLiteral(red: 0.8745098039, green: 0.1843137255, blue: 0.1843137255, alpha: 1)).font(12)
            
            if UserData.shared.userType == .jzgs {
                priceLabel.text("¥\(material.priceSellMin ?? 0)/\(material.unitTypeName ?? "")")
            } else if UserData.shared.userType == .cgy {
                priceLabel.text("¥\(material.priceSupplyMin1 ?? 0)/\(material.unitTypeName ?? "")")
            }
            
            btn.sv(image, label, priceDesLabel, priceLabel)
            btn.layout(
                0,
                |image| ~  120,
                5,
                |-5-label-5-|,
                >=0,
                |-5-priceDesLabel.width(34).height(16)-5-priceLabel.height(12.5),
                10
            )
            btn.tag = index
            btn.addTarget(self, action: #selector(serviceBtnsClick(btn:)))
        }
        cell.backgroundColor(.white)
        if materials?.count ?? 0 == 0 {
            let noDataBtn = UIButton().image(#imageLiteral(resourceName: "nodata_icon")).text("  暂无服务").textColor(.kColor66).font(14)
            cell.sv(noDataBtn)
            noDataBtn.width(200).height(100)
            noDataBtn.centerInContainer()
        }
    }
    
    @objc private func serviceBtnsClick(btn: UIButton) {
        let materials = detailModel?.materials
        let vc = MaterialsDetailVC()
        let materialModel = MaterialsModel()
        materialModel.id = materials?[btn.tag].id
        vc.materialsModel = materialModel
        navigationController?.pushViewController(vc)
    }
    
    @objc private func caseBtnsClick(btn: UIButton) {
        let caseModels = detailModel?.cases
         let vc = WholeHouseDetailController()
         if let url = caseModels?[btn.tag].url {
             vc.detailUrl =  url
         }
        let caseModel = HouseCaseModel()
        let model = caseModels?[btn.tag]
        caseModel.caseNo = model?.caseNo
        caseModel.caseRemarks = model?.caseRemarks
        caseModel.caseStyle = model?.caseStyle
        caseModel.communityId = model?.communityId
        caseModel.communityName = model?.communityName
        caseModel.createTime = model?.createTime
        caseModel.houseArea = model?.houseArea
        caseModel.houseType = model?.houseType
        caseModel.id = model?.id
        caseModel.mainImgUrl = model?.mainImgUrl
        caseModel.showFlag = model?.showFlag
        caseModel.type = model?.type
        caseModel.updateTime = model?.updateTime
        caseModel.userId = model?.userId
        caseModel.caseStyleName = model?.caseStyleName
        caseModel.houseAreaName = model?.houseAreaName
        caseModel.houseTypeName = model?.houseTypeName
        caseModel.url = model?.url
        caseModel.userName = model?.userName
        vc.caseModel = caseModel
         navigationController?.pushViewController(vc, animated: true)
    }
}
