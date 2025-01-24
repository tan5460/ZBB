//
//  StoreDetailVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2020/11/11.
//

import UIKit
import ObjectMapper
import TLTransitions

class StoreDetailVC: BaseViewController {
    var categoryId: String?
    private var lowPrice: Int? // 最低价
    private var heightPrice: Int? // 最高价
    private var brandModel: HoBrandModel?
    private var baseBrandModel: HoBrandModel?
    private var sortType = 1
    var sjsFlag = false
    var searchName: String?
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
        configNav()
        configCollectionView()
        configSelectViews()
        configZHPopView()
        requestBrands()
        requestAttrClassification()
    }
    
    //MARK: - 接口请求
    
    ///获取三级方类品牌
    func requestBrands() {
        let urlStr = APIURL.newSecondCategoryBrandList + (categoryId ?? "")
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<HoBrandModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.brandModel = HoBrandModel()
                self.brandModel?.attrDataValueList = modelArray
                self.tableView.reloadData()
            }
        }) { (error) in }
    }
    /// 获取筛选类型
    func requestAttrClassification() {
        let parameters = Parameters()
        let urlStr = APIURL.jcdAttrClassification + "\(categoryId ?? "")"
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                self.baseBrandModel = Mapper<HoBrandModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
            }
        } failure: { (error) in
            
        }

    }
    
    
    
    
    //MARK: - 返回搜索
    func configNav() {
        let backBtn = UIButton().image(#imageLiteral(resourceName: "detail_back"))
        if searchName == nil {
            let searchBtn = UIButton().backgroundColor(UIColor.hexColor("#F0F0F0")).cornerRadius(16).masksToBounds()
            let searchIcon = UIImageView().image(#imageLiteral(resourceName: "icon_searchBar"))
            let searchTitle = UILabel().text("输入产品名称搜索").textColor(.kColor99).font(14)
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
    private var zhBtn = UIButton().backgroundColor(.white) // 综合按钮
    private var xlBtn = UIButton().backgroundColor(.white) // 销量按钮
    private var jgBtn = UIButton().backgroundColor(.white) //  价格按钮
    private var sxBtn = UIButton().backgroundColor(.white) // 筛选按钮
    func configSelectViews() {
        let lineView = UIView().backgroundColor(.kColorEE)
        view.sv(lineView, zhBtn, xlBtn, jgBtn, sxBtn)
        view.layout(
            PublicSize.kNavBarHeight,
            |lineView.height(0.5)|,
            |-0-zhBtn.height(37)-0-xlBtn-0-jgBtn-0-sxBtn-0-|,
            >=0
        )
        equal(sizes: zhBtn, xlBtn, jgBtn, sxBtn)
        configZHBtn()
        configXLBtn()
        configJGBtn()
        configSXBtn()
    }
    //MARK: - 综合按钮
    private var zhTitleLabel = UILabel().text("综合").textColor(UIColor.hexColor("#2FD4A7")).font(12)
    private var zhIcon = UIImageView().image(#imageLiteral(resourceName: "store_zh_arrow_1"))
    func configZHBtn() {
        let zhView = UIView()
        zhBtn.sv(zhView)
        zhView.centerInContainer()
        zhView.sv(zhTitleLabel, zhIcon)
        zhView.layout(
            0,
            |-0-zhTitleLabel.height(16.5)-4-zhIcon.width(6).height(3)-0-|,
            0
        )
        zhView.isUserInteractionEnabled = false
        zhBtn.tapped { [weak self] (btn) in
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
            |zhPop.height(93)|,
            0,
            |bottomView|,
            0
        )
        zhPopView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissZHPopView)))
        
        
        ["综合", "新品"].enumerated().forEach { (item) in
            let index = item.offset
            let element = item.element
            let btn = UIButton()
            let offsetX: CGFloat = 46.5 * CGFloat(index)
            let line = UIView().backgroundColor(.kColor220)
            zhPop.sv(btn, line)
            zhPop.layout(
                offsetX,
                |-0-btn.height(46.5)-0-|,
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
                15,
                |-14-titleLabel.height(16.5)-(>=0)-arrowIcon.width(9).height(6)-14-|,
                15
            )
            btn.tag = index
            zhPopBtns.append(btn)
            btn.tapped { [weak self] (btn1) in
                self?.resetSortViews(false)
                self?.zhPopIndex = index
                if index == 0 {
                    self?.sortType = 1
                } else if index == 1 {
                    self?.sortType = 7
                }
                self?.zhTitleLabel.text(element).textColor(UIColor.hexColor("2FD4A7"))
                self?.zhIcon.image(#imageLiteral(resourceName: "store_zh_arrow_1"))
                self?.dismissZHPopView()
                self?.current = 1
                self?.loadData()
            }
        }
        refreshZHPopView()
    }
    
    private func refreshZHPopView() {
        zhPopBtns.forEach { (btn) in
            let titleLabel = btn.viewWithTag(10000) as? UILabel
            let arrowIcon = btn.viewWithTag(10001) as? UIImageView
            if btn.tag == zhPopIndex {
                titleLabel?.textColor(UIColor.hexColor("#2FD4A7"))
                arrowIcon?.isHidden = false
            } else {
                titleLabel?.textColor(.kColor66)
                arrowIcon?.isHidden = true
            }
        }
    }
    
    @objc func dismissZHPopView() {
        zhPopView.isHidden = true
    }
    
    //MARK: - 销量按钮
    private var xlTitleLabel = UILabel().text("销量").textColor(UIColor.hexColor("#333333")).font(12)
    func configXLBtn() {
        let xlView = UIView()
        xlBtn.sv(xlView)
        xlView.isUserInteractionEnabled = false
        xlView.centerInContainer()
        xlView.sv(xlTitleLabel)
        xlView.layout(
            0,
            |-0-xlTitleLabel.height(16.5)-0-|,
            0
        )
        xlBtn.tapped { [weak self] (btn) in
            self?.resetSortViews(false)
            self?.xlTitleLabel.textColor(UIColor.hexColor("#2FD4A7"))
            self?.sortType = 9
            self?.current = 1
            self?.loadData()
        }
    }
    
    //MARK: - 价格按钮
    private var jgTitleLabel = UILabel().text("价格").textColor(UIColor.hexColor("#333333")).font(12)
    private var jgIcon = UIImageView().image(#imageLiteral(resourceName: "store_jg_arrow_0"))
    private var jgSortIndex = 0
    func configJGBtn() {
        let jgView = UIView()
        jgBtn.sv(jgView)
        jgView.centerInContainer()
        jgView.sv(jgTitleLabel, jgIcon)
        jgView.layout(
            0,
            |-0-jgTitleLabel.height(16.5)-4-jgIcon.width(5).height(8)-0-|,
            0
        )
        jgView.isUserInteractionEnabled = false
        jgBtn.tapped { [weak self] (btn) in
            self?.resetSortViews(true)
            self?.jgTitleLabel.textColor(UIColor.hexColor("#2FD4A7"))
            if self?.jgSortIndex == 0 || self?.jgSortIndex == 2 {
                self?.jgSortIndex = 1
                self?.jgIcon.image(#imageLiteral(resourceName: "store_jg_arrow_1"))  // 降序
                if UserData.shared.userType == .jzgs {
                    self?.sortType = 5
                } else if UserData.shared.userType == .cgy {
                    self?.sortType = 3
                }
            } else if self?.jgSortIndex == 1 {
                self?.jgSortIndex = 2
                self?.jgIcon.image(#imageLiteral(resourceName: "store_jg_arrow_2"))  // 升序
                if UserData.shared.userType == .jzgs {
                    self?.sortType = 6
                } else if UserData.shared.userType == .cgy {
                    self?.sortType = 4
                }
            }
            self?.current = 1
            self?.loadData()
        }
    }
    //MARK: - 重置综合销量价格排序状态
    private func resetSortViews(_ isJG: Bool) {
        zhPopIndex = nil
        xlTitleLabel.textColor(.kColor66)
        zhTitleLabel.textColor(.kColor66)
        zhIcon.image(#imageLiteral(resourceName: "store_zh_arrow_0"))
        if !isJG {
            jgSortIndex = 0
        }
        jgTitleLabel.textColor(.kColor66)
        jgIcon.image(#imageLiteral(resourceName: "store_jg_arrow_0"))
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
    private var sxPopBGView = UIView().backgroundColor(UIColor.hexColor("#000000", alpha: 0.5))
    private var sxPopView = UIView().backgroundColor(.white)
    private func configSXPopBGView() {
        sxPopBGView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        view.addSubview(sxPopBGView)
        
        sxPopView.frame = CGRect(x: view.width, y: 0, width: 289, height: view.height)
        view.addSubview(sxPopView)
        
        sxPopBGView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissSXPopBGView)))
        configSXPopView()
        sxPopBGView.isHidden = true
        sxPopView.isHidden = true
    }
    
    func showSXPopBGView() {
        sxPopBGView.isHidden = false
        sxPopView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.sxPopView.frame.origin.x = self.view.width-289
        } completion: { (flag) in
            
        }
    }
    
    @objc func dismissSXPopBGView() {
        UIView.animate(withDuration: 0.3) {
            self.sxPopBGView.isHidden = true
            self.sxPopView.frame.origin.x = self.view.width
        } completion: { (flag) in
            self.sxPopView.isHidden = true
        }
        var isChange = false
        if lowPrice ?? -1 >= 0 || heightPrice ?? -1 >= 0 {
            isChange = true
        }
        brandModel?.attrDataValueList?.forEach({ (model) in
            if model.isCheckItem ?? false {
                isChange = true
            }
        })
        baseBrandModel?.attrDataList?.forEach({ (attrList) in
            attrList.attrDataValueList?.forEach({ (attr) in
                if attr.isCheckItem ?? false {
                    isChange = true
                }
            })
        })
        if isChange {
            sxTitleLabel.textColor(.k2FD4A7)
            sxIcon.image(#imageLiteral(resourceName: "store_sx_arrow_1"))
        } else {
            sxTitleLabel.textColor(.kColor66)
            sxIcon.image(#imageLiteral(resourceName: "store_sx_arrow_0"))
        }
        
    }
    //MARK: - 配置筛选侧边栏页面
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
        let btnBGView = UIView().borderColor(UIColor.hexColor("#CCCCCC")).borderWidth(0.5).cornerRadius(20).masksToBounds()
        let sxResetBtn = UIButton().text("重置").textColor(.kColor33).font(14).backgroundColor(.white)
        
        let sxSureBtn = UIButton().text("确认").textColor(.white).font(14).borderColor(UIColor.hexColor("#2FD4A7")).borderWidth(0.5).backgroundColor(UIColor.hexColor("#2FD4A7"))
        
        sxPopView.sv(tableView, btnBGView)
        sxPopView.layout(
            54,
            |tableView|,
            10,
            |-18-btnBGView.height(40)-14-|,
            50
        )
        btnBGView.sv(sxResetBtn, sxSureBtn)
        btnBGView.layout(
            0,
            |-0-sxResetBtn-0-sxSureBtn-0-|,
            0
        )
        equal(sizes: sxResetBtn, sxSureBtn)
        
        sxResetBtn.tapped { [weak self] (btn) in
            //self?.brandModel?.isShowMore = false
            self?.brandModel?.attrDataValueList?.forEach({ (att) in
                att.isCheckItem = false
            })
            self?.baseBrandModel?.attrDataList?.forEach({ (attrData) in
                //attrData.isShowMore = false
                attrData.attrDataValueList?.forEach({ (att) in
                    att.isCheckItem = false
                })
            })
            self?.tableView.reloadData()
        }
        
        sxSureBtn.tapped { [weak self] (btn) in
            if (self?.lowPrice != nil && self?.heightPrice != nil) && (self?.lowPrice ?? 0) > (self?.heightPrice ?? 0) {
                let temp = self?.heightPrice
                self?.heightPrice = self?.lowPrice
                self?.lowPrice = temp
            }
            self?.tableView.reloadData()
            self?.current = 1
            self?.loadData()
            self?.dismissSXPopBGView()
        }
    }
    
    
    //MARK: - collectionView
    private var current = 1
    private var size = 10
    private var collectionView: UICollectionView!
    private var noDataBtn = UIButton()
    private var dataSource: [MaterialsModel] = []
    func configCollectionView() {
        let layout = UICollectionViewFlowLayout.init()
        let w: CGFloat = (view.width-39)/2
        layout.itemSize = CGSize(width: w, height: 97+w)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 20, right: 14)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout).backgroundColor(.kBackgroundColor)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: StoreDetailCell.self)
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
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无产品～").textColor(.kColor66).font(14)
        collectionView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
        loadData()
    }
    
    func loadData() {
        var parameters: Parameters = [:]
        let urlStr = APIURL.getMaterials
        parameters["current"] = current
        parameters["size"] = size
        parameters["sortType"] = sortType
        parameters["categorycId"] = categoryId
        if UserData.shared.userType == .jzgs {
            parameters["priceSellMin"] = lowPrice
            parameters["priceSellMax"] = heightPrice
        }
        if UserData.shared.userType == .cgy {
            parameters["priceSupplyMin"] = lowPrice
            parameters["priceSupplyMax"] = heightPrice
        }
        var brandIds = "" // 品牌筛选
        brandModel?.attrDataValueList?.forEach({ (attr) in
            if attr.isCheckItem ?? false {
                if brandIds != ""  {
                    brandIds.append(",")
                }
                brandIds.append(attr.id ?? "")
            }
        })
        if brandIds != "" {
            parameters["brandIds"] = brandIds
        }
        
        // 搜索参数
        if let name = searchName {
            parameters["name"] = name
        }
        
        var attrDataStr = [[String: Any]]()
        baseBrandModel?.attrDataList?.forEach({ (dataList) in
            var dic = [String: Any]()
            dic["id"] = dataList.id
            var attrDataValueList = [[String: Any]]()
            dataList.attrDataValueList?.forEach({ (valueList) in
                var dic1 = [String: Any]()
                if valueList.isCheckItem ?? false {
                    dic1["id"] = valueList.id
                    attrDataValueList.append(dic1)
                }
            })
            if attrDataValueList.count > 0 {
                dic["attrDataValueList"] = attrDataValueList
                attrDataStr.append(dic)
            }
        })
        parameters["attrDataStr"] = attrDataStr.jsonStr
        if dataSource.count == 0 {
            UIApplication.shared.windows.first?.pleaseWait()
        }
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            self.collectionView.endHeaderRefresh()
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                var dataArray = [Any]()
                if UserData.shared.userType == .yys {
                    let dataDic1 = Utils.getReadDic(data: dataDic, field: "page")
                    dataArray = Utils.getReadArr(data: dataDic1, field: "records") as! [Any]
                } else {
                    dataArray = Utils.getReadArr(data: dataDic, field: "records") as! [Any]
                }
                
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current > 1 {
                    self.dataSource += modelArray
                }
                else {
                    self.dataSource = modelArray
                }
                
                if modelArray.count < self.size {
                    self.collectionView.endFooterRefreshNoMoreData()
                }else {
                    self.collectionView.endFooterRefresh()
                }
                
            }
            self.collectionView.reloadData()
            if self.dataSource.count <= 0 {
                self.noDataBtn.isHidden = false
            }else {
                self.noDataBtn.isHidden = true
            }
            
        }) { (error) in
            UIApplication.shared.windows.first?.clearAllNotice()
            self.collectionView.endHeaderRefresh()
            self.collectionView.endFooterRefresh()
            //结束刷新
            if self.dataSource.count <= 0 {
                self.noDataBtn.isHidden = false
            }else {
                self.noDataBtn.isHidden = true
            }
        }
    }
}


