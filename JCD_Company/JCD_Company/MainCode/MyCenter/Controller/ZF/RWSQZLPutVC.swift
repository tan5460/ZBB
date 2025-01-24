//
//  RWSQZLPutVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2020/12/17.
//

import UIKit

class RWSQZLPutVC: BaseViewController {
   
    private var companyNameTF = UITextField().placeholder("请填写公司名称")
    private var yyzzTF = UITextField().placeholder("请填写统一信用代码/营业执照号")
    private var addressTF = UITextField().placeholder("请输入商户经营地址")
    private var contactTF = UITextField().placeholder("请输入联系人姓名")
    private var phoneTF = UITextField().placeholder("请输入手机号")
    private var mailTF = UITextField().placeholder("请输入邮箱")
    private var parameters1 = [String: String]()
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "入网申请资料提交"
        view.backgroundColor(.kBackgroundColor)
        [companyNameTF, yyzzTF, phoneTF, mailTF, contactTF, addressTF].forEach {
            $0.placeholderColor = .kColor99
            $0.font = .systemFont(ofSize: 14)
            $0.clearButtonMode = .whileEditing
        }
        
        yyzzTF.keyboardType = .numberPad
        phoneTF.keyboardType = .phonePad
        mailTF.keyboardType = .emailAddress
        
        
        
        let sureBtn = UIButton().text("下一步").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_put_btn"))
        
        
        tableView.backgroundColor(.kBackgroundColor)
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
        view.sv(tableView, sureBtn)
        view.layout(
            0,
            |tableView|,
            10,
            sureBtn.width(280).height(44).centerHorizontally(),
            80+PublicSize.kBottomOffset
        )
        
        sureBtn.tapped { [weak self] (btn) in
            self?.putRequest()
        }
        
    }
    
    

    func putRequest() {
        if companyNameTF.text == "" {
            self.noticeOnlyText(companyNameTF.placeholder ?? "")
            return
        }
        
        if yyzzTF.text == "" {
            self.noticeOnlyText(yyzzTF.placeholder ?? "")
            return
        }
        
        if addressTF.text == "" {
            self.noticeOnlyText(addressTF.placeholder ?? "")
            return
        }
        
        if contactTF.text == "" {
            self.noticeOnlyText(contactTF.placeholder ?? "")
            return
        }
        
        if phoneTF.text == "" {
            self.noticeOnlyText(phoneTF.placeholder ?? "")
            return
        }
        
        if mailTF.text == "" {
            self.noticeOnlyText(mailTF.placeholder ?? "")
            return
        }
        
        var parameters = Parameters()
        parameters["companyName"] = companyNameTF.text
        parameters["certNo"] = yyzzTF.text
        parameters["email"] = mailTF.text
        parameters["mobile"] = phoneTF.text
        parameters["address"] = addressTF.text
        parameters["contactName"] = contactTF.text
        let vc = RWSQStepTwoVC()
        vc.parameters = parameters
        vc.backBlock = { [weak self] (parame) in
            self?.parameters1 = parame
        }
        vc.parameters1 = parameters1
        self.navigationController?.pushViewController(vc)
    }
}

extension RWSQZLPutVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            let icon = UIImageView().image(#imageLiteral(resourceName: "zf_icon_name"))
            cell.sv(icon, companyNameTF)
            cell.layout(
                13.5,
                |-14-icon.size(17)-5-companyNameTF-14-|,
                13.5
            )
        case 1:
            let icon = UIImageView().image(#imageLiteral(resourceName: "zf_icon_no"))
            cell.sv(icon, yyzzTF)
            cell.layout(
                13.5,
                |-14-icon.size(17)-5-yyzzTF-14-|,
                13.5
            )
        
        case 2:
            let icon = UIImageView().image(#imageLiteral(resourceName: "zf_icon_address"))
            cell.sv(icon, addressTF)
            cell.layout(
                13.5,
                |-14-icon.size(17)-5-addressTF-14-|,
                13.5
            )
        case 3:
            let icon = UIImageView().image(#imageLiteral(resourceName: "zf_icon_contact"))
            cell.sv(icon, contactTF)
            cell.layout(
                13.5,
                |-14-icon.size(17)-5-contactTF-14-|,
                13.5
            )
        case 4:
            let icon = UIImageView().image(#imageLiteral(resourceName: "zf_icon_phone"))
            cell.sv(icon, phoneTF)
            cell.layout(
                13.5,
                |-14-icon.size(17)-5-phoneTF-14-|,
                13.5
            )
        case 5:
            let icon = UIImageView().image(#imageLiteral(resourceName: "zf_icon_mail"))
            cell.sv(icon, mailTF)
            cell.layout(
                13.5,
                |-14-icon.size(17)-5-mailTF-14-|,
                13.5
            )
        default:
            break
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
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
