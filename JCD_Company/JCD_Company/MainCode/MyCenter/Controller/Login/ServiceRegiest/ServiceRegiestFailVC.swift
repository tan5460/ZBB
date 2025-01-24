//
//  ServiceRegiestFailVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia

class ServiceRegiestFailVC: BaseViewController {
    var isRZ = false // 是否会员认证流程
    var regiestModel: RegisterModel?
    var reason: String? 
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "人工审核"
        let stepIV = UIImageView().image(#imageLiteral(resourceName: "pps_register_step_3"))
        let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_fail"))
        let tipLab = UILabel().text("审核未通过").textColor(UIColor.hexColor("#FD3B3B")).fontBold(18)
        let reasonLabel = UILabel().text("失败原因：\(reason ?? "")").textColor(.kColor66).font(14)
        let backBtn = UIButton().text("返回").textColor(.kColor66).font(14).borderColor(.kColor99).borderWidth(0.5).cornerRadius(5).masksToBounds()
        let editBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_next_btn")).text("修改信息").textColor(.white).font(14).borderColor(#colorLiteral(red: 0.1019607843, green: 0.6039215686, blue: 0.4666666667, alpha: 1)).borderWidth(0.5).cornerRadius(5).masksToBounds()
        if isRZ {
            view.sv(icon, tipLab, reasonLabel, backBtn, editBtn)
            view.layout(
                82,
                icon.width(230).height(218).centerHorizontally(),
                20,
                tipLab.height(25).centerHorizontally(),
                15,
                reasonLabel.width(view.width-98).centerHorizontally(),
                80,
                |-49-backBtn.height(40)-57-editBtn.height(40)-49-|,
                >=0
            )
            reasonLabel.numberOfLines(0).lineSpace(2)
            equal(widths: backBtn, editBtn)
        } else {
            view.sv(stepIV, icon, tipLab, reasonLabel, backBtn, editBtn)
            view.layout(
                20,
                stepIV.height(58).centerHorizontally(),
                20,
                icon.width(230).height(218).centerHorizontally(),
                20,
                tipLab.height(25).centerHorizontally(),
                15,
                reasonLabel.width(view.width-98).centerHorizontally(),
                80,
                |-49-backBtn.height(40)-57-editBtn.height(40)-49-|,
                >=0
            )
            reasonLabel.numberOfLines(0).lineSpace(2)
            equal(widths: backBtn, editBtn)
        }
        backBtn.tapped { [weak self] (btn) in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        editBtn.addTarget(self, action: #selector(editBtnClick(btn:)))
    }
    
    @objc private func editBtnClick(btn: UIButton) {
        
        if regiestModel?.merchantType == 1 { // 品牌商流程
            let vc = PPSRegiestSecondVC()
            let baseModel = RegisterBaseModel()
            baseModel.registerRData = regiestModel
            vc.regiestBaseModel = baseModel
            navigationController?.pushViewController(vc)
            return
        }
        
        switch regiestModel?.serviceType {
        case 5: // 工人
            let vc = ServiceRegiestWorkerVC()
            vc.regiestModel = regiestModel
            navigationController?.pushViewController(vc)
        case 6: // 设计师
            let vc = ServiceRegiestDesignVC()
            vc.regiestModel = regiestModel
            navigationController?.pushViewController(vc)
        case 7: // 工长
            let vc = ServiceRegiestForemanVC()
            vc.regiestModel = regiestModel
            navigationController?.pushViewController(vc)
        default:
            let vc = MemberAuthVC()
            vc.isEdit = true
            navigationController?.pushViewController(vc)
            
        }
    }
}
