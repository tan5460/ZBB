//
//  ServiceOrderDetailVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/10.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import TLTransitions
import Alamofire
import MJRefresh
import PopupDialog
import ObjectMapper

class ServiceOrderDetailVC: BaseViewController {

    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    private let bottomView = UIView().backgroundColor(.white)
    private var pop: TLTransition!
    var purchaseModel: PurchaseOrderModel?
    var infoModel: BaseUserInfoModel?
    var orderId = ""                    //订单id
    var removeId = ""                   //移除id
    var goBackBlock: ((_ orderModel: PurchaseOrderModel?)->())?
    var isPayQuery = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isPayQuery {
            self.isPayQuery = false
            let popup = PopupDialog(title: "提示", message: "支付结果查询可能会延迟，如支付成功但是订单状态未改变，请尝试下拉刷新重新查看订单状态！", buttonAlignment: .horizontal, tapGestureDismissal: false)
            let sureBtn = AlertButton(title: "确认") {
                
               // self.pleaseWait()
                self.loadData()
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
            
        }else {
            
           // self.pleaseWait()
            self.loadData()
        }
    }
    
    var orderDatas: [PurchaseMaterialModel]?
    @objc func loadData() {
        let parameters = Parameters()
        AppLog("订单id: \(parameters)")
        let urlStr = APIURL.getYYSPurchaseOrderData + orderId
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String : Any])
                self.purchaseModel = self.infoModel?.order
                self.orderDatas = self.infoModel?.orderData
                self.tableView.reloadData()
                self.goBackBlock?(self.purchaseModel)
            }
        }) { (error) in
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    ///合伙人移除待办消息
    private func removeOrder() {
        if removeId == "" {
            return
        }
        let parameters: Parameters = ["id": removeId]
        
        self.pleaseWait()
        let urlStr =  APIURL.deleteSysMessage
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                GlobalNotificationer.post(notification: .yysSureOrderRefresh)
                // self.goBackBlock?(self.purchaseModel)
            }
            
        }) { (error) in
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单详情"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
        }
        let bottomOffsetView = UIView().backgroundColor(.white)
        view.sv(tableView, bottomView, bottomOffsetView)
        view.layout(
            0,
            |tableView|,
            0,
            |bottomView| ~ 49,
            0,
            |bottomOffsetView| ~ PublicSize.kBottomOffset,
            0
        )
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(loadData))
        tableView.mj_header = header
        configBottomView()
        configNodeView()
        configZBPopView()
        configNeedTimePopView()
        configReOrderPricePopView()
    }
    private let warrantyBtn = UIButton().text("发起质保").textColor(.kColor99).font(12).cornerRadius(4).borderColor(.kColor99).borderWidth(0.5)
    private let reOrderPriceBtn = UIButton().text("修改订单金额").textColor(.kColor99).font(12).cornerRadius(4).borderColor(.kColor99).borderWidth(0.5)
    // 确认订单
    private let sureOrderBtn = UIButton().text("确认订单").textColor(.kDF2F2F).font(12).cornerRadius(4).borderColor(.kDF2F2F).borderWidth(0.5)
    private func configBottomView() {
        // 发起质保
        
        bottomView.sv(warrantyBtn)
        warrantyBtn.width(80).height(30).centerVertically()-14-|
        warrantyBtn.addTarget(self, action: #selector(warrantyBtnClick(btn:)))
        warrantyBtn.isHidden = true
        // 修改订单金额
        
        bottomView.sv(reOrderPriceBtn, sureOrderBtn)
        reOrderPriceBtn.width(104).height(30).centerVertically()-15-sureOrderBtn.width(80).height(30).centerVertically()-14-|
        reOrderPriceBtn.addTarget(self, action: #selector(reOrderPriceBtnClick(btn:)))
        sureOrderBtn.addTarget(self, action: #selector(sureOrderBtnClick(btn:)))
        
        if UserData.shared.userType == .fws {
            warrantyBtn.isHidden = true
            reOrderPriceBtn.isHidden = false
            sureOrderBtn.isHidden = false
        } else {
            warrantyBtn.isHidden = true
            reOrderPriceBtn.isHidden = true
            sureOrderBtn.isHidden = true
            let orderState = "\(purchaseModel?.orderStatus ?? 0)"
            if orderState == "13" {
                warrantyBtn.isHidden = false
            } else if orderState == "3" {
                warrantyBtn.isHidden = false
                warrantyBtn.text("付款")
            }
        }
    }
    private let nodePopView = UIView().backgroundColor(.white)
    private var currentNodeIndex = 0
    private var isNodeOK = true
    private let okBtn = UIButton().image(#imageLiteral(resourceName: "login_check")).text(" 通过").textColor(.kColor33).font(14)
    private let noBtn = UIButton().image(#imageLiteral(resourceName: "login_uncheck")).text(" 不通过").textColor(.kColor33).font(14)
    func configNodeView() {
        nodePopView.frame = CGRect(x: 0, y: 0, width: 272, height: 154)
        let title = UILabel().text("节点验收").textColor(.kColor33).fontBold(14)
        
        let line1 = UIView().backgroundColor(.kColor220)
        let line2 = UIView().backgroundColor(.kColor220)
        let cancelBtn = UIButton().text("取消").textColor(.kColor33).font(14)
        let sureBtn = UIButton().text("确认").textColor(.kColor33).font(14)
        nodePopView.sv(title, okBtn, noBtn, line1, line2, cancelBtn, sureBtn)
        nodePopView.layout(
            25,
            title.height(20).centerHorizontally(),
            0,
            |okBtn.height(60)-0-noBtn.height(60)|,
            0,
            |line1| ~ 0.5,
            |cancelBtn-0-line2.width(0.5)-sureBtn|,
            0
        )
        equal(widths: okBtn, noBtn)
        equal(widths: cancelBtn,sureBtn)
        equal(heights: cancelBtn, line2, sureBtn)
        
        sureBtn.tag = 0
        okBtn.addTarget(self, action: #selector(okBtnClick(btn:)))
        noBtn.addTarget(self, action: #selector(noBtnClick(btn:)))
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(btn:)))
    }
    
    private let zbPopView = UIView().backgroundColor(.white)
    func configZBPopView() {
        zbPopView.frame = CGRect(x: 0, y: 0, width: 272, height: 164)
        let title = UILabel().text("发起质保").textColor(.kColor33).fontBold(14)
        let des = UILabel().text("发起质保后，此订单将变为待商家服务，是否进行质保？").textColor(.kColor33).fontBold(14)
        let line1 = UIView().backgroundColor(.kColor220)
        let line2 = UIView().backgroundColor(.kColor220)
        let cancelBtn = UIButton().text("取消").textColor(.kColor33).font(14)
        let sureBtn = UIButton().text("确认").textColor(.kColor33).font(14)
        des.numberOfLines(2).lineSpace(2)
        zbPopView.sv(title, des, line1, line2, cancelBtn, sureBtn)
        zbPopView.layout(
            25,
            title.height(20).centerHorizontally(),
            15,
            |-24-des-24-|,
            >=0,
            |line1| ~ 0.5,
            |cancelBtn.height(48.5)-0-line2.height(48.5).width(0.5)-sureBtn.height(48.5)|,
            0
        )
        equal(widths: cancelBtn,sureBtn)
        sureBtn.tag = 1
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(btn:)))
    }
    /// 确认工期
    private let needTimePopView = UIView().backgroundColor(.white)
    private var needTimeTextField = UITextField()
    func configNeedTimePopView() {
        needTimePopView.frame = CGRect(x: 0, y: 0, width: 272, height: 164)
        let title = UILabel().text("所需工期").textColor(.kColor33).fontBold(14)
        let textField = UITextField().backgroundColor(.kColorEE).cornerRadius(2)
        textField.keyboardType = .numberPad
        textField.clearButtonMode = .whileEditing
        textField.placeholder("请输入工期天数")
        textField.placeholderColor = .kColor99
        textField.textColor = .kColor33
        textField.font = .systemFont(ofSize: 13)
        textField.textAlignment = .center
        needTimeTextField = textField
        
        let dayLab = UILabel().text("天").textColor(.kColor33).fontBold(14)
        
        let line1 = UIView().backgroundColor(.kColor220)
        let line2 = UIView().backgroundColor(.kColor220)
        let cancelBtn = UIButton().text("取消").textColor(.kColor33).font(14)
        let sureBtn = UIButton().text("确认").textColor(.kColor33).font(14)
        needTimePopView.sv(title, textField, dayLab, line1, line2, cancelBtn, sureBtn)
        needTimePopView.layout(
            25,
            title.height(20).centerHorizontally(),
            17,
            |-49-textField.width(150).height(30)-10-dayLab-(>=0)-|,
            >=0,
            |line1| ~ 0.5,
            |cancelBtn.height(48.5)-0-line2.height(48.5).width(0.5)-sureBtn.height(48.5)|,
            0
        )
        equal(widths: cancelBtn,sureBtn)
        sureBtn.tag = 2
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(btn:)))
    }
    /// 修改订单金额
    private let reOrderPricePopView = UIView().backgroundColor(.white)
    func configReOrderPricePopView() {
        reOrderPricePopView.frame = CGRect(x: 0, y: 0, width: 272, height: 164)
        let title = UILabel().text("修改订单金额").textColor(.kColor33).fontBold(14)
        let textField = UITextField().backgroundColor(.kColorEE).cornerRadius(2)
        textField.keyboardType = .numberPad
        textField.clearButtonMode = .whileEditing
        textField.placeholder("请输入金额")
        textField.placeholderColor = .kColor99
        textField.textColor = .kColor33
        textField.font = .systemFont(ofSize: 13)
        textField.textAlignment = .center
        
        let dayLab = UILabel().text("元").textColor(.kColor33).fontBold(14)
        
        let line1 = UIView().backgroundColor(.kColor220)
        let line2 = UIView().backgroundColor(.kColor220)
        let cancelBtn = UIButton().text("取消").textColor(.kColor33).font(14)
        let sureBtn = UIButton().text("确认").textColor(.kColor33).font(14)
        reOrderPricePopView.sv(title, textField, dayLab, line1, line2, cancelBtn, sureBtn)
        reOrderPricePopView.layout(
            25,
            title.height(20).centerHorizontally(),
            17,
            |-49-textField.width(150).height(30)-10-dayLab-(>=0)-|,
            >=0,
            |line1| ~ 0.5,
            |cancelBtn.height(48.5)-0-line2.height(48.5).width(0.5)-sureBtn.height(48.5)|,
            0
        )
        equal(widths: cancelBtn,sureBtn)
        sureBtn.tag = 3
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(btn:)))
    }
    
}

