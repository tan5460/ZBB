//
//  StoreViewController.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/6.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import SkeletonView
import MJRefresh

class StoreViewController: BaseViewController {
    
    /// 逻辑处理
    private var viewModel: StoreViewModel!
    /// 搜索
    private var searchBar: UISearchBar!
    /// 左分类
    private var leftTableView: UITableView!
    /// 右品牌
    private var rightCollectionView: UICollectionView!
    
    var sjsFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindValue()
        setupUI()
        viewModel.loadData()
//        if UserData.shared.userType == .cgy {
//            if !UserDefaults.standard.bool(forKey: UserDefaultStr.firstGuide2) {
//                UserDefaults.standard.set(true, forKey: UserDefaultStr.firstGuide2)
//                loadGuideView()
//            }
//        }
    }
    
    func loadGuideView() {
        let guideView = UIView()
        guideView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        guideView.backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        UIApplication.shared.windows.first?.addSubview(guideView)
        
        let guideIcon = UIImageView().image(#imageLiteral(resourceName: "guide_icon"))
        let guideIV1 = UIImageView().image(#imageLiteral(resourceName: "guide_3_1"))
        let guideIV2 = UIImageView().image(#imageLiteral(resourceName: "guide_3_2"))
        guideView.sv(guideIcon, guideIV1, guideIV2)
        guideView.layout(
            PublicSize.kNavBarHeight + 75,
            |-130.5-guideIcon.width(33.5).height(55.5),
            1,
            |-143-guideIV1.width(133).height(47),
            >=0,
            guideIV2.width(162.24).height(63)-86.5-|,
            PublicSize.kTabBarHeight+10
        )
        
        let tabbarW: CGFloat = view.width/5
        let tabbarH: CGFloat = 45
        let tabbarBtn = UIButton().image(#imageLiteral(resourceName: "guide_3_white")).text("预购清单").textColor(.white).font(10)
        guideView.sv(tabbarBtn)
        guideView.layout(
            >=0,
            tabbarBtn.width(tabbarW).height(tabbarH)-tabbarW-|,
            PublicSize.kBottomOffset
        )
        tabbarBtn.layoutButton(imageTitleSpace: 8)
        let nextBtn = UIButton().text("下一步").textColor(.white).font(14).borderColor(.white).borderWidth(1).cornerRadius(15)
        guideView.sv(nextBtn)
        guideView.layout(
            >=0,
            |-126-nextBtn.width(90).height(30),
            PublicSize.kTabBarHeight+21
        )
        nextBtn.tapped {  [weak self] (btn) in
            guideView.removeFromSuperview()
            self?.tabBarController?.selectedIndex = 3
        }
        
        let guideIV3 = UIImageView().image(#imageLiteral(resourceName: "guide_5_5"))
        guideView.sv(guideIV3)
        guideView.layout(
            >=0,
            |-211.5-guideIV3.width(23).height(16),
            PublicSize.kTabBarHeight+13
        )
    }
    
}
// MARK: - StoreViewModelDelegate
extension StoreViewController: StoreViewModelDelegate {
    
    func toSearchVC() {
        let vc = CurrencySearchController()
        //        if UserData.shared.userType == .cgy {
        //            vc.searchType = .newMaterial
        //        }
        vc.searchString = searchBar.text
        vc.sjsFlag = sjsFlag
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func reloadData() {
        rightCollectionView.mj_header?.endRefreshing()
        leftTableView.hideSkeleton()
        rightCollectionView.hideSkeleton()
        leftTableView.reloadData()
    }
    
    func reloadRightView(_ isFirstItem: Bool) {
        
        if isFirstItem {
            leftTableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .none)
        }
        rightCollectionView.reloadData()
    }
    
    func toDetail(_ withModel: HoStoreModel?, sectionModel: HoStoreModel?) {
        let vc = StoreDetailVC()
        vc.categoryId = withModel?.id
        vc.sjsFlag = sjsFlag
        navigationController?.pushViewController(vc)
    }
}

private extension StoreViewController {
    
    /// UI初始化
    func setupUI() {
        leftTableView = UITableView(frame: CGRect.zero, style: .plain)
        leftTableView.hw_registerCell(cell: StoreTableViewCell.self)
        leftTableView.tableFooterView = UIView()
        leftTableView.separatorStyle = .none
        view?.addSubview(leftTableView!)
        leftTableView.delegate = viewModel
        leftTableView.dataSource = viewModel
        leftTableView.backgroundColor = UIColor.init(netHex: 0xf7f7f7)
        let rowHeight = UIScreen.main.bounds.size.height * 180 / 2436
        leftTableView.rowHeight = rowHeight
        let tableViewWidth = UIScreen.main.bounds.width * 288 / 1125
        leftTableView.snp.makeConstraints({ (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(64)
            }
            make.left.bottom.equalToSuperview()
            make.width.equalTo(tableViewWidth)
        })
        leftTableView.isSkeletonable = true
        //leftTableView.showSkeleton()
        
        let layout = UICollectionViewFlowLayout()
        let itemWidth = UIScreen.main.bounds.width * 180 / 1125
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        rightCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        let leftOffset = UIScreen.main.bounds.width * 62 / 1125
        rightCollectionView.contentInset = UIEdgeInsets(top: 0, left: leftOffset, bottom: 0, right: leftOffset)
        view?.addSubview(rightCollectionView)
        rightCollectionView.delegate = viewModel
        rightCollectionView.dataSource = viewModel
        rightCollectionView.backgroundColor = .white
        rightCollectionView.hw_registerCollectionHeaderView(reusableView: StoreCollectionHeaderView.self)
        rightCollectionView.hw_registerCell(cell: StoreCollectionViewCell.self)
        rightCollectionView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(leftTableView)
            make.left.equalTo(leftTableView.snp.right)
            make.right.equalToSuperview()
        }
        //        rightCollectionView.isSkeletonable = true
        //        rightCollectionView.showSkeleton()
        
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        rightCollectionView.mj_header = header
        
        //搜索栏
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = viewModel
        searchBar.placeholder = "请输入产品名称"
        if sjsFlag {
            self.title = "产品商城"
            self.view.addSubview(searchBar)
            
            searchBar.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.top.equalTo(64)
                }
                make.left.right.equalToSuperview()
            }
            searchBar.sizeToFit()
            
            leftTableView.snp.remakeConstraints({ (make) in
                make.top.equalTo(searchBar.snp.bottom)
                make.left.bottom.equalToSuperview()
                make.width.equalTo(tableViewWidth)
            })
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
        
        
        let scanBtn = UIButton().image(#imageLiteral(resourceName: "scan_icon"))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: scanBtn)
        scanBtn.tapped { [weak self] (btn) in
            let vc = ScanCodeController()
            self?.navigationController?.pushViewController(vc)
        }
    }
    
    
    @objc func headerRefresh() {
        viewModel.loadData()
        leftTableView.showSkeleton()
        rightCollectionView.showSkeleton()
    }
    
    /// 绑定
    func bindValue() {
        viewModel = StoreViewModel()
        viewModel.vc = self
        viewModel.delegate = self
    }
}
