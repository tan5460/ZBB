//
//  OrderPayVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/25.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import TLTransitions

class OrderPayVC: BaseViewController {
    private var pop: TLTransition?
    var citySubstationID: String! = ""
    var isRegister: Bool = false
    var payMoney: Double = 0
    var isTip = false
    var allCouponMoney: Double = 0
    var couponMoney: Double = 0
    var couponIds: String = ""

    var purchaseOrderId = ""
    var platServiceMoneyRate: NSNumber = 0
    var platformTradServiceMoney: NSNumber = 0
    var registerID: String?
    var purchaseModel: PurchaseOrderModel?
    var tel: String?
    var isContinue: Bool = false
    var params: [String: Any] = [:]
    private var exchangeLessMoney: String = "未开户"
    private var payMethod = "upacp" // alipay wx balance
    private var realPrice: Double = 0
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    private var checkBtns: [UIButton] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单支付"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        loadLessMoeny()
        fetchVipMoney(citySubstationID)
    }
    
    // 加载余额
    func loadLessMoeny() {
        if isRegister { return }
        let urlStr = APIURL.lessMoney
              
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { [unowned self](response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "008" {
                // 未开户
                self.exchangeLessMoney = "未开户"
            }
            else if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let accountModel = Mapper<OpenAccountInfoModel>().map(JSON: dataDic as! [String : Any])
                
                let balance = accountModel?.availableBalance?.doubleValue ?? 0
                
                self.exchangeLessMoney = "\(balance)"
                self.exchangeLessMoney = "剩余：￥\(((self.exchangeLessMoney as NSString?)?.doubleValue ?? 0).notRoundingString(afterPoint: 2))元"
            }
            self.tableView.reloadData()
        }) { (error) in
            
        }
    }

    // 获取会员w费
    func fetchVipMoney(_ stationID: String) {
        if isRegister == false { return }
        YZBSign.shared.request(APIURL.getVipMoney, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let money = Utils.getReadString(dir: response as NSDictionary, field: "data")
                self.payMoney = (Double.init(string: money) ?? 0)
                self.tableView.reloadData()
            }
        }) { (r) in
            
        }
        
    }
}