extension StoreDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: StoreDetailCell.self
                                                      , for: indexPath)
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = MaterialsDetailVC()
        let materialModel = MaterialsModel()
        materialModel.id = dataSource[indexPath.row].id
        vc.materialsModel = materialModel
        navigationController?.pushViewController(vc)
    }
}


class StoreDetailCell: UICollectionViewCell {
    private let zhgIcon = UIImageView().image(#imageLiteral(resourceName: "comBuy"))
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading")).backgroundColor(.kBackgroundColor)
    private let title = UILabel().text("简约而不简单，工薪阶层现代 风三居").textColor(.kColor33).fontBold(12).numberOfLines(2)
    private let brand = UILabel().text("品牌：美标").textColor(.kColor66).font(12)
    private let price = UILabel().text("￥1270.00").textColor(.kDF2F2F).fontBold(14)
    private let priceShow = UILabel().text("￥1370").textColor(.kColor99).font(10)
    private let desLabel = UILabel().text("销售价").textColor(.kColor99).font(10)
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(.white)
        cornerRadius(5)
        addShadowColor()
        sv(icon, title, price, brand, priceShow, desLabel)
        let iconW = (PublicSize.kScreenWidth-39)/2
        layout(
            0,
            |icon.size(iconW)|,
            5,
            |-6-title-6-|,
            6,
            |-6-brand.height(16.5)-6-|,
            6,
            |-6-price.height(20),
            9.5
        )
        layout(
            >=0,
            desLabel.height(14)-6-|,
            9.5
        )
        icon.sv(zhgIcon)
        icon.layout(
            10,
            zhgIcon.width(54.5).height(22)-10-|,
            >=0
        )
        zhgIcon.isHidden = true
        priceShow.Left == price.Right + 8
        priceShow.Bottom == price.Bottom
        priceShow.setLabelUnderline()
        icon.contentMode = .scaleAspectFit
        icon.masksToBounds()
    }
    
