//
//  ZBBSubsidyRegionViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/7.
//

import UIKit
import MJRefresh
import ObjectMapper

class ZBBSubsidyRegionViewController: BaseViewController {

    private var collectionView: UICollectionView!
    private var typeView: ZBBSubsidyRegionTypeView!
    private var sortView: ZBBSubsidyRegionSortView!
    private var categoryPopView: ZBBSubsidyRegionCategoryPopView!
    
    private var dataList = [MaterialsModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createView()
        refreshData()
    }
    
    private func createView() {
        
        let layout = CollectionWaterLayout()
        layout.delegate = self
        layout.edgeInsets = UIEdgeInsets(top: 160, left: 10, bottom: 10, right: 10)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(ZBBSubsidyRegionCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        let mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        mj_header.ignoredScrollViewContentInsetTop = -150
        collectionView.mj_header = mj_header
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.loadMoreData()
        })
        
        //
        typeView = ZBBSubsidyRegionTypeView(frame: CGRectMake(0, 0, SCREEN_WIDTH, 110))
        typeView.selectedClosure = {[weak self] typeId in
            if let typeId = typeId {
                self?.categoryPopView.refreshData(for: typeId)
            }
        }
        view.addSubview(typeView)
        
        //
        sortView = ZBBSubsidyRegionSortView(frame: CGRectMake(0, 110, SCREEN_WIDTH, 40))
        sortView.sortTypeActionClosure = {[weak self] in
            self?.refreshData()
        }
        sortView.categoryActionClosure = {[weak self] in
            self?.categoryPopView.show()
        }
        sortView.filterActionClosure = {[weak self] in
            self?.refreshData()
        }
        view.addSubview(sortView)
        
        //
        categoryPopView = ZBBSubsidyRegionCategoryPopView()
        categoryPopView.isHidden = true
        categoryPopView.hideClosure = {[weak self] in
            self?.sortView.isSelectedCategory = false
        }
        view.addSubview(categoryPopView)
        categoryPopView.snp.makeConstraints { make in
            make.top.equalTo(sortView.snp.bottom)
            make.left.bottom.right.equalTo(0)
        }
    }

    

}

extension ZBBSubsidyRegionViewController: UICollectionViewDelegate, UICollectionViewDataSource, CollectionWaterLayoutDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        if offsetY < 0 {
            typeView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 110)
            sortView.frame = CGRectMake(0, 110, SCREEN_WIDTH, 40)
        } else if offsetY <= typeView.height {
            typeView.frame = CGRectMake(0, -offsetY, SCREEN_WIDTH, 110)
            sortView.frame = CGRectMake(0, 110-offsetY, SCREEN_WIDTH, 40)
        } else {
            typeView.frame = CGRectMake(0, -110, SCREEN_WIDTH, 110)
            sortView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZBBSubsidyRegionCollectionViewCell
        cell.model = dataList[indexPath.row]
        return cell
    }
    
    func collectionWaterLayout(_ waterFlow: CollectionWaterLayout, heightForItemAt indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        ZBBSubsidyRegionCollectionViewCell.cellHeight(model: dataList[indexPath.row], width: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MaterialsDetailVC()
        vc.materialsModel = dataList[indexPath.row]
        navigationController?.pushViewController(vc)
    }
}

extension ZBBSubsidyRegionViewController {
    
    private func refreshData() {
        requestDataList(with: 1) {[weak self] list in
            self?.collectionView.mj_header?.endRefreshing()
            self?.page = 1
            self?.dataList.removeAll()
            self?.dataList.append(contentsOf: list ?? [])
            self?.collectionView.reloadData()
            if let list = list, list.count == 0 {
                self?.collectionView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self?.collectionView.mj_footer?.resetNoMoreData()
            }
        }
    }
    
    private func loadMoreData() {
        let page = page + 1
        requestDataList(with: page) {[weak self] list in
            self?.collectionView.mj_footer?.endRefreshing()
            if let list = list {
                self?.page = page
                self?.dataList.append(contentsOf: list)
                self?.collectionView.reloadData()
                if list.count == 0 {
                    self?.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
    private func requestDataList(with page: Int, complete: (([MaterialsModel]?) -> Void)?) {
        var param = Parameters()
        param["current"] = page
        param["size"] = 20
        param["saleType"] = 1

        switch sortView.sortType {
        case .normal:
            param["sortType"] = 4
        case .priceUp:
            param["sortType"] = 3
        case .priceDown:
            param["sortType"] = 2
        }
        
        YZBSign.shared.request(APIURL.getMaterials, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReadDic(data: response as AnyObject, field: "data")
                let records = Utils.getReadArr(data: data, field: "records") as! [Any]
                let list = Mapper<MaterialsModel>().mapArray(JSONArray: records as! [[String : Any]])
                complete?(list)
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
                complete?(nil)
            }
        } failure: { error in
            complete?(nil)
        }

            
    }
}
