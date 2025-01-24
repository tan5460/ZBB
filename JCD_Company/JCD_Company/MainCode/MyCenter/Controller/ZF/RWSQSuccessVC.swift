//
//  RWSQSuccessVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2020/12/17.
//

import UIKit

class RWSQSuccessVC: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "入网申请"
        let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_success"))
        let tip = UILabel().text("入网申请提交成功！").textColor(.kColor33).font(14)
        let backBtn = UIButton().text("返回首页").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_put_btn"))
        
        view.sv(icon, tip, backBtn)
        view.layout(
            82,
            icon.size(230).centerHorizontally(),
            30,
            tip.height(20).centerHorizontally(),
            80,
            backBtn.width(280).height(44).centerHorizontally(),
            >=0
        )
        backBtn.tapped { [weak self] (btn) in
            self?.navigationController?.popToRootViewController(animated: false)
//            self?.navigationController?.viewControllers.forEach({ (vc) in
//                if vc.isKind(of: ChatViewController.classForCoder()) {
//                    self?.navigationController?.popToViewController(vc, animated: false)
//                }
//            })
        }
    }

}
