//
//  MembershipLevelVC.swift
//  YZB_Company
//
//  Created by Cloud on 2020/2/17.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Then
import ObjectMapper

class MembershipLevelVC: BaseViewController {
    var orderId: String = ""
    var substationId = ""
    var userId = ""
    var infoModel: MembershipInfoModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "请选择会员等级"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        createSubViews()
        requestData()
    }
    
    let scrollView = UIScrollView().backgroundColor(.white)
    let vipView = UIButton().backgroundColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 0.1)).cornerRadius(10).borderColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1)).borderWidth(1)
    let normalView = UIButton().backgroundColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.1)).cornerRadius(10).borderColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)).borderWidth(1)
    var selectType = 1 // 1: vip会员 2： 普通会员
    let payBtn = UIButton().text("确认支付：¥3980").textColor(.white).font(14, weight: .bold).backgroundColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1)).cornerRadius(4)
    private func createSubViews() {
        view.sv(scrollView)
        scrollView.followEdges(view)
        scrollView.sv(vipView, normalView, payBtn)
        scrollView.layout(
            30,
            |-20-vipView-20-| ~ 233,
            30,
            |-20-normalView-20-| ~ 208,
            60,
            payBtn.width(210).height(44).centerHorizontally(),
            >=50
        )
        vipView.Width == scrollView.Width - 40
        normalView.Width == vipView.Width
        vipView.addTarget(self, action: #selector(vipViewClick))
        normalView.addTarget(self, action: #selector(normalViewClick))
        createVipViewSubViews()
        createNormalViewSubViews()
        payBtn.addTarget(self, action: #selector(payBtnClick))
    }
    
    let vipLab1 = UILabel().text("聚材道VIP会员").textColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1)).font(18, weight: .bold)
    let vipLab2 = UILabel().text("¥3980/年").textColor(#colorLiteral(red: 0.9647058824, green: 0.4078431373, blue: 0.2901960784, alpha: 1)).font(18, weight: .bold)
    let vipLab3 = UILabel().text("¥5980/年").textColor(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)).font(12, weight: .bold).then {
        $0.setLabelUnderline()
    }
    let vipImg4 = UIImageView().image("allow_icon")
    let vipLab4 = UILabel().text("系统使用版权").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(16)
    let vipImg5 = UIImageView().image("allow_icon")
    let vipLab5 = UILabel().text("酷家乐VIP账号1个").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(16)
    let vipImg6 = UIImageView().image("allow_icon")
    let vipLab6 = UILabel().text("酷家乐普通账号2个").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(16)
    let vipBottomView = UIView().backgroundColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1)).cornerRadius(10)
    
    private func createVipViewSubViews() {
        vipView.sv([vipLab1, vipLab2, vipLab3, vipImg4, vipImg5, vipImg6, vipLab4, vipLab5, vipLab6, vipBottomView])
        vipView.layout(
            20,
            |-20-vipLab1.height(25)-32-vipLab2.height(25)-10-vipLab3.height(17)-(>=0)-|,
            20,
            |-83-vipImg4.size(22)-10-vipLab4-(>=0)-|,
            16,
            |-83-vipImg5.size(22)-10-vipLab5-(>=0)-|,
            16,
            |-83-vipImg6.size(22)-10-vipLab6-(>=0)-|,
            20,
            |vipBottomView|,
            0
        )
        createVipBottomViewSubViews()
    }
    
    let vipBottomLab1 = UILabel().text("前350名立减2000元").textColor(.white).font(14, weight: .bold)
    let vipBottomLab2 = UILabel().text("（剩余名额：300个）").textColor(.white).font(10)
    private func createVipBottomViewSubViews() {
        vipBottomView.sv([vipBottomLab1, vipBottomLab2])
        vipBottomView.layout(
            5,
            vipBottomLab1.centerHorizontally().height(20),
            4,
            vipBottomLab2.centerHorizontally().height(14),
            >=0
        )
    }
    
    let normalLab1 = UILabel().text("聚材道普通会员").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(18, weight: .bold)
    let normalLab2 = UILabel().text("¥3980/年").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(18, weight: .bold)
    let normalImg4 = UIImageView().image("allow_icon_gray")
    let normalLab4 = UILabel().text("系统使用版权").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(16)
    let normalImg5 = UIImageView().image("unallow_icon")
    let normalLab5 = UILabel().text("酷家乐VIP账号1个").textColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)).font(16)
    let normalImg6 = UIImageView().image("allow_icon_gray")
    let normalLab6 = UILabel().text("酷家乐普通账号1个").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(16)
    func createNormalViewSubViews() {
        normalView.sv([normalLab1, normalLab2, normalImg4, normalImg5, normalImg6, normalLab4, normalLab5, normalLab6])
        normalView.layout(
            20,
            |-20-normalLab1.height(25)-32-normalLab2.height(25)-(>=0)-|,
            20,
            |-83-normalImg4.size(22)-10-normalLab4-(>=0)-|,
            16,
            |-83-normalImg5.size(22)-10-normalLab5-(>=0)-|,
            16,
            |-83-normalImg6.size(22)-10-normalLab6-(>=0)-|,
            >=0
        )
    }

}

