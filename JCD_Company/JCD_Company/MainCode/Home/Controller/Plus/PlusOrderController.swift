//
//  PlusOrderController.swift
//  YZB_Company
//
//  Created by yzb_ios on 14.11.2018.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import ObjectMapper
import Kingfisher

class PlusOrderController: BaseViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var plusMaterialArray: Array<PlusMaterialModel> = []
    var rowsData: Array<PlusDataModel> = []             //套餐内容列表
    var orderId = ""                                    //订单Id
    var isShowHint = false                              //是否已经卫生间多件套提示
    var isClickButton = false                           //是否是点击按钮改变按钮状态
    var selBtnTag = 100                                 //选中房间的tag
    var totalValue: Double = 0                          //订单总价
    var selPackageId = ""                               //选中主材包id
    var brandLastY: CGFloat = 40                        //品牌视图最终高度
    var selBrandStr = "全部品牌"                          //选中品牌的名字
    var isBrandOpen = false                              //品牌筛选是否展开
    
    var packageCellId = "orderPackageCell"
    var materialCellId = "orderMaterialCell"
    var plusModel: PlusModel?                           //套餐
    var houseModel: HouseModel?                         //工地
    
    var topBarView: UIView!                             //顶部条
    var roomScrollerView: UIScrollView!                 //房间滚动视图
    var followView: UIView!                             //跟随条
    var contentScrollerView: UIScrollView!              //内容h滚动视图
    
    var bottomView: UIView!                             //底部栏
    var surePayBtn: UIButton!                           //保存订单
    var orderPriceLabel: UILabel!                       //订单总价
    var materialPriceLabel: UILabel!                    //主材价
    var servicePriceLabel: UILabel!                     //施工价
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>> 套餐开单页面释放 <<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        prepareNavItem()
        prepareBottomView()
        prepareScrollerView()
        prepareContentView()
        guard let leftTableView = contentScrollerView.viewWithTag((selBtnTag-100+1)*1000+1) as? UITableView else {
            return
        }
        leftTableView.reloadData()
        
        guard let rightTableView = contentScrollerView.viewWithTag((selBtnTag-100+1)*1000+2) as? UITableView else {
            return
        }
        rightTableView.reloadData()
        
        getAllPrice()
        updateRoomBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
      
        
