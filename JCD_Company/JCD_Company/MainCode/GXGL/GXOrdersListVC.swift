//
//  GXOrdersListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper
import TLTransitions

class GXOrdersListVC: BaseViewController {
    public var index = 0
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    var rowsData: [PurchaseOrderModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        tableView.backgroundColor(.clear)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(cellWithClass: GXOrdersListCell.self)
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        prepareNoDateView("暂无数据")
        if index == 0 {
            loadData()
        }
    }
    private var queryStatus = 0
    private var size = 10
    var current = 1
    //获取订单
    func loadData() {
        var orderStatus = ""
        switch index {
        case 1:
            orderStatus = "2"
        case 2:
            orderStatus = "3"
        case 3:
            orderStatus = "4"
        case 4:
            orderStatus = "5"
        default:
            orderStatus = ""
        }
        
        var parameters: Parameters = ["size": "\(size)"]
        parameters["orderStatuss"] = orderStatus
        parameters["current"] = "\(self.current)"
        
        if UserData.shared.workerModel?.jobType == 999 {
            parameters["workerId"] = UserData.shared.workerModel?.id
        }
        parameters["storeId"] = UserData.shared.storeModel?.id
        parameters["orderType"] = 3
        
        let urlStr = APIURL.getYYSPurchaseOrder
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataDic1 = Utils.getReadDic(data: dataDic as AnyObject, field: "orderPage")
                let dataArray = Utils.getReadArr(data: dataDic1, field: "records")
                let modelArray = Mapper<PurchaseOrderModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current > 1 {
                    self.rowsData += modelArray
                }
                else {
                    self.rowsData = modelArray
                }
                if modelArray.count < self.size {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.rowsData.removeAll()
            }
            
            self.tableView.reloadData()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self.noDataView.isHidden = self.rowsData.count > 0
            
        }) { (error) in
            self.noDataView.isHidden = self.rowsData.count > 0
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
    }
    
    private func endRefreshHandle(_ haveNextPage: Bool?) {
        self.tableView.endHeaderRefresh()
        if haveNextPage ?? true {
            self.tableView.endFooterRefresh()
        } else {
            self.tableView.endFooterRefreshNoMoreData()
        }
    }
    
    
}

extension GXOrdersListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GXOrdersListCell().backgroundColor(.clear)
        cell.model = rowsData[indexPath.row]
        cell.refreshData = {
            self.tableView.beginHeaderRefresh()
        }
        return cell
    }
    
    func refreshTableViewList(indexPath: IndexPath, cell: UITableViewCell) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orderModel = rowsData[indexPath.row]
        let vc = PurchaseDetailController()
        
        if let valueStr = orderModel.id {
            vc.orderId = valueStr
        }
        vc.goBackBlock = { [weak self] model in
            if let purchaseModel = model {
                if self?.rowsData.count ?? 0 > 0 {
                    self?.rowsData.remove(at: indexPath.row)
                    self?.rowsData.append(purchaseModel)
                    self?.tableView.reloadData()
                }
            } else {
                if self?.rowsData.count ?? 0 > 0 {
                    self?.rowsData.remove(at: indexPath.row)
                    self?.tableView.reloadData()
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.clear)
    }
}

