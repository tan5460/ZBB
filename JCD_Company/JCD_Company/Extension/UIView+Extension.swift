//
//  UIView+Extension.swift
//  YS_JFQ
//
//  Created by Cloud on 2018/10/23.
//  Copyright © 2018 chaoyun. All rights reserved.
//

import UIKit

extension UIView {
    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        self.layoutIfNeeded()
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    /// 4个角都切圆角
    @discardableResult
    func corner(radii: CGFloat) -> Self {
        self.corner(byRoundingCorners: [.topRight, .topLeft, .bottomRight, .bottomLeft], radii: radii)
        return self
    }
    
    /// 设置渐变色
    ///
    /// - Parameters:
    ///   - color1: 开始颜色
    ///   - color2: 结束颜色
    ///   - isAcross: 是横着渐变还是竖着
    func gradient(color1: UIColor, color2: UIColor, isAcross: Bool = true) {
        //将颜色和颜色的位置定义在数组内
        let gradientColors: [CGColor] = [color1.cgColor, color2.cgColor]
        //创建并实例化CAGradientLayer
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        //(这里的起始和终止位置就是按照坐标系,四个角分别是左上(0,0),左下(0,1),右上(1,0),右下(1,1))
        if isAcross {
            //渲染的起始位置
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            //渲染的终止位置
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        } else {
            //渲染的起始位置
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            //渲染的终止位置
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        }
        //设置frame和插入view的layer
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addShadowColor() {
        self.layoutIfNeeded()
        
        addShadow(ofColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.16), radius: 5, offset: CGSize(width: 3, height: 3), opacity: 1)
    }
    
    func removeShadowColor() {
        self.layoutIfNeeded()
        addShadow(ofColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.16), radius: 5, offset: CGSize(width: 3, height: 3), opacity: 0)
    }
    
    func fillColor()  {
        layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 1, green: 0.53, blue: 0.13, alpha: 1).cgColor, UIColor(red: 0.85, green: 0.19, blue: 0.14, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(bgGradient, at: 0)
        //layer.addSublayer(bgGradient)
        layer.cornerRadius = 10;
        alpha = 1
    }
    
    func fillYelloColor()  {
        layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 1, green: 0.63, blue: 0, alpha: 1).cgColor, UIColor(red: 1, green: 0.67, blue: 0.24, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = bounds
        bgGradient.startPoint = CGPoint(x: 1, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 0, y: 0.5)
        layer.insertSublayer(bgGradient, at: 0)
        layer.cornerRadius = 10;
        alpha = 1
    }
    
    func fillGreenColor()  {
        layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.11, green: 0.77, blue: 0.59, alpha: 1).cgColor, UIColor(red: 0.38, green: 0.85, blue: 0.73, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = bounds
        bgGradient.startPoint = CGPoint(x: 1, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 0, y: 0.48)
        layer.insertSublayer(bgGradient, at: 0)
        layer.cornerRadius = 10;
        alpha = 1
    }
    
    func fillGreenColorLF()  {
        layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.38, green: 0.85, blue: 0.73, alpha: 1).cgColor, UIColor(red: 0.11, green: 0.77, blue: 0.59, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = bounds
        bgGradient.startPoint = CGPoint(x: 1, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 0, y: 0.5)
        layer.insertSublayer(bgGradient, at: 0)
        layer.cornerRadius = 10;
        alpha = 1
    }
    
    
    func fillRedColorLF()  {
        layoutIfNeeded()
        // fill
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.47, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.24, blue: 0.24, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = bounds
        bgGradient.startPoint = CGPoint(x: 0.05, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(bgGradient, at: 0)
        layer.cornerRadius = 10;
        alpha = 1
    }
    
    
    func fillGreenColorV()  {
        layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.87, green: 0.98, blue: 0.93, alpha: 1).cgColor, UIColor(red: 0, green: 0.53, blue: 0.3, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = bounds
        bgGradient.startPoint = CGPoint(x: 0.5, y: 1)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 0)
        layer.insertSublayer(bgGradient, at: 0)
        layer.cornerRadius = 15;
        alpha = 1
    }
    
    func clearShadowColor() {
        self.layoutIfNeeded()
        addShadow(ofColor: UIColor.init(white: 1, alpha: 0.0), radius: 8, offset: CGSize(width: 0, height: 2), opacity: 1)
    }
    
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }
    
    @discardableResult
    func alpha(_ value: CGFloat) -> Self {
        alpha = value
        return self
    }
    
    @discardableResult
    func cornerRadius(_ value: CGFloat) -> Self {
        layer.cornerRadius = value
        return self
    }
    
    @discardableResult
    func masksToBounds() -> Self {
        layer.masksToBounds = true
        return self
    }
    
    
    @discardableResult
    func borderWidth(_ value: CGFloat) -> Self {
        layer.borderWidth = value
        return self
    }
    
    @discardableResult
    func borderColor(_ color: UIColor) -> Self {
        layer.borderColor = color.cgColor
        return self
    }
    
}
