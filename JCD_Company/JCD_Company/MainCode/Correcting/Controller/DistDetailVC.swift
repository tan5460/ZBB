//
//  DistDetailVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/7.
//

import UIKit
import ObjectMapper
import TLTransitions

class DistDetailVC: BaseViewController {
    var categoryId: String?
    var brandName: String?
    private var lowPrice: Int? // 最低价
    private var heightPrice: Int? // 最高价
    private var brandModel: HoBrandModel?
    private var baseBrandModel: HoBrandModel?
    private var sortType = 1
    var sjsFlag = false
    var searchName: String?
    
    
    private var currentKMIndex: Int?
    private var currentFWIndexs = [Int]()
    private var currentNumIndex: Int?
    
    private var distanceMin: Int?
    private var distanceMax: Int?
    private var productNumMin: Int?
    private var productNumMax: Int?
    
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
        view.backgroundColor(.white)
        selectCategory(brandName: brandName ?? "")
        configNav()
        configCollectionView()
        configSelectViews()
        configZHPopView()
    }
    
    
    //MARK: - 返回搜索
    func configNav() {
        let backBtn = UIButton().image(#imageLiteral(resourceName: "detail_back"))
        if searchName == nil {
            let searchBtn = UIButton().backgroundColor(UIColor.hexColor("#F0F0F0")).cornerRadius(16).masksToBounds()
            let searchIcon = UIImageView().image(#imageLiteral(resourceName: "icon_searchBar"))
            let searchTitle = UILabel().text("请输入品牌名或产品名称").textColor(.kColor99).font(14)
            view.sv(backBtn, searchBtn)
            view.layout(
                PublicSize.kStatusBarHeight,
                |-0-backBtn.size(44)-7.5-searchBtn.height(32)-51.5-|,
                >=0
            )
            searchBtn.sv(searchIcon, searchTitle)
            searchBtn.layout(
                8.5,
                |-15-searchIcon.size(15)-2.5-searchTitle,
                8.5
            )
            searchBtn.tapped { [weak self] (btn) in
                self?.toSearchVC()
            }
        } else {
            let titleLabel = UILabel().text("搜索：\(searchName ?? "")").textColor(.kColor33).fontBold(18)
            view.sv(backBtn, titleLabel)
            view.layout(
                PublicSize.kStatusBarHeight,
                |-0-backBtn.size(44)-(>=0)-titleLabel.centerHorizontally(),
                >=0
            )
        }
        backBtn.tapped { [weak self] (btn) in
            self?.navigationController?.popViewController()
        }
        
    }
    
    func toSearchVC() {
        let vc = CurrencySearchController()
        if sjsFlag {
            vc.searchString = searchName
            vc.sjsFlag = sjsFlag
        } else {
            vc.searchType = .newMaterial
            vc.categoryId = categoryId
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    //MARK: - 筛选按钮
    private var flBtn = UIButton().backgroundColor(.white) // 分类按钮
    private var kbBtn = UIButton().backgroundColor(.white) // 口碑按钮
    private var sxBtn = UIButton().backgroundColor(.white) // 筛选按钮
    func configSelectViews() {
        let lineView = UIView().backgroundColor(.kColorEE)
        view.sv(lineView, flBtn, kbBtn, sxBtn)
        view.layout(
            PublicSize.kNavBarHeight,
            |lineView.height(0.5)|,
            |-0-flBtn.height(37)-0-kbBtn-0-sxBtn-0-|,
            >=0
        )
        equal(sizes: flBtn, kbBtn, sxBtn)
        configZHBtn()
        configKBBtn()
        configSXBtn()
    }
    //MARK: - 综合按钮
    private var zhTitleLabel = UILabel().text("全部类目").textColor(.kColor33).font(12)
    private var zhIcon = UIImageView().image(#imageLiteral(resourceName: "store_zh_arrow_0"))
    func configZHBtn() {
        if brandName != nil {
            zhTitleLabel.text(brandName ?? "")
        }
        let zhView = UIView()
        flBtn.sv(zhView)
        zhView.centerInContainer()
        zhView.sv(zhTitleLabel, zhIcon)
        zhView.layout(
            0,
            |-0-zhTitleLabel.height(16.5)-4-zhIcon.width(6).height(3)-0-|,
            0
        )
        zhView.isUserInteractionEnabled = false
        flBtn.tapped { [weak self] (btn) in
            self?.zhPopView.isHidden = false
            self?.refreshZHPopView()
        }
    }
    private var zhPopView = UIView()  // 点击综合按钮弹出视图
    private var zhPopBtns = [UIButton]()
    private var zhPopIndex: Int? = 0
    func configZHPopView() {
        view.sv(zhPopView)
        view.layout(
            0,
            |zhPopView|,
            0
        )
        zhPopView.isHidden = true // 第一次进来默认隐藏
        let topView = UIView().backgroundColor(.clear)
        let zhPop = UIView().backgroundColor(.white)
        let bottomView = UIView().backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        zhPopView.sv(topView, zhPop, bottomView)
        zhPopView.layout(
            0,
            |topView.height(PublicSize.kNavBarHeight+37)|,
            0,
            |zhPop.height(175)|,
            0,
            |bottomView|,
            0
        )
        let zhScrollView = UIScrollView()
        zhPop.sv(zhScrollView)
        zhPop.layout(
            0,
            |zhScrollView|,
            10
        )
        zhPopView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissZHPopView)))
        
        ["全部类目", "厨房卫浴", "墙地面类", "电器", "灯具灯饰", "装饰辅料", "家具家饰", "生活用品", "展厅物料"].enumerated().forEach { (item) in
            let index = item.offset
            let element = item.element
            let btnW: CGFloat = CGFloat((view.width-90)/3)
            let btnH: CGFloat = 30
            let btn = UIButton().text(element).textColor(.k2FD4A7).font(12).borderWidth(0.5).borderColor(.k2FD4A7).cornerRadius(15).masksToBounds().backgroundColor(.kF2FFFB)
            let offsetX: CGFloat = 14 + (btnW + 31) * CGFloat(index % 3)
            let offsetY: CGFloat = 10 + (btnH + 10) * CGFloat(index / 3)
            zhScrollView.sv(btn)
            zhScrollView.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=10
            )
            btn.tag = index
            
            if brandName == element {
                zhPopIndex = index
                btn.textColor(.k2FD4A7).backgroundColor(.kF2FFFB).borderColor(.k2FD4A7)
                selectCategory(brandName: element)
            } else {
                btn.textColor(.kColor33).backgroundColor(.kF7F7F7).borderColor(.kF7F7F7)
            }
            
            zhPopBtns.append(btn)
            btn.tapped { [weak self] (btn1) in
                self?.selectCategory(brandName: element)
                self?.resetSortViews(false)
                self?.zhPopIndex = index
                self?.zhTitleLabel.text(element).textColor(UIColor.hexColor("2FD4A7"))
                self?.zhIcon.image(#imageLiteral(resourceName: "store_zh_arrow_1"))
                self?.dismissZHPopView()
                
                self?.current = 1
                self?.loadData()
            }
        }
        refreshZHPopView()
    }
    
    
    func selectCategory(brandName: String) {
        switch brandName {
        case "全部类目":
            self.categoryId = nil
        case "厨房卫浴":
            self.categoryId = "80942a00c5ae4ca087fc599007428419"
        case "墙地面类":
            self.categoryId = "b1d583e8cc5c4ca5875e5b7b2358ff9d"
        case "电器":
            self.categoryId = "4a71ee0953ee45c1b4fd657a290e9785"
        case "灯具灯饰":
            self.categoryId = "968caf46346446d3a746318fb7808436"
        case "全屋定制":
            self.categoryId = "db5ba32fc01b4e54b2b4a27e6a432f77"
        case "装饰辅料":
            self.categoryId = "a8fbc5cf077b4083ad08643dd26d5946"
        case "家具家饰":
            self.categoryId = "ff7fc76bdfe843659ba5f83e9108824d"
        case "生活用品":
            self.categoryId = "becb1633cc3d0a1e61c944df0ea27265"
        case "展厅物料":
            self.categoryId = "1155696493ed21916cba11669a707a40"
        default:
            break
        }
    }
    
    private func refreshZHPopView() {
        zhPopBtns.forEach { (btn) in
            if btn.tag == zhPopIndex {
                btn.textColor(.k2FD4A7).backgroundColor(.kF2FFFB).borderColor(.k2FD4A7)
            } else {
                btn.textColor(.kColor33).backgroundColor(.kF7F7F7).borderColor(.kF7F7F7)
            }
        }
    }
    
    @objc func dismissZHPopView() {
        zhPopView.isHidden = true
    }
    
    
    //MARK: - 口碑排行按钮
    private var kbTitleLabel = UILabel().text("口碑排序").textColor(.kColor33).font(12)
    private var kbIcon = UIImageView().image(#imageLiteral(resourceName: "store_zh_arrow_0"))
    func configKBBtn() {
        let zhView = UIView()
        kbBtn.sv(zhView)
        zhView.centerInContainer()
        zhView.sv(kbTitleLabel, kbIcon)
        zhView.layout(
            0,
            |-0-kbTitleLabel.height(16.5)-4-kbIcon.width(6).height(3)-0-|,
            0
        )
        zhView.isUserInteractionEnabled = false
        configKBPopView()
        kbBtn.tapped { [weak self] (btn) in
            self?.kbPopView.isHidden = false
            self?.refreshKBPopView()
            
        }
    }
    private var kbPopView = UIView()  // 点击综合按钮弹出视图
    private var kbPopBtns = [UIButton]()
    private var kbPopIndex: Int?
    func configKBPopView() {
        view.sv(kbPopView)
        view.layout(
            0,
            |kbPopView|,
            0
        )
        self.kbPopView.isHidden = true
        let topView = UIView().backgroundColor(.clear)
        let zhPop = UIView().backgroundColor(.white)
        let bottomView = UIView().backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        kbPopView.sv(topView, zhPop, bottomView)
        kbPopView.layout(
            0,
            |topView.height(PublicSize.kNavBarHeight+37)|,
            0,
            |zhPop.height(127.5)|,
            0,
            |bottomView|,
            0
        )
        kbPopView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissKBPopView)))
        
        
        ["口碑排序", "销量最高", "距离最近"].enumerated().forEach { (item) in
            let index = item.offset
            let element = item.element
            let btn = UIButton()
            let offsetY: CGFloat = 42.5 * CGFloat(index)
            let line = UIView().backgroundColor(.kColor220)
            zhPop.sv(btn, line)
            zhPop.layout(
                offsetY,
                |-0-btn.height(42.5)-0-|,
                0,
                |-14-line.height(0.5)-14-|,
                >=0
            )
            let titleLabel = UILabel().text(element).textColor(UIColor.hexColor("#2FD4A7")).font(12)
            let arrowIcon = UIImageView().image(#imageLiteral(resourceName: "store_select_arrow"))
            titleLabel.tag = 10000
            arrowIcon.tag = 10001
            btn.sv(titleLabel, arrowIcon)
            btn.layout(
                13,
                |-14-titleLabel.height(16.5)-(>=0)-arrowIcon.width(16).height(10)-14-|,
                13.5
            )
            btn.tag = index
            kbPopBtns.append(btn)
            btn.tapped { [weak self] (btn1) in
                self?.resetSortViews(false)
                self?.kbPopIndex = index
                self?.kbTitleLabel.text(element).textColor(UIColor.hexColor("2FD4A7"))
                self?.kbIcon.image(#imageLiteral(resourceName: "store_zh_arrow_1"))
                self?.dismissKBPopView()
                self?.current = 1
                self?.loadData()
            }
        }
        refreshKBPopView()
    }
    
    private func refreshKBPopView() {
        kbPopBtns.forEach { (btn) in
            let titleLabel = btn.viewWithTag(10000) as? UILabel
            let arrowIcon = btn.viewWithTag(10001) as? UIImageView
            if btn.tag == kbPopIndex {
                titleLabel?.textColor(UIColor.hexColor("#2FD4A7"))
                arrowIcon?.isHidden = false
            } else {
                titleLabel?.textColor(.kColor33)
                arrowIcon?.isHidden = true
            }
        }
    }
    
    @objc func dismissKBPopView() {
        kbPopView.isHidden = true
    }
    //MARK: - 重置综合销量价格排序状态
    private func resetSortViews(_ isJG: Bool) {
        zhTitleLabel.textColor(.kColor33)
        zhIcon.image(#imageLiteral(resourceName: "store_zh_arrow_0"))
        
        kbTitleLabel.textColor(.kColor66)
        kbIcon.image(#imageLiteral(resourceName: "store_zh_arrow_0"))
        
        sxTitleLabel.textColor(.kColor66)
        sxIcon.image(#imageLiteral(resourceName: "store_sx_arrow_0"))
    }
    
    //MARK: - 筛选按钮
    private var sxTitleLabel = UILabel().text("筛选").textColor(UIColor.hexColor("#333333")).font(12)
    private var sxIcon = UIImageView().image(#imageLiteral(resourceName: "store_sx_arrow_0"))
    func configSXBtn() {
        let sxView = UIView()
        sxBtn.sv(sxView)
        sxView.isUserInteractionEnabled = false
        sxView.centerInContainer()
        sxView.sv(sxTitleLabel, sxIcon)
        sxView.layout(
            0,
            |-0-sxTitleLabel.height(16.5)-2-sxIcon.width(10).height(10)-0-|,
            0
        )
        sxBtn.tapped { [weak self] (btn) in
            self?.showSXPopBGView()
        }
        configSXPopBGView()
    }
    private var sxPopBGView = UIView()
    private var sxPopView = UIView().backgroundColor(.white)
    private func configSXPopBGView() {
        sxPopBGView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        view.addSubview(sxPopBGView)
        
        let topView = UIView().backgroundColor(.clear)
        
        
        let bottomView = UIView().backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        sxPopBGView.sv(topView, sxPopView, bottomView)
        sxPopBGView.layout(
            0,
            |topView.height(PublicSize.kNavBarHeight+37)|,
            0,
            |sxPopView.height(367)|,
            0,
            |bottomView|,
            0
        )
        sxPopBGView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissSXPopBGView)))
        configSXPopView()
        sxPopBGView.isHidden = true
    }
    
    func showSXPopBGView() {
        sxPopBGView.isHidden = false
    }
    
    @objc func dismissSXPopBGView() {
        resetSortViews(false)
        sxPopBGView.isHidden = true
        var isChange = false
        if currentKMIndex != nil {
            isChange = true
        }
        if currentNumIndex != nil {
            isChange = true
        }
        if currentFWIndexs.count > 0 {
            isChange = true
        }
        if isChange {
            sxTitleLabel.textColor(.k2FD4A7)
            sxIcon.image(#imageLiteral(resourceName: "store_sx_arrow_1"))
        } else {
            sxTitleLabel.textColor(.kColor66)
            sxIcon.image(#imageLiteral(resourceName: "store_sx_arrow_0"))
        }
        
    }
    //MARK: - 配置筛选
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.white)
    @objc func configSXPopView() {
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
        let btnBGView = UIView().borderColor(UIColor.hexColor("#1DC597")).borderWidth(0.5)
        let sxResetBtn = UIButton().text("重置").textColor(UIColor.hexColor("#1DC597")).font(12).backgroundColor(.white)
        
        let sxSureBtn = UIButton().text("完成").textColor(.white).font(12).backgroundColor(UIColor.hexColor("#1DC597"))
        
        sxPopView.sv(tableView, btnBGView)
        sxPopView.layout(
            0,
            |tableView|,
            10,
            |btnBGView.height(40)|,
            0
        )
        btnBGView.sv(sxResetBtn, sxSureBtn)
        btnBGView.layout(
            0,
            |-0-sxResetBtn-0-sxSureBtn-0-|,
            0
        )
        equal(sizes: sxResetBtn, sxSureBtn)
        
        sxResetBtn.tapped { [weak self] (btn) in
            self?.distanceMin = nil
            self?.distanceMax = nil
            self?.productNumMin = nil
            self?.productNumMax = nil
            self?.currentKMIndex = nil
            self?.currentNumIndex = nil
            self?.currentFWIndexs.removeAll()
            self?.tableView.reloadData()
        }
        
        sxSureBtn.tapped { [weak self] (btn) in
            self?.dismissSXPopBGView()
            self?.current = 1
            self?.loadData()
        }
    }
    
    
    //MARK: - collectionView
    private var current = 1
    private var size = 10
    private var collectionView: UICollectionView!
    private var noDataBtn = UIButton()
    private var dataSource: [DistProductionModel] = []
    func configCollectionView() {
        let layout = UICollectionViewFlowLayout.init()
        let w: CGFloat = view.width-28
        layout.itemSize = CGSize(width: w, height: 103)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 20, right: 14)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout).backgroundColor(.kBackgroundColor)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: DistDetailCell.self)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.sv(collectionView)
        view.layout(
            PublicSize.kNavBarHeight+37,
            |collectionView|,
            0
        )
        collectionView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        collectionView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无数据～").textColor(.kColor66).font(14)
        collectionView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
        loadData()
    }
    
    var latitude: String?  // 经度
    var longitude: String? // 纬度
    func loadData() {
        var parameters = Parameters()
        parameters["latitude"] = latitude
        parameters["longitude"] = longitude
        parameters["current"] = current
        parameters["size"] = size
        parameters["categoryaId"] = categoryId
        parameters["distanceMin"] = distanceMin
        parameters["distanceMax"] = distanceMax
        parameters["productNumMin"] = productNumMin
        parameters["productNumMax"] = productNumMax
        
        var brandProtection = ""
        currentFWIndexs.forEach { (fwIndex) in
            if !brandProtection.isEmpty {
                brandProtection.append(",")
            }
            let fwValue = AppData.brandProtectionList[fwIndex]["value"] as? String
            brandProtection.append(fwValue ?? "")
        }
        if !brandProtection.isEmpty {
            parameters["brandProtection"] = brandProtection
        }
        
        if kbPopIndex == 0 {
            parameters["brandSort"] = "3"
        } else if kbPopIndex == 1 {
            parameters["brandSort"] = "2"
        } else if kbPopIndex  == 2 {
            parameters["brandSort"] = "1"
        }
        
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
                    self.collectionView.endFooterRefresh()
                } else {
                    self.collectionView.endFooterRefreshNoMoreData()
                }
                self.noDataBtn.isHidden = self.dataSource.count > 0
                self.collectionView.endHeaderRefresh()
                self.collectionView.reloadData()
            }
        }) { (error) in
            self.collectionView.endHeaderRefresh()
            self.collectionView.endFooterRefresh()
        }
    }
}


