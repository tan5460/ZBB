//
//  MaterialSearchController.swift
//  YZB_Company
//
//  Created by yzb_ios on 10.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import MJRefresh


class MaterialSearchController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    var isBrand = false //是否品牌介绍跳过来
    var isSecondSearch = false          //是否第二次搜索
    var isAddMaterial: Bool = false     //是否添加主材
    var isFirstLoad = true              //第一次请求
    var brandName = ""                  //品牌名
    var brandId = ""                    // 品牌id
    var merchantId = ""                 //供应商id
    var addMaterialBlock: ((_ materialModel: MaterialsModel)->())?
    
    var categoryId: String?                 //分类id
    
    var searchStr = ""
    var searchBar: UISearchBar!         //搜索
    var searchBtn: UIButton!
    
    var itemsData: Array<MaterialsModel> = []
    var collectionView: UICollectionView!
    var curPage = 1                     //页码
    let cellIdentifier = "MaterialSearchCell"
    var sjsFlag = false
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 主材搜索界面释放 <<<<<<<<<<<<<<<<<<<<<<")
    }
    
    ///默认需要品牌
    var brandNameIsNeeded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isBrand {
            
            prepareNavigationItem()
        }
        prepareNoDateView("暂无产品")
        prepareCollectionView()
        
        if isFirstLoad {
            isFirstLoad = false
            mjReloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    //MARK: - 创建视图
    func prepareNavigationItem() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if isSecondSearch {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        }
        
        //搜索栏
        searchBar = UISearchBar(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth-50, height: 40))
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = "请输入产品名/品牌名"
        navigationItem.titleView = searchBar
        
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
        
        searchBar.backgroundImage = UIColor.white.image()
        searchBar.backgroundColor = .white
        let textfield = searchBar.textField
        textfield?.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF0F0F0)
        textfield?.layer.cornerRadius = 18
        textfield?.layer.masksToBounds = true
        textfield?.font = UIFont.systemFont(ofSize: 13)
        textfield?.clearButtonMode = .never
        textfield?.textColor = PublicColor.commonTextColor
        
        //让UISearchBar 支持空搜索
        textfield?.enablesReturnKeyAutomatically = false
        
        searchBar.text = searchStr
    }
   
    func prepareCollectionView() {
        
        var cellWidth = IS_iPad ? (PublicSize.screenWidth-40)/3 : (PublicSize.screenWidth-30)/2
        var cellHeight = cellWidth*(245.0/173)
        if UserData.shared.sjsEnter && sjsFlag || UserData.shared.userType == .cgy {
            cellWidth = PublicSize.screenWidth - 20
            cellHeight = cellWidth*(500.0/369) / 4
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(MaterialCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.hw_registerCell(cell: CGYCollectionViewCell.self)
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(64)
            }
            make.left.right.bottom.equalToSuperview()
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        collectionView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        collectionView.mj_footer = footer
        collectionView.mj_footer?.isHidden = true
    }
    
    //刷新列表
    @objc func mjReloadData() {
        
        if ((collectionView.mj_header?.isRefreshing) != nil) {
            collectionView.mj_header?.endRefreshing()
        }
        
        self.pleaseWait()
        headerRefresh()
    }
    
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        
        curPage = 1
        collectionView.mj_footer?.endRefreshingWithNoMoreData()
        loadData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        
        if itemsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    //MARK: - 按钮事件
    @objc func backAction() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - 网络请求
    
    func loadData() {
        
        var storeID = ""
        var cityID = ""
        var substationId = ""
        var merchantIdStr = ""
        
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            if let valueStr = UserData.shared.workerModel?.store?.id {
                storeID = valueStr
            }
            if let valueStr = UserData.shared.workerModel?.store?.city?.id {
                cityID = valueStr
            }
            if let valueStr = UserData.shared.workerModel?.substation?.id {
                substationId = valueStr
            }
            
        case .gys:// 品牌商
            if let valueStr = UserData.shared.merchantModel?.id {
                merchantIdStr = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.substationId {
                substationId = valueStr
            }
            
            if let brandN = UserData.shared.merchantModel?.brandName, brandNameIsNeeded {
                brandName = brandN
            }
            
        case .yys:
            if let valueStr = UserData.shared.substationModel?.id {
                substationId = valueStr
            }
        case .fws:
            if let valueStr = UserData.shared.merchantModel?.id {
                merchantIdStr = valueStr
            }
            if let valueStr = UserData.shared.merchantModel?.substationId {
                substationId = valueStr
            }
            
            if let brandN = UserData.shared.merchantModel?.brandName, brandNameIsNeeded {
                brandName = brandN
            }
        }
        
        if merchantIdStr != "" {
            merchantId = merchantIdStr
        }
        
        let pageSize = IS_iPad ? 21 : 20
        var parameters: Parameters = [:]
        
        parameters["current"] = "\(self.curPage)"
        parameters["size"] = "\(pageSize)"
        parameters["cityId"] = UserData.shared.substationModel?.cityId
        parameters["substationld"] = UserData.shared.substationModel?.id
        parameters["name"] = searchStr
        parameters["sortType"] = "4"
        parameters["merchantId"] = merchantId
        parameters["brandName"] = brandName
        let tag = UserData.shared.tabbarItemIndex
        if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            if tag == 1 {
                parameters["materialsType"] = 2
            } else if tag == 2 {
                parameters["materialsType"] = 1
            }
        }        
        parameters["isOneSell"] = ""
        if categoryId != nil {
            parameters["category"] = categoryId!
        }
        parameters["substationId"] = substationId
        
        AppLog(">>>>>>>>>>>>> 分类筛选: \(parameters)")
        
        let urlStr = APIURL.getMaterials
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            //结束刷新
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            self.collectionView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" || errorCode == "015" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                var dataArray = [Any]()
                if UserData.shared.userType == .yys {
                    let dataDic1 = Utils.getReadDic(data: dataDic, field: "page")
                    dataArray = Utils.getReadArr(data: dataDic1, field: "records") as! [Any]
                } else {
                    dataArray = Utils.getReadArr(data: dataDic, field: "records") as! [Any]
                }
                
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.curPage > 1 {
                    self.itemsData += modelArray
                }
                else {
                    self.itemsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.collectionView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.itemsData.removeAll()
            }
            
            self.collectionView.reloadData()
            
            if self.itemsData.count <= 0 {
                self.collectionView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
            
        }) { (error) in
            
            //结束刷新
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            
            if self.itemsData.count <= 0 {
                self.collectionView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.collectionView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
        }
    }
    
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if sjsFlag || UserData.shared.userType == .cgy {
            let cell = collectionView.hw_dequeueReusableCell(indexPath: indexPath) as CGYCollectionViewCell
            cell.sjsFlag = sjsFlag
            cell.delegate = self
            cell.model = itemsData[indexPath.item]
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MaterialCell
            cell.model = itemsData[indexPath.item]
            cell.isAddMaterial = isAddMaterial
//            cell.addShopBtn.isHidden = UserData.shared.sjsEnter || UserData.shared.userType == .gys || UserData.shared.userType == .yys
            cell.addMaterialBlock = { [weak self] in
                let model = self?.itemsData[indexPath.row]
                
                if let block = self?.addMaterialBlock {
                    block(model!)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        navigationController?.viewControllers.forEach({ (vc) in
            if vc.isKind(of: GXTGYQVC.classForCoder()) {
                let model = itemsData[indexPath.item]
                navigationController?.popToViewController(vc, animated: true)
                NotificationCenter.default.post(name: NotificationName.returnMaterialId, object: model.id, userInfo: nil)
                return
            }
        })
        
        if UserData.shared.sjsEnter && sjsFlag { return }
            
        let vc = MaterialsDetailVC()
        vc.hidesBottomBarWhenPushed = true
//        vc.detailType = .detail
//        vc.isMainPageEnter = false
        vc.materialsModel = itemsData[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)

    }
    
    
    //MARK: - SearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let vc = CurrencySearchController()
        vc.searchString = searchBar.text
        
        if UserData.shared.userType == .jzgs {
            vc.searchType = .material
        }else {
            vc.searchType = .cgMaterial
        }
        vc.sjsFlag = sjsFlag
        vc.isSecondSearch = true
        vc.searchBlock = {[weak self] (searchString) in
            self?.searchBar.text = searchString
            self?.searchStr = searchString
            self?.isFirstLoad = true
            self?.mjReloadData()
        }
        self.navigationController?.pushViewController(vc, animated: false)
        return false
    }

}

extension MaterialSearchController: CGYCollectionViewCellDelegate {
    ///查询是否已经加入预购
    func checkIsAdded(_ model: MaterialsModel!) {
        
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        guard let workerId = UserData.shared.workerModel?.id else{
            self.noticeOnlyText("参数异常")
            return
        }
        
        let parameters: Parameters = ["storeId": storeID, "id": model!.id!, "workerId": workerId]
        
        self.clearAllNotice()
        let urlStr = APIURL.isAddPurchase
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let isExist = Utils.getReadString(dir: response["body"] as! NSDictionary, field: "isExist")
                if isExist == "1" { // 已加入
                    self.noticeOnlyText("已加入预购清单")
                }
                else {
                }
                
            }
            
        }) { (error) in
            
        }
    }
    
    func addPurchase(_ model: MaterialsModel!) {
        
        checkIsAdded(model)
    }
}
