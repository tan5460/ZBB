//
//  FloatSwipeButton.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/16.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
// 声明协议
class FloatSwipeButton: UIButton {

    // 拖拽后是否自动移到边缘
    var isAbsortEnable: Bool = true
    
    // 背景颜色
    var bgColor: UIColor? = UIColor.clear
    
    // 按钮距离边缘的内边距
    var paddingOfbutton: CGFloat = 2
    
    // 内部使用 起到数据传递的作用
    fileprivate var allPoint: CGPoint?
    
    // 内部使用
    fileprivate var isHasMove: Bool = false
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = self.bgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        super.touchesBegan(touches, with: event)
        
        self.allPoint = touches.first?.location(in: self)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isHasMove = true

        let temp = touches.first?.location(in: self)
        // 计算偏移量
        let offsetx = (temp?.x)! - (self.allPoint?.x)!
        let offsety = (temp?.y)! - (self.allPoint?.y)!
        self.center = CGPoint.init(x: self.center.x + offsetx, y: self.center.y + offsety)
       
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        // 这段代码只有在按钮移动后才需要执行
        if self.isHasMove && isAbsortEnable && self.superview != nil {
            // 移到父view边缘
//            let marginL = self.frame.origin.x
            var marginT = self.frame.origin.y
            
            let navHeight = UIApplication.shared.statusBarFrame.height + 44
            let tempy = PublicSize.screenHeight - 44 - 34 - self.height - self.paddingOfbutton
            
            let xOfR = PublicSize.screenWidth - self.frame.width - self.paddingOfbutton
            UIView.animate(withDuration: 0.2, animations: {
                
                // 靠右移动
                if marginT > tempy {
                    marginT = tempy
                }
                if marginT < navHeight + self.paddingOfbutton {
                    marginT = navHeight + self.paddingOfbutton
                }
                self.frame = CGRect.init(x: xOfR, y: marginT, width: self.frame.width, height: self.frame.height)
                
//                if marginL > (PublicSize.screenWidth / 2) {
//                    if marginT > tempy {
//                        marginT = tempy
//                    }
//                    if marginT < navHeight + self.paddingOfbutton {
//                        marginT = navHeight + self.paddingOfbutton
//                    }
//                    // 靠右移动
//                    self.frame = CGRect.init(x: xOfR, y: marginT, width: self.frame.width, height: self.frame.height)
//                } else {
//                    if marginT > tempy {
//                        marginT = tempy
//                    }
//                    if marginT < navHeight + self.paddingOfbutton {
//                        marginT = navHeight + self.paddingOfbutton
//                    }
//                    // 靠左移动
//                    self.frame = CGRect.init(x: self.paddingOfbutton, y: marginT, width: self.frame.width, height: self.frame.height)
//                }
            })
        }
        self.isHasMove = false
        
        let temp = touches.first?.location(in: self)
       
        if temp?.x == self.allPoint?.x && temp?.y == self.allPoint?.y {
            super.touchesEnded(touches, with: event)
        }else {
            self.isHighlighted = false
        }
        
    }
    
}
