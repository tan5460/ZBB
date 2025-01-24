//
//  WantPurchaseController.swift
//  YZB_Company
//
//  Created by yzb_ios on 24.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Kingfisher
import Alamofire
import ObjectMapper

/**
 * 1. 向采购员商城提供查询本地已添加清单服务
 * 2. 实时更新自身列表(当添加商品)
 */

class WantPurchaseController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var materialTableView: UITableView!
    let identifier = "CartCell"
    let sectionHeaderId = "sectionHeaderView"
    var rowsData: Array<WantPSectionModel> = []
    var isRootVC = true
    var isFirstLoad = true
    
    var topView: UIView!                            //顶部视图
    var houseDetailView: UIView!                    //工地详情
    var houseHintLabel: UILabel!                    //选择工地提示
    var nameLabel: UILabel!                         //客户名字
    var phoneLabel: UILabel!                        //客户电话
    var plotLabel: UILabel!                         //小区
    
    var consigneeNameLabel: UILabel!                //收货人
    var consigneePhoneLabel: UILabel!               //收货人电话
    var consigneePlotLabel: UILabel!                //收货人地址
    
    var allSelectView: UIView!                      //全选视图
    
    var cartNullView: UIImageView!                  //购物车空提示
    var bottomView: UIView!                         //底部视图
    var tipView = UIView().backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1004922945))
    var placeOrderBtn: UIButton!                    //下一步
    var materialCountLabel: UILabel!                //主材项数
    var priceLabel: UILabel!                        //总价项数
    
    var isOneKeyBuy:Bool = false                    //是否一键采购
    var cusOrderId = ""                             //客户订单id
    
    lazy var selectedBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "car_unchecked"), for: .normal)
        btn.setImage(UIImage.init(named: "car_checked"), for: .selected)
        btn.addTarget(self, action: #selector(selectedAction), for: .touchUpInside)
        return btn
    }()
    
    var houseModel: HouseModel?
    var orderModel: OrderModel?
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>> 预购清单界面释放 <<<<<<<<<<<<<<<<<<")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "购物车"
        
        prepareTopView()
        prepareBottomView()
        prepareTableView()
        
        getAllMaterialsCount()
        loadHouseModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationPurchaseCart), name: NSNotification.Name(rawValue: "PurchaseAddCart"), object: nil)
        
        if rowsData.count <= 0 {
            if !isOneKeyBuy {
                loadData()
            }
        }
