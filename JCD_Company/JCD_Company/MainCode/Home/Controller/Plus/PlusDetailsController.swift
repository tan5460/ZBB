//
//  PackageDetailsController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/2.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import WebKit

class PlusDetailsController: BaseViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    var bottomView: UIView!
    var progressView: UIProgressView!
    var detailUrl: String?
    var plusModel: PlusModel?
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 套餐详情页释放 <<<<<<<<<<<<<<<<<<")
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.navigationDelegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "套餐详情"
        
        prepareNavigationItem()
        createSubView()
    }
    
    func prepareNavigationItem() {
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "share_nav"), style: .plain, target: self, action: #selector(shareAction))
    }
    
    func createSubView() {
        
        //底部结算栏
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
            } else {
                make.height.equalTo(44)
            }
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        bottomView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //选此套餐
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        let addCartBtn = UIButton.init(type: .custom)
        addCartBtn.setTitle("选此套餐", for: .normal)
        addCartBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        addCartBtn.setTitleColor(UIColor.white, for: .normal)
        addCartBtn.setBackgroundImage(backgroundImg, for: .normal)
        addCartBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        addCartBtn.addTarget(self, action: #selector(buyBtnAction), for: .touchUpInside)
        bottomView.addSubview(addCartBtn)
        
        if IS_iPad {
            
            addCartBtn.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(44)
            }
        }
        else {
            addCartBtn.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.width.equalTo(120)
                make.height.equalTo(44)
            }
        }
        
        //套餐价
        let priceShowLabel = UILabel()
        priceShowLabel.text = "未定价"
        priceShowLabel.font = UIFont.systemFont(ofSize: 18)
        priceShowLabel.textColor = PublicColor.emphasizeTextColor
        bottomView.addSubview(priceShowLabel)
        
        priceShowLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(4)
        }
        
        let priceShowTitle = UILabel()
        priceShowTitle.text = "套餐价"
        priceShowTitle.font = UIFont.systemFont(ofSize: 11)
        priceShowTitle.textColor = UIColor.colorFromRGB(rgbValue: 0x4D4D4D)
        bottomView.addSubview(priceShowTitle)
        
        priceShowTitle.snp.makeConstraints { (make) in
            make.left.equalTo(priceShowLabel.snp.left)
            make.top.equalTo(priceShowLabel.snp.bottom)
        }
        
        if let valueStr = plusModel?.price?.doubleValue {
            let priceStr = valueStr.notRoundingString(afterPoint: 2)
            priceShowLabel.text = "￥" + priceStr
            
            if let unitValue = plusModel?.unitType?.intValue {
                
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(unitValue)", fieldB: "label")
                if unitStr.count > 0 {
                    
                    priceShowLabel.text = String.init(format: "￥%@/%@", priceStr, unitStr)
                }
                
            }
        }
        let config = WKWebViewConfiguration()
        //HTML5视频是否内联播放的布尔值(true)或使用本机全屏控制器(false)。默认值是false
        config.allowsInlineMediaPlayback = true
//        config.requiresUserActionForMediaPlayback = false
        config.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
        
        //webView
        webView = WKWebView.init(frame: CGRect.zero, configuration: config)
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        if let urlStr = detailUrl {
            let request = URLRequest.init(url:  URL.init(string: urlStr)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            webView.load(request)
        }
        
        //进度条
        progressView = UIProgressView()
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = PublicColor.progressColor
        progressView.transform = CGAffineTransform.init(scaleX: 1, y: 2)
        progressView.progress = 0.05 //设置初始值，防止网页加载过慢时没有进度
        view.addSubview(progressView)
        
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    
    //MARK: - 触发事件
    @objc func backAction() {
        if webView.canGoBack {
            webView.goBack()
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func backPopAction() {
        if webView.canGoBack {
            webView.goBack()
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareAction() {
        var storeName = ""
        if let valueStr = UserData.shared.workerModel?.store?.name {
            storeName = valueStr
        }
        
        let shareTitle = (self.plusModel?.name)!
        _ = "来自 \(storeName) 分享的套餐"
        var shareImage: Any!
        var shareUrl = ""
        if let valueStr = self.detailUrl {
            shareUrl = valueStr + "&signUp=1"
        }
        
        shareImage = UIImage.init(named: "shareImage")!
        if let valueStr = self.plusModel?.picUrl {
            if valueStr != "" {
                shareImage = APIURL.ossPicUrl + valueStr
            }
        }
        let items = [shareTitle, shareImage as Any, shareUrl as Any] as [Any]
         let activityVC = UIActivityViewController(
             activityItems: items,
             applicationActivities: nil)
        activityVC.completionWithItemsHandler =  { activity, success, items, error in
            print(activity as Any)
             print(success)
            print(items as Any)
            print(error as Any)
             
             
         }
         self.present(activityVC, animated: true, completion: { () -> Void in
             
         })
        
//        UMSocialUIManager.showShareMenuViewInWindow { (platformType, userInfo) in
//
//            var storeName = ""
//            if let valueStr = UserData.shared.workerModel?.store?.name {
//                storeName = valueStr
//            }
//
//            let shareTitle = (self.plusModel?.name)!
//            let shareDescr = "来自 \(storeName) 分享的套餐"
//            var shareImage: Any!
//            var shareUrl = ""
//            if let valueStr = self.detailUrl {
//                shareUrl = valueStr + "&signUp=1"
//            }
//
//            shareImage = UIImage.init(named: "shareImage")!
//            if let valueStr = self.plusModel?.picUrl {
//                if valueStr != "" {
//                    shareImage = APIURL.ossPicUrl + valueStr
//                }
//            }
//
//            let messageObject = UMSocialMessageObject()
//            let shareObject = UMShareWebpageObject.shareObject(withTitle: shareTitle, descr: shareDescr, thumImage: shareImage)
//            shareObject?.webpageUrl = shareUrl
//            messageObject.shareObject = shareObject
//
//            UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self, completion: { (data, error) in
//
//                if error != nil {
//                    AppLog("************Share fail with error \(error!)************")
//
//                }else {
//
//                    if let resp = data as? UMSocialShareResponse {
//
//                        AppLog("response message is \(String(describing: resp.message))")
//                        AppLog("response originalResponse data is \(String(describing: resp.originalResponse))")
//
//                    }else {
//                        AppLog("response data is \(data!)")
//                    }
//                }
//            })
//        }
    }
    
    @objc func buyBtnAction(_ sender: UIButton) {
        
        let vc = SureInfoController()
        vc.plusModel = plusModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: - webView
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress"{
            progressView.alpha = 1.0
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("开始获取网页内容")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("加载完成")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("加载失败")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let urlStr = navigationAction.request.url?.absoluteString
        let isContains = urlStr?.contains("/yzbPlus/getPlusDetails")
        
        if isContains == nil || isContains == false {
            navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction)),UIBarButtonItem(image: UIImage(named: "podBack_nav"), style: .plain, target: self, action: #selector(backPopAction))]
            
            decisionHandler(WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
            bottomView.snp.remakeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(0)
            }
        }else {
            navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))]
            
            bottomView.snp.remakeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
                } else {
                    make.height.equalTo(44)
                }
            }
            decisionHandler(.allow)
        }
    }

}
