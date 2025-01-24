//
//  VRDesignController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/29.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper

class VRDesignController: BaseViewController, CollectionWaterLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {

    var rowsData:Array<VRdesignModel> = []
    var collectionView: UICollectionView!
    let identifier = "VRDesignCell"
    var curPage = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "VR设计"
        prepareNoDateView("暂无方案")
        prepareCollectionView()
        
        //开始刷新
        collectionView.mj_header?.beginRefreshing()
    }
    
    func prepareCollectionView() {
        //collectionView
        let layout = CollectionWaterLayout()
        layout.delegate = self
        layout.columnCount = 1
        if IS_iPad {
            layout.columnCount = 2
        }
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(VRDesignCell.self, forCellWithReuseIdentifier: identifier)
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
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
    
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 0
        loadData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        
        if rowsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 0
        }
        loadData()
    }
    
    
    //MARK: - 网络请求
    
    func loadData() {
        
        let userId = UserData.shared.workerModel?.appUid ?? UserData.shared.workerModel?.id ?? ""
        
        let pageSize = 12
        
        let parameters: Parameters = ["userId": userId, "num": "\(pageSize)", "start": "\(self.curPage)"]
        
        let urlStr = APIURL.findAllPlan
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            self.collectionView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
            
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<VRdesignModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage > 0 {
                    self.rowsData += modelArray
                }
                else {
                    self.rowsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.collectionView.mj_footer?.resetNoMoreData()
                }
                
                self.collectionView.reloadData()
                
                if self.rowsData.count <= 0 {
                    self.collectionView.mj_footer?.isHidden = true
                    self.noDataView.isHidden = false
                }else {
                    self.noDataView.isHidden = true
                }
            } else if errorCode == "1" {
                self.noticeOnlyText("当前账号还未开通权限或已被禁用!")
                // 结束刷新
                self.collectionView.mj_header?.endRefreshing()
                self.collectionView.mj_footer?.endRefreshing()
                
                if self.rowsData.count <= 0 {
                    self.collectionView.mj_footer?.isHidden = true
                    self.noDataView.isHidden = false
                }else {
                    self.noDataView.isHidden = true
                }
            } else {
                // 结束刷新
                self.collectionView.mj_header?.endRefreshing()
                self.collectionView.mj_footer?.endRefreshing()
                
                if self.rowsData.count <= 0 {
                    self.collectionView.mj_footer?.isHidden = true
                    self.noDataView.isHidden = false
                }else {
                    self.noDataView.isHidden = true
                }
            }
            
        }) { (error) in
            
            // 结束刷新
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            
            if self.rowsData.count <= 0 {
                self.collectionView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.collectionView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
        }
    }
    
    //获取vr清单id，漫游图链接
    func loadVrDetail(_ vrModel: VRdesignModel) {
        
        let parameters: Parameters = ["designId": vrModel.designId!]
        
        self.pleaseWait()
        let urlStr = APIURL.getPano
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let panoUrl = dataDic["panoLink"] as! String
                let listingId = dataDic["listingId"] as! String
                vrModel.renderpicPanoUrl = panoUrl
                vrModel.listingId = listingId
                
                let vc = VRDetailController()
                vc.vrModel = vrModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if errorCode == "008" {
                self.noticeOnlyText("该方案没有可用渲染图哦~")
            }
            
        }) { (error) in
            
        }
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! VRDesignCell

        let model = rowsData[indexPath.row]
        cell.setModelWithCollectionView(model,collectionView)
        
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vrModel = rowsData[indexPath.row]
        loadVrDetail(vrModel)

    }
    
    func collectionWaterLayout(_ waterFlow: CollectionWaterLayout, heightForItemAt indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        let model = rowsData[indexPath.row]
        
        let image = UIImage.init(named: "loading_vr")
        
        //图片尺寸处理
        let imgHeight = image!.size.height * (itemWidth / image!.size.width)
        
        var h:CGFloat = 15.0
        
        if let str = model.name {
            
            let w = str.getLabWidth(font: UIFont.systemFont(ofSize: 15))
            if w > itemWidth - 20 {
                h  = 30.0
            }
        }
        
        if let mainImgUrl = model.coverPic {

            let imageUrl = URL(string: mainImgUrl)
            return XHWebImageAutoSize.imageHeight(for: imageUrl!, layoutWidth: itemWidth, estimateHeight: imgHeight) + 42 + h
        }

        return imgHeight + 42 + h
    }

}
