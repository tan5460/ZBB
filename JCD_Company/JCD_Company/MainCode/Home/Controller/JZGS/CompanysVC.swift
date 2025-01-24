//
//  CompanysVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/13.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper
import TLTransitions

class CompanysVC: BaseViewController {
    
    private var pop: TLTransition?
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "装饰公司"
        setupBanner()
        setupSelectViews()
        setupTableView()
        loadCitysData()
        loadData()
    }
    private var citys = [ProviceModel?]()
    private var currentCityId: String?
    func loadCitysData() {
        YZBSign.shared.request(APIURL.getSubstationCity, method: .get, parameters: Parameters(), success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.citys = [ProviceModel].deserialize(from: model?.data as? [Any]) ?? [ProviceModel]()
            }
        }) { (error) in
            
        }
    }
    private var current = 1
    private var size = 10
    private var storeType: Int?
    private var sortType: Int?
    private var roleModels: [RoleModel]? {
        didSet {
            tableView.reloadData()
        }
    }
    func loadData() {
        let url = APIURL.getZSCompanyList
        var para = [String: Any]()
        para["current"] = current
        para["size"] = size
        para["storeType"] = storeType
        para["sortType"] = sortType
        para["cityId"] = currentCityId
        para["id"] = UserData.shared.storeModel?.id
        //para["citySubstation"] = UserData.shared.substationModel?.id
        YZBSign.shared.request(url, method: .get, parameters: para, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let roleModelList = [RoleModel].deserialize(from: dataArray as? [Any]) as? [RoleModel]
                self.tableView.endHeaderRefresh()
                if self.current == 1 {
                    self.roleModels = roleModelList
                } else {
                    self.roleModels?.append(contentsOf: roleModelList ?? [RoleModel]())
                }
                self.tableView.reloadData()
                self.noDataBtn.isHidden = self.roleModels?.count ?? 0 > 0
                if roleModelList?.count ?? 0 < self.size {
                    self.tableView.endFooterRefreshNoMoreData()
                } else {
                    self.tableView.endFooterRefresh()
                }
            } else {
                self.tableView.endHeaderRefresh()
                self.tableView.endFooterRefresh()
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
    private var noDataBtn = UIButton()
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(tableView)
        view.layout(
            171,
            |tableView|,
            0
        )
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无数据～").textColor(.kColor66).font(14)
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
    }
    
    private let bannerIV = UIImageView().image(#imageLiteral(resourceName: "companys_banner"))
    private func setupBanner() {
        view.sv(bannerIV)
        view.layout(
            15,
            |-14-bannerIV.height(110)-14-|,
            >=0
        )
    }
    private var substationSelectBtn = UIButton()
    private var substationSelectLab = UILabel().text("全国").textColor(.kColor66).font(12)
    private var substationSelectIV = UIImageView().image(#imageLiteral(resourceName: "gx_qc_arrow_down"))
    private var companyTypeSelectBtn = UIButton()
    private var companyTypeSelectLab = UILabel().text("公司类型").textColor(.kColor66).font(12)
    private var companyTypeSelectIV = UIImageView().image(#imageLiteral(resourceName: "gx_qc_arrow_down"))
    private var starsSelectBtn = UIButton()
    private var starsSelectLab = UILabel().text("人气优先").textColor(.kColor66).font(12)
    private func setupSelectViews() {
        view.sv(substationSelectBtn, companyTypeSelectBtn, starsSelectBtn)
        view.layout(
            125,
            |substationSelectBtn-0-companyTypeSelectBtn-0-starsSelectBtn|,
            >=0
        )
        substationSelectBtn.height(46)
        equal(widths: substationSelectBtn, companyTypeSelectBtn, starsSelectBtn)
        equal(heights: substationSelectBtn, companyTypeSelectBtn, starsSelectBtn)
        
        substationSelectBtn.sv(substationSelectLab, substationSelectIV)
        |-24-substationSelectLab.centerVertically()-5-substationSelectIV.centerVertically()
        
        let priceV = UIView()
        companyTypeSelectBtn.sv(priceV)
        priceV.centerInContainer()
        priceV.sv(companyTypeSelectLab, companyTypeSelectIV)
        |companyTypeSelectLab.centerVertically()-5-companyTypeSelectIV.centerVertically()|
        
        starsSelectBtn.sv(starsSelectLab)
        starsSelectLab.centerVertically()-24-|
        substationSelectBtn.addTarget(self, action: #selector(substationSelectBtnClick(btn:)))
        companyTypeSelectBtn.addTarget(self, action: #selector(companyTypeSelectBtnClick(btn:)))
        starsSelectBtn.addTarget(self, action: #selector(starsSelectBtnClick(btn:)))
    }
    
    // MARK: - 分站
    @objc private func substationSelectBtnClick(btn: UIButton) {
        substationSelectIV.image(#imageLiteral(resourceName: "gx_qc_arrow_up"))
        substationPopView()
    }
    
    func substationPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.kScreenWidth, height: PublicSize.kScreenHeight))
        let sv = UIScrollView(frame: CGRect(x: 0, y: PublicSize.kNavBarHeight+171-PublicSize.kStatusBarHeight, width: view.width, height: 200)).backgroundColor(.white)
        v.addSubview(sv)
        v.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismiss(tap:))))
        pop = TLTransition.show(v, to: CGPoint(x: 0, y: 0))
        pop?.cornerRadius = 0
        setupsubstationBtns(sv)
    }
    
    private var currentsubstationIndex: Int?
    
    func setupsubstationBtns(_ sv: UIScrollView) {
        let spaceW = (view.width-313)/2
        var tmpCitys = citys
        var allsubstation = ProviceModel()
        allsubstation.shortName = "全国"
        tmpCitys.insert(allsubstation, at: 0)
        tmpCitys.enumerated().forEach { (item) in
            let index = item.offset
            let city = item.element
            let offsetX: CGFloat =  (95 + spaceW) * CGFloat(index % 3) + 14
            let offsetY: CGFloat =  CGFloat(15 + 40 * (index / 3))
            let btn = UIButton().text(city?.shortName ?? "").textColor(.kColor33).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            sv.sv(btn)
            sv.layout(
                offsetY,
                |-offsetX-btn.width(95).height(30),
                >=15
            )
            if index == currentsubstationIndex {
                btn.textColor(.k2FD4A7).backgroundColor(.kF2FFFB).borderColor(.k2FD4A7).borderWidth(0.5)
            }
            btn.tag = index
            btn.addTarget(self, action: #selector(substationBtnsClick(btn:)))
        }
    }
    
    @objc func substationBtnsClick(btn: UIButton) {
        currentsubstationIndex = btn.tag
        substationSelectLab.text(btn.titleLabel?.text ?? "全国")
        if btn.tag > 0 {
            currentCityId = citys[btn.tag-1]?.id ?? ""
            
        } else {
            currentCityId = nil
        }
        current = 1
        loadData()
        resetSelectStatus()
    }
    
    
    
    // MARK: - 公司类型
    @objc private func companyTypeSelectBtnClick(btn: UIButton) {
        companyTypeSelectIV.image(#imageLiteral(resourceName: "gx_qc_arrow_up"))
        companyTypePopView()
    }
    
    func companyTypePopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.kScreenWidth, height: PublicSize.kScreenHeight))
        let sv = UIScrollView(frame: CGRect(x: 0, y: PublicSize.kNavBarHeight+171-PublicSize.kStatusBarHeight, width: view.width, height: 200)).backgroundColor(.white)
        v.addSubview(sv)
        v.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismiss(tap:))))
        pop = TLTransition.show(v, to: CGPoint(x: 0, y: 0))
        pop?.cornerRadius = 0
        setupCompanyTypeBtns(sv)
    }
    
    private var currentCompanyTypeIndex: Int?
    private let tmpCompanyTypes = ["全部", "家装公司","工装公司", "家装+工装公司"]
    func setupCompanyTypeBtns(_ sv: UIScrollView) {
        let spaceW = (view.width-313)/2
        
        //         let allsubstation = GXQCsubstationModel()
        //         allsubstation.name = "全国"
        //         tmpsubstations?.insert(allsubstation, at: 0)
        tmpCompanyTypes.enumerated().forEach { (item) in
            let index = item.offset
            let substation = item.element
            let offsetX: CGFloat =  (95 + spaceW) * CGFloat(index % 3) + 14
            let offsetY: CGFloat =  CGFloat(15 + 40 * (index / 3))
            let btn = UIButton().text(substation).textColor(.kColor33).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            sv.sv(btn)
            sv.layout(
                offsetY,
                |-offsetX-btn.width(95).height(30),
                >=15
            )
            if index == currentCompanyTypeIndex {
                btn.textColor(.k2FD4A7).backgroundColor(.kF2FFFB).borderColor(.k2FD4A7).borderWidth(0.5)
            }
            btn.tag = index
            btn.addTarget(self, action: #selector(companyTypeBtnsClick(btn:)))
        }
    }
    
    @objc func companyTypeBtnsClick(btn: UIButton) {
        currentCompanyTypeIndex = btn.tag
        companyTypeSelectLab.text(btn.titleLabel?.text ?? "公司类型")
        switch btn.tag {
        case 0:
            storeType = nil
        case 1:
            storeType = 1
        case 2:
            storeType = 2
        case 3:
            storeType = 3
        default:
            storeType = nil
        }
        current = 1
        loadData()
        resetSelectStatus()
    }
    
    // MARK: - 人气
    @objc private func starsSelectBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            starsSelectLab.textColor(.k2FD4A7)
            sortType = 2
        } else {
            starsSelectLab.textColor(.kColor66)
            sortType = nil
        }
        current = 1
        loadData()
    }
    
    
    @objc func dismiss(tap: UITapGestureRecognizer) {
        resetSelectStatus()
    }
    
    func resetSelectStatus() {
        pop?.dismiss()
        substationSelectIV.image(#imageLiteral(resourceName: "gx_qc_arrow_down"))
        companyTypeSelectIV.image(#imageLiteral(resourceName: "gx_qc_arrow_down"))
    }
    
}

extension CompanysVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roleModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = roleModels?[indexPath.row]
        let cell = UITableViewCell()
        
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v.height(103)-14-|,
            5
        )
        v.addShadowColor()
        v.cornerRadius(5)
        
        let logo = UIImageView().image(#imageLiteral(resourceName: "companys_logo")).cornerRadius(2)
        let name = UILabel().text(model?.name ?? "").textColor(.kColor33).fontBold(14)
        let cityName = UILabel().text(model?.cityName ?? "").textColor(.kColor99).font(12)
        let address = UILabel().text(model?.address ?? "").textColor(.kColor66).font(10)
        let chatBtn = UIButton().image(#imageLiteral(resourceName: "sjs_chat"))
        let phoneBtn = UIButton().image(#imageLiteral(resourceName: "sjs_contact"))
        
        if !logo.addImage(model?.storeLogo) {
            logo.image(#imageLiteral(resourceName: "companys_logo"))
        }
        
        v.sv(logo, name, address, chatBtn, phoneBtn, cityName)
        v.layout(
            10,
            |-10-logo.width(103).height(83),
            10
        )
        v.layout(
            10,
            |-123-name.height(20)-10-|,
            6.32,
            |-123-cityName.height(16.5),
            26.5,
            |-123-address.height(16.5)-14-|,
            >=0
        )
        v.layout(
            36.5,
            chatBtn.size(30)-15-phoneBtn.size(30)-15-|,
            >=0
        )
        chatBtn.tag = indexPath.row
        phoneBtn.tag = indexPath.row
        chatBtn.addTarget(self, action: #selector(chatBtnClick(btn:)))
        phoneBtn.addTarget(self, action: #selector(phoneBtnClick(btn:)))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = roleModels?[indexPath.row]
        let vc = CompanyDetailVC()
        vc.roleModel = model
        vc.storeId = model?.id
        navigationController?.pushViewController(vc)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PublicSize.kBottomOffset + 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    @objc private func chatBtnClick(btn: UIButton) {
        contactSubstation(index: btn.tag)
    }
    
    /// 进入联系客服页面
    func contactSubstation(index: Int) {
        let roleModel = roleModels?[index]
        var userId = ""
        var userName = ""
        var headUrl = ""
        var tel1 = ""
        let tel2 = ""
        let storeName = ""
        let nickname = ""
        let storeType = "3"
        
        if let valueStr = roleModel?.id {
            userId = valueStr
        }
        if let valueStr = roleModel?.userName {
            userName = valueStr
        }
        if let valueStr = roleModel?.logoUrl {
            headUrl = valueStr
        }
        if let valueStr = roleModel?.mobile {
            tel1 = valueStr
        }
        
        let ex: NSDictionary = ["detailTitle": storeName, "headUrl":headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
        
        let user = JMSGUserInfo()
        user.nickname = nickname
        user.extras = ex as! [AnyHashable : Any]
        updConsultNumRequest(id: userId)
        YZBChatRequest.shared.createSingleMessageConversation(username: userName) { (conversation, error) in
            if error == nil {
                
                if let userInfo = conversation?.target as? JMSGUser {
                    
                    let userName = userInfo.username
                    self.pleaseWait()
                    
                    YZBChatRequest.shared.getUserInfo(with: userName) { (user, error) in
                        
                        self.clearAllNotice()
                        if error == nil {
                            let vc = ChatMessageController(conversation: conversation!)
                            vc.convenUser = user
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }else {
                if error!._code == 898002 {
                    
                    YZBChatRequest.shared.register(with: userName, pwd: YZBSign.shared.passwordMd5(password: userName), userInfo: user, errorBlock: { (error) in
                        if error == nil {
                            self.contactSubstation(index: index)
                        }
                    })
                }
            }
        }
    }
    
    @objc private func phoneBtnClick(btn: UIButton) {
        let roleModel = roleModels?[btn.tag]
        houseListCallTel(name: roleModel?.name ?? "", phone: roleModel?.mobile ?? "")
    }
}

