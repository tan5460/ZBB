//
//  SureInfoController.swift
//  YZB_Company
//
//  Created by yzb_ios on 13.11.2018.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class SureInfoController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    let cellIdentifier = "sureInfoCell"
    
    var houseModel: HouseModel?
    var plusModel: PlusModel?
    var selRoomArray: Array<SelRoomModel> = []
    var rowsData: Array<MaterialsModel> = []         //套餐内容列表
    
    var freeType = 1                                //自由开单类型： 1.主材+施工 2.主材 3.施工
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "确认信息"
        
        createSubViews()
    }
    
    func createSubViews() {
        
        //下一步
        let nextBtn = UIButton()
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        nextBtn.setTitle("下一步", for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        nextBtn.setTitleColor(UIColor.white, for: .normal)
        nextBtn.setBackgroundImage(backgroundImg, for: .normal)
        nextBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        nextBtn.addTarget(self, action: #selector(nextBtnAction), for: .touchUpInside)
        view.addSubview(nextBtn)
        
        nextBtn.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }else {
                make.bottom.equalToSuperview()
            }
        }
        
        //列表
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = PublicColor.partingLineColor
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.register(NewUserInfoCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(nextBtn.snp.top)
        }
    }
    
    //下一步
    @objc func nextBtnAction() {
        
        if rowsData.count > 0 {
            
            if houseModel == nil {
                self.noticeOnlyText("请选择客户工地")
                return
            }
            
            let vc = PlusOrderController()
         //   vc.rowsData = rowsData
            vc.plusModel = plusModel
            vc.houseModel = houseModel
            navigationController?.pushViewController(vc, animated: true)
            
        }else {
            
            if houseModel == nil {
                self.noticeOnlyText("请选择客户工地")
                return
            }
            
            if selRoomArray.count <= 0 {
                self.noticeOnlyText("请选择户型")
                return
            }
            
            var roomTypes = ""
            
            for i in 0..<selRoomArray.count {
                
                let roomModel = selRoomArray[i]
                
                if let roomType = roomModel.roomType {
                    
                    if i > 0 {
                        roomTypes += "(,)"
                    }
                    
                    for i in 0..<roomModel.roomCount {
                        
                        if i > 0 {
                            roomTypes += "(,)"
                        }
                        
                        roomTypes += "\(roomType)"
                    }
                }
            }
            
            loadPlusData(roomTypes: roomTypes)
        }
    }
    
    
    //MARK: - 网络请求
    
    //获取套餐数据
    func loadPlusData(roomTypes: String = "") {
        
//        guard let materialsplusID = plusModel?.id else {
//            self.noticeOnlyText("获取套餐数据失败")
//            return
//        }
//
//        AppLog("套餐id: "+materialsplusID)
//
//        let parameters: Parameters = ["plus": materialsplusID, "roomTypes": roomTypes, "pageSize": "500"]
//
//        self.pleaseWait()
//        let urlStr =  APIURL.getPlusRoomProList
//
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" {
//
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                var modelArray = Mapper<PlusDataModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//
//                if modelArray.count <= 0 {return}
//
//                _ = modelArray.map({ (plusDataModel) -> () in
//
//                    if plusDataModel.packageList.count > 0 {
//                        plusDataModel.packageList[0].isCheck = true
//                    }
//
//                    for serviceModel in plusDataModel.serviceList {
//                        if serviceModel.cusPrice == nil {
//                            serviceModel.cusPrice = 0
//                        }
//                        serviceModel.category = serviceModel.type
//                    }
//                })
//
//                modelArray = modelArray.sorted(by: { (model1, model2) -> Bool in
//                    return model1.roomType?.intValue ?? 0 < model2.roomType?.intValue ?? 0
//                })
//
//                let vc = PlusOrderController()
//                vc.rowsData = modelArray
//                vc.plusModel = self.plusModel
//                vc.houseModel = self.houseModel
//                vc.title = "套餐开单"
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//
//        }) { (error) in
//
//        }
    }
    
    //获取自由开单数据
    func loadFreeData(roomTypes: String = "") {
        
//        var storeID = ""
//        if let valueStr = UserData.shared.workerModel?.store?.id {
//            storeID = valueStr
//        }
//        
//        let parameters: Parameters = ["store": storeID, "roomTypes": roomTypes, "freeType": freeType, "pageSize": "500"]
//        
//        self.pleaseWait()
//        let urlStr =  APIURL.getFreeTemplate
//        
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" {
//                
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                var modelArray = Mapper<PlusDataModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                
//                modelArray = modelArray.sorted(by: { (model1, model2) -> Bool in
//                    return model1.roomType?.intValue ?? 0 < model2.roomType?.intValue ?? 0
//                })
//                
//            }
//            
//        }) { (error) in
//            
//        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if rowsData.count > 0 {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NewUserInfoCell
        cell.line.isHidden = true
        cell.selectionStyle = .default
        cell.rightLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xB3B3B3)
        
        cell.rightLabel.text = "未选"
        if indexPath.row == 0 {
            cell.leftLabel.text = "选择客户工地"
            
            if let valueStr = houseModel?.custom?.realName {
                cell.rightLabel.text = valueStr
                cell.rightLabel.textColor = PublicColor.commonTextColor
                if let spaceValue = houseModel?.space?.doubleValue {
                    let spaceStr = spaceValue.notRoundingString(afterPoint: 2)
                    cell.rightLabel.text = String.init(format: "%@ %@㎡", valueStr, spaceStr)
                }
            }
        }else if indexPath.row == 1 {
            cell.leftLabel.text = "选择户型"
            
            if selRoomArray.count > 0 {
                //几室
                var roomCount = 0
                //几厅
                var parlourCount = 0
                //几卫
                var toiletCount = 0
                
                for roomModel in selRoomArray {
                    
                    if roomModel.roomType == 1 || roomModel.roomType == 2 || roomModel.roomType == 3 {
                        parlourCount += roomModel.roomCount
                    }
                    if roomModel.roomType == 6 || roomModel.roomType == 7 || roomModel.roomType == 10 || roomModel.roomType == 11 || roomModel.roomType == 12 || roomModel.roomType == 13 || roomModel.roomType == 14 || roomModel.roomType == 15 || roomModel.roomType == 21 {
                        roomCount += roomModel.roomCount
                    }
                    if roomModel.roomType == 5 {
                        toiletCount += roomModel.roomCount
                    }
                }
                cell.rightLabel.text = "\(roomCount)室\(parlourCount)厅\(toiletCount)卫"
                cell.rightLabel.textColor = PublicColor.commonTextColor
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            
            let vc = HouseViewController()
            vc.title = "请选择客户工地"
            vc.houseModel = houseModel
            vc.isOrder = true
            vc.isEditHouse = true
            
            vc.selectedHouseBlock = { [weak self] houseModel in
                self?.houseModel = houseModel
                self?.tableView.reloadData()
            }
            
            navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 1 {
            
            let vc = SelectRoomController()
            vc.selRoomList = selRoomArray
            vc.plusModel = plusModel
            vc.title = "选择户型"
            
            vc.selectedRoomlock = { [weak self] selRoomArray, freeType in
                self?.selRoomArray = selRoomArray
                self?.freeType = freeType
                self?.tableView.reloadData()
            }
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
