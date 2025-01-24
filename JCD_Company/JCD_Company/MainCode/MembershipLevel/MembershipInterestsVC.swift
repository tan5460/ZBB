//
//  MembershipInterestsVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

class MembershipInterestsVC: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "会员能享受哪些权益"
        let desLabel = UILabel().text("    湖南省豫章装饰设计工程有限公司于2019年11月01日成立。法定代表人罗仁章，公司经营范围包括：室内装饰设计服务；住宅装饰和装修；建筑装饰；建筑装饰材料的零售；建筑装饰材料的批发；家居用品的销售等。").textColor(.kColor33).font(14)
        desLabel.numberOfLines(0).lineSpace(2)
        view.sv(desLabel)
        view.layout(
            12,
            |-14-desLabel-14-|,
            >=0
        )
    }

}
