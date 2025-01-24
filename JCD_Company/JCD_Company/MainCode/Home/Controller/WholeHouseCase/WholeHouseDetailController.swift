//
//  WholeHouseDetailController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/2.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import WebKit
import TLTransitions

class WholeHouseDetailController: BaseViewController, WKNavigationDelegate {
    
    var backBtn: UIButton!                  //返回按钮
    var shareBtn: UIButton!                  //分享
    var webView: WKWebView!
    var progressView: UIProgressView!
    var detailUrl: String?
    var caseModel: HouseCaseModel?
    var pop: TLTransition?
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 装修案例详情页释放 <<<<<<<<<<<<<<<<<<")
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.statusStyle = .lightContent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func prepareNavigationItem() {
        
        //返回按钮
        backBtn = UIButton.init()
        backBtn.setImage(UIImage(named: "back_white"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
        backBtn.layer.cornerRadius = 15
        backBtn.layer.masksToBounds = true
        view.addSubview(backBtn)
        
        backBtn.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(6)
            } else {
                make.top.equalTo(view.snp.top).offset(26)
            }
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(30)
        }
        
        //分享按钮
        shareBtn = UIButton.init()
        shareBtn.setImage(UIImage(named: "share_nav_white"), for: .normal)
        shareBtn.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        shareBtn.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x000000, alpha: 0.3)
        shareBtn.layer.cornerRadius = 15
        shareBtn.layer.masksToBounds = true
        view.addSubview(shareBtn)
        
        shareBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(30)
        }
        
        let zxBtn = UIButton().text("咨询").textColor(.white).font(14).backgroundColor(UIColor.hexColor("#FFFFFF", alpha: 0.2)).borderColor(.white).borderWidth(1).cornerRadius(15)
        view.addSubview(zxBtn)
        
        zxBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn)
            make.right.equalToSuperview().offset(-60)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        zxBtn.tapped { [weak self] (btn) in
            self?.zxBtnAction()
        }
        
        if caseModel?.userName == nil {
            zxBtn.isHidden = true
            shareBtn.isHidden = true
        }
    }
    
    func zxBtnAction() {
        let userName = caseModel?.userName ?? ""
        YZBChatRequest.shared.getUserInfo(with: userName) { (user, error) in
            self.clearAllNotice()
            if error == nil {
                YZBChatRequest.shared.createSingleMessageConversation(username: userName) { (conversation, error) in
                    if error == nil {
                        if (conversation?.target as? JMSGUser) != nil {
                            let vc = ChatMessageController(conversation: conversation!)
                            vc.convenUser = user
                            vc.caseModel = self.caseModel
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    }
                }
            }
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
        
        if webView.canGoBack {
            webView.goBack()
        }else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func shareAction() {
        configShareSelectView()
    }
    
    func configShareSelectView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height)).backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3045537243))
        v.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(shareGesTap)))
        let scanView = UIView().backgroundColor(.white).borderColor(UIColor.hexColor("#707070")).borderWidth(0.5)
        
        let shareView = ShareSelectView(frame: CGRect(x: 0, y: 0, width: view.width, height: 176)).backgroundColor(.white)
        shareView.shareSelectStyleBlock = { [weak self] (style) in
            let shareImage = UIImage.convertViewToImage(v: scanView)
            let shareImageData = shareImage.jpegData(compressionQuality: 1)
            let manager = ShareManager.init(data: shareImageData, vc: self)
            manager.shareSelectStyle = style
            manager.share()
            self?.pop?.dismiss()
        }
        shareView.cancelBtnBlock = { [weak self] in
            self?.pop?.dismiss()
        }
        let bottomView = UIView().backgroundColor(.white)
        v.sv(scanView, shareView, bottomView)
        v.layout(
            >=0,
            scanView.width(323).height(375).centerHorizontally(),
            92,
            shareView.width(view.width).height(176),
            0,
            bottomView.width(view.width).height(PublicSize.kBottomOffset).centerHorizontally(),
            0
        )
        let scanIcon = UIImageView()
        let scanLine = UIView().backgroundColor(UIColor.hexColor("#DEDEDE"))
        let scanLabel = UILabel().text("长按或扫描二维码查看详情").textColor(.kColor33).font(12)
        let scanIV = UIImageView().backgroundColor(.kBackgroundColor)
        scanView.sv(scanIcon, scanLine, scanLabel, scanIV)
        scanView.layout(
            20,
            |-20-scanIcon.width(283).height(250)-20-|,
            25,
            |-20-scanLine.width(30).height(4),
            15,
            |-20-scanLabel.width(100).height(33),
            >=0
        )
        scanView.layout(
            >=0,
            scanIV.size(70)-20-|,
            20
        )
        scanIcon.addImage(self.caseModel?.mainImgUrl)
        let scanImage = UIImage.setupQRCodeImage(self.detailUrl ?? "", image: nil)
        scanIV.image(scanImage)
        scanLabel.numberOfLines(2).lineSpace(2)
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
    }
    
    @objc func shareGesTap() {
        pop?.dismiss()
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
        let isContains = urlStr?.contains("yzb.store")
        if isContains == nil || isContains == false {
            decisionHandler(WKNavigationActionPolicy(rawValue: WKNavigationActionPolicy.allow.rawValue + 2)!)
            if caseModel?.userName == nil {
                shareBtn.isHidden = true
            } else {
                shareBtn.isHidden = false
            }
            
        }else {
            decisionHandler(.allow)
            if caseModel?.userName == nil {
                shareBtn.isHidden = true
            } else {
                shareBtn.isHidden = false
            }
        }
    }
    
}
