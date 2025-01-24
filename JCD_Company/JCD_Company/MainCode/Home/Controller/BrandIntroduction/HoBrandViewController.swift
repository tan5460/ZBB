//
//  HoBrandViewController.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/11.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import MJRefresh
import Alamofire

class HoBrandViewController: BaseViewController {
    
    var brandType: String?
    var brandId: String?
    var brandName: String?
    var categoryId: String?
    var sortType = "1"
    var isSecond = false
    var searchText: String?
    var sjsFlag = false

    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var firstBtn: UIButton!
    @IBOutlet weak var fLine: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var secondItem: HoPriceLabel!
    @IBOutlet weak var thirdItem: HoSiLabel!
    
    @IBOutlet weak var zLeft: NSLayoutConstraint!
    @IBOutlet weak var siCollectionView: UICollectionView!
    private struct Constant {
        private static let screenW = UIScreen.main.bounds.size.width
        private static let screenH = UIScreen.main.bounds.size.height
        private static let itemWidth = screenW * 517 / 1125
        
        static let upsItemSize: CGSize = CGSize(width: screenW * 315 / 1125, height: screenH * 90 / 2436)
        static let itemSize: CGSize = CGSize(width: itemWidth, height: itemWidth + 63)
        
        static let normalTag = 10
        static let popTag = 20
    }
    
    @IBOutlet weak var siLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var sureBtn: UIButton! {
        didSet {
            sureBtn.setBackgroundImage(PublicColor.gradualColorImage, for: .normal)
        }
    }
    
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightView: UIView!
    
    private var searchBar: UISearchBar!
    
    // 分类数据
    private var catItems: [HoStoreModel]!
    // 主材数据
    private var itms: [MaterialsModel]!
    
    // 分页
    private var pageSize = 1
    
    // 每页数据个数
    private let size = IS_iPad ? 21 : 20

    // 选中一级分类
    private var selectedFirst: HoStoreModel!
    // 选中二级分类
    private var selectedSecond: HoStoreModel!
    // 选中三级分类
    private var selectedThird: HoStoreModel!
    // 选中规格
    private var selectedGg: HoSpecData!
    
