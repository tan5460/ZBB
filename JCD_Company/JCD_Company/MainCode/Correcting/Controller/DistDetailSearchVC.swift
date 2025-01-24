//
//  DistDetailSearchVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/7.
//

import UIKit
import ObjectMapper

class DistDetailSearchVC: BaseViewController {
    //MARK: - collectionView
    var latitude: String?  // 经度
    var longitude: String? // 纬度
    var searchType: Int?
    var searchName: String?
    private var current = 1
    private var size = 10
    private var collectionView: UICollectionView!
    private var noDataBtn = UIButton()
    private var dataSource: [DistProductionModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = searchName
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
            0,
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
    
    func loadData() {
        var parameters = Parameters()
        parameters["queryStr"] = searchName
        if searchType == 0 {
            parameters["queryType"] = "1"
        } else if searchType == 1 {
            parameters["queryType"] = "2"
        }
        parameters["latitude"] = latitude
        parameters["longitude"] = longitude
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.queryBrandOrProduct, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let queryResultDic = Utils.getReadDic(data: dataDic, field: "queryResult")
                let pageModel = Mapper<PagesModel>().map(JSON: queryResultDic as! [String : Any])
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
                self.collectionView.endHeaderRefresh()
                self.collectionView.reloadData()
                self.noDataBtn.isHidden = self.dataSource.count > 0
            }
        }) { (error) in
            self.collectionView.endHeaderRefresh()
            self.collectionView.endFooterRefresh()
        }
    }

}


extension DistDetailSearchVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: DistDetailCell.self
                                                      , for: indexPath)
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

