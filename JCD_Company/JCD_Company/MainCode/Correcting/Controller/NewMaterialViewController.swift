//
//  NewMaterialViewController.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import MJRefresh
import Alamofire
import ObjectMapper

class NewMaterialViewController: BaseViewController , UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    
    var viewModel: NewMaterialViewModel!
    
    var searchBar: UISearchBar!         //搜索
    
    var collectionView: UICollectionView!
    var toolView: UIView!
    var filtrateView: BrandFiltrateView!
    var leftSelectView: SelctItemView!
    var topSelectView: SelctItemView!
    var systemBrandBtn: UIButton!
    var addMaterialBlock: ((_ materialModel: MaterialsModel)->())?
    var sjsFlag = false
    
    private struct Identifier {
        static let jzgs = "JzgsCell"
        static let cgy  = "NewMaterialCell"
    }
    
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 商城界面释放 <<<<<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NewMaterialViewModel()
        viewModel.delegate = self
        
        prepareNavigationItem()
        prepareNoDateView("暂无产品")
        prepareToolView()
        prepareCollectionView()
        
        noDataView.snp.remakeConstraints { (make) in
            make.center.equalTo(collectionView)
            make.width.height.equalTo(200)
        }
        
        collectionView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hiddenFiltrateView()
    }
    //MARK: - 自定义导航栏
    func prepareNavigationItem() {
        
        //搜索栏
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = "请输入产品名称"
        if sjsFlag {
            self.title = "产品商城"
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
    }
    
    
    //MARK: - 工具栏
    func prepareToolView() {
        
        if sjsFlag {
            view?.addSubview(searchBar)
            searchBar.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.top.equalTo(64)
                }
                make.left.right.equalTo(view)
            }
            searchBar.sizeToFit()
        }
        
        
        leftSelectView = SelctItemView(frame: CGRect.zero, scrollDirection: .vertical)
        
        view?.addSubview(leftSelectView!)
        leftSelectView.selectedBlock = viewModel.leftSelectedBlock
        leftSelectView.snp.makeConstraints({ (make) in
            
            if #available(iOS 11.0, *) {
                if sjsFlag {
                    make.top.equalTo(searchBar.snp.bottom)
                }
                else {
                    make.top.equalTo(view.safeAreaLayoutGuide)
                }
            } else {
                if sjsFlag {
                    make.top.equalTo(searchBar.snp.bottom)
                }
                else {
                    make.top.equalTo(64)
                }
            }
            make.left.bottom.equalToSuperview()
            make.width.equalTo(95)
        })
        
        topSelectView = SelctItemView(frame: CGRect.zero, scrollDirection: .horizontal)
        
        view?.addSubview(topSelectView!)
        topSelectView.selectedBlock = viewModel.topSelectedBlock
        topSelectView.snp.makeConstraints({ (make) in
            
            make.top.equalTo(leftSelectView)
            make.left.equalTo(leftSelectView.snp.right)
            make.right.equalTo(-11)
            make.height.equalTo(50)
        })
        
        toolView = UIView()
        toolView.backgroundColor = UIColor.white
        view.addSubview(toolView)
        
        toolView.snp.makeConstraints { (make) in
            
            make.top.equalTo(topSelectView.snp.bottom)
            make.left.equalTo(leftSelectView.snp.right)
            make.right.equalTo(-11)
            make.height.equalTo(40)
        }
        
        //系统品牌
        systemBrandBtn = UIButton(type: .custom)
        systemBrandBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        systemBrandBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
        systemBrandBtn.setImage(UIImage.init(named: "up_arrows"), for: .selected)
        systemBrandBtn.addTarget(self, action: #selector(systemBrandAction(_:)), for: .touchUpInside)
        toolView.addSubview(systemBrandBtn)
        
        systemBrandBtn.snp.makeConstraints { (make) in
            make.left.top.equalTo(0)
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
        systemBrandBtn.set(image: UIImage.init(named: "down_arrows"), title: "全部品牌", imagePosition: .right, additionalSpacing: 5, state: .normal)
        
        filtrateView = BrandFiltrateView()
        filtrateView.selectedBlock = viewModel.filtrateSelectedBlock
        filtrateView.hiddeBlock = {[weak self] in
            self?.systemBrandBtn.isSelected = false
        }
    }
    
    //MARK: - 创建collectionView
    func prepareCollectionView() {
        
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 11)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(NewMaterialCell.self, forCellWithReuseIdentifier: Identifier.jzgs)
        collectionView.register(UINib.init(nibName: "CGYCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Identifier.cgy)
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.equalTo(leftSelectView.snp.right)
            make.top.equalTo(toolView.snp.bottom)
            make.right.bottom.equalToSuperview()
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        collectionView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        collectionView.mj_footer = footer
        //        collectionView.mj_footer?.isHidden = true
        
        view?.addSubview(filtrateView)
        filtrateView?.snp.makeConstraints({ (make) in
            
            make.top.equalTo(toolView.snp.bottom)
            make.left.equalTo(leftSelectView.snp.right)
            make.right.equalTo(-18)
            make.bottom.equalToSuperview()
        })
    }
    
    
    
    @objc func headerRefresh() {
        viewModel.headerRefresh()
        //        collectionView.mj_footer?.endRefreshingWithNoMoreData()
    }
    
    @objc func footerRefresh() {
        viewModel.footerRefresh()
    }
    
    //MARK: - 按钮事件
    //系统品牌
    @objc func systemBrandAction(_ sender: UIButton) {
        
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected  {
            filtrateView?.showMenu()
            
        }else {
            filtrateView?.hiddenMenu()
        }
    }
    
    func hiddenFiltrateView() {
        if filtrateView.isHidden == false {
            filtrateView?.hiddenMenu()
        }
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if UserData.shared.sjsEnter && sjsFlag {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.cgy, for: indexPath) as! CGYCollectionViewCell
            cell.model = viewModel.itemsData[indexPath.item]
            cell.delegate = viewModel
            cell.addShopCarButton.isHidden = true
            return cell
        }
        
        switch UserData.shared.userType {
        case .jzgs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.jzgs, for: indexPath) as! NewMaterialCell
            cell.model = viewModel.itemsData[indexPath.item]
            return cell
        case .cgy:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.cgy, for: indexPath) as! CGYCollectionViewCell
            cell.model = viewModel.itemsData[indexPath.item]
            cell.delegate = viewModel
            return cell
        default:
            fatalError("\(UserData.shared.userType) is unused reuseIdentifier")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if UserData.shared.sjsEnter && sjsFlag { return }
        
        let vc = MaterialDetailController()
        if !viewModel.isAddMaterial {
            vc.detailType = .addCart
        }
        else {
            vc.detailType = .addShop
            vc.selectBlock = { [weak self] materialsModel in
                self?.addMaterialBlock?(materialsModel)
            }
        }
        vc.hidesBottomBarWhenPushed = true
        vc.materialsModel = viewModel.itemsData[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if UserData.shared.sjsEnter && sjsFlag {
            let cellWidth = IS_iPad ? (PublicSize.screenWidth-95-13)/2 : (PublicSize.screenWidth-95-12)
            let cellHeight = cellWidth*(500.0/369) / 4
            let itemSize = CGSize(width: cellWidth, height: cellHeight)
            return itemSize
        }
        
        switch UserData.shared.userType {
        case .jzgs:
            let cellWidth = IS_iPad ? (PublicSize.screenWidth-95-13)/3 : (PublicSize.screenWidth-95-12)/2
            let cellHeight = cellWidth*(500.0/369)
            let itemSize = CGSize(width: cellWidth, height: cellHeight)
            return itemSize
        case .cgy:
            let cellWidth = IS_iPad ? (PublicSize.screenWidth-95-13)/2 : (PublicSize.screenWidth-95-12)
            let cellHeight = cellWidth*(500.0/369) / 4
            let itemSize = CGSize(width: cellWidth, height: cellHeight)
            return itemSize
        default:
            fatalError("\(UserData.shared.userType) is unused reuseIdentifier")
        }
        
    }
    
    
    //MARK: - SearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        let vc = CurrencySearchController()
        vc.sjsFlag = self.tabBarItem.title != "商城"
        vc.searchString = searchBar.text
        vc.isAddMaterial = viewModel.isAddMaterial
        vc.addMaterialBlock = addMaterialBlock
        vc.searchBlock = viewModel.searchBlock
        self.navigationController?.pushViewController(vc, animated: false)
        return false
    }
}
// MARK: - NewMaterialViewModelDelegate
extension NewMaterialViewController: NewMaterialViewModelDelegate {
    
