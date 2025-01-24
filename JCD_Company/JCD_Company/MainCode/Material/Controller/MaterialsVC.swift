//
//  MaterialsVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/24.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import MJRefresh

class MaterialsVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var type: Int?
    private var collectionView: UICollectionView!
    private let cellIdentifier = "cellIdentifier"
    override func viewDidLoad() {
        super.viewDidLoad()
        switch type {
        case 1:
            title = "新品专区"
        case 2:
            title = "本期主推"
        case 3:
            title = "口碑热销"
        default:
            break
        }
        prepareNoDateView("暂无产品")
        prepareCollectionView()
        mjReloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    func prepareCollectionView() {
        
        let cellWidth = IS_iPad ? (PublicSize.screenWidth-40)/3 : (PublicSize.screenWidth-30)/2
        let cellHeight = cellWidth*(245.0/173)
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
        collectionView.refreshHeader { [weak self] in
            self?.curPage = 1
            self?.loadData()
        }
//        collectionView.refreshFooter { [weak self] in
//            self?.curPage += 1
//            self?.loadData()
//        }
    }
    var hud: MBProgressHUD?
    //刷新列表
    @objc func mjReloadData() {
        
        if collectionView.mj_header?.isRefreshing ?? false {
            collectionView.mj_header?.endRefreshing()
        }
        
        hud = "加载中".textShowLoading()
        headerRefresh()
    }
    
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        loadData()
    }
    private var curPage = 1
    private var itemsData: [MaterialsModel] = []
    //MARK: - 按钮事件
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - 网络请求
    func loadData() {
        
        let pageSize = 50
        var parameters: Parameters = [:]

        parameters["current"] = "\(self.curPage)"
        parameters["size"] = "\(pageSize)"
        parameters["type"] = "\(type ?? 1)"

        let urlStr = APIURL.getMoreMaterials

        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            self.hud?.hide(animated: true)
            //结束刷新
            self.collectionView.mj_header?.endRefreshing()

            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.curPage > 1 {
                    self.itemsData += modelArray
                }
                else {
                    self.itemsData = modelArray
                }
//                if modelArray.count == pageSize {
//                    self.collectionView.endFooterRefresh()
//                } else {
//                    self.collectionView.endFooterRefreshNoMoreData()
//                }
            }else if errorCode == "008" {
                self.itemsData.removeAll()
            }

            self.collectionView.reloadData()

            if self.itemsData.count <= 0 {
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
           // self.collectionView.endFooterRefresh()
        }) { (error) in
            self.hud?.hide(animated: true)
            //结束刷新
            self.collectionView.mj_header?.endRefreshing()
           // self.collectionView.endFooterRefresh()
            if self.itemsData.count <= 0 {
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
        }
    }
    
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MaterialCell
        cell.model = itemsData[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MaterialsDetailVC()
        vc.hidesBottomBarWhenPushed = true
        vc.materialsModel = itemsData[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}
