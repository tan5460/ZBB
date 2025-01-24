//
//  ServiceRegiestSelectVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia

class ServiceRegiestSelectVC: BaseViewController {
    
    var phone: String = ""
    var openId: String = ""
    var authLoginType: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let personBtn = UIButton().backgroundColor(#colorLiteral(red: 0.9254901961, green: 1, blue: 0.9803921569, alpha: 1)).borderColor(.k2FD4A7).borderWidth(0.5).cornerRadius(20).masksToBounds()
        let companyBtn = UIButton().backgroundColor(#colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)).borderColor(#colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)).borderWidth(0.5).cornerRadius(20).masksToBounds()
        
        
        view.sv(personBtn, companyBtn)
        if UserData.shared.userType == .fws {
            view.layout(
                15,
                |-25-personBtn.height(200)-25-|,
                25,
                |-25-companyBtn.height(200)-25-|,
                >=0
            )
        } else {
            view.layout(
                15,
                |-25-companyBtn.height(200)-25-|,
                25,
                |-25-personBtn.height(200)-25-|,
                >=0
            )
        }
        
        let personIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_person_icon"))
        let personTitle = UILabel().text("个人注册").textColor(.kColor33).fontBold(18)
        let personDetailTitle = UILabel().text("注册需提供身份证及资质信息").textColor(.kColor33).font(14)
        let companyIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_company"))
        if UserData.shared.userType != .fws {
            companyIcon.image(#imageLiteral(resourceName: "regiest_company_1"))
        }
        let companyTitle = UILabel().text("公司注册").textColor(.kColor66).fontBold(18)
        let companyDetailTitle = UILabel().text("注册需提供营业执照、身份证、资质信息").textColor(.kColor66).font(14)
        if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            personDetailTitle.text("")
            companyDetailTitle.text("注册需提供营业执照")
            companyBtn.backgroundColor(#colorLiteral(red: 0.9254901961, green: 1, blue: 0.9803921569, alpha: 1)).borderColor(.k2FD4A7).borderWidth(0.5).cornerRadius(20).masksToBounds()
        }
        personBtn.sv(personIcon, personTitle, personDetailTitle)
        personBtn.layout(
            40,
            personIcon.centerHorizontally(),
            20,
            personTitle.height(25).centerHorizontally(),
            15,
            personDetailTitle.height(20).centerHorizontally(),
            >=0
        )
        
        companyBtn.sv(companyIcon, companyTitle, companyDetailTitle)
        companyBtn.layout(
            40,
            companyIcon.centerHorizontally(),
            20,
            companyTitle.height(25).centerHorizontally(),
            15,
            companyDetailTitle.height(20).centerHorizontally(),
            >=0
        )
        personBtn.addTarget(self, action: #selector(personBtnClick(btn:)))
        companyBtn.addTarget(self, action: #selector(companyBtnClick(btn:)))
    }
    
    @objc private func personBtnClick(btn: UIButton) {
        let vc = ServiceRegiestPersonVC()
        vc.title = "个人注册"
        vc.phone = phone
        vc.openId = openId
        vc.authLoginType = authLoginType
        navigationController?.pushViewController(vc)
    }
    
    @objc private func companyBtnClick(btn: UIButton) {
        if UserData.shared.userType == .fws {
            noticeOnlyText("开发中，敬请期待～")
        } else {
            let vc = ServiceRegiestPersonVC()
            vc.title = "公司注册"
            vc.phone = phone
            vc.openId = openId
            vc.authLoginType = authLoginType
            navigationController?.pushViewController(vc)
        }
    }
}
