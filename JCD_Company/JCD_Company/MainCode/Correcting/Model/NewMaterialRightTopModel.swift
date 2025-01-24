//
//  NewMaterialRightTopViewModel.swift
//  YZB_Company
//
//  Created by Mac on 17.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

/*{
    "id": "91a502f85d184c90a92b25799af267d4",
    "isNewRecord": false,
    "remarks": null,
    "createBy": null,
    "createDate": null,
    "updateBy": null,
    "updateDate": null,
    "delFlag": "0",
    "parentIds": "0,b1d583e8cc5c4ca5875e5b7b2358ff9d,",
    "name": "瓷砖",
    "sort": 10,
    "remark": "",
    "type": 2,
    "parentId": null,
    "specification": {
id": "",
isNewRecord": true,
remarks": null,
createBy": null,
createDate": null,
updateBy": null,
updateDate": null,
delFlag": "0",
name": null,
sort": null
    }
}
*/

class NewMaterialRightTopModel: NSObject, Mappable {
    var id: String? = "" // "91a502f85d184c90a92b25799af267d4",
    var isNewRecord: String? // false,
    var remarks: String? // null,
    var createBy: String? // null,
    var createDate: String? // null,
    var updateBy: String? // null,
    var updateDate: String? // null,
    var delFlag: String? // "0",
    var parentIds: String? // "0,b1d583e8cc5c4ca5875e5b7b2358ff9d,",
    var name: String? = "全部" // "瓷砖",
    var sort: String? // 10,
    var remark: String? // "",
    var type: String? // 2,
    var specification: [SpecificationModel]?
    var parentId: String?
    
    required init?(map: Map) {
        
    }
    override init() {
        super.init()
        
    }
    
    func mapping(map: Map) {
        id <- map["id"] //"91a502f85d184c90a92b25799af267d4",
        isNewRecord <- map["isNewRecord"] //false,
        remarks <- map["remarks"] //null,
        createBy <- map["createBy"] //null,
        createDate <- map["createDate"] //null,
        updateBy <- map["updateBy"] //null,
        updateDate <- map["updateDate"] //null,
        delFlag <- map["delFlag"] //"0",
        parentIds <- map["parentIds"] //"0,b1d583e8cc5c4ca5875e5b7b2358ff9d,",
        name <- map["name"] //"瓷砖",
        sort <- map["sort"] //10,
        remark <- map["remark"] //"",
        type <- map["type"] //2,
        parentId <- map["parentId"] //null,
        specification <- map["specification"]
    }
}
