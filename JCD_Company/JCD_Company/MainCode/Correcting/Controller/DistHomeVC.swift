//
//  DistHomeVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/6.
//

import UIKit
import ObjectMapper
import TLTransitions
import CoreLocation

class DistHomeVC: BaseViewController, LLCycleScrollViewDelegate, AMapLocationManagerDelegate {
    var pop: TLTransition?
    var guideView = UIView()
    var canLoadMsgCountSelf = false // 是否不通过通知刷新通知未读数量
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var tableView = UITableView.init(frame: .zero, style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        
        let topIV = UIImageView().image(#imageLiteral(resourceName: "home_top_bg"))
        view.sv(topIV)
        view.layout(
            0,
            |topIV.height(156.5)|,
            >=0
        )
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
      //  locationManager.allowsBackgroundLocationUpdates = true
        locationManager.locationTimeout = 5
        locationManager.reGeocodeTimeout = 5
        locationManager.delegate = self
        locationManager.requestLocation(withReGeocode: true) { (location , geocode, error) in
            self.latitude = "\(location?.coordinate.latitude ?? 0)"
            self.longitude = "\(location?.coordinate.longitude ?? 0)"
            self.city = geocode?.city
            self.addressLabel.text(self.city ?? "")
            self.loadData()
        }
        
        let topToolView = UIView().backgroundColor(.clear)
        
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
        view.sv(topToolView, tableView)
        view.layout(
            0,
            topToolView.width(view.width).height(91),
            0,
            |tableView|,
            0
        )
        configHeaderView(v: topToolView)
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private var latitude: String?  // 经度
    private var longitude: String? // 纬度
    private var city: String? // 地址
    private let locationManager = AMapLocationManager()
    
    private var current = 1
    private var size = 10
    
    private var dataSource = [DistProductionModel]()
    
    func loadData() {
        var parameters = Parameters()
        parameters["latitude"] = latitude
        parameters["longitude"] = longitude
        parameters["current"] = current
        parameters["size"] = size                                                      
        YZBSign.shared.request(APIURL.regionMerchantBrandPage, method: .post, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let pageModel = Mapper<PagesModel>().map(JSON: dataDic as! [String : Any])
                let models = Mapper<DistProductionModel>().mapArray(JSONObject: pageModel?.records) ?? [DistProductionModel]()
                if self.current == 1 {
                    self.dataSource = models
                } else {
                    self.dataSource.append(contentsOf: models)
                }
                if pageModel?.hasNextPage ?? false {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
                self.tableView.endHeaderRefresh()
                self.tableView.reloadData()
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
    
    private let addressLabel = UILabel().text("").textColor(.white).font(12)
    //MARK: - 头部搜索
    func configHeaderView(v: UIView) {
        let backBtn = UIButton().image(#imageLiteral(resourceName: "scanCode_back"))
        let searchBtn = UIButton().backgroundColor(UIColor.hexColor("#DBF1E7")).cornerRadius(15.5).masksToBounds()
        let searchIcon = UIImageView().image(#imageLiteral(resourceName: "item_search"))
        let searchLabel = UILabel().text("搜索你想要的内容").textColor(.kColor99).font(12)
        
        let addressIV = UIImageView().image(#imageLiteral(resourceName: "home_icon_address"))
        v.sv(backBtn, searchBtn, addressLabel, addressIV)
        v.layout(
            43,
            |-0-backBtn.width(37).height(44)-21-searchBtn.height(31)-21-addressLabel.height(16.5)-4-addressIV.width(11).height(15)-14-|,
            3
        )
        searchBtn.sv(searchIcon, searchLabel)
        searchBtn.layout(
            8.5,
            |-15-searchIcon.size(15)-5-searchLabel,
            7.5
        )
        backBtn.tapped { [weak self] (tapBtn) in
            self?.navigationController?.popViewController()
        }
        searchBtn.tapped { [weak self] (btn) in
            let vc = DistSearchVC()
            vc.latitude = self?.latitude
            vc.longitude = self?.longitude
            self?.navigationController?.pushViewController(vc, animated: false)
        }
    }
    //
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "home_banner_dist")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "home_banner_dist")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    func configSection0(cell: UITableViewCell) {
        cell.sv(cycleScrollView)
        cell.layout(
            10,
            |-14-cycleScrollView.height(110)-14-|,
            5
        )
        cycleScrollView.delegate = self
    }
    
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
    }
    
    //MARK: - 菜单栏
    func configSection1(cell: UITableViewCell) {
        let icons = [#imageLiteral(resourceName: "home_dist_item_0"),#imageLiteral(resourceName: "home_dist_item_1"),#imageLiteral(resourceName: "home_dist_item_2"),#imageLiteral(resourceName: "home_dist_item_3"),#imageLiteral(resourceName: "home_dist_item_4"),#imageLiteral(resourceName: "home_dist_item_5"),#imageLiteral(resourceName: "home_dist_item_6"),#imageLiteral(resourceName: "home_dist_item_7"), #imageLiteral(resourceName: "home_dist_item_8"),#imageLiteral(resourceName: "home_dist_item_9")]
        let titles = ["厨房卫浴", "墙地面类", "电器", "灯具灯饰", "全屋定制", "装饰辅料", "家具家饰", "生活用品", "展厅物料", "全部"]
        titles.enumerated().forEach { (item) in
            let title = item.element
            let index = item.offset
            let icon = icons[index]
            let btnH: CGFloat = 68
            let btnW: CGFloat = view.width/5
            let offsetX: CGFloat = btnW * (CGFloat(index%5))
            let offsetY: CGFloat = 10 + btnH * (CGFloat(index/5))
            let btn = UIButton().image(icon).text(title).textColor(.kColor33).font(10)
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=20
            )
            btn.layoutButton(imageTitleSpace: -1)
            btn.tag = index
            btn.tapped { [weak self] (tapBtn) in
                let vc = DistDetailVC()
                vc.brandName = tapBtn.titleLabel?.text
                vc.latitude = self?.latitude
                vc.longitude = self?.longitude
                self?.navigationController?.pushViewController(vc)
            }
        }
    }
    
    
    func configSection2(cell: UITableViewCell) {
        let topIV = UIImageView().image(#imageLiteral(resourceName: "home_dist_rmdp"))
        let v = UIView().backgroundColor(UIColor.hexColor("#88C3AA"))
        cell.sv(topIV, v)
        cell.layout(
            5,
            |-14-topIV.height(60)-14-|,
            0,
            |-14-v.width(view.width-28)-14-|,
            20+PublicSize.kBottomOffset
        )
        if dataSource.count == 0 {
            let noDataBtn = UIButton()
            noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无数据～").textColor(.kColor66).font(14)
            v.sv(noDataBtn)
            v.layout(
                10,
                noDataBtn.width(200).height(300).centerHorizontally(),
                10
            )
            noDataBtn.layoutButton(imageTitleSpace: 20)
        } else {
            dataSource.enumerated().forEach { (item) in
                let index = item.offset
                let model = item.element
                
                let btn = UIButton().backgroundImage(.white).cornerRadius(5).masksToBounds()
                let btnH: CGFloat = 97
                let offsetY: CGFloat = CGFloat(10 + 107*index)
                v.sv(btn)
                v.layout(
                    offsetY,
                    |-10-btn.height(btnH)-10-|,
                    >=10
                )
                
                let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
                icon.cornerRadius(3).masksToBounds()
                icon.contentMode = .scaleAspectFill
                if !icon.addImage(model.brandImg) {
                    icon.image(#imageLiteral(resourceName: "loading"))
                }
                
                let titleLabel = UILabel().text("\(model.brandName ?? "")").textColor(.kColor33).fontBold(14)
                let kmLabel = UILabel().text("\(model.distance ?? "0")km").textColor(.k2FD4A7).font(10)
                let distLabel = UILabel().text("服务区域：\(model.serviceRegion ?? "无")").textColor(.kColor99).font(12)
                let addressIV = UIImageView().image(#imageLiteral(resourceName: "home_dist_address"))
                let addressLabel = UILabel().text("\(model.merchantAddress ?? "暂无")").textColor(.kColor99).font(10)
                let seeBtn = UIButton().text("查看").textColor(.white).font(12)
                btn.sv(icon, titleLabel, kmLabel, distLabel, addressIV, addressLabel, seeBtn)
                btn.layout(
                    9,
                    |-9-icon.width(97).height(79),
                    9
                )
                btn.layout(
                    9,
                    |-115-titleLabel.height(20)-(>=0)-kmLabel-10-|,
                    6,
                    |-115-distLabel.height(16.5),
                    22.5,
                    |-115-addressIV.width(10).height(14)-2-addressLabel-10-|,
                    9
                )
                seeBtn.centerVertically()-10-|
                seeBtn.width(50).height(24).corner(radii: 4).fillGreenColorLF()
                seeBtn.tapped { [weak self] (tapBtn) in
                    let vc = DistBrandDetailVC()
                    vc.latitude = self?.latitude
                    vc.longitude = self?.longitude
                    vc.brandId = model.id
                    self?.navigationController?.pushViewController(vc)
                }
            }
        }
        
//        v.width(view.width-28)
//        v.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 10)
        
    }
    
    func fillVipBtnColor(btn: UIButton) {
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.95, green: 0.77, blue: 0.43, alpha: 1).cgColor, UIColor(red: 1, green: 0.88, blue: 0.6, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = btn.bounds
        bgGradient.startPoint = CGPoint(x: 0.52, y: 1)
        bgGradient.endPoint = CGPoint(x: 0.49, y: 0)
        btn.layer.insertSublayer(bgGradient, at: 0)
    }
    
}



extension DistHomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.clear)
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            configSection0(cell: cell)
        case 1:
            configSection1(cell: cell)
        case 2:
            configSection2(cell: cell)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.01
        default:
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return UIView()
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


class DistProductionModel : NSObject, Mappable{
    var imageUrl: String?
    var brandImg : String?
    var brandManageQualifi : String?
    var brandName : String?
    var brandNames : String?
    var brandProtection : String?
    var brandType : String?
    var brandTypeName : String?
    var categoryaId : String?
    var checkStatus : String?
    var citySubstation : String?
    var content : String?
    var createTime : String?
    var delFlag : String?
    var distance : String?
    var distanceMax : String?
    var distanceMin : String?
    var groupName : String?
    var id : String?
    var isFz : String?
    var isStatistics : String?
    var latitude : String?
    var longitude : String?
    var materialsCount : Int?
    var merchantAddress : String?
    var merchantId : String?
    var merchantName : String?
    var merchantType : String?
    var pariseSort : String?
    var praise : String?
    var productMerchant : String?
    var productNum : Int?
    var productNumMax : String?
    var productNumMin : String?
    var productProtection : String?
    var remarks : String?
    var serviceRegion : String?
    var sortNo : Int?
    var substationId : String?
    var updateTime : String?
    var upperStatus : String?
    var url : String?

    required init?(map: Map){}
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        imageUrl <- map["imageUrl"]
        brandImg <- map["brandImg"]
        brandManageQualifi <- map["brandManageQualifi"]
        brandName <- map["brandName"]
        brandNames <- map["brandNames"]
        brandProtection <- map["brandProtection"]
        brandType <- map["brandType"]
        brandTypeName <- map["brandTypeName"]
        categoryaId <- map["categoryaId"]
        checkStatus <- map["checkStatus"]
        citySubstation <- map["citySubstation"]
        content <- map["content"]
        createTime <- map["createTime"]
        delFlag <- map["delFlag"]
        distance <- map["distance"]
        distanceMax <- map["distanceMax"]
        distanceMin <- map["distanceMin"]
        groupName <- map["groupName"]
        id <- map["id"]
        isFz <- map["isFz"]
        isStatistics <- map["isStatistics"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        materialsCount <- map["materialsCount"]
        merchantAddress <- map["merchantAddress"]
        merchantId <- map["merchantId"]
        merchantName <- map["merchantName"]
        merchantType <- map["merchantType"]
        pariseSort <- map["pariseSort"]
        praise <- map["praise"]
        productMerchant <- map["productMerchant"]
        productNum <- map["productNum"]
        productNumMax <- map["productNumMax"]
        productNumMin <- map["productNumMin"]
        productProtection <- map["productProtection"]
        remarks <- map["remarks"]
        serviceRegion <- map["serviceRegion"]
        sortNo <- map["sortNo"]
        substationId <- map["substationId"]
        updateTime <- map["updateTime"]
        upperStatus <- map["upperStatus"]
        url <- map["url"]
        
    }

}