//        if !UserDefaults.standard.bool(forKey: UserDefaultStr.firstGuide4) {
//            UserDefaults.standard.set(true, forKey: UserDefaultStr.firstGuide4)
//            loadGuideView()
//        }
    }
    
    func loadGuideView() {
        let guideView = UIView()
        guideView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        guideView.backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        UIApplication.shared.windows.first?.addSubview(guideView)
        
        
        let guideIV1 = UIImageView().image(#imageLiteral(resourceName: "guide_4_1"))
        let guideIV2 = UIImageView().image(#imageLiteral(resourceName: "guide_4_2"))
        let guideIV3 = UIImageView().image(#imageLiteral(resourceName: "guide_4_3"))
        let xdcgBtn = UIButton().text("下单采购").textColor(.white).font(15)

        guideView.sv(guideIV1, guideIV2, guideIV3, xdcgBtn)
        guideView.layout(
            PublicSize.kNavBarHeight + 2,
            |-11-guideIV1.width(353).height(94),
            >=0,
            guideIV2.width(270).height(122)-14-|,
            PublicSize.kTabBarHeight+53.5
        )
        guideView.layout(
            >=0,
            xdcgBtn.width(100).height(44)-0-|,
            PublicSize.kTabBarHeight
        )
        guideView.layout(
            >=0,
            guideIV3.width(285).height(108)-62-|,
            PublicSize.kBottomOffset+8.5
        )
        
        let tabbarW: CGFloat = view.width/5
        let tabbarH: CGFloat = 45
        let tabbarBtn = UIButton().image(#imageLiteral(resourceName: "guide_4_white")).text("我的").textColor(.white).font(10)
        guideView.sv(tabbarBtn)
        guideView.layout(
            >=0,
            tabbarBtn.width(tabbarW).height(tabbarH)-0-|,
            PublicSize.kBottomOffset
        )
        tabbarBtn.layoutButton(imageTitleSpace: 8)
        let nextBtn = UIButton().text("下一步").textColor(.white).font(14).borderColor(.white).borderWidth(1).cornerRadius(15)
        guideView.sv(nextBtn)
        guideView.layout(
            >=0,
            |-30-nextBtn.width(90).height(30),
            PublicSize.kTabBarHeight+8.5
        )
        nextBtn.tapped {  [weak self] (btn) in
            guideView.removeFromSuperview()
            self?.tabBarController?.selectedIndex = 4
        }
        let guideIV4 = UIImageView().image(#imageLiteral(resourceName: "guide_5_5"))
        guideView.sv(guideIV4)
        guideView.layout(
            >=0,
            |-115-guideIV4.width(23).height(16),
            PublicSize.kTabBarHeight-2.5
        )
        fillXDCGBtnColor(v: xdcgBtn)
    }
    
    func fillXDCGBtnColor(v: UIView) {
        v.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.11, green: 0.77, blue: 0.59, alpha: 1).cgColor, UIColor(red: 0.38, green: 0.85, blue: 0.73, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = v.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.6)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.61)
        v.layer.insertSublayer(bgGradient, at: 0)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadHouseModel() {
        nameLabel.text = "客户姓名："
        phoneLabel.text = "客户电话："
        plotLabel.text = "小区："
        
        consigneeNameLabel.text = "收货人："
        consigneePhoneLabel.text = "收货人电话："
        consigneePlotLabel.text = "收货地址："
        
        if isOneKeyBuy && houseModel == nil {
            if let valueStr = orderModel?.customName {
                
                nameLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "客户姓名: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            if let valueStr = orderModel?.customeMobile {
                
                phoneLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "客户电话: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            var plotName = ""
            if let valueStr = orderModel?.plotName {
                plotName = valueStr
                
                if let roomNoStr = orderModel?.roomNo {
                    plotName += roomNoStr
                    plotLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "小区: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: plotName, color: PublicColor.commonTextColor, font: nameLabel.font)])
                }
            }
            
            if let valueStr = orderModel?.expressName, !valueStr.isEmpty {
                consigneeNameLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货人: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            if let valueStr = orderModel?.expressTel, !valueStr.isEmpty {
                consigneePhoneLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货人电话: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            
            if let valueStr = orderModel?.shippingAddress, !valueStr.isEmpty {
                consigneePlotLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货地址: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
                
            } else if let valueStr = orderModel?.expressAdd, !valueStr.isEmpty {
                consigneePlotLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货地址: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
                
            }
            
            
            if orderModel == nil {
                
                houseDetailView.isHidden = true
                
                topView.snp.remakeConstraints { (make) in
                    
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(44)
                }
                
            }else {
                houseDetailView.isHidden = false
                
                topView.snp.remakeConstraints { (make) in
                    
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(126)
                }
                
            }
        } else {
            if let valueStr = houseModel?.customName {
                nameLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "客户姓名: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            if let valueStr = houseModel?.customMobile {
                
                phoneLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "客户电话: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            var plotName = ""
            if let valueStr = houseModel?.plotName {
                plotName = valueStr
                
                if let roomNoStr = houseModel?.roomNo {
                    plotName += roomNoStr
                    plotLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "小区: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: plotName, color: PublicColor.commonTextColor, font: nameLabel.font)])
                }
            }
            
            if let valueStr = houseModel?.expressName, !valueStr.isEmpty {
                consigneeNameLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货人: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            if let valueStr = houseModel?.expressTel, !valueStr.isEmpty {
                consigneePhoneLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货人电话: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
            }
            
            
            if let valueStr = houseModel?.shippingAddress, !valueStr.isEmpty {
                
                consigneePlotLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "收货地址: ", color: PublicColor.minorTextColor, font: nameLabel.font), MixtureAttr(string: valueStr, color: PublicColor.commonTextColor, font: nameLabel.font)])
                
            }
            
            
            if houseModel == nil {
                
                houseDetailView.isHidden = true
                
                topView.snp.remakeConstraints { (make) in
                    
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(44)
                }
                
            }else {
                houseDetailView.isHidden = false
                
                topView.snp.remakeConstraints { (make) in
                    
                    make.top.left.right.equalToSuperview()
                    make.height.equalTo(126)
                }
                
            }
        }
        
        
    }
    
    var selectCount = 0 // 当前选中的商品数，除去补差价产品
    var isOneSellCount = 0 // 统计当前品牌商下组合购产品数量，只有1个的时候不能购买
    var isCanSell = true // 是否可购买
    //MARK: - 计算价格
    func getAllMaterialsCount() {
        
        var materialCount = 0
        var sumPrice = 0.0
        var isAllSelect = true
        selectCount = 0
        isOneSellCount = 0
        isCanSell = true
        for sectionModel in rowsData {
            let cellsModel = sectionModel.materials
            
            if (isOneSellCount == 1) {
                isCanSell = false
            }
            isOneSellCount = 0
            for model in cellsModel {
                
                if model.isSelectCheck {
                    
                    materialCount += 1
                    
                    selectCount += 1
                    if isOneKeyBuy {
                        if model.materials?.isOneSell == 2 {
                            isOneSellCount += 1
                        }
                        if let valueStr = model.materials?.beforePriceSupply?.doubleValue {
                            let mCount = Double(model.countInt)
                            let moneyStr = (valueStr*mCount).notRoundingString(afterPoint: 2, qian: false)
                            sumPrice += Double(moneyStr) ?? 0
                        }else if let valueStr = Double(model.materials?.materialsPriceSupply1 ?? "") {
                            let mCount = Double(model.countInt)
                            let moneyStr = (valueStr*mCount).notRoundingString(afterPoint: 2, qian: false)
                            sumPrice += Double(moneyStr) ?? 0
                        }
                    } else {
                        if model.materials?.materials?.isOneSell == 2 {
                            isOneSellCount += 1
                        }
                        if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                            if let valueStr = model.materials?.priceSell?.doubleValue {
                                let mCount = Double(model.countInt)
                                let moneyStr = (valueStr*mCount).notRoundingString(afterPoint: 2, qian: false)
                                sumPrice += Double(moneyStr) ?? 0
                            }
                        } else {
                            if let valueStr = model.materials?.price1?.doubleValue {
                                let mCount = Double(model.countInt)
                                let moneyStr = (valueStr*mCount).notRoundingString(afterPoint: 2, qian: false)
                                sumPrice += Double(moneyStr) ?? 0
                            }
                        }
                        
                    }
                }else {
                    isAllSelect = false
                }
            }
        }
        
        if rowsData.count <= 0 {
            isAllSelect = false
        }
        
        selectedBtn.isSelected = isAllSelect
        
        materialCountLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "已选: ", color: PublicColor.minorTextColor, font: materialCountLabel.font), MixtureAttr(string: "\(materialCount)件", color: PublicColor.commonTextColor, font: materialCountLabel.font)])
        
        if isOneSellCount == 1 || isCanSell == false{
            priceLabel.isHidden = true
        } else {
            priceLabel.isHidden = false
            let moneySumStr = sumPrice.notRoundingString(afterPoint: 2, qian: false)
            priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "合计: ", color: PublicColor.commonTextColor, font: priceLabel.font), MixtureAttr(string: "¥\(moneySumStr.addMicrometerLevel())", color: PublicColor.emphasizeColor, font: priceLabel.font)])
        }
        
        
        //刷新选中状态
        materialTableView.reloadData()
        
        if self.rowsData.count <= 0 {
            allSelectView.isHidden = true
            topView.isHidden = true
            bottomView.isHidden = true
            tipView.isHidden = true
            cartNullView.isHidden = false
            navigationItem.rightBarButtonItems = nil
            
            bottomView.snp.remakeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
                } else {
                    make.height.equalTo(44)
                }
            }
        }
        else {
            allSelectView.isHidden = false
            topView.isHidden = false
            bottomView.isHidden = false
            tipView.isHidden = false
            cartNullView.isHidden = true
            if navigationItem.rightBarButtonItems == nil {
                doneAction()
            }
        }
    }
    
    //MARK: 按钮事件
    //编辑
    @objc func editAction() {
        
        //完成
        let doneBtn = UIButton(type: .custom)
        doneBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        doneBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        doneBtn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
        //删除
        let deleteBtn = UIButton(type: .custom)
        deleteBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        deleteBtn.setTitle("删除", for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        deleteBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        deleteBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        deleteBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        let doneItem = UIBarButtonItem.init(customView: doneBtn)
        let deleteItem = UIBarButtonItem.init(customView: deleteBtn)
        navigationItem.rightBarButtonItems = [doneItem, deleteItem]
        
        bottomView.isHidden = true
        bottomView.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    //完成
    @objc func doneAction() {
        
        let editBtn = UIButton(type: .custom)
        editBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        editBtn.setTitle("编辑", for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        editBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        editBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        editBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        let editItem = UIBarButtonItem.init(customView: editBtn)
        navigationItem.rightBarButtonItems = [editItem]
        
        bottomView.isHidden = false
        
        bottomView.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
            } else {
                make.height.equalTo(44)
            }
        }
    }
    
    //删除
    @objc func deleteAction() {
        
        if isOneKeyBuy == true && selectedBtn.isSelected {
            self.noticeOnlyText("至少保留一个商品")
            return
        }
        
        var ids = ""
        
        for (_, item) in rowsData.enumerated() {
            for cellModel in item.materials {
                if cellModel.isSelectCheck {
                    if isOneKeyBuy {
                        if let materalsId = cellModel.materials?.skuId {
                            if ids.count > 0 {
                                ids += "," + materalsId
                            }else {
                                ids = materalsId
                            }
                        }
                    } else {
                        if let materalsId = cellModel.materials?.id {
                            if ids.count > 0 {
                                ids += "," + materalsId
                            }else {
                                ids = materalsId
                            }
                        }
                    }
                    
                }
            }
        }
        if ids == "" {
            self.noticeOnlyText("请选择需要删除的选项")
            return
        }
        
        let popup = PopupDialog(title: "是否删除所有选中项?", message: nil, buttonAlignment: .horizontal, tapGestureDismissal: false)
        let sureBtn = DestructiveButton(title: "删除") { [weak self] in
            let parameters: Parameters = ["skuIds": ids]
            
            self?.pleaseWait()
            let urlStr = APIURL.purchaseDelAllCart
            
            YZBSign.shared.request(urlStr, method: .delete, parameters: parameters, success: { (response) in
                
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                if errorCode == "0" {
                    self?.pleaseWait()
                    self?.loadData()
                }
            }) { (error) in
                
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    //全选
    @objc func selectedAction() {
        
        for sectionModel in rowsData {
            for model in sectionModel.materials {
                model.isSelectCheck = !selectedBtn.isSelected
            }
        }
        getAllMaterialsCount()
    }
    
    ///编辑工地
    @objc func editHouseAction() {
        
        let vc = HouseViewController()
        vc.title = "请选择客户工地"
        vc.houseModel = houseModel
        vc.isOrder = false
        vc.isEditHouse = true
        
        vc.selectedHouseBlock = { [weak self] houseModel in
            self?.houseModel = houseModel
            self?.loadHouseModel()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///备注
    @objc func remarkAction(tap:UITapGestureRecognizer) {
        
        if let label = tap.view as? UILabel {
            let model = rowsData[label.tag - 100]
            
            let remarkStr = model.remarks ?? ""
            let remarkVC = RemarksViewController(title: "备注", remark: remarkStr)
            remarkVC.doneBlock = { (remarks, re2) in
                
                if remarks == "" || remarks == nil {
                    label.text = "点击添加订单备注"
                    model.remarks = nil
                }
                else if remarks!.containsEmoji {
                    self.noticeOnlyText("请移除表情")
                }
                else {
                    label.text = remarks
                    model.remarks = remarks
                }
            }
            
            self.present(remarkVC, animated: true, completion:nil)
        }
        
    }
    
    ///添加补差价产品
    @objc func makeDifferenceAction(_ sender:UIButton) {
        
        let vc = AddSpreadController()
        vc.title = "添加补差价产品"
        vc.spreadType = .new
        vc.saveModelBlock = {[weak self](model) in
            
            self?.rowsData[sender.tag - 100].materials.append(model!)
            self?.getAllMaterialsCount()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    ///去结算
    @objc func placeOrderAction() {
        
        if isOneSellCount == 1  || isCanSell == false  {
            self.noticeOnlyText("同一品牌的组合购产品不足两个")
            return
        }
        
        if isOneKeyBuy {
            if houseModel == nil {
                if orderModel == nil {
                    editHouseAction()
                    return
                } else {
                    if orderModel?.expressName == nil || orderModel?.expressTel == nil || orderModel?.expressAdd == nil ||
                        orderModel?.expressName?.isEmpty ?? true || orderModel?.expressTel?.isEmpty ?? true || orderModel?.expressAdd?.isEmpty ?? true{
                        self.noticeOnlyText("请先补全收货信息~")
                        return
                    }
                }
            } else {
                if houseModel?.expressName == nil || houseModel?.expressTel == nil || houseModel?.expressAdd == nil ||
                    houseModel?.expressName?.isEmpty ?? true || houseModel?.expressTel?.isEmpty ?? true || houseModel?.expressAdd?.isEmpty ?? true{
                    self.noticeOnlyText("请先补全收货信息~")
                    return
                }
            }
        } else {
            if houseModel == nil {
                editHouseAction()
                return
            }
            if houseModel?.expressName == nil || houseModel?.expressTel == nil || houseModel?.expressAdd == nil ||
                houseModel?.expressName?.isEmpty ?? true || houseModel?.expressTel?.isEmpty ?? true || houseModel?.expressAdd?.isEmpty ?? true{
                self.noticeOnlyText("请先补全收货信息~")
                return
            }
        }
        
        
        
        var parameters: Parameters = [:]
        if isOneKeyBuy {
            if houseModel == nil {
                parameters["houseId"] = orderModel?.houseId
            } else {
                parameters["houseId"] = houseModel?.id
            }
        } else {
            parameters["houseId"] = houseModel?.id
        }
        parameters["from"] = "APP"
        parameters["orderId"] = orderModel?.id
        parameters["orderNo"] = orderModel?.orderNo
        
        var orderDatas = [[String: Any]]()
        rowsData.forEach { (sectionModel) in
            var materialsDic = [String: Any]()
            var dicArr = [[String: Any]]()
            var payMoneyAll: Decimal = 0
            sectionModel.materials.forEach { (purchaseModel) in
                if purchaseModel.isSelectCheck {
                    var dic = [String: Any]()
                    let materials = purchaseModel.materials
                    if isOneKeyBuy {
                        dic["materialsId"] = materials?.materialsId
                        dic["materialsName"] = materials?.materialsName
                        dic["skuId"] = materials?.skuId
                        dic["count"] = materials?.materialsCount
                        dic["price"] = Double.init(string: materials?.materialsPriceSupply1 ?? "0")
                        if let value = purchaseModel.remarks, !value.isEmpty {
                            dic["remarks"] = value
                        } else {
                            dic["remarks"] = "无"
                        }
                        if let value = purchaseModel.remarks2, !value.isEmpty {
                            dic["remarks2"] = value
                        } else {
                            dic["remarks2"] = "无"
                        }
                        if let value = purchaseModel.remarks3, !value.isEmpty {
                            dic["remarks3"] = value
                        } else {
                            dic["remarks3"] = "无"
                        }
                        dic["uploadFile"] = purchaseModel.fileUrls
                        let price = Decimal.init(string: materials?.materialsPriceSupply1 ?? "0") ?? 0
                        let count = Decimal.init(materials?.materialsCount?.doubleValue ?? 0)
                        let payMoney = price * count
                        payMoneyAll += payMoney
                    } else {
                        dic["materialsId"] = materials?.materials?.id
                        dic["materialsName"] = materials?.materials?.name
                        dic["skuId"] = materials?.id
                        dic["count"] = materials?.count
                        if let value = purchaseModel.remarks, !value.isEmpty {
                            dic["remarks"] = value
                        } else {
                            dic["remarks"] = "无"
                        }
                        if let value = purchaseModel.remarks2, !value.isEmpty {
                            dic["remarks2"] = value
                        } else {
                            dic["remarks2"] = "无"
                        }
                        if let value = purchaseModel.remarks3, !value.isEmpty {
                            dic["remarks3"] = value
                        } else {
                            dic["remarks3"] = "无"
                        }
                        if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                            dic["price"] = materials?.priceSell?.doubleValue
                        } else {
                            dic["price"] = materials?.price?.doubleValue
                        }
                        dic["uploadFile"] = purchaseModel.fileUrls
                        var price = Decimal.init(materials?.price?.doubleValue ?? 0)
                        if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                            price = Decimal.init(materials?.priceSell?.doubleValue ?? 0)
                        }
                        let count = Decimal.init(materials?.count?.doubleValue ?? 0)
                        let payMoney = price * count
                        payMoneyAll += payMoney
                    }
                    dicArr.append(dic)
                }
            }
            if dicArr.count > 0 {
                materialsDic["merchantId"] = sectionModel.materials.first?.materials?.merchantId
                materialsDic["datas"] = dicArr
                materialsDic["payMoney"]  = payMoneyAll
                materialsDic["supplyMoney"] = payMoneyAll
                if let value = sectionModel.remarks, !value.isEmpty {
                    materialsDic["bigRemarks"] = value
                } else {
                    materialsDic["bigRemarks"] = "无"
                }
                orderDatas.append(materialsDic)
            }
            
        }
        
        if orderDatas.count == 0 {
            noticeOnlyText("请选择需要下单的商品")
            return
        }
        
        parameters["orderDatas"] = orderDatas.jsonStr
        
        self.pleaseWait()
        let urlStr = APIURL.savePurchaseOrder
        
        placeOrderBtn.isEnabled = false
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            self.placeOrderBtn.isEnabled = true
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.houseModel = nil
                self.loadHouseModel()
                self.loadData()
                let vc = PurchaseSuccessVC()
                self.navigationController?.pushViewController(vc)
                
                //                let popup = PopupDialog(title: "保存成功", message: "可在 '采购订单'或 '服务订单' 中查看或修改", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                //
                //                let sureBtn = AlertButton(title: "确定") {
                //                    GlobalNotificationer.post(notification: .purchaseRefresh)
                //                    self.houseModel = nil
                //                    self.loadHouseModel()
                //                    self.loadData()
                //                    self.goBackRootViewController()
                //                }
                //                popup.addButtons([sureBtn])
                //                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            self.placeOrderBtn.isEnabled = true
        }
    }
    
    //MARK: 返回根控制器
    func goBackRootViewController() {
        
        if let tabBarVC = self.navigationController?.tabBarController {
            
            navigationController?.popToRootViewController(animated: false)
            if tabBarVC.selectedIndex != 0 {
                tabBarVC.selectedIndex = 3
                if let naVC = tabBarVC.selectedViewController as? UINavigationController {
                    if let vc = naVC.topViewController as? PurchaseViewController {
                        if !vc.isFirstLoad {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                                self.pleaseWait()
                                vc.headerRefresh()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - 网络请求
    @objc func refresh() {
        
        if self.rowsData.count <= 0 {
            
            self.loadData()
            
        }else {
            
            let popup = PopupDialog(title: "刷新会重置你修改的内容，是否重置?", message: nil,buttonAlignment: .horizontal)
            let sureBtn = DestructiveButton(title: "确认") {
                
                self.loadData()
            }
            let cancelBtn = CancelButton(title: "取消") {
                // 结束刷新
                self.materialTableView.mj_header?.endRefreshing()
            }
            
            popup.addButtons([cancelBtn,sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
        
    }
    
    @objc func loadData() {
        let urlStr = APIURL.getPurchaseCartList
        
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { [weak self] response in
            
            if self?.isOneKeyBuy == false {
                // 结束刷新
                self?.materialTableView.mj_header?.endRefreshing()
            }
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                var modelArray = [MaterialsModel]()
                dataArray.forEach { (item) in
                    let dataArray1 = Utils.getReadArr(data: item as! NSDictionary, field: "merchantProductList")
                    let modelArray1 = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray1 as! [[String : Any]])
                    modelArray += modelArray1
                }
                self?.rowsData.removeAll()
                self?.dealWithData(data: modelArray)
            }
            else {
                
                if errorCode == "008" {
                    self?.rowsData.removeAll()
                }
            }
            
            self?.getAllMaterialsCount()
            
        }) { [weak self] error in
            
            if self?.isOneKeyBuy == false {
                // 结束刷新
                self?.materialTableView.mj_header?.endRefreshing()
            }
            self?.getAllMaterialsCount()
        }
    }
    
    ///处理数据 isSelect处理时是否选中(从一键采购过来传True)
    func dealWithData(data:[MaterialsModel],isSelect:Bool = false) {
        isOneKeyBuy = isSelect
        for model in data {
            addDealWithData(model: model,isSelect:isSelect)
        }
    }
    
    func addDealWithData(model: MaterialsModel, isSelect: Bool) {
        
        var countIntValue: Double = 0
        if isSelect {
            countIntValue = model.materialsCount?.doubleValue ?? 0
        } else {
            countIntValue = model.count?.doubleValue ?? 0
        }
        
        var sectModel = WantPSectionModel()
        sectModel.merchantId = model.merchantId
        sectModel.merchantName = model.merchantName
        
        var purModel = PurchaseMaterialModel()
        purModel.materials = model
        purModel.remarks = model.remarks
        purModel.remarks3 = model.areaRemark
        purModel.remarks = " \(model.remarks ) "
        if model.areaRemark != "" {
            purModel.remarks3 = " \(model.areaRemark) "
        }
        
        purModel.isSelectCheck = isSelect
        
        //如果还没有供应商
        if (self.rowsData.count) <= 0 {
            //保存当前主材和供应商
            sectModel.materials = [purModel]
            self.rowsData.append(sectModel)
            
        }else {
            //判断这个主材是否属于这个供应商
            let hasMerchant = self.rowsData.contains(where: { (sectionModel) -> Bool in
                if sectionModel.merchantId == model.merchantId {
                    //主材是属于这个供应商，替换model
                    sectModel = sectionModel
                    return true
                }
                return false
            })
            
            //如果这个主材是属于这个供应商
            if hasMerchant == true {
                
                var hasMaterial = false
                
                //判断是否是相同主材
                hasMaterial = sectModel.materials.contains(where: { (materialModel) -> Bool in
                    if isOneKeyBuy {
                        if materialModel.materials?.skuId == model.skuId {
                            var ramarkStr = ""
                            if let remarks1 = materialModel.remarks {
                                ramarkStr = remarks1
                            }
                            
                            if let remarks2 = purModel.remarks, remarks2 != "" {
                                
                                if ramarkStr == "" {
                                    ramarkStr = remarks2
                                }else {
                                    ramarkStr += "|" + remarks2
                                }
                            }
                            
                            var areaRemark = ""
                            if let remarks1 = materialModel.remarks3 {
                                areaRemark = remarks1
                            }
                            
                            if let remarks2 = purModel.remarks3, remarks2 != "" {
                                
                                if areaRemark == "" {
                                    areaRemark = remarks2
                                }else {
                                    if areaRemark.range(of: remarks2) == nil {
                                        areaRemark += "|" + remarks2
                                    }
                                }
                            }
                            
                            purModel = materialModel
                            purModel.remarks = ramarkStr
                            purModel.remarks3 = areaRemark
                            return true
                        }
                    } else {
                        if materialModel.materials?.id == model.id {
                            var ramarkStr = ""
                            if let remarks1 = materialModel.remarks {
                                ramarkStr = remarks1
                            }
                            
                            if let remarks2 = purModel.remarks, remarks2 != "" {
                                
                                if ramarkStr == "" {
                                    ramarkStr = remarks2
                                }else {
                                    ramarkStr += "|" + remarks2
                                }
                            }
                            
                            var areaRemark = ""
                            if let remarks1 = materialModel.remarks3 {
                                areaRemark = remarks1
                            }
                            
                            if let remarks2 = purModel.remarks3, remarks2 != "" {
                                
                                if areaRemark == "" {
                                    areaRemark = remarks2
                                }else {
                                    if areaRemark.range(of: remarks2) == nil {
                                        areaRemark += "|" + remarks2
                                    }
                                }
                            }
                            
                            purModel = materialModel
                            purModel.remarks = ramarkStr
                            purModel.remarks3 = areaRemark
                            return true
                        }
                    }
                    
                    
                    return false
                })
                
                //是相同主材数量加1
                if hasMaterial == true {
                    
                    countIntValue += purModel.countInt
                    
                }else {//不是相同主材保存为新的model
                    purModel.materials = model
                    purModel.isSelectCheck = isSelect
                    
                    for (index, model) in sectModel.materials.enumerated() {
                        
                        //主材插入到补差价产品前面
                        if model.materials == nil {
                            sectModel.materials.insert(purModel, at: index)
                            break
                        }
                    }
                    if !sectModel.materials.contains(purModel) {
                        sectModel.materials.append(purModel)
                    }
                }
                
            }else {
                //如果这个主材不属于这个供应商，保存为新的model
                sectModel.materials = [purModel]
                self.rowsData.append(sectModel)
            }
        }
        purModel.countInt = countIntValue
    }
    
    
    @objc func notificationPurchaseCart(nofi : Notification){
        
        if let model = nofi.userInfo!["PurchaseCart"] as? MaterialsModel{
            
            if model.beforeUnitType != nil {
                model.unitType = model.beforeUnitType
            }
            addDealWithData(model: model, isSelect: false)
        }
        getAllMaterialsCount()
        materialTableView.reloadData()
    }
    
    //MARK: - tableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let model = rowsData[section]
        return model.materials.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //主材
        let cell = tableView.dequeueReusableCell(withIdentifier: WantPurchaseCell.self.description(), for: indexPath) as! WantPurchaseCell
        
        let model = rowsData[indexPath.section]
        
        let cellModel = model.materials[indexPath.row]
        
        cell.isCusMaterials = false
        cell.isOneKeyBuy = isOneKeyBuy
        cell.purchaseMaterial = cellModel
        
        cell.selectedBlock = { [weak self] (isCheck) in
            cellModel.isSelectCheck = isCheck
            self?.getAllMaterialsCount()
        }
        
        cell.detailBlock = { [weak self] in
            let rootVC = MaterialsDetailVC()
            rootVC.isDismiss = true
            let model = MaterialsModel()
            model.id = cellModel.materials?.materials?.id
            rootVC.materialsModel =  model
            let vc = BaseNavigationController.init(rootViewController: rootVC)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.isUserInteractionEnabled = true
        header.backgroundColor = .white
        
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: PublicSize.screenWidth - 100 - 30, height: 35))
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.text = "长沙艾肯销售中心"
        header.addSubview(titleLabel)
        
        let model = rowsData[section]
        titleLabel.text = model.merchantName 
        //自定义分割线
        let separatorView = UIView(frame: CGRect(x: 0, y: 34, width: PublicSize.screenWidth, height: 1))
        separatorView.backgroundColor = PublicColor.partingLineColor
        header.addSubview(separatorView)
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = rowsData[indexPath.section]
        var purchaseMaterial = model.materials[indexPath.row]
        
        let vc = PurchaseEnclosureController()
        vc.purchaseMaterial = purchaseMaterial
        
        vc.saveModelBlock = {[weak self] (model1) in
            purchaseMaterial = model1 ?? PurchaseMaterialModel()
            self?.getAllMaterialsCount()
            tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: 35))
        backView.backgroundColor = .white
        footer.addSubview(backView)
        
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 0, width: PublicSize.screenWidth-30, height: 35))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.textColor = PublicColor.minorTextColor
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.text = "点击添加订单备注"
        footer.addSubview(titleLabel)
        titleLabel.tag = section + 100
        
        let model = rowsData[section]
        if let remark = model.remarks {
            titleLabel.text = remark
        }
        
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(remarkAction))
        tapOne.numberOfTapsRequired = 1
        titleLabel.addGestureRecognizer(tapOne)
        
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 45
    }
}
