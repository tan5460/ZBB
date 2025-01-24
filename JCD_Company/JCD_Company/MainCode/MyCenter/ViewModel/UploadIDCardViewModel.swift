//
//  UploadIDCardViewModel.swift
//  YZB_Company
//
//  Created by Mac on 24.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

/**
 * 处理UploadIDCardViewController逻辑
 * 1.字符输入
 * 2.照片添加
 */

import UIKit

//TODO: - 9.24
@objc protocol UploadIDCardViewModelDelegate {
    
    /// 提示信息
    func alertInfo(_ text: String)
    
    /// 更新界面
    func updateUI()
    
    /// 提示自动隐藏
    func alertInfoAutoRelease(_ text: String)
    
}

private protocol UploadIDCardInterface {
    
    var delegate: UploadIDCardViewModelDelegate! { set get}
    
    /// 添加营业执照
    func addLicenseAction()
    
    

}


class UploadIDCardViewModel: NSObject, UploadIDCardInterface {
   

    weak var delegate: UploadIDCardViewModelDelegate!
    
    func addLicenseAction() {
        
    }

}
