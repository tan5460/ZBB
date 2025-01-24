//
//  PayTableViewController.swift
//  YZB_Company
//
//  Created by Mac on 15.10.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Stevia
import Then
import Alamofire

class PayTableViewController: UITableViewController {

    var citySubstationID: String! = ""
    var isRegister: Bool = false
    var payMoney: Double = 0 {
        didSet { updateUI() }
    }
    var purchaseOrderId = ""
    var platServiceMoneyRate: NSNumber = 0
    var platformTradServiceMoney: NSNumber = 0
    var registerID: String?
    var purchaseModel: PurchaseOrderModel?
    var tel: String?
    
    @IBOutlet weak var displayAmount: UILabel! {
        didSet { updateUI() }
    }
    @IBOutlet weak var displaySubtitle: UILabel! {
        didSet { updateUI() }
    }
    @IBOutlet weak var displayLess: UILabel!
    
    @IBOutlet weak var sureBtn: UIButton! {
        didSet {
            let bgImg = PublicColor.gradualColorImage
            let bgHighImg = PublicColor.gradualHightColorImage
            sureBtn.setBackgroundImage(bgImg, for: .normal)
            sureBtn.setBackgroundImage(bgHighImg, for: .highlighted)
        }
    }
    
    @IBOutlet private weak var exchangeBtn: UIButton! {
        didSet { viewModel?.exchangeButton = exchangeBtn }
    }
    private var viewModel: PayViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "请选择支付方式"
        viewModel = PayViewModel()
        viewModel.vc = self
        viewModel.isRegister = isRegister
        viewModel.delegate = self
        viewModel.orderId = purchaseOrderId
        viewModel.payMoney = payMoney
        viewModel.exchangeButton = exchangeBtn
        viewModel.registerID = registerID
        viewModel.loadLessMoeny()
        viewModel.fetchVipMoney(citySubstationID)
        updateUI()
    }

    
    @IBAction func pay(_ sender: UIButton) {
        viewModel.pay(sender)
    }
    
    @IBAction func selected(_ sender: UIButton) {
        viewModel.payMethod(sender)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isRegister ? 3 : 4
    }

}
// MARK: - PayViewModelDelegate
extension PayTableViewController: PayViewModelDelegate {
    
