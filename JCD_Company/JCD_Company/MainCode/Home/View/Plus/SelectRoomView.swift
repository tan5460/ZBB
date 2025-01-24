//
//  SelectRoomView.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/5/25.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class SelectRoomView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    var opacityView: UIView!                //蒙版
    var popupView: UIView!                  //弹窗
    var titleLabel: UILabel!                //标题
    var selectAllBtn: UIButton!             //全部
    var selectMaterialBtn: UIButton!        //主材
    var selectServiceBtn: UIButton!         //施工
    var cancelBtn: UIButton!                //取消按钮
    var sureBtn: UIButton!                  //确定按钮
    
    var cancelBlock: (()->())?
    var addRoomBlock: ((_ roomDataArray: Array<PlusDataModel>)->())?
    
    var isFirstLoad = false
    
    var plusModel: PlusModel? {
        
        didSet {
            if plusModel != nil {
                
                selectAllBtn.isHidden = true
                selectMaterialBtn.isHidden = true
                selectServiceBtn.isHidden = true
                
                collectionView.snp.remakeConstraints { (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(15)
                    make.left.equalTo(5)
                    make.right.equalTo(-5)
                    make.bottom.equalTo(sureBtn.snp.top).offset(-10)
                }
            }
        }
    }
    
    let cellIdentifier = "selectRoomCell"
    var itemsData: Array<SelRoomModel> = []
    var collectionView: UICollectionView!
    
    deinit {
        AppLog("添加房间弹窗释放")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        createSubView()
        
        for roomDic in AppData.roomTypeList {
            let model = SelRoomModel()
            model.roomType = Utils.getReadInt(dir: roomDic, field: "value")
            model.roomName = Utils.getReadString(dir: roomDic, field: "label")
            itemsData.append(model)
        }
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //半透明蒙版
        opacityView = UIView()
        opacityView.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        self.addSubview(opacityView)
        
        opacityView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //内容弹窗
        popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 5
        self.addSubview(popupView)
        
        popupView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.width.equalTo(300)
            make.height.equalTo(426)
        }
        
        //标题
        titleLabel = UILabel()
        titleLabel.text = "选择房间"
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .black
        popupView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(12)
        }
        
        //全部按钮
        let btnNormalImg = UIColor.white.image()
        let btnSelectImg = UIColor.colorFromRGB(rgbValue: 0xFFA018).image()
        let btnHighLightedImg = UIColor.init(red: 242.0/255, green: 242.0/255, blue: 242.0/255, alpha: 1).image()
        selectAllBtn = UIButton.init(type: .custom)
        selectAllBtn.isSelected = true
        selectAllBtn.layer.cornerRadius = 11
        selectAllBtn.layer.masksToBounds = true
        selectAllBtn.layer.borderWidth = 0
        selectAllBtn.layer.borderColor = PublicColor.navigationLineColor.cgColor
        selectAllBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        selectAllBtn.setTitle("产品+施工", for: .normal)
        selectAllBtn.setTitleColor(PublicColor.navigationLineColor, for: .normal)
        selectAllBtn.setBackgroundImage(btnNormalImg, for: .normal)
        selectAllBtn.setTitleColor(.white, for: .selected)
        selectAllBtn.setBackgroundImage(btnSelectImg, for: .selected)
        selectAllBtn.setBackgroundImage(btnHighLightedImg, for: .highlighted)
        selectAllBtn.addTarget(self, action: #selector(selectAllAction), for: .touchUpInside)
        popupView.addSubview(selectAllBtn)
        
        selectAllBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(titleLabel.snp.bottom).offset(13)
            make.width.equalTo(80)
            make.height.equalTo(22)
        }
        
        //主材按钮
        selectMaterialBtn = UIButton.init(type: .custom)
        selectMaterialBtn.layer.cornerRadius = selectAllBtn.layer.cornerRadius
        selectMaterialBtn.layer.masksToBounds = true
        selectMaterialBtn.layer.borderWidth = 1
        selectMaterialBtn.layer.borderColor = selectAllBtn.layer.borderColor
        selectMaterialBtn.titleLabel?.font = selectAllBtn.titleLabel?.font
        selectMaterialBtn.setTitle("产品", for: .normal)
        selectMaterialBtn.setTitleColor(PublicColor.navigationLineColor, for: .normal)
        selectMaterialBtn.setBackgroundImage(btnNormalImg, for: .normal)
        selectMaterialBtn.setTitleColor(.white, for: .selected)
        selectMaterialBtn.setBackgroundImage(btnSelectImg, for: .selected)
        selectMaterialBtn.setBackgroundImage(btnHighLightedImg, for: .highlighted)
        selectMaterialBtn.addTarget(self, action: #selector(selectMaterialAction), for: .touchUpInside)
        popupView.addSubview(selectMaterialBtn)
        
        selectMaterialBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.width.height.equalTo(selectAllBtn)
        }
        
        //施工按钮
        selectServiceBtn = UIButton.init(type: .custom)
        selectServiceBtn.layer.cornerRadius = selectAllBtn.layer.cornerRadius
        selectServiceBtn.layer.masksToBounds = true
        selectServiceBtn.layer.borderWidth = 1
        selectServiceBtn.layer.borderColor = selectAllBtn.layer.borderColor
        selectServiceBtn.titleLabel?.font = selectAllBtn.titleLabel?.font
        selectServiceBtn.setTitle("施工", for: .normal)
        selectServiceBtn.setTitleColor(PublicColor.navigationLineColor, for: .normal)
        selectServiceBtn.setBackgroundImage(btnNormalImg, for: .normal)
        selectServiceBtn.setTitleColor(.white, for: .selected)
        selectServiceBtn.setBackgroundImage(btnSelectImg, for: .selected)
        selectServiceBtn.setBackgroundImage(btnHighLightedImg, for: .highlighted)
        selectServiceBtn.addTarget(self, action: #selector(selectServiceAction), for: .touchUpInside)
        popupView.addSubview(selectServiceBtn)
        
        selectServiceBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.width.height.equalTo(selectAllBtn)
        }
        
        //确定
        let redBtnImg = PublicColor.gradualColorImage
        let redHighLightedImg = PublicColor.gradualHightColorImage
        sureBtn = UIButton.init(type: .custom)
        sureBtn.layer.cornerRadius = 17
        sureBtn.layer.masksToBounds = true
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.setBackgroundImage(redBtnImg, for: .normal)
        sureBtn.setBackgroundImage(redHighLightedImg, for: .highlighted)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        popupView.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalTo(selectServiceBtn)
            make.bottom.equalTo(-12)
            make.width.equalTo(120)
            make.height.equalTo(34)
        }
        
        //取消
        cancelBtn = UIButton.init(type: .custom)
        cancelBtn.layer.cornerRadius = 17
        cancelBtn.layer.masksToBounds = true
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = PublicColor.navigationLineColor.cgColor
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
        cancelBtn.setBackgroundImage(btnNormalImg, for: .normal)
        cancelBtn.setBackgroundImage(btnHighLightedImg, for: .highlighted)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        popupView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(selectAllBtn)
            make.centerY.width.height.equalTo(sureBtn)
        }
        
        //房间列表
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 82, height: 90)
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        popupView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(selectAllBtn.snp.bottom).offset(10)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.bottom.equalTo(sureBtn.snp.top).offset(-10)
        }
    }
    
    @objc func selectAllAction() {
        
        selectAllBtn.isSelected = true
        selectMaterialBtn.isSelected = false
        selectServiceBtn.isSelected = false
        selectAllBtn.layer.borderWidth = 0
        selectMaterialBtn.layer.borderWidth = 1
        selectServiceBtn.layer.borderWidth = 1
    }
    
    @objc func selectMaterialAction() {
        
        selectAllBtn.isSelected = false
        selectMaterialBtn.isSelected = true
        selectServiceBtn.isSelected = false
        selectAllBtn.layer.borderWidth = 1
        selectMaterialBtn.layer.borderWidth = 0
        selectServiceBtn.layer.borderWidth = 1
    }
    
    @objc func selectServiceAction() {
        
        selectAllBtn.isSelected = false
        selectMaterialBtn.isSelected = false
        selectServiceBtn.isSelected = true
        selectAllBtn.layer.borderWidth = 1
        selectMaterialBtn.layer.borderWidth = 1
        selectServiceBtn.layer.borderWidth = 0
    }
    
    @objc func cancelAction() {
        
        if isFirstLoad {
            self.isHidden = true
            
            if let block = cancelBlock {
                block()
            }
            
            self.removeFromSuperview()
            
        }else {
            hiddenView()
        }
    }
    
    @objc func sureAction() {
        
        var selRoomArray: Array<SelRoomModel> = []
        
        for model in itemsData {
            if model.roomCount > 0 {
                selRoomArray.append(model)
            }
        }
        
        if selRoomArray.count <= 0 {
            self.noticeOnlyText("请选择房间")
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
        
        if plusModel != nil {
            loadPlusData(roomTypes: roomTypes)
        }else {
            loadFreeData(roomTypes: roomTypes)
        }
    }
    
    func hiddenView() {
        
        if plusModel != nil {
            
            popupView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(self.snp.bottom)
                make.width.equalTo(300)
                make.height.equalTo(400)
            }
        }else {
            
            popupView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(self.snp.bottom)
                make.width.equalTo(300)
                make.height.equalTo(426)
            }
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.1
            self.layoutIfNeeded()
        }) { (finish) in
            self.isHidden = true
        }
    }
    
    func showView() {
        
        titleLabel.text = "添加房间"
        
        for model in itemsData {
            model.roomCount = 0
        }
        
        collectionView.reloadData()
        
        self.alpha = 0
        self.isHidden = false
        isFirstLoad = false
        
        if plusModel != nil {
            
            popupView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(300)
                make.height.equalTo(400)
            }
        }else {
            
            popupView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(300)
                make.height.equalTo(426)
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            
            self.layoutIfNeeded()
            
        }) { (isFinish) in
            
        }
    }
    
    
    //MARK: - 网络请求
    
    //获取套餐数据
    func loadPlusData(roomTypes: String = "") {
        
//        guard let materialsplusID = plusModel?.id else {
//            self.noticeOnlyText("获取套餐信息失败")
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
//                if let block = self.addRoomBlock {
//                    self.hiddenView()
//                    block(modelArray)
//                }
//            }else if errorCode == "011" {
//                self.hiddenView()
//            }
//
//        }) { (error) in
//
//        }
    }
    
    //获取模板数据
    func loadFreeData(roomTypes: String = "") {
        
//        var storeID = ""
//        if let valueStr = UserData.shared.workerModel?.store?.id {
//            storeID = valueStr
//        }
//        
//        var freeType = 1
//        
//        if selectMaterialBtn.isSelected {
//            freeType = 2
//        }else if selectServiceBtn.isSelected {
//            freeType = 3
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
//                if let block = self.addRoomBlock {
//                    self.hiddenView()
//                    block(modelArray)
//                }
//            }else if errorCode == "011" {
//                self.hiddenView()
//            }
//            
//        }) { (error) in
//            
//        }
    }
    
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
//        cell.selRoomModel = itemsData[indexPath.item]
        
        return cell
    }
}
