//
//  RWSQStepTwoVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2020/12/31.
//

import UIKit

class RWSQStepTwoVC: BaseViewController {
    
    var parameters = Parameters()
    var parameters1 = [String: String]()
    var backBlock: (([String: String]) -> Void)?
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.kBackgroundColor)
    private var isPrivate = true
    
    private var nameTF = UITextField().placeholder("请输入姓名")
    private var idcardTF = UITextField().placeholder("请输入身份证号")
    private var phoneTF = UITextField().placeholder("请输银行卡所绑定手机号")
    private var bankTF = UITextField().placeholder("请输入银行卡号")
    private var kfzhTF = UITextField().placeholder("请输入开户支行")
    private var accountTF = UITextField().placeholder("请输入账户名")
    private var accountNoTF = UITextField().placeholder("请输入账户号")
    private var bankNoTF = UITextField().placeholder("请输入联行行号")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "入网申请资料提交"
          
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(back))
        let param = parameters1
        let accountType = param["accountType"]
        if accountType == "03" {
            isPrivate = true
        } else if accountType == "02" {
            isPrivate = false
        }
        
        
        view.backgroundColor(.kBackgroundColor)
        [nameTF, idcardTF, phoneTF, bankTF, kfzhTF, accountTF, accountNoTF, bankNoTF].forEach {
            $0.placeholderColor = .kColor99
            $0.font = .systemFont(ofSize: 14)
            $0.clearButtonMode = .whileEditing
        }
        nameTF.text = param["name"]
        idcardTF.text = param["idcard"]
        phoneTF.text = param["phone"]
        bankTF.text = param["bank"]
        kfzhTF.text = param["kfzh"]
        accountNoTF.text = param["accountNo"]
        accountTF.text = param["account"]
        bankNoTF.text = param["bankNo"]
        
        // Do any additional setup after loading the view.
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
        let topBgView = UIView().backgroundColor(.white)
        let privateBtn = UIButton().text("对私账户").textColor(.k2FD4A7).font(14)
        let privateLine = UIView().backgroundColor(.k2FD4A7)
        let publicBtn = UIButton().text("对公账户").textColor(.kColor99).font(14)
        let publicLine = UIView().backgroundColor(.k2FD4A7)
        let preBtn = UIButton().text("上一步").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "zf_btn_yellow"))
        let putBtn = UIButton().text("提交").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "zf_btn_green"))
        if isPrivate {
            privateLine.isHidden = false
            publicLine.isHidden = true
            privateBtn.textColor(.k2FD4A7)
            publicBtn.textColor(.kColor99)
        } else {
            privateLine.isHidden = true
            publicLine.isHidden = false
            privateBtn.textColor(.kColor99)
            publicBtn.textColor(.k2FD4A7)
        }
        
        preBtn.isHidden = true
        
        view.sv(tableView, topBgView, privateBtn, privateLine, publicBtn, publicLine, preBtn, putBtn)
        view.layout(
            0,
            |topBgView.height(40)|,
            >=0
        )
        view.layout(
            0,
            |-40-privateBtn.height(40)-0-publicBtn.height(40)-40-|,
            0,
            |tableView|,
            10,
            preBtn.width(280).height(40).centerHorizontally(),
            30,
            putBtn.width(280).height(40).centerHorizontally(),
            80+PublicSize.kBottomOffset
        )
        equal(widths: privateBtn, publicBtn)
        privateBtn.sv(privateLine)
        privateBtn.layout(
            >=0,
            privateLine.width(24).height(2).centerHorizontally(),
            0
        )
        publicBtn.sv(publicLine)
        publicBtn.layout(
            >=0,
            publicLine.width(24).height(2).centerHorizontally(),
            0
        )
        privateBtn.tapped { [weak self] (tapBtn) in
            self?.isPrivate = true
            privateLine.isHidden = false
            publicLine.isHidden = true
            privateBtn.textColor(.k2FD4A7)
            publicBtn.textColor(.kColor99)
            self?.tableView.reloadData()
        }
        publicBtn.tapped { [weak self] (tapBtn) in
            self?.isPrivate = false
            privateLine.isHidden = true
            publicLine.isHidden = false
            privateBtn.textColor(.kColor99)
            publicBtn.textColor(.k2FD4A7)
            self?.tableView.reloadData()
        }
        
        preBtn.tapped { [weak self] (tapBtn) in
            self?.back()
        }
        
        putBtn.tapped { [weak self] (tapBtn) in
            self?.putRequest()
        }
    }
    
    @objc func back() {
        self.view.endEditing(true)
        var param = [String: String]()
        if isPrivate {
            param["accountType"] = "03"
        } else  {
            param["accountType"] = "02"
        }
        param["name"] = nameTF.text
        param["idcard"] = idcardTF.text
        param["phone"] = phoneTF.text
        param["bank"] = bankTF.text
        param["kfzh"] = kfzhTF.text
        param["account"] = accountTF.text
        param["accountNo"] = accountNoTF.text
        param["bankNo"] = bankNoTF.text
        backBlock?(param)
        navigationController?.popViewController()
    }
    
    func putRequest() {
        if isPrivate {
            
            if nameTF.text == "" {
                self.noticeOnlyText(nameTF.placeholder ?? "")
                return
            }
            
            if idcardTF.text == "" {
                self.noticeOnlyText(idcardTF.placeholder ?? "")
                return
            }
            
            if phoneTF.text == "" {
                self.noticeOnlyText(phoneTF.placeholder ?? "")
                return
            }
            
            if bankTF.text == "" {
                self.noticeOnlyText(bankTF.placeholder ?? "")
                return
            }
            
            parameters["accountType"] = "03"
            parameters["accountName"] = nameTF.text
            parameters["idCard"] = idcardTF.text
            parameters["bankCardMobile"] = phoneTF.text
            parameters["account"] = bankTF.text
        } else {
            
            if kfzhTF.text == "" {
                self.noticeOnlyText(kfzhTF.placeholder ?? "")
                return
            }
            
            if accountTF.text == "" {
                self.noticeOnlyText(accountTF.placeholder ?? "")
                return
            }
            
            if accountNoTF.text == "" {
                self.noticeOnlyText(accountNoTF.placeholder ?? "")
                return
            }
            
            if bankNoTF.text == "" {
                self.noticeOnlyText(bankNoTF.placeholder ?? "")
                return
            }
            
            parameters["accountType"] = "02"
            parameters["accountBank"] = kfzhTF.text
            parameters["accountName"] = accountTF.text
            parameters["account"] = accountNoTF.text
            parameters["accountBankCode"] = bankNoTF.text
        }
        parameters["userId"] = UserData1.shared.tokenModel?.userId
        YZBSign.shared.request(APIURL.addInfo, method: .post, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let vc = RWSQSuccessVC()
                self.navigationController?.pushViewController(vc)
            }
        } failure: { (error) in
            
        }
    }
}


