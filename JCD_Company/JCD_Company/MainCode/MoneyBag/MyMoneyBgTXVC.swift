//
//  MyMoneyBgTXVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/19.
//

import UIKit
import TLTransitions
import ObjectMapper

class MyMoneyBgTXVC: UIViewController {
    var infoModel: MoneyBagInfoModel?
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.white)
    private var pop: TLTransition?
    private let amountTF = UITextField()
    private var currentBindModel: AuthAppUserInfoModel?
    private var txAmount: Decimal?
    private let sureBtn = UIButton().text("提现").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "sure_btn_gray"))
    private var isLoadTX = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let txRecordBtn = UIButton().text("提现记录").textColor(.k1DC597).font(15)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: txRecordBtn)
        txRecordBtn.tapped { [weak self] (tapBtn) in
            let vc = MyMoneyBagTXRecordVC()
            self?.navigationController?.pushViewController(vc)
        }
        
        title = "提现"
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAppBindList()
    }
    
    private var bindList: [AuthAppUserInfoModel] = []
    func getAppBindList() {
        YZBSign.shared.request(APIURL.jcdUserAppBindList, method: .get, parameters: Parameters()) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataArr = Utils.getReadArrDic(data: response as NSDictionary, field: "data") as! [[String: Any]]
                self.bindList = Mapper<AuthAppUserInfoModel>().mapArray(JSONArray: dataArr)
                self.currentBindModel = self.bindList.first
                if self.currentBindModel == nil {
                    self.toBindPopView()
                }
                self.tableView.reloadData()
            } else if code == "10010" {
                
            }
        } failure: { (error) in
            
        }

    }
    
    func toBindPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 272, height: 210)).backgroundColor(.white)
        let icon = UIImageView().image(#imageLiteral(resourceName: "qb_tip_icon"))
        let titleLabel = UILabel().text("暂未绑定结算账户，请前往绑定结算账户").textColor(.kColor66).font(12)
        let line1 = UIView().backgroundColor(.kColor220)
        let line2 = UIView().backgroundColor(.kColor220)
        let cancelBtn = UIButton().text("暂不前往").textColor(.kColor33).font(14)
        let sureBtn = UIButton().text("立即前往").textColor(.k1DC597).font(14)
        
        v.sv(icon, titleLabel, line1, line2, cancelBtn, sureBtn)
        v.layout(
            15.5,
            icon.size(105).centerHorizontally(),
            4,
            titleLabel.height(16.5).centerHorizontally(),
            20,
            |line1.height(0.5)|,
            0,
            |cancelBtn.height(49)-0-line2.width(0.5).height(49)-0-sureBtn.height(49)|,
            0
        )
        equal(widths: cancelBtn, sureBtn)
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
        
        cancelBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss()
        }
        
        sureBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss(completion: {
                self?.enterAuthVC()
            })
        }
    }
    
    func enterAuthVC() {
        let vc = MyMoneyBagAuthVC()
        vc.currentBindModel = currentBindModel
        self.navigationController?.pushViewController(vc)
    }
}

