//
//  ChangeIdentityController.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/23.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class ChangeIdentityController: BaseViewController {

    @IBOutlet weak var imageView: UIImageView! //头像
    @IBOutlet weak var identLabel: UILabel!    //身份
    @IBOutlet weak var changeBtn: UIButton!    //切换按钮
    @IBOutlet weak var backBtn: UIButton!      //返回按钮
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>> 切换身份界面释放 <<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "身份切换"
        
        changeBtn.layer.cornerRadius = 45/2
        changeBtn.layer.masksToBounds = true
        
        backBtn.layer.borderColor = PublicColor.partingLineColor.cgColor
        backBtn.layer.cornerRadius = 45/2
        backBtn.layer.borderWidth = 1
                
        if UserData.shared.userType == .jzgs {
            identLabel.text = "管理员"
            imageView.image = UIImage(named: "img_administrator")
            changeBtn.setTitle("切换采购模式", for: .normal)
        }else {
            identLabel.text = "采购员"
            imageView.image = UIImage(named: "img_buyer")
            changeBtn.setTitle("切换为管理员", for: .normal)
        }
    }


    @IBAction func backAction(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changAtion(_ sender: Any) {
        
        self.dismiss(animated: false) {
            
            if let window = UIApplication.shared.keyWindow {
                
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: {
                    let oldState: Bool = UIView.areAnimationsEnabled
                    UIView.setAnimationsEnabled(false)
                    
                    if UserData.shared.userType == .jzgs {
                        AppUtils.setUserType(type: .cgy)
                    }else {
                        AppUtils.setUserType(type: .jzgs)
                    }
                    
                    //更新极光用户信息
                    YZBChatRequest.shared.updateUserInfo(errorBlock: { (error) in
                    })
                    
                    window.rootViewController = MainViewController()
                    UIView.setAnimationsEnabled(oldState)
                })
            }
        }
    }
}
