//
//  MemberAuthSuccessVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/19.
//

import UIKit
import ObjectMapper

class MemberAuthSuccessVC: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(back))
        
        let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_success"))
        let tip = UILabel().text("你的资料已提交，\n审核结果将以短信形式通知您！ ").textColor(.kColor33).font(14).textAligment(.center)
        let tip1 = UILabel().text("（正常3个工作日审核完毕）").textColor(.kColor99).font(12)
        let backBtn = UIButton().text("返回").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_put_btn"))
        tip.numberOfLines(2).lineSpace(2)
        tip.textAligment(.center)
        view.sv(icon, tip, tip1, backBtn)
        view.layout(
            82,
            icon.width(230).height(218).centerHorizontally(),
            20,
            tip.centerHorizontally(),
            4,
            tip1.height(16.5).centerHorizontally(),
            49.5,
            backBtn.width(280).height(44).centerHorizontally(),
            >=0
        )
        tip1.isHidden = true
        backBtn.tapped { [weak self] (btn) in
            self?.back()
        }
    }
    
    @objc func back() {
        self.getUserInfoRequest()
    }
    
    func getUserInfoRequest() {
        pleaseWait()
        YZBSign.shared.request(APIURL.getUserInfo, method: .get, parameters: Parameters(), success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
                UserData.shared.userInfoModel = infoModel
                self.navigationController?.viewControllers.forEach({ (vc) in
                    if vc.isKind(of: MaterialsDetailVC.classForCoder()) {
                        self.navigationController?.popToViewController(vc, animated: false)
                    } else if vc.isKind(of: MarketMateriasDetailVC.classForCoder()) {
                        self.navigationController?.popToViewController(vc, animated: false)
                    }
                })
            }
        }) { (error) in
            
        }
    }
}