    func configCell() {
        zhgIcon.isHidden = model?.isOneSell != 2
        
        let imageUrl = model?.imageUrl
        let imageUrls = imageUrl?.components(separatedBy: ",")
        if !icon.addImage(imageUrls?.first) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        title.text(model?.name ?? "")
        brand.text("品牌：\(model?.brandName ?? "")")
        if UserData.shared.userType == .jzgs {
            price.text("\(model?.priceSellMin?.doubleValue ?? 0)")
            desLabel.text("销售价")
        } else if UserData.shared.userType == .cgy {
            price.text("\(model?.priceSupplyMin1?.doubleValue ?? 0)")
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                desLabel.text("销售价")
            } else {
                desLabel.text("会员价")
            }
            
        }
        priceShow.text("\(model?.priceShow?.doubleValue ?? 0)")
        
        if model?.isOneSell == 2 {
            price.text("***")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - 筛选侧边栏 tableview
extension StoreDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 + (baseBrandModel?.attrDataList?.count ?? 0)
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
        let titleLabel = UILabel().text("价格区间（元）").textColor(.kColor33).fontBold(14)
        let lowPriceTextField = UITextField().placeholder("最低价").cornerRadius(15).masksToBounds().backgroundColor(.kF7F7F7)
        lowPriceTextField.delegate = self
        lowPriceTextField.tag = 10000
        if let price = lowPrice {
            lowPriceTextField.text("\(price)")
        }
        
        let zLabel = UILabel().text("至").textColor(.kColor33).font(12)
        let heightPriceTextField = UITextField().placeholder("最高价").cornerRadius(15).masksToBounds().backgroundColor(.kF7F7F7)
        heightPriceTextField.delegate = self
        heightPriceTextField.tag = 10001
        if let price = heightPrice {
            heightPriceTextField.text("\(price)")
        }
        cell.sv(titleLabel, lowPriceTextField, zLabel, heightPriceTextField)
        cell.layout(
            14,
            |-14-titleLabel.height(20),
            10.5,
            |-14-lowPriceTextField.width(112).height(30)-12.5-zLabel-7-heightPriceTextField.width(112).height(30)-14-|,
            10.5
        )
        lowPriceTextField.textAlignment = .center
        lowPriceTextField.setPlaceHolderTextColor(.kColor99)
        lowPriceTextField.font = .systemFont(ofSize: 12)
        lowPriceTextField.keyboardType = .numberPad
        
        heightPriceTextField.textAlignment = .center
        heightPriceTextField.setPlaceHolderTextColor(.kColor99)
        heightPriceTextField.font = .systemFont(ofSize: 12)
        heightPriceTextField.keyboardType = .numberPad
    }
    