class GXOrdersListCell: UITableViewCell {
    var refreshData: (() -> Void)?
    var model: PurchaseOrderModel? {
        didSet {
            configCell()
        }
    }
    private var pop: TLTransition?
    private var pop1: TLTransition?
    private let headIcon = UIImageView().image(#imageLiteral(resourceName: "gx_dd_qc_icon"))
    private let headLab = UILabel().text("清仓处理").textColor(.kColor33).font(14)
    private let status = UILabel().text("待审核").textColor(.kColor66).font(14)
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
    private let title = UILabel().text("巴拉巴拉小魔仙乌卡拉卡边身 铁架子双人床").textColor(.kColor33).fontBold(16)
    private let price = UILabel().text("￥1270.00").textColor(.kDF2F2F).font(12)
    private let num = UILabel().text("数量：1").textColor(.kColor66).font(12)
    private let line = UIView().backgroundColor(.kColorEE)
    private let line1 = UIView().backgroundColor(.kColorEE)
    private let cancelBtn = UIButton().text("取消订单").textColor(.kColor99).font(12).borderColor(.kColor99).borderWidth(0.5).cornerRadius(15).masksToBounds()
    /// 已发布 #1DC597 已拒绝 #DF2F2F
    func configCell() {
        switch model?.activityType {
        case 1:
            headIcon.image(#imageLiteral(resourceName: "gx_dd_qc_icon"))
            headLab.text("正常订单")
        case 2:
            headIcon.image(#imageLiteral(resourceName: "gx_dd_qc_icon"))
            headLab.text("清仓处理")
        case 3:
            headIcon.image(#imageLiteral(resourceName: "gx_dd_th_icon"))
            headLab.text("每周特惠")
        case 4:
            headIcon.image(#imageLiteral(resourceName: "gx_dd_xh_icon"))
            headLab.text("新品现货")
        default:
            break
        }
        //订单状态    // 2: 等待商家确认 3: 商家已确认 4: 完成付款 5: 商家出货 6: 已确认收货 8: 订单取消 9: 已付款待审核  10: 付款审核拒绝 11: 已失效
        switch model?.orderStatus {
        case 2:
            status.text("待确认").textColor(.kColor66)
            if UserData.shared.userType == .gys {
                cancelBtn.text("确认订单").textColor(.k2FD4A7).borderColor(.k2FD4A7)
            } else {
                cancelBtn.text("取消订单").textColor(.kColor99).borderColor(.kColor99)
            }
            
        case 3:
            status.text("待付款").textColor(#colorLiteral(red: 0.9921568627, green: 0.6117647059, blue: 0.231372549, alpha: 1))
            if UserData.shared.userType == .gys {
                cancelBtn.isHidden = true
            } else {
                cancelBtn.isUserInteractionEnabled = false
                cancelBtn.text("立即支付").textColor(.k2FD4A7).borderColor(.k2FD4A7)
            }
        case 4:
            status.text("待发货").textColor(.kColor66)
            if UserData.shared.userType == .gys {
                cancelBtn.text("确认发货").textColor(.k2FD4A7).borderColor(.k2FD4A7)
            } else {
                cancelBtn.isHidden = true
            }
            
        case 5:
            status.text("待收货").textColor(.kColor66)
            if UserData.shared.userType == .gys {
                cancelBtn.isHidden = true
            } else {
                cancelBtn.text("确认收货").textColor(.k2FD4A7).borderColor(.k2FD4A7)
            }
        case 6:
            status.text("已确认收货").textColor(.kColor66)
            cancelBtn.isHidden = true
        case 8:
            status.text("订单取消").textColor(.kColor66)
            cancelBtn.isHidden = true
        case 10:
            status.text("付款审核拒绝").textColor(#colorLiteral(red: 0.9921568627, green: 0.6117647059, blue: 0.231372549, alpha: 1))
            if UserData.shared.userType == .gys {
                cancelBtn.isHidden = true
            } else {
                cancelBtn.isUserInteractionEnabled = false
                cancelBtn.text("立即支付").textColor(.k2FD4A7).borderColor(.k2FD4A7)
            }
        case 11:
            status.text("已失效").textColor(.kColor66)
            cancelBtn.isHidden = true
        default:
            break
        }
        
        if !icon.addImage(model?.imageUrl) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        title.text(model?.name ?? "")
        price.text("￥\(model?.payMoney ?? 0)")
        num.text("数量：\(model?.count ?? 0)")
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let v = UIView().backgroundColor(.white)
        sv(v)
        layout(
            5,
            |-14-v.height(210)-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        v.sv(headIcon, headLab, num, icon, title, price, line, line1, status, cancelBtn)
        title.numberOfLines(0).lineSpace(2)
        v.layout(
            15,
            |-15-headIcon.size(20)-2-headLab.height(20)-(>=0)-status-15-|,
            9.75,
            |-14.75-line-14.75-|,
            15.25,
            |-15-icon.size(80),
            14.75,
            |-14.75-line1-14.75-|,
            10.25,
            cancelBtn.width(90).height(30)-15-|,
            15
        )
        v.layout(
            60,
            |-105-title-15-|,
            >=10,
            |-105-price.height(20)-(>=0)-num-15-|,
            70
        )
        icon.contentMode = .scaleAspectFit
        icon.cornerRadius(3).masksToBounds()
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(btn:)))
    }
    
    @objc private func cancelBtnClick(btn: UIButton) {
        //订单状态    // 2: 等待商家确认 3: 商家已确认 4: 完成付款 5: 商家出货 6: 已确认收货 8: 订单取消 9: 已付款待审核  10: 付款审核拒绝 11: 已失效
        if UserData.shared.userType == .gys {
            switch model?.orderStatus {
            case 1, 2:
                self.sureOrderRequest()
            case 4: // 供应商确认发货
                self.sureSendGoodsRequest()
            default:
                break
            }
        } else {
            switch model?.orderStatus {
            case 2:
                let alert = UIAlertController.init(title: "提示", message: "是否确认取消该订单", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
                    self.cancelOrderRequest()
                }))
                parentController?.present(alert, animated: true, completion: nil)
            case 3, 10:
                toPay()
            case 5:
                let alert = UIAlertController.init(title: "提示", message: "是否确认收货", preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction.init(title: "确认", style: .default, handler: { (action) in
                    self.sureShouHuoRequest()
                }))
                parentController?.present(alert, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    func sureShouHuoRequest() {
        var parameters = Parameters()
        parameters["orderStatus"] = "6"
        parameters["id"] = model?.id
        let method: HTTPMethod = .put
        let urlStr = APIURL.purchaseOrderStatus
        self.pleaseWait()
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("确认收货成功")
                self.refreshData?()
            }
        }) { (error) in
            
        }
    }
    
    func cancelOrderRequest() {
        var parameters = Parameters()
        parameters["orderId"] = model?.id
        let method: HTTPMethod = .put
        let urlStr = APIURL.cancelPurchaseOrder
        self.pleaseWait()
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("取消订单成功")
                self.refreshData?()
            }
        }) { (error) in
            
        }
    }
    
    func sureOrderRequest() {
        var btnArray: [PopupDialogButton] = []
        
        let popup = PopupDialog(title: "请选择发货期限（以付款时间计算）", message: nil, buttonAlignment: .vertical)
        
        for dic in AppData.yzbSendTermList {
            
            let title = Utils.getReadString(dir: dic, field: "label")
            
            let btn = AlertButton(title: title) {
                self.sureOrderRequeset1(sendTime: title)
            }
            btnArray.append(btn)
        }
        let cancelBtn = CancelButton(title: "取消") {
            
        }
        
        btnArray.append(cancelBtn)
        popup.addButtons(btnArray)
        parentController?.present(popup, animated: true, completion: nil)
        
        
        
    }
    
    func sureOrderRequeset1(sendTime: String) {
        var parameters = Parameters()
        parameters["recevingTerm"] = sendTime
        parameters["id"] = model?.id
        let method: HTTPMethod = .post
        let urlStr = APIURL.surePurchaseOrder
        self.pleaseWait()
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("确认订单成功")
                self.refreshData?()
            }
        }) { (error) in
            
        }
    }
    
    func sureSendGoodsRequest() {
        var parameters = Parameters()
        parameters["orderStatus"] = "5"
        parameters["id"] = model?.id
        let method: HTTPMethod = .put
        let urlStr = APIURL.purchaseOrderStatus
        self.pleaseWait()
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("确认发货成功")
                self.refreshData?()
            }
        }) { (error) in
            
        }
    }
    
    /// 去付款
    @objc func toPay() {
        if couponModels.count > 0 {
            configDJQView()
        } else {
            sureBtnClick(btn: UIButton())
        }
    }
    
    /// 去付款
    @objc private func sureBtnClick(btn: UIButton) {
        pop?.dismiss()
        // PayTableViewController
        let payMoney = (self.model?.payMoney?.doubleValue ?? 0)
        let vc = OrderPayVC()
        vc.payMoney = payMoney
        if checkCouponMoney > (payMoney / 10) {
            vc.couponMoney = payMoney / 10
        } else {
            vc.couponMoney = checkCouponMoney
        }
        vc.purchaseModel = self.model
        vc.purchaseOrderId = self.model?.id ?? ""
        self.parentController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    private var couponModels: [CouponModel] = []
    private var current = 1
    private var pageSize = 300
    /// 获取订单可用优惠券列表
    func loadUseableCouponsData() {
        let hud = "".textShowLoading()
        var materialsIdStr = ""
        self.model?.materialsList?.forEach({ (item) in
            if !materialsIdStr.isEmpty {
                materialsIdStr.append(",")
            }
            materialsIdStr.append(item.materialsId ?? "")
        })
        
        var parameters = Parameters()
        parameters["orderId"] = model?.id
        parameters["materialsIdStr"] = materialsIdStr
        parameters["current"] = current
        parameters["size"] = pageSize
        YZBSign.shared.request(APIURL.getUsableCouponList, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            //            self.couponScrollView.mj_header.endRefreshing()
            //            self.couponScrollView.mj_footer.endRefreshing()
            hud.hide(animated: true)
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<CouponModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current > 1 {
                    self.couponModels += modelArray
                }
                else {
                    self.couponModels = modelArray
                }
                
                self.configDJQScrollView(self.couponScrollView)
                //                if modelArray.count < self.size {
                //                    self.couponScrollView.mj_footer.endRefreshingWithNoMoreData()
                //                }else {
                //                    self.couponScrollView.mj_footer.resetNoMoreData()
                //                }
            }else if errorCode == "008" {
                self.couponModels.removeAll()
                self.configDJQScrollView(self.couponScrollView)
            }
            
            //            if self.couponModels.count <= 0 {
            //                self.couponScrollView.mj_footer.endRefreshingWithNoMoreData()
            //            }
            
        }) { (error) in
            hud.hide(animated: true)
            //            self.couponScrollView.mj_header.endRefreshing()
            //            self.couponScrollView.mj_footer.endRefreshing()
        }
    }
    
    private var couponScrollView = UIScrollView()
    func configDJQView() {
        let v = UIView().backgroundColor(.white)
        v.frame = CGRect(x: 0, y: 0, width: PublicSize.kScreenWidth, height: 502-PublicSize.kBottomOffset)
        v.corner(byRoundingCorners: [.topLeft, .topRight], radii: 10)
        
        pop = TLTransition.show(v, popType: TLPopTypeActionSheet)
        
        let titleLab = UILabel().text("代金券").textColor(.kColor33).fontBold(16)
        let instructionsBtn = UIButton().text("使用说明").textColor(.kColor99).font(12)
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "plus_close_icon"))
        let line = UIView().backgroundColor(UIColor.hexColor("#DEDEDE"))
        let selectLab = UILabel().text("请选择代金券").textColor(.kColor33).font(12)
        let sureBtn = UIButton().text("确定").textColor(.white).font(14).cornerRadius(19).masksToBounds()
        v.sv(titleLab, instructionsBtn, closeBtn, line, selectLab, couponScrollView, sureBtn)
        v.layout(
            15,
            |-14-titleLab.height(22.5)-(>=0)-instructionsBtn.width(50).height(30)-6-closeBtn.size(30)-10-|,
            9.5,
            |-14-line.height(0.5)-14-|,
            10.5,
            |-14-selectLab.height(16.5),
            5,
            |-0-couponScrollView-0-|,
            5,
            sureBtn.width(PublicSize.kScreenWidth-60).height(38).centerHorizontally(),
            40-PublicSize.kBottomOffset
        )
        sureBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.46, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.23, blue: 0.23, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = sureBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        sureBtn.layer.insertSublayer(bgGradient, at: 0)
        
        instructionsBtn.addTarget(self, action: #selector(instructionsBtnClick(btn:)))
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        closeBtn.addTarget(self, action: #selector(closeBtnClick(btn:)))
    }
     
    @objc private func closeBtnClick(btn: UIButton) {
        pop?.dismiss()
    }
    
    @objc private func instructionsBtnClick(btn: UIButton) {
        let v = UIView().backgroundColor(.white)
        v.frame = CGRect(x: 0, y: 0, width: 313, height: 390)
        pop1 = TLTransition.show(v, popType: TLPopTypeAlert)
        
        let title = UILabel().text("代金券使用说明").textColor(.kColor33).fontBold(16)
        let sv = UIScrollView()
        let okBtn = UIButton().text("我知道了").textColor(.white).font(14).cornerRadius(15).masksToBounds()
        
        v.sv(title, sv, okBtn)
        v.layout(
            15,
            title.height(22.5).centerHorizontally(),
            20,
            |-0-sv-0-|,
            17.5,
            okBtn.width(130).height(30).centerHorizontally(),
            25
        )
        
        let content = UILabel().text("一、定义\n\n1、全网券：可用于抵扣所有的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n2、天网券：可用于抵扣天网的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n3、地网券：可用于抵扣地网的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n\n二、代金券的使用规则\n\n1、代金券抵扣金额不超过订单金额的10%。\n2、代金券面额为代金券的最高抵扣金额。\n3、代金券的金额大于订单金额的10%时，差额部分不予退回。\n4、服务类商品不享受代金券优惠。\n5、预购产品在尾款阶段，可使用，抵扣金额不超过尾款的10%。\n6、订单中可同时叠加使用代金券。").textColor(.kColor66).font(14)
        content.numberOfLines(0).lineSpace(2)
        sv.sv(content)
        sv.layout(
            10,
            content.width(273).centerHorizontally(),
            10
        )
        okBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.46, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.23, blue: 0.23, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = okBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        okBtn.layer.insertSublayer(bgGradient, at: 0)
        okBtn.addTarget(self, action: #selector(okBtnClick(btn:)))
    }
    
    @objc private func okBtnClick(btn: UIButton) {
        pop1?.dismiss()
    }
    
    
    func configDJQScrollView(_ sv: UIScrollView) {
        sv.removeSubviews()
        
        //        couponScrollView.refreshHeader { [weak self] in
        //            self?.current = 1
        //            self?.loadUseableCouponsData()
        //        }
        //        couponScrollView.refreshFooter { [weak self] in
        //            self?.current += 1
        //            self?.loadUseableCouponsData()
        //        }
        
        couponModels.enumerated().forEach { (item) in
            let index = item.offset
            let offsetY: CGFloat = CGFloat(10 + 110*index)
            let model = item.element
            let bgIV = UIImageView().image(#imageLiteral(resourceName: "purchase_djq_1"))
            bgIV.isUserInteractionEnabled = true
            let priceDes = UILabel().text("¥").textColor(.white).font(18)
            let price = UILabel().text("500").textColor(.white).fontBold(28)
            let useBtn = UIButton().text("立即使用").textColor(.k2AC99E).font(10).backgroundColor(.white).cornerRadius(10).masksToBounds()
            let status = UILabel().text("全网券").textColor(.white).font(10)
            let titleDes = UIView().backgroundColor(#colorLiteral(red: 0.1137254902, green: 0.7725490196, blue: 0.5921568627, alpha: 1)).cornerRadius(3).masksToBounds()
            let title = UILabel().text("仅限购买厨房卫浴-厨电品类的产品").textColor(.kColor33).fontBold(12)
            let time = UILabel().text("有效期至2020.08.18").textColor(.kColor66).font(10)
            let statusIV = UIImageView().image(#imageLiteral(resourceName: "purchase_use_icon"))
            let checkBtn = UIButton()
            sv.sv(bgIV)
            sv.layout(
                offsetY,
                bgIV.width(347).height(100).centerHorizontally(),
                >=10
            )
            bgIV.sv(priceDes, price, useBtn, status, titleDes, title, time, statusIV, checkBtn)
            
            bgIV.layout(
                >=0,
                statusIV.size(55)-6-|,
                6
            )
            bgIV.layout(
                3,
                status.height(14)-15-|,
                >=0
            )
            bgIV.layout(
                35.5,
                |-125-titleDes.size(6),
                >=0,
                |-125-time.height(14),
                15
            )
            bgIV.layout(
                30,
                |-135-title-60-|,
                >=0
            )
            bgIV.layout(
                30,
                checkBtn.size(40)-0-|,
                >=0
            )
            checkBtn.setImage(#imageLiteral(resourceName: "purchase_uncheck"), for: .normal)
            checkBtn.setImage(#imageLiteral(resourceName: "purchase_check"), for: .selected)
            checkBtn.tag = index
            
            checkBtn.isSelected = model.isCheckBox ?? false
            checkBtn.isEnabled = model.isEnable ?? true
            
            checkBtn.addTarget(self, action: #selector(checkBtnClick(btn:)))
            
            title.numberOfLines(0).lineSpace(2)
            statusIV.isHidden = true
            
            price.text("\(model.denomination ?? 0)")
            switch model.type {
            case "1":
                status.text("全网券")
                bgIV.image(#imageLiteral(resourceName: "purchase_djq_1"))
                titleDes.backgroundColor(UIColor.hexColor("#1DC597"))
            case "2":
                status.text("天网券")
                bgIV.image(#imageLiteral(resourceName: "purchase_djq_2"))
                titleDes.backgroundColor(UIColor.hexColor("#3564F6"))
            case "3":
                status.text("地网券")
                bgIV.image(#imageLiteral(resourceName: "purchase_djq_3"))
                titleDes.backgroundColor(UIColor.hexColor("#F68235"))
            default:
                break
            }
            switch model.usableRange {
            case "1":
                title.text("全场通用")
            case "2":
                title.text("仅限购买\(model.name ?? "")-\(model.objName ?? "")品类的产品")
            case "3":
                title.text("仅限购买\(model.objName ?? "")品牌商的产品")
            default:
                break
            }
            time.text("有效期至\(model.invalidDate ?? "")")
            
            statusIV.isHidden = true
            useBtn.isHidden = true
            bgIV.layout(
                41,
                |-21-priceDes.height(25)-2-price.height(39),
                >=0
            )
        }
    }
    
    var checkCouponMoney: Double = 0
    @objc private func checkBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        let payMoney = (self.model?.payMoney?.doubleValue ?? 0)
        couponModels[btn.tag].isCheckBox = btn.isSelected
        checkCouponMoney = 0
        couponModels.forEach { (model) in
            if model.isCheckBox ?? false {
                checkCouponMoney += (model.denomination?.doubleValue ?? 0)
            }
        }
        var isEnable = true
        if checkCouponMoney > (payMoney / 10) {
            isEnable = false
        } else {
            isEnable = true
        }
        
        couponModels.forEach { (model) in
            if model.isCheckBox == false {
                model.isEnable = isEnable
            }
        }
        configDJQScrollView(couponScrollView)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
