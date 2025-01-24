//
//  AgreementViewController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/2/27.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import WebKit

enum AgreementType {
    case protocl
    case protocl1
    case level
    case qualifications
}

class AgreementViewController: BaseViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    var type = AgreementType.protocl
    var urlStr = APIURL.VIPIntegralRule
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 服务协议页释放 <<<<<<<<<<<<<<<<<<")
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.navigationDelegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .protocl {
            if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                title = "入驻协议"
            } else {
                title = "注册条款"
            }
        } else if type == .protocl1 {
            title = "隐私条款"
        } else if type == .level {
            title = "等级说明"
        } else if type == .qualifications {
            title = "公司资质"
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = PublicColor.commonTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: PublicColor.commonTextColor]
        if type == .protocl || type == .protocl1 {
            prepareBackItem()
        }
        createSubView()
    }
    
    func prepareBackItem() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
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
        
        if type == .protocl {
            if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                urlStr = APIURL.registerAgreement1
            } else {
                urlStr = APIURL.registerAgreement
            }
        } else if type == .protocl1 {
            urlStr = APIURL.privacy_agreement
        } else if type == .qualifications {
        
        }
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
