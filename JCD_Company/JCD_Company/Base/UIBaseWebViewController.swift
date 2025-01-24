//
//  UIBaseWebViewController.swift
//  TD
//
//  Created by 巢云 on 2020/3/30.
//  Copyright © 2020 chaoyun. All rights reserved.
//

import UIKit
import WebKit
import TLTransitions

class UIBaseWebViewController: BaseViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView!
    var progressView: UIProgressView!
    var urlStr: String?
    var isShare = false
    var materialId = ""
    private var pop: TLTransition?
    deinit {
        debugPrint("\(type(of: self).className) 释放了")
        if webView != nil {
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.navigationDelegate = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44)).image(#imageLiteral(resourceName: "share_nav"))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: shareBtn)
        shareBtn.addTarget(self, action: #selector(shareBtnClick(btn:)))
        if isShare {
            shareBtn.isHidden = true
        }
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = PublicColor.commonTextColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: PublicColor.commonTextColor]
        createSubView()
    }
    
    @objc private func shareBtnClick(btn: UIButton) {
        let shareTitle = title ?? ""
        let urlStr1 = urlStr?.components(separatedBy: "?id").first
        configShareSelectView(title: shareTitle, des: "戳一下，查看详情！", imageStr: nil, urlStr: urlStr1, vc: self)
    }
    
    func createSubView() {
        var urlStr1 = ""
        var url: URL!
        if !(urlStr?.contains("?") ?? false) {
            guard let urlStr2 = urlStr, let url1 = URL.init(string: urlStr2 + "?type=1") else {
                noticeOnlyText("地址出了点问题～")
                return
            }
            url = url1
            urlStr1 = urlStr2
        } else {
            guard let urlStr2 = urlStr, let url1 = URL.init(string: urlStr2) else {
                noticeOnlyText("地址出了点问题～")
                return
            }
            url = url1
            urlStr1 = urlStr2
        }
        ///偏好设置
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.selectionGranularity = WKSelectionGranularity.character
        configuration.userContentController = WKUserContentController()
        // 给webview与swift交互起名字，webview给swift发消息的时候会用到
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "openDetailById")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "openMarketDetailById")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "enterMaterialDetail")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "myPosition")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "getRegistionId")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "getUserInfo")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "saveUserInfo")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "scanCode")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "alertl")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "appShareOpenOrDownload")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "appImmediatelyOpened")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "payActivity")
        configuration.userContentController.add(WeakScriptMessageDelegate(self), name: "shareInvitation")
        //webView
        webView = WKWebView.init(frame: .zero, configuration: configuration)
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if isShare {
            let url1 = URL.init(string: urlStr1)!
            let request = URLRequest.init(url: url1, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20.0)
            webView.load(request)
        } else {
            let request = URLRequest.init(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20.0)
            webView.load(request)
        }
        
        
        //进度条
        progressView = UIProgressView()
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = PublicColor.emphasizeColor
        progressView.transform = CGAffineTransform.init(scaleX: 1, y: 2)
        progressView.progress = 0.05 //设置初始值，防止网页加载过慢时没有进度
        view.addSubview(progressView)
        
        progressView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        ///接收js调用方法
        ///在控制台中打印html中console.log的内容,方便调试
        let body = message.body
        debugPrint("--------js交互了------------")
        if message.name == "logger" {
            debugPrint("JS Log \(body)")
            return
        }
        ///message.name是约定好的方法名,message.body是携带的参数
        switch message.name {
        case "openDetailById":
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 0 || UserData.shared.userInfoModel?.yzbVip?.vipType ?? 0 > 1 {
                let id = message.body as! String
                let vc = MaterialsDetailVC()
                let materialModel = MaterialsModel()
                materialModel.id = id
                vc.materialsModel = materialModel
                navigationController?.pushViewController(vc)
            } else {
                self.vipDistTipPopView()
            }
        case "openMarketDetailById":
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 0 || UserData.shared.userInfoModel?.yzbVip?.vipType ?? 0 > 1 {
                let id = message.body as! String
                let vc = MarketMateriasDetailVC()
                let materialModel = MaterialsModel()
                materialModel.id = id
                vc.materialsModel = materialModel
                navigationController?.pushViewController(vc)
            } else {
                self.vipDistTipPopView()
            }
        case "enterMaterialDetail":
            let vc = MaterialsDetailVC()
            let materialModel = MaterialsModel()
            materialModel.id = materialId
            vc.materialsModel = materialModel
            navigationController?.pushViewController(vc)
        case "payActivity":
            let vc = MembershipLevelsVC()
            navigationController?.pushViewController(vc)
        case "appShareOpenOrDownload":
            let urlStr = APIURL.webUrl + "/other/jcd-active-h5/#/share-h5?id=\(UserData1.shared.tokenModel?.userId ?? "")"
            configShareSelectView(title: "下载聚材道APP获代金券", des: "聚材道APP，方便装饰公司、设计师、产业工人等会员使用的业务直接对接工具，立即下载注册为会员得代金券", imageStr: nil, urlStr: urlStr, vc: self)
        case "appImmediatelyOpened":
            let vc = MembershipLevelsVC()
            navigationController?.pushViewController(vc)
        case "shareInvitation":
            let vc = SharePosterVC()
            navigationController?.pushViewController(vc)
        default:
            break
        }
    }
    
    //MARK: - 会员专区点击提醒框
    func vipDistTipPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 272, height: 210)).backgroundColor(.white)
        let icon = UIImageView().image(#imageLiteral(resourceName: "purchase_icon_vip_tip"))
        let titleLab = UILabel().text("很抱歉，会员专区仅限缴费会员使用，9.9元开通体验会员即可畅享").textColor(.kColor66).font(12)
        titleLab.numberOfLines(2).lineSpace(2)
        let ktBtn = UIButton().text("立即开通").textColor(.white).font(14)
        let cancelBtn = UIButton().text("取 消").textColor(.kColor66).font(12)
        v.sv(icon, titleLab, ktBtn, cancelBtn)
        v.layout(
            20,
            icon.size(50).centerHorizontally(),
            10,
            titleLab.width(236).centerHorizontally(),
            >=0,
            ktBtn.width(130).height(30).centerHorizontally(),
            5,
            cancelBtn.width(130).height(26.5).centerHorizontally(),
            15.5
        )
        
        ktBtn.corner(radii: 15).fillGreenColorLF()
        ktBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss(completion: {
                let vc = MembershipLevelsVC()
                self?.navigationController?.pushViewController(vc)
            })
        }
        cancelBtn.tapped { [weak self] (tapBtn) in
            self?.pop?.dismiss()
        }
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
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
        } else if keyPath == "title"{
            if self.title == nil {
                self.title = webView.title
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


class WeakScriptMessageDelegate: NSObject, WKScriptMessageHandler {
    
    weak var scriptDelegate: WKScriptMessageHandler?
    
    init(_ scriptDelegate: WKScriptMessageHandler) {
        super.init()
        self.scriptDelegate = scriptDelegate
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        scriptDelegate?.userContentController(userContentController, didReceive: message)
    }
}
