//
//  HoPriceLabel.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/11.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

enum HoPriceState: Int {
    case normal = 0
    case down = 1
    case up = 2
}
protocol HoPriceLabelDelegate {
    
    func stateChanged(state: HoPriceState)
}


class HoPriceLabel: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var up: UIImageView!
    @IBOutlet private weak var down: UIImageView!
    @IBOutlet private weak var line: UIView!

    private var curIndex = 0;
    
    var delegate: HoPriceLabelDelegate?
    
    var state: HoPriceState {
        get {
            return HoPriceState.init(rawValue: curIndex) ?? .normal
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        curIndex += 1
        if curIndex == 3 {
            curIndex = 1
        }
        delegate?.stateChanged(state: state)

        updateUI()
    }
    
    func setNormal() {
        curIndex = 0
        updateUI()
    }
    
    private func updateUI() {
        
        let normalUp = "arrow_up_unsel"
        let normalDown = "arrow_down_unsel"
        let selUp = "arrow_down"
        let selDown = "arrow_down_sel"
        
        if curIndex == 1 {
            titleLabel.textColor = UIColor.init(netHex: 0x1e1e1e)
            line.isHidden = false
            up.image = UIImage.init(named: normalUp)
            down.image = UIImage.init(named: selDown)
        }
        else if curIndex == 2 {
            titleLabel.textColor = UIColor.init(netHex: 0x1e1e1e)
            line.isHidden = false
            up.image = UIImage.init(named: selUp)
            down.image = UIImage.init(named: normalDown)
        }
        else if curIndex == 0 {
            titleLabel.textColor = UIColor.init(netHex: 0x999999)
            line.isHidden = true
            up.image = UIImage.init(named: normalUp)
            down.image = UIImage.init(named: normalDown)
        }
        
    }
    
}
