//
//  BrandHouseController.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import MJRefresh

class BrandHouseController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var leftSelectView: SelctItemView!

    var viewModel: BrandHouseViewModel!
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 商城界面释放 <<<<<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = BrandHouseViewModel()
        viewModel.delegate = self
        
        self.title = "品牌馆"
        prepareToolView()
        prepareCollectionView()
        
        collectionView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - 工具栏
    func prepareToolView() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        leftSelectView = SelctItemView(frame: CGRect.zero, scrollDirection: .vertical)
        
        view?.addSubview(leftSelectView!)
        leftSelectView.selectedBlock = viewModel.leftSelectViewBlock
       
        leftSelectView.snp.makeConstraints({ (make) in
            
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(64)
            }
            make.left.bottom.equalToSuperview()
            make.width.equalTo(95)
        })
        
    }
    
    //MARK: - 创建collectionView
    func prepareCollectionView() {
        
        let cellWidth = IS_iPad ? (PublicSize.screenWidth-95-16)/4 : (PublicSize.screenWidth-95-16)/3
        let cellHeight = cellWidth*(160.0/130)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(BrandHouseCell.self, forCellWithReuseIdentifier: BrandHouseCell.description())
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.equalTo(leftSelectView.snp.right)
            make.top.equalTo(leftSelectView.snp.top)
            make.right.bottom.equalToSuperview()
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        collectionView.mj_header = header
    }
    
    
    @objc func headerRefresh() {
        viewModel.headerRefresh()
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return viewModel.itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrandHouseCell.description(), for: indexPath) as! BrandHouseCell

        if let model = viewModel?.item?.brandList?[indexPath.row] {
            cell.merchantModel = model
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selModel = viewModel?.item, let model = selModel.brandList?[indexPath.row] {
            
            if let idStr = model.id {
                
                let urlStr = APIURL.getMerchantIntoDetail + idStr
                let vc = BrandDetailController()
                vc.title = "品牌介绍"
                vc.brandId = model.id
                vc.detailUrl = urlStr
                vc.brandName = model.brandName
                vc.categoryId = selModel.categoryId
                self.navigationController?.pushViewController(vc, animated: true)

            }
        }
    }
    
    
    
}
// MARK: - BrandHouseViewModelDelegate
extension BrandHouseController: BrandHouseViewModelDelegate {
    
    func clearNotice() {
        self.clearAllNotice()
    }
    
    func showWait() {
        self.pleaseWait()
    }
    
    func endRefreshing() {
        self.collectionView.mj_header?.endRefreshing()
    }
    
    func updateUI() {
        self.leftSelectView.itemsData = viewModel.leftDatas
        self.collectionView.reloadData()
    }
    
    func reloadCollectionView() {
        self.collectionView.reloadData()
    }
}

