//
//  UIButton+Ex.swift
//  YS_HelloRead
//
//  Created by Cloud on 2019/4/16.
//  Copyright © 2019 chaoyun. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    /// 设置字体，字体为系统字体
    ///
    /// - Parameter ofSize: 字体大小
    /// - Returns: self
    @discardableResult
    func font(_ size: CGFloat, weight: UIFont.Weight? = nil) -> Self {
        if let weight = weight {
           titleLabel?.font = UIFont.systemFont(ofSize: size, weight: weight)
        } else {
            titleLabel?.font = UIFont.systemFont(ofSize: size)
        }
        
        return self
    }
    @discardableResult
    func font(_ size: Int, weight: UIFont.Weight? = nil) -> Self {
        if let weight = weight {
            titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(size), weight: weight)
        } else {
            titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(size))
        }
        
        return self
    }
    
    /// 设置字体颜色， 默认为normal
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - state: 状态
    /// - Returns: self
    @discardableResult
    func textColor(_ color: UIColor, state: UIControl.State = UIControl.State.normal) -> Self {
        setTitleColor(color, for: state)
        return self
    }
    @discardableResult
    func image(_ image: UIImage?) -> Self {
        guard let image = image else {
            return self
        }
        setImage(image, for: .normal)
        return self
    }
    
    @discardableResult
    func addImage(_ urlString: String?) -> Bool {
        var str = urlString
        str = str?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if var urlStr = str, !urlStr.isEmpty {
            urlStr = APIURL.ossPicUrl + urlStr
            self.sd_setImage(with: URL.init(string: urlStr), for: .normal, completed: nil)
            return true
        } else {
            return false
        }
    }
    @discardableResult
    func backgroundImage(_ color: UIColor?) -> Self {
        guard let color = color else {
            return self
        }
        setBackgroundImage(UIImage.imageFromColor(color: color), for: .normal)
        return self
    }
    @discardableResult
    func backgroundImage(_ image: UIImage?) -> Self {
        guard let image = image else {
            return self
        }
        setBackgroundImage(image, for: .normal)
        return self
    }
    
    /// 添加阴影
    ///
    /// - Returns: self
    func addShadow() -> Self {
        return addShadow(radius: 8)
    }
    
    /// 添加阴影
    ///
    /// - Returns: self
    func addShadow(radius: CGFloat) -> Self {
        layer.shadowColor = UIColor.hexColor("#999999", alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = radius
        return self
    }
    
    func layoutButton(imageTitleSpace: CGFloat) {
        
        //得到imageView和titleLabel的宽高
        let imageWidth = self.imageView?.frame.size.width
        let imageHeight = self.imageView?.frame.size.height
        
        var labelWidth: CGFloat! = 0.0
        var labelHeight: CGFloat! = 0.0
        
        labelWidth = self.titleLabel?.intrinsicContentSize.width
        labelHeight = self.titleLabel?.intrinsicContentSize.height
        
        //初始化imageEdgeInsets和labelEdgeInsets
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        
        //重点： 修改imageEdgeInsets和labelEdgeInsets的相对位置的计算
        imageEdgeInsets = UIEdgeInsets(top: -labelHeight-imageTitleSpace/2, left: 0, bottom: 0, right: -labelWidth)
        labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!, bottom: -imageHeight!-imageTitleSpace/2, right: 0)
       // break;
        
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
        
    }
    func addTarget(_ target: Any?, action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
}

typealias buttonClick = ((UIButton)->Void) // 定义数据类型(其实就是设置别名)
extension UIButton {
    // 改进写法【推荐】
    private struct RuntimeKey {
        static let actionBlock = UnsafeRawPointer.init(bitPattern: "actionBlock".hashValue)
        /// ...其他Key声明
    }
    /// 运行时关联
    private var actionBlock: buttonClick? {
        set {
            objc_setAssociatedObject(self, UIButton.RuntimeKey.actionBlock!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return  objc_getAssociatedObject(self, UIButton.RuntimeKey.actionBlock!) as? buttonClick
        }
    }
     /// 点击回调
    @objc func tapped(button:UIButton){
        self.actionBlock?(button)
    }
    
    func tapped(action:@escaping buttonClick) {
        self.addTarget(self, action:#selector(tapped(button:)) , for:.touchUpInside)
        self.actionBlock = action
        self.sizeToFit()
    }
    
    /// 快速创建
    convenience init(action:@escaping buttonClick){
        self.init()
        self.addTarget(self, action:#selector(tapped(button:)) , for:.touchUpInside)
        self.actionBlock = action
        self.sizeToFit()
    }
    /// 快速创建
    convenience init(setImage:String, action:@escaping buttonClick){
        self.init()
        self.frame = frame
        self.setImage(UIImage(named:setImage), for: UIControl.State.normal)
        self.addTarget(self, action:#selector(tapped(button:)) , for:.touchUpInside)
        self.actionBlock = action
        self.sizeToFit()
    }
    /// 快速创建按钮 setImage: 图片名 frame:frame action:点击事件的回调
    convenience init(setImage:String, frame:CGRect, action: @escaping buttonClick){
        self.init( setImage: setImage, action: action)
        self.frame = frame
    }
}
