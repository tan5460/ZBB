//
//  Dictionary+Ex.swift
//  ChalkTalks
//
//  Created by 巢云 on 2019/9/5.
//  Copyright © 2019 巢云. All rights reserved.
//

import Foundation
extension Dictionary {
    var jsonStr: String? {
        if !JSONSerialization.isValidJSONObject(self) {
            print("无法解析出JSONString")
            return ""
        }
        if let data = try? JSONSerialization.data(withJSONObject: self, options: []) {
            let json = String.init(data: data, encoding: String.Encoding.utf8)
            return json
        } else {
            return nil
        }
    }
}