extension OrderPayVC {
    func configSection0(_ v: UITableViewCell) {
        let vLine = UIView()
        let title = UILabel().text("支付信息").textColor(.kColor33).fontBold(14)
        let line = UIView().backgroundColor(UIColor.hexColor("#DEDEDE"))
        let goodsPriceDes = UILabel().text("商品金额：").textColor(.kColor33).font(12)
        let goodsPrice = UILabel().text("¥\(purchaseModel?.supplyMoney?.doubleValue ?? 0)").textColor(.kColor33).font(12)
        let servicePriceDes = UILabel().text("服务费：").textColor(.kColor33).font(12)
        let servicePrice = UILabel().text("¥\(purchaseModel?.serviceMoney?.doubleValue ?? 0)").textColor(.kColor33).font(12)
        let deductionPriceDes = UILabel().text("金额抵扣：").textColor(.kColor33).font(12)
        let deductionPrice = UILabel().text("-¥\(couponMoney)").textColor(.kColor33).font(12)
        let priceDes = UILabel().text("实付金额：").textColor(.kColor33).font(12)
        
        let payMoney = purchaseModel?.payMoney?.doubleValue ?? 0
        let payMoneyD = Decimal.init(payMoney)
        let couponMoneyD = Decimal.init(couponMoney)
        let realPriceD = payMoneyD - couponMoneyD
        realPrice = Double.init(string: "\(realPriceD)") ?? 0
        let price = UILabel().text("¥\(realPriceD)").textColor(UIColor.hexColor("#EC632A")).font(12)
        v.sv(vLine, title, line, goodsPriceDes, goodsPrice, servicePriceDes, servicePrice, deductionPriceDes, deductionPrice, priceDes, price)
        v.layout(
            17.5,
            |-14-vLine.width(2).height(15)-5-title,
            12,
            |-14-line.height(0.5)-14-|,
            10.5,
            |-14-goodsPriceDes.width(62).height(16.5)-14-goodsPrice,
            5,
            |-14-servicePriceDes.width(62).height(16.5)-14-servicePrice,
            5,
            |-14-deductionPriceDes.width(62).height(16.5)-14-deductionPrice,
            5,
            |-14-priceDes.width(62).height(16.5)-14-price,
            15
        )
        vLine.width(2).height(15)
        vLine.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.11, green: 0.77, blue: 0.59, alpha: 1).cgColor, UIColor(red: 0.38, green: 0.85, blue: 0.72, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = vLine.bounds
        bgGradient.startPoint = CGPoint(x: 0.5, y: 0)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 1)
        vLine.layer.insertSublayer(bgGradient, at: 0)
    }
    
    func configSection1(_ v: UITableViewCell) {
        let vLine = UIView()
        let title = UILabel().text("选择支付方式").textColor(.kColor33).fontBold(14)
        v.sv(vLine, title)
        v.layout(
        17.5,
        |-14-vLine.width(2).height(15)-5-title,
        >=0
        )
        let icons = [#imageLiteral(resourceName: "pay_type_icon1"), #imageLiteral(resourceName: "pay_type_icon2"), #imageLiteral(resourceName: "pay_type_icon3"), #imageLiteral(resourceName: "pay_type_icon4")]
        let payTypes = ["银联支付", "微信支付", "支付宝支付", "余额支付"]
        icons.enumerated().forEach { (item) in
            let index = item.offset
            let icon = item.element
            let offsetY: CGFloat = 44.5 + CGFloat(60*index)
            let btn = UIButton()
            v.sv(btn)
            v.layout(
                offsetY,
                |btn|,
                >=0
            )
            let line = UIView().backgroundColor(UIColor.hexColor("#DEDEDE"))
            let iconIV = UIImageView().image(icon)
            let payTypeLab = UILabel().text(payTypes[index]).textColor(.kColor33).fontBold(14)
            let checkBtn = UIButton()
            checkBtn.setImage(#imageLiteral(resourceName: "login_check"), for: .selected)
            checkBtn.setImage(#imageLiteral(resourceName: "login_uncheck"), for: .normal)
            btn.sv(line, iconIV, payTypeLab, checkBtn)
            if index == 3 {
                let statusLab = UILabel().text(exchangeLessMoney).textColor(.kColor99).fontBold(12)
                btn.sv(statusLab)
                btn.layout(
                    0,
                    |-14-line.height(0.5)-14-|,
                    20.5,
                    |-24-iconIV.size(20)-5-payTypeLab-5-statusLab-(>=0)-checkBtn.size(40)-14-|,
                    19.5
                )
            } else {
                btn.layout(
                    0,
                    |-14-line.height(0.5)-14-|,
                    20.5,
                    |-24-iconIV.size(20)-5-payTypeLab-(>=0)-checkBtn.size(40)-14-|,
                    19.5
                )
            }
            
            checkBtn.tag = index
            btn.tag = index
            btn.addTarget(self, action: #selector(checkBtnClick(btn:)))
            checkBtn.addTarget(self, action: #selector(checkBtnClick(btn:)))
            checkBtns.append(checkBtn)
            if exchangeLessMoney == "未开户" && index == 3 {
                btn.isEnabled = false
                checkBtn.isEnabled = false
            } else {
                btn.isEnabled = true
                checkBtn.isEnabled = true
            }
            if payMethod == "upacp" && index == 0 {
                checkBtn.isSelected = true
            }
        }
    }
    
    @objc private func checkBtnClick(btn: UIButton) {
        checkBtns.forEach { (btn1) in
            if btn1.tag == btn.tag {
                btn1.isSelected = true
            } else {
                btn1.isSelected = false
            }
        }
        switch btn.tag {
        case 0:
            payMethod = "upacp"
        case 1:
            payMethod = "wx"
        case 2:
            payMethod = "alipay"
        case 3:
            payMethod = "balance"
        default:
            payMethod = "upacp" // alipayNoUTDID wx
        }
    }
    
    func configSection2(_ v: UITableViewCell) {
        let surePayBtn = UIButton().text("确认支付 ¥\(realPrice)").textColor(.white).font(14).cornerRadius(5).masksToBounds()
        v.sv(surePayBtn)
        v.layout(
            40,
            surePayBtn.width(280).height(40).centerHorizontally(),
            100
        )
        surePayBtn.width(280).height(40)
        surePayBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.11, green: 0.77, blue: 0.59, alpha: 1).cgColor, UIColor(red: 0.38, green: 0.85, blue: 0.72, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = surePayBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        surePayBtn.layer.insertSublayer(bgGradient, at: 0)
        surePayBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        
    }
    
    @objc private func sureBtnClick(btn: UIButton) {
        if isTip {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: 272, height: 184)).backgroundColor(.white)
            let titleLab = UILabel().text("支付提醒").textColor(.kColor33).fontBold(14)
            let tipLab = UILabel().text("已选择代金券面额\(allCouponMoney)元，当前订单仅抵扣了\(couponMoney)元，剩余券额将不设找零，是否继续使用？").textColor(.kColor33).font(14)
            let closePopBtn = UIButton().text("关闭").textColor(.kColor33).font(14).borderColor(UIColor.hexColor("#F0F0F0")).borderWidth(0.5)
            let surePopBtn = UIButton().text("继续").textColor(UIColor.hexColor("#1DC597")).font(14).borderColor(UIColor.hexColor("#F0F0F0")).borderWidth(0.5)
            v.sv(titleLab, tipLab, closePopBtn, surePopBtn)
            v.layout(
                25,
                titleLab.height(20).centerHorizontally(),
                15,
                tipLab.width(224).centerHorizontally(),
                >=0,
                |-0-closePopBtn.height(48.5)-0-surePopBtn.height(48.5)-0-|,
                0
            )
            tipLab.numberOfLines(0).lineSpace(2)
            closePopBtn.addTarget(self, action: #selector(closePopBtnClick(btn:)))
            surePopBtn.addTarget(self, action: #selector(surePopBtnClick(btn:)))
            equal(widths: closePopBtn, surePopBtn)
            pop = TLTransition.show(v, popType: TLPopTypeAlert)
        } else {
            surePopBtnClick(btn: UIButton())
        }
    }
    
    @objc private func closePopBtnClick(btn: UIButton) {
        pop?.dismiss()
        
    }
    
    @objc private func surePopBtnClick(btn: UIButton) {
        pop?.dismiss()
        AppLog("支付")

        // wx alipay
        var params: Parameters = ["payType": payMethod]
        var url = APIURL.orderPay
        params["discountMoney"] = couponMoney
        params["couponIds"] = couponIds
        if isContinue {
            params = self.params
        }
        else {
            if isRegister {
                params["userId"] = registerID ?? ""
                url = APIURL.vipPay
            }
            else {
                params["orderId"] = purchaseOrderId
            }
            
            if payMethod == "balance" {
                guard let window = UIApplication.shared.keyWindow else { return }
                let popView = GetPhoneCodeToPayView(frame: window.frame)
                popView.tel = tel
                popView.mobile = self.purchaseModel?.store?.mobile
                var par = params
                popView.blockff = { (code) in
                    par["code"] = code
                    self.params = par
                    self.isContinue = true
                    self.sureBtnClick(btn: btn)
                }
                popView.config()
                window.addSubview(popView)
                return
            }
        }
        YZBSign.shared.request(url, method: .post, parameters: params, success: { (response) in
            AppLog(response)
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            let errorMsg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
            self.clearAllNotice()
            if errorCode == "0" {
                
                if self.payMethod == "balance" {
                    AppLog("展示结果")
                    self.alert("余额支付成功")
                    self.updateOrder()
                    return
                }
                let dataString = Utils.getReadString(dir: response as NSDictionary, field: "data")
                let responseDic = String.getDictionaryFromJSONString(jsonString: dataString)
                if let body = responseDic["body"] as? [String: Any] {
                    if let data = body["data"] as? [String: Any] {
                        if let charges = data["charges"] as? [String: Any] {
                            var jdataArray: Any!
                            if let jdata = charges["data"] as? [[String: Any]] {
                               jdataArray = jdata[0]
                            }
                            else if let jdata = charges["data"] as? [String: Any] {
                                jdataArray = jdata
                            }
                            if jdataArray == nil {
                                self.alert("获取支付状态异常，请重试")
                            }
                            let date = try! JSONSerialization.data(withJSONObject: jdataArray as Any,options: [])
                            let charge = NSString(data: date, encoding: String.Encoding.utf8.rawValue)
                            AppLog(charge!)
                            
                            if self.payMethod != "balance" {
                                self.switchThird(charge)
                            }
                        }
                    }
                }
            }
            else if errorCode == "001" {
                self.alert("订单号错误")
            } else {
                UIApplication.shared.windows.first?.noticeOnlyText(errorMsg)
            }
        }) { (erro) in
            AppLog(erro)
        }
    }
    
    func alert(_ info: String) {
        var t = info
        var m: String! = nil
        if info == "余额支付成功" {
            t = "支付成功"
            m = "请稍后查看支付状态"
        }
        else if info == "订单号错误" {
            self.noticeOnlyText(info)
            return
        }
        
        let popup = PopupDialog(title: t, message:m, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

        var titl = "确定"
        if info == "支付成功" {
            titl = "已支付"
        }
        else if info == "支付失败" {
            titl = "取消"
        }
        else if info == "余额支付成功" {
            titl = "确定"
        }
        
        let sureBtn = AlertButton(title: titl) {
            if let viewControllers = self.navigationController?.viewControllers {
                for viewController in viewControllers {
                    if let vc = viewController as? PurchaseDetailController {
                        vc.isPayQuery = true
                    }
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
        popup.addButtons([sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    // 更新支付状态
    private func updateOrder() {
        var parameters = Parameters()
        parameters["id"] = purchaseOrderId
        parameters["payStatus"] = 3
        YZBSign.shared.request(APIURL.updatePurchaseStatus, method: .put, parameters: ["id": purchaseOrderId], success: { (response) in
           // self.vc.navigationController?.popViewController(animated: true)
            
        }) { (err) in
            
        }
    }
    
    // 第三方支付
    private func switchThird(_ charge: NSString!) {
        Pingpp.createPayment(charge as NSObject, viewController: self, appURLScheme: kAppURLScheme) { (result, error) -> Void in
            AppLog("=======: \(result!)")
            if error != nil {
                print(error!.getMsg()!)
                if error?.getMsg() == "用户取消操作" {
                    self.alert("支付取消")
                } else {
                    self.alert("支付失败")
                }
                return
            }
            self.alert("支付成功")
            self.updateOrder()
        }
    }
}

extension OrderPayVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            configSection0(cell)
        } else if indexPath.section == 1 {
            configSection1(cell)
        } else if indexPath.section == 2 {
            configSection2(cell)
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}



