//
//  PurchaseSuccessVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/16.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

class PurchaseSuccessVC: BaseViewController {
    
    var orderId: String?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        let topBgIV = UIImageView().image(#imageLiteral(resourceName: "purchase_top_bg_1"))
        let backBtn = UIButton().image(#imageLiteral(resourceName: "icon_return"))
        let titleLab = UILabel().text("下单成功").textColor(.white).fontBold(18)
        let lab1 = UILabel().text("下单成功！").textColor(UIColor.hexColor("#1DC597")).fontBold(24)
        let lab2 = UILabel().text("商家确认您的订单后，才能付款，请耐心等待！").textColor(.kColor66).font(14)
        let sureBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_next_btn")).text("查看订单").textColor(.white).font(14)
        view.sv(topBgIV, backBtn, titleLab, lab1, lab2, sureBtn)
        view.layout(
            0,
            |topBgIV.height(305)|,
            44.5,
            lab1.height(33.5).centerHorizontally(),
            20,
            lab2.height(20).centerHorizontally(),
            80,
            sureBtn.width(280).height(40).centerHorizontally(),
            >=0
        )
        
        view.layout(
            PublicSize.kStatusBarHeight,
            |-0-backBtn.size(44)-(>=0)-titleLab.centerHorizontally(),
            >=0
        )
        backBtn.addTarget(self, action: #selector(backBtnClick(btn:)))
        sureBtn.tapped { [weak self] (btn) in
            let vc = PurchaseViewController()
            self?.navigationController?.pushViewController(vc)
        }
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
}
