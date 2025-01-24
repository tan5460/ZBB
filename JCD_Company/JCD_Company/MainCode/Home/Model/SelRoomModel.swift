//
//  SelectRoomModel.swift
//  YZB_Company
//
//  Created by TanHao on 2017/11/19.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import Foundation

class SelRoomModel: NSObject {
    
    //选中房间模型
    var roomType: Int?
    var roomName: String?
    var roomCount: Int = 0
    
    override init() {
        super.init()
    }
}

