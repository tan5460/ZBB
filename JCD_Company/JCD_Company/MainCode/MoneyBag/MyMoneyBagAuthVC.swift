//
//  MyMoneyBagAuthVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/19.
//

import UIKit

class MyMoneyBagAuthVC: BaseViewController, AliPayBack {
    var openId: String?
    var type: String?
    private var authInfoStr = ""
    private var authCode = ""
    func finish(_ result: String?) {
        let resultArr = result?.components(separatedBy: "&")
        resultArr?.forEach({ (str) in
            if str.length > 15 && str.hasPrefix("alipay_open_id=") {
                self.openId = str.subString(from: 15)
                self.type = "2"
                self.tableView.reloadData()
            } else if str.hasPrefix("auth_code=") {
                self.authCode = str.subString(from: 10)
                self.authBindZFBRequest()
            }
        })
    }
    
    func failed() {
        
    }
    private var zfbImg: String?
    private var zfbNickName: String?
    var currentBindModel: AuthAppUserInfoModel?
    //MARK: - 授权绑定支付宝
    func authBindZFBRequest() {
        self.pleaseWait()
        var parameters = Parameters()
        parameters["authCode"] = authCode
        YZBSign.shared.request(APIURL.authBindZFB, method: .post, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                self.noticeOnlyText("授权成功")
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.zfbImg = dataDic["bindUserIcon"] as? String
                self.zfbNickName = dataDic["nickName"] as? String
                self.tableView.reloadData()
            }
            
        } failure: { (error) in
            
        }
    }
    
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.kBackgroundColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "结算账户"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
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
    }

}


extension MyMoneyBagAuthVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            configRow0(cell: cell)
        case 1:
            configRow1(cell: cell)
        case 2:
            configRow2(cell: cell)
        default:
            break
        }
        return cell
    }
    
    func configRow0(cell: UITableViewCell) {
        let line = UIView()
        let titleLabel = UILabel().text("结算授权").textColor(.kColor33).fontBold(14)
        cell.sv(line, titleLabel)
        cell.layout(
            17.5,
            |-14-line.width(2).height(15)-5-titleLabel,
            12.5
        )
        line.fillGreenColor()
    }
    
    func configRow1(cell: UITableViewCell) {
        let icon = UIImageView().image(#imageLiteral(resourceName: "login_zfb"))
        let titleLabel = UILabel().text("支付宝").textColor(.kColor33).font(14)
        let authBtn = UIButton().text("未授权").textColor(.kDF2F2F).font(12).cornerRadius(4).masksToBounds().borderWidth(0.5).borderColor(.kDF2F2F)
        
        cell.sv(icon, titleLabel, authBtn)
        cell.layout(
            10,
            |-14-icon.size(40)-10-titleLabel-(>=0)-authBtn.width(60).height(24)-14-|,
            10
        )
        if let model = currentBindModel, model.type == "2" {
            titleLabel.text(model.bindUserName ?? "")
            authBtn.text("重新授权").textColor(.k1DC597).font(12).cornerRadius(4).masksToBounds().borderWidth(0.5).borderColor(.k1DC597)
         //   authBtn.isUserInteractionEnabled = false
        }
        
        if zfbNickName != nil {
            titleLabel.text(zfbNickName ?? "")
            authBtn.text("重新授权").textColor(.k1DC597).font(12).cornerRadius(4).masksToBounds().borderWidth(0.5).borderColor(.k1DC597)
           // authBtn.isUserInteractionEnabled = false
        }
        authBtn.tapped { [weak self] (tapBtn) in
            self?.authRequest()
           // self?.doAPAuth()
        }
    }
    //MARK: - 授权支付宝获取openid。authcode
    func authRequest() {
        let para = Parameters()
        self.pleaseWait()
        YZBSign.shared.request(APIURL.authZFB, method: .post, parameters: para) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataStr = Utils.getReadString(dir: response as NSDictionary, field: "data")
                self.authInfoStr = dataStr
                self.doAPAuth()
            }
        } failure: { (error) in
            
        }
    }
        

    
    //MARK: - 点击支付宝授权登录
        func doAPAuth() {
            if !authInfoStr.isEmpty {
                AliPayUtils.login(signStr: authInfoStr, aliAuthBack: self)
            } else {
                self.noticeOnlyText("支付宝签名失败")
            }
        }
    
    func configRow2(cell: UITableViewCell) {
        let icon = UIImageView().image(#imageLiteral(resourceName: "login_wechat"))
        let titleLabel = UILabel().text("微信").textColor(.kColor33).font(14)
        let authBtn = UIButton().text("未授权").textColor(.kColor99).font(12).cornerRadius(4).masksToBounds().borderWidth(0.5).borderColor(.kColor99)
        
        cell.sv(icon, titleLabel, authBtn)
        cell.layout(
            10,
            |-14-icon.size(40)-10-titleLabel-(>=0)-authBtn.width(60).height(24)-14-|,
            10
        )
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
