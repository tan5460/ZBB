//
//  HoSiLabel.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/11.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

@objc protocol HoSiLabelDelegate {
    
    func click()
}

class HoSiLabel: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var leftIcon: UIImageView!
    @IBOutlet private weak var line: UIView!

    var isSelected: Bool! {
        didSet {
            updateUI()
        }
    }
    
    weak var delegate: HoSiLabelDelegate?

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.click()
    }
    
    func updateUI() {
        
        let imageStr = isSelected ? "icon_filter_sel" : "icon_filter_unsel"
        let titleColor = isSelected ? 0x1e1e1e : 0x999999
        
        leftIcon.image = UIImage.init(named: imageStr)
        titleLabel.textColor = UIColor.init(netHex: titleColor)
        line.isHidden = !isSelected
    }
}
