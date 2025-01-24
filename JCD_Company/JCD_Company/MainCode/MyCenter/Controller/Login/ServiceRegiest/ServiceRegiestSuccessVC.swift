//
//  ServiceRegiestSuccessVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia

class ServiceRegiestSuccessVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "人工审核"
        let stepIV = UIImageView().image(#imageLiteral(resourceName: "pps_register_step_3"))
        let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_success"))
        let tipLab = UILabel().text("你的资料已提交，\n审核结果将以短信形式通知您！").textColor(.kColor33).font(14)
        tipLab.numberOfLines(2).lineSpace(2)
        let backBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_next_btn")).text("返回").textColor(.white).font(14)
        view.sv(stepIV, icon, tipLab, backBtn)
        view.layout(
            20,
            stepIV.height(60).centerHorizontally(),
            20,
            icon.width(230).height(218).centerHorizontally(),
            30,
            tipLab.height(50).centerHorizontally(),
            80,
            backBtn.width(280).height(40).centerHorizontally(),
            >=0
        )
        tipLab.numberOfLines(2).lineSpace(2)
        tipLab.textAligment(.center)
        backBtn.addTarget(self, action: #selector(backBtnClick(btn:)))
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }

}
