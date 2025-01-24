//
//  PictureBrowseController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/1/30.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class PictureBrowseController: BaseViewController, UIScrollViewDelegate {

    var showImage: UIImage!             //需展示的图片
    var showImageView: UIImageView!     //图片视图
    var scrollerView: UIScrollView!     //滚动视图
    
    var imageHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isStatusHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isStatusHidden = false
    }
    
    func createSubView() {
        
        //滚动视图
        scrollerView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: PublicSize.screenHeight))
        scrollerView.backgroundColor = UIColor.black
        scrollerView.maximumZoomScale = 3
        scrollerView.delegate = self
        scrollerView.bounces = true
        scrollerView.alwaysBounceHorizontal = true
        view.addSubview(scrollerView)
        
        //手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(tapOneAction))
        //通过numberOfTouchesRequired属性设置触摸点数，比如设置2表示必须两个手指触摸时才会触发
        tapOne.numberOfTapsRequired = 1
        //通过numberOfTapsRequired属性设置点击次数，单击设置为1，双击设置为2
        tapOne.numberOfTouchesRequired = 1
        
        //双击
        let tapTwo = UITapGestureRecognizer(target: self, action: #selector(tapTwoAction))
        tapTwo.numberOfTapsRequired = 2
        tapTwo.numberOfTouchesRequired = 1
        //声明点击事件需要双击事件检测失败后才会执行
        tapOne.require(toFail: tapTwo)
        
        scrollerView.addGestureRecognizer(tapOne)
        scrollerView.addGestureRecognizer(tapTwo)
        
        //图片视图
        var imageWidth: CGFloat = 0
        let imageRatio = showImage.size.width/showImage.size.height
        let screenRatio = PublicSize.screenWidth/PublicSize.screenHeight
        
        if imageRatio > screenRatio {
            imageWidth = PublicSize.screenWidth
            imageHeight = showImage.size.height * PublicSize.screenWidth / showImage.size.width
        }else {
            imageHeight = PublicSize.screenHeight
            imageWidth = showImage.size.width * PublicSize.screenHeight / showImage.size.height
        }
        
        showImageView = UIImageView.init(frame: CGRect.init(x: 0, y: (PublicSize.screenHeight-imageHeight)/2, width: imageWidth, height: imageHeight))
        showImageView.contentMode = .scaleAspectFit
        showImageView.image = showImage
        scrollerView.addSubview(showImageView)
    }
    
    /// 单击事件
    @objc func tapOneAction() {
        self.dismiss(animated: false, completion: nil)
    }
    
    /// 双击事件
    @objc func tapTwoAction() {
        
        if scrollerView.zoomScale > 1 {
            scrollerView.setZoomScale(1, animated: true)
        }else {
            scrollerView.setZoomScale(3, animated: true)
        }
        
        AppLog(scrollerView.contentSize)
    }
    
    //MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return showImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
        var xcenter = scrollView.center.x
        var ycenter = scrollView.center.y
        
        xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter
        ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter
        showImageView.center = CGPoint.init(x: xcenter, y: ycenter)
    }
    
}
