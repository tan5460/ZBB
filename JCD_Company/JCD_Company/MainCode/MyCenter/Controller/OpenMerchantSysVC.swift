//
//  OpenMerchantSysVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/19.
//

import UIKit
import WebKit

class OpenMerchantSysVC: BaseViewController {

    var merchantType: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "开通商户系统"
        
        let bindAccountBtn = UIButton().text("绑定已有账户").textColor(.k1DC597).font(14)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: bindAccountBtn)
        bindAccountBtn.tapped { [weak self] (tapBtn) in
            self?.noticeOnlyText("111")
        }
        
        let webView = WKWebView()
        let bottomView = UIView().backgroundColor(.white)
        view.sv(webView, bottomView)
        view.layout(
            0,
            |webView|,
            0,
            |bottomView.height(146)|,
            0
        )
        webView.load(URLRequest.init(url: URL.init(string: "https://www.baidu.com")!))
        bottomView.addShadowColor()
        
        bindAccountBtn.tapped { [weak self] (tapBtn) in
            let vc = BindMerchantSysVC()
            vc.merchantType = self?.merchantType
            self?.navigationController?.pushViewController(vc)
        }
        
        configBottomView(v: bottomView)
    }
    
    func configBottomView(v: UIView) {
        let checkBtn = UIButton()
        checkBtn.setImage(#imageLiteral(resourceName: "login_uncheck"), for: .normal)
        checkBtn.setImage(#imageLiteral(resourceName: "login_check"), for: .selected)
        
        let lab1 = UILabel().text("我已阅读并同意").textColor(UIColor.hexColor("#AAAAAA")).font(10)
        let protocolBtn = UIButton().text("《入驻协议》").textColor(UIColor.hexColor("#1DC597")).font(10)
        let sureBtn = UIButton().text("立即开通").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_put_btn"))
        sureBtn.isEnabled = false
        v.sv(checkBtn, lab1, protocolBtn, sureBtn)
        v.layout(
            5,
            |-9-checkBtn.size(27)-0-lab1-0-protocolBtn.height(30),
            25,
            sureBtn.width(280).height(40).centerHorizontally(),
            >=0
        )
        checkBtn.tapped { (tapBtn) in
            checkBtn.isSelected = !checkBtn.isSelected
            sureBtn.isEnabled = checkBtn.isSelected
        }
        
        protocolBtn.tapped { [weak self] (tapBtn) in
            let rootVC = AgreementViewController()
            let vc = BaseNavigationController.init(rootViewController: rootVC)
            rootVC.type = .protocl
            vc.modalPresentationStyle = .fullScreen
            self?.navigationController?.present(vc, animated: true, completion: nil)
        }
        
        sureBtn.tapped { [weak self] (tapBtn) in
            self?.noticeOnlyText("111")
        }
    }

}
