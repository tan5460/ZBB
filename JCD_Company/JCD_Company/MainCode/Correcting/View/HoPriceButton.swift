//
//  HoPriceButton.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/7.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class HoPriceButton: UIView {

    
    @IBOutlet private weak var displayTitle: UILabel!
    
    @IBOutlet private weak var up:   UIImageView!
    @IBOutlet private weak var down: UIImageView!
   
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
        updateUI()
        delegate?.stateChanged(state: state)
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
            displayTitle.textColor = UIColor.init(netHex: 0x1e1e1e)
            up.image = UIImage.init(named: normalUp)
            down.image = UIImage.init(named: selDown)
        }
        else if curIndex == 2 {
            displayTitle.textColor = UIColor.init(netHex: 0x1e1e1e)
            up.image = UIImage.init(named: selUp)
            down.image = UIImage.init(named: normalDown)
        }
        else if curIndex == 0 {
            displayTitle.textColor = UIColor.init(netHex: 0x999999)
            up.image = UIImage.init(named: normalUp)
            down.image = UIImage.init(named: normalDown)
        }
        
    }
    
}
