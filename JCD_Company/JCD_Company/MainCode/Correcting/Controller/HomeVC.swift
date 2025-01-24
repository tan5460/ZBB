//
//  HomeVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/23.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class HomeVC: BaseViewController, LLCycleScrollViewDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private var tableView = UITableView.init(frame: .zero, style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        let topIV = UIImageView().image(#imageLiteral(resourceName: "home_top_bg"))
        view.sv(topIV)
        view.layout(
            0,
            |topIV.height(160)|,
            >=0
        )
        tableView.backgroundColor(.clear)
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
            0,
            |tableView|,
            0
        )
        tableView.refreshHeader { [weak self] in
            self?.loadData()
            self?.requestAdvertList()
            self?.loadCaseData()
        }
        //获取用户本地信息
        AppUtils.getLocalUserData()
        loadData()
        requestAdvertList()
        loadCaseData()
    }
    
    //MARK: - 获取广告图列表
    private var advertModel: AdvertModel?
    func requestAdvertList()  {
        YZBSign.shared.request(APIURL.advertList, method: .get, parameters: Parameters()) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.advertModel = Mapper<AdvertModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
            }
            self.tableView.endHeaderRefresh()
        } failure: { (error) in
            self.tableView.endHeaderRefresh()
        }
    }
    
    private var exchangeData: MaterialsCorrcetModel?
    private var exchangeImagePaths:Array<String> = []
    //MARK: - 网络请求
    func loadData() {
        let urlStr = APIURL.getMaterialsList
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            self.tableView.endHeaderRefresh()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.exchangeData = Mapper<MaterialsCorrcetModel>().map(JSON: dataDic as! [String : Any])
            }
            self.tableView.reloadData()
            
        }) { (error) in
            
            // 结束刷新
            self.tableView.endHeaderRefresh()
        }
    }
    
    private var caseModels: [HouseCaseModel] = []
    func loadCaseData() {
        var storeId = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeId = valueStr
        }
        let pageSize = 5
        var parameters: Parameters = ["userId": storeId, "size": "\(pageSize)", "current": "1"]
        parameters["citySubstation"] = UserData.shared.substationModel?.id
        let urlStr = APIURL.getHouseCase
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            self.tableView.endHeaderRefresh()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<HouseCaseModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.caseModels = modelArray
                
            }
            self.tableView.reloadData()
        }) { (error) in
            // 结束刷新
            self.tableView.endHeaderRefresh()
        }
    }
    
    //MARK: - banner栏目
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = UIImage()
        cycleScrollView.placeHolderImage = UIImage()
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        let model = advertModel?.carouselList?[index]
        if let advertLink = model?.advertLink {
            let vc = UIBaseWebViewController()
            vc.urlStr = advertLink
            if model?.whetherCanShare == "2" {
                vc.isShare = false
            } else {
                vc.isShare = true
            }
            navigationController?.pushViewController(vc)
        }
    }

    func configSection0(cell: UITableViewCell) {
        cell.sv(cycleScrollView)
        cell.layout(
            68,
            |-14-cycleScrollView.height(170)-14-|,
            5
        )
        cycleScrollView.delegate = self
        var paths = [String]()
        advertModel?.carouselList?.forEach({ (model) in
            paths.append("\(APIURL.ossPicUrl)/\(model.advertImg ?? "")")
        })
        cycleScrollView.imagePaths = paths
    }
    func configSection1(cell: UITableViewCell) {
        let iv1 = UIImageView().image(#imageLiteral(resourceName: "home_icon_1"))
        let iv2 = UIImageView().image(#imageLiteral(resourceName: "home_icon_2"))
        let lab1 = UILabel().text("品牌制造商直供，高性价比").textColor(.kColor66).font(10)
        let lab2 = UILabel().text("平安等五大公司承保，退换无忧").textColor(.kColor66).font(10)
        let lineIV = UIImageView().image(#imageLiteral(resourceName: "home_icon_3"))
        cell.sv(iv1, iv2, lab1, lab2, lineIV)
        cell.layout(
            10,
            |-14-iv1.size(15)-4-lab1-(>=0)-iv2.size(15)-4-lab2-14-|,
            15,
            |-14-lineIV.height(3.36)-14-|,
            5
        )
    }
    //MARK: - item菜单
    func configSection2(cell: UITableViewCell) {
        let icons = [#imageLiteral(resourceName: "home_icon_4_1"),#imageLiteral(resourceName: "home_icon_4_2"),#imageLiteral(resourceName: "home_icon_4_3"),#imageLiteral(resourceName: "home_icon_4_4")]
        let titles = ["品牌馆", "示范案例", "VR设计", "工地管理"]
        titles.enumerated().forEach { (item) in
            let title = item.element
            let index = item.offset
            let icon = icons[index]
            let btnH: CGFloat = 86.5
            let btnW: CGFloat = view.width/4
            let offsetX: CGFloat = btnW * (CGFloat(index%4))
            let offsetY: CGFloat = 0
            let btn = UIButton().image(icon).text(title).textColor(.kColor33).font(10)
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                5
            )
            btn.layoutButton(imageTitleSpace: 10)
            btn.tag = index
            btn.tapped { [weak self] (tapBtn) in
                self?.itemBtnAction(tag: tapBtn.tag)
            }
        }
    }
    
    func itemBtnAction(tag: Int) {
        switch tag {
        case 0:
            toBrandHouse()
        case 1:
            toWholeHouse()
        case 2:
            toVR()
        case 3:
            toSiteManager()
        default:
            break
        }
    }
    /// 品牌馆
    func toBrandHouse() {
        let vc = BrandIntroductionController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 客户案例
    func toWholeHouse() {
        let vc = WholeHouseController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// VR
    func toVR() {
        let vc = VRDesignController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 工地管理
    func toSiteManager() {
        let vc = HouseViewController()
        vc.title = "我的工地"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - 新品专区，本期主推，口碑热销
    func configSection3(cell: UITableViewCell) {
        let topIV = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_1"))
        let bottomView = UIView()
        cell.sv(topIV, bottomView)
        cell.layout(
            20,
            |-12-topIV.height(121)-12-|,
            -10,
            |-14-bottomView.height(140)-14-|,
            5
        )
        bottomView.width(view.width-28).height(140)
        bottomView.layoutIfNeeded()
        fillBottomViewColor(v: bottomView)
        bottomView.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 14.9)
        
        let xpzqBtn = UIButton().backgroundColor(UIColor.hexColor("#EBF1D2"))
        let bqztBtn = UIButton().backgroundColor(UIColor.hexColor("#F1E9D2"))
        let kbrxBtn = UIButton().backgroundColor(UIColor.hexColor("#F1EFD2"))
        bottomView.sv(xpzqBtn, bqztBtn, kbrxBtn)
        bottomView.layout(
            10,
            |-10-xpzqBtn-10.5-bqztBtn-10.5-kbrxBtn-10-|,
            10
        )
        equal(sizes: xpzqBtn, bqztBtn, kbrxBtn)
        
        configXPZQBtn(btn: xpzqBtn)
        configBQZTBtn(btn: bqztBtn)
        configKBRXBtn(btn: kbrxBtn)
        xpzqBtn.tapped { [weak self] (btn) in
            self?.toMaterialsVC(type: 1)
        }
        bqztBtn.tapped { [weak self] (btn) in
            self?.toMaterialsVC(type: 2)
        }
        kbrxBtn.tapped { [weak self] (btn) in
            self?.toMaterialsVC(type: 3)
        }
    }
    
    func toMaterialsVC(type: Int) {
        let vc = MaterialsVC()
        vc.type = type
        navigationController?.pushViewController(vc)
    }
    
    
    
    func fillBottomViewColor(v: UIView) {
        // fill
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.79, green: 0.83, blue: 0.5, alpha: 1).cgColor, UIColor(red: 0.44, green: 0.51, blue: 0.28, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = v.bounds
        bgGradient.startPoint = CGPoint(x: 0.5, y: 0.04)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 0.99)
        v.layer.insertSublayer(bgGradient, at: 0)
    }
    
    func configXPZQBtn(btn: UIButton) {
        let lab1 = UILabel().text("新品专区").textColor(UIColor.hexColor("#01884D")).fontBold(14)
        let lab2 = UILabel().text("超多新品等你来").textColor(UIColor.hexColor("#39AE7B")).font(10)
        let iv1 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_2"))
        let iv2 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_5"))
        btn.sv(lab1, lab2, iv1, iv2)
        btn.layout(
            10,
            |-10-lab1.height(20),
            5,
            |-10-lab2.height(14),
            27,
            |iv2|,
            0
        )
        btn.layout(
            60,
            iv1.width(41.5).height(45).centerHorizontally(),
            >=0
        )
    }
    
    func configBQZTBtn(btn: UIButton) {
        let lab1 = UILabel().text("本期主推").textColor(UIColor.hexColor("#E55A28")).fontBold(14)
        let lab2 = UILabel().text("严选高性价比产品").textColor(UIColor.hexColor("#E57C56")).font(10)
        let iv1 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_3"))
        let iv2 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_6"))
        btn.sv(lab1, lab2, iv1, iv2)
        btn.layout(
            10,
            |-10-lab1.height(20),
            5,
            |-10-lab2.height(14),
            27,
            |iv2|,
            0
        )
        btn.layout(
            64.5,
            iv1.width(74).height(35).centerHorizontally(),
            >=0
        )
    }
    
    func configKBRXBtn(btn: UIButton) {
        let lab1 = UILabel().text("口碑热销").textColor(UIColor.hexColor("#AC7152")).fontBold(14)
        let lab2 = UILabel().text("买过的都说好").textColor(UIColor.hexColor("#CE9D83")).font(10)
        let iv1 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_4"))
        let iv2 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_7"))
        btn.sv(lab1, lab2, iv1, iv2)
        btn.layout(
            10,
            |-10-lab1.height(20),
            5,
            |-10-lab2.height(14),
            27,
            |iv2|,
            0
        )
        btn.layout(
            64.5,
            iv1.width(73).height(33).centerHorizontally(),
            >=0
        )
    }
    //MARK: - 我的家
    func configSection4(cell: UITableViewCell) {
        let v = UIView().backgroundColor(UIColor.hexColor("#F4F6E5")).cornerRadius(10).masksToBounds()
        let spaceView = UIView().backgroundColor(.kBackgroundColor)
        cell.sv(v, spaceView)
        cell.layout(
            10,
            |-14-v.height(55)-14-|,
            15,
            |spaceView.height(5)|,
            0
        )
        let btn1 = UIButton().image(#imageLiteral(resourceName: "home_icon_6-1")).backgroundColor(UIColor.hexColor("#718348")).cornerRadius(35/2).masksToBounds()
        let lab1 = UILabel().text("免费获取全屋搭配方案").textColor(UIColor.hexColor("#01884D")).font(12)
        let lab2 = UILabel().text("专业家居顾问为您服务").textColor(UIColor.hexColor("#01884D")).font(10)
        let homeBtn = UIButton().text("我的家").textColor(.white).font(12).backgroundColor(UIColor.hexColor("#718348")).cornerRadius(15).masksToBounds()
        let rightIV = UIImageView().image(#imageLiteral(resourceName: "home_icon_6"))
        v.sv(btn1, lab1, lab2, rightIV, homeBtn)
        v.layout(
            0,
            rightIV.width(97.79).height(55)-0-|,
            0
        )
        v.layout(
            10,
            |-10-btn1.size(35)-(>=0)-homeBtn.width(70).height(26)-15.5-|,
            10
        )
        v.layout(
            10,
            |-55-lab1.height(16.5),
            4,
            |-55-lab2.height(14),
            >=0
        )
        homeBtn.tapped { [weak self] (tapBtn) in
            self?.toSiteManager()
        }
    }
    
    func configSection5(cell: UITableViewCell) {
        let lab1 = UILabel().text("公司案例").textColor(.kColor33).fontBold(20)
        let moreBtn = UIButton().text("查看更多").textColor(.kColor66).font(12)
        
        cell.sv(lab1, moreBtn)
        cell.layout(
            15,
            |-14-lab1.height(28)-(>=0)-moreBtn.height(40)-14-|,
            >=0
        )
        
        caseModels.enumerated().forEach { (item) in
            let index = item.offset
            let model = item.element
            let btnW: CGFloat = view.width-28
            let btnH: CGFloat = 90
            let offsetX: CGFloat = 14
            let offsetY: CGFloat = 58 + (btnH+10)*CGFloat(index)
            let btn = UIButton().backgroundColor(.white)
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=30
            )
            btn.cornerRadius(5)
            let icon = UIImageView().image(#imageLiteral(resourceName: "service_mall_banner_bg")).cornerRadius(0).masksToBounds()
            icon.contentMode = .scaleAspectFit
            if !icon.addImage(model.mainImgUrl1) {
                icon.image(#imageLiteral(resourceName: "loading"))
            }
            let titleLabel = UILabel().text(model.caseRemarks ?? "").textColor(.kColor33).font(14)
            let addressIV = UIImageView().image(#imageLiteral(resourceName: "home_icon_7"))
            let addressLabel = UILabel().text(model.communityName ?? "").textColor(.kColor66).font(12)
            btn.sv(icon, titleLabel, addressIV, addressLabel)
            btn.layout(
                0,
                |icon.width(120).height(90),
                0
            )
            btn.layout(
                0,
                |-134-titleLabel-0-|,
                >=0
            )
            btn.layout(
                >=0,
                |-148-addressLabel-14-|,
                2
            )
            addressLabel.numberOfLines(0).lineSpace(2)
            |-134-addressIV.width(10).height(13)
            addressIV.CenterY == addressLabel.CenterY
            titleLabel.numberOfLines(0).lineSpace(2)
            
            btn.tag = index
            btn.tapped { [weak self] (tapBtn) in
                self?.toWholeHouseDetailVC(tag: tapBtn.tag)
            }
        }
        moreBtn.tapped { [weak self] (tapBtn) in
            self?.toWholeHouse()
        }
    }
    
    func toWholeHouseDetailVC(tag: Int) {
        let vc = WholeHouseDetailController()
        if let url = caseModels[tag].url {
            vc.detailUrl = url
        }
        vc.caseModel = self.caseModels[tag]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            cell.backgroundColor(.clear)
            configSection0(cell: cell)
        case 1:
            configSection1(cell: cell)
        case 2:
            configSection2(cell: cell)
        case 3:
            configSection3(cell: cell)
        case 4:
            configSection4(cell: cell)
        case 5:
            configSection5(cell: cell)
        default:
            break
        }
        return cell
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
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
