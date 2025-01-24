//
//  CustomerViewController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/28.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import MJRefresh
import ObjectMapper
import PopupDialog


class HouseViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var houseModel: HouseModel?                         //选中的工地
    var isEditHouse = false                             //是否编辑工地
    var isOrder = false                                 //是否是下单
    var activityType: Int = 1
    var tableView: UITableView!
    var curPage = 1                                     //页码
    var isOnekey: Bool = false
    var rowsData: Array<HouseModel> = []
    
    var selectedHouseBlock: ((_ houseModel: HouseModel?)->())?      //选择工地block
    
    let identifier = "customerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationItem()
        prepareNoDateView("暂无客户工地")
        prepareTableView()
         
        //开始刷新
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !(tableView.mj_header?.isRefreshing  ?? false) {
            self.pleaseWait()
            headerRefresh()
        }
    }
    
    func prepareNavigationItem() {
        
        //新增
        let addBtn = UIButton(type: .custom)
        addBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        addBtn.setTitle("添加", for: .normal)
        addBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        addBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        addBtn.addTarget(self, action: #selector(addNewAction), for: .touchUpInside)
        
        let addItem = UIBarButtonItem.init(customView: addBtn)
        navigationItem.rightBarButtonItems = [addItem]
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 156
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        tableView.register(HouseCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        if UserData.shared.userType == .cgy || activityType == 2 || activityType == 3 {
            tableView.register(SelectHouseCell.self, forCellReuseIdentifier: SelectHouseCell.self.description())
        }
        
        // 下拉刷新
        tableView.refreshHeader { [weak self] in
            self?.headerRefresh()
        }
        //上拉加载
        tableView.refreshFooter { [weak self] in
            self?.footerRefresh()
        }
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
    
    //MARK: - 加载数据
    func loadData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeID = valueStr
        }
        var jobType = ""
        if let valueStr = UserData.shared.workerModel?.jobType?.stringValue {
            jobType = valueStr
        }
        
        let pageSize = 20
        var parameters: Parameters = [
            "size": "\(pageSize)",
            "current": "\(self.curPage)",
            "store.id": storeID,
            "workerId": userId,
            "jobType": jobType]
        
        if isOrder == false {
            if UserData.shared.workerModel?.jobType == 4 || UserData.shared.workerModel?.jobType == 999 {
                parameters.removeValue(forKey: "workerId")
            }
        }
      
        let urlStr = APIURL.getHouseList
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<HouseModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage == 1 {
                    self.rowsData.removeAll()
                    if let houseModel = self.houseModel {
                        self.rowsData.append(houseModel)
                    }
                }
                
                for model in modelArray {
                    
                    if let houseModel = self.houseModel {
                        if model.id != houseModel.id {
                            self.rowsData.append(model)
                        }else {
                            self.houseModel = model
                            self.rowsData[0] = model
                            self.selectedHouseBlock?(model)
                        }
                    }else {
                        self.rowsData.append(model)
                    }
                }
                
                if modelArray.count < pageSize {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.rowsData.removeAll()
            }
            
            self.tableView.reloadData()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
            
        }) { (error) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.tableView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
        }
    }
     
    
    //MARK: - 新增客户
    @objc func addNewAction() {
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeID = valueStr
        }
        var jobType = ""
        if let valueStr = UserData.shared.workerModel?.jobType?.stringValue {
            jobType = valueStr
        }
        
        let parameters: Parameters = ["size": "1", "current": "\(self.curPage)", "storeId": storeID, "workerId": userId, "jobType": jobType]
        self.pleaseWait()
        
        let urlStr =  APIURL.getCompanyCustom
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            var modelArray:Array<CustomModel> = []
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                modelArray = Mapper<CustomModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
            }else if errorCode == "008" {
               
            }
            
            if modelArray.count <= 0 {
                let vc = AddHousesController()
                vc.title = "添加客户工地"
                vc.selectedHouseBlock = { [weak self] (houseModel) in
                    self?.selectedHouseBlock?(houseModel)
                }
                self.navigationController?.pushViewController(vc, animated: true)
              
            }else {
                
                let vc = MyCustomController()
                vc.title = "选择客户"
                vc.selectedHouseBlock = { [weak self] (houseModel) in
                    self?.selectedHouseBlock?(houseModel)
                }
                vc.isSelectCustom = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }) { (error) in
           
        }
        
    }
    
    //MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (UserData.shared.userType == .cgy || activityType == 2 || activityType == 3) && isOnekey == false {
           let cell = tableView.dequeueReusableCell(withIdentifier: SelectHouseCell.self.description(), for: indexPath) as! SelectHouseCell
            cell.containerView.backgroundColor(.white)
            cell.containerView.borderColor(.white).borderWidth(0.5)
            cell.selectLabel.isHidden = true
            
            var cellModel = rowsData[indexPath.row]
            
            cell.houseModel = cellModel
            
            if houseModel != nil && indexPath.row == 0 {
                cell.containerView.backgroundColor(UIColor.hexColor("#ECFFFA"))
                cell.containerView.borderColor(.k1DC597).borderWidth(0.5)
                cell.selectLabel.isHidden = false
            }
            
            //编辑
            cell.editHouseBlock = { [weak self] in
                
                let vc = AddHousesController()
                vc.title = "修改客户工地信息"
                vc.houseModel = cellModel
                
                if self?.houseModel != nil && indexPath.row == 0 {
                    
                    vc.modifyHouseBlock = { [weak self] houseModel in
                        cellModel = houseModel
                        self?.houseModel = houseModel
                        
                        if let block = self?.selectedHouseBlock {
                            block(houseModel)
                        }
                    }
                }
                
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            
            //删除
            cell.deleteBlock = { [weak self] in
                
                let popup = PopupDialog(title: "是否删除该工地?", message: nil,buttonAlignment: .horizontal)
                let sureBtn = DestructiveButton(title: "删除") {
                    
                    let parameters: Parameters = ["id": cellModel.id!]
                    
                    self?.pleaseWait()
                    let urlStr = APIURL.delHouse + "\(cellModel.id ?? "")"
                    
                    YZBSign.shared.request(urlStr, method: .delete, parameters: parameters, success: { (response) in
                        
                        let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                        if errorCode == "0" {
                            self?.rowsData.remove(at: indexPath.row)
                            self?.tableView.reloadData()
                            self?.noticeSuccess("删除成功")
                            
                            if (self?.rowsData.count)! <= 0 {
                                self?.tableView.mj_footer?.isHidden = true
                                self?.noDataView.isHidden = false
                            }else {
                                self?.tableView.mj_footer?.isHidden = false
                                self?.noDataView.isHidden = true
                            }
                            if self?.houseModel != nil && indexPath.row == 0 {
                                
                                self?.houseModel = nil
                                
                                if let block = self?.selectedHouseBlock {
                                    block(nil)
                                }
                            }
                        }
                        
                    }) { (error) in
                        
                    }
                }
                let cancelBtn = CancelButton(title: "取消") {
                    
                }
                popup.addButtons([cancelBtn,sureBtn])
                self?.present(popup, animated: true, completion: nil)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! HouseCell
        cell.selectedLabel.isHidden = true
        cell.nameLabel.textColor = .black
        cell.phoneLabel.textColor = .black
        
        var cellModel = rowsData[indexPath.row]
        cell.houseModel = cellModel
        	
        if houseModel != nil && indexPath.row == 0 {
            
            cell.selectedLabel.isHidden = false
            cell.nameLabel.textColor = PublicColor.emphasizeTextColor
            cell.phoneLabel.textColor = PublicColor.emphasizeTextColor
        }
        
        //编辑
        cell.editHouseBlock = { [weak self] in

            let vc = AddHousesController()
            vc.title = "修改客户工地信息"
            vc.houseModel = cellModel

            if self?.houseModel != nil && indexPath.row == 0 {

                vc.modifyHouseBlock = { [weak self] houseModel in
                    cellModel = houseModel
                    self?.houseModel = houseModel

                    if let block = self?.selectedHouseBlock {
                        block(houseModel)
                    }
                }
            }

            self?.navigationController?.pushViewController(vc, animated: true)
        }

        //删除
        cell.deleteBlock = { [weak self] in

            let popup = PopupDialog(title: "是否删除该工地?", message: nil,buttonAlignment: .horizontal)
            let sureBtn = DestructiveButton(title: "删除") {

                let parameters: Parameters = ["id": cellModel.id!]

                self?.pleaseWait()
                let urlStr = APIURL.delHouse + "\(cellModel.id ?? "")"

                YZBSign.shared.request(urlStr, method: .delete, parameters: parameters, success: { (response) in

                    let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                    if errorCode == "0" {
                        self?.rowsData.remove(at: indexPath.row)
                        self?.tableView.reloadData()
                        self?.noticeSuccess("删除成功")

                        if (self?.rowsData.count)! <= 0 {
                            self?.tableView.mj_footer?.isHidden = true
                            self?.noDataView.isHidden = false
                        }else {
                            self?.tableView.mj_footer?.isHidden = false
                            self?.noDataView.isHidden = true
                        }
                        if self?.houseModel != nil && indexPath.row == 0 {

                            self?.houseModel = nil

                            if let block = self?.selectedHouseBlock {
                                block(nil)
                            }
                        }
                    }

                }) { (error) in

                }
            }
            let cancelBtn = CancelButton(title: "取消") {

            }
            popup.addButtons([cancelBtn,sureBtn])
            self?.present(popup, animated: true, completion: nil)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if isEditHouse {
            
            let model = self.rowsData[indexPath.row]
            if (UserData.shared.userType == .cgy || activityType == 2 || activityType == 3) && isOnekey == false   {
                
                if model.expressName != nil && model.expressTel != nil && model.expressAdd != nil && !(model.expressName?.isEmpty ?? false) && !(model.expressTel?.isEmpty ?? false) && !(model.expressAdd?.isEmpty ?? false) &&  !(model.shippingAddress?.isEmpty ?? false) && model.provinceId != nil && model.cityId != nil && model.areaId != nil {
                    if let block = selectedHouseBlock {
                        block(model)
                    }
                    self.navigationController?.popViewController(animated: true)
                }else {
                    let popup = PopupDialog(title: "请补全收货信息", message: nil,buttonAlignment: .horizontal)
                    let sureBtn = DestructiveButton(title: "确认") {
                        let vc = AddHousesController()
                        vc.acitivityType = self.activityType
                        vc.title = "修改客户工地信息"
                        vc.houseModel = model
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    }
                    let cancelBtn = CancelButton(title: "取消") {
                        
                    }
                    popup.addButtons([cancelBtn,sureBtn])
                    self.present(popup, animated: true, completion: nil)
                }
            }else {
                if let block = selectedHouseBlock {
                    block(model)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }else {
            
            let cellModel = rowsData[indexPath.row]
            
            let vc = AddHousesController()
            vc.title = "修改客户工地信息"
            vc.houseModel = cellModel
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
