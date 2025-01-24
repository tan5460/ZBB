//
//  MainTabBar.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/15.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

protocol MainTabBarDelegate : NSObjectProtocol {
    func centerButtonClick(tabBar:MainTabBar, centerBtn:UIButton)
}

class MainTabBar: UITabBar {

    var centerBtn: UIButton!
    weak var mainTBDelegata : MainTabBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isTranslucent = false
        self.shadowImage = UIImage()
        self.backgroundImage = UIImage()
        self.backgroundColor = UIColor.white
        createCenterButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //创建中间按钮
    func createCenterButton(){
        
        //创建中间按钮
        centerBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        centerBtn.addTarget(self, action: #selector(centerDidClickAction), for: .touchUpInside)
        centerBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        centerBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        addSubview(centerBtn)
        centerBtn.set(image: UIImage(named: "scan_code"), title: "扫码选材", imagePosition: .top, additionalSpacing: 8, state: .normal)
  
    }
    
    //响应中间按钮点击事件
    @objc func centerDidClickAction() {
        if mainTBDelegata != nil {
            mainTBDelegata?.centerButtonClick(tabBar: self, centerBtn: centerBtn)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 把tabBarButton取出来
        var tabBarButtonArray: [UIView] = []
        for view: UIView in subviews {

            if view.isKind(of: NSClassFromString("UITabBarButton")!) {
                tabBarButtonArray.append(view)
            }
            
        }
        
        //获得宽高
        let barWidth = bounds.size.width
//        let barHeight = bounds.size.height
        let centerBtnWidth = centerBtn.frame.width
        let centerBtnHeight = centerBtn.frame.height
        
        // 设置中间按钮的位置，居中，凸起一丢丢
        centerBtn.frame = CGRect(x: (barWidth - centerBtnWidth) / 2, y: -8.7 , width: centerBtnWidth, height: centerBtnHeight)
        
        // 重新布局其他tabBarItem
        // 平均分配其他tabBarItem的宽度
        let barItemWidth: CGFloat = (barWidth - centerBtnWidth) / CGFloat(tabBarButtonArray.count)
        
        // 逐个布局tabBarItem，修改UITabBarButton的frame
        for (idx,view) in tabBarButtonArray.enumerated() {
            
            var frame: CGRect = view.frame
            if idx >= tabBarButtonArray.count / 2 {
                // 重新设置x坐标，如果排在中间按钮的右边需要加上中间按钮的宽度
                frame.origin.x = CGFloat(idx) * barItemWidth + centerBtnWidth
            } else {
                frame.origin.x = CGFloat(idx) * barItemWidth
            }
            // 重新设置宽度
            frame.size.width = barItemWidth;
            view.frame = frame;
        }
         // 把中间按钮带到视图最前面
        self.bringSubviewToFront(centerBtn)
    }
    
    // 重写hitTest方法，让超出tabBar部分也能响应事件
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if self.clipsToBounds || self.isHidden || (self.alpha == 0) {
            return nil;
        }
        var result: UIView? = super.hitTest(point, with: event)
        // 如果事件发生在tabbar里面直接返回
        if result != nil {
            return result;
        }
        // 这里遍历那些超出的部分就可以了，不过这么写比较通用。
        for subview in subviews {
           // 把这个坐标从tabbar的坐标系转为subview的坐标系
            let subPoint =  subview.convert(point, from: self)
            result = subview.hitTest(subPoint, with: event)
            // 如果事件发生在subView里就返回
            if result != nil {
                return result
            }
        }
       
        return nil
    }
}

extension UITabBar {
    
    func showBadgeOnItem(index: Int, btnCount: Float, unreadNo: Int = 1) {
        
        let width: CGFloat = 10
        removeBadgeOnItem(index: index)
        
        let bview = UIView.init()
        bview.tag = 888+index
        bview.layer.cornerRadius = width/2
        bview.clipsToBounds = true
        bview.backgroundColor = UIColor.red
        let tabFrame = self.frame
        
        let percentX = (Float(index)+0.6)/btnCount
        let x = CGFloat(ceilf(percentX*Float(tabFrame.width)))
//        let y = CGFloat(ceilf(0.1*Float(tabFrame.height)))
        bview.frame = CGRect(x: x, y: 5, width: width, height: width)
        
//        let cLabel = UILabel.init()
//        cLabel.text = "\(unreadNo)"
//        cLabel.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
//        cLabel.font = UIFont.systemFont(ofSize: 10)
//        cLabel.textColor = UIColor.white
//        cLabel.textAlignment = .center
//        bview.addSubview(cLabel)
        
        addSubview(bview)
        bringSubviewToFront(bview)
    }
    
    //隐藏红点
    func hideBadgeOnItem(index:Int) {
        removeBadgeOnItem(index: index)
    }
    
    //移除控件
    func removeBadgeOnItem(index:Int) {
        for subView:UIView in subviews {
            if subView.tag == 888+index {
                subView.removeFromSuperview()
            }
        }
    }
}