//        if !isShowHint {
//
//            let roomList = rowsData.filter {$0.roomType==6}
//            if roomList.count > 0 {
//                isShowHint = true
//
//                let popup = PopupDialog(title: "提示", message: "'卫生间'如果包含卫浴多件套时，请注意'龙头'、'浴室柜'、'马桶'、'花洒'不要重复选择！")
//                let sureBtn = AlertButton(title: "确定") {}
//                popup.addButtons([sureBtn])
//                self.present(popup, animated: true, completion: nil)
//            }
//        }
    }
    
    
    //MARK: - 初始化
    
    func prepareContentView() {
        
        _ = roomScrollerView.subviews.map {$0.removeFromSuperview()}
        _ = contentScrollerView.subviews.map {$0.removeFromSuperview()}
        roomScrollerView.addSubview(followView)
        selBtnTag = 100
        roomScrollerView.contentOffset = CGPoint(x: -10, y: 0)
        contentScrollerView.contentOffset = CGPoint.zero
        
        selPackageId = ""
        if let packageModel = rowsData.first?.packageList.first {
            _ = rowsData.first?.packageList.map { $0.isCheck = false }
            packageModel.isCheck = true
            selPackageId = packageModel.id!
        }
        
        //循环创建
        var sumWidth: CGFloat = 0
        for (i, model) in rowsData.enumerated() {
            
            let roomModel = SelRoomModel()
            roomModel.roomType = model.roomType?.intValue
            roomModel.roomName = "房间名"
            
            if let valueStr = roomModel.roomType {
                roomModel.roomName = Utils.getFieldValInDirArr(arr: AppData.roomTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
                
                var index = 0
                var sumCount = 0
                for dataModel in rowsData {
                    
                    if model == dataModel {
                        break
                    }
                    if dataModel.roomType?.intValue == valueStr {
                        index += 1
                    }
                }
                
                for dataModel in rowsData {
                    
                    if dataModel.roomType?.intValue == valueStr {
                        sumCount += 1
                    }
                }
                
                if index >= 0 && sumCount > 1 && index < LetterPrefixArray.count {
                    roomModel.roomName = roomModel.roomName! + LetterPrefixArray[index]
                }
            }
            
            let roomFont = UIFont.systemFont(ofSize: 14)
            let roomWidth = roomModel.roomName!.getLabWidth(font: roomFont) + 30
            
            //房间按钮
            let roomBtn = UIButton.init(frame: CGRect(x: sumWidth, y: 0, width: roomWidth, height: 44))
            roomBtn.tag = 100+i
            roomBtn.titleLabel?.font = roomFont
            roomBtn.setTitle(roomModel.roomName, for: .normal)
            roomBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
            roomBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
            roomBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0xB3B3B3), for: .highlighted)
            roomBtn.addTarget(self, action: #selector(roomBtnAction), for: .touchUpInside)
            roomScrollerView.addSubview(roomBtn)
            
            sumWidth += roomWidth
            if i == 0 {
                roomBtn.isSelected = true
                followView.frame = CGRect(x: 0, y: roomBtn.bottom-2, width: roomWidth-14, height: 2)
                followView.centerX = roomBtn.centerX
            }
            
            if i == rowsData.count-1 {
                roomScrollerView.contentSize = CGSize(width: roomBtn.right, height: 0)
            }
            
            //内容列表
            let bgView = UIView()
            bgView.tag = (i+1) * 1000
            contentScrollerView.addSubview(bgView)
            
            bgView.snp.makeConstraints { (make) in
                make.top.height.bottom.equalToSuperview()
                make.width.equalTo(PublicSize.screenWidth)
                make.left.equalToSuperview().offset(PublicSize.screenWidth*CGFloat(i))
                if i == rowsData.count - 1 {
                    make.right.equalToSuperview()
                }
            }
            
            //主材包列表
            let packageTableView = UITableView()
            packageTableView.tag = bgView.tag + 1
            packageTableView.backgroundColor = PublicColor.backgroundViewColor
            packageTableView.delegate = self
            packageTableView.dataSource = self
            packageTableView.separatorStyle = .none
            packageTableView.rowHeight = 49
            packageTableView.tableFooterView = UIView()
            packageTableView.register(OrderPackageCell.self, forCellReuseIdentifier: packageCellId)
            bgView.addSubview(packageTableView)
            
            packageTableView.snp.makeConstraints { (make) in
                make.left.top.bottom.equalToSuperview()
                make.width.equalTo(83)
            }
            
            //主材施工列表
            let dataTableView = UITableView()
            dataTableView.tag = bgView.tag + 2
            dataTableView.delegate = self
            dataTableView.dataSource = self
            dataTableView.separatorStyle = .none
            dataTableView.estimatedRowHeight = 95
            dataTableView.tableFooterView = UIView()
            dataTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
            dataTableView.register(OrderMaterialCell.self, forCellReuseIdentifier: materialCellId)
            bgView.addSubview(dataTableView)
            
            dataTableView.snp.makeConstraints { (make) in
                make.right.top.bottom.equalToSuperview()
                make.left.equalTo(packageTableView.snp.right)
            }
        }
        
        //选中项初始化值
        if let package = rowsData.first?.packageList.first {
            loadPackageMaterial(package.id!)
        }else {
            selPackageId = ""
        }
    }
    
    //刷新房间按钮显示状态
    func updateRoomBtn() {
        
        let subViews = roomScrollerView.subviews
        
        for roomBtn in subViews {
            
            if roomBtn is UIButton {
                
                let index = roomBtn.tag - 100
                let roomModel = rowsData[index]
                var isAllSel = true
                
                for packageModel in roomModel.packageList {
                    if packageModel.materials == nil {
                        isAllSel = false
                    }
                }
                
                if roomModel.serviceList.count <= 0 {
                    isAllSel = false
                }
                
                let roomTitle = (roomBtn as! UIButton).titleLabel?.text
                if isAllSel {
                    (roomBtn as! UIButton).set(image: UIImage.init(named: "order_room_sel"), title: roomTitle!, imagePosition: .right, additionalSpacing: 2, state: .normal)
                }else {
                    (roomBtn as! UIButton).set(image: nil, title: roomTitle!, imagePosition: .right, additionalSpacing: 0, state: .normal)
                }
                
            }
        }
    }
    
    
    //MARK: - 按钮事件
    
    @objc func backAction() {
        
        //收起键盘
        UIApplication.shared.keyWindow?.endEditing(true)
        
        if orderId == "" {
            
            let popup = PopupDialog(title: "提示", message: "下单未完成，退出后将无法继续下单！",buttonAlignment: .horizontal, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
            let exitlBtn = DestructiveButton(title: "退出") {
                self.navigationController?.popViewController(animated: true)
            }
            let cancelBtn = CancelButton(title: "取消") {
                
            }
            popup.addButtons([cancelBtn,exitlBtn])
            self.present(popup, animated: true, completion: nil)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    //编辑
    @objc func editAction() {
        
        let plusVC = PlusOrderEditController()
        plusVC.rowsData = rowsData
        plusVC.delBlock = { [weak self] rowsData, delType in
            
            self?.rowsData = rowsData
            self?.getAllPrice()
            
            if delType == 1 {
                //删除房间
                self?.prepareContentView()
            }else {
                //删除项
                self?.selPackageId = ""
                let dateModel = self!.rowsData[self!.selBtnTag-100]
                if let packageModel = dateModel.packageList.first {
                    _ = dateModel.packageList.map { $0.isCheck = false }
                    packageModel.isCheck = true
                    self?.selPackageId = packageModel.id!
                }
                
                guard let leftTableView = self?.contentScrollerView.viewWithTag((self!.selBtnTag-100+1)*1000+1) as? UITableView else {
                    return
                }
                leftTableView.reloadData()
                
                guard let rightTableView = self?.contentScrollerView.viewWithTag((self!.selBtnTag-100+1)*1000+2) as? UITableView else {
                    return
                }
                rightTableView.reloadData()
            }
            
            //刷新按钮状态
            self?.updateRoomBtn()
        }
        plusVC.doneBlock = { [weak self] in
            
            if self!.rowsData.count <= 0 {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        self.present(plusVC, animated: true, completion: nil)
    }
    
    //添加
    @objc func addRoomAction() {
        
        let addServiceBlock: ((_ serviceModel: ServiceModel)->()) = { [weak self] serviceModel in
            
            let roomIndex = self!.selBtnTag-100
            let dataModel = self!.rowsData[roomIndex]
            _ = dataModel.packageList.map { $0.isCheck = false }
            self?.selPackageId = ""
            
            for model in dataModel.serviceList {
                if model.id == serviceModel.id && serviceModel.id != "S001" {
                    self?.noticeOnlyText("已添加")
                    return
                }
            }
            
            if serviceModel.cusPrice == nil {
                serviceModel.cusPrice = 0
            }
            
            if serviceModel.serviceType == 2 {
                serviceModel.remarks = "常规施工 (套餐外)"
                self?.noticeSuccess("添加成功")
            }else if serviceModel.serviceType == 3 {
                serviceModel.remarks = "升级项施工 (套餐内)"
                self?.noticeSuccess("添加成功")
            }
            dataModel.serviceList.insert(serviceModel, at: 0)
        }
        
        let popup = PopupDialog(title: "请选择添加内容", message: nil, buttonAlignment: .vertical)
        
        let addBtn0 = AlertButton(title: "添加房间") {
            
            let vc = SelectRoomController()
            vc.title = "添加房间"
            vc.isAddRoom = true
            vc.plusModel = self.plusModel
            
            vc.addRoomBlock = { [weak self] plusDataArray in
                
                for addModel in plusDataArray {
                    for (i, oldModel) in self!.rowsData.enumerated() {
                        if let addValue = addModel.roomType?.intValue, let oldValue = oldModel.roomType?.intValue {
                            if addValue < oldValue {
                                self?.rowsData.insert(addModel, at: i)
                                break
                            }
                        }
                    }
                    
                    if !self!.rowsData.contains(addModel) {
                        self?.rowsData.append(addModel)
                    }
                }
                
                self?.prepareContentView()
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let addBtn1 = AlertButton(title: "商城产品 (套餐外)") {
            
            let vc = MaterialViewController()
            vc.isAddMaterial = true
            
            vc.addMaterialBlock = { [weak self] materialModel in
                
                //添加主材
                let packageModel = PackageModel()
                packageModel.id = "A001"
                packageModel.packageType = 2
                packageModel.materials = materialModel
                self?.selPackageId = packageModel.id!
                
                var categoryName = ""
                if let valeStr = materialModel.categoryd?.name {
                    categoryName = valeStr
                }
                else if let valeStr = materialModel.categoryc?.name {
                    categoryName = valeStr
                }
                else if let valeStr = materialModel.categoryb?.name {
                    categoryName = valeStr
                }
                else if let valeStr = materialModel.categorya?.name {
                   categoryName = valeStr
                }
                else if let valeStr = materialModel.categorys?.name {
                    categoryName = valeStr
                }
                packageModel.name = categoryName
                
                let roomIndex = self!.selBtnTag-100
                let dataModel = self!.rowsData[roomIndex]
                _ = dataModel.packageList.map { $0.isCheck = false }
                packageModel.isCheck = true
                
                for model in dataModel.packageList {
                    if model.materials?.id == materialModel.id {
                        model.isCheck = true
                        self?.selPackageId = model.id!
                        self?.noticeOnlyText("已添加")
                        return
                    }
                }
                
                self?.noticeSuccess("添加成功")
                dataModel.packageList.append(packageModel)
            }
            
            let navVC = BaseNavigationController.init(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }

        let addBtn2 = AlertButton(title: "临时创建产品 (套餐外)") {

            let vc = AddSelfMaterialController()
            vc.title = "临时创建产品 (套餐外)"

            vc.addPackageBlock = { [weak self] packageModel in
                
                let roomIndex = self!.selBtnTag-100
                if let dataModel = self?.rowsData[roomIndex] {
                    
                    _ = dataModel.packageList.map { $0.isCheck = false }
                    packageModel.isCheck = true
                    packageModel.roomType = dataModel.roomType
                    dataModel.packageList.append(packageModel)
                    self?.selPackageId = packageModel.id!
                }
            }

            let viewController = BaseNavigationController.init(rootViewController: vc)
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }
        let addBtn3 = AlertButton(title: "常规施工 (套餐外)") {

            let vc = ServiceViewController()
            vc.addServiceType = .AddRoutine
            vc.addServiceBlock = addServiceBlock

            let navVC = BaseNavigationController.init(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        let addBtn4 = AlertButton(title: "升级项施工 (套餐内)") {

            let vc = ServiceViewController()
            vc.addServiceType = .AddCheapen
            vc.addServiceBlock = addServiceBlock

            let navVC = BaseNavigationController.init(rootViewController: vc)
            self.navigationController?.present(navVC, animated: true, completion: nil)
        }
        let addBtn5 = AlertButton(title: "临时创建施工 (套餐外)") {

            let vc = AddServiceController()
            vc.title = "临时创建施工 (套餐外)"
            vc.isFreeAdd = true
            vc.addServiceBlock = addServiceBlock

            let viewController = BaseNavigationController.init(rootViewController: vc)
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        
        if self.plusModel?.type == 1 {
            popup.addButtons([addBtn0, addBtn1, addBtn2, addBtn3, addBtn4, addBtn5, cancelBtn])
        }else if self.plusModel?.type == 2 {
            popup.addButtons([addBtn0, addBtn1, addBtn2, cancelBtn])
        }else if self.plusModel?.type == 3 {
            popup.addButtons([addBtn0, addBtn3, addBtn4, addBtn5, cancelBtn])
        }
        self.present(popup, animated: true, completion: nil)
        
    }
    
    //点击房间按钮
    @objc func roomBtnAction(_ sender: UIButton) {
        
        isClickButton = true
        switchRoomScrollerBtn(switchTag: sender.tag, isClick: true)
    }
    
    //保存订单
    @objc func sureOrderAction() {
        
        saveOrder()
    }
    
    //扫码
    @objc func scancodeAction() {
        
        let dataModel = rowsData[selBtnTag-100]
        let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
        
        let vc = ScanCodeController()
        vc.title = "产品二维码"
        vc.packageModel = selPackage
        vc.queryPlusMaterialBlock = { [weak self] (materialsId) -> (MaterialsModel?) in
            
            let package = self?.plusMaterialArray.filter{ $0.packageId == self?.selPackageId }.first
            guard var materialList = package?.materialList else { return nil }
            materialList = materialList.filter{ $0.id == materialsId }
            
            if let material = materialList.first {
                
                let modelDic = material.toJSON()
                let dicModel = Mapper<MaterialsModel>().map(JSON: modelDic)
                
                //同步数量
                let oldSelMaterial = selPackage?.materials
                
                if let valueStr = oldSelMaterial?.buyCount.intValue {
                    
                    var count = valueStr
                    if let unitValue = dicModel?.unitType {
                        
                        let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                        if unitStr != "平方" && unitStr != "米" && unitStr != "公斤" && unitStr != "立方" {
                            
                            if valueStr % 100 != 0 {
                                count = (valueStr/100 + 1) * 100
                            }
                        }
                    }
                    dicModel?.buyCount = NSNumber(value: count)
                }
                
                return dicModel
            }
            return nil
        }
        vc.addPlusMaterialBlock = { [weak self] in
            guard let rightTableView = self?.contentScrollerView.viewWithTag((self!.selBtnTag-100+1)*1000+2) as? UITableView else {
                return
            }
            rightTableView.reloadSections([0, 1], with: .fade)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //品牌筛选
    @objc func brandAction(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        isBrandOpen = sender.isSelected
        guard let rightTableView = self.contentScrollerView.viewWithTag((selBtnTag-100+1)*1000+2) as? UITableView else {
            return
        }
        rightTableView.reloadSections([1], with: .fade)
    }
    
    //点击品牌按钮
    @objc func brandBtnClick(_ sender: UIButton) {
        
        isBrandOpen = false
        brandLastY = 40
        
        if let valueStr = sender.titleLabel?.text {
            selBrandStr = valueStr
        }
        guard let rightTableView = self.contentScrollerView.viewWithTag((selBtnTag-100+1)*1000+2) as? UITableView else {
            return
        }
        rightTableView.reloadSections([1], with: .fade)
    }
    
    
    //MARK: - 功能函数
    
    //切换房间按钮动画
    func switchRoomScrollerBtn(switchTag: Int, isClick: Bool=false) {
        
        if selBtnTag == switchTag {return}
        
        if let oldRoomBtn = roomScrollerView.viewWithTag(selBtnTag) as? Button {
            
            oldRoomBtn.isSelected = false
            let newRoomBtn = roomScrollerView.viewWithTag(switchTag) as? Button
            newRoomBtn?.isSelected = true
            selBtnTag = switchTag
            isBrandOpen = false
            brandLastY = 40
            selBrandStr = "全部品牌"
            
            //选中项初始化值
            let packageList = rowsData[switchTag-100].packageList
            let selPackage = packageList.filter{ $0.isCheck == true }.first
            if let package = selPackage {
                loadPackageMaterial(package.id!)
            }else {
                selPackageId = ""
                guard let rightTableView = self.contentScrollerView.viewWithTag((switchTag-100+1)*1000+2) as? UITableView else {
                    return
                }
                rightTableView.reloadData()
            }
            
            guard let leftTableView = self.contentScrollerView.viewWithTag((switchTag-100+1)*1000+1) as? UITableView else {
                return
            }
            leftTableView.reloadData()
            
            //右边滑动上限
            let rightOffset = roomScrollerView.contentSize.width - newRoomBtn!.centerX
            
            //需要偏移量
            let btnOffset = newRoomBtn!.centerX - PublicSize.screenWidth/2
            
            UIView.animate(withDuration: 0.3, animations: {
                self.followView.width = newRoomBtn!.width-14
                self.followView.centerX = newRoomBtn!.centerX
                
                if btnOffset < 0 || self.roomScrollerView.contentSize.width <= self.roomScrollerView.width {
                    //左上限
                    self.roomScrollerView.contentOffset = CGPoint(x: -10, y: 0)
                }
                else if rightOffset > PublicSize.screenWidth/2-45 {
                    //中间
                    self.roomScrollerView.contentOffset = CGPoint(x: btnOffset, y: 0)
                }
                else {
                    //右上限
                    self.roomScrollerView.contentOffset = CGPoint(x: self.roomScrollerView.contentSize.width-self.roomScrollerView.width, y: 0)
                }
                
                if isClick {
                    self.contentScrollerView.contentOffset = CGPoint(x: CGFloat(self.selBtnTag-100)*PublicSize.screenWidth, y: 0)
                }
                
            }) { (finish) in
                self.isClickButton = false
            }
        }
    }
    
    //计算所有价格
    func getAllPrice() {
        
        var packageSum: Double = 0
        var servicesSum: Double = 0
        
        for sectionModel in rowsData {
            //主材
            for model in sectionModel.packageList {
                
                if let value = model.materials?.priceCustom?.doubleValue {
                    let sumPrice = value * model.materials!.buyCount.doubleValue/100
                    packageSum += sumPrice
                }
            }
            
            //施工
            for model in sectionModel.serviceList {
                
                if let value = model.cusPrice?.doubleValue {
                    let sumPrice = value * model.buyCount.doubleValue/100
                    servicesSum += sumPrice
                }
            }
            
            let sumValue = packageSum+servicesSum
            
            //订单总价
            if let unitValue = plusModel?.unitType?.intValue {
                
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                if unitStr.count > 0 {
                    
                    if unitStr == "平方" {
                        if let space = houseModel?.space?.doubleValue, let plusPrice = plusModel?.price?.doubleValue {
                            totalValue = plusPrice * space + sumValue
                            let totalStr = totalValue.notRoundingString(afterPoint: 2)
                            orderPriceLabel.text = String.init(format: "订单总价:￥%@", totalStr)
                        }
                    }else if unitStr == "套" {
                        if let plusPrice = plusModel?.price?.doubleValue {
                            totalValue = plusPrice + sumValue
                            let totalStr = totalValue.notRoundingString(afterPoint: 2)
                            orderPriceLabel.text = String.init(format: "订单总价:￥%@", totalStr)
                        }
                    }
                }
                
            }
            
            //主材加减价
            let packageSumStr = packageSum.notRoundingString(afterPoint: 2)
            if packageSum >= 0 {
                materialPriceLabel.text = String.init(format: "产品:￥+%@", packageSumStr)
            }else {
                materialPriceLabel.text = String.init(format: "产品:￥%@", packageSumStr)
            }
            
            //施工加减价
            let servicesSumStr = servicesSum.notRoundingString(afterPoint: 2)
            if servicesSum >= 0 {
                servicePriceLabel.text = String.init(format: "施工:￥+%@", servicesSumStr)
            }else {
                servicePriceLabel.text = String.init(format: "施工:￥%@", servicesSumStr)
            }
        }
    }
    
    
    //MARK: - 网络请求
    
    //加载主材包对应主材  切换主材包都会调用
    func loadPackageMaterial(_ packageId: String) {
        
//        guard let rightTableView = self.contentScrollerView.viewWithTag((selBtnTag-100+1)*1000+2) as? UITableView else {
//            return
//        }
//        
//        selPackageId = packageId
//        
//        //自增商城主材 或 临时主材
//        if packageId == "A001" || packageId == "B001" {
//            self.clearAllNotice()
//            rightTableView.reloadData()
//            return
//        }
//        
//        let package = plusMaterialArray.filter{$0.packageId == selPackageId}.first
//        if package != nil {
//            self.clearAllNotice()
//            rightTableView.reloadData()
//            return
//        }
//        else {
//            let model = PlusMaterialModel()
//            model.packageId = packageId
//            plusMaterialArray.append(model)
//            rightTableView.reloadData()
//        }
//        
//        var cityID = ""
//        if let valueStr = UserData.shared.workerModel?.store?.city?.id {
//            cityID = valueStr
//        }
//        var storeID = ""
//        if let valueStr = UserData.shared.workerModel?.store?.id {
//            storeID = valueStr
//        }
//        
//        var parameters: Parameters = [:]
//        parameters["pageSize"] = "500"
//        parameters["city.id"] = cityID
//        parameters["storeId"] = storeID
//        parameters["packageId"] = packageId
//        
//        let urlStr = APIURL.getPlusMaterialist
//        self.pleaseWait()
//        
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { response in
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" || errorCode == "015" {
//                
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                
//                for materialModel in modelArray {
//                    if materialModel.cusPrice == nil {
//                        materialModel.cusPrice = 0
//                    }
//                    
//                    if let value = materialModel.cusPrice {
//                        materialModel.priceCustom = value
//                    }
//                }
//                for plusMaterialModel in self.plusMaterialArray {
//                    if plusMaterialModel.packageId == packageId {
//                        plusMaterialModel.materialList = modelArray
//                    }
//                }
//                rightTableView.reloadData()
//            }
//            
//        }) { error in
//            
//        }
        
    }
    
    //下单
    func saveOrder() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        var parameters: Parameters = [:]
        parameters["orderStatus"] = "1"
        parameters["orderType"] = "2"
        parameters["storeId"] = storeID
        parameters["workerId"] = userId
        parameters["houseId"] = houseModel?.id
        parameters["plusId"] = plusModel?.id
        parameters["plusType"] = "1"
        parameters["payMoney"] = totalValue.notRoundingString(afterPoint: 2)
        
        if let type = plusModel?.type?.stringValue {
            parameters["plusType"] = type
        }
        
        if orderId != "" {
            parameters["id"] = orderId
        }
        
        var materialCount = 0
        var serviceCount = 0
        
        var roomArray = [Parameters]()
        for sectionModel in rowsData {
            
            //主材
            var materialsArray = [Parameters]()
            for model in sectionModel.packageList {
                
                if model.materials?.id != nil && model.materials?.id != ""  {
                    
                    materialCount += 1
                    
                    var param: Parameters = [:]
                    param["packageId"] = "无"
                    param["packageName"] = "无"
                    param["packageType"] = "\(model.packageType)"
                    param["packagePrice"] = "0"
                    param["packageCategory"] = "无"
                    param["category"] = "无"
                    param["id"] = "无"
                    param["name"] = "无"
                    param["count"] = "\(model.materials!.buyCount)"
                    param["remarks"] = "无"
                    param["imageUrl"] = "0"
                    param["unitType"] = "0"
                    param["priceShow"] = "0"
                    param["priceCustom"] = "0"
                    param["sizeType"] = "无"
                    param["merchantId"] = "无"
                    param["brandName"] = "无"
                    param["type"] = "0"
                    
                    if model.packageType == 2 {
                        if model.materials?.remarks == nil {
                            
                            model.materials?.remarks = "商城主材 (套餐外)"
                        }
                    }
                    
                    if let valueStr = model.id {
                        param["packageId"] = valueStr
                    }
                    if let valueStr = model.name {
                        param["packageName"] = valueStr
                    }
                    if let valueStr = model.costPrice?.stringValue {
                        param["packagePrice"] = valueStr
                    }
                    if let valueStr = model.category?.id {
                        param["packageCategory"] = valueStr
                    }
                    if let valueStr = model.materials?.id {
                        if valueStr.count > 0 {
                            
                            param["id"] = valueStr
                        }
                    }
                    if let valueStr = model.materials?.name {
                        param["name"] = valueStr
                    }
                    if let valueStr = model.materials?.remarks {
                        param["remarks"] = valueStr
                    }
                    if let valueStr = model.materials?.imageUrl {
                        param["imageUrl"] = valueStr
                    }
                    if let valueStr = model.materials?.unitType?.stringValue {
                        param["unitType"] = valueStr
                    }
                    if let valueStr = model.materials?.priceShow?.stringValue {
                        param["priceShow"] = valueStr
                    }
                    if let valueStr = model.materials?.priceCustom?.stringValue {
                        param["priceCustom"] = valueStr
                    }
                    if let valueStr = model.materials?.yzbSpecification?.id {
                        if valueStr.count > 0 {
                            
                            param["sizeType"] = valueStr
                        }
                    }
                    if let valueStr = model.materials?.yzbMerchant?.id {
                        if valueStr.count > 0 {
                            param["merchantId"] = valueStr
                        }
                    }
                    if let valueStr = model.materials?.brandName {
                        param["brandName"] = valueStr
                    }
                    if let valueStr = model.materials?.type {
                        param["type"] = valueStr
                    }
                    
                    var categoryId = "无"
                    if model.materials?.categoryd?.id != nil && model.materials?.categoryd?.id != "" {
                        categoryId = (model.materials?.categoryd?.id)!
                    }
                    else if model.materials?.categoryc?.id != nil && model.materials?.categoryc?.id != "" {
                        categoryId = (model.materials?.categoryc?.id)!
                    }
                    else if model.materials?.categoryb?.id != nil && model.materials?.categoryb?.id != "" {
                        categoryId = (model.materials?.categoryb?.id)!
                    }
                    else if model.materials?.categorya?.id != nil && model.materials?.categorya?.id != "" {
                        categoryId = (model.materials?.categorya?.id)!
                    }
                    else if model.materials?.categorys?.id != nil && model.materials?.categorys?.id != "" {
                        categoryId = (model.materials?.categorys?.id)!
                    }
                    param["category"] = categoryId
                    
                    materialsArray.append(param)
                }
            }
            
            //施工
            var serviceArray = [Parameters]()
            for model in sectionModel.serviceList {
                
                serviceCount += 1
                
                var param: Parameters = [:]
                param["id"] = "无"
                param["count"] = "\(model.buyCount)"
                param["type"] = "\(model.serviceType)"
                param["unitType"] = "0"
                param["remarks"] = "无"
                param["name"] = "无"
                param["price"] = "0"
                param["category"] = "0"
                
                if let valueStr = model.id {
                    if valueStr.count > 0 {
                        
                        param["id"] = valueStr
                    }
                }
                if let valueStr = model.unitType?.stringValue {
                    param["unitType"] = valueStr
                }
                
                param["remarks"] = model.remarks
//                if let valueStr = model.remarks {
//                    param["remarks"] = valueStr
//                }
                if let valueStr = model.name {
                    param["name"] = valueStr
                }
                if let valueStr = model.cusPrice?.stringValue {
                    param["price"] = valueStr
                }
                if let valueStr = model.category?.stringValue {
                    param["category"] = valueStr
                }
                
                serviceArray.append(param)
            }
            
            if materialsArray.count > 0 || serviceArray.count > 0 {
                
                var roomParam: Parameters = [:]
                roomParam["roomType"] = sectionModel.roomType?.stringValue
                roomParam["materials"] = ""
                roomParam["services"] = ""
                
                if materialsArray.count > 0 {
                    roomParam["materials"] = materialsArray
                }
                if serviceArray.count > 0 {
                    roomParam["services"] = serviceArray
                }
                
                roomArray.append(roomParam)
            }
        }
        
        if materialCount <= 0 && serviceCount <= 0 {
            //没有可下单的主材或施工
            let popup = PopupDialog(title: "下单提示", message: "没有可下单的产品", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
            
            let sureBtn = AlertButton(title: "确定") {
                
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        parameters["rooms"] = roomArray
        
        if (!JSONSerialization.isValidJSONObject(parameters)) {
            print("无法解析出JSONString")
            return
        }
        
        let data : NSData! = try! JSONSerialization.data(withJSONObject: parameters, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        
        let dataParam: Parameters = ["data": JSONString!]
        
        AppLog(dataParam)
        self.pleaseWait()
        let urlStr = APIURL.saveOrder
        
        YZBSign.shared.request(urlStr, method: .post, parameters: dataParam, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                // 通知刷新状态
                GlobalNotificationer.post(notification: .order, object: nil, userInfo: nil)
                
                let popup = PopupDialog(title: "保存成功", message: "可在 '客户订单' 中查看或修改", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    
                    if self.orderId != "" {
                        self.navigationController?.popViewController(animated: true)
                    }else {
                        if let viewControllers = self.navigationController?.viewControllers {
                            let vc = viewControllers[viewControllers.count-3]
                            self.navigationController?.popToViewController(vc, animated: true)
                        }
                    }
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            else if errorCode == "001" {
                
                self.noticeOnlyText("备注不能包含表情图片")
            }
            
            
        }) { (error) in
            
        }
    }
    
    
    //MARK: - tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView.tag%1000 == 2 {
            
            if selPackageId != "" {
                let roomIndex = selBtnTag-100
                let dataModel = rowsData[roomIndex]
                let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
                if selPackage?.packageType == 1 {
                    return 2
                }else {
                    return 1
                }
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //不是当前选中房间不刷新
        if tableView.tag/1000-1 != selBtnTag-100 {
            return 0
        }
        
        if tableView.tag%1000 == 1 {
            
            let roomIndex = tableView.tag/1000 - 1
            let dataModel = rowsData[roomIndex]
            return dataModel.packageList.count+1
        }
        else if tableView.tag%1000 == 2 && selBtnTag%100 == tableView.tag/1000-1 {
            
            let roomIndex = tableView.tag/1000 - 1
            let dataModel = rowsData[roomIndex]
            
            if selPackageId == "" {
                return dataModel.serviceList.count
            }
            else {
                if section == 0 {
                    let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
                    
                    if selPackage?.packageType == 1 {
                        //套餐主材
                        if selPackage?.materials != nil {
                            return 1
                        }else {
                            return 0
                        }
                    }else {
                        //自增主材
                        return 1
                    }
                }else {
                    
                    let package = plusMaterialArray.filter{$0.packageId == selPackageId}.first
                    if package != nil {
                        if selBrandStr != "全部品牌" {
                            let filterMaterial = package!.materialList.filter{ $0.brandName == selBrandStr}
                            
                            return filterMaterial.count
                        }
                        return package!.materialList.count
                        
                    }
                }
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag%1000 == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: packageCellId, for: indexPath) as! OrderPackageCell
            cell.backgroundColor = .clear
            cell.signView.isHidden = true
            cell.selIcon.isHidden = true
            cell.roomTitleLabel.textColor = PublicColor.commonTextColor
            
            let roomIndex = tableView.tag/1000 - 1
            let dataModel = rowsData[roomIndex]
            var isCheck = false
                
            if indexPath.row < dataModel.packageList.count {
                
                let packageModel = dataModel.packageList[indexPath.row]
                isCheck = packageModel.isCheck
                
                if let valueStr = packageModel.name {
                    if packageModel.packageType == 1 {
                        cell.roomTitleLabel.text = valueStr
                    }else {
                        cell.roomTitleLabel.text = "(增)" + valueStr
                    }
                }
                
                if packageModel.materials != nil {
                    cell.selIcon.isHidden = false
                }
                
            }else {
                cell.roomTitleLabel.text = "施工"
                
                isCheck = true
                for packageModel in dataModel.packageList {
                    if packageModel.isCheck {
                        isCheck = false
                    }
                }
                
                if dataModel.serviceList.count > 0 {
                    cell.selIcon.isHidden = false
                }
            }
            if isCheck {
                cell.backgroundColor = .white
                cell.signView.isHidden = false
                cell.roomTitleLabel.textColor = PublicColor.emphasizeTextColor
            }
            
            return cell
        }
        else if tableView.tag%1000 == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: materialCellId, for: indexPath) as! OrderMaterialCell
            cell.materialModel = nil
            cell.serviceModel = nil
            
            cell.changeCountBlock = { [weak self] in
                self?.getAllPrice()
            }
            
            let roomIndex = tableView.tag/1000 - 1
            let dataModel = rowsData[roomIndex]
            
            if selPackageId == "" {
                let serviceArray = dataModel.serviceList
                cell.serviceModel = serviceArray[indexPath.row]
                cell.orderCellType = .service
                
                cell.remarkBlock = { [weak self] in
                    
                    var remarkStr = ""
                    remarkStr = serviceArray[indexPath.row].remarks
//                    if let valueStr = serviceArray[indexPath.row].remarks {
//                        remarkStr = valueStr
//                    }
                    
                    let remarkVC = RemarksViewController(title: "备注", remark: remarkStr)
                    remarkVC.remarksType = .remarks
                    remarkVC.doneBlock = { (remarks, re2) in
                        serviceArray[indexPath.row].remarks = remarks ?? "无"
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    
                    self?.present(remarkVC, animated: true, completion:nil)
                }
            }
            else {
                let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
                
                //主材详情
                cell.detailBlock = { [weak self] in
                    
                    if selPackage?.packageType == 3 {
                        
                        let vc = AddSelfMaterialController()
                        vc.title = "临时创建产品 (套餐外)"
                        vc.packageModel = selPackage
                        
                        vc.addPackageBlock = { packageModel in
                            tableView.reloadRows(at: [indexPath], with: .none)
                        }
                        
                        let viewController = BaseNavigationController.init(rootViewController: vc)
                        self?.navigationController?.present(viewController, animated: true, completion: nil)
                    }
                    else {
                        let vc = MaterialDetailController()
                        if indexPath.section == 0 {
                            if let materialModel = selPackage?.materials {
                                vc.materialsModel = materialModel
                            }
                        }else {
                            
                            let package = self?.plusMaterialArray.filter{$0.packageId == self!.selPackageId}.first
                            
                            guard var materialList = package?.materialList else { return }
                            
                            if self?.selBrandStr != "全部品牌" {
                                materialList = materialList.filter{ $0.brandName == self?.selBrandStr}
                            }
                            
                            let materialModel = materialList[indexPath.row]
                            
                            vc.materialsModel = materialModel
                            vc.detailType = .select
                            vc.packageModel = selPackage
                            
                            vc.addPlusMaterialBlock = {
                                selPackage?.materials = materialModel
                                tableView.reloadSections([0, 1], with: .fade)
                            }
                        }
                        let rootVc = BaseNavigationController.init(rootViewController: vc)
                        self?.present(rootVc, animated: true, completion: nil)
                    }
                }
                
                if indexPath.section == 0 {
                    cell.materialModel = selPackage?.materials
                    cell.orderCellType = .nowMaterial
                    
                    if selPackage?.packageType != 1 {
                        cell.isAddMaterial = true
                    }
                    
                    cell.remarkBlock = { [weak self] in
                        
                        var remarkStr = ""
                        if let valueStr = selPackage?.materials?.remarks {
                            remarkStr = valueStr
                        }
                        
                        let remarkVC = RemarksViewController(title: "备注", remark: remarkStr)
                        remarkVC.remarksType = .remarks
                        remarkVC.doneBlock = { (remarks, re2) in
                            selPackage?.materials?.remarks = remarks ?? "无"
                            tableView.reloadRows(at: [indexPath], with: .none)
                        }
                        
                        self?.present(remarkVC, animated: true, completion:nil)
                    }
                }
                else {
                    let package = plusMaterialArray.filter{$0.packageId == selPackageId}.first
                    
                    guard var materialList = package?.materialList else { return cell}
                    
                    if selBrandStr != "全部品牌" {
                        materialList = materialList.filter{ $0.brandName == selBrandStr}
                    }
                    
                    let materialModel = materialList[indexPath.row]
                    cell.materialModel = materialModel
                    
                    let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
                    cell.operationBlock = { [weak self] in
                        
                        let modelDic = materialModel.toJSON()
                        let dicModel = Mapper<MaterialsModel>().map(JSON: modelDic)
                        
                        let oldSelMaterial = selPackage?.materials
                        selPackage?.materials = dicModel
                        
                        //同步数量
                        if let valueStr = oldSelMaterial?.buyCount.intValue {
                            
                            var count = valueStr
                            if let unitValue = dicModel?.unitType {
                                
                                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                                if unitStr != "平方" && unitStr != "米" && unitStr != "公斤" && unitStr != "立方" {
                                    
                                    if valueStr % 100 != 0 {
                                        count = (valueStr/100 + 1) * 100
                                    }
                                }
                            }
                            selPackage?.materials?.buyCount = NSNumber(value: count)
                        }
                        
                        tableView.reloadSections([0, 1], with: .fade)
                        
                        guard let leftTableView = self?.contentScrollerView.viewWithTag((self!.selBtnTag-100+1)*1000+1) as? UITableView else {
                            return
                        }
                        leftTableView.reloadData()
                        
                        self?.getAllPrice()
                        self?.updateRoomBtn()
                    }
                    
                    if let selMaterial = selPackage?.materials {
                        
                        if materialModel.id == selMaterial.id {
                            cell.orderCellType = .optional_set
                        }else {
                            cell.orderCellType = .optional_did
                        }
                    }else {
                        cell.orderCellType = .optional_un
                    }
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.tag%1000 == 1 {
            
            let roomIndex = tableView.tag/1000 - 1
            let dataModel = rowsData[roomIndex]
            
            _ = dataModel.packageList.map { $0.isCheck = false }
            isBrandOpen = false
            brandLastY = 40
            selBrandStr = "全部品牌"
            
            if indexPath.row < dataModel.packageList.count {
                let packageModel = dataModel.packageList[indexPath.row]
                packageModel.isCheck = true
                loadPackageMaterial(packageModel.id!)
            }else {
                selPackageId = ""
                guard let rightTableView = self.contentScrollerView.viewWithTag((selBtnTag-100+1)*1000+2) as? UITableView else {
                    return
                }
                rightTableView.reloadData()
            }
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView.tag%1000 == 2 {
            
            let roomIndex = tableView.tag/1000 - 1
            let dataModel = rowsData[roomIndex]
            
            if selPackageId != "" {
                
                if section == 0 {
                    let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
                    if selPackage?.materials == nil {
                        return 80
                    }else {
                        return 40
                    }
                }else {
                    let package = plusMaterialArray.filter{$0.packageId == selPackageId}.first
                    if let materialList = package?.materialList {
                        if materialList.count > 0 {
                            if isBrandOpen {
                                return brandLastY
                            }
                            return 40
                        }
                    }
                    return 80
                }
            }else {
                let serviceArray = dataModel.serviceList
                if serviceArray.count <= 0 {
                    return 40
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView.tag%1000 == 2 {
            
            var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "plusOrderHeader")
            
            if headerView == nil {
                headerView = UITableViewHeaderFooterView()
                headerView?.contentView.backgroundColor = .white
                headerView?.contentView.backgroundColor = .white
                headerView?.contentView.layer.masksToBounds = true
                
                //组内容空时提示语
                let detailLabel = UILabel()
                detailLabel.text = "还未选择产品哦~"
                detailLabel.isHidden = true
                detailLabel.textColor = PublicColor.minorTextColor
                detailLabel.font = UIFont.systemFont(ofSize: 12)
                headerView?.contentView.addSubview(detailLabel)
                
                detailLabel.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(44)
                }
                
                if selPackageId != "" {
                    
                    //组的标题
                    let titleLabel = UILabel()
                    titleLabel.tag = 501
                    titleLabel.textColor = PublicColor.commonTextColor
                    titleLabel.font = UIFont.systemFont(ofSize: 14)
                    headerView?.contentView.addSubview(titleLabel)
                    
                    titleLabel.snp.makeConstraints { (make) in
                        make.left.equalTo(12)
                        make.top.equalTo(15)
                    }
                    
                    //扫码
                    let scancodeBtn = UIButton()
                    scancodeBtn.tag = 502
                    scancodeBtn.setImage(UIImage.init(named: "order_scanCode"), for: .normal)
                    scancodeBtn.addTarget(self, action: #selector(scancodeAction), for: .touchUpInside)
                    headerView?.contentView.addSubview(scancodeBtn)
                    
                    if section == 0 {
                        
                        titleLabel.text = "当前产品"
                        
                        //扫码
                        scancodeBtn.snp.makeConstraints { (make) in
                            make.width.height.equalTo(36)
                            make.centerY.equalTo(titleLabel)
                            make.right.equalTo(-5)
                            make.left.equalTo(titleLabel.snp.right)
                        }
                        
                        let roomIndex = tableView.tag/1000 - 1
                        let dataModel = rowsData[roomIndex]
                        let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
                        if selPackage?.materials == nil {
                            
                            detailLabel.text = "还没选择产品哦~"
                            detailLabel.isHidden = false
                            
                            let lineView = UIView()
                            lineView.backgroundColor = PublicColor.partingLineColor
                            headerView?.contentView.addSubview(lineView)
                            
                            lineView.snp.makeConstraints { (make) in
                                make.left.equalTo(titleLabel).offset(5)
                                make.height.equalTo(1)
                                make.bottom.equalToSuperview()
                                make.right.equalTo(-15)
                            }
                        }
                        
                        if selPackage?.packageType != 1 {
                            scancodeBtn.isHidden = true
                        }
                    }
                    else {
                        
                        titleLabel.text = "可选产品"
                        
                        let brandBtn = UIButton()
                        brandBtn.isSelected = isBrandOpen
                        brandBtn.setTitle(selBrandStr, for: .normal)
                        brandBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                        brandBtn.titleLabel?.sizeToFit()
                        brandBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
                        brandBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
                        brandBtn.addTarget(self, action: #selector(brandAction), for: .touchUpInside)
                        let brandBtnWidth = (brandBtn.titleLabel?.bounds.width)! + 20
                        headerView?.contentView.addSubview(brandBtn)
                        
                        brandBtn.snp.makeConstraints { (make) in
                            make.centerY.equalTo(titleLabel)
                            make.right.equalTo(-10)
                            make.height.equalTo(30)
                            make.width.equalTo(brandBtnWidth)
                        }
                        
                        brandBtn.set(image: UIImage.init(named: "down_arrows_o"), title: selBrandStr, imagePosition: .right, additionalSpacing: 5, state: .normal)
                        brandBtn.set(image: UIImage.init(named: "up_arrows"), title: selBrandStr, imagePosition: .right, additionalSpacing: 5, state: .selected)
                        
                        //扫码
                        scancodeBtn.isHidden = true
                        scancodeBtn.snp.makeConstraints { (make) in
                            make.width.height.equalTo(36)
                            make.centerY.equalTo(titleLabel)
                            make.right.equalTo(brandBtn.snp.left)
                            make.left.equalTo(titleLabel.snp.right)
                        }
                        
                        //品牌列表
                        let package = plusMaterialArray.filter{$0.packageId == selPackageId}.first
                        guard let materialList = package?.materialList else { return headerView }
                        if materialList.count <= 0 {
                            detailLabel.text = "没有产品可选呢~"
                            detailLabel.isHidden = false
                        }
                        else {
                            var brandArray: Array<String> = []
                            for materialModel in materialList {
                                if let valueStr = materialModel.brandName {
                                    if !brandArray.contains(valueStr) {
                                        brandArray.append(valueStr)
                                    }
                                }
                            }
                            brandArray.insert("全部品牌", at: 0)
                            
                            //按钮的高度
                            let btnH: CGFloat = 22
                            //文字与按钮两边的距离之和
                            let addW: CGFloat = 16
                            //横向间距
                            let marginX: CGFloat = 10
                            //纵向间距
                            let marginY: CGFloat = 12
                            //按钮范围宽度
                            let btnBackW: CGFloat = PublicSize.screenWidth-83
                            //上一个按钮的maxX加上间距
                            var lastX: CGFloat = 12
                            //上一个按钮的y值
                            var lastY: CGFloat = 45
                            
                            for brandName in brandArray {
                                
                                let btn = UIButton()
                                btn.setTitle(brandName, for: .normal)
                                btn.setTitleColor(PublicColor.minorTextColor, for: .normal)
                                btn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
                                btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                                btn.titleLabel?.sizeToFit()
                                btn.layer.cornerRadius = 2
                                btn.layer.borderWidth = 0.5
                                btn.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xe6e6e6).cgColor
                                btn.addTarget(self, action: #selector(brandBtnClick), for: .touchUpInside)
                                //按钮的总宽度
                                let btnW = (btn.titleLabel?.bounds.width)! + addW
                                
                                //在给按钮的frame赋值之前先判断本行余下的宽度是否大于将要布局的按钮的宽度,如果大于则x值为上一个按钮的宽度加上横向间距,y值与上一个按钮相同,如果小于则x值为0,y值为上一个按钮的y值加上按钮的高度和纵向间距
                                if btnBackW - lastX - 12 > btnW {
                                    btn.frame = CGRect(x: lastX, y: lastY, width: btnW, height: btnH)
                                } else {
                                    btn.frame = CGRect(x: 12, y: lastY + marginY + btnH, width: btnW, height: btnH)
                                }
                                lastX = btn.frame.maxX + marginX
                                lastY = btn.frame.origin.y
                                brandLastY = btn.frame.maxY+10
                                headerView?.contentView.addSubview(btn)
                                
                                //是否选中
                                if selBrandStr == brandName {
                                    btn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
                                    btn.layer.borderColor = PublicColor.emphasizeTextColor.cgColor
                                }
                            }
                            
                        }
                    }
                }else {
                    //组内容空时提示语
                    detailLabel.text = "没有施工服务哦~"
                    detailLabel.isHidden = false
                    
                    detailLabel.snp.remakeConstraints { (make) in
                        make.centerX.equalToSuperview()
                        make.top.equalTo(26)
                    }
                }
                return headerView
            }
        }
        
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        
        if tableView.tag%1000 == 2 && selPackageId != "" {
            
            let dataModel = rowsData[selBtnTag-100]
            let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
            
            if selPackage?.packageType == 1 {
                
                let header = tableView.headerView(forSection: 1)
                if let titleView = header?.viewWithTag(501) as? UILabel {
                    
                    if let materialName = selPackage?.materials?.name {
                        titleView.text = "已选 " + materialName
                    }else {
                        titleView.text = "可选产品"
                    }
                }
                if let scancode = header?.viewWithTag(502) {
                    scancode.isHidden = false
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if tableView.tag%1000 == 2 && selPackageId != "" {
            
            let dataModel = rowsData[selBtnTag-100]
            let selPackage = dataModel.packageList.filter{ $0.isCheck == true }.first
            
            if selPackage?.packageType == 1 {
                
                let header = tableView.headerView(forSection: 1)
                if let titleView = header?.viewWithTag(501) as? UILabel {
                    titleView.text = "可选产品"
                }
                if let scancode = header?.viewWithTag(502) {
                    scancode.isHidden = true
                }
            }
        }
    }
    
    //MARK: - scrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == contentScrollerView {
            
            //滑动偏移量
            let offsetX = scrollView.contentOffset.x
            if offsetX<=0 {return}
            
            //点击按钮不计算偏移量
            if isClickButton == true {return}
            
            //计算需要下一个按钮tag
            var tag = 100
            if offsetX >= PublicSize.screenWidth/2 {
                tag = 100+Int((offsetX - PublicSize.screenWidth/2) / PublicSize.screenWidth + 1)
            }
            if tag >= rowsData.count+100 {return}
            
            switchRoomScrollerBtn(switchTag: tag)
        }
    }
}
