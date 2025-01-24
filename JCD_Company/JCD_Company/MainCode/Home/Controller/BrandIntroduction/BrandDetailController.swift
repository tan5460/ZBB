//
//  BrandDetailController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/12/6.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import WebKit

class BrandDetailController: BaseViewController, WKNavigationDelegate{

    var webView: WKWebView!
    var progressView: UIProgressView!
    var detailUrl: String?
    var isShare:Bool = false
    var isOrderPay = false
    var shareImgUrl:String?
    var brandId:String?
    var brandName:String?
    var brandType: String?
    var categoryId: String?
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 品牌释放 <<<<<<<<<<<<<<<<<<")
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.navigationDelegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        
        if isShare {
            prepareNavigationItem()
        }
        createSubView()
    }
    func prepareNavigationItem() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "share_nav"), style: .plain, target: self, action: #selector(shareAction))
        
    }
    func createSubView() {
        
        let config = WKWebViewConfiguration()
        //HTML5视频是否内联播放的布尔值(true)或使用本机全屏控制器(false)。默认值是false
        config.allowsInlineMediaPlayback = true
//        config.requiresUserActionForMediaPlayback = false
        config.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
        
        //自适应手机屏幕
//        let jScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
//        let wkUScript = WKUserScript.init(source: jScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//        let wkUController = WKUserContentController()
//        wkUController.addUserScript(wkUScript)
//
//        config.userContentController = wkUController
        
        //webView
        webView = WKWebView.init(frame: CGRect.zero, configuration: config)
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        view.addSubview(webView)
    
        
        if brandId != nil {
            let backgroundImg = PublicColor.gradualColorImage
            let backgroundHImg = PublicColor.gradualHightColorImage
            let lookBtn = UIButton()
            lookBtn.setBackgroundImage(backgroundImg, for: .normal)
            lookBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
            lookBtn.setTitle("查看该品牌下所有产品", for: .normal)
            lookBtn.setTitleColor(UIColor.white, for: .normal)
            lookBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            lookBtn.addTarget(self, action: #selector(lookAction), for: .touchUpInside)
            view.addSubview(lookBtn)
            //lookBtn.isHidden = true
            
            lookBtn.snp.makeConstraints { (make) in
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(view.safeAreaLayoutGuide)
                } else {
                    make.bottom.equalTo(0)
                }
                make.left.equalTo(47.5)
                make.right.equalToSuperview().offset(-47.5)
                make.height.equalTo(40)
            }
            lookBtn.cornerRadius(20).masksToBounds()
            
            webView.snp.makeConstraints { (make) in
                make.bottom.equalTo(lookBtn.snp.top)
                make.left.right.top.equalToSuperview()
            }
        }else {
            webView.snp.makeConstraints { (make) in
                make.bottom.left.right.top.equalToSuperview()
            }
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
        
        if let urlStr = detailUrl {
            if urlStr.hasPrefix("http") {
                
                let request = URLRequest.init(url:  URL.init(string: urlStr)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
                webView.load(request)
            }else {
                webView.loadHTMLString(urlStr, baseURL: nil)
            }
        }else {
            progressView.isHidden = true
        }
        
    }
    
    //MARK: - 触发事件
    @objc func backAction() {
        
        if isOrderPay {
            if let viewControllers = self.navigationController?.viewControllers {
                if let vc = viewControllers[viewControllers.count-5] as? PurchaseDetailController {
                    vc.isPayQuery = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func shareAction() {
        var storeName = ""
        if let valueStr = UserData.shared.workerModel?.store?.name {
            storeName = valueStr
        }
        let shareTitle = self.title
        _ = "来自 \(storeName) 分享的品牌"
        var shareImage: Any!

        shareImage = UIImage.init(named: "shareImage")!
        if let valueStr = self.shareImgUrl{
            if valueStr != "" {
                shareImage = valueStr
            }
        }
        let items = [shareTitle as Any, shareImage as Any] as [Any]
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
//            var storeName = ""
//            if let valueStr = UserData.shared.workerModel?.store?.name {
//                storeName = valueStr
//            }
//            let shareTitle = self.title
//            let shareDescr = "来自 \(storeName) 分享的品牌"
//            var shareImage: Any!
//
//            shareImage = UIImage.init(named: "shareImage")!
//            if let valueStr = self.shareImgUrl{
//                if valueStr != "" {
//                    shareImage = valueStr
//                }
//            }
//
//            let messageObject = UMSocialMessageObject()
//            let shareObject = UMShareWebpageObject.shareObject(withTitle: shareTitle, descr: shareDescr, thumImage: shareImage)
//            shareObject?.webpageUrl = self.detailUrl
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
    
    @objc func lookAction() {
        
        let vc = HoBrandViewController()
        
        
//        let vc = MaterialSearchController()
//        vc.isSecondSearch = true
//        vc.isBrand = true
//        vc.categoryId = categoryId
//        vc.brandName = brandName ?? ""
//        vc.title = brandName ?? ""
        vc.brandType = brandType
        vc.brandName = brandName
        vc.brandId = brandId
        vc.categoryId = categoryId
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
    

}
