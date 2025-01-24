//
//  CompanyDetailVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/10.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper


struct NameAgeModel {
    var name: String?
    var age: Int?
}

class CompanyDetailVC: BaseViewController {
    var storeId: String?
    var roleModel: RoleModel?
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    private var bottomView = UIView().backgroundColor(.white)
    
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .snake
        cycleScrollView.customPageControlTintColor = .k1DC597
        cycleScrollView.customPageControlInActiveTintColor = #colorLiteral(red: 0.1137254902, green: 0.7725490196, blue: 0.5921568627, alpha: 0.4013270548)
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "Company_detail_banner_default")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "Company_detail_banner_default")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "公司详情"
        
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
        view.sv(tableView, bottomView)
        view.layout(
            0,
            |tableView|,
            0,
            |bottomView|,
            0
        )
        tableView.refreshHeader { [weak self] in
            self?.loadData()
        }
        loadData()
        bottomView.height(50+PublicSize.kBottomOffset)
        configBootomView()
        cycleScrollView.delegate = self
    }
    
    private var detailModel: CompanyDetailModel?
    private func loadData() {
        var parameters = Parameters()
        parameters["storeId"] = storeId
        YZBSign.shared.request(APIURL.getCompanyDetail, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.detailModel = Mapper<CompanyDetailModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
            }
            self.tableView.endHeaderRefresh()
        }) { (error) in
            self.tableView.endHeaderRefresh()
        }
    }
    
    private func configBootomView() {
        let phoneImage =  #imageLiteral(resourceName: "company_detail_bottom_phone")
        let phoneBtn = UIButton().image(phoneImage).text("电话").textColor(.kColor66).font(10)
        let zxBtn = UIButton().text("立即咨询").textColor(.white).font(14).backgroundColor(#colorLiteral(red: 1, green: 0.631372549, blue: 0.003921568627, alpha: 1)).cornerRadius(20).masksToBounds()
        bottomView.sv(phoneBtn, zxBtn)
        bottomView.layout(
            5,
            |-14-phoneBtn.width(82).height(40)-14-zxBtn.height(40)-14-|,
            >=0
        )
        phoneBtn.layoutButton(imageTitleSpace: 3)
        phoneBtn.addTarget(self, action: #selector(phoneBtnClick(btn:)))
        zxBtn.addTarget(self, action: #selector(chatBtnClick(btn:)))
    }
}

// MARK: - LLCycleScrollViewDelegate
extension CompanyDetailVC: LLCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        if detailModel?.bannerList?.count ?? 0 > 0 {
            if let urlStr = detailModel?.bannerList?[index].linkUrl, !urlStr.isEmpty {
                let webVC = UIBaseWebViewController()
                webVC.urlStr = detailModel?.bannerList?[index].linkUrl
                navigationController?.pushViewController(webVC)
            }
        }
    }
    
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, scrollTo index: NSInteger) {
       // countLabel.text = " \(index+1)/\(cycleScrollView.imagePaths.count) "
    }
}

