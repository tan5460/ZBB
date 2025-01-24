//
//  THTextField.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/3/29.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit


protocol THTextFieldDelegate: NSObjectProtocol {
    func tHTextFieldDeleteBackward(_ textField: THTextField)
}


class THTextField: UITextField {
    
    weak var thDelegate: THTextFieldDelegate?
    
    override func deleteBackward() {
        super.deleteBackward()
        
        thDelegate?.tHTextFieldDeleteBackward(self)
    }

}
