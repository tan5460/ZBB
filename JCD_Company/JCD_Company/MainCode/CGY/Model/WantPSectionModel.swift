//
//  WantPurchaseModel.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/24.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class WantPSectionModel: NSObject {
    var merchant: MerchantModel?
    var merchantName: String?
    var merchantId: String?              //供应商id
    var materials: [PurchaseMaterialModel] = []      //主材
    var remarks: String?
}
