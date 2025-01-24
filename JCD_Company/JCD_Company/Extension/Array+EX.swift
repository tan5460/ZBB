//
//  Array+EX.swift
//  YS_HelloRead
//
//  Created by Cloud on 2019/1/24.
//  Copyright © 2019 chaoyun. All rights reserved.
//

import Foundation
import UIKit

extension Array {
    mutating func randamArray() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        self = list
        return list
    }
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
