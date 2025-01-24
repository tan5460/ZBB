//
//  PackageViewController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/2.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper
import Kingfisher

class PlusViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var rowsData: Array<PlusModel> = []
    var curPage = 1
    
    let identifier = "PlusCell"

    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>> 套餐列表界面释放 <<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "所有套餐"
        
        prepareNoDateView("暂无套餐")
        prepareTableView()

        //开始刷新
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 270*PublicSize.RateWidth
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlusCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer = footer
        tableView.mj_footer?.isHidden = true
    }
    
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        
        if rowsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    func loadData() {
        
//        var storeId = ""
//        
//        if let valueStr = UserData.shared.workerModel?.store?.id {
//            storeId = valueStr
//        }
//        
//        AppLog("店铺id: "+storeId)
//        
//        let pageSize = 20
//        
//        let parameters: Parameters = ["store": storeId, "pageSize": "\(pageSize)", "pageNo": "\(self.curPage)"]
//        
//        let urlStr = APIURL.getMaterialsPlus
//        
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//            
//            // 结束刷新
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
//            self.tableView.mj_footer?.isHidden = false
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" || errorCode == "015" {
//                
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                let modelArray = Mapper<PlusModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                    
//                if self.curPage > 1 {
//                    self.rowsData += modelArray
//                }
//                else {
//                    self.rowsData = modelArray
//                }
//                
//                if modelArray.count < pageSize {
//                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//                }else {
//                    self.tableView.mj_footer?.resetNoMoreData()
//                }
//                
//            }else if errorCode == "008" {
//                self.rowsData.removeAll()
//                
//            }
//            
//            self.tableView.reloadData()
//            
//            if self.rowsData.count <= 0 {
//                self.tableView.mj_footer?.isHidden = true
//                self.noDataView.isHidden = false
//            }else {
//                self.noDataView.isHidden = true
//            }
//            
//        }) { (error) in
//            
//            // 结束刷新
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
//            
//            if self.rowsData.count <= 0 {
//                self.tableView.mj_footer?.isHidden = true
//                self.noDataView.isHidden = false
//            }else {
//                
//                self.tableView.mj_footer?.isHidden = false
//                self.noDataView.isHidden = true
//            }
//        }
    }
    
    //MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PlusCell
        
        let model = rowsData[indexPath.row]
        cell.setModelWithTableView(model,tableView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let plusModel = rowsData[indexPath.row]
        let image = UIImage.init(named: "plus_backImage")
        //图片尺寸处理
        let width = PublicSize.screenWidth
        let height = image!.size.height * (width / image!.size.width)
        if let picUrl = plusModel.picUrl {
            let imgUrlStr = APIURL.ossPicUrl + picUrl
            let imageUrl = URL(string: imgUrlStr)
            return XHWebImageAutoSize.imageHeight(for: imageUrl!, layoutWidth: width-20, estimateHeight: height)+40+10
        }
        return height + 40 + 10
    }
    
    func setImageCell(cell: PlusCell, indexPath: IndexPath) -> () {
        //取出对应的图片链接
        let plusModel = rowsData[indexPath.row]
        //SDImageCache取出对应链接缓存的图片
        if let picUrl = plusModel.picUrl {
            let imgUrlStr = APIURL.ossPicUrl + picUrl
            let img = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: imgUrlStr)
            if img != nil {
                cell.packageImageView.image = img
            }else {
                cell.packageImageView.image = UIImage.init(named: "plus_backImage")
                if let imageUrl = URL(string: imgUrlStr) {
                    KingfisherManager.shared.retrieveImage(with: imageUrl, options: nil, progressBlock: nil) { (image, error, casheType, url) in
                        
                        if image != nil {
                            cell.packageImageView.image = image
                            DispatchQueue.main.async {
                                self.tableView.reloadRows(at: [indexPath], with: .none)
                            }
                        }
                    }
                }
            }
            
        }else {
            cell.packageImageView.image = UIImage.init(named: "plus_backImage")
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = PlusDetailsController()
        if let valueStr = rowsData[indexPath.row].id {
            vc.detailUrl = APIURL.getPlusDetails+valueStr
        }
        
        vc.plusModel = self.rowsData[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }

}
