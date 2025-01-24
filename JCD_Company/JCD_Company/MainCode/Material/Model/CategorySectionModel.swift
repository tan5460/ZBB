//
//  CategorySectionModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/25.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

//  自建model 用于分组归类

import UIKit

class CategorySectionModel: NSObject {

    var isExpanded = false                          //是否展开
    var isNotExpanded = false                       //是否可展开
    var section = 0                                 //判断是否是第一项 全部分类
    
    var model: CategoryModel?                       //当前一级分类
    var cellModels: Array<CategoryModel> = []       //子分类id
    
    override init() {
        super.init()
    }
    
}
