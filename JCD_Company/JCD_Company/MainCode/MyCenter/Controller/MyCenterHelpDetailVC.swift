//
//  MyCenterHelpDetailVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/24.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import WebKit
class MyCenterHelpDetailVC: BaseViewController {
    var model: HelpCenterModel?
    private let webView: WKWebView = WKWebView.init().backgroundColor(.white)
    private var progressView: UIProgressView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = model?.title
        view.sv(webView)
        view.layout(
            5,
            |webView|,
            0
        )
        //进度条
        progressView = UIProgressView()
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = PublicColor.emphasizeColor
        progressView.transform = CGAffineTransform.init(scaleX: 1, y: 2)
        progressView.progress = 0.05 //设置初始值，防止网页加载过慢时没有进度
        view.sv(progressView)
        view.layout(
            0,
            |progressView.height(1)|,
            >=0
        )

        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.loadHTMLString(model?.content ?? "", baseURL: nil)
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
        } else if keyPath == "title"{
            self.title = webView.title
        }
    }
}
