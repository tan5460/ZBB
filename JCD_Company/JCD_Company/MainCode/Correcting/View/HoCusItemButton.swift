//
//  HoCusItemButton.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/7.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import SnapKit

class HoCusItemButton: UIView {

    var isSelected: Bool! {
        didSet {
            layoutSubviews()
        }
    }

    /// 展开
    var isOpen = false {
        didSet {
            layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let corner = frame.size.height / 2
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.cornerRadius = corner
        
        if isOpen {
            
            layer.borderColor = UIColor.init(netHex: 0xE6E6E6).cgColor
            backgroundColor = UIColor.white
            if #available(iOS 11.0, *) {
                layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue)
            } else {
                filletedCorner(CGSize(width: corner, height: corner), UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue)|(UIRectCorner.topRight.rawValue)))
            }
        }
        else {
            if #available(iOS 11.0, *) {
                layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue | CACornerMask.layerMinXMaxYCorner.rawValue | CACornerMask.layerMaxXMaxYCorner.rawValue)
            } else {
                filletedCorner(CGSize(width: corner, height: corner), UIRectCorner(rawValue: (UIRectCorner.topLeft.rawValue)|(UIRectCorner.topRight.rawValue)|(UIRectCorner.bottomRight.rawValue)|(UIRectCorner.bottomLeft.rawValue)))
            }

            if isSelected {
                layer.borderColor = UIColor.init(netHex: 0x23AC38).cgColor
                backgroundColor = UIColor.init(netHex: 0xEEFAF0)
            }
            else {
                layer.borderColor = UIColor.init(netHex: 0xE6E6E6).cgColor
                backgroundColor = UIColor.white
               
            }
        }

    }
    
    

}
extension UIView {
 
    /// 设置多个圆角
    ///
    /// - Parameters:
    ///   - cornerRadii: 圆角幅度
    ///   - roundingCorners: UIRectCorner(rawValue: (UIRectCorner.topRight.rawValue) | (UIRectCorner.bottomRight.rawValue))
     public func filletedCorner(_ cornerRadii:CGSize,_ roundingCorners:UIRectCorner)  {
          let fieldPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii:cornerRadii )
          let fieldLayer = CAShapeLayer()
          fieldLayer.frame = bounds
          fieldLayer.path = fieldPath.cgPath
          self.layer.mask = fieldLayer
    }
}