extension RWSQStepTwoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if isPrivate {
            switch indexPath.section {
            case 0:
                let titleLab = UILabel().text("姓名").textColor(.kColor33).font(14)
                cell.sv(titleLab, nameTF)
                cell.layout(
                    12,
                    |-14-titleLab.height(20),
                    12
                )
                cell.layout(
                    0,
                    |-90-nameTF.height(44)-20-|,
                    0
                )
            case 1:
                let titleLab = UILabel().text("身份证号").textColor(.kColor33).font(14)
                cell.sv(titleLab, idcardTF)
                cell.layout(
                    12,
                    |-14-titleLab.height(20),
                    12
                )
                cell.layout(
                    0,
                    |-90-idcardTF.height(44)-20-|,
                    0
                )
            case 2:
                let titleLab = UILabel().text("手机号").textColor(.kColor33).font(14)
                cell.sv(titleLab, phoneTF)
                cell.layout(
                    12,
                    |-14-titleLab.height(20),
                    12
                )
                cell.layout(
                    0,
                    |-90-phoneTF.height(44)-20-|,
                    0
                )
            case 3:
                let titleLab = UILabel().text("银行卡号").textColor(.kColor33).font(14)
                cell.sv(titleLab, bankTF)
                cell.layout(
                    12,
                    |-14-titleLab.height(20),
                    12
                )
                cell.layout(
                    0,
                    |-90-bankTF.height(44)-20-|,
                    0
                )
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 0:
                let titleLab = UILabel().text("开户支行").textColor(.kColor33).font(14)
                cell.sv(titleLab, kfzhTF)
                cell.layout(
                    12,
                    |-14-titleLab.height(20),
                    12
                )
                cell.layout(
                    0,
                    |-90-kfzhTF.height(44)-20-|,
                    0
                )
            case 1:
                let titleLab = UILabel().text("账户名").textColor(.kColor33).font(14)
                cell.sv(titleLab, accountTF)
                cell.layout(
                    12,
                    |-14-titleLab.height(20),
                    12
                )
                cell.layout(
                    0,
                    |-90-accountTF.height(44)-20-|,
                    0
                )
            case 2:
                let titleLab = UILabel().text("账户号").textColor(.kColor33).font(14)
                cell.sv(titleLab, accountNoTF)
                cell.layout(
                    12,
                    |-14-titleLab.height(20),
                    12
                )
                cell.layout(
                    0,
                    |-90-accountNoTF.height(44)-20-|,
                    0
                )
            case 3:
                let titleLab = UILabel().text("联行号").textColor(.kColor33).font(14)
                cell.sv(titleLab, bankNoTF)
                cell.layout(
                    12,
                    |-14-titleLab.height(20),
                    12
                )
                cell.layout(
                    0,
                    |-90-bankNoTF.height(44)-20-|,
                    0
                )
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.kBackgroundColor)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 100
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 3 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 100)).backgroundColor(.kBackgroundColor)
            let tipIV = UIImageView().image(#imageLiteral(resourceName: "zf_icon_tip"))
            let tipLabel = UILabel().text("以上资料供商户收款使用，请仔细核实！").textColor(UIColor.hexColor("#3564F6")).font(12)
            v.sv(tipIV, tipLabel)
            v.layout(
                11.5,
                |-14-tipIV.size(14)-5-tipLabel.height(16.5),
                >=0
            )
            return v
        }
        return UIView()
    }
}
