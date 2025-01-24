//
//  UIFont+Ex.swift
//  ChalkTalks
//
//  Created by 巢云 on 2019/9/4.
//  Copyright © 2019 巢云. All rights reserved.
//

import Foundation
import UIKit
// MARK: - Font
extension UILabel {
    @discardableResult
    func font(_ size: CGFloat, weight: UIFont.Weight? = nil) -> Self {
        if let weight = weight {
            font = UIFont.systemFont(ofSize: size, weight: weight)
        } else {
            font = UIFont.systemFont(ofSize: size)
        }
        return self
    }
    @discardableResult
    func font(_ size: Int, weight: UIFont.Weight? = nil) -> Self {
        if let weight = weight {
            font = UIFont.systemFont(ofSize: CGFloat(size), weight: weight)
        } else {
            font = UIFont.systemFont(ofSize: CGFloat(size))
        }
        return self
    }
    @discardableResult
    func fontBold(_ size: CGFloat) -> Self {
        font = UIFont.systemFont(ofSize: CGFloat(size), weight: .bold)
        return self
    }
    
    @discardableResult
    func font(_ theFont: UIFont) -> Self {
        font = theFont
        return self
    }
    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        textColor = color
        return self
    }
    @discardableResult
    func fontSemibold(_ size: CGFloat) -> Self {
        font = UIFont(name: "PingFangSC-Medium", size: 17.0)
        return self
    }
    @discardableResult
    func numberOfLines(_ num: Int) -> Self {
        numberOfLines = num
        return self
    }
    @discardableResult
    func textAligment(_ textAligment: NSTextAlignment) -> Self {
        self.textAlignment = textAligment
        return self
    }
}
// MARK: - Attributed
extension UILabel {
    /// 设置label行间距
    func lineSpace(_ value: CGFloat) {
        let attributedString = NSMutableAttributedString(string: text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineBreakMode = .byTruncatingTail
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: attributedString.length))
        attributedText = attributedString
    }
    
    ///给Label设置中划线
    func setLabelUnderline() {
        let priceString = NSMutableAttributedString.init(string: self.text ?? "")
        priceString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSNumber.init(value: 1), range: NSRange(location: 0, length: priceString.length))
        self.attributedText = priceString
    }
    
    ///去掉Label中划线
    func removeLabelUnderline() {
        let priceString = NSMutableAttributedString.init(string: self.text ?? "")
        priceString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSNumber.init(value: 0), range: NSRange(location: 0, length: priceString.length))
        self.attributedText = priceString
    }
    
}
