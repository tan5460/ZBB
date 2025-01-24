//
//  HomeFooterView.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/27.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit

class HomeFooterView: UICollectionReusableView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var pageTimer: Timer!
    
    var allViewArr: Array<UIView> = []              //总共页面
    var brandViewArr: Array<UIView> = []            //轮播页面
    
    var screenWidth = PublicSize.screenWidth
    var scrollHeight: CGFloat = 0
    
    let cellWidth: CGFloat = IS_iPad ? PublicSize.screenWidth*113.0/768 : PublicSize.RateWidth*72
    let cellLeft: CGFloat = IS_iPad ? PublicSize.screenWidth*80.0/768 : PublicSize.RateWidth*20
    
    var cellHeight: CGFloat {
        get {
            return scrollHeight*(IS_iPad ? 64.0/240.4 : 40.0/146)
        }
    }
    var cellTop: CGFloat {
        get {
            return scrollHeight*(IS_iPad ? 39.0/240.4 : 25.0/146)
        }
    }
    var cellSpacing: CGFloat {
        get {
            return (PublicSize.screenWidth-cellWidth*4-cellLeft*2)/3
        }
    }
    var cellLine: CGFloat {
        get {
            return scrollHeight-cellHeight*2-cellTop*2-(IS_iPad ? 0 : 5)
        }
    }
    
    
    var brandImageList: Array<UIButton>? {
        
        didSet {
            
            //清除刷新前数据
            allViewArr.removeAll()
            brandViewArr.removeAll()
            
            //没有数据时
            if brandImageList!.count <= 0 {
                
                pageControl.isHidden = true
                scrollView.isScrollEnabled = false
                
                //设置中间页显示内容
                let brandBackView = scrollView.viewWithTag(101)
                
                var subView = brandBackView?.viewWithTag(201)
                
                if subView != nil {
                    subView?.removeFromSuperview()
                }
                
                subView = UIView()
                subView?.backgroundColor = .white
                subView?.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: scrollHeight)
                subView?.tag = 201
                brandBackView?.addSubview(subView!)
                
                let imgView = UIImageView.init(image: UIImage.init(named: "img_panda"))
                imgView.frame = CGRect.init(x: (screenWidth-49)/2, y: 15, width: 49, height: 67)
                subView!.addSubview(imgView)
                
                let btn = UIButton()
                let str = "立即登录"
                let attributedString = NSMutableAttributedString(string:"")
                let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize:14.0),
                             NSAttributedString.Key.foregroundColor : PublicColor.emphasizeTextColor,
                             NSAttributedString.Key.underlineStyle :1] as [NSAttributedString.Key : Any]
                let setstr = NSMutableAttributedString.init(string: str, attributes: attrs)
                attributedString.append(setstr)
                btn.setAttributedTitle(attributedString, for: .normal)
                btn.frame = CGRect.init(x: (screenWidth-80)/2, y: imgView.bottom+12, width: 80, height: 20)
                btn.addTarget(self, action: #selector(clickLoginAction), for: .touchUpInside)
                subView!.addSubview(btn)
                
                //关闭时钟
                if let timer = pageTimer {
                    if timer.isValid {
                        timer.invalidate()
                    }
                }
                
                return
            }
            
            let imageCount = (brandImageList!.count/8)+1
            
            for i in 0..<imageCount {
                
                let brandsView = UIView(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: scrollHeight))
                
                var jCount = 0
                if i < imageCount-1 {
                    jCount = 8
                }else {
                    jCount = brandImageList!.count%8
                }
                
                for j in 0..<jCount {
                    let logoView = brandImageList![j+i*8]
                    
                    logoView.frame = CGRect.init(x: cellLeft+(cellSpacing+cellWidth)*CGFloat(j%4), y: cellTop+(cellHeight+cellLine)*CGFloat(j/4), width: cellWidth, height: cellHeight)
                    brandsView.addSubview(logoView)
                }
                
                if jCount > 0 {
                    allViewArr.append(brandsView)
                }
            }
            
            if allViewArr.count > 1 {
                
                //超过一页
                scrollView.isScrollEnabled = true
                
                //设置页面内容
                let view3 = allViewArr.last
                brandViewArr.append(view3!)
                
                let view1 = allViewArr[0]
                brandViewArr.append(view1)
                
                let view2 = allViewArr[1]
                brandViewArr.append(view2)
                
                //设置页显示内容
                for i in 0..<3 {
                    
                    let brandBackView = scrollView.viewWithTag(100+i)
                    
                    var subView = brandBackView?.viewWithTag(200+i)
                    
                    if subView != nil {
                        subView?.removeFromSuperview()
                    }
                    
                    subView = brandViewArr[i]
                    subView?.tag = 200+i
                    brandBackView?.addSubview(subView!)
                }
                
                //开启时钟，显示分页指示器
                if let timer = pageTimer {
                    if !timer.isValid {
                        creatTimer()
                    }
                }else {
                    creatTimer()
                }
                
                pageControl.isHidden = false
                pageControl.numberOfPages = allViewArr.count
                pageControl.currentPage = 0
            }
            else if allViewArr.count == 1 {
                
                //只有一页
                scrollView.isScrollEnabled = false
                
                //设置页面内容
                let view1 = allViewArr[0]
                brandViewArr.append(view1)
                brandViewArr.append(view1)
                brandViewArr.append(view1)
                
                //设置中间页显示内容
                let brandBackView = scrollView.viewWithTag(101)
                
                var subView = brandBackView?.viewWithTag(201)
                
                if subView != nil {
                    subView?.removeFromSuperview()
                }
                
                subView = brandViewArr[0]
                subView?.tag = 201
                brandBackView?.addSubview(subView!)
                
                //关闭时钟，隐藏分页指示器
                if let timer = pageTimer {
                    if timer.isValid {
                        timer.invalidate()
                    }
                }
                
                pageControl.isHidden = true
            }
            
        }
    }
    
    deinit {
        AppLog("首页尾视图释放")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        scrollHeight = self.frame.size.height-10
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creatTimer() {
        
        pageTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(setScrollPage), userInfo: nil, repeats: true)
    }
    
    @objc func setScrollPage() {
        
        //刷新轮播图
        updateImageShow()
        
        var point = scrollView.contentOffset
        point.x += screenWidth
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.scrollView.contentOffset = point
            
        }) { (finish) in
            
            //刷新轮播图
            self.updateImageShow()
        }
    }
    
    //刷新图片位置 轮播图归位
    func updateImageShow() {
        
        let contentIndex: Int = Int(scrollView.contentOffset.x / screenWidth)
        
        var centerView = brandViewArr[1]
        
        if contentIndex == 0 {
            
            centerView = brandViewArr[0]
            brandViewArr[1] = centerView
        }
        else if contentIndex == 2 {
            
            centerView = brandViewArr[2]
            brandViewArr[1] = centerView
        }
        
        let imageIndex = allViewArr.firstIndex(of: centerView)!
        
        if imageIndex == 0 {
            brandViewArr[0] = allViewArr[allViewArr.count-1]
            brandViewArr[2] = allViewArr[imageIndex+1]
        }
        else if imageIndex == allViewArr.count-1 {
            brandViewArr[0] = allViewArr[imageIndex-1]
            brandViewArr[2] = allViewArr[0]
        }
        else {
            brandViewArr[0] = allViewArr[imageIndex-1]
            brandViewArr[2] = allViewArr[imageIndex+1]
        }
        
        //跳回中间
        if contentIndex != 1 {
            scrollView.contentOffset = CGPoint(x: screenWidth, y: 0)
            
            for i in 0..<3 {
                
                let brandBackView = scrollView.viewWithTag(100+i)
                
                var subView = brandBackView?.viewWithTag(200+i)
                
                if subView != nil {
                    subView?.removeFromSuperview()
                }
                
                subView = brandViewArr[i]
                subView?.tag = 200+i
                brandBackView?.addSubview(subView!)
            }
        }
        
        pageControl.currentPage = imageIndex
    }
    
    func createSubView() {
        
        //轮播图 创建展示图片
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize.init(width: 3*screenWidth, height: 0)
        self.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        
        for i in 0..<3 {
            let brandView = UIView(frame: CGRect.init(x: CGFloat(i)*screenWidth, y: 0, width: screenWidth, height: scrollHeight))
            brandView.tag = 100+i
            scrollView.addSubview(brandView)
            
            let subView = UIView()
            subView.backgroundColor = .white
            subView.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: scrollHeight)
            subView.tag = 200+i
            brandView.addSubview(subView)
            
            let imgView = UIImageView.init(image: UIImage.init(named: "img_panda"))
            imgView.frame = CGRect.init(x: (screenWidth-49)/2, y: 15, width: 49, height: 67)
            subView.addSubview(imgView)
            
            let btn = UIButton()
            let str = "立即登录"
            let attributedString = NSMutableAttributedString(string:"")
            let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize:14.0),
                         NSAttributedString.Key.foregroundColor : UIColor.colorFromRGB(rgbValue: 0xFB6E30),
                         NSAttributedString.Key.underlineStyle :1] as [NSAttributedString.Key : Any]
            let setstr = NSMutableAttributedString.init(string: str, attributes: attrs)
            attributedString.append(setstr)
            btn.setAttributedTitle(attributedString, for: .normal)
            btn.frame = CGRect.init(x: (screenWidth-80)/2, y: imgView.bottom+12, width: 80, height: 20)
            btn.addTarget(self, action: #selector(clickLoginAction), for: .touchUpInside)
            subView.addSubview(btn)
        }
        
        //下标
        pageControl = UIPageControl()
        pageControl.isHidden = true
        pageControl.numberOfPages = 1
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor.colorFromRGB(rgbValue: 0xF37041)
        pageControl.pageIndicatorTintColor = UIColor.colorFromRGB(rgbValue: 0xC9C9C9)
        self.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-6)
        }
        
        //设置初始偏移量
        scrollView.contentOffset = CGPoint.init(x: screenWidth, y: 0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if allViewArr.count <= 0 {
            return
        }
        
        if let timer = pageTimer {
            if timer.isValid {
                return
            }
        }
        
        let point = scrollView.contentOffset
        if point.x <= 0 || point.x >= 2*screenWidth {
            //刷新轮播图
            updateImageShow()
        }
        
        var isLeftScroll = false
        
        if point.x < screenWidth {
            isLeftScroll = true
        }
        
        for i in 0..<3 {
            var j = i
            if isLeftScroll {
                j = 2-i
            }
            
            let brandBackView = scrollView.viewWithTag(100+j)
            
            var subView = brandBackView?.viewWithTag(200+j)
            
            if subView != nil {
                subView?.removeFromSuperview()
            }
            
            subView = brandViewArr[j]
            subView?.tag = 200+j
            brandBackView?.addSubview(subView!)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let timer = pageTimer {
            if timer.isValid {
                pageTimer.invalidate()
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if let timer = pageTimer {
            if !timer.isValid {
                creatTimer()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        AppLog("停止滚动")
        
        //刷新轮播图
        updateImageShow()
    }
    
    //立即登录
    @objc func clickLoginAction() {
        ToolsFunc.showLoginVC()
    }
}
