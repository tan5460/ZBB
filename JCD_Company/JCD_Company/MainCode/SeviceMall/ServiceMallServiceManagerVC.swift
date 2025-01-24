//
//  ServiceMallServiceManagerVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/15.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh
import ObjectMapper


class ServiceMallServiceManagerVC: BaseViewController {

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hideShadowImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.showShadowImage()
    }
    
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "服务管理"
        configTableView()
    }
    
    func configTableView()  {
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
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        tableView.mj_header = MJRefreshGifCustomHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_footer = MJRefreshAutoNormalFooter()
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        prepareNoDateView("暂无数据")
        noDataView.isHidden = true
        loadData()
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
        parameters["isOneSell"] = ""
        if categoryId != nil {
            parameters["category"] = categoryId!
        }
        parameters["substationId"] = substationId
        
        AppLog(">>>>>>>>>>>>> 分类筛选: \(parameters)")
        
        let urlStr = APIURL.getMaterials
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            //结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
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
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.itemsData.removeAll()
            }
            
            self.tableView.reloadData()
            
            if self.itemsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
            
        }) { (error) in
            
            //结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            
            if self.itemsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.tableView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
        }
    }
    
    @objc func headerRefresh() {
        tableView.mj_footer?.resetNoMoreData()
        curPage = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        curPage += 1
        loadData()
    }

}


extension ServiceMallServiceManagerVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        cell.selectionStyle = .none
        let v = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
        cell.sv(v)
        cell.layout(
            10,
            |-14-v-14-| ~ 138.5,
            0
        )
        configCell(v, indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 148.5
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
    
    func configCell(_ v: UIView, _ indexPath: IndexPath) {
        let model = itemsData[indexPath.row]
        let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
        if !icon.addImage(model.imageUrl) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        let title = UILabel().text(model.name ?? "").textColor(.kColor33).font(14).numberOfLines(2)
        title.lineSpace(2)
        let price = UILabel().text("¥\(model.priceSupplyMin1?.doubleValue ?? 0)/次").textColor(.kDF2F2F).font(12)
        let saleNum = UILabel().text("已售\(model.sellNum ?? 0)单").textColor(.kColor33).font(12)
        let line = UIView().backgroundColor(.kColor220)
        let downBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_down")).text(" 下架").textColor(.kColor66).font(12)
        downBtn.isHidden = true
        if model.upperFlag == "1" {
            downBtn.text(" 下架")
        } else {
            downBtn.text(" 上架")
        }
        let previewBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_preview")).text(" 预览").textColor(.kColor66).font(12)
        icon.contentMode = .scaleAspectFit
        icon.cornerRadius(2).masksToBounds()
        v.sv(icon, title, price, saleNum, line, downBtn, previewBtn)
        v.layout(
            15,
            |-15-icon.width(100).height(72),
            10,
            |-15-line-15-| ~ 0.5,
            0,
            downBtn.width(70).height(41.5)-0-previewBtn.width(70).height(41.5)|,
            0
        )
        v.layout(
            15,
            |-125-title-15-|,
            >=0,
            |-125-price.height(16.5)-(>=0)-saleNum.height(16.5)-15-|,
            51.5
        )
        downBtn.tag = indexPath.row
        previewBtn.tag = indexPath.row
        downBtn.addTarget(self, action: #selector(downBtnClick(btn:)))
        previewBtn.addTarget(self, action: #selector(previewBtnClick(btn:)))
    }
}

// MARK: - 按钮点击方法
extension ServiceMallServiceManagerVC {
    @objc private func downBtnClick(btn: UIButton) {
        let model1 = self.itemsData[btn.tag]
        var message = "是否确认下架该服务"
        if model1.upperFlag == "1" {
            message = "是否确认下架该服务"
        } else {
            message = "是否确认上架该服务"
        }
        let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
            
            var parameters = Parameters()
            parameters["id"] = model1.id
            if model1.upperFlag ==  "1" {
                parameters["upperFlag"] = 0
            } else {
                parameters["upperFlag"] = 1
            }
            YZBSign.shared.request(APIURL.updUpperFlag, method: .put, parameters: parameters,  success: { (response) in
                let model = BaseModel.deserialize(from: response)
                if model?.code == 0 {
                    if model1.upperFlag ==  "1" {
                        self.noticeOnlyText("下架成功")
                    } else {
                        self.noticeOnlyText("上架成功")
                    }
                    self.loadData()
                }
            }) { (error) in
                
            }
        }))
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc private func previewBtnClick(btn: UIButton) {
        let vc = MaterialsDetailVC()
        vc.materialsModel = itemsData[btn.tag]
        navigationController?.pushViewController(vc)
    }
}