extension MembershipLevelVC {
    @objc func vipViewClick() {
        _ = vipView.backgroundColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 0.1)).borderColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1))
        _ = vipLab1.textColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1))
        _ = vipLab2.textColor(#colorLiteral(red: 0.9647058824, green: 0.4078431373, blue: 0.2901960784, alpha: 1))
        _ = vipImg4.image("allow_icon")
        _ = vipImg5.image("allow_icon")
        _ = vipImg6.image("allow_icon")
        _ = vipBottomView.backgroundColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1))
        
        _ = normalView.backgroundColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.1)).borderColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        _ = normalLab1.textColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        _ = normalLab2.textColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        _ = normalImg4.image("allow_icon_gray")
        _ = normalImg6.image("allow_icon_gray")
        
        selectType = 1
        if infoModel?.hasActivity ?? false {
            payBtn.text("确认支付：¥\(infoModel?.vipCompanySellPrice ?? 0)")
        } else {
            payBtn.text("确认支付：¥\(infoModel?.vipCompanyPrice ?? 0)")
        }
    }
    
    @objc func normalViewClick() {
        _ = vipView.backgroundColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.1)).borderColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        _ = vipLab1.textColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        _ = vipLab2.textColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        _ = vipImg4.image("allow_icon_gray")
        _ = vipImg5.image("allow_icon_gray")
        _ = vipImg6.image("allow_icon_gray")
        _ = vipBottomView.backgroundColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1))
        
        _ = normalView.backgroundColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 0.1)).borderColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1))
        _ = normalLab1.textColor(#colorLiteral(red: 0.137254902, green: 0.6745098039, blue: 0.2196078431, alpha: 1))
        _ = normalLab2.textColor(#colorLiteral(red: 0.9647058824, green: 0.4078431373, blue: 0.2901960784, alpha: 1))
        _ = normalImg4.image("allow_icon")
        _ = normalImg6.image("allow_icon")
        
        selectType = 2
        payBtn.text("确认支付：¥\(infoModel?.companyPrice ?? 0)")
    }
    
    @objc func payBtnClick() {
        var payMoney = 0
        var payVipType = "vip"
        if selectType == 1 {
            payVipType = "vip"
            if infoModel?.hasActivity ?? false {
                payMoney = infoModel?.vipCompanySellPrice ?? 0
            } else {
                payMoney = infoModel?.vipCompanyPrice ?? 0
            }
        } else {
            payVipType = "general"
            payMoney = infoModel?.companyPrice ?? 0
        }
        let window = UIApplication.shared.keyWindow
        let popView = PayPopView(frame: window!.frame)
        popView.payBtnBlock = { [weak self] (type) in
            self?.payRequest(type: type, payVipType: payVipType, payMoney: payMoney)
        }
        window?.addSubview(popView)
    }
    
    func payRequest(type: Int, payVipType: String, payMoney: Int) {
        var payType = "upacp"
        switch type {
        case 1:
            payType = "upacp"
            break
        case 2:
            payType = "wx"
            break
        case 3:
            payType = "alipay"
            break
        default:
            payType = "upacp"
        }
        var parameters = [String: Any]()
        parameters["payType"] = payType
        parameters["payMoney"] = payMoney
        parameters["payVipType"] = payVipType
        parameters["userId"] = userId
        let url = APIURL.membershipPay
        YZBSign.shared.request(url, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataString = Utils.getReadString(dir: response as NSDictionary, field: "data")
                let dataDic = String.getDictionaryFromJSONString(jsonString: dataString)
                if let body = dataDic["body"] as? [String: Any] {
                    if let data = body["data"] as? [String: Any] {
                        if let charges = data["charges"] as? [String: Any] {
                            var jdataArray: Any!
                            if let jdata = charges["data"] as? [[String: Any]] {
                               jdataArray = jdata[0]
                            }
                            else if let jdata = charges["data"] as? [String: Any] {
                                jdataArray = jdata
                            }
                            let date = try! JSONSerialization.data(withJSONObject: jdataArray as Any, options: [])
                            let charge = NSString(data: date, encoding: String.Encoding.utf8.rawValue)
                            AppLog(charge!)
                            
                            self.switchThird(charge)
                            
                        }
                        
                    }
                }
                
            }
            else if errorCode == "001" {
                self.noticeOnlyText("订单号错误")
            }
        }) { (error) in
            
        }
    }
    
    // 第三方支付
    private func switchThird(_ charge: NSString!) {
        Pingpp.createPayment(charge as NSObject, viewController: self, appURLScheme: kAppURLScheme) { (result, error) -> Void in
            AppLog("=======: \(result!)")
            if error != nil {
                print(error!.getMsg()!)
                if error?.getMsg() == "用户取消操作" {
                    self.noticeOnlyText("支付取消")
                } else {
                    self.noticeOnlyText("支付失败")
                }
                return
            }
            self.noticeOnlyText("支付成功")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//    // 更新支付状态
//    private func updateOrder() {
//
//        YZBSign.shared.request(APIURL.updatePurchaseStatus, method: .post, parameters: ["orderId": orderId], success: { (response) in
//
//        }) { (err) in
//
//        }
//    }
}

extension MembershipLevelVC {
    private func requestData() {
        var parameters = [String: Any]()
        parameters["substationId"] = substationId
        YZBSign.shared.request(APIURL.getMembershipInfo, method: .get, parameters: parameters, success: { (res) in
            let errorCode = Utils.getReadString(dir: res as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: res as AnyObject)
                self.updateUI(dataDic)
            }
        }) { (error) in
            
        }
    }
    
    private func updateUI(_ dataDic: AnyObject) {
        infoModel = Mapper<MembershipInfoModel>().map(JSON: dataDic as! [String : Any])
        
        if infoModel?.hasActivity ?? false {
            vipLab2.text("¥\(infoModel?.vipCompanySellPrice ?? 0)/年")
            vipLab3.text("¥\(infoModel?.vipCompanyPrice ?? 0)/年")
            vipBottomLab1.text("前\(infoModel?.totalQuota ?? 0)名立减\(infoModel?.discountMoney ?? 0)元")
            let totalNum = infoModel?.totalQuota ?? 0
            let usedNum = infoModel?.usedQuota ?? 0
            let num = totalNum - usedNum
            vipBottomLab2.text("（剩余名额：\(num)个）")
            normalLab2.text("¥\(infoModel?.companyPrice ?? 0)/年")
            payBtn.text("确认支付：¥\(infoModel?.vipCompanySellPrice ?? 0)")
        } else {
            vipLab2.text("¥\(infoModel?.vipCompanyPrice ?? 0)/年")
            vipLab3.isHidden = true
            vipBottomView.isHidden = true
            normalLab2.text("¥\(infoModel?.companyPrice ?? 0)/年")
            payBtn.text("确认支付：¥\(infoModel?.vipCompanyPrice ?? 0)")
        }
        
        
    }
}


