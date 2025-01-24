//
//  ZBBWebViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/15.
//

import UIKit
import WebKit

class ZBBWebViewController: BaseViewController {
    
    var url: String?
    
    private var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        
        if let url = url, let request = URLRequest(urlString: url) {
            webView.load(request)
        }
    }
    
    private func createViews() {
        webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    

}
