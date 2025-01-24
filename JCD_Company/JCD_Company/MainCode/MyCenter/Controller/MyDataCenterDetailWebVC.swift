//
//  MyDataCenterDetailWebVC.swift
//  YZB_Company
//
//  Created by Cloud on 2020/3/12.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import WebKit

class MyDataCenterDetailWebVC: BaseViewController, WKNavigationDelegate {
    var urlStr = ""
    var webView:WKWebView?
    lazy private var progressView: UIProgressView = {
        self.progressView = UIProgressView.init(frame: CGRect(x: CGFloat(0), y: CGFloat(1), width: UIScreen.main.bounds.width, height: 2))
        self.progressView.tintColor = UIColor.green      // 进度条颜色
        self.progressView.trackTintColor = UIColor.white // 进度条背景色
        return self.progressView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height))
        view.addSubview(webView!)
        view.addSubview(progressView)
        webView?.load(URLRequest.init(url: URL.init(string: urlStr)!))
        webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView?.navigationDelegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
        //  加载进度条
            if keyPath == "estimatedProgress"{
                progressView.alpha = 1.0
                progressView.setProgress(Float((self.webView?.estimatedProgress) ?? 0), animated: true)
                if (self.webView?.estimatedProgress ?? 0.0)  >= 1.0 {
                    UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                        self.progressView.alpha = 0
                    }, completion: { (finish) in
                        self.progressView.setProgress(0.0, animated: false)
                    })
                }
            }
        }
    
    deinit {
        debugPrint("\(type(of: self).className) 释放了")
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView?.uiDelegate = nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