    func updateBrandUI() {
        systemBrandBtn.setTitle(viewModel.brandName == "" ? "全部品牌" : viewModel.brandName, for: .normal)
    }
    
    func reloadUI() {
        
        DispatchQueue.main.async {
            //            self.collectionView.setContentOffset(CGPoint.zero, animated: true)
            self.collectionView.scrollsToTop = true
            self.collectionView.reloadData()
            self.noDataView.isHidden = self.viewModel.isHiddenNoMoreData
            if self.viewModel.showMoreData {
                self.collectionView.mj_footer?.resetNoMoreData()
            }
            else {
                self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self.collectionView.mj_footer?.isHidden = !self.viewModel.isHiddenNoMoreData
        }
        
    }
    
    func showNormoreData() {
        self.collectionView.mj_footer?.resetNoMoreData()
    }
    
    func hiddenFiltrate() {
        self.hiddenFiltrateView()
    }
    
    // 更新顶部标签栏
    func updateTopViewUI() {
        self.topSelectView.seletIndexPath = IndexPath(item: 0, section: 0)
        self.systemBrandBtn.setTitle("全部品牌", for: .normal)
        self.filtrateView.merchantData = viewModel.category.brandList
    }
    
    func updateTopViewUINotNeedIndex() {
        self.systemBrandBtn.setTitle("全部品牌", for: .normal)
        DispatchQueue.main.async {
            self.filtrateView.merchantData = self.viewModel.secondItems ?? []
        }
    }
    
    // 刷新搜索栏
    func updateSearchBar() {
        searchBar.text = viewModel.searchName
    }
    
    func endRefreshing() {
        if collectionView.mj_header?.isRefreshing ?? false {
            collectionView.mj_header?.endRefreshing()
        }
        if collectionView.mj_footer?.isRefreshing ?? false {
            collectionView.mj_footer?.endRefreshing()
        }
    }
    
    
    func alertSuccess(_ text: String, autoClear: Bool, autoClearTime: Float) {
        self.noticeSuccess(text, autoClear: autoClear, autoClearTime: autoClearTime)
    }
    
    func updateLeftSelectView() {
        self.leftSelectView.itemsData = viewModel.leftItems
    }
    
    func updateTopSelectView() {
        self.topSelectView.itemsData = viewModel.topItems
    }
    
    func clearNotice() {
        self.clearAllNotice()
    }
    
    func showWait() {
        self.pleaseWait()
    }
    
    func alert(_ text: String) {
        self.noticeOnlyText(text)
    }
    
    func noneMoreData() {
        self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
    }
}
