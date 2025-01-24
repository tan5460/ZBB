//
//  SelectIdentityController.swift
//  YZB_Company
//
//  Created by yzb_ios on 8.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Stevia

class SelectIdentityController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
       // loadSomeInfo()
        
        createSubView()
    }
    /// 这里的代码暂时不需要，微信支付宝不登录只授权，不需要隐藏
    func loadSomeInfo() {
        let hud = "".textShowLoading()
        let infoDictionary = Bundle.main.infoDictionary
        let OldVersion :AnyObject? = infoDictionary! ["CFBundleShortVersionString"] as AnyObject?
        let OldVersionStr = OldVersion as? String
        var path = "https://itunes.apple.com/cn/lookup?id="
        path = path + "1478207090"
        var version:String = ""
        Alamofire.request(path, method: .post).response { (responseObj) in
            hud.hide(animated: true)
            if responseObj.error == nil {
                let dic:Dictionary = try! JSONSerialization.jsonObject(with: responseObj.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
                if  dic["resultCount"] as! Int > 0{
                    let results:Array = dic["results"] as! Array<Any>
                    if results.count > 0 {
                        let resultsDic:Dictionary = results.first as! Dictionary<String,Any>
                        version = resultsDic["version"] as! String
                        if let oldVersionString = OldVersionStr, oldVersionString == version {
                            UserData1.shared.isNew = true
                        } else {
                            UserData1.shared.isNew = false
                        }
                    }
                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func createSubView() {
        let titleLab = UILabel().text("请选择您的身份").textColor(.kColor33).font(22, weight: .bold)
        let detailLab = UILabel().text("根据选择为您提供专属的服务").textColor(.kColor33).font(18)
        let memberBtn = UIButton().image(#imageLiteral(resourceName: "select_bg_image1"))
        let brandBtn = UIButton().image(#imageLiteral(resourceName: "select_bg_image2"))
        let serviceBtn = UIButton().image(#imageLiteral(resourceName: "select_bg_image3"))
        let subsitationBtn = UIButton().image(#imageLiteral(resourceName: "select_bg_image4"))
        
        let w = (PublicSize.screenWidth-60-25)/2
        let h = 210*w/145
        
        view.sv(titleLab, detailLab, memberBtn, brandBtn, serviceBtn, subsitationBtn)
        view.layout(
            PublicSize.kStatusBarHeight+51,
            titleLab.height(33.5).centerHorizontally(),
            15,
            detailLab.height(25).centerHorizontally(),
            60,
            |-30-memberBtn.width(w).height(h)-25-brandBtn-30-|,
            25,
            |-30-serviceBtn-25-subsitationBtn-30-|,
            >=0
        )
        equal(sizes: memberBtn, brandBtn, serviceBtn, subsitationBtn)
        let memberLab1 = UILabel().text("会员公司").textColor(.kColor33).font(18, weight: .bold)
        let memberLab2 = UILabel().text("专业的企业管家").textColor(.kColor66).font(14)
        // memberBtn.backgroundColor(.blue)
        memberBtn.sv(memberLab1, memberLab2)
        memberLab1.textAligment(.center)
        memberLab2.textAligment(.center)
        memberBtn.layout(
            120,
            |memberLab1.height(25)|,
            10,
            |memberLab2.height(20)|,
            >=0
        )
        //brandBtn.backgroundColor(.red)
        let brandLab1 = UILabel().text("品牌商").textColor(.kColor33).font(18, weight: .bold)
        let brandLab2 = UILabel().text("客户、订单管理系统").textColor(.kColor66).font(14)
        brandLab1.textAligment(.center)
        brandLab2.textAligment(.center)
        brandBtn.sv(brandLab1, brandLab2)
        brandBtn.layout(
            120,
            |brandLab1.height(25)|,
            10,
            |brandLab2.height(20)|,
            >=0
        )
        
        let serviceLab1 = UILabel().text("服务商").textColor(.kColor33).font(18, weight: .bold)
        let serviceLab2 = UILabel().text("装饰行业服务管家").textColor(.kColor66).font(14)
        serviceBtn.sv(serviceLab1, serviceLab2)
        serviceBtn.layout(
            120,
            serviceLab1.height(25).centerHorizontally(),
            10,
            serviceLab2.height(20).centerHorizontally(),
            >=0
        )
        
        let subsitationLab1 = UILabel().text("城市分站").textColor(.kColor33).font(18, weight: .bold)
        let subsitationLab2 = UILabel().text("行业资源梳理系统").textColor(.kColor66).font(14)
        subsitationBtn.sv(subsitationLab1, subsitationLab2)
        subsitationBtn.layout(
            120,
            subsitationLab1.height(25).centerHorizontally(),
            10,
            subsitationLab2.height(20).centerHorizontally(),
            >=0
        )
        
        memberBtn.addTarget(self, action: #selector(jzClickAction), for: .touchUpInside)
        brandBtn.addTarget(self, action: #selector(gysClickAction), for: .touchUpInside)
        serviceBtn.addTarget(self, action: #selector(fwsClickAction), for: .touchUpInside)
        subsitationBtn.addTarget(self, action: #selector(yysClickAction), for: .touchUpInside)
        memberBtn.addShadowColor()
        brandBtn.addShadowColor()
        serviceBtn.addShadowColor()
        subsitationBtn.addShadowColor()
    }
    
    @objc func jzClickAction() {
        
        AppUtils.setUserType(type: .cgy)
        let vc = LoginViewController()
        vc.title = "会员公司"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func gysClickAction() {
        
        AppUtils.setUserType(type: .gys)
        let vc = LoginViewController()
        vc.title = "品牌商"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func fwsClickAction() {
        
        AppUtils.setUserType(type: .fws)
        let vc = LoginViewController()
        vc.title = "服务商"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func yysClickAction() {
        
        AppUtils.setUserType(type: .yys)
        let vc = LoginViewController()
        vc.title = "城市分站"
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
