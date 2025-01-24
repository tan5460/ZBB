//
//  CartModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/1/13.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

//  自建model 用于分组归类

import UIKit


class CartSectionModel: NSObject {
    
    var typeValue: Int = 1                                  //购物车类型 1.主材 2.施工
    var cellModels: Array<MaterialsModel> = []               //购物车列表
    
    override init() {
        super.init()
    }
    
}
