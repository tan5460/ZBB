//
//  UIImageView+EX.swift
//  YZB_Company
//
//  Created by Mac on 21.03.2020.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import Foundation
import SDWebImage

import UIKit

extension UIImageView {
    /// 设置图片
    @discardableResult
    func image(_ image: UIImage) -> Self {
        self.image = image
        return self
    }
    @discardableResult
    func addImage(_ urlString: String?, place: UIImage? = nil) -> Bool {
        var str =  urlString
        str = str?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let urlStr = str, !urlStr.isEmpty {
            self.sd_setImage(with: URL.init(string: APIURL.ossPicUrl + urlStr), placeholderImage: place)
            return true
        } else {
            return false
        }
    }
}
