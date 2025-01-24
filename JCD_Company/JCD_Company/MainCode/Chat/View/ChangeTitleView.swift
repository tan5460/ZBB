//
//  ChangeTitleView.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

extension UISegmentedControl {

    public func ensureiOS13Style() {

        if #available(iOS 13.0, *) {
            
            let tintColorImage = tintColor.image(size: CGSize(width: 1, height: 30), radius: 0)

            setBackgroundImage(UIColor.white.image(), for: .normal, barMetrics: .default)

            setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)

            setBackgroundImage(tintColorImage, for: .highlighted, barMetrics: .default)

            setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)

            layer.borderColor = tintColor.cgColor

            layer.borderWidth = 1

            setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)
            setTitleTextAttributes([NSAttributedString.Key.foregroundColor : tintColor], for: .normal)
            
            snp.makeConstraints { (make) in
                make.height.equalTo(30)
            }
        }

    }
}

class ChangeTitleView: UIView {
 
    var selectItemIndex:((_ index:Int)->())?
    
    lazy var segmentView:UISegmentedControl = {
        let seg = UISegmentedControl(items: ["待办", "聊天"])
        seg.tintColor = UIColor.colorFromRGB(rgbValue: 0x23AC38)
        seg.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        seg.selectedSegmentIndex = 0
        seg.setWidth(80, forSegmentAt: 0)
        seg.setWidth(80, forSegmentAt: 1)
        seg.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)], for: .normal)
        seg.ensureiOS13Style()
       
        return seg
    }()
    
    lazy var unReadView1:UIView = {
        let rview = UIView()
        rview.isHidden = true
        rview.backgroundColor = PublicColor.unreadMsgColor
        rview.layer.cornerRadius = 3
        return rview
    }()
    
    lazy var unReadView2:UIView = {
        let rview = UIView()
        rview.isHidden = true
        rview.backgroundColor = PublicColor.unreadMsgColor
        rview.layer.cornerRadius = 3
        return rview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        self.addSubview(segmentView)
        segmentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(unReadView1)
        self.addSubview(unReadView2)
        unReadView2.snp.makeConstraints { (make) in
            make.centerX.equalTo(segmentView.snp.centerX).offset(-22)
            make.top.equalTo(6)
            make.height.width.equalTo(6)
        }
       
        unReadView1.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.top.equalTo(6)
            make.height.width.equalTo(6)
        }
    }
    
    func showOrhiddenUnReadView(index:Int,isHidden:Bool) {
        if index == 0 {
            unReadView1.isHidden = isHidden
        }else if index == 1 {
            unReadView2.isHidden = isHidden
        }
    }
    
    @objc func segmentAction(seg:UISegmentedControl) {
        
        selectItemIndex?(seg.selectedSegmentIndex)
//        if seg.selectedSegmentIndex == 1 {
//            unReadView2.isHidden = true
//        }
    }
}
