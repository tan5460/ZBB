//
//  SelectRoomController.swift
//  YZB_Company
//
//  Created by yzb_ios on 7.11.2018.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class SelectRoomController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var isAddRoom = false
    var isfree = false
    var selectedRoomlock: ((_ selRoomArray: Array<SelRoomModel>, _ orderType: Int)->())?
    var addRoomBlock: ((_ plusDataArray: Array<PlusDataModel>) -> ())?
    var selRoomList: Array<SelRoomModel> = []
    var plusModel: PlusModel?
    
    var topView: UIView!
    var tableView: UITableView!
    var rowsData: Array<SelRoomModel> = []
    let cellIdentifier = "roomNameCell"
    
    var nextBtn: UIButton!                  //下一步
    var selectAllBtn: UIButton!             //全部
    var materialBtn: UIButton!              //主材
    var serviceBtn: UIButton!               //施工
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        prepareRowsData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - 创建TableView
    
    func prepareTableView() {
        
        //列表
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 54
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorColor = PublicColor.partingLineColor
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.tableFooterView = UIView()
        tableView.register(SelectRoomCell.self, forCellReuseIdentifier: cellIdentifier)
        view.addSubview(tableView)
        
        //切换栏
        topView = UIView()
        topView.isHidden = true
        topView.backgroundColor = .white
        topView.layerShadow(color: .black, offsetSize: CGSize(width: 0, height: 1), opacity: 0.1, radius: 2)
        view.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        //主材+施工按钮
        selectAllBtn = UIButton()
        selectAllBtn.isSelected = true
        selectAllBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        selectAllBtn.set(image: UIImage.init(named: "point_normal"), title: "产品+施工", imagePosition: .left, additionalSpacing: 5, state: .normal)
        selectAllBtn.setImage(UIImage.init(named: "point_sel"), for: .selected)
        selectAllBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        selectAllBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
        selectAllBtn.addTarget(self, action: #selector(selectAllAction), for: .touchUpInside)
        topView.addSubview(selectAllBtn)
        
        selectAllBtn.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
        }
        
        //主材按钮
        materialBtn = UIButton.init(type: .custom)
        materialBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        materialBtn.set(image: UIImage.init(named: "point_normal"), title: "产品", imagePosition: .left, additionalSpacing: 5, state: .normal)
        materialBtn.setImage(UIImage.init(named: "point_sel"), for: .selected)
        materialBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        materialBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
        materialBtn.addTarget(self, action: #selector(materialBtnAction), for: .touchUpInside)
        topView.addSubview(materialBtn)
        
        materialBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(selectAllBtn.snp.right)
            make.width.equalTo(selectAllBtn)
        }
        
        //施工按钮
        serviceBtn = UIButton.init(type: .custom)
        serviceBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        serviceBtn.set(image: UIImage.init(named: "point_normal"), title: "施工", imagePosition: .left, additionalSpacing: 5, state: .normal)
        serviceBtn.setImage(UIImage.init(named: "point_sel"), for: .selected)
        serviceBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        serviceBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
        serviceBtn.addTarget(self, action: #selector(serviceBtnAction), for: .touchUpInside)
        topView.addSubview(serviceBtn)
        
        serviceBtn.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview()
            make.left.equalTo(materialBtn.snp.right)
            make.width.equalTo(selectAllBtn)
        }
        
        //下一步
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        nextBtn = UIButton.init(type: .custom)
        nextBtn.setTitle("确定", for: .normal)
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
        
        //表格约束
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(nextBtn.snp.top)
        }
        
        if isAddRoom {
            nextBtn.setTitle("确认", for: .normal)
            
//            topView.isHidden = false
//
//            tableView.snp.remakeConstraints { (make) in
//                make.left.right.equalToSuperview()
//                make.top.equalTo(topView.snp.bottom)
//                make.bottom.equalTo(nextBtn.snp.top)
//            }
        }
    }
    
    //主材+施工
    @objc func selectAllAction() {
        
        selectAllBtn.isSelected = true
        materialBtn.isSelected = false
        serviceBtn.isSelected = false
    }
    
    //主材
    @objc func materialBtnAction() {
        
        selectAllBtn.isSelected = false
        materialBtn.isSelected = true
        serviceBtn.isSelected = false
    }
    
    //施工
    @objc func serviceBtnAction() {
        
        selectAllBtn.isSelected = false
        materialBtn.isSelected = false
        serviceBtn.isSelected = true
    }
    
    //下一步
    @objc func nextBtnAction() {
        
        var selRoomArray: Array<SelRoomModel> = []
        
        for model in rowsData {
            if model.roomCount > 0 {
                selRoomArray.append(model)
            }
        }
        
        if selRoomArray.count <= 0 {
            self.noticeOnlyText("请选择房间")
            return
        }
        
        if isAddRoom {
            
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
            return
        }
        
        if let block = selectedRoomlock {
            
            var freeType = 1
            if materialBtn.isSelected {
                freeType = 2
            }else if serviceBtn.isSelected {
                freeType = 3
            }
            block(selRoomArray, freeType)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - 网络请求
    //获取套餐包含房间
    func prepareRowsData() {
        
//        guard let materialsplusID = plusModel?.id else {
//            self.noticeOnlyText("获取套餐数据失败")
//            return
//        }
//
//        let parameters: Parameters = ["id": materialsplusID, "pageSize": "500"]
//
//        self.pleaseWait()
//        let urlStr =  APIURL.getPlusContainRoom
//
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" {
//
//                let dataArray: [String] = Utils.getReqArr(data: response as AnyObject) as! [String]
//
//                self.rowsData.removeAll()
//                for roomStr in dataArray {
//
//                    for roomDic in AppData.roomTypeList {
//
//                        if roomStr == Utils.getReadString(dir: roomDic, field: "value") {
//
//                            let model = SelRoomModel()
//                            model.roomType = Utils.getReadInt(dir: roomDic, field: "value")
//                            model.roomName = Utils.getReadString(dir: roomDic, field: "label")
//                            self.rowsData.append(model)
//
//                            if !self.isAddRoom {
//
//                                let equalRoom = self.selRoomList.filter{$0.roomType==model.roomType}
//                                if let roomCount = equalRoom.first?.roomCount {
//                                    model.roomCount = roomCount
//                                }
//                            }
//
//                            break
//                        }
//                    }
//                }
//                self.tableView.reloadData()
//            }
//
//        }) { (error) in
//
//        }
    }
    
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
//                let modelArray = Mapper<PlusDataModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
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
//                if let block = self.addRoomBlock {
//                    block(modelArray)
//                }
//                self.navigationController?.popViewController(animated: true)
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
//                let modelArray = Mapper<PlusDataModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//
//                let vc = PlusOrderController()
//                vc.rowsData = modelArray
//                vc.title = "自由开单"
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//
//        }) { (error) in
//
//        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SelectRoomCell
        cell.selRoomModel = rowsData[indexPath.row]
        
        return cell
    }
}
