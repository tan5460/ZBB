//
//  LoginViewModel.swift
//  YZB_Company
//
//  Created by HOA on 2019/9/11.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation
import UIKit

@objc protocol LoginViewModelDelegate {
    
    func reloadViews()
    func moveToHomeScreen()
    func reloadSwitchViews(sender: UIButton)
}

private protocol LoginViewModelInterface {
    
    var delegate: LoginViewModelDelegate? { get set }
    
    func accountFieldDidChange(text: String?)
    func switchAction(sender: UIButton)
    
    var normalViewEnable: Bool {get}
    var otherViewEnable:  Bool {get}

    func login()
}

public class LoginViewModel: LoginViewModelInterface {
    
    var normalViewEnable: Bool = true
    
    var otherViewEnable: Bool = false
    

    var delegate: LoginViewModelDelegate?
    
    private var account: String?
    
    private var accountVaild    = false

    
    /// 判断手机号或账号
    func accountFieldDidChange(text: String?) {
        accountVaild = text!.count >= 6
    }
    
    /// 切换登录模式
    func switchAction(sender: UIButton) {
        
        if sender.tag != 100 {
            normalViewEnable = false
            otherViewEnable  = true
        }else {
            normalViewEnable = true
            otherViewEnable  = false
        }
        delegate?.reloadSwitchViews(sender: sender)
    }
    
    func login() {
        
    }
}
