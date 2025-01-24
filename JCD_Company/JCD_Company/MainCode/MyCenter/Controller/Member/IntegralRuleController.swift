//
//  IntegralRuleController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/20.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import WebKit

class IntegralRuleController: BaseViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 积分规则页释放 <<<<<<<<<<<<<<<<<<")
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.navigationDelegate = nil
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "积分规则"

        createSubView()
    }
    
    func createSubView() {
        
        //webView
        webView = WKWebView()
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let urlStr = APIURL.VIPIntegralRule
        let request = URLRequest.init(url:  URL.init(string: urlStr)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20.0)
        webView.load(request)
        
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
    
    //MARK: - 按钮点击事件
    
    //返回
    @objc func backAction() {
        
        self.dismiss(animated: true, completion: nil)
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
        decisionHandler(.allow);
    }
    
    

}
