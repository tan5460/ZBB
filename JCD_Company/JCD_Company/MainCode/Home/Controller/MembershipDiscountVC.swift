//
//  MembershipDiscountVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/6.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh
import ObjectMapper
import TLTransitions

class MembershipDiscountVC: BaseViewController, UIScrollViewDelegate {

    private var pop: TLTransition?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private lazy var titleBar: ZFTitleBar = {
        let titleBar = ZFTitleBar()
        titleBar.mainTitleLabel.text("会员体验")
        titleBar.titleLabel.text("会员体验")
        titleBar.maxScrollY = PublicSize.kNavBarHeight
        return titleBar
    }()
    private let tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.white)
    
    
    private let navBarView = UIView().backgroundColor(.white)
    private var noDataBtn = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        statusStyle = .lightContent
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
        view.sv(tableView, titleBar)
        view.layout(
            0,
            |titleBar| ~ PublicSize.kNavBarHeight,
            >=0
        )
        view.layout(
            0,
            |tableView|,
            0
        )
        navBarView.alpha = 0
        tableView.tableHeaderView = tableHeaderView()
        view.bringSubviewToFront(titleBar)
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter {  [weak self] in
            self?.current += 1
            self?.loadData()
        }
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无活动～").textColor(.kColor66).font(14)
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
        pleaseWait()
        loadData()
    }
    private var current = 1
    private var size = 10
    private var dataSource = [marketModel]()
    func loadData() {
        var parameters = Parameters()
        parameters["marketId"] = "8365d861b394bedfe0966eaecc739018" // 营销活动id
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.jcdMarketingMaterials, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let pageModel = Mapper<PagesModel>().map(JSON: dataDic as! [String : Any])
                let models = Mapper<marketModel>().mapArray(JSONObject: pageModel?.records) ?? [marketModel]()
                if self.current == 1 {
                    self.dataSource = models
                } else {
                    self.dataSource.append(contentsOf: models)
                }
                self.tableView.reloadData()
                if pageModel?.hasNextPage ?? false {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
                self.tableView.endHeaderRefresh()
                self.noDataBtn.isHidden = self.dataSource.count > 0
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
    
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "home_banner_hyzx")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "home_banner_hyzx")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    private let headerView = UIView()
    private func tableHeaderView() -> UIView {
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: 135+PublicSize.kNavBarHeight)
        let topBgView = UIView()
        headerView.sv(topBgView, cycleScrollView)
        headerView.layout(
            0,
            |topBgView| ~ 156.5-88+PublicSize.kNavBarHeight,
            >=0
        )
        topBgView.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 15)
        topBgView.fillGreenColorV()
        headerView.layout(
            PublicSize.kNavBarHeight+15,
            |-14-cycleScrollView-14-| ~ 110,
            >=0
        )
        return headerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        titleBar.setTransparent(scrollView.contentOffset.y)
    }

}
// MARK: - 按钮点击方法
extension MembershipDiscountVC {
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
}

extension MembershipDiscountVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell().backgroundColor(.white)
        let v = UIView().backgroundColor(.white).cornerRadius(5)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        v.addShadowColor()
        
        let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
        let titleLabel = UILabel().text("\(model.materials?.name ?? "")").textColor(.kColor33).fontBold(14)
        let priceBg = UIImageView().image(#imageLiteral(resourceName: "home_hyzx_cell_bg"))
        let priceDes = UILabel().text("会员\n专享").textColor(UIColor.hexColor("#FFF1B5")).fontBold(12)
        let price = UILabel().text("￥\(model.activityPriceMin?.doubleValue ?? 0)").textColor(.kDF2F2F).fontBold(14)
        let priceShow = UILabel().text("市场价：￥\(model.materials?.priceShowMin?.doubleValue ?? 0)").textColor(.kColor99).font(10)
        titleLabel.numberOfLines(2).lineSpace(2)
        priceDes.numberOfLines(2).lineSpace(2)
        priceShow.setLabelUnderline()
        icon.cornerRadius(3).masksToBounds()
        icon.contentMode = .scaleAspectFill
        if !icon.addImage(model.materials?.imageUrl) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        
        v.sv(icon, titleLabel, priceBg, priceShow)
        v.layout(
            14,
            |-14-icon.size(100),
            14
        )
        v.layout(
            14,
            |-128-titleLabel-14-|,
            >=0,
            |-128-priceBg.width(151).height(49),
            0,
            |-128-priceShow.height(14),
            14
        )
        priceBg.sv(priceDes, price)
        priceBg.layout(
            6.5,
            |-16-priceDes.width(25).height(33),
            9.5
        )
        priceBg.layout(
            13,
            |-69.5-price.height(20),
            16
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        
        let vipType = UserData.shared.userInfoModel?.yzbVip?.vipType
        if vipType == 1 {
            self.vipDistTipPopView() //普通会员会提醒去开通体验会员
        } else { // 已经是体验会员直接进入会员专享页面
            let vc = MarketMateriasDetailVC()
            let material = MaterialsModel()
            material.id = model.id
            vc.materialsModel = material
            navigationController?.pushViewController(vc)
        }
        
        
    }
    
    //TODO: 需要完善
    //MARK: - 会员专区点击提醒框
    func vipDistTipPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 272, height: 210)).backgroundColor(.white)
        let icon = UIImageView().image(#imageLiteral(resourceName: "purchase_icon_vip_tip"))
        let titleLab = UILabel().text("很抱歉，会员专区仅限缴费会员使用，9.9元开通体验会员即可畅享").textColor(.kColor66).font(12)
        titleLab.numberOfLines(2).lineSpace(2)
        let ktBtn = UIButton().text("立即开通").textColor(.white).font(14)
        let cancelBtn = UIButton().text("取 消").textColor(.kColor66).font(12)
        v.sv(icon, titleLab, ktBtn, cancelBtn)
        v.layout(
            20,
            icon.size(50).centerHorizontally(),
            10,
            titleLab.width(236).centerHorizontally(),
            >=0,
            ktBtn.width(130).height(30).centerHorizontally(),
            5,
            cancelBtn.width(130).height(26.5).centerHorizontally(),
            15.5
        )
        
        ktBtn.corner(radii: 15).fillGreenColorLF()
        ktBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss(completion: {
//                let vc = UIBaseWebViewController()
//                vc.urlStr = "http://192.168.1.16:8080/#/new-member?id=1"
//                self?.navigationController?.pushViewController(vc)
             //   self?.loadLevelsData()
                let vc = MembershipLevelsVC()
                self?.navigationController?.pushViewController(vc)
            })
        }
        cancelBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss()
        }
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PublicSize.kBottomOffset
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.white)
    }
}


class marketModel : NSObject, Mappable{

    var activityPriceMax : NSNumber?
    var activityPriceMin : NSNumber?
    var createBy : String?
    var createTime : String?
    var id : String?
    var marketId : String?
    var materials : MaterialsModel?
    var materialsId : String?
    var status : Int?


    required init?(map: Map){}
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        activityPriceMax <- map["activityPriceMax"]
        activityPriceMin <- map["activityPriceMin"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        id <- map["id"]
        marketId <- map["marketId"]
        materials <- map["materials"]
        materialsId <- map["materialsId"]
        status <- map["status"]
    }

}