extension CompanyDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            configSection0(v: cell)
        case 1:
            configSection1(v: cell)
        case 2:
            configSection2(v: cell)
        case 3:
            configSection3(v: cell)
        case 4:
            configSection4(v: cell)
        case 5:
            configSection5(v: cell)
        case 6:
            configSection6(v: cell)
        default:
            break
        }
        return cell
    }
    
    
    func configSection0(v: UITableViewCell) {
        v.sv(cycleScrollView)
        v.layout(
            0,
            |cycleScrollView.height(230)|,
            0
        )
        var imagePaths: [String] = []
        detailModel?.bannerList?.forEach({ (model) in
            imagePaths.append(APIURL.ossPicUrl + (model.fileUrl ?? ""))
        })
        cycleScrollView.imagePaths = imagePaths
    }
    
    func configSection1(v: UITableViewCell) {
        let model = detailModel?.store
        v.backgroundColor(.white)
        let content = UIView().backgroundColor(.white)
        v.sv(content)
        v.layout(
            10,
            |-14-content.height(137)-14-|,
            10
        )
        content.cornerRadius(5)
        content.addShadowColor()
        
        
        let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
        if !icon.addImage(model?.storeLogo) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        let title = UILabel().text(model?.storeName ?? "").textColor(.kColor33).fontBold(14)
        let caseLab = UILabel().text("案例：\(model?.houseCaseCount ?? 0)").textColor(.kColor33).font(12)
        let siteLab = UILabel().text("工地：\(model?.houseCount ?? 0)").textColor(.kColor33).font(12)
        let yearLab = UILabel().text("营业年限：\(model?.businessYears ?? "0")年").textColor(.kColor33).font(12)
        let line = UIView().backgroundColor(.kColor220)
        let phoneIV = UIImageView().image(#imageLiteral(resourceName: "company_detail_phone"))
        let phone = UILabel().text(model?.storeMobile ?? "暂无").textColor(.kColor33).font(12)
        let addressIV = UIImageView().image(#imageLiteral(resourceName: "company_detail_address"))
        let address = UILabel().textColor(.kColor33).font(12)
        if let storeAddress = model?.storeAddress, !storeAddress.isEmpty {
            address.text(storeAddress)
        } else {
            address.text("暂无")
        }
        let tipLab = UILabel().text("近期\(model?.storeConsult ?? 0)人咨询").textColor(.kColor99).font(10)
        content.sv(icon, title, caseLab, siteLab, yearLab, line, phoneIV, phone, addressIV, address, tipLab)
        content.layout(
            15,
            |-15-icon.width(55).height(44),
            10.5,
            |-15.5-line.height(0.5)-14.5-|,
            10.5,
            |-15-phoneIV.size(15)-5-phone,
            11.5,
            |-15-addressIV.size(15)-5-address,
            15.5
        )
        content.layout(
            15,
            |-80-title.height(20)-14-|,
            7.5,
            |-80-caseLab.height(16.5)-30-siteLab-30-yearLab,
            21.5,
            tipLab.height(14)-15-|,
            >=0
        )
        
    }
    
    func configSection2(v: UITableViewCell) {
        let storeIntro = detailModel?.store?.storeIntro
        let title = UILabel().text("公司介绍").textColor(.kColor33).fontBold(14)
        if storeIntro == nil {
            let noDataIV = UIImageView().image(#imageLiteral(resourceName: "company_detail_no_js"))
            let noDataLab = UILabel().text("暂无介绍").textColor(.kColor99).font(12)
            v.sv(title, noDataIV, noDataLab)
            v.layout(
                15,
                |-14-title.height(20),
                15,
                noDataIV.width(100).height(73).centerHorizontally(),
                10,
                noDataLab.height(16.5).centerHorizontally(),
                15
            )
        } else {
            let detailTitle = UILabel().text(storeIntro ?? "").textColor(.kColor33).font(12)
            v.sv(title, detailTitle)
            v.layout(
                15,
                |-14-title.height(20),
                10,
                |-14-detailTitle-14-|,
                15
            )
            detailTitle.numberOfLines(0).lineSpace(2)
        }
        
    }
    
    func configSection3(v: UITableViewCell) {
        let certificateList = detailModel?.certificateList
        let title = UILabel().text("企业证书").textColor(.kColor33).fontBold(14)
        let moreBtn = UIButton().text("更多>").textColor(.kColor66).font(10)
        let cerBtn1 = UIButton().image(#imageLiteral(resourceName: "loading")).cornerRadius(5).borderColor(.kColor220).borderWidth(0.5)
        let cerBtn2 = UIButton().image(#imageLiteral(resourceName: "loading")).cornerRadius(5).borderColor(.kColor220).borderWidth(0.5)
        if certificateList?.count == 0 {
            let noDataIV = UIImageView().image(#imageLiteral(resourceName: "company_detail_no_zs"))
            let noDataLab = UILabel().text("暂无证书").textColor(.kColor99).font(12)
            v.sv(title, noDataIV, noDataLab)
            v.layout(
            15,
            |-14-title.height(20),
            15,
            noDataIV.width(100).height(73).centerHorizontally(),
            10,
            noDataLab.height(16.5).centerHorizontally(),
            15
            )
        } else {
            v.sv(title, moreBtn, cerBtn1, cerBtn2)
            v.layout(
                15,
                |-14-title.height(20)-(>=0)-moreBtn.height(30)-14-|,
                10,
                |-12-cerBtn1.height(117)-11-cerBtn2.height(117)-12-|,
                15
            )
            equal(widths: cerBtn1, cerBtn2)
            
            cerBtn1.imageView?.contentMode = .scaleAspectFit
            cerBtn2.imageView?.contentMode = .scaleAspectFit
            cerBtn1.addImage(certificateList?[0].fileUrl)
            if certificateList?.count ?? 0 > 1 {
                cerBtn2.addImage(certificateList?[1].fileUrl)
            }
            cerBtn1.addTarget(self, action: #selector(cerBtn1Click(btn:)))
            cerBtn2.addTarget(self, action: #selector(cerBtn2Click(btn:)))
        }
        moreBtn.addTarget(self, action: #selector(cerBtnClick(btn:)))
    }
    
    @objc private func cerBtn1Click(btn: UIButton) {
        let phoneVC = IMUIImageBrowserController()
        let urlStr = APIURL.ossPicUrl + (detailModel?.certificateList?.first?.fileUrl ?? "")
        let url = URL.init(string: urlStr)
        if let url1 = url {
            phoneVC.imageArr = [url1]
            phoneVC.imgCurrentIndex = 0
            phoneVC.title = "查看大图"
            phoneVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(phoneVC)
        }
    }
    
    @objc private func cerBtn2Click(btn: UIButton) {
        if detailModel?.certificateList?.count ?? 0 > 1 {
            let phoneVC = IMUIImageBrowserController()
            let urlStr = APIURL.ossPicUrl + (detailModel?.certificateList?[1].fileUrl ?? "")
            let url = URL.init(string: urlStr)
            if let url1 = url {
                phoneVC.imageArr = [url1]
                phoneVC.imgCurrentIndex = 0
                phoneVC.title = "查看大图"
                phoneVC.modalPresentationStyle = .overFullScreen
                navigationController?.pushViewController(phoneVC)
            }
        }
    }
    
    @objc private func cerBtnClick(btn: UIButton) {
        let vc = CompanyCertificateVC()
        vc.storeId = storeId
        navigationController?.pushViewController(vc)
    }
    
    func configSection4(v: UITableViewCell) {
        let houseCaseList = detailModel?.houseCaseList
        let title = UILabel().text("工程项目展示").textColor(.kColor33).fontBold(14)
        if houseCaseList?.count == 0 {
            let noDataIV = UIImageView().image(#imageLiteral(resourceName: "company_detail_no_xm"))
            let noDataLab = UILabel().text("暂无项目").textColor(.kColor99).font(12)
            v.sv(title, noDataIV, noDataLab)
            v.layout(
                15,
                |-14-title.height(20),
                15,
                noDataIV.width(100).height(64).centerHorizontally(),
                10,
                noDataLab.height(16.5).centerHorizontally(),
                20
            )
        } else {
            let allBtn = UIButton().text("查看全部项目>").textColor(.kColor99).font(10).borderWidth(0.5).borderColor(.kColor220)
            let btnW: CGFloat = view.width - 28
            let btnH: CGFloat = 130
            v.sv(title, allBtn)
            v.layout(
                15,
                |-14-title.height(20),
                >=15,
                allBtn.width(140).height(22).centerHorizontally(),
                15
            )
            allBtn.cornerRadius(11).masksToBounds()
            houseCaseList?.enumerated().forEach { (item) in
                let index = item.offset
                let houseCase = item.element
                let offsetX: CGFloat = 14
                let offsetY: CGFloat = 50 + CGFloat(btnH + 10) * CGFloat(index)
                let btn = UIButton().backgroundColor(#colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1))
                v.sv(btn)
                v.layout(
                    offsetY,
                    |-offsetX-btn.width(btnW).height(btnH),
                    >=52
                )
                let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
                let name = UILabel().text(houseCase.caseRemarks ?? "").textColor(.kColor33).fontBold(12)
                
                
                let rule1 = UILabel().text("户型面积：\(houseCase.houseAreaName ?? "") | \(houseCase.houseTypeName ?? "")").textColor(.kColor33).font(10)
                
                var zxStr = ""
                if houseCase.casePrice?.type == "1" {
                   zxStr = "全包"
                } else if houseCase.casePrice?.type == "2" {
                    zxStr = "半包"
                } else {
                    zxStr = "全包"
                }
                let price1 = Decimal.init(houseCase.casePrice?.totalPrice?.intValue ?? 0)
                let value1 = Decimal.init(10000)
                let totalPrice = price1 / value1
                let floatPrice = Float.init(string: "\(totalPrice)")
                let totalPriceStr = String(format: "%.2f", floatPrice ?? 0)
                
                let rule2 = UILabel().text("装修报价：\(zxStr) | \(totalPriceStr)万").textColor(.kColor33).font(10)
                btn.sv(icon, name, rule1, rule2)
                btn.layout(
                    0,
                    |icon.width(182).height(130),
                    0
                )
                btn.layout(
                    15,
                    |-192-name-10-|,
                    >=0,
                    |-192-rule1.height(14)-10-|,
                    6,
                    |-192-rule2.height(14)-10-|,
                    20
                )
                name.numberOfLines(0).lineSpace(2)
                icon.contentMode = .scaleAspectFit
                icon.masksToBounds()
                if !icon.addImage(houseCase.mainImgUrl) {
                    icon.image(#imageLiteral(resourceName: "loading"))
                }
                btn.tag = index
                btn.addTarget(self, action: #selector(xmBtnsClick(btn:)))
            }
            allBtn.addTarget(self, action: #selector(allBtnClick(btn:)))
        }
        
    }
    
    @objc private func xmBtnsClick(btn: UIButton) {
        let vc = WholeHouseDetailController()
        if let url = detailModel?.houseCaseList?[btn.tag].url {
            vc.detailUrl = url
        }
        vc.caseModel = self.detailModel?.houseCaseList?[btn.tag]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func allBtnClick(btn: UIButton) {
        let vc = WholeHouseController()
        vc.userId = storeId
        vc.citySubstation = roleModel?.citySubstation
        navigationController?.pushViewController(vc)
    }
    
    func configSection5(v: UITableViewCell) {
        let title = UILabel().text("团队成员").textColor(.kColor33).fontBold(14)
        let peoplesBtn = UIButton().text("共\(detailModel?.workerCount ?? 0)人>").textColor(.kColor66).font(10)
        peoplesBtn.addTarget(self, action: #selector(peoplesBtnClick(btn:)))
        let btnW: CGFloat = 80
        let btnH: CGFloat = 105
        let space: CGFloat = (view.width - 320)/5
        v.sv(title, peoplesBtn)
        v.layout(
            15,
            |-14-title.height(20)-(>=0)-peoplesBtn.height(30)-14-|,
            >=15
        )
        let workerList = detailModel?.workerList
        if  workerList?.count == 0 {
            peoplesBtn.isHidden = true
            let noDataIV = UIImageView().image(#imageLiteral(resourceName: "company_detail_no_member"))
            let noDataLab = UILabel().text("暂无成员").textColor(.kColor99).font(12)
            v.sv(noDataIV, noDataLab)
            v.layout(
                50,
                noDataIV.width(100).height(67).centerHorizontally(),
                10,
                noDataLab.height(16.5).centerHorizontally(),
                15
            )
        } else {
            workerList?.enumerated().forEach { (item) in
                let index = item.offset
                let model = item.element
                let offsetY = 50
                let offsetX = space + CGFloat(btnW + space) * CGFloat(index)
                let btn = UIButton()
                v.sv(btn)
                v.layout(
                    offsetY,
                    |-offsetX-btn.width(btnW).height(btnH),
                    >=10
                )
                let btnBg = UIView().backgroundColor(.white)
                let icon = UIImageView().image(#imageLiteral(resourceName: "loading")).cornerRadius(25)
                if !icon.addImage(model.headUrl) {
                    icon.image(#imageLiteral(resourceName: "loading"))
                }
                var job = ""
                switch model.jobType {
                case 1:
                    job = "工长"
                case 2:
                    job = "客户经理"
                case 3:
                    job = "设计师"
                case 4:
                    job = "采购员"
                case 999:
                    job = "管理员"
                default:
                    break
                }
                let name = UILabel().text(  job).textColor(.kColor33).fontBold(12)
                let year = UILabel().text("\(model.workingYear ?? "0")年经验").textColor(.kColor99).font(10)
                btn.sv(btnBg, icon, name, year)
                btn.layout(
                    25,
                    |btnBg.height(80)|,
                    0
                )
                btnBg.addShadowColor()
                btnBg.cornerRadius(2)
                btn.layout(
                    0,
                    icon.size(50).centerHorizontally(),
                    10,
                    name.width(btnW-5).height(16.5).centerHorizontally(),
                    5,
                    year.height(14).centerHorizontally(),
                    >=0
                )
                name.textAligment(.center)
                icon.contentMode = .scaleAspectFit
                icon.masksToBounds()
            }
        }
        
    }
    
    @objc private func peoplesBtnClick(btn: UIButton) {
        let vc  = CompanyMembersVC()
        vc.storeId = storeId
        navigationController?.pushViewController(vc)
    }
    
    func configSection6(v: UITableViewCell) {
        let title = UILabel().text("业主评价").textColor(.kColor33).fontBold(14)
        let numBtn = UIButton().text("共0条>").textColor(.kColor66).font(10)
        v.sv(title, numBtn)
        v.layout(
            15,
            |-14-title.height(20)-(>=0)-numBtn.height(30)-14-|,
            >=15
        )
        numBtn.isHidden = true
        let noDataIV = UIImageView().image(#imageLiteral(resourceName: "company_detail_no_comment"))
        let noDataLab = UILabel().text("暂无评价").textColor(.kColor99).font(12)
        v.sv(noDataIV, noDataLab)
        v.layout(
            50,
            noDataIV.width(100).height(66).centerHorizontally(),
            10,
            noDataLab.height(16.5).centerHorizontally(),
            15
        )
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section >= 2 {
            return 5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    @objc private func chatBtnClick(btn: UIButton) {
        contactSubstation()
    }
    
    /// 进入联系客服页面
    func contactSubstation() {
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
                            self.contactSubstation()
                        }
                    })
                }
            }
        }
    }
    
    @objc private func phoneBtnClick(btn: UIButton) {
        houseListCallTel(name: roleModel?.name ?? "", phone: roleModel?.mobile ?? "")
    }
}



