//
//  HHeader.swift
//  YZB_Company
//
//  Created by Mac on 17.10.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

@objc protocol HProgressViewDeleagate {
    
    func layoutChanged(_ width: CGFloat)
}

class HProgressView: UIProgressView {

    weak var delegate: HProgressViewDeleagate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let hf = self.frame.width
        delegate?.layoutChanged(hf)
    }

}
