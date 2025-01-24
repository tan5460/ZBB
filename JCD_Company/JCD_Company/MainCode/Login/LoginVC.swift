//
//  LoginVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/18.
//

import UIKit

class LoginVC: BaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    private let phoneTF = UITextField().placeholder("请输入您的手机号码")
    override func viewDidLoad() {
        super.viewDidLoad()
        let bottomIV = UIImageView().image(#imageLiteral(resourceName: "login_bottom_bg"))
        view.sv(bottomIV)
        view.layout(
            >=0,
            |bottomIV.height(194)|,
            0
        )
        let lab1 = UILabel().text("欢迎登录聚材道").textColor(.kColor33).fontBold(24)
        let lab2 = UILabel().text("请输入您的手机号码").textColor(.kColor33).font(16)
        let lab3 = UILabel().text("未注册的手机号通过后自动创建聚材道账户").textColor(.kColor99).font(12)
        let phoneTFBG = UIView().cornerRadius(4).borderColor(UIColor.hexColor("#61D9B9")).borderWidth(0.5)
        let phoneIcon = UIImageView().image(#imageLiteral(resourceName: "login_icon_phone"))
        
        let getCodeBtn = UIButton().text("获取短信验证码").textColor(.white).font(16)
        let passwordLoginBtn = UIButton()
        let passwordLoginLab = UILabel().text("密码登录").textColor(.k1DC597).font(12)
        let passwordLoginIV = UIImageView().image(#imageLiteral(resourceName: "login_icon_in"))
        let infoBtn = UIButton()
        let infoLab = UILabel().text("遇到问题").textColor(.kColor99).font(12)
        let infoIV = UIImageView().image(#imageLiteral(resourceName: "login_icon_info"))
        view.sv(lab1, lab2, lab3, phoneTFBG, getCodeBtn, passwordLoginBtn, infoBtn)
        view.layout(
            PublicSize.kStatusBarHeight+61,
            |-30-lab1.height(33.5),
            20,
            |-30-lab2.height(22.5),
            5,
            |-30-lab3.height(16.5),
            19.5,
            |-30-phoneTFBG.height(50)-30-|,
            30,
            |-30-getCodeBtn.height(50)-30-|,
            10,
            |-30-passwordLoginBtn.width(100).height(16.5)-(>=0)-infoBtn.width(100).height(16.5)-30-|,
            >=0
        )
        
        phoneTF.placeholderColor = .kColor99
        phoneTF.font(14)
        phoneTF.keyboardType = .phonePad
        phoneTF.delegate = self
        phoneTFBG.sv(phoneIcon, phoneTF)
        phoneTFBG.layout(
            15,
            |-15-phoneIcon.size(20)-10-phoneTF.height(50)-10-|,
            15
        )
        
        getCodeBtn.corner(radii: 4).fillGreenColorLF()
        
        passwordLoginBtn.sv(passwordLoginLab, passwordLoginIV)
        passwordLoginBtn.layout(
            0,
            |passwordLoginLab.height(16.5)-2-passwordLoginIV.size(16),
            0
        )
        
        infoBtn.sv(infoIV, infoLab)
        infoBtn.layout(
            0.5,
            infoIV.height(16)-2-infoLab.height(16.5)-0-|,
            0
        )
        
        getCodeBtn.tapped { [weak self] (tapBtn) in
            self?.enterCodeLoginVC()
        }
        
        passwordLoginBtn.tapped { [weak self] (tapBtn) in
            self?.enterPasswordLoginVC()
        }
        
        infoBtn.tapped { [weak self] (tapBtn) in
            self?.enterHelpVC()
        }
    }
    
    func enterCodeLoginVC() {
        guard let mobile = phoneTF.text, !mobile.isEmpty else {
            noticeOnlyText("请输入您的手机号码")
            return
        }
        let vc = LoginCodeVC()
        vc.mobile = mobile
        navigationController?.pushViewController(vc)
    }
    
    func enterPasswordLoginVC() {
        let vc = PasswordLoginVC()
        navigationController?.pushViewController(vc)
    }
    
    func enterHelpVC() {
        let vc = MyCenterHelpVC()
        navigationController?.pushViewController(vc)
    }
}

extension LoginVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.count ?? 0 < 11 && string.isNumber()) || string.isEmpty {
            return true
        }
        return false
    }
}
