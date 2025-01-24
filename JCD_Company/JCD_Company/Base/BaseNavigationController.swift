//
//  BaseNavigationController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/22.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController,UINavigationControllerDelegate {
    
    var popDelegate: UIGestureRecognizerDelegate?
    
    //想要通过`rootViewController`来控制`UIStatusBarStyle`,需重写此方法
    override var childForStatusBarStyle: UIViewController?{
        return self.topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //导航栏按钮颜色
        navigationBar.tintColor = UIColor.black
        
        //导航栏背景颜色
        navigationBar.barTintColor = .white
        
        //导航栏半透明
        navigationBar.isTranslucent = false

        //导航栏字体
        navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black]
        
        //侧滑
        self.popDelegate = self.interactivePopGestureRecognizer?.delegate
        self.delegate = self

    }

    /**
     *  重写这个方法的目的:为了拦截整个push过程,拿到所有push进来的子控制器
     *
     *  @param viewController 当前push进来的子控制器
     */
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            // 当push这个子控制器时, 隐藏底部的工具条
            viewController.hidesBottomBarWhenPushed = true
            
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(back))
        }
        
        super.pushViewController(viewController, animated: animated)
        
        self.setNavigationBarHidden(false, animated: true)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        super.popToViewController(viewController, animated: animated)
        return viewControllers
    }
   
    @objc func back() {
        self.popViewController(animated: true)
    }
    
   //UINavigationControllerDelegate方法
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        //实现滑动返回功能
        //清空滑动返回手势的代理就能实现
        if viewController == self.viewControllers[0] {
            self.interactivePopGestureRecognizer!.delegate = self.popDelegate
        }
        else {
            self.interactivePopGestureRecognizer!.delegate = nil
        }
    }
    
    //MARK: - 横竖屏支持
    override var shouldAutorotate: Bool {
        return (topViewController?.shouldAutorotate)!
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (topViewController?.supportedInterfaceOrientations)!
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return (topViewController?.preferredInterfaceOrientationForPresentation)!
    }
    
    
    
}

extension UINavigationController {
    
    func showShadowImage() {
        navigationBar.shadowImage = nil
    }
    
    func hideShadowImage() {
        navigationBar.shadowImage = UIImage()
    }
}