extension DistDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: DistDetailCell.self
                                                      , for: indexPath)
        cell.latitude = latitude
        cell.longitude = longitude
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    
        
//        let vc = MaterialsDetailVC()
//        let materialModel = MaterialsModel()
//        materialModel.id = dataSource[indexPath.row].id
//        vc.materialsModel = materialModel
//        navigationController?.pushViewController(vc)
    }
}

class DistDetailCell: UICollectionViewCell {
    
    var model: DistProductionModel? {
        didSet {
            configCell()
        }
    }
    var latitude: String?  // 经度
    var longitude: String? // 纬度
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
    private let titleLabel = UILabel().text("南宇装饰").textColor(.kColor33).fontBold(14)
    private let kmLabel = UILabel().text("1.5km").textColor(.k2FD4A7).font(10)
    private let distLabel = UILabel().text("服务区域：长沙").textColor(.kColor99).font(12)
    private let addressIV = UIImageView().image(#imageLiteral(resourceName: "home_dist_address"))
    private let addressLabel = UILabel().text("湖南省长沙市岳麓区岳麓大道与东方湖南...").textColor(.kColor99).font(10)
    private let seeBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(.white).cornerRadius(5).addShadowColor()
        
        sv(icon, titleLabel, kmLabel, distLabel, addressIV, addressLabel, seeBtn)
        layout(
            9,
            |-9-icon.width(103).height(83),
            9
        )
        layout(
            10,
            |-123-titleLabel.height(20)-(>=0)-kmLabel-10-|,
            6,
            |-123-distLabel.height(16.5),
            26.5,
            |-123-addressIV.width(10).height(14)-2-addressLabel-10-|,
            10
        )
        icon.cornerRadius(3).masksToBounds()
        icon.contentMode = .scaleAspectFill
        seeBtn.width(50).height(24).centerVertically()-10-|
        seeBtn.width(50).height(24).corner(radii: 4).fillGreenColorLF()
        
        let seeLabel = UILabel().text("查看").textColor(.white).font(12)
        seeBtn.sv(seeLabel)
        seeLabel.centerInContainer()
    }
    
