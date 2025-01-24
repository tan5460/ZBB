//
//  PlaceOrderController2.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/1.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import ObjectMapper
import Kingfisher


enum ShopCartEnterType {
    case fromDetail  // 从商品详情进入
    case fromCart   // 从购物车进入
    case fromOrderDetail // 从订单详情进入
}
class PlaceOrderController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var detailType: MaterialsDetailType = .nomarl
    var classView: ClassificationSlidingView!//分类滑动视图
    var materials1: [MaterialsModel] = []
    var currentSKUModel: MaterialsSkuListModel?
    
    var topView: UIView!                                //顶部栏
    var houseDetailView: UIView!                        //工地详情
    var houseHintLabel: UILabel!                        //选择工地提示
    var nameLabel: UILabel!                             //客户名字
    var phoneLabel: UILabel!                            //客户电话
    var acreageLabel: UILabel!                          //面积
    var plotLabel: UILabel!                             //小区
    
    var bottomView: UIView!                             //底部栏
    var surePayBtn: UIButton!                           //确认下单
    var orderPriceLabel: UILabel!                       //订单总价
    var orderPrice: UILabel!                            //订单总价
    var selectNumLabel: UILabel!                        // 已选数目
    var allPriceLabel: UILabel!                         // 合计价格
    var materialPriceLabel: UILabel!                    //主材价
    
    var leftTableView: UITableView!
    
    var leftEmptyLabel: UILabel!                         //无数据提示
    
    var totalValue: Decimal = 0                          //订单总价
    
    var rowsData: Array<MaterialsModel> = []             //内容列表
    var orderId = ""                                    //订单Id
    var orderNo = ""
    var orderStatus = 1
    var enterType: ShopCartEnterType = .fromCart
    var orderModel: OrderModel?
    var houseModel: HouseModel? {
        didSet {
            if let valueStr = houseModel?.customName {
                 nameLabel.text = valueStr
             }
             
             if let valueStr = houseModel?.customMobile {
                 phoneLabel.text = valueStr
             }
             
             if let acreageStr = houseModel?.space?.doubleValue {
                 let acreage = acreageStr.notRoundingString(afterPoint: 2, qian: false)
                 acreageLabel.text = String.init(format: "%@㎡", acreage)
             }
             
             var plotName = ""
             if let valueStr = houseModel?.plotName {
                 plotName = valueStr
                 
                 if let roomNoStr = houseModel?.roomNo {
                     plotName += roomNoStr
                     plotLabel.text = plotName
                 }
             }
             
             if houseModel == nil {
                 
                 houseDetailView.isHidden = true
                 
                 topView.snp.remakeConstraints { (make) in
                     if #available(iOS 11.0, *) {
                         make.top.equalTo(view.safeAreaLayoutGuide)
                     } else {
                         make.top.equalTo(64)
                     }
                     make.left.right.equalToSuperview()
                     make.height.equalTo(40)
                 }
                 
             }else {
                 houseDetailView.isHidden = false
            
                 topView.snp.remakeConstraints { (make) in
                     if #available(iOS 11.0, *) {
                         make.top.equalTo(view.safeAreaLayoutGuide)
                     } else {
                         make.top.equalTo(64)
                     }
                     make.left.right.equalToSuperview()
                     make.height.equalTo(56)
                 }
                 
             }
        }
    }
    var activityType: Int? // 2 清仓 3特惠。4新品 5: 拼购
    var activityId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "自由组合"
        if materials1.count > 0 {
            rowsData = materials1
        }
        prepareTopView()
        prepareBottomView()
        prepareTableView()
        
        screenEdgePanGestureRecognizerRequireFailToScrollView(self.classView.scollView)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
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
        
    //编辑工地
    @objc func editHouseAction() {
    
        let vc = HouseViewController()
        vc.title = "请选择客户工地"
        vc.houseModel = houseModel
        vc.isOrder = true
        vc.activityType = activityType ?? 1
        vc.isEditHouse = true
        vc.selectedHouseBlock = { [weak self] houseModel in
            self?.houseModel = houseModel
        }
        if materials1.count > 0 {
            vc.isOnekey = true
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    //保存订单
    @objc func sureOrderAction() {
        if houseModel == nil {
            editHouseAction()
        }else {
            if activityId == nil { // 判断是不是特惠订单，不是就用客户下单，是的话用采购下单
                saveOrder()
            } else {
                placeOrderAction()
            }
            
        }
    }
    
    
    //下单
    func saveOrder() {
        self.pleaseWait()
        var parameters = Parameters()
        if orderId != "" {
            parameters["id"] = orderId
            parameters["orderNo"] = orderNo
        }
        parameters["orderStatus"] = orderStatus
        parameters["orderType"] = 1
        parameters["storeId"] = UserData.shared.storeModel?.id
        parameters["workerId"] = UserData.shared.workerModel?.id
        if houseModel == nil {
            parameters["houseId"] = orderModel?.houseId
            parameters["customId"] = orderModel?.customId
        } else {
            parameters["houseId"] = houseModel?.id
            parameters["customId"] = houseModel?.customId
        }
        parameters["payMoney"] = "\(totalValue)"
        
        var arr = [[String: String]]()
        rowsData.forEach { (model) in
            var dic: [String: String] = [:]
            if materials1.count > 0 {
                dic["id"] = model.materialsId ?? ""
                dic["skuId"] = model.id ?? ""
                dic["count"] = "\(model.buyCount )"
                dic["priceCustom"] = "\(model.priceSell ?? 0)"
                dic["remarks"] = model.remarks
                dic["materialsName"] = model.materialsName
            } else {
                if enterType == .fromCart {
                    dic["id"] = model.materials?.id ?? ""
                    dic["skuId"] = model.id ?? ""
                    dic["count"] = "\(model.count ?? 0)"
                    dic["priceCustom"] = "\(model.priceSell ?? 0)"
                    dic["remarks"] = model.remarks
                    dic["materialsName"] = model.materialsName
                } else if enterType == .fromOrderDetail {
                    dic["id"] = model.materialsId ?? ""
                    dic["skuId"] = model.skuId ?? ""
                    dic["count"] = "\(model.materialsCount ?? 0)"
                    dic["priceCustom"] = "\(model.materialsPriceCustom ?? "")"
                    dic["remarks"] = model.remarks
                    dic["materialsName"] = model.materialsName
                } else {
                    dic["id"] = model.id ?? ""
                    dic["skuId"] = currentSKUModel?.id ?? ""
                    dic["count"] = "\(model.buyCount)"
                    dic["priceCustom"] = "\(currentSKUModel?.priceSell ?? 0)"
                    dic["remarks"] = model.remarks
                    dic["materialsName"] = model.materialsName
                }
            }
            
            arr.append(dic)
        }
        parameters["materials"] = arr
        var parametersNew = Parameters()
        parametersNew["comOrderStr"] = parameters.jsonStr
        let urlStr = APIURL.saveOrder
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parametersNew, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                GlobalNotificationer.post(notification: .order, object: nil, userInfo: nil)
                let popup = PopupDialog(title: "保存成功", message: "可在 '客户订单' 中查看或修改", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

                let sureBtn = AlertButton(title: "确定") {
                    var isIn = true
                    self.navigationController?.viewControllers.forEach {
                        if $0.classForCoder == StoreDetailVC.classForCoder() {
                            isIn = false
                            self.navigationController?.popToViewController($0, animated: true)
                        }
                    }
                    
                    if isIn {
                        self.navigationController?.popToRootViewController(animated: true)
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
    
    ///去结算
    @objc func placeOrderAction() {
        var parameters: Parameters = [:]
        parameters["houseId"] = houseModel?.id
        parameters["from"] = "APP"
        parameters["orderId"] = orderModel?.id
        parameters["orderNo"] = orderModel?.orderNo
        
        var orderDatas = [[String: Any]]()
        rowsData.forEach { (materials) in
            var materialsDic = [String: Any]()
            var dicArr = [[String: Any]]()
            var payMoneyAll: Decimal = 0
            var dic = [String: Any]()
            dic["materialsId"] = materials.id
            dic["materialsName"] = materials.name
            dic["skuId"] = currentSKUModel?.id
            dic["count"] = materials.buyCount
            dic["remarks"] = "无"
            dic["remarks2"] = "无"
            dic["remarks3"] = "无"
            var price = Decimal.init(currentSKUModel?.price1?.doubleValue ?? 0)
            if detailType == .hyzx {
                price = Decimal.init(currentSKUModel?.activityPrice?.doubleValue ?? 0)
            }
            dic["price"] = "\(price)"
            
            let count = Decimal.init(materials.buyCount.doubleValue)
            let payMoney = price * count
            payMoneyAll += payMoney
            dicArr.append(dic)
            if dicArr.count > 0 {
                materialsDic["merchantId"] = materials.merchantId
                materialsDic["datas"] = dicArr
                if activityType == 2 { // 清仓用一口价
                    materialsDic["payMoney"]  = price
                    materialsDic["supplyMoney"] = price
                } else {
                    materialsDic["payMoney"]  = payMoneyAll
                    materialsDic["supplyMoney"] = payMoneyAll
                }
                
                materialsDic["bigRemarks"] = materials.remarks
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
        if let activityID = activityId { // 清仓处理，每周特惠额外添加参数
            if detailType == .hyzx {
                parameters["activityId"] = activityID
                parameters["orderType"] = 1
            } else {
                parameters["activityId"] = activityID
                parameters["activityType"] = activityType
                parameters["orderType"] = 3
            }
        }
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                var str = "可在“供需市场我的订单”中查看或修改"
                if self.detailType == .hyzx {
                    str = "可在“我的订单”中查看或修改"
                }
                let popup = PopupDialog(title: "保存成功", message: str, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
                
                let sureBtn = AlertButton(title: "确定") {
                    GlobalNotificationer.post(notification: .purchaseRefresh)
                    self.houseModel = nil
                    
                    let vcCount = self.navigationController?.viewControllers.count
                    if vcCount ?? 0 >= 3 {
                        self.navigationController?.popToViewController((self.navigationController?.viewControllers[vcCount! - 3])!, animated: true)
                    }
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = rowsData[indexPath.row]
        let cell = PlaceOrderCell()
        cell.contentView.backgroundColor = UIColor.white
        if materials1.count > 0 {
            cell.isOneKey = true
        }
        cell.activityType = activityType ?? 0
        cell.enterType = enterType
        if enterType == .fromDetail {
            cell.currentSKUModel = currentSKUModel
        }
        cell.detailType = detailType
        cell.indexPath = indexPath
        cell.materialsModel = model
        cell.remarkBlock = { [weak self] in
            let remarkStr = ""
            let remarkVC = RemarksViewController(title: "备注", remark: remarkStr)
            remarkVC.remarksType = .remarks
            remarkVC.doneBlock = { (remarks, re2) in
                model.remarks = remarks ?? ""
                self?.leftTableView.reloadData()
            }
            self?.present(remarkVC, animated: true, completion:nil)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}
