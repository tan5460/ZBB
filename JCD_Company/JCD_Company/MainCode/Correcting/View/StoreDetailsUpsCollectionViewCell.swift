//
//  StoreDetailsUpsCollectionViewCell.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/7.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class StoreDetailsUpsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var displayName: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let color = UIColor.init(netHex: 0x23AC38)
        bg.layer.borderColor = color.cgColor
        bg.layer.borderWidth = 1
        bg.layer.cornerRadius = self.frame.size.height / 2
        bg.layer.masksToBounds = true
        bg.backgroundColor = UIColor.init(netHex: 0xEEFAF0)
    }
    
    var model: HoStoreModel! {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        displayName?.text = model?.name
        displayName?.textColor = model?.showColor
        bg.isHidden = !model.isSelected
    }

    var brand: HoBrandModel! {
        didSet {
            displayName?.text = brand?.brandName
            displayName?.textColor = brand?.showColor
            bg.isHidden = !brand.isSelected
        }
    }
    
    var spe: HoSpecSubModel! {
        didSet {
            displayName?.text = spe?.transformName
            displayName?.textColor = spe?.showColor
            bg.isHidden = !spe.isSelected
        }
    }
    
}
extension HoBrandModel {
    
    var showColor: UIColor! {
        get {
            return isSelected ? UIColor.init(netHex: 0x23AC38) : UIColor.init(netHex:  0x1e1e1e)
        }
    }
}
extension HoSpecSubModel {
    
    var showColor: UIColor! {
        get {
            return isSelected ? UIColor.init(netHex: 0x23AC38) : UIColor.init(netHex:  0x1e1e1e)
        }
    }
}

extension HoStoreModel {
    
    var showColor: UIColor! {
        get {
            return isSelected ? UIColor.init(netHex: 0x23AC38) : UIColor.init(netHex:  0x1e1e1e)
        }
    }
}