extension ServiceOrderDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        cell.selectionStyle = .none
        let content = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
        cell.sv(content)
        cell.layout(
            0,
            |-14-content-14-|,
            0
        )
        switch indexPath.section {
        case 0:
            configCell0(content)
        case 1:
            configCell1(content)
        case 2:
            configCell2(content)
        case 3:
            configCell3(content)
        default:
            configCell4(content)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.kBackgroundColor)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.kBackgroundColor)
    }
}
// MARK: - cells
extension ServiceOrderDetailVC {
    func configCell0(_ v: UIView) {
        let titleLine = UIView()
        let titleLab = UILabel().text("订单信息").textColor(.kColor33).fontBold(14)
        let orderNo = UILabel().text("订单号：").textColor(.kColor66).font(12)
        let orderNo1 = UILabel().text(purchaseModel?.orderNo ?? "").textColor(.kColor66).font(12)
        let orderStatus = UILabel().text("订单状态：").textColor(.kColor66).font(12)
        let orderState = "\(purchaseModel?.orderStatus ?? 0)"
        let orderStatus1 = UILabel().text("待验收").textColor(.kColor66).font(12)
        let copyOrderNoBtn = UIButton().text(" 复制").textColor(.k1DC597).font(12).image(#imageLiteral(resourceName: "purchase_copy"))
        copyOrderNoBtn.tapped { [weak self] (btn) in
            if let valueStr = self?.purchaseModel?.orderNo {
                let paste = UIPasteboard.general
                paste.string = valueStr
                self?.noticeSuccess("订单号已复制")
            }else {
                self?.noticeOnlyText("订单号为空")
            }
        }
        AppData.serviceStatusTypes.forEach { (dic) in
            if orderState == Utils.getReadString(dir: dic, field: "value") {
                orderStatus1.text(Utils.getReadString(dir: dic, field: "label"))
            }
        }
        if UserData.shared.userType == .fws { // 服务商下，商家确认后隐藏掉
            if Int(orderState) ?? 0 == 2  {
                warrantyBtn.isHidden = true
                sureOrderBtn.isHidden = false
                reOrderPriceBtn.isHidden = false
                bottomView.isHidden = false
//                tableView.snp.updateConstraints { (make) in
//                    make.bottom.equalTo(bottomView.snp.top)
//                }
            } else {
               // tableView.Height == view.Height
                warrantyBtn.isHidden = true
                sureOrderBtn.isHidden  = true
                reOrderPriceBtn.isHidden = true
               // bottomView.isHidden = true
//                tableView.snp.updateConstraints { (make) in
//                    make.bottom.equalToSuperview()
//                }
            }
        } else { // 采购模式下，除质保中可发起质保，其他都隐藏掉
            if orderState != "13" && orderState != "3" {
                //tableView.Bottom == view.Bottom
                warrantyBtn.isHidden = true
                sureOrderBtn.isHidden = true
                reOrderPriceBtn.isHidden = true
                if orderState == "2" {
                    sureOrderBtn.text("取消订单")
                    sureOrderBtn.isHidden = false
                    bottomView.isHidden = false
//                    tableView.snp.updateConstraints { (make) in
//                        make.height.equalToSuperview().offset(-49-PublicSize.kBottomOffset)
//                    }
                } else {
                //    bottomView.isHidden = true
//                    tableView.snp.updateConstraints { (make) in
//                        make.height.equalToSuperview()
//                    }
                }
            } else {
                //tableView.Bottom == bottomView.Top
                if orderState == "13" {
                    warrantyBtn.text("发起质保")
                } else if orderState == "3" {
                    warrantyBtn.text("付款")
                }
                sureOrderBtn.isHidden = true
                warrantyBtn.isHidden = false
                bottomView.isHidden = false
//                tableView.snp.updateConstraints { (make) in
//                    make.height.equalToSuperview().offset(-49-PublicSize.kBottomOffset)
//                }
            }
        }
        
        let needTime = UILabel().text("所需工期：").textColor(.kColor66).font(12)
        let needTime1 = UILabel().text("\(purchaseModel?.timeLimit ?? "0")天").textColor(.kColor66).font(12)
        let time = UILabel().text("下单时间：").textColor(.kColor66).font(12)
        let time1 = UILabel().text(purchaseModel?.orderTime ?? "").textColor(.kColor66).font(12)
        let remark = UILabel().text("备注：").textColor(.kColor66).font(12)
        let remark1 = UILabel().text(purchaseModel?.remarks ?? "无").textColor(.kColor66).font(12).numberOfLines(0)
        remark1.lineSpace(2)
        v.sv(titleLab, titleLine, orderNo, copyOrderNoBtn, orderNo1, orderStatus, orderStatus1, needTime, needTime1, time, time1, remark, remark1)
        if ((purchaseModel?.timeLimit) != nil) {
            v.layout(
                17.5,
                |-15-titleLine.width(2).height(15)-5-titleLab.height(20),
                12.5,
                |-15-orderNo.height(16.5),
                5,
                |-15-orderStatus.height(16.5),
                5,
                |-15-needTime.height(16.5),
                5,
                |-15-time.height(16.5),
                5,
                |-15-remark.height(16.5),
                >=15
            )
            v.layout(
                45,
                |-77-orderNo1.height(16.5)-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-77-orderStatus1.height(16.5),
                5,
                |-77-needTime1.height(16.5),
                5,
                |-77-time1.height(16.5),
                5,
                |-77-remark1.height(>=16.5)-15-|,
                15
            )
            needTime.isHidden = false
            needTime1.isHidden = false
        } else {
            v.layout(
                17.5,
                |-15-titleLine.width(2).height(15)-5-titleLab.height(20),
                12.5,
                |-15-orderNo.height(16.5),
                5,
                |-15-orderStatus.height(16.5),
                5,
                |-15-time.height(16.5),
                5,
                |-15-remark.height(16.5),
                >=15
            )
            v.layout(
                45,
                |-77-orderNo1.height(16.5)-10-copyOrderNoBtn.width(42).height(20),
                5,
                |-77-orderStatus1.height(16.5),
                5,
                |-77-time1.height(16.5),
                5,
                |-77-remark1.height(>=16.5)-15-|,
                15
            )
            needTime.isHidden = true
            needTime1.isHidden = true
        }
        titleLine.fillGreenColor()
    }
    
    func configCell1(_ v: UIView) {
        let titleLine = UIView()
        let titleLab = UILabel().text("收货信息").textColor(.kColor33).fontBold(14)
        let cgfLab = UILabel().text("采购方：").textColor(.kColor66).font(12)
        let cgfLab1 = UILabel().text(purchaseModel?.storeName ?? "").textColor(.kColor66).font(12)
        let fwsLab = UILabel().text("服务商：").textColor(.kColor66).font(12)
        let fwsLab1 = UILabel().text(purchaseModel?.merchantName ?? "").textColor(.kColor66).font(12)
        let shrLab = UILabel().text("收货人：").textColor(.kColor66).font(12)
        let shrLab1 = UILabel().text(purchaseModel?.contact ?? "").textColor(.kColor66).font(12)
        let phone = UILabel().text("手机号：").textColor(.kColor66).font(12)
        let phone1 = UILabel().text(purchaseModel?.tel ?? "").textColor(.kColor66).font(12)
        let address = UILabel().text("地址：").textColor(.kColor66).font(12)
        let address1 = UILabel().text(purchaseModel?.address ?? "").textColor(.kColor66).font(12).numberOfLines(0)
        address1.lineSpace(2)
        let messageBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_message_btn")).text("联系买家").textColor(.k2FD4A7).font(10).borderColor(.k2FD4A7).borderWidth(0.5).cornerRadius(2)
        let phoneBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_phone_btn")).text("拨打买家电话").textColor(.k2FD4A7).font(10).borderColor(.k2FD4A7).borderWidth(0.5).cornerRadius(2)
        if UserData.shared.userType == .cgy {
            messageBtn.text("联系卖家")
            phoneBtn.text("拨打卖家电话")
        }
        
        v.sv(titleLab, titleLine, cgfLab, cgfLab1, fwsLab, fwsLab1, shrLab, shrLab1, phone, phone1, address, address1, messageBtn, phoneBtn)
        v.layout(
            17.5,
            |-15-titleLine.width(2).height(15)-5-titleLab.height(20),
            12.5,
            |-15-cgfLab.height(16.5),
            5,
            |-15-fwsLab.height(16.5),
            5,
            |-15-shrLab.height(16.5),
            5,
            |-15-phone.height(16.5),
            5,
            |-15-address.height(16.5),
            >=49
        )
        v.layout(
            45,
            |-77-cgfLab1.height(16.5),
            5,
            |-77-fwsLab1.height(16.5),
            5,
            |-77-shrLab1.height(16.5),
            5,
            |-77-phone1.height(16.5),
            5,
            |-77-address1.height(>=16.5)-15-|,
            10,
            |-16-messageBtn.width(69).height(24)-25-phoneBtn.width(89).height(24),
            15
        )
        messageBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        phoneBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        titleLine.fillGreenColor()
        messageBtn.addTarget(self, action: #selector(messageBtnClick(btn:)))
        phoneBtn.addTarget(self, action: #selector(phoneBtnClick(btn:)))
    }
    
    func configCell2(_ v: UIView) {
        let titleLine = UIView()
        let titleLab = UILabel().text("服务信息").textColor(.kColor33).fontBold(14)
        v.sv(titleLab, titleLine)
        v.layout(
            17.5,
            |-15-titleLine.width(2).height(15)-5-titleLab.height(20),
            >=0
        )
        titleLine.fillGreenColor()
        infoModel?.orderData?.enumerated().forEach { (item) in
            let index = item.offset
            let materialsModel = item.element
            let offsetY = 45 + (70) * index
            
            let btn = UIButton().backgroundColor(.white)
            v.sv(btn)
            v.layout(
                offsetY,
                |btn.height(60)|,
                >=15
            )
            let icon = UIImageView().image(#imageLiteral(resourceName: "home_case_btn_iv4")).backgroundColor(.kBackgroundColor)
            icon.addImage(materialsModel.materialsImageUrl)
            let title = UILabel().text(materialsModel.materialsName ?? "").textColor(.kColor33).font(14).numberOfLines(2)
            title.lineSpace(2)
            let price = UILabel().text("￥\(materialsModel.price ?? 0)").textColor(#colorLiteral(red: 0.9921568627, green: 0.6117647059, blue: 0.231372549, alpha: 1)).font(12)
            let materialsCount = Int(Double.init(string: materialsModel.materialsCount ?? "0") ?? 0)
            let num = UILabel().text("×\(materialsCount )").textColor(.kColor66).font(12)
            btn.sv(icon, title, price, num)
            |-15-icon.size(60).centerVertically()
            btn.layout(
                0,
                |-85-title-93.5-|,
                >=0
            )
            btn.layout(
                0,
                price.height(16.5)-15-|,
                5,
                num.height(16.5)-15-|,
                >=0
            )
            icon.contentMode = .scaleAspectFit
            icon.cornerRadius(2).masksToBounds()
            btn.tag = index
            btn.addTarget(self, action: #selector(serviceInfoBtnClick(btn:)))
        }
    }
    
    func configCell3(_ v: UIView) {
        let titleLine = UIView()
        let titleLab = UILabel().text("节点清单及费用").textColor(.kColor33).fontBold(14)
        v.sv(titleLab, titleLine)
        v.layout(
            17.5,
            |-15-titleLine.width(2).height(15)-5-titleLab.height(20),
            >=0
        )
        titleLine.fillGreenColor()
        infoModel?.nodeDataList?.enumerated().forEach { (item) in
            let index = item.offset
            let nodeDataModel = item.element
            let offsetY = 45 + (60) * index
            let btn = UIButton().backgroundColor(.white)
            v.sv(btn)
            v.layout(
                offsetY,
                |btn.height(50)|,
                >=15
            )
            let icon = UIImageView().image(#imageLiteral(resourceName: "loading_rectangle")).backgroundColor(.kBackgroundColor)
            
            if infoModel?.nodeDataList?.count == 2 {
                if index == 0 {
                    icon.image(#imageLiteral(resourceName: "service_mall_node1"))
                } else if index == 1 {
                    icon.image(#imageLiteral(resourceName: "service_mall_node2"))
                }
            } else if infoModel?.nodeDataList?.count == 3 {
                if index == 0 {
                    icon.image(#imageLiteral(resourceName: "service_mall_node3"))
                } else if index == 1 {
                    icon.image(#imageLiteral(resourceName: "service_mall_node4"))
                } else if index == 2 {
                    icon.image(#imageLiteral(resourceName: "service_mall_node5"))
                }
            }
            let lab1 = UILabel().text("所占比例:\(nodeDataModel.percent ?? 0)%").textColor(.kColor33).font(12)
            let lab2 = UILabel().text("金额:¥\(nodeDataModel.nodeMoney ?? 0)").textColor(.kColor33).font(12)
            let lab3 = UILabel().text("状态：\(nodeDataModel.nodeName ?? "")").textColor(.kColor33).font(12)
            // status 状态(1待完成(等待上传图片) 2待验收(已上传图片，待验收)  3已完成   4拒绝)
            switch nodeDataModel.status {
            case 1:
                lab3.text("状态：待完成")
            case 2:
                lab3.text("状态：待验收")
            case 3:
                lab3.text("状态：已完成")
            case 4:
                lab3.text("状态：拒绝")
            default:
                break
            }
            let nodeBtn = UIButton().text("节点验收").textColor(.white).font(10).backgroundColor(.k2FD4A7).cornerRadius(4).masksToBounds()
            if UserData.shared.userType == .fws {
                nodeBtn.text("上传图片")
                if purchaseModel?.orderStatus == 4 || purchaseModel?.orderStatus == 13 {
                    if nodeDataModel.status == 1 || nodeDataModel.status == 4 {
                        nodeBtn.backgroundColor(.k2FD4A7)
                        nodeBtn.isUserInteractionEnabled = true
                    } else {
                        nodeBtn.backgroundColor(.kColor99)
                        nodeBtn.isUserInteractionEnabled = false
                    }
                    
                } else {
                    if purchaseModel?.orderStatus == 12 && nodeDataModel.status == 4 {
                        nodeBtn.backgroundColor(.k2FD4A7)
                        nodeBtn.isUserInteractionEnabled = true
                    } else {
                        nodeBtn.backgroundColor(.kColor99)
                        nodeBtn.isUserInteractionEnabled = false
                    }
                    
                }
            } else {
                if nodeDataModel.status == 1 || nodeDataModel.status == 3 || nodeDataModel.status == 4 {
                    nodeBtn.backgroundColor(.kColor99)
                    nodeBtn.isUserInteractionEnabled = false
                }
            }
            
            let arrow = UIImageView().image(#imageLiteral(resourceName: "purchase_arrow"))
            btn.sv(icon, lab1, lab2, lab3, nodeBtn, arrow)
            |-15-icon.width(80).height(50).centerVertically()-(>=0)-arrow.width(5).height(9).centerVertically()-15-|
            btn.layout(
                0,
                |-105-lab1.height(16.5)-15-lab2.height(16.5),
                14.5,
                |-105-lab3.height(16.5)-15-nodeBtn.width(63).height(22),
                >=0
            )
            icon.contentMode = .scaleAspectFit
            icon.cornerRadius(2).masksToBounds()
            
            let nodeNameLab = UILabel().text(nodeDataModel.nodeName ?? "").textColor(.white).font(12)
            icon.sv(nodeNameLab)
            nodeNameLab.followEdges(icon)
            nodeNameLab.textAlignment = .center
            
            btn.tag = index
            nodeBtn.tag = index
            nodeBtn.addTarget(self , action: #selector(nodeBtnClick(btn:)))
            btn.addTarget(self, action: #selector(nodeInfoBtnClick(btn:)))
//            if UserData.shared.userType == .fws {
//                btn.addTarget(self, action: #selector(nodeBtnClick(btn:)))
//            } else {
//
//            }
            
            
        }
    }
    
    func configCell4(_ v: UIView) {
        let titleLine = UIView()
        let titleLab = UILabel().text("支付信息").textColor(.kColor33).fontBold(14)
        let lab1 = UILabel().text("订单金额：").textColor(.kColor66).font(12)
        let qualityMonty = String.init(format: "%.2f", infoModel?.qualityMoney?.floatValue ?? 0)
        let lab1_1 = UILabel().text("¥\(purchaseModel?.payMoney ?? 0) (含质保金\(qualityMonty)元)").textColor(.kColor66).font(12)
        let lab2 = UILabel().text("支付状态：").textColor(.kColor66).font(12)
        let lab2_1 = UILabel().text("未支付").textColor(.kColor66).font(12)
        let payTyps = AppData.purchaseOrderPayStatusList
        payTyps.forEach { (dic) in
            if "\(purchaseModel?.payStatus ?? 0)" == Utils.getReadString(dir: dic, field: "value") {
                lab2_1.text(Utils.getReadString(dir: dic, field: "label"))
            }
        }
        v.sv(titleLab, titleLine, lab1, lab1_1, lab2, lab2_1)
        v.layout(
            17.5,
            |-15-titleLine.width(2).height(15)-5-titleLab.height(20),
            10,
            |-15-lab1.width(65).height(16.5)-2-lab1_1.height(16.5),
            5,
            |-15-lab2.width(65).height(16.5)-2-lab2_1.height(16.5),
            15
        )
        titleLine.fillGreenColor()
    }
}

// MARK: - 按钮点击方法
extension ServiceOrderDetailVC {
    /// 节点验收
    @objc private func nodeBtnClick(btn: UIButton) {
        currentNodeIndex = btn.tag
        let model = infoModel?.nodeDataList?[btn.tag]
        if UserData.shared.userType == .fws {
            let vc = ServiceMallNodeImageAppVC()
            vc.nodeModel = model
            vc.refresh = {
                self.loadData()
            }
            navigationController?.pushViewController(vc)
        } else {
            pop = TLTransition.show(nodePopView, popType: TLPopTypeAlert)
        }
        
    }
    
    /// 服务信息
    @objc private func serviceInfoBtnClick(btn: UIButton) {
       // noticeOnlyText("点击了按钮")
    }
    
    /// 节点
    @objc private func nodeInfoBtnClick(btn: UIButton) {
        let nodeModel = infoModel?.nodeDataList?[btn.tag]
        if nodeModel?.status == 1 {
            noticeOnlyText("待服务商上传验收图片")
            return
        }
        let vc = ServiceMallNodeImageVC()
        vc.nodeModel = nodeModel
        navigationController?.pushViewController(vc)
    }
    
    /// 发起质保
    @objc private func warrantyBtnClick(btn: UIButton) {
        if btn.titleLabel?.text == "付款" {
            toPay()
        } else {
            pop = TLTransition.show(zbPopView, popType: TLPopTypeAlert)
        }
        
    }
    
    /// 修改订单金额
    @objc private func reOrderPriceBtnClick(btn: UIButton) {
        editOrderPriceAction()
       // pop = TLTransition.show(reOrderPricePopView, popType: TLPopTypeAlert)
    }
    
    /// 确认订单
    @objc private func sureOrderBtnClick(btn: UIButton) {
        if UserData.shared.userType == .fws {
            if purchaseModel?.orderStatus == 2 {
                pop = TLTransition.show(needTimePopView, popType: TLPopTypeAlert)
            }
        } else {
            if purchaseModel?.orderStatus == 2 {
                let alertAction = UIAlertController.init(title: "是否确认取消订单", message: nil, preferredStyle: .alert)
                
                alertAction.addAction(UIAlertAction.init(title: "是", style:.default, handler: { (alertPhpto) in
                    self.cancelOrderRequest()
                }))
                
                alertAction.addAction(UIAlertAction.init(title: "否", style: .cancel, handler: { (alertCancel) in
                    
                }))
                self.present(alertAction, animated: true, completion: nil)
            }
        }
    }
    
    /// 取消订单
    private func cancelOrderRequest() {
        var parameters: Parameters = [:]
        if let orderId = self.purchaseModel?.id {
            parameters["id"] = orderId
        }
        parameters["orderStatus"] = "8" // 订单取消
        let method: HTTPMethod = .put
        let urlStr = APIURL.purchaseOrderStatus
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("取消订单成功")
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.purchaseModel?.orderStatus = 8
                    self.goBackBlock?(self.purchaseModel)
                    self.navigationController?.popViewController()
                }
            }
        }) { (error) in
            
        }
    }
    
    /// 节点验证通过
    @objc private func okBtnClick(btn: UIButton) {
        isNodeOK = true
        okBtn.image(#imageLiteral(resourceName: "login_check"))
        noBtn.image(#imageLiteral(resourceName: "login_uncheck"))
    }
    /// 节点验证不通过
    @objc private func noBtnClick(btn: UIButton) {
        isNodeOK = false
        okBtn.image(#imageLiteral(resourceName: "login_uncheck"))
        noBtn.image(#imageLiteral(resourceName: "login_check"))
    }
    
    /// 节点验证取消
    @objc private func cancelBtnClick(btn: UIButton) {
        pop.dismiss()
    }
    
    /// 节点验证确认
    @objc private func sureBtnClick(btn: UIButton) {
        switch btn.tag {
        case 0: // 节点验收
            checkNodeRequest()
        case 1: // 发起质保
            warrantyRequest()
        case 2: // 所需工期
            sureOrderAction()
            break
        case 3: // 修改订单金额
            break
        default:
            break
        }
        pop.dismiss()
    }
    
    func checkNodeRequest() {
        let nodeModel = infoModel?.nodeDataList?[currentNodeIndex]
        var parameters = Parameters()
        parameters["id"] = nodeModel?.id
        if isNodeOK {
            parameters["status"] = 3
        } else {
            parameters["status"] = 4
        }
        
        YZBSign.shared.request(APIURL.checkNode + (nodeModel?.id ?? ""), method: .post, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.noticeOnlyText("该节点验证成功")
                self.loadData()
            }
        }) { (error) in
            
        }
    }
    
    func warrantyRequest() {
        let urlStr = APIURL.doWarranty + (purchaseModel?.id ?? "")
        YZBSign.shared.request(urlStr, method: .post, parameters: Parameters(), success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.noticeOnlyText("发起质保成功")
                self.loadData()
            }
        }) { (error) in
            
        }
    }
    
    @objc private func messageBtnClick(btn: UIButton) {
        if UserData.shared.userType == .cgy {
            let merchant = infoModel?.merchant
            self.updConsultNumRequest(id: purchaseModel?.merchantId ?? "")
            messageBtnClick(userId: purchaseModel?.merchantId, userName: merchant?.userName, storeName: merchant?.name, headUrl: merchant?.url, nickname: merchant?.userName, tel1: merchant?.mobile, tel2: "")
        } else if UserData.shared.userType == .fws {
            
            let urlStr = APIURL.getAppointUserInfo + (purchaseModel?.workerId ?? "")
            YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
                let model = BaseModel.deserialize(from: response)
                if model?.code == 0 {
                    let worker = Mapper<WorkerModel>().map(JSONObject: model?.data)
                    self.messageBtnClick(userId: worker?.id, userName: worker?.userName , storeName: worker?.storeName, headUrl: worker?.headUrl, nickname: worker?.userName, tel1: worker?.mobile, tel2: "")
                }
            }) { (error) in
                
            }
        }

    }
    
    
    
    @objc private func phoneBtnClick(btn: UIButton) {
        if UserData.shared.userType == .cgy {
            let merchant = infoModel?.merchant
            houseListCallTel(name: merchant?.name ?? "", phone: merchant?.mobile ?? "")
        } else if UserData.shared.userType == .fws {
            let worker = infoModel?.worker
            houseListCallTel(name: purchaseModel?.workerName ?? "", phone: worker?.mobile ?? "")
        }
    }
}
// MARK: - 接口请求
extension ServiceOrderDetailVC {
    ///返回
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    ///确认订单
    @objc func sureOrderAction(isCancel: Bool = false) {
        let method: HTTPMethod = .post
        let urlStr = APIURL.surePurchaseOrder
        self.pleaseWait()
        
        var parameters = Parameters()
        parameters["id"] = purchaseModel?.id
        parameters["timeLimit"] = needTimeTextField.text
        
        YZBSign.shared.request(urlStr, method: method, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                GlobalNotificationer.post(notification: .purchaseRefresh)
                self.pleaseWait()
                self.removeOrder()
                self.loadData()
            }
        }) { (error) in
            
        }
    }
    
    ///修改订单价
    @objc func editOrderPriceAction() {
        let money = self.purchaseModel?.payMoney?.doubleValue
        let moneyStr = "\(money ?? 0)"
        let remarkVC = RemarksViewController(title: "修改订单金额",money: moneyStr, remark: moneyStr)
        remarkVC.remarksType = .tel
        remarkVC.doneBlock = { (remarks, remarks2) in
            if let remarksStr = remarks {
                let  parameters: Parameters = ["payMoney": remarksStr, "id": self.orderId]
                AppLog("传参: \(parameters)")
                let urlStr = APIURL.editServiceOrderMoney
                self.pleaseWait()
                
                YZBSign.shared.request(urlStr, method: .put, parameters: parameters, success: { (response) in
                    
                    let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                    if errorCode == "0" {
                        self.noticeTop("修改成功", autoClear: true, autoClearTime: 1)
                        self.loadData()
                        
                    }
                    
                }) { (error) in
                    
                }
            } else {
                self.noticeOnlyText("未填写订单金额，放弃修改~")
            }
        }
        self.present(remarkVC, animated: true, completion:nil)
    }
    
    
    func editSpread(_ purchaseMaterial: PurchaseMaterialModel?) {
        
        let vc = AddSpreadController()
        vc.title = "修改补差价产品"
        vc.orderId =  orderId
        vc.purchaseMaterial = purchaseMaterial
        
        if (purchaseModel?.orderStatus == 1 || purchaseModel?.orderStatus == 2) && (UserData.shared.userType != .jzgs && UserData.shared.userType != .cgy) {
            vc.spreadType = .edit
        }else {
            vc.spreadType = .look
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 去付款
    @objc func toPay() {
//        let paySb = UIStoryboard.init(name: "PayStoryboard", bundle: nil)
//        let vc = paySb.instantiateViewController(withIdentifier: "PayTableViewController") as? PayTableViewController
//        vc?.payMoney = (self.purchaseModel?.payMoney?.doubleValue ?? 0)
//        vc?.purchaseModel = self.purchaseModel
//        vc?.purchaseOrderId = self.orderId
//        self.navigationController?.pushViewController(vc!, animated: true)
        
        let payMoney = (self.purchaseModel?.payMoney?.doubleValue ?? 0)
//        let vc = OrderPayVC()
//        vc.payMoney = payMoney
//        if checkCouponMoney > (payMoney / 10) {
//            vc.couponMoney = payMoney / 10
//            vc.isTip = true
//        } else {
//            vc.isTip = false
//            vc.couponMoney = checkCouponMoney
//        }
//        vc.allCouponMoney = checkCouponMoney
//        vc.couponIds = checkCouponIds
//        vc.purchaseModel = self.purchaseModel
//        vc.purchaseOrderId = self.orderId
//        self.navigationController?.pushViewController(vc, animated: true)
        let vc = OrderPayNewVC()
        vc.payMoney = payMoney
        vc.purchaseModel = self.purchaseModel ?? PurchaseOrderModel()
        vc.orderId = self.orderId
        vc.orderDatas = orderDatas
        vc.isServiceOrder = true
        self.navigationController?.pushViewController(vc)
    }
}
