//
//  VRDeatilController.swift
//  YZB_Company
//
//  Created by yzb_ios on 30.11.2018.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import ObjectMapper

class VRDetailController: BaseViewController, WKNavigationDelegate {
    
    var backBtn: UIButton!                  //返回按钮
    var shareBtn: UIButton!                 //分享
    var webView: WKWebView!
    var progressView: UIProgressView!
    var vrModel: VRdesignModel?
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> VR详情页释放 <<<<<<<<<<<<<<<<<<")
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.navigationDelegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        createSubView()
        prepareNavigationItem()
        
        if let urlStr = vrModel?.renderpicPanoUrl {
            let request = URLRequest.init(url:  URL.init(string: urlStr)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            webView.load(request)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        self.statusStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let urlStr = URLRequest.init(url: URL.init(string: "about:blank")!)
        webView.load(urlStr)
    }
    
    func prepareNavigationItem() {
        
        //返回按钮
        backBtn = UIButton.init()
        backBtn.setImage(UIImage(named: "back_white"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.4)
        backBtn.layer.cornerRadius = 17
        backBtn.layer.masksToBounds = true
        view.addSubview(backBtn)
        
        backBtn.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            } else {
                make.top.equalTo(view.snp.top).offset(26)
            }
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(34)
        }
        
        //分享按钮
//        shareBtn = UIButton.init()
//        shareBtn.setImage(UIImage(named: "share_nav_white"), for: .normal)
//        shareBtn.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
//        shareBtn.backgroundColor = backBtn.backgroundColor
//        shareBtn.layer.cornerRadius = backBtn.layer.cornerRadius
//        shareBtn.layer.masksToBounds = true
//        view.addSubview(shareBtn)
//
//        shareBtn.snp.makeConstraints { (make) in
//            make.centerX.equalTo(backBtn)
//            make.top.equalTo(backBtn.snp.bottom).offset(20)
//            make.width.height.equalTo(backBtn)
//        }
        
        //清单按钮
        let listBtn = UIButton.init()
        let bgImg = PublicColor.gradualColorImage
        listBtn.setBackgroundImage(bgImg, for: .normal)
        listBtn.addTarget(self, action: #selector(listAction), for: .touchUpInside)
        listBtn.setTitle("一键下单", for: .normal)
        listBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        listBtn.layer.cornerRadius = 17
        listBtn.layer.masksToBounds = true
        view.addSubview(listBtn)
        
        listBtn.snp.makeConstraints { (make) in
            make.right.equalTo(view.snp.right).offset(17)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(93)
            make.height.equalTo(33)
        }
    }
    
    func createSubView() {
        
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
            make.left.bottom.right.top.equalToSuperview()
        }
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        //进度条
        progressView = UIProgressView()
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = PublicColor.progressColor
        progressView.transform = CGAffineTransform.init(scaleX: 1, y: 2)
        progressView.progress = 0.05 //设置初始值，防止网页加载过慢时没有进度
        view.addSubview(progressView)
        
        progressView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(20)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    
    //MARK: - 触发事件
    
    @objc func backAction() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareAction() {
        
        var storeName = ""
        if let valueStr = UserData.shared.workerModel?.store?.name {
            storeName = valueStr
        }
        
        guard let shareUrl = self.vrModel?.renderpicPanoUrl else { return }
        
        let shareTitle = (self.vrModel?.name)!
        _ = "来自 \(storeName) 分享的VR方案"
        var shareImage: Any!
        
        shareImage = UIImage.init(named: "shareImage")!
        if let valueStr = self.vrModel?.coverPic {
            if valueStr != "" {
                shareImage = valueStr
            }
        }
        let items = [shareTitle, shareImage as Any, shareUrl] as [Any]
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
//            guard let shareUrl = self.vrModel?.renderpicPanoUrl else { return }
//
//            let shareTitle = (self.vrModel?.name)!
//            let shareDescr = "来自 \(storeName) 分享的VR方案"
//            var shareImage: Any!
//
//            shareImage = UIImage.init(named: "shareImage")!
//            if let valueStr = self.vrModel?.coverPic {
//                if valueStr != "" {
//                    shareImage = valueStr
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
    
    @objc func listAction(_ sender: UIButton) {
        
        sender.removeTarget(self, action: #selector(listAction), for: .touchUpInside)
        
        guard let storeId = UserData.shared.storeModel?.id else{
            fatalError("storeId is nil")
        }
       
        guard let listingId = vrModel?.listingId else {
            fatalError("listingId is nil")
        }
        
        //type: 1.套餐开单  2.自由开单
        let parameters: Parameters = ["storeId": storeId, "listingId": listingId]
        
        self.pleaseWait()
        let urlStr = APIURL.listingToOrder

        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            sender.addTarget(self, action: #selector(self.listAction), for: .touchUpInside)
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dateDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                if let arr = dateDic.value(forKey: "materList") as? [[String: Any]] {
                    let materials = Mapper<MaterialsModel>().mapArray(JSONArray: arr)
                    let vc = PlaceOrderController()
                    vc.materials1 = materials
                   // vc.isOneKey = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                
            }else {
                self.noticeOnlyText("套餐信息匹配失败~")
            }

        }) { (error) in
            
            self.noticeOnlyText("套餐信息匹配失败~")
            sender.addTarget(self, action: #selector(self.listAction), for: .touchUpInside)
        }
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
        
        decisionHandler(WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
    }

}