extension MyMoneyBgTXVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            configSection0(cell: cell)
        }
        return cell
    }
    
    func configSection0(cell: UITableViewCell) {
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            15,
            |-14-v.height(285)-14-|,
            10
        )
        v.cornerRadius(10).addShadowColor()
        
        let topView = UIView().backgroundColor(UIColor.hexColor("#F7F7F7"))
        v.sv(topView)
        v.layout(
            0,
            |topView.height(50)|,
            >=0
        )
        
        let lab1 = UILabel().text("提现到").textColor(.kColor33).font(14)
        let txAccountBtn = UIButton()
        topView.sv(lab1, txAccountBtn)
        topView.layout(
            15,
            |-15-lab1.height(20)-(>=0)-txAccountBtn.height(50)-0-|,
            15
        )
        
        if self.bindList.count == 0 {
            let txAccountLabel = UILabel().text("绑定结算账户").textColor(.k1DC597).font(14)
            let txAccountArrow = UIImageView().image(#imageLiteral(resourceName: "arrow_green"))
            txAccountBtn.sv(txAccountLabel, txAccountArrow)
            txAccountBtn.layout(
                15,
                |-0-txAccountLabel-6-txAccountArrow.width(6).height(11)-14-|,
                15
            )
            txAccountBtn.tapped { [weak self] (tapBtn) in
                self?.enterAuthVC()
            }
        } else {
            let txAccountIcon = UIImageView().image(#imageLiteral(resourceName: "login_zfb"))
            let txAccountLabel = UILabel().text("\(currentBindModel?.bindUserName ?? "")").textColor(.kColor33).font(14)
            let txAccountArrow = UIImageView().image(#imageLiteral(resourceName: "arrow_right"))
            txAccountBtn.sv(txAccountIcon, txAccountLabel, txAccountArrow)
            txAccountBtn.layout(
                15,
                |-0-txAccountIcon.size(20)-4-txAccountLabel-6-txAccountArrow.width(6).height(11)-14-|,
                15
            )
            txAccountBtn.tapped { [weak self] (tapBtn) in
                self?.bingOtherAccountPopView()
            }
        }
        
        
        
        let txAmountLabel = UILabel().text("提现金额").textColor(.kColor33).fontBold(16)
        let amountLabel = UILabel().text("¥").textColor(.kColor33).fontBold(22)
        
        let txBalanceLabel = UILabel().text("可提现余额:").textColor(.kColor33).font(12)
        let line = UIView().backgroundColor(.kColor220)
        
        let balanceLabel = UILabel().text("¥\(infoModel?.accountAmount?.doubleValue ?? 0)").textColor(.k1DC597).font(12)
        let allTxBtn = UIButton().text("全部提现").textColor(.k1DC597).font(12)
        
        v.sv(txAmountLabel, amountLabel, amountTF, line, txBalanceLabel, balanceLabel, allTxBtn, sureBtn)
        v.layout(
            65,
            |-15-txAmountLabel.height(22.5),
            15,
            |-15-amountLabel.height(31)-10-amountTF.height(30)-10-|,
            15,
            |-15-line.height(0.5)-15-|,
            10,
            |-15-txBalanceLabel.height(16.5)-2-balanceLabel.height(16.5)-(>=0)-allTxBtn.height(30)-15-|,
            30,
            sureBtn.width(280).height(40).centerHorizontally(),
            40
        )
        amountTF.clearButtonMode = .whileEditing
        amountTF.keyboardType = .decimalPad
        amountTF.fontBold(22)
        amountTF.delegate = self
        if let amount = txAmount {
            amountTF.text("\(amount)")
        }
        amountTF.addTarget(self, action: #selector(textFieldEditChange(textField:)), for: .editingChanged)
        
        allTxBtn.tapped { [weak self] (tapBtn) in
            let accountAmount = self?.infoModel?.accountAmount?.doubleValue ?? 0.0
            self?.txAmount = Decimal.init(string: "\(accountAmount)")
            self?.tableView.reloadData()
            if self?.txAmount ?? 0 <= 0 {
                self?.sureBtn.isUserInteractionEnabled = false
                self?.sureBtn.backgroundImage(#imageLiteral(resourceName: "sure_btn_gray"))
            } else {
                self?.sureBtn.isUserInteractionEnabled = true
                self?.sureBtn.backgroundImage(#imageLiteral(resourceName: "regiest_next_btn"))
            }
        }
        
        sureBtn.tapped { [weak self] (tapBtn) in
            self?.txRequest()
        }
    }
    
    @objc func textFieldEditChange(textField: UITextField) {
        if textField == amountTF {
            let amount = textField.text ?? "0"
            txAmount = Decimal.init(string: amount)
            if txAmount != 0 && currentBindModel != nil && txAmount != nil {
                sureBtn.isUserInteractionEnabled = true
                sureBtn.backgroundImage(#imageLiteral(resourceName: "regiest_next_btn"))
            } else {
                sureBtn.isUserInteractionEnabled = false
                sureBtn.backgroundImage(#imageLiteral(resourceName: "sure_btn_gray"))
            }
        }
        
    }
    //MARK: - 提现
    
    private func txRequest() {
        
        let accountAmount = Decimal.init(infoModel?.accountAmount?.doubleValue ?? 0)
        guard let amount = txAmount else {
            self.noticeOnlyText("请输入提现金额")
            return
        }
        if amount > accountAmount {
            self.noticeOnlyText("可提现余额不足")
            return
        }
        if amount < 0.1 {
            self.noticeOnlyText("提现金额不能小于0.1元")
            return
        }
        pleaseWait()
        var parameters = Parameters()
        parameters["type"] = currentBindModel?.type
        parameters["withdrawAmount"] = "\(amount)"
        parameters["accountName"] = UserData.shared.userInfoModel?.worker?.mobile
        YZBSign.shared.request(APIURL.jcdWithdraw, method: .post, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let des = dataDic["des"] as? String
                let success = dataDic["success"] as? String
                if success == "true" {
                    self.amountTF.text = nil
                    self.txAmount = nil
                    self.isLoadTX = true
                    self.loadData()
                } else {
                    self.noticeSuccess(des ?? "提现失败，请联系客服，电话:400-698-7066", autoClear: true, autoClearTime: 5)
                }
            }
        } failure: { (error) in
            
        }

    }
    
    
    func loadData() {
        let parameters = Parameters()
        let urlStr = APIURL.moneyBagInfo + (UserData1.shared.tokenModel?.userId ?? "")
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.infoModel = Mapper<MoneyBagInfoModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
                if self.isLoadTX {
                    self.noticeOnlyText("提现成功")
                    self.isLoadTX = false
                }
            }
        }) { (error) in
        }
    }
    
    //MARK: - 绑定其他提现账户
    func bingOtherAccountPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 329)).backgroundColor(.white)
        pop = TLTransition.show(v, popType: TLPopTypeActionSheet)
        
        let topV = UIView().backgroundColor(.white)
        let line = UIView().backgroundColor(.kColor220)
        v.sv(topV, line)
        v.layout(
            0,
            |topV.height(40)|,
            0,
            |-14-line.height(0.5)-13.5-|,
            >=0
        )
        let tipLabel = UILabel().text("请选择收款账户").textColor(.kColor99).font(14)
        topV.sv(tipLabel)
        tipLabel.centerInContainer()
        let scrollView = UIScrollView()
        let line1 = UIView().backgroundColor(.kBackgroundColor)
        let bindAccountBtn = UIButton().text("绑定其他账户").textColor(UIColor.hexColor("#1DC597")).font(14)
        let cancelBtn = UIButton().text("取消").textColor(.kColor33).font(14)

        v.sv(scrollView, line1, bindAccountBtn, cancelBtn)

        v.layout(
            40.5,
            |scrollView|,
            0,
            |line1.height(5)|,
            0,
            |cancelBtn.height(40)-0-bindAccountBtn.height(40)|,
            PublicSize.kBottomOffset
        )
        equal(widths: cancelBtn, bindAccountBtn)
        bindList.enumerated().forEach { (item) in
            let index = item.offset
            let model = item.element
            let btnW: CGFloat = view.width
            let btnH: CGFloat = 40.5
            let offsetY: CGFloat = 40.5 * CGFloat(index)
            var image = #imageLiteral(resourceName: "login_zfb").scaled(to: CGSize(width: 17, height: 17))
            if model.type == "1" { // 微信
                image = #imageLiteral(resourceName: "login_wechat").scaled(to: CGSize(width: 17, height: 17))
            } else if model.type == "2" {
                image = #imageLiteral(resourceName: "login_zfb").scaled(to: CGSize(width: 17, height: 17))
            }
            let btn = UIButton().image(image).text(" \(model.bindUserName ?? "")").textColor(.kColor33).font(14)
            let line = UIView().backgroundColor(.kColor220)
            scrollView.sv(btn)
            scrollView.layout(
                offsetY,
                |-0-btn.width(btnW).height(btnH),
                >=0
            )
            btn.sv(line)
            btn.layout(
                >=0,
                |-14.5-line.height(0.5)-13.5-|,
                0
            )
            btn.tapped { [weak self] (tapBtn) in
                self?.pop?.dismiss(completion: {
                    self?.currentBindModel = model
                    self?.tableView.reloadData()
                })
            }
        }
        
        cancelBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss()
        }
        
        bindAccountBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss(completion: {
                self?.enterAuthVC()
            })
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountTF {
            if string.isEmpty {
                return true
            }
            var text1 = (textField.text ?? "0")
            if string == "." {
                text1 = text1 + ".0"
            } else {
                text1 = text1 + string
            }
            if !(text1.verifyNumberTwo()) && !text1.isEmpty{
                return false
            }
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
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


class AuthAppUserInfoModel : NSObject, Mappable{

    var bindUserIcon : String?
    var bindUserId : String?
    var bindUserName : String?
    var createTime : String?
    var currentFlag : String?
    var id : String?
    var type : String?
    var updateTime : String?
    var userId : String?
    required init?(map: Map){}
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        bindUserIcon <- map["bindUserIcon"]
        bindUserId <- map["bindUserId"]
        bindUserName <- map["bindUserName"]
        createTime <- map["createTime"]
        currentFlag <- map["currentFlag"]
        id <- map["id"]
        type <- map["type"]
        updateTime <- map["updateTime"]
        userId <- map["userId"]
        
    }


}
