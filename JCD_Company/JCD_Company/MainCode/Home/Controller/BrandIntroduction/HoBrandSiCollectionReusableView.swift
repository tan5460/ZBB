//
//  HoBrandSiCollectionReusableView.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/11.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

@objc protocol HoBrandSiCollectionReusableViewDelegate {
    
    func up(_ didClick: IndexPath)
}

class HoBrandSiCollectionReusableView: UICollectionReusableView {

   
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var upButton: UIButton!
    
    var delegate: HoBrandSiCollectionReusableViewDelegate?
    
    var upIsHidden = false {
        didSet {
            upButton?.isHidden = upIsHidden
        }
    }
    var section: IndexPath!
    
    /// 显示标题
    var title: String? {
        didSet {
            titleLabel?.text = title
        }
    }
    
    @IBAction func up(_ sender: Any) {
        delegate?.up(section)
    }
    
}
