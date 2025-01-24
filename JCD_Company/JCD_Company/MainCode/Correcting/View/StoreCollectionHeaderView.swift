//
//  StoreCollectionHeaderView.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/6.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import SkeletonView

@objc protocol StoreCollectionHeaderViewDelegate {
    
    func reload(section: Int)
}

class StoreCollectionHeaderView: UICollectionReusableView {

    @IBOutlet private weak var displayTitle: UILabel!
    
    @IBOutlet private weak var constantLabel: UILabel!
    @IBOutlet private weak var constantIcon: UIImageView!
    @IBOutlet private weak var actionButton: UIButton!
    
    weak var delegate: StoreCollectionHeaderViewDelegate?
    
    var section: Int = 0
    var model: HoStoreModel? {
        didSet {
            updateUI()
        }
    }
    
    
    
    @IBAction func hidden(_ sender: UIButton) {
        [constantIcon,constantLabel,actionButton].forEach { $0?.isHidden =  (model?.isOpen ?? false)  }
        delegate?.reload(section: section)
    }
    
    private func updateUI() {
        displayTitle?.text = model?.name
        [constantIcon,constantLabel,actionButton].forEach { $0?.isHidden =  !(model?.isOpen ?? false)  }
        
    }
    
    
}