    func configCell() {
        if !icon.addImage(model?.brandImg) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        titleLabel.text("\(model?.brandName ?? "")")
        kmLabel.text("\(model?.distance ?? "")km")
        distLabel.text("服务区域：\(model?.serviceRegion ?? "无")")
        addressLabel.text("\(model?.merchantAddress ?? "暂无")")
        seeBtn.tapped { [weak self] (tapBtn) in
            let vc = DistBrandDetailVC()
            vc.latitude = self?.latitude
            vc.longitude = self?.longitude
            vc.brandId = self?.model?.id
            self?.parentController?.navigationController?.pushViewController(vc)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 筛选侧边栏 tableview
extension DistDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            configSection0(cell: cell, indexPath: indexPath)
        case 1:
            configSection1(cell: cell, indexPath: indexPath)
        default:
            configSection2(cell: cell, indexPath: indexPath)
            break
        }
        return cell
    }
    
    func configSection0(cell: UITableViewCell, indexPath: IndexPath) {
        let titleLabel = UILabel().text("店铺距离").textColor(.kColor66).fontBold(10)
        cell.sv(titleLabel)
        cell.layout(
            10,
            |-14-titleLabel.height(14),
            >=10.5
        )
        ["1km以内", "1-5km", "5-10km" , "10-20km", "20-30km", "30km以上"].enumerated().forEach { (item) in
            let index = item.offset
            let attModel = item.element
            let btnW: CGFloat = CGFloat(view.width-90)/3
            let btnH: CGFloat = 30
            let offsetY: CGFloat = 34 + CGFloat(40 * (index/3))
            let offsetX: CGFloat = 14 + CGFloat(btnW+31) * CGFloat(index%3)
            let btn = UIButton().text(attModel).textColor(.kColor33).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            if currentKMIndex == index {
                btn.textColor(.k2FD4A7).borderColor(.k2FD4A7).borderWidth(0.5).backgroundColor(.kF2FFFB)
            } else {
                btn.textColor(.kColor33).borderColor(.kF7F7F7).borderWidth(0.5).backgroundColor(.kF7F7F7)
            }
            btn.tag = index
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=0
            )
            btn.tapped { [weak self] (btn1) in
                if self?.currentKMIndex == index {
                    self?.currentKMIndex = nil
                } else {
                    self?.currentKMIndex = index
                }
                self?.configDistance()
                self?.tableView.reloadData()
            }
        }
    }
    
    func configDistance() {
        switch currentKMIndex {
        case 0:
            distanceMax = 1
        case 1:
            distanceMin = 1
            distanceMax = 5
        case 2:
            distanceMin = 5
            distanceMax = 10
        case 3:
            distanceMin = 10
            distanceMax = 20
        case 4:
            distanceMin = 20
            distanceMax = 30
        case 5:
            distanceMin = 30
            distanceMax = nil
        default:
            distanceMin = nil
            distanceMax = nil
        }
    }
    
    
    
    
    func configSection1(cell: UITableViewCell, indexPath: IndexPath) {
        let titleLabel = UILabel().text("产品数量").textColor(.kColor66).fontBold(10)
        cell.sv(titleLabel)
        cell.layout(
            10,
            |-14-titleLabel.height(14),
            >=10.5
        )
        ["0-10款", "10-20款", "20-30款", "30款以上"].enumerated().forEach { (item) in
            let index = item.offset
            let attModel = item.element
            let btnW: CGFloat = CGFloat(view.width-90)/3
            let btnH: CGFloat = 30
            let offsetY: CGFloat = 34 + CGFloat(40 * (index/3))
            let offsetX: CGFloat = 14 + CGFloat(btnW+31) * CGFloat(index%3)
            let btn = UIButton().text(attModel).textColor(.kColor33).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            if index == currentNumIndex {
                btn.textColor(.k2FD4A7).borderColor(.k2FD4A7).borderWidth(0.5).backgroundColor(.kF2FFFB)
            } else {
                btn.textColor(.kColor33).borderColor(.kF7F7F7).borderWidth(0.5).backgroundColor(.kF7F7F7)
            }
            btn.tag = index
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=0
            )
            btn.tapped { [weak self] (btn1) in
                if self?.currentNumIndex == index {
                    self?.currentNumIndex = nil
                } else {
                    self?.currentNumIndex = index
                }
                self?.configProductNum()
                self?.tableView.reloadData()
            }
        }
    }
    
    func configSection2(cell: UITableViewCell, indexPath: IndexPath) {
        let titleLabel = UILabel().text("产品服务").textColor(.kColor66).fontBold(10)
        cell.sv(titleLabel)
        cell.layout(
            10,
            |-14-titleLabel.height(14),
            >=10.5
        )
        AppData.brandProtectionList.enumerated().forEach { (item) in
            let index = item.offset
            let attModel = item.element
            let btnW: CGFloat = CGFloat(view.width-90)/3
            let btnH: CGFloat = 30
            let offsetY: CGFloat = 34 + CGFloat(40 * (index/3))
            let offsetX: CGFloat = 14 + CGFloat(btnW+31) * CGFloat(index%3)
            let label = attModel["label"] as? String
            let btn = UIButton().text(label ?? "").textColor(.kColor33).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            btn.textColor(.kColor33).borderColor(.kF7F7F7).borderWidth(0.5).backgroundColor(.kF7F7F7)
            
            currentFWIndexs.enumerated().forEach({ (fwIndex) in
                if fwIndex.element == index {
                    btn.textColor(.k2FD4A7).borderColor(.k2FD4A7).borderWidth(0.5).backgroundColor(.kF2FFFB)
                }
            })
            btn.tag = index
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=0
            )
            btn.tapped { [weak self] (btn1) in
                if self?.currentFWIndexs.contains(index) ?? false {
                    self?.currentFWIndexs.removeAll(index)
                } else {
                    self?.currentFWIndexs.append(index)
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func configProductNum() {
        switch currentNumIndex {
        case 0:
            productNumMin = 0
            productNumMax = 10
        case 1:
            productNumMin = 10
            productNumMax = 20
        case 2:
            productNumMin = 20
            productNumMax = 30
        case 3:
            productNumMax = nil
            productNumMin = 30
        default:
            productNumMin = nil
            productNumMax = nil
        }
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

extension DistDetailVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 10000 {
            lowPrice = textField.text?.toInt
        } else if textField.tag == 10001 {
            heightPrice = textField.text?.toInt
        }
    }
}