    private var firstMoreItem: HoStoreModel!
    private var secondMoreItem: HoStoreModel!
    private var thirdMoreItem: HoStoreModel!
    private var ggMoreItem: HoSpecData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
       // loadCateData()
    }
    
    @IBAction func closePopView(_ sender: Any) {
        hiddenSiView()
    }
    
    @IBAction func reset(_ sender: Any) {
        thirdItem?.isSelected = false
        
        resetItems()
        
        selectedFirst = catItems.first
        selectedFirst?.isSelected = true
        siCollectionView?.reloadData()
    }
    @IBAction func sure(_ sender: UIButton) {
        thirdItem?.isSelected = true
        hiddenSiView()
        
        // 筛选分类id
        categoryId = selectedThird?.id ?? selectedSecond?.id ?? selectedFirst?.id ?? ""
        collectionView.mj_header?.beginRefreshing()

    }
    
    @IBAction func defClick(_ sender: UIButton) {
        
        firstBtn?.isSelected = true
        fLine.isHidden = false
        
        secondItem.setNormal()
        
        sortType = "1"
        collectionView.mj_header?.beginRefreshing()
    }
    
    
    deinit {
        [leftBtn, rightView].forEach { $0?.removeFromSuperview() }
    }
    
    
    func showSiView() {
        [leftBtn,rightView].forEach { $0?.isHidden = false }
    }
    
    func hiddenSiView() {
        [leftBtn,rightView].forEach { $0?.isHidden = true }
        self.zLeft?.constant = self.view.width
    }
    
    private func setupUI() {
        
        secondItem.delegate = self
        //搜索栏
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        
        searchBar.placeholder = "请输入产品名称"
        searchBar.delegate = self
        if isSecond {
            navigationItem.title = "搜索: \(searchText ?? "")"
        }
        else {
            navigationItem.titleView = searchBar
        }
        
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
        
        searchBar.backgroundImage = UIColor.white.image()
        searchBar.backgroundColor = .white
        let textfield = searchBar.textField
        textfield?.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF0F0F0)
        textfield?.layer.cornerRadius = 18
        textfield?.layer.masksToBounds = true
        textfield?.clearButtonMode = .never
        textfield?.font = UIFont.systemFont(ofSize: 13)
        textfield?.textColor = PublicColor.commonTextColor
        
        //让UISearchBar 支持空搜索
        textfield?.enablesReturnKeyAutomatically = false
        
        
        UIApplication.shared.keyWindow?.addSubview(leftBtn)
        UIApplication.shared.keyWindow?.addSubview(rightView)
        
        leftBtn.snp.makeConstraints { (make) in
            make.width.equalTo(80)
            make.top.left.bottom.equalToSuperview()
        }
        
        rightView.snp.makeConstraints { (make) in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(leftBtn.snp.right)
        }
        firstBtn.isHidden = true
        fLine.isHidden = true
        secondItem.isHidden = true
        thirdItem.isHidden = true
        
        let screenW = UIScreen.main.bounds.size.width
        let itemWidth = screenW * 517 / 1125
        let itemSize: CGSize = CGSize(width: itemWidth, height: itemWidth + 63)
        layout.sectionInset = UIEdgeInsets(top: 11, left: 0, bottom: 0, right: 0)
        layout.itemSize = itemSize
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 3
        
        collectionView.snp.remakeConstraints { (make) in
            make.top.equalTo(0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        collectionView.hw_registerCell(cell: MaterialCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 11, bottom: 11, right: 11)
        collectionView.refreshHeader { [weak self] in
            self?.headerRefresh()
        }
        collectionView.refreshFooter { [weak self] in
            self?.footerRefresh()
        }
        // 筛选
        thirdItem.delegate = self
        
        let siItemWidth = (screenW - 80) / 3 - 20
        let siItemSize: CGSize = CGSize(width: siItemWidth, height: 30)
        siLayout.itemSize = siItemSize
        siLayout.minimumLineSpacing = 8
        siLayout.minimumInteritemSpacing = 1
        siCollectionView.hw_registerCell(cell: HoBrandItemCollectionViewCell.self)
        siCollectionView.hw_registerCollectionHeaderView(reusableView: HoBrandSiCollectionReusableView.self)
        siCollectionView.delegate = self
        siCollectionView.dataSource = self
        siCollectionView.contentInset = UIEdgeInsets(top: 11, left: 11, bottom: 11, right: 11)
        
        self.headerHeight.constant = isSecond ? 0 : 60
        self.header.isHidden = isSecond
        
        collectionView.mj_header?.beginRefreshing()
    }
    
    // 头部刷新
    @objc func headerRefresh() {
        
        self.pageSize = 1
        loadData()
    }
    
    // 加载更多
    @objc func footerRefresh() {
        self.pageSize += 1
        loadData()
    }
    
    private func loadData() {
        
        var parameters = Parameters()
        parameters["cityId"] = UserData.shared.storeModel?.cityId
        parameters["storeId"] = UserData.shared.storeModel?.id
        parameters["substationId"] = UserData.shared.substationModel?.id
        parameters["current"] = "\(self.pageSize)"
        parameters["size"] = "\(size)"
        parameters["name"] = searchText
       // parameters["brandName"] = brandName
        parameters["brandId"] = brandId
        parameters["sortType"] = sortType // 1综合 2升序 3降序
        parameters["materialsType"] = "1"
        parameters["isOneSell"] = ""
        parameters["categorycId"] = categoryId
        parameters["merchantId"] = UserData.shared.merchantModel?.id
        if selectedGg?.id == "2" {
            parameters["customizeFlag"] = selectedGg?.id ?? ""
        } else {
            parameters["yzbSpecification.id"] = selectedGg?.id ?? ""
        }
        YZBSign.shared.request(APIURL.getMaterials, method: .get, parameters: parameters, success: responset) { (error) in  }
    }
    
    // MARK: - 加载数据
    private func loadCateData() {
//        YZBSign.shared.request(APIURL.getCategoryByBrandType, method: .post, parameters: ["brandType": brandType ?? ""], success: response(_:)) { (er) in }
    }
    
    private func response(_ res : [String : AnyObject]) {
        self.clearAllNotice()
        let errorCode = Utils.getReadString(dir: res as NSDictionary, field: "code")
        if errorCode == "0" {
            let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
            let dataArray = Utils.getReadArr(data: dataDic, field: "records")
            let modelArray = Mapper<HoStoreModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
            self.catItems = modelArray
            let all = HoStoreModel()
            all.name = "全部"
            all.id = ""
            all.isSelected = true
            self.selectedFirst = all
            self.catItems?.insert(all, at: 0)
            siCollectionView.reloadData()
        }
        else if errorCode == "008" {
            
        }
    }
    
    private func responset(_ res : [String : AnyObject]) {
        collectionView.mj_header?.endRefreshing()
        self.clearAllNotice()
        let errorCode = Utils.getReadString(dir: res as NSDictionary, field: "code")
        if errorCode == "0" {
            let dataDic = Utils.getReadDic(data: res as AnyObject, field: "data")
            let dataArray = Utils.getReadArr(data: dataDic, field: "records")
            let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
            if modelArray.count < size {
                collectionView.mj_footer?.endRefreshingWithNoMoreData()
            }
            else {
                collectionView.mj_footer?.endRefreshing()
            }
            
            if self.pageSize > 1 {
                self.itms += modelArray
            }
            else {
                self.itms = modelArray
            }
            
            collectionView.reloadData()
            
        }else if errorCode == "008" {
            // 无数据
            self.itms = []
            collectionView.mj_footer?.endRefreshingWithNoMoreData()
            collectionView.reloadData()
        }
        else if errorCode == "015" { // 超出记录
            
            collectionView.mj_footer?.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var shadowHeaght: CGFloat = 1
        let screenScale = UIScreen.main.scale
        
        if screenScale == 2 {
            shadowHeaght = shadowHeaght/2
        }else if screenScale == 3 {
            shadowHeaght = shadowHeaght/3
        }
        
        //设置导航栏分割线
        let shadImage = UIColor.white.image(size: CGSize(width: PublicSize.screenWidth, height: shadowHeaght))
        navigationController?.navigationBar.shadowImage = shadImage
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension HoBrandViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == Constant.normalTag {
            return 1
        }
        else if collectionView.tag == Constant.popTag {
            
            if selectedFirst != nil {
                
                if selectedFirst?.name != "全部" {
                    
                    if selectedSecond != nil {
                        if selectedThird != nil {
                            return 4
                        }
                        return 3
                    }
                    return 2
                }
                return 1
            }
            return 1
        }
        
        fatalError("Not Set Tag")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == Constant.normalTag {
            return itms?.count ?? 0
        }
        else if collectionView.tag == Constant.popTag {
            
            if section == 0 {
                
                if catItems != nil && catItems.count > 9 {
                    firstMoreItem = catItems[8]
                    firstMoreItem.isMoreItem = true
                }
                else {
                    firstMoreItem = nil
                }
                
                if firstMoreItem?.isOpen == false {
                    return 9
                }
                else {
                    return catItems?.count ?? 0
                }
                
            }
            else if section == 3 {
                
                if selectedThird?.specDataList != nil && selectedThird?.specDataList?.count ?? 0 > 9 {
                    ggMoreItem = selectedThird?.specDataList?[8]
                    ggMoreItem.isMoreItem = true
                }
                else {
                    ggMoreItem = nil
                }
                
                if ggMoreItem?.isOpen == false {
                    return 9
                }
                else {
                    return selectedThird?.specDataList?.count ?? 0
                }
            }
            
            if section == 1 {
                if selectedFirst?.categoryList != nil && selectedFirst?.categoryList?.count ?? 0 > 9 {
                    secondMoreItem = selectedFirst?.categoryList?[8]
                    secondMoreItem.isMoreItem = true
                }
                else {
                    secondMoreItem = nil
                }
                
                if secondMoreItem?.isOpen == false {
                    return 9
                }
                else {
                    return selectedFirst?.categoryList?.count ?? 0
                }
            }
            else if section == 2 {
                if selectedSecond?.categoryList != nil && selectedSecond?.categoryList?.count ?? 0 > 9 {
                    thirdMoreItem = selectedSecond?.categoryList?[8]
                    thirdMoreItem.isMoreItem = true
                }
                else {
                    thirdMoreItem = nil
                }
                
                if thirdMoreItem?.isOpen == false {
                    return 9
                }
                else {
                    return selectedSecond?.categoryList?.count ?? 0
                }
            }
            
            return 0
        }
        
        fatalError("Not Set Tag")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == Constant.normalTag {
            
            let cell = collectionView.hw_dequeueReusableCell(indexPath: indexPath) as MaterialCell
            cell.model = itms[indexPath.item]
            cell.sjsFlag = sjsFlag
            cell.model = itms[indexPath.item]
            cell.isAddMaterial = false
//            cell.addShopBtn.isHidden = UserData.shared.sjsEnter || UserData.shared.userType == .gys || UserData.shared.userType == .yys
//            cell.addMaterialBlock = { [weak self] in
//                let model = self?.itemsData[indexPath.row]
//
//                if let block = self?.addMaterialBlock {
//                    block(model!)
//                }
//            }
            
            return cell
        }
        else if collectionView.tag == Constant.popTag {
            
            let cell = collectionView.hw_dequeueReusableCell(indexPath: indexPath) as HoBrandItemCollectionViewCell
            
            if indexPath.section == 0 {
                cell.item = catItems[indexPath.item]
            }
            else {
                
                if indexPath.section == 3 {
                    let item = selectedThird?.specDataList?[indexPath.item]
                    cell.ggItem = item
                }
                else if indexPath.section == 2 {
                    let item = selectedSecond?.categoryList?[indexPath.item]
                    cell.item = item
                }
                else if indexPath.section == 1 {
                    let item = selectedFirst?.categoryList?[indexPath.item]
                    cell.item = item
                }
            }
            
            return cell
        }
        
        fatalError("Not Set Tag")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView.tag == Constant.popTag {
            return CGSize.init(width: collectionView.width, height: 44)
        }
        
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if collectionView.tag == Constant.popTag {
            let header = collectionView.hw_dequeueCollectionHeaderView(indexPath: indexPath) as HoBrandSiCollectionReusableView
            header.title = indexPath.headerTitle
            header.section = indexPath
            header.delegate = self
            
            if indexPath.section == 0 {
               header.upIsHidden = !(firstMoreItem?.isOpen ?? false)
            }
            else if indexPath.section == 1 {
               header.upIsHidden = !(secondMoreItem?.isOpen ?? false)
            }
            else if indexPath.section == 2 {
               header.upIsHidden = !(thirdMoreItem?.isOpen ?? false)
            }
            else if indexPath.section == 3 {
               header.upIsHidden = !(ggMoreItem?.isOpen ?? false)
            }
            
            return header
        }
        return UICollectionReusableView(frame: CGRect.zero)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == Constant.normalTag {
            let vc = MaterialsDetailVC()
            vc.materialsModel = itms[indexPath.item]
            navigationController?.pushViewController(vc, animated: true)
        }
        else if collectionView.tag == Constant.popTag {
            
            if indexPath.section == 0 {
                let item = catItems[indexPath.row]
                selectedFirst?.isSelected = false
                selectedFirst = item
                selectedFirst?.isSelected = true
                
                selectedSecond?.isSelected = false
                selectedSecond = nil
                selectedThird?.isSelected = false
                selectedThird = nil
                selectedGg?.isSelected = false
                selectedGg = nil
                
                if item == firstMoreItem {
                    item.isOpen = true
                }
            }
            if indexPath.section == 1 {
                let item = selectedFirst?.categoryList?[indexPath.row]
                selectedSecond?.isSelected = false
                selectedSecond = item
                selectedSecond?.isSelected = true
                
                selectedThird?.isSelected = false
                selectedThird = nil
                selectedGg?.isSelected = false
                selectedGg = nil
                
                if item == secondMoreItem {
                    item?.isOpen = true
                }
            }
            if indexPath.section == 2 {
                let item = selectedSecond?.categoryList?[indexPath.row]
                
                selectedThird?.isSelected = false
                selectedThird = item
                selectedThird?.isSelected = true
                
                selectedGg?.isSelected = false
                selectedGg = nil
                
                if item == thirdMoreItem {
                    item?.isOpen = true
                }
            }
            
            if indexPath.section == 3 {
                let item = selectedThird?.specDataList?[indexPath.row]
                selectedGg?.isSelected = false
                selectedGg = item
                selectedGg?.isSelected = true
                
                if item == ggMoreItem {
                    item?.isOpen = true
                }
            }
            
            
            collectionView.reloadData()
        }
        
    }
    
}

private extension IndexPath {
    
    var headerTitle: String? {
        get {
            var t = "一"
            switch section {
            case 0: t = "一"
            case 1: t = "二"
            case 2: t = "三"
            case 3: t = "四"
            case 4: t = "五"
            case 5: t = "六"
            default: return "无定义"
            }
            
            return "\(t)级分类"
        }
    }
}
// MARK: - HoBrandSiCollectionReusableViewDelegate
extension HoBrandViewController: HoBrandSiCollectionReusableViewDelegate {
    
    func up(_ didClick: IndexPath) {
        
        if didClick.section == 0 {
            firstMoreItem?.isOpen = false
        }
        else if didClick.section == 1 {
            secondMoreItem?.isOpen = false
        }
        else if didClick.section == 2 {
            thirdMoreItem?.isOpen = false
        }
        else if didClick.section == 3 {
            ggMoreItem?.isOpen = false
        }
        
        siCollectionView.reloadData()
    }
}
// MARK: - 搜索
extension HoBrandViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let vc = CurrencySearchController()
        vc.searchType = .brand
        vc.brandType = brandType
        vc.brandName = brandName
        vc.categoryId = categoryId
        self.navigationController?.pushViewController(vc, animated: false)
        return false
    }
}
// MARK: - 价格点击
extension HoBrandViewController: HoPriceLabelDelegate {
    
    func stateChanged(state: HoPriceState) { 
        switch state {
        case .normal:
            defClick(firstBtn)
        case .up:
            sortType = "3"
            firstBtn.isSelected = false
            fLine.isHidden = true
            collectionView.mj_header?.beginRefreshing()
        case .down:
            sortType = "2"
            firstBtn.isSelected = false
            fLine.isHidden = true
            collectionView.mj_header?.beginRefreshing()
        }
    }
}
// MARK: - 筛选点击
extension HoBrandViewController: HoSiLabelDelegate {
    
    func click() {
        
        showSiView()
    }
    
    private func resetItems() {
        selectedFirst?.isSelected = false
        selectedFirst = nil
        selectedSecond?.isSelected = false
        selectedSecond = nil
        selectedThird?.isSelected = false
        selectedThird = nil
        selectedGg?.isSelected = false
        selectedGg = nil
        
        selectedFirst = catItems?.first
        selectedFirst?.isSelected = true
        
        ggMoreItem?.isOpen = false
        [firstMoreItem, secondMoreItem, thirdMoreItem].forEach { $0?.isOpen = false }
        
        siCollectionView?.reloadData()
    }
}
