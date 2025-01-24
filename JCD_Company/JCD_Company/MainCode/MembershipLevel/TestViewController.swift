//
//  TestViewController.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/26.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import TLTransitions

class TestViewController: UIViewController {

    var pop: TLTransition?
    override func viewDidLoad() {
        super.viewDidLoad()

        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 500)).backgroundColor(.white)
        let scrollView = UIScrollView().backgroundColor(.red)
        v.sv(scrollView)
        v.layout(
            100,
            |-0-scrollView-0-|,
            0
        )
        scrollView.refreshHeader {
            scrollView.endHeaderRefresh()
        }
        pop = TLTransition.show(v, popType: TLPopTypeActionSheet)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
