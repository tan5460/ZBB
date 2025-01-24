//
//  BankCardModel.swift
//  YZB_Company
//
//  Created by yzb_ios on 23.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import ObjectMapper

class BankCardModel: NSObject, Mappable {
 
    
    var id: String?//" : "320119101116044500001101",
    var livemode: Bool?// : false,
    var created: String?//" : 1570781085,
    var channel: String?//" : "bank_account",
    var recipient: RecipientModel? //" : {
//        "account" : "623251***1234",
//        "name" : "***司",
//        "card_type" : 6,
//        "mobile" : "132****7455",
//        "open_bank" : "中国建设银行",
//        "type" : "b2b",
//        "extra" : {
//            "card_id" : "4bcc30bed7500d3e687555921f4aa596",
//            "bank_card_status" : "succeeded",
//            "default_flag" : "1"
//            }
//    },
    var object: String?//" : "settle_account"
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        livemode <- map["livemode"]
        created <- map["created"]
        channel <- map["channel"]
        recipient <- map["recipient"]
        object <- map["object"]
    }
}

class RecipientModel: NSObject, Mappable {
    var account: String?//" : "623251***1234",
    var name: String?//" : "***司",
    var card_type: NSNumber?//" : 6,
    var mobile: String?//" : "132****7455",
    var open_bank: String?//" : "中国建设银行",
    var type: String?//" : "b2b",
    var extra: ExtraModel?
    
    required init?(map: Map) {
          
      }
      
    func mapping(map: Map) {
        account <- map["account"]
        name <- map["name"]
        card_type <- map["card_type"]
        mobile <- map["mobile"]
        open_bank <- map["open_bank"]
        type <- map["type"]
        extra <- map["extra"]
    }
}
class ExtraModel: NSObject, Mappable {
    var card_id: String?//" : "4bcc30bed7500d3e687555921f4aa596",
    var bank_card_status: String?//" : "succeeded",
    var default_flag: String?//" : "1"
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        card_id <- map["card_id"]
        bank_card_status <- map["bank_card_status"]
        default_flag <- map["default_flag"]
    }
}