    func configSection1(cell: UITableViewCell, indexPath: IndexPath) {
        
        let attList = brandModel?.attrDataValueList
        var selectTitle = ""
        attList?.forEach({ (attr) in
            if attr.isCheckItem ?? false {
                if !selectTitle.isEmpty {
                    selectTitle.append(",")
                }
                selectTitle.append(attr.brandName ?? "")
            }
        })
        
        let titleLabel = UILabel().text("品牌").textColor(.kColor33).fontBold(14)
        let selectLabel = UILabel().text(selectTitle).textColor(.k2FD4A7).font(10)
        let arrowBtn = UIButton().image(#imageLiteral(resourceName: "store_sx_arrow_up"))
        cell.sv(titleLabel, selectLabel, arrowBtn)
        cell.layout(
            14,
            |-14-titleLabel.width(60).height(20)-(>=20)-selectLabel-(0)-arrowBtn.size(30)-4.5-|,
            >=10.5
        )
        if attList?.count ?? 0 <= 3 {
          //  selectLabel.isHidden = true
            arrowBtn.isHidden = true
        }
        if brandModel?.isShowMore ?? false {
            arrowBtn.image(#imageLiteral(resourceName: "store_sx_arrow_up"))
        } else {
            arrowBtn.image(#imageLiteral(resourceName: "store_sx_arrow_down"))
        }
        attList?.enumerated().forEach { (item) in
            let index = item.offset
            if !(brandModel?.isShowMore ?? false) && index > 2{
                return
            }
            let attModel = item.element
            let btnW: CGFloat = 79
            let btnH: CGFloat = 30
            let offsetY: CGFloat = 49.5 + CGFloat(40 * (index/3))
            let offsetX: CGFloat = 14 + CGFloat(91 * (index%3))
            let btn = UIButton().text(attModel.brandName ?? "").textColor(.kColor66).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            if attModel.isCheckItem ?? false {
                btn.textColor(.k2FD4A7).backgroundColor(UIColor.hexColor("#F2FFFB", alpha: 0.5)).borderColor(.k2FD4A7).borderWidth(0.5)
            }
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            btn.tag = index
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=10.5
            )
            btn.tapped { [weak self] (btn1) in
                attModel.isCheckItem = !(attModel.isCheckItem ?? false )
                self?.tableView.reloadData()
            }
        }
        arrowBtn.tapped { [weak self] (btn) in
            self?.brandModel?.isShowMore = !(self?.brandModel?.isShowMore ?? false)
            self?.tableView.reloadData()
        }
    }
    
    
    func configSection2(cell: UITableViewCell, indexPath: IndexPath) {
        let model = baseBrandModel?.attrDataList?[indexPath.section-2]
        let attList = model?.attrDataValueList
        var selectTitle = ""
        attList?.forEach({ (attr) in
            if attr.isCheckItem ?? false {
                if !selectTitle.isEmpty {
                    selectTitle.append(",")
                }
                selectTitle.append(attr.attrName ?? "")
            }
        })
        
        let titleLabel = UILabel().text(model?.attrName ?? "").textColor(.kColor33).fontBold(14)
        let selectLabel = UILabel().text(selectTitle).textColor(.k2FD4A7).font(10)
        let arrowBtn = UIButton().image(#imageLiteral(resourceName: "store_sx_arrow_up"))
        cell.sv(titleLabel, selectLabel, arrowBtn)
        cell.layout(
            14,
            |-14-titleLabel.width(60).height(20)-(>=20)-selectLabel-(0)-arrowBtn.size(30)-4.5-|,
            >=10.5
        )
        if attList?.count ?? 0 <= 3 {
          //  selectLabel.isHidden = true
            arrowBtn.isHidden = true
        }
        if model?.isShowMore ?? false {
            arrowBtn.image(#imageLiteral(resourceName: "store_sx_arrow_up"))
        } else {
            arrowBtn.image(#imageLiteral(resourceName: "store_sx_arrow_down"))
        }
        attList?.enumerated().forEach { (item) in
            let index = item.offset
            if !(model?.isShowMore ?? false) && index > 2{
                return
            }
            let attModel = item.element
            let btnW: CGFloat = 79
            let btnH: CGFloat = 30
            let offsetY: CGFloat = 49.5 + CGFloat(40 * (index/3))
            let offsetX: CGFloat = 14 + CGFloat(91 * (index%3))
            let btn = UIButton().text(attModel.attrName ?? "").textColor(.kColor66).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            if attModel.isCheckItem ?? false {
                btn.textColor(.k2FD4A7).backgroundColor(UIColor.hexColor("#F2FFFB", alpha: 0.5)).borderColor(.k2FD4A7).borderWidth(0.5)
            }
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            btn.tag = index
            cell.sv(btn)
            cell.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=10.5
            )
            btn.tapped { [weak self] (btn1) in
                attModel.isCheckItem = !(attModel.isCheckItem ?? false)
                self?.tableView.reloadData()
            }
        }
        arrowBtn.tapped { [weak self] (btn) in
            model?.isShowMore = !(model?.isShowMore ?? false)
            self?.tableView.reloadData()
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

extension StoreDetailVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 10000 {
            lowPrice = textField.text?.toInt
        } else if textField.tag == 10001 {
            heightPrice = textField.text?.toInt
        }
    }
}