class MembershipInfoModel: NSObject, Mappable {
    var discountMoney: NSNumber?
    var companyPrice: Int?
    var hasActivity: Bool?
    var activityName: String?
    var vipCompanyPrice: Int?
    var usedQuota: Int?
    var totalQuota: Int?
    var lastQuota: Int?
    var vipCompanySellPrice: Int?
    var memberLevelList: [MembershipLevelModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        discountMoney <- map["discountMoney"]
        companyPrice <- map["companyPrice"]
        hasActivity <- map["hasActivity"]
        activityName <- map["activityName"]
        vipCompanyPrice <- map["vipCompanyPrice"]
        usedQuota <- map["usedQuota"]
        totalQuota <- map["totalQuota"]
        lastQuota <- map["lastQuota"]
        vipCompanySellPrice <- map["vipCompanySellPrice"]
        memberLevelList <- map["memberLevelList"]
    }
}


class MembershipLevelModel: NSObject, Mappable {
    var commonNum : Int?
    var couponAmount : NSNumber?
    var couponId : String?
    var couponNum : Int?
    var createBy : String?
    var createDate : String?
    var id : String?
    var isGive : String?
    var level : String?
    var levelName : String?
    var memberFee : NSNumber?
    var remarks : String?
    var updateBy : String?
    var updateDate : String?
    var vipNum : Int?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        commonNum <- map["commonNum"]
        couponAmount <- map["couponAmount"]
        couponId <- map["couponId"]
        couponNum <- map["couponNum"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        id <- map["id"]
        isGive <- map["isGive"]
        level <- map["level"]
        levelName <- map["levelName"]
        memberFee <- map["memberFee"]
        remarks <- map["remarks"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        vipNum <- map["vipNum"]
    }
}
