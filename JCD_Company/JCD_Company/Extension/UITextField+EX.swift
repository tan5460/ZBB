//
//  UITextField+EX.swift
//  YS_HelloRead
//
//  Created by usen on 2019/7/19.
//  Copyright © 2019 chaoyun. All rights reserved.
//

import Foundation
import UIKit

var maxTextNumberDefault = 15

extension UITextField {

    func setVerifyCodeKeyboard() {
        if #available(iOS 12.0, *) {
          self.textContentType = .oneTimeCode
        }
    }
    
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
    func text(_ string: String) -> Self {
        text = string
        return self
    }
    
    private struct PlaceholderColorKey {
        static var identifier: String = "PlaceholderColorKey"
    }
    
    var placeholderColor: UIColor {
        get {
            return objc_getAssociatedObject(self, &PlaceholderColorKey.identifier) as! UIColor
        }
        set (newColor) {
            objc_setAssociatedObject(self, &PlaceholderColorKey.identifier, newColor, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            let attrString = NSMutableAttributedString.init(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: newColor, NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 15)])
            self.attributedPlaceholder = attrString
        }
    }
    
    /// 以runtime的形式UITextField添加最大输入字数属性
    public var maxTextNumber: Int {
        set {
            objc_setAssociatedObject(self, &maxTextNumberDefault, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            if let rs = objc_getAssociatedObject(self, &maxTextNumberDefault) as? Int {
                return rs
            }
            return 15
        }
    }
    /// 添加限制最大输入字数target
    public func addChangeTextTarget(){
        self.addTarget(self, action: #selector(changeText), for: .editingChanged)
    }
    @objc private func changeText(){
        //判断是不是在拼音状态,拼音状态不截取文本
        if let positionRange = self.markedTextRange{
            guard self.position(from: positionRange.start, offset: 0) != nil else {
                checkTextFieldText()
                return
            }
        }else {
            checkTextFieldText()
        }
    }
    /// 检测如果输入数高于设置最大输入数则截取
    private func checkTextFieldText(){
        guard (self.text?.utf16.count)! <= maxTextNumber  else {
            guard let text = self.text else {
                return
            }
            /// emoji的utf16.count是2，所以不能以maxTextNumber进行截取，改用text.count-1
            let sIndex = text.index(text
                .startIndex, offsetBy: text.count-1)
            self.text = String(text[..<sIndex])
            return
        }
    }
    
}
