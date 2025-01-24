//
//  UIView+Other.swift
//  YS_HelloRead
//
//  Created by Cloud on 2018/12/22.
//  Copyright © 2018 chaoyun. All rights reserved.
//

import UIKit

public struct UIRectSide: OptionSet {
    public let rawValue: Int
    
    public static let left = UIRectSide(rawValue: 1 << 0)
    
    public static let top = UIRectSide(rawValue: 1 << 1)
    
    public static let right = UIRectSide(rawValue: 1 << 2)
    
    public static let bottom = UIRectSide(rawValue: 1 << 3)
    
    public static let all: UIRectSide = [.top, .right, .left, .bottom]
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
}

extension UIView {
    ///画虚线边框
    
    func drawDashLine(strokeColor: UIColor, lineWidth: CGFloat = 1, lineLength: Int = 10, lineSpacing: Int = 5, corners: UIRectSide) {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = .round
        //每一段虚线长度 和 每两段虚线之间的间隔
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        let path = CGMutablePath()
        
        if corners.contains(.left) {
            
            path.move(to: CGPoint(x: 0, y: self.layer.bounds.height))
            
            path.addLine(to: CGPoint(x: 0, y: 0))
            
        }
        if corners.contains(.top) {
            path.move(to: CGPoint(x: 0, y: 0))
            
            path.addLine(to: CGPoint(x: self.layer.bounds.width, y: 0))
            
        }
        if corners.contains(.right) {
            
            path.move(to: CGPoint(x: self.layer.bounds.width, y: 0))
            
            path.addLine(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
            
        }
        if corners.contains(.bottom) {
            path.move(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
            path.addLine(to: CGPoint(x: 0, y: self.layer.bounds.height))
        }
        
        shapeLayer.path = path
        
        self.layer.addSublayer(shapeLayer)
        
    }
    
    ///画实线边框
    func drawLine(strokeColor: UIColor, lineWidth: CGFloat = 1, corners: UIRectSide) {
        if corners == UIRectSide.all {
            self.layer.borderWidth = lineWidth
            self.layer.borderColor = strokeColor.cgColor
        } else {
            let shapeLayer = CAShapeLayer()
            shapeLayer.bounds = self.bounds
            shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
            shapeLayer.fillColor = UIColor.blue.cgColor
            shapeLayer.strokeColor = strokeColor.cgColor
            shapeLayer.lineWidth = lineWidth
            shapeLayer.lineJoin = .round
            let path = CGMutablePath()
            if corners.contains(.left) {
                path.move(to: CGPoint(x: 0, y: self.layer.bounds.height))
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
            if corners.contains(.top) {
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: self.layer.bounds.width, y: 0))
            }
            if corners.contains(.right) {
                path.move(to: CGPoint(x: self.layer.bounds.width, y: 0))
                path.addLine(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
            }
            if corners.contains(.bottom) {
                path.move(to: CGPoint(x: self.layer.bounds.width, y: self.layer.bounds.height))
                path.addLine(to: CGPoint(x: 0, y: self.layer.bounds.height))
            }
            shapeLayer.path = path
            self.layer.addSublayer(shapeLayer)
        }
    }
    //画虚线
    func drawDashLine(lineView: UIView, lineLength: Int, lineSpacing: Int, lineColor: UIColor) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.bounds = lineView.bounds
        //        只要是CALayer这种类型,他的anchorPoint默认都是(0.5,0.5)
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
        //        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = lineColor.cgColor
        
        shapeLayer.lineWidth = lineView.frame.size.height
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [NSNumber(value: lineLength), NSNumber(value: lineSpacing)]
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: lineView.frame.size.width, y: 0))
        
        shapeLayer.path = path
        lineView.layer.addSublayer(shapeLayer) 
    }

    var parentController: UIViewController? {
        var responder = self.next
        while responder != nil {
            if responder!.isKind(of: UIViewController.self) {
                return responder as? UIViewController
            }
            responder = responder!.next
        }
        return nil
    }
}