       func updateUI() {
        displayAmount?.text = (viewModel?.payMoney.notRoundingString(afterPoint: 2) ?? "未知")
        displaySubtitle?.text = "佣金费率: \(platServiceMoneyRate.doubleValue * 100)% 含平台交易服务佣金: ￥\((platformTradServiceMoney.doubleValue.notRoundingString(afterPoint: 2)))元"
        displaySubtitle?.isHidden = true
        displayLess?.text = viewModel?.lessMoney
        if isRegister {
            displaySubtitle?.isHidden = true
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
    
    func pushCodeAlert(_ params: [String: Any]) {
        guard let window = UIApplication.shared.keyWindow else { return }
        let popView = GetPhoneCodeToPayView(frame: window.frame)
        popView.tel = tel
        popView.mobile = self.purchaseModel?.store?.mobile
        var par = params
        popView.blockff = { (code) in
            par["code"] = code
            self.viewModel.params = par
            self.viewModel.pay(nil, isContinue: true)
        }
        popView.config()
        window.addSubview(popView)
//        let vc = InputPhoneViewController()
//        vc.modalPresentationStyle = .fullScreen
//        vc.tel = tel
//        vc.mobile = self.purchaseModel?.store?.mobile
//        var par = params
//        vc.blockff = { (code) in
//            par["code"] = code
//            self.viewModel.params = par
//            self.viewModel.pay(nil, isContinue: true)
//        }
//        UIApplication.shared.keyWindow?.addSubview(vc.view)
      //  self.view.addSubview(vc.view)
      //  self.present(vc, animated: true, completion: nil)
    }
    
    
    func clearNotice() {
        self.clearAllNotice()
    }
}
                          

class GetPhoneCodeToPayView:  UIView {
    var blockff: ((String) -> Void)?
    var tel: String?
    var mobile: String?
    private var timer: Timer?
    private var count = 60
    let popView = UIView().cornerRadius(8).backgroundColor(.white)
    let titleLab = UILabel().text("输入短信验证码").textColor(#colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)).font(15)
    let closeBtn = UIButton().then {
        $0.setImage(#imageLiteral(resourceName: "podBack_nav"), for: .normal)
    }
    let phoneTextFieldBG = UIView().cornerRadius(4).borderColor(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)).borderWidth(1)
    let phoneTextField = UITextField().then {
        $0.text = "158****2545"
        $0.textColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.isUserInteractionEnabled = false
    }
    let codeTextFieldBG = UIView().cornerRadius(4).borderColor(#colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)).borderWidth(1)
    let codeTextField = UITextField().then {
        $0.placeholder = "请输入验证码"
        $0.textColor = #colorLiteral(red: 0.1215686275, green: 0.1215686275, blue: 0.1215686275, alpha: 1)
        $0.font = UIFont.systemFont(ofSize: 13)
    }
    let sendCodeBtn = UIButton().text("发送验证码").textColor(.white).font(12).backgroundColor(#colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.2549019608, alpha: 1))
    let sureBtn = UIButton().text("确认付款").textColor(.white).font(14).cornerRadius(4).backgroundColor(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1))
    private var isSendCode = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2986577181)
        popView.frame = CGRect(x: 0, y: 0, width: PublicSize.kScreenWidth-80, height: 240)
        popView.center = self.center
        addSubview(popView)
        
        popView.sv(closeBtn, titleLab, phoneTextFieldBG, codeTextFieldBG, sureBtn)
        popView.layout(
            8.5,
            |-(>=0)-closeBtn.width(13)-12-| ~ 13,
            6,
            titleLab.centerHorizontally().height(14.5),
            19.5,
            |-20-phoneTextFieldBG-20-| ~ 39,
            10.5,
            |-20-codeTextFieldBG-20-| ~ 39,
            20.5,
            |-20-sureBtn-20-| ~ 41,
            >=0
        )
        closeBtn.addTarget(self, action: #selector(closeBtnClick))
        
        phoneTextFieldBG.sv(phoneTextField)
        phoneTextFieldBG.layout(
            0,
            |-15-phoneTextField-15-|,
            0
        )
        
        codeTextFieldBG.sv(codeTextField, sendCodeBtn)
        codeTextFieldBG.layout(
            0,
            |-15-codeTextField.height(39)-15-sendCodeBtn.width(75.3).height(39)-0-|,
            0
        )
        
        sendCodeBtn.addTarget(self, action: #selector(sendCodeBtnClick))
        sureBtn.addTarget(self, action: #selector(sureBtnClick))
        sureBtn.isUserInteractionEnabled = false
        codeTextField.addTarget(self, action: #selector(codeTextFiledChange), for: .editingChanged)
    }
    
    @objc func closeBtnClick() {
        self.removeFromSuperview()
        self.endEditing(true)
    }
    
    @objc func codeTextFiledChange() {
        if codeTextField.text?.length ?? 0 >= 6 {
            sureBtn.isUserInteractionEnabled = true
            sureBtn.backgroundColor = #colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.2549019608, alpha: 1)
            if codeTextField.text!.length >= 6 {
                codeTextField.text = codeTextField.text!.subString(to: 6)
            }
        }
        else {
            sureBtn.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1)
            sureBtn.isUserInteractionEnabled = false
        }
    }
    
    @objc func sendCodeBtnClick() {
        if timer == nil {
            isSendCode = true
            fetchCode()
        }
    }
    @objc func updateCount() {
        count -= 1
        sendCodeBtn.setTitle("\(count)s后重发", for: .normal)
        if count == 0 {
            count = 60
            sendCodeBtn.setTitle("发送验证码", for: .normal)
            sendCodeBtn.isUserInteractionEnabled = true
            sendCodeBtn.backgroundColor = #colorLiteral(red: 0.4, green: 0.8509803922, blue: 0.2549019608, alpha: 1)
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func fetchCode() {
        YZBSign.shared.request(APIURL.balancePayMsg, method: .get, parameters: Parameters(), success: { (response) in
            AppLog(response)
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                self.noticeOnlyText("验证码已发送")
                self.sendCodeBtn.isUserInteractionEnabled = false
                self.sendCodeBtn.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1)
                self.sendCodeBtn.setTitle("\(self.count)s后重发", for: .normal)
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCount), userInfo: nil, repeats: true)
            }
        }) { (err) in
            AppLog(err)
        }
    }
    
    @objc func sureBtnClick() {
        if isSendCode == false {
            self.noticeOnlyText("请发送验证码")
            return
        }
        blockff?(codeTextField.text!)
        self.closeBtnClick()
    }
    
    func config() {
        if (UserData.shared.workerModel?.jobType == 999) {
            phoneTextField.text = UserData.shared.workerModel?.mobile ?? ""
        } else {
            phoneTextField.text = mobile
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       // self.closeBtnClick()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
