//
//  HoIconButton.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/11.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class HoIconButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 22
        self.layer.masksToBounds = true
    }
    

}
