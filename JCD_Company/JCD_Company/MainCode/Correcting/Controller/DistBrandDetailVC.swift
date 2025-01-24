//
//  DistBrandDetailVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/7.
//

import UIKit

import ObjectMapper
import TLTransitions

class DistBrandDetailVC: BaseViewController {
    var latitude: String?  // 经度
    var longitude: String? // 纬度
    var pop: TLTransition?
    var canLoadMsgCountSelf = false // 是否不通过通知刷新通知未读数量
    var brandId: String?
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
            topToolView.width(view.width).height(PublicSize.kNavBarHeight),
            0,
            |tableView|,
            0
        )
        configHeaderView(v: topToolView)
        tableView.refreshHeader { [weak self] in
            self?.loadData()
        }
        
        loadData()
    }
    
    
    private var brandDetailModel: DistBrandDetailModel?
    
    func loadData() {
        
        pleaseWait()
        var parameters = Parameters()
        parameters["brandId"] = brandId
        YZBSign.shared.request(APIURL.regionBrandProductPage, method: .get, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.brandDetailModel = Mapper<DistBrandDetailModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
                self.tableView.endHeaderRefresh()
            }
        } failure: { (error) in
            self.tableView.endHeaderRefresh()
        }

    }
    //MARK: - 头部搜索
    func configHeaderView(v: UIView) {
        let backBtn = UIButton().image(#imageLiteral(resourceName: "scanCode_back"))
        let titleLabel = UILabel().text("品牌详情").textColor(.white).fontBold(18)
        v.sv(backBtn, titleLabel)
        v.layout(
            PublicSize.kStatusBarHeight,
            |-0-backBtn.width(37).height(44)-(>=0)-titleLabel.centerHorizontally(),
            0
        )
        backBtn.tapped { [weak self] (tapBtn) in
            self?.navigationController?.popViewController()
        }
    }
    
    
    func configSection0(cell: UITableViewCell) {
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v.height(195)-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        let model = brandDetailModel?.brandDetail
        
        let titleLabel = UILabel().text("\(model?.brandName ?? "")").textColor(.kColor33).fontBold(16)
        let xzIcon = UIImageView().image(#imageLiteral(resourceName: "dist_icon_xz"))
        let xzLabel = UILabel().text("认证店铺").textColor(.kColor33).font(14)
        let xzArrow = UIImageView().image(#imageLiteral(resourceName: "purchase_arrow"))
        let line = UIView().backgroundColor(UIColor.hexColor("#C1F8E0"))
        let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
        icon.cornerRadius(3).masksToBounds()
        icon.contentMode = .scaleAspectFill
        if !icon.addImage(model?.brandImg) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        let kbLabel = UILabel().text("口碑：").textColor(.kColor33).font(12)
        
        icon.masksToBounds()
        icon.contentMode = .scaleAspectFill
        let distLabel = UILabel().text("服务区域：").textColor(.kColor33).font(12)
        let distLabel1 = UILabel().text("\(model?.serviceRegion ?? "")").textColor(.kColor33).font(12)
        
        let fwLabel = UILabel().text("产品服务：").textColor(.kColor33).font(12)
        let fwLabel1 = UILabel().text("暂无").textColor(.kColor33).font(12)
        if let brandProtection = brandDetailModel?.brandDetail?.brandProtection {
            let protectionArr = brandProtection.components(separatedBy: ",")
            var protectionStr = ""
            AppData.brandProtectionList.forEach { (dic) in
                let value = Utils.getReadString(dir: dic, field: "value")
                if protectionArr.contains(value) {
                    if protectionStr != "" {
                        protectionStr.append(",")
                    }
                    protectionStr.append(Utils.getReadString(dir: dic, field: "label"))
                }
            }
            fwLabel1.text(protectionStr)
        }
        
        let csLabel = UILabel().text("厂商：").textColor(.kColor33).font(12)
        let csLabel1 = UILabel().text("\(model?.productMerchant ?? "未知")").textColor(.kColor33).font(12)
        v.sv(titleLabel, xzIcon, xzLabel, xzArrow, line, icon, kbLabel, distLabel, distLabel1, fwLabel, fwLabel1, csLabel, csLabel1)
        v.layout(
            15,
            |-15-titleLabel.height(22.5)-(>=0)-xzIcon.size(18)-1-xzLabel-6-xzArrow.width(5).height(9)-15-|,
            15.5,
            |-15-line.height(0.5)-15-|,
            14,
            |-15-icon.width(140).height(113),
            15
        )
        v.layout(
            67,
            |-165-kbLabel.height(16.5),
            10,
            |-165-distLabel.height(16.5)-0-distLabel1-(>=15)-|,
            10,
            |-165-fwLabel.width(62).height(16.5),
            >=0,
            |-165-csLabel.height(16.5)-0-csLabel1-(>=15)-|,
            15.5
        )
        fwLabel1.numberOfLines(2).lineSpace(2)
        fwLabel1.Top == fwLabel.Top + 1
        fwLabel1.Left == fwLabel.Right
        fwLabel1-15-|
        
        [0, 0, 0, 1, 2].enumerated().forEach { (item) in
            let index = item.offset
            let starIV = UIImageView().image(#imageLiteral(resourceName: "dist_star_0"))
            let starW = 12
            let offsetX: CGFloat = 201 + CGFloat(starW+4)*CGFloat(index)
            v.sv(starIV)
            v.layout(
                68.5,
                |-offsetX-starIV.size(12),
                >=0
            )
            let praise = Double.init(string: brandDetailModel?.brandDetail?.praise ?? "0") ?? 0
            
            if (praise - Double(index)) < 0.5 {
                starIV.image(#imageLiteral(resourceName: "dist_star_2"))
            } else if (praise - Double(index)) < 1 {
                starIV.image(#imageLiteral(resourceName: "dist_star_1"))
            } else {
                starIV.image(#imageLiteral(resourceName: "dist_star_0"))
            }
//            if element == 0 {
//                starIV.image(#imageLiteral(resourceName: "dist_star_0"))
//            } else if element == 1 {
//                starIV.image(#imageLiteral(resourceName: "dist_star_1"))
//            } else {
//                starIV.image(#imageLiteral(resourceName: "dist_star_2"))
//            }
        }
        
        let desLabel = UILabel().text("地网产品").textColor(.white).font(10).backgroundColor(.black).textAligment(.center)
        icon.sv(desLabel)
        icon.layout(
            >=0,
            |-0-desLabel.width(55).height(20),
            0
        )
        desLabel.corner(byRoundingCorners: [.topRight, .bottomLeft], radii: 2)
        
        xzLabel.isUserInteractionEnabled = true
        xzLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(enterRZDPVC)))
    }
    //MARK: - 进入认证店铺
    @objc func enterRZDPVC() {
        let vc = DistStoreDetailVC()
        vc.brandId = brandId
        navigationController?.pushViewController(vc)
    }
    
    //MARK: - 菜单栏
    func configSection1(cell: UITableViewCell) {
        let model = brandDetailModel?.brandDetail
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v.height(50)-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        let mapIV = UIImageView().image(#imageLiteral(resourceName: "dist_icon_map"))
        let addressLabel = UILabel().text("\(model?.merchantAddress ?? "")").textColor(.kColor33).font(10)
        let navIV = UIImageView().image(#imageLiteral(resourceName: "dist_icon_dh"))
        v.sv(mapIV, addressLabel, navIV)
        v.layout(
            10,
            |-15-mapIV.size(30)-6-addressLabel.height(14)-(>=15)-navIV.size(24)-15-|,
            10
        )
    }
    
    
    
    //MARK: - VIP会员升级
    func configSection2(cell: UITableViewCell) {
        let materials = brandDetailModel?.productPage?.records
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        let titleLabel = UILabel().text("热门产品").textColor(.kColor33).fontBold(16)
        v.sv(titleLabel)
        v.layout(
            15,
            |-15-titleLabel.height(22.5),
            >=10
        )
        materials?.enumerated().forEach { (item) in
            let index = item.offset
            let model = item.element
            
            let btnW: CGFloat = CGFloat(view.width-69)/2
            let btnH: CGFloat = btnW + 78
            let btn = UIButton().cornerRadius(5).masksToBounds().borderColor(UIColor.hexColor("#AED4C9")).borderWidth(0.5)
            let offsetX: CGFloat = 15 + CGFloat(btnW+11) * CGFloat(index % 2)
            let offsetY: CGFloat = 48 + CGFloat(btnH + 10) * CGFloat(index / 2)
            v.sv(btn)
            v.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=10
            )
            let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
            icon.cornerRadius(3).masksToBounds()
            icon.contentMode = .scaleAspectFill
            if !icon.addImage(model.imageUrl) {
                icon.image(#imageLiteral(resourceName: "loading"))
            }
            
            
            let titleLab = UILabel().text("\(model.name ?? "")").textColor(.kColor33).fontBold(12)
            let priceLabel = UILabel().text("￥\(model.priceSupplyMin1?.doubleValue ?? 0)").textColor(.kDF2F2F).fontBold(14)
            let priceLabel1 = UILabel().text("/套").textColor(.kDF2F2F).fontBold(10)
            let addCarBtn = UIButton().image(#imageLiteral(resourceName: "home_car"))
            titleLabel.numberOfLines(0).lineSpace(2)
            btn.sv(icon, titleLab, priceLabel, priceLabel1, addCarBtn)
            btn.layout(
                0,
                |-0-icon.size(btnW)-0-|,
                6,
                |-6-titleLab-6-|,
                >=0,
                |-6-priceLabel.height(20)-(>=0)-addCarBtn.size(26)-6-|,
                13
            )
            priceLabel1.Left == priceLabel.Right
            priceLabel1.Bottom == priceLabel.Bottom - 3
            addCarBtn.isUserInteractionEnabled = false
//            addCarBtn.tapped { [weak self] (tapBtn) in
//                self?.noticeOnlyText("111")
//            }
            
            btn.tapped { [weak self] (tapBtn) in
                let vc = MaterialsDetailVC()
                let materialModel = MaterialsModel()
                materialModel.id = model.id
                vc.materialsModel = materialModel
                self?.navigationController?.pushViewController(vc)
            }
        }
    }
}



extension DistBrandDetailVC: UITableViewDelegate, UITableViewDataSource {
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
        if indexPath.section == 1 {
            let lat = Double.init(string: (brandDetailModel?.brandDetail?.latitude ?? "0")) ?? 0
            let long = Double.init(string: (brandDetailModel?.brandDetail?.longitude ?? "0")) ?? 0
            let name = brandDetailModel?.brandDetail?.merchantAddress ?? ""
            
            MapNavigation.showMapsAlert(self,
                                        targetLat: lat,
                                        targetLong: long,
                                        targetName: name)
        }
        
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
        if section == 2 {
            return PublicSize.kBottomOffset
        }
        return 0.01
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


class DistBrandDetailModel : NSObject, Mappable{

    var brandDetail : DistProductionModel?
    var productPage : ProductPageModel?

    required init?(map: Map){}
    private override init(){
        super.init()
    }
    func mapping(map: Map)
    {
        brandDetail <- map["brandDetail"]
        productPage <- map["productPage"]
        
    }
}


class ProductPageModel : NSObject, Mappable{

    var current : Int?
    var orders : [AnyObject]?
    var pages : Int?
    var records : [MaterialsModel]?
    var searchCount : Bool?
    var size : Int?
    var total : Int?
    
    required init?(map: Map){}
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        current <- map["current"]
        orders <- map["orders"]
        pages <- map["pages"]
        records <- map["records"]
        searchCount <- map["searchCount"]
        size <- map["size"]
        total <- map["total"]
        
    }
}


