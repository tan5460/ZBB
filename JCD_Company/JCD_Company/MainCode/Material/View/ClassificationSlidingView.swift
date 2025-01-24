//
//  ClassificationSlidingView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/18.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class ClassificationSlidingView: UIView, UIScrollViewDelegate{

    var topView: UIView!                 //顶部视图
    var topButtons: Array<UIButton>!       //按钮数组
    var isClickButton: Bool = false       //是否是点击按钮改变按钮状态
    var selectBtnTag = 100               //选择的buttonTag
    var selectBtoView: UIView!            //选择的button下的横线
    var scollView: UIScrollView!           //滑动视图
    var scollBgViews: Array<UIView>!       //滑动视图上的子视图
    
    var changeSelectTagBlock:((_ selectBtnTag: Int?)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    //重写init方法
    init(frame: CGRect, titles:Array<String>) {
        super.init(frame: frame)
        
        self.createSubviews(titles)
    }

    //创建视图
    func createSubviews(_ titles:Array<String>) {
        
        //创建上部视图
        topView = UIView()
        topView.backgroundColor = UIColor.white
        topView.clipsToBounds = true
//        topView.layerShadow()
        addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(0)
//            make.height.equalTo(44)
        }
        
        scollView = UIScrollView()
        scollView.isPagingEnabled = true
        scollView.showsHorizontalScrollIndicator = false
        scollView.showsVerticalScrollIndicator = false
        scollView.delegate = self
        scollView.backgroundColor = UIColor.white
        addSubview(scollView)
        
        scollView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(1)
            make.bottom.right.left.equalToSuperview()
        }
        
        //创建上部视图上的按钮和滑动视图的子视图
        topButtons = []
        scollBgViews = []
        let w = (PublicSize.screenWidth - CGFloat(titles.count-1))/CGFloat(titles.count)
        for (i,title) in titles.enumerated() {
            
            let btn = UIButton()
            btn.setTitle(title, for: .normal)
            btn.tag = 100 + i
            btn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            btn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
            btn.frame = CGRect(x: (w+1)*CGFloat(i), y: 0, width: w, height: 44)
            topView.addSubview(btn)
            topButtons.append(btn)
            if i == 0 {
                btn.isSelected = true
                selectBtnTag = btn.tag
                
                selectBtoView = UIView()
                selectBtoView.frame = CGRect(x: (btn.width-63)/2, y: btn.bottom, width: 63, height: 1)
                selectBtoView.backgroundColor = PublicColor.emphasizeTextColor
                topView.addSubview(selectBtoView)
            }
            if i < titles.count-1 {
                let lineView = UIView()
                lineView.frame = CGRect(x: btn.right-0.5, y: (44-24)/2, width: 1, height: 24)
                lineView.backgroundColor = PublicColor.navigationLineColor
                topView.addSubview(lineView)
            }
            
            let bgView = UIView()
            scollView.addSubview(bgView)
            bgView.snp.makeConstraints { (make) in
                make.top.bottom.equalTo(scollView)
                make.width.equalTo(PublicSize.screenWidth)
                make.height.equalTo(scollView.snp.height)
                make.left.equalTo(scollView.snp.left).offset(PublicSize.screenWidth*CGFloat(i))
                if i == titles.count - 1 {
                    make.right.equalTo(scollView)
                }
            }
            scollBgViews.append(bgView)
        }
        
       
    }
    func changeScollView(_ sender:UIButton){
        buttonAction(sender)
    }
    
    @objc func buttonAction(_ sender:UIButton) {
        
        if selectBtnTag == sender.tag {return}
        let btn = topView.viewWithTag(selectBtnTag) as! UIButton
        btn.isSelected = false
        sender.isSelected = true
        selectBtnTag = sender.tag
        
        if let block = changeSelectTagBlock {
            block(selectBtnTag)
        }
        
        //按钮下视图动画
        isClickButton = true
        UIView.animate(withDuration: 0.3, animations: {
            self.selectBtoView.centerX = sender.centerX
        }) { (finish) in
            self.isClickButton = false
        }

        //滑动一页
        let rect = CGRect(x: PublicSize.screenWidth*CGFloat(sender.tag - 100), y: 0, width: scollView.width, height: scollView.height)
        self.scollView.scrollRectToVisible(rect, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //点击按钮不计算偏移量
        if isClickButton == true {return}
        
        let offsetX = scrollView.contentOffset.x
        if offsetX<=0 {return}
    
        let w = PublicSize.screenWidth
        var offset = offsetX/(w/2)
        
        if offset > 1 {
            offset = (offsetX-w/2)/w + 1
        }
        
        let tag = Int(offset) + 100
        
        if tag > topButtons.count - 1 + 100 {return}
        
//        print("\(offsetX)---------\(offset)----------\(tag)")
        if tag != selectBtnTag {
            let sbtn = topView.viewWithTag(selectBtnTag) as! UIButton
            sbtn.isSelected = false
            let sender = topView.viewWithTag(tag) as! UIButton
            sender.isSelected = true
            selectBtnTag = tag
            
            if let block = changeSelectTagBlock {
                block(selectBtnTag)
            }

            UIView.animate(withDuration: 0.3) {
                 self.selectBtoView.centerX = sender.centerX
            }
        }

    }
}

