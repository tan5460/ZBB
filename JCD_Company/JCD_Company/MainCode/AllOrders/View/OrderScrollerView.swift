//
//  OrderScrollerView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/16.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class OrderScrollerView: UIScrollView, UIGestureRecognizerDelegate{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    //手势可同时触发
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }

}
